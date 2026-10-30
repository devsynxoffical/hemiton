import withdrawalRepository from '../repositories/withdrawal.repository.js';
import walletRepository from '../repositories/wallet.repository.js';
import ledgerService from './ledger.service.js';
import { sanitizeFinancial } from '../utils/bigint.util.js';
import prisma from '../config/database.js';

export async function getWithdrawals({ status, userId, page = 1, limit = 20 }) {
  const items = await withdrawalRepository.findAll({ status, userId, page, limit });
  const total = await withdrawalRepository.countAll({ status, userId });

  return {
    items: items.map((w) => sanitizeFinancial(w)),
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total,
      totalPages: Math.ceil(total / limit) || 1,
    },
  };
}

export async function approveWithdrawal({ id, adminId, isOwner = false, ipAddress }) {
  const request = await withdrawalRepository.findById(id);
  if (!request) {
    const error = new Error('Withdrawal request not found');
    error.status = 404;
    error.code = 'NOT_FOUND';
    throw error;
  }

  if (request.status !== 'PENDING') {
    const error = new Error(`Withdrawal request has already been processed with status: ${request.status}`);
    error.status = 400;
    error.code = 'ALREADY_PROCESSED';
    throw error;
  }

  const wallet = await walletRepository.findByUserId(request.userId);
  if (!wallet) {
    const error = new Error('Host wallet not found');
    error.status = 404;
    error.code = 'WALLET_NOT_FOUND';
    throw error;
  }

  const diamondsDebited = BigInt(request.diamondsDebited);
  const amountUSD = Number(request.amountUSD);

  return await prisma.$transaction(async (tx) => {
    // 1. Update WithdrawalRequest
    const updated = await withdrawalRepository.updateStatus(
      id,
      {
        status: 'APPROVED',
        reviewerAdminId: adminId,
        reviewedAt: new Date(),
      },
      tx
    );

    // 2. Post atomic ledger withdrawal
    const ledgerResult = await ledgerService.postTransaction({
      operations: [
        {
          walletId: wallet.id,
          diamondDelta: -diamondsDebited,
          usdDelta: -amountUSD,
          withdrawnDeltaUSD: amountUSD,
        },
      ],
      referenceId: `WD-${request.id}`,
      transactionType: 'WITHDRAWAL',
      db: tx,
    });

    // 3. Emit AuditLog
    await tx.auditLog.create({
      data: {
        adminId,
        adminName: isOwner ? 'Root Owner' : 'Administrator',
        action: 'WITHDRAWAL_APPROVED',
        targetEntity: 'WithdrawalRequest',
        targetEntityId: id,
        afterStateJson: {
          diamondsDebited: diamondsDebited.toString(),
          amountUSD,
          referenceId: ledgerResult.referenceId,
        },
        reason: `Approved diamond cashout of $${amountUSD} for host ${request.user?.username}`,
        ipAddress,
      },
    });

    return {
      success: true,
      message: 'Withdrawal approved and diamonds debited successfully.',
      withdrawal: sanitizeFinancial(updated),
      ledger: ledgerResult,
    };
  });
}

export async function rejectWithdrawal({ id, adminId, isOwner = false, reason, ipAddress }) {
  const request = await withdrawalRepository.findById(id);
  if (!request) {
    const error = new Error('Withdrawal request not found');
    error.status = 404;
    error.code = 'NOT_FOUND';
    throw error;
  }

  if (request.status !== 'PENDING') {
    const error = new Error(`Withdrawal request has already been processed with status: ${request.status}`);
    error.status = 400;
    error.code = 'ALREADY_PROCESSED';
    throw error;
  }

  return await prisma.$transaction(async (tx) => {
    const updated = await withdrawalRepository.updateStatus(
      id,
      {
        status: 'REJECTED',
        reviewerAdminId: adminId,
        rejectionReason: reason,
        reviewedAt: new Date(),
      },
      tx
    );

    await tx.auditLog.create({
      data: {
        adminId,
        adminName: isOwner ? 'Root Owner' : 'Administrator',
        action: 'WITHDRAWAL_REJECTED',
        targetEntity: 'WithdrawalRequest',
        targetEntityId: id,
        reason,
        ipAddress,
      },
    });

    return {
      success: true,
      message: 'Withdrawal request rejected.',
      withdrawal: sanitizeFinancial(updated),
    };
  });
}

function getCountryFlag(countryCode) {
  if (!countryCode || countryCode.length !== 2) return '🌐';
  try {
    const codePoints = countryCode
      .toUpperCase()
      .split('')
      .map(c => 127397 + c.charCodeAt(0));
    return String.fromCodePoint(...codePoints);
  } catch {
    return '🌐';
  }
}

/**
 * Fetch active, authorized withdrawal recipients filtered strictly by user ID country.
 * Supports COIN_SELLER and MERCHANT tabs.
 */
export async function getWithdrawalRecipients({ userId, type = 'COIN_SELLER' }, db = prisma) {
  const user = await db.user.findUnique({
    where: { id: userId },
    select: { id: true, countryCode: true, username: true },
  });

  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    error.code = 'USER_NOT_FOUND';
    throw error;
  }

  if (!user.countryCode || user.countryCode.trim() === '') {
    const error = new Error('No registered country saved for your user account. Please configure your account country before requesting withdrawals.');
    error.statusCode = 400;
    error.code = 'COUNTRY_NOT_SET';
    throw error;
  }

  const country = user.countryCode.trim().toUpperCase();
  const normalizedType = String(type).toUpperCase();

  if (normalizedType === 'MERCHANT') {
    const merchants = await db.merchant.findMany({
      where: {
        status: 'ACTIVE',
        user: {
          countryCode: country,
        },
      },
      include: {
        user: {
          select: { id: true, username: true, countryCode: true, profile: true },
        },
      },
    });

    return {
      country,
      type: 'MERCHANT',
      countryFlag: getCountryFlag(country),
      recipients: merchants.map(m => ({
        id: m.id,
        recipientId: m.id,
        userId: m.userId,
        name: m.companyName || m.user.profile?.displayName || m.user.username,
        uniqueId: m.user.username || m.id.slice(0, 8),
        role: 'MERCHANT',
        roleLabel: 'Authorized Merchant',
        countryCode: country,
        countryFlag: getCountryFlag(country),
        status: m.status,
      })),
    };
  }

  // Default: COIN_SELLER
  const sellers = await db.coinSeller.findMany({
    where: {
      sellerStatus: 'ACTIVE',
      user: {
        countryCode: country,
      },
    },
    include: {
      user: {
        select: { id: true, username: true, countryCode: true, profile: true },
      },
    },
  });

  return {
    country,
    type: 'COIN_SELLER',
    countryFlag: getCountryFlag(country),
    recipients: sellers.map(s => ({
      id: s.id,
      recipientId: s.id,
      userId: s.userId,
      name: s.businessName || s.user.profile?.displayName || s.user.username,
      uniqueId: s.user.username || s.id.slice(0, 8),
      role: 'COIN_SELLER',
      roleLabel: 'Authorized Coin Seller',
      countryCode: country,
      countryFlag: getCountryFlag(country),
      status: s.sellerStatus,
    })),
  };
}

export const CHANNEL_FEES = {
  USDT_TRC20: 2.00,
  USDT_BEP20: 1.00,
  BINANCE_PAY: 0.00,
  LOCAL_BANK_RAAST: 1.00,
  JAZZCASH: 1.00,
  EASYPAISA: 1.00,
  PAYONEER: 3.00,
  WIRE: 15.00,
  COIN_SELLER: 1.00,
  MERCHANT: 1.00,
};

export const HOST_TIERS = [
  { name: 'Platinum', minDiamonds: 200000, rate: 0.055, sharePercent: 55 },
  { name: 'Gold', minDiamonds: 50000, rate: 0.050, sharePercent: 50 },
  { name: 'Silver', minDiamonds: 10000, rate: 0.048, sharePercent: 48 },
  { name: 'Standard', minDiamonds: 0, rate: 0.045, sharePercent: 45 },
];

export function getHostTier(monthlyDiamonds) {
  const diamonds = Number(monthlyDiamonds || 0);
  return HOST_TIERS.find((t) => diamonds >= t.minDiamonds) || HOST_TIERS[3];
}

/**
 * Submit Host or Creator Withdrawal Request (HEMI TON Policy).
 * Re-validates user country, minimum $50.00, 2% platform fee, channel fee, and host tier.
 */
export async function createWithdrawalRequest({
  userId,
  recipientId,
  recipientRole = 'USDT_TRC20',
  payoutMethod = 'USDT_TRC20',
  cryptoAddress,
  binancePayId,
  bankAccountDetails,
  amountUSD,
  ipAddress,
}, db = prisma) {
  const parsedAmount = Number(amountUSD);
  if (!parsedAmount || isNaN(parsedAmount) || parsedAmount <= 0) {
    const error = new Error('Please enter a valid withdrawal amount greater than $0.00');
    error.statusCode = 400;
    error.code = 'INVALID_AMOUNT';
    throw error;
  }

  // HEMI TON Policy: Minimum withdrawal is USD 50.00
  if (parsedAmount < 50.0) {
    const error = new Error('Minimum withdrawal amount is $50.00 as per HEMI TON policy');
    error.statusCode = 400;
    error.code = 'MINIMUM_WITHDRAWAL_NOT_MET';
    throw error;
  }

  const user = await db.user.findUnique({
    where: { id: userId },
    include: {
      wallet: true,
      hostProfile: true,
      profile: true,
    },
  });

  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    error.code = 'USER_NOT_FOUND';
    throw error;
  }

  const userCountry = (user.countryCode || 'PK').trim().toUpperCase();

  // 48-Hour Wallet Modification Cooldown Check
  if (user.wallet?.updatedAt) {
    const hoursSinceUpdate = (Date.now() - new Date(user.wallet.updatedAt).getTime()) / (1000 * 60 * 60);
    const hoursSinceCreated = (Date.now() - new Date(user.createdAt).getTime()) / (1000 * 60 * 60);
    if (hoursSinceUpdate < 48 && hoursSinceCreated > 2) {
      // Wallet was recently altered
      const remainingHours = Math.ceil(48 - hoursSinceUpdate);
      const error = new Error(`Withdrawal locked for security: Payout details were modified recently. Cooldown active for ${remainingHours} more hours.`);
      error.statusCode = 403;
      error.code = 'WALLET_COOLDOWN_ACTIVE';
      throw error;
    }
  }

  // Calculate Host Tier & Diamond Conversion Rate
  const monthlyDiamonds = Number(user.hostProfile?.totalDiamondsEarnedMonth || user.profile?.totalEarnedDiamonds || 0);
  const hostTier = getHostTier(monthlyDiamonds);
  const hostRate = hostTier.rate; // 0.045 to 0.055

  // Validate available diamond balance
  const diamondBalance = Number(user.wallet?.diamondBalance || 0n);
  const pendingRequests = await db.withdrawalRequest.findMany({
    where: { userId, status: 'PENDING' },
  });
  const pendingUSD = pendingRequests.reduce((sum, w) => sum + Number(w.amountUSD), 0);
  const totalUSDValue = Math.round((diamondBalance * hostRate) * 100) / 100;
  const availableUSD = Math.max(0, Math.round((totalUSDValue - pendingUSD) * 100) / 100);

  if (availableUSD <= 0 || parsedAmount > availableUSD) {
    const error = new Error(`Insufficient available salary. Available: $${availableUSD.toFixed(2)}, Requested: $${parsedAmount.toFixed(2)}`);
    error.statusCode = 400;
    error.code = 'INSUFFICIENT_BALANCE';
    throw error;
  }

  // Determine effective payout method and channel fee
  const effectiveMethod = (payoutMethod || recipientRole || 'USDT_TRC20').toUpperCase();
  const channelFee = CHANNEL_FEES[effectiveMethod] ?? 1.00;
  const platformFee = Math.round(parsedAmount * 0.02 * 100) / 100; // 2% platform fee
  const netAmountUSD = Math.max(0, Math.round((parsedAmount - platformFee - channelFee) * 100) / 100);

  const diamondsDebited = BigInt(Math.ceil(parsedAmount / hostRate));

  return await db.$transaction(async (tx) => {
    const newRequest = await tx.withdrawalRequest.create({
      data: {
        userId,
        amountUSD: parsedAmount,
        diamondsDebited,
        payoutMethod: effectiveMethod,
        accountDetails: {
          recipientId: recipientId || null,
          payoutMethod: effectiveMethod,
          cryptoAddress: cryptoAddress || null,
          binancePayId: binancePayId || null,
          bankAccountDetails: bankAccountDetails || null,
          platformFeeUSD: platformFee,
          channelFeeUSD: channelFee,
          netAmountUSD,
          hostTier: hostTier.name,
          hostRate,
          country: userCountry,
          submittedAt: new Date().toISOString(),
        },
        status: 'PENDING',
      },
    });

    try {
      const fallbackAdmin = await tx.admin.findFirst({ select: { id: true, name: true } });
      if (fallbackAdmin) {
        await tx.auditLog.create({
          data: {
            adminId: fallbackAdmin.id,
            adminName: fallbackAdmin.name || 'Withdrawal Engine',
            action: 'HOST_WITHDRAWAL_REQUESTED',
            targetEntity: 'WithdrawalRequest',
            targetEntityId: newRequest.id,
            afterStateJson: {
              userId,
              amountUSD: parsedAmount,
              payoutMethod: effectiveMethod,
              platformFeeUSD: platformFee,
              channelFeeUSD: channelFee,
              netAmountUSD,
              hostTier: hostTier.name,
              hostRate,
              country: userCountry,
            },
            reason: `Host requested salary withdrawal of $${parsedAmount} via ${effectiveMethod} (Net: $${netAmountUSD}) in ${userCountry}`,
            ipAddress: ipAddress || '127.0.0.1',
          },
        });
      }
    } catch (_) {}

    return {
      success: true,
      message: `Withdrawal request for $${parsedAmount.toFixed(2)} (${effectiveMethod}) submitted successfully. Net payout: $${netAmountUSD.toFixed(2)}.`,
      withdrawal: sanitizeFinancial(newRequest),
    };
  });
}

export default {
  getWithdrawals,
  approveWithdrawal,
  rejectWithdrawal,
  getWithdrawalRecipients,
  createWithdrawalRequest,
};


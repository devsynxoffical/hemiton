// ============================================================
// Hemi Ton Admin Console — Testing Economy Policy Mock Data
// Purely for offline client testing & mathematical validation
// ============================================================

export const MOCK_GLOBAL_REVENUE_SPLIT = {
  version: 'v3.2.0-TEST',
  platformShare: 45,
  hostShare: 35,
  agencyShare: 12,
  roomReward: 8,
  status: 'ACTIVE',
  lastUpdated: new Date().toISOString(),
  notes: 'Testing baseline: 45% platform, 35% host, 12% agency, 8% room audio rewards'
};

export const MOCK_COUNTRY_OVERRIDES = [
  { id: 'ov-pk', country: 'PK', platform: 40, host: 40, agency: 12, room: 8, status: 'ACTIVE' },
  { id: 'ov-sa', country: 'SA', platform: 42, host: 38, agency: 12, room: 8, status: 'ACTIVE' },
  { id: 'ov-us', country: 'US', platform: 45, host: 35, agency: 12, room: 8, status: 'DEFAULT' },
  { id: 'ov-ae', country: 'AE', platform: 42, host: 38, agency: 12, room: 8, status: 'ACTIVE' },
  { id: 'ov-br', country: 'BR', platform: 40, host: 40, agency: 12, room: 8, status: 'ACTIVE' },
  { id: 'ov-tr', country: 'TR', platform: 41, host: 39, agency: 12, room: 8, status: 'ACTIVE' },
  { id: 'ov-eg', country: 'EG', platform: 38, host: 42, agency: 12, room: 8, status: 'ACTIVE' },
];

export const MOCK_EXCHANGE_RATES = [
  {
    id: 'ex-101',
    rateType: 'USD_TO_COIN',
    name: 'USD Standard Coin Recharge Rate',
    currency: 'USD',
    country: 'US',
    currentRate: 10000,
    proposedRate: 10500,
    unit: 'Coins / $1 USD',
    status: 'ACTIVE',
    version: 'v3.2.0',
    effectiveDate: '2026-08-01',
    history: [
      { version: 'v3.2.0', rate: 10000, effectiveDate: '2026-08-01', changedBy: 'Hemi Ton Lead Admin', notes: 'Baseline standard 10,000 coins per $1.00 USD.' }
    ]
  },
  {
    id: 'ex-102',
    rateType: 'DIAMOND_TO_USD',
    name: 'Creator Diamond Payout Rate',
    currency: 'USD',
    country: 'US',
    currentRate: 10000,
    proposedRate: 10000,
    unit: 'Diamonds / $1 USD',
    status: 'ACTIVE',
    version: 'v3.0.0',
    effectiveDate: '2026-01-01',
    history: [
      { version: 'v3.0.0', rate: 10000, effectiveDate: '2026-01-01', changedBy: 'Finance Admin', notes: 'Host payout conversion: 10,000 diamonds = $1 USD.' }
    ]
  },
  {
    id: 'ex-103',
    rateType: 'PK_LOCAL_CURRENCY',
    name: 'PKR Local Currency to Coin Rate',
    currency: 'PKR',
    country: 'PK',
    currentRate: 35,
    proposedRate: 38,
    unit: 'Coins / 1 PKR',
    status: 'ACTIVE',
    version: 'v3.3.0',
    effectiveDate: '2026-08-15',
    history: [
      { version: 'v3.2.0', rate: 35, effectiveDate: '2026-06-01', changedBy: 'Regional PK Ops', notes: 'Configured for local payment gateways.' }
    ]
  },
  {
    id: 'ex-104',
    rateType: 'SAR_LOCAL_CURRENCY',
    name: 'Saudi Riyal to Coin Rate',
    currency: 'SAR',
    country: 'SA',
    currentRate: 2660,
    proposedRate: 2700,
    unit: 'Coins / 1 SAR',
    status: 'ACTIVE',
    version: 'v3.1.0',
    effectiveDate: '2026-07-01',
    history: [
      { version: 'v3.1.0', rate: 2660, effectiveDate: '2026-07-01', changedBy: 'MENA Ops', notes: 'Pegged to 3.75 SAR/USD baseline.' }
    ]
  },
  {
    id: 'ex-105',
    rateType: 'AED_LOCAL_CURRENCY',
    name: 'UAE Dirham to Coin Rate',
    currency: 'AED',
    country: 'AE',
    currentRate: 2720,
    proposedRate: 2750,
    unit: 'Coins / 1 AED',
    status: 'ACTIVE',
    version: 'v3.1.0',
    effectiveDate: '2026-07-01',
    history: [
      { version: 'v3.1.0', rate: 2720, effectiveDate: '2026-07-01', changedBy: 'Gulf Finance', notes: 'Pegged to 3.67 AED/USD baseline.' }
    ]
  },
  {
    id: 'ex-106',
    rateType: 'EUR_TO_COIN',
    name: 'Eurozone Coin Rate',
    currency: 'EUR',
    country: 'DE',
    currentRate: 10800,
    proposedRate: 11000,
    unit: 'Coins / 1 EUR',
    status: 'ACTIVE',
    version: 'v3.0.0',
    effectiveDate: '2026-05-01',
    history: [
      { version: 'v3.0.0', rate: 10800, effectiveDate: '2026-05-01', changedBy: 'EU Ops', notes: 'FX pegged conversion rate.' }
    ]
  }
];

export const MOCK_TRANSFER_RATES = [
  {
    id: 'tr-201',
    transferType: 'CASHOUT_PROCESSING_FEE',
    name: 'Host Cashout Settlement Fee',
    description: 'Processing deduction on creator fiat bank transfers and crypto withdrawals',
    currentRatePercent: 2.5,
    proposedRatePercent: 2.0,
    status: 'ACTIVE',
    version: 'v2.1.0'
  },
  {
    id: 'tr-202',
    transferType: 'MERCHANT_ALLOCATION_FEE',
    name: 'Merchant Coin Allocation Fee',
    description: 'Processing percentage fee for authorized coin reseller bulk distribution',
    currentRatePercent: 1.8,
    proposedRatePercent: 2.0,
    status: 'ACTIVE',
    version: 'v1.4.0'
  },
  {
    id: 'tr-203',
    transferType: 'HOST_TO_HOST_TRANSFER_FEE',
    name: 'Peer-to-Peer Coin Transfer Fee',
    description: 'Platform commission fee for direct user-to-host transfers outside live rooms',
    currentRatePercent: 5.0,
    proposedRatePercent: 5.0,
    status: 'ACTIVE',
    version: 'v3.0.0'
  },
  {
    id: 'tr-204',
    transferType: 'AGENCY_SUB_COMMISSION',
    name: 'Agency Guild Sub-Commission',
    description: 'Management override fee credited to master agencies on sub-talent earnings',
    currentRatePercent: 3.0,
    proposedRatePercent: 3.5,
    status: 'ACTIVE',
    version: 'v2.0.0'
  }
];

export const MOCK_LIVE_HOST_TIERS = [
  { level: 1, targetDiamonds: 25000, durationDays: 10, basicSalaryUSD: 2.00, dailyHoursRequired: 1.0 },
  { level: 2, targetDiamonds: 50000, durationDays: 10, basicSalaryUSD: 4.00, dailyHoursRequired: 1.0 },
  { level: 3, targetDiamonds: 100000, durationDays: 10, basicSalaryUSD: 8.00, dailyHoursRequired: 1.0 },
  { level: 4, targetDiamonds: 250000, durationDays: 10, basicSalaryUSD: 20.00, dailyHoursRequired: 1.0 },
  { level: 5, targetDiamonds: 500000, durationDays: 8, basicSalaryUSD: 40.00, dailyHoursRequired: 1.0 },
  { level: 6, targetDiamonds: 1000000, durationDays: 8, basicSalaryUSD: 80.00, dailyHoursRequired: 1.0 },
  { level: 7, targetDiamonds: 2500000, durationDays: 8, basicSalaryUSD: 200.00, dailyHoursRequired: 1.0 },
  { level: 8, targetDiamonds: 5000000, durationDays: 5, basicSalaryUSD: 400.00, dailyHoursRequired: 1.0 },
  { level: 9, targetDiamonds: 10000000, durationDays: 5, basicSalaryUSD: 800.00, dailyHoursRequired: 1.0 },
  { level: 10, targetDiamonds: 20000000, durationDays: 5, basicSalaryUSD: 1600.00, dailyHoursRequired: 1.0 }
];

export const MOCK_AUDIO_HOST_TIERS = [
  { level: 1, tierName: '30K Audio Starter', targetCoins: 30000, dailyRewardUSD: 0.80, agencyProfitUSD: 0.15, minDailyHours: 2.0, durationDays: 10 },
  { level: 2, tierName: '60K Audio Bronze', targetCoins: 60000, dailyRewardUSD: 1.60, agencyProfitUSD: 0.30, minDailyHours: 2.0, durationDays: 10 },
  { level: 3, tierName: '100K Audio Silver', targetCoins: 100000, dailyRewardUSD: 2.80, agencyProfitUSD: 0.50, minDailyHours: 2.0, durationDays: 10 },
  { level: 4, tierName: '350K Audio Gold', targetCoins: 350000, dailyRewardUSD: 9.50, agencyProfitUSD: 1.70, minDailyHours: 2.0, durationDays: 10 },
  { level: 5, tierName: '1M Audio Platinum', targetCoins: 1000000, dailyRewardUSD: 28.00, agencyProfitUSD: 5.00, minDailyHours: 2.0, durationDays: 8 },
  { level: 6, tierName: '3M Audio VIP Master', targetCoins: 3000000, dailyRewardUSD: 90.00, agencyProfitUSD: 16.00, minDailyHours: 2.0, durationDays: 8 },
  { level: 7, tierName: '10M Audio Crown Royalty', targetCoins: 10000000, dailyRewardUSD: 320.00, agencyProfitUSD: 55.00, minDailyHours: 2.0, durationDays: 5 }
];

export const MOCK_RESELLER_PACKAGES = [
  { id: 'res-1', tierName: 'Silver Reseller Tier', priceUSD: 50, totalCoins: 525000, bonusCoins: 25000, profitPercent: 8 },
  { id: 'res-2', tierName: 'Gold Reseller Tier', priceUSD: 200, totalCoins: 2160000, bonusCoins: 160000, profitPercent: 10 },
  { id: 'res-3', tierName: 'Platinum Reseller Tier', priceUSD: 1000, totalCoins: 11200000, bonusCoins: 1200000, profitPercent: 12 },
  { id: 'res-4', tierName: 'VIP Master Reseller Tier', priceUSD: 5000, totalCoins: 58000000, bonusCoins: 8000000, profitPercent: 15 }
];

export const MOCK_WITHDRAWAL_POLICY = {
  minWithdrawalUSD: 25.0,
  maxDailyWithdrawalUSD: 5000.0,
  fourEyesApprovalThresholdUSD: 1000.0,
  fraudHoldPeriodHours: 24,
  autoApproveVerifiedHosts: true,
  status: 'ACTIVE'
};

// Returns the full database-like configs collection for /v1/admin/economy/configs
export function getMockEconomyConfigsPayload() {
  return [
    {
      id: 'cfg-eco-01',
      key: 'ECONOMY_POLICY_GLOBAL',
      name: 'Global Platform Revenue Allocation Policy',
      valueJson: {
        revenueSplit: MOCK_GLOBAL_REVENUE_SPLIT,
        countryOverrides: MOCK_COUNTRY_OVERRIDES,
      },
      status: 'ACTIVE',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'cfg-eco-02',
      key: 'EXCHANGE_RATES',
      name: 'Fiat and Virtual Currency Conversion Rates',
      valueJson: MOCK_EXCHANGE_RATES,
      status: 'ACTIVE',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'cfg-eco-03',
      key: 'TRANSFER_RATES',
      name: 'Platform Commission & Transfer Fee Matrix',
      valueJson: MOCK_TRANSFER_RATES,
      status: 'ACTIVE',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'cfg-eco-04',
      key: 'LIVE_HOST_TIERS',
      name: 'Live Video Host Salary Schedule',
      valueJson: MOCK_LIVE_HOST_TIERS,
      status: 'ACTIVE',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'cfg-eco-05',
      key: 'AUDIO_HOST_TIERS',
      name: 'Multi-Speaker Audio Party Host Compensation',
      valueJson: MOCK_AUDIO_HOST_TIERS,
      status: 'ACTIVE',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'cfg-eco-06',
      key: 'RESELLER_PACKAGES',
      name: 'Merchant Coin Reseller Margin Tiers',
      valueJson: MOCK_RESELLER_PACKAGES,
      status: 'ACTIVE',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'cfg-eco-07',
      key: 'WITHDRAWAL_POLICY',
      name: 'Host Withdrawal & Four-Eyes Threshold Policy',
      valueJson: MOCK_WITHDRAWAL_POLICY,
      status: 'ACTIVE',
      updatedAt: new Date().toISOString(),
    },
  ];
}

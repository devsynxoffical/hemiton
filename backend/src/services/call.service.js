// ==============================================================================
// HEMI TON — Voice & Video Calling Service
// Chatta-style Calling Lifecycle, Friend Verification & Agora RTC Provisioning
// ==============================================================================

import crypto from 'crypto';
import prisma from '../config/database.js';
import * as socialRepository from '../repositories/social.repository.js';
import { generateAgoraRtcToken, deriveAgoraUid, AGORA_ROLES } from '../utils/agoraToken.util.js';

export const CALL_STATUS = {
  INITIATED: 'INITIATED',
  RINGING: 'RINGING',
  ACCEPTED: 'ACCEPTED',
  REJECTED: 'REJECTED',
  CANCELLED: 'CANCELLED',
  ENDED: 'ENDED',
  MISSED: 'MISSED',
  FAILED: 'FAILED',
  BUSY: 'BUSY',
};

export const CALL_TYPE = {
  VOICE_1ON1: 'VOICE_1ON1',
  VIDEO_1ON1: 'VIDEO_1ON1',
  VOICE_GROUP: 'VOICE_GROUP',
};

/**
 * Initiates a new 1-on-1 voice or video call to an eligible friend.
 */
export async function initiateCall({ callerId, recipientId, callType = CALL_TYPE.VOICE_1ON1 }, db = prisma) {
  if (!callerId) {
    const error = new Error('Caller ID is required');
    error.status = 400;
    error.code = 'CALLER_REQUIRED';
    throw error;
  }

  if (!recipientId) {
    const error = new Error('Recipient ID is required');
    error.status = 400;
    error.code = 'RECIPIENT_REQUIRED';
    throw error;
  }

  if (callerId === recipientId) {
    const error = new Error('Cannot initiate a call to yourself');
    error.status = 400;
    error.code = 'SELF_CALL_NOT_ALLOWED';
    throw error;
  }

  // 1. Verify Caller Account Status
  const caller = await db.user.findUnique({
    where: { id: callerId },
    select: { id: true, username: true, status: true, avatarUrl: true, profile: { select: { displayName: true } } },
  });

  if (!caller || caller.status === 'BANNED' || caller.status === 'SUSPENDED') {
    const error = new Error('Your account is restricted from placing calls');
    error.status = 403;
    error.code = 'CALLER_RESTRICTED';
    throw error;
  }

  // 2. Verify Recipient Account Status
  const recipient = await db.user.findUnique({
    where: { id: recipientId },
    select: { id: true, username: true, status: true, avatarUrl: true, profile: { select: { displayName: true } } },
  });

  if (!recipient || recipient.status !== 'ACTIVE') {
    const error = new Error('Recipient is currently unavailable or account is inactive');
    error.status = 404;
    error.code = 'RECIPIENT_UNAVAILABLE';
    throw error;
  }

  // 3. Mutual Block Check
  const [callerBlockedRecipient, recipientBlockedCaller] = await Promise.all([
    socialRepository.isBlocked(callerId, recipientId, db).catch(() => false),
    socialRepository.isBlocked(recipientId, callerId, db).catch(() => false),
  ]);

  if (callerBlockedRecipient || recipientBlockedCaller) {
    const error = new Error('Unable to connect call due to privacy restrictions');
    error.status = 403;
    error.code = 'CALL_BLOCKED';
    throw error;
  }

  // 4. Friendship Check (Mutual Follow Relationship)
  const [followCallerToRecipient, followRecipientToCaller] = await Promise.all([
    socialRepository.findFollow({ followerId: callerId, followingId: recipientId }, db).catch(() => null),
    socialRepository.findFollow({ followerId: recipientId, followingId: callerId }, db).catch(() => null),
  ]);

  const isMutualFriend = Boolean(followCallerToRecipient && followRecipientToCaller);
  if (!isMutualFriend) {
    const error = new Error('Voice calling is only available between mutual friends');
    error.status = 403;
    error.code = 'CALL_FRIENDS_ONLY';
    throw error;
  }

  // 5. Check if Caller is already in an active call
  const callerActiveCall = await db.callSession.findFirst({
    where: {
      status: { in: [CALL_STATUS.INITIATED, CALL_STATUS.RINGING, CALL_STATUS.ACCEPTED] },
      participants: { some: { userId: callerId } },
    },
    select: { id: true },
  });

  if (callerActiveCall) {
    const error = new Error('You are already participating in an active call session');
    error.status = 409;
    error.code = 'CALLER_ALREADY_IN_CALL';
    throw error;
  }

  // 6. Check if Recipient is currently in an active call (Return BUSY state)
  const recipientActiveCall = await db.callSession.findFirst({
    where: {
      status: { in: [CALL_STATUS.INITIATED, CALL_STATUS.RINGING, CALL_STATUS.ACCEPTED] },
      participants: { some: { userId: recipientId } },
    },
    select: { id: true },
  });

  const channelName = `call_${crypto.randomUUID()}`;

  if (recipientActiveCall) {
    // Record busy attempt in history
    const busyCall = await db.callSession.create({
      data: {
        callerId,
        recipientId,
        callType,
        status: CALL_STATUS.BUSY,
        channelName,
        endReason: 'RECIPIENT_BUSY',
        endedAt: new Date(),
        participants: {
          create: [
            { userId: callerId, role: 'CALLER' },
            { userId: recipientId, role: 'RECIPIENT' },
          ],
        },
      },
      include: {
        caller: { select: { id: true, username: true, avatarUrl: true } },
        recipient: { select: { id: true, username: true, avatarUrl: true } },
      },
    });

    return {
      isBusy: true,
      call: busyCall,
      message: 'Recipient is currently busy in another call',
    };
  }

  // 7. Create Active Call Session in INITIATED state
  const callSession = await db.callSession.create({
    data: {
      callerId,
      recipientId,
      callType,
      status: CALL_STATUS.INITIATED,
      channelName,
      participants: {
        create: [
          { userId: callerId, role: 'CALLER', joinedAt: new Date() },
          { userId: recipientId, role: 'RECIPIENT' },
        ],
      },
    },
    include: {
      caller: {
        select: {
          id: true,
          username: true,
          avatarUrl: true,
          profile: { select: { displayName: true } },
        },
      },
      recipient: {
        select: {
          id: true,
          username: true,
          avatarUrl: true,
          profile: { select: { displayName: true } },
        },
      },
    },
  });

  return {
    isBusy: false,
    call: callSession,
  };
}

/**
 * Recipient accepts incoming call. Generates short-lived Agora RTC tokens for both parties.
 */
export async function acceptCall({ callId, userId }, db = prisma) {
  const call = await db.callSession.findUnique({
    where: { id: callId },
    include: {
      participants: true,
      caller: { select: { id: true, username: true, avatarUrl: true } },
      recipient: { select: { id: true, username: true, avatarUrl: true } },
    },
  });

  if (!call) {
    const error = new Error('Call session not found');
    error.status = 404;
    error.code = 'CALL_NOT_FOUND';
    throw error;
  }

  if (call.recipientId !== userId) {
    const error = new Error('Only the recipient can accept this call');
    error.status = 403;
    error.code = 'UNAUTHORIZED_CALL_ACTION';
    throw error;
  }

  if (call.status !== CALL_STATUS.INITIATED && call.status !== CALL_STATUS.RINGING) {
    const error = new Error(`Cannot accept call in '${call.status}' state`);
    error.status = 400;
    error.code = 'INVALID_CALL_STATE';
    throw error;
  }

  const now = new Date();

  // Update Call Session to ACCEPTED
  const updatedCall = await db.callSession.update({
    where: { id: callId },
    data: {
      status: CALL_STATUS.ACCEPTED,
      startedAt: now,
    },
    include: {
      caller: { select: { id: true, username: true, avatarUrl: true } },
      recipient: { select: { id: true, username: true, avatarUrl: true } },
    },
  });

  // Update participant joinedAt for recipient
  await db.callParticipant.updateMany({
    where: { callSessionId: callId, userId },
    data: { joinedAt: now },
  });

  // Provision Agora RTC tokens for both caller and recipient
  const callerUid = deriveAgoraUid(call.callerId);
  const recipientUid = deriveAgoraUid(call.recipientId);

  const callerToken = generateAgoraRtcToken({
    channelName: call.channelName,
    uid: callerUid,
    role: AGORA_ROLES.BROADCASTER,
    expirySeconds: 7200, // 2 hours max call session TTL
  });

  const recipientToken = generateAgoraRtcToken({
    channelName: call.channelName,
    uid: recipientUid,
    role: AGORA_ROLES.BROADCASTER,
    expirySeconds: 7200,
  });

  return {
    call: updatedCall,
    channelName: call.channelName,
    callerTokens: {
      userId: call.callerId,
      agoraUid: callerUid,
      rtcToken: callerToken,
    },
    recipientTokens: {
      userId: call.recipientId,
      agoraUid: recipientUid,
      rtcToken: recipientToken,
    },
  };
}

/**
 * Recipient declines incoming call.
 */
export async function rejectCall({ callId, userId, reason = 'DECLINED' }, db = prisma) {
  const call = await db.callSession.findUnique({
    where: { id: callId },
  });

  if (!call) {
    const error = new Error('Call session not found');
    error.status = 404;
    error.code = 'CALL_NOT_FOUND';
    throw error;
  }

  if (call.recipientId !== userId) {
    const error = new Error('Only the recipient can reject this call');
    error.status = 403;
    error.code = 'UNAUTHORIZED_CALL_ACTION';
    throw error;
  }

  if (call.status !== CALL_STATUS.INITIATED && call.status !== CALL_STATUS.RINGING) {
    return call; // Idempotent return
  }

  const updated = await db.callSession.update({
    where: { id: callId },
    data: {
      status: CALL_STATUS.REJECTED,
      endedAt: new Date(),
      endReason: reason,
    },
  });

  return updated;
}

/**
 * Caller cancels call before recipient answers.
 */
export async function cancelCall({ callId, userId }, db = prisma) {
  const call = await db.callSession.findUnique({
    where: { id: callId },
  });

  if (!call) {
    const error = new Error('Call session not found');
    error.status = 404;
    error.code = 'CALL_NOT_FOUND';
    throw error;
  }

  if (call.callerId !== userId) {
    const error = new Error('Only the caller can cancel this call');
    error.status = 403;
    error.code = 'UNAUTHORIZED_CALL_ACTION';
    throw error;
  }

  if (call.status !== CALL_STATUS.INITIATED && call.status !== CALL_STATUS.RINGING) {
    return call;
  }

  const updated = await db.callSession.update({
    where: { id: callId },
    data: {
      status: CALL_STATUS.CANCELLED,
      endedAt: new Date(),
      endReason: 'CANCELLED_BY_CALLER',
    },
  });

  return updated;
}

/**
 * Ends an active or ongoing call session.
 */
export async function endCall({ callId, userId, reason = 'NORMAL_END' }, db = prisma) {
  const call = await db.callSession.findUnique({
    where: { id: callId },
    include: { participants: true },
  });

  if (!call) {
    const error = new Error('Call session not found');
    error.status = 404;
    error.code = 'CALL_NOT_FOUND';
    throw error;
  }

  const isParticipant = call.callerId === userId || call.recipientId === userId || call.participants.some((p) => p.userId === userId);
  if (!isParticipant) {
    const error = new Error('Unauthorized call action');
    error.status = 403;
    error.code = 'UNAUTHORIZED_CALL_ACTION';
    throw error;
  }

  if (call.status === CALL_STATUS.ENDED || call.status === CALL_STATUS.CANCELLED || call.status === CALL_STATUS.REJECTED || call.status === CALL_STATUS.MISSED) {
    return call;
  }

  const now = new Date();
  let durationSeconds = 0;
  if (call.startedAt) {
    durationSeconds = Math.max(0, Math.round((now.getTime() - new Date(call.startedAt).getTime()) / 1000));
  }

  const updated = await db.callSession.update({
    where: { id: callId },
    data: {
      status: CALL_STATUS.ENDED,
      endedAt: now,
      durationSeconds,
      endReason: reason,
    },
    include: {
      caller: { select: { id: true, username: true, avatarUrl: true } },
      recipient: { select: { id: true, username: true, avatarUrl: true } },
    },
  });

  // Record friendship progress if call lasted at least 30 seconds
  if (durationSeconds >= 30 && call.callerId && call.recipientId) {
    const callMinutes = Math.ceil(durationSeconds / 60);
    const [u1, u2] = [call.callerId, call.recipientId].sort();
    await db.friendshipLevel.upsert({
      where: { userOneId_userTwoId: { userOneId: u1, userTwoId: u2 } },
      create: {
        userOneId: u1,
        userTwoId: u2,
        callMinutes,
        xp: callMinutes * 5,
      },
      update: {
        callMinutes: { increment: callMinutes },
        xp: { increment: callMinutes * 5 },
      },
    }).catch(() => {});
  }

  return updated;
}

/**
 * Handles unanswered call timeout (45-second default).
 */
export async function handleTimeout({ callId }, db = prisma) {
  const call = await db.callSession.findUnique({
    where: { id: callId },
  });

  if (!call) return null;

  if (call.status === CALL_STATUS.INITIATED || call.status === CALL_STATUS.RINGING) {
    return await db.callSession.update({
      where: { id: callId },
      data: {
        status: CALL_STATUS.MISSED,
        endedAt: new Date(),
        endReason: 'UNANSWERED_TIMEOUT',
      },
    });
  }

  return call;
}

/**
 * Generates or refreshes an Agora RTC token for an active call participant.
 */
export async function getCallToken({ callId, userId }, db = prisma) {
  const call = await db.callSession.findUnique({
    where: { id: callId },
    include: { participants: true },
  });

  if (!call) {
    const error = new Error('Call session not found');
    error.status = 404;
    error.code = 'CALL_NOT_FOUND';
    throw error;
  }

  if (call.status !== CALL_STATUS.ACCEPTED) {
    const error = new Error('Cannot issue call token for call that is not active');
    error.status = 400;
    error.code = 'CALL_NOT_ACTIVE';
    throw error;
  }

  const isParticipant = call.callerId === userId || call.recipientId === userId || call.participants.some((p) => p.userId === userId);
  if (!isParticipant) {
    const error = new Error('User is not an authorized participant of this call');
    error.status = 403;
    error.code = 'UNAUTHORIZED_CALL_PARTICIPANT';
    throw error;
  }

  const agoraUid = deriveAgoraUid(userId);
  const rtcToken = generateAgoraRtcToken({
    channelName: call.channelName,
    uid: agoraUid,
    role: AGORA_ROLES.BROADCASTER,
    expirySeconds: 3600,
  });

  return {
    callId,
    channelName: call.channelName,
    agoraUid,
    rtcToken,
    expiresIn: 3600,
  };
}

/**
 * Returns call history for an authenticated user.
 */
export async function getUserCallHistory({ userId, page = 1, limit = 20, type }, db = prisma) {
  const skip = (Math.max(1, Number(page)) - 1) * Math.max(1, Number(limit));
  const take = Math.min(100, Math.max(1, Number(limit)));

  const where = {
    OR: [{ callerId: userId }, { recipientId: userId }],
    ...(type ? { callType: type } : {}),
  };

  const [calls, total] = await Promise.all([
    db.callSession.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take,
      include: {
        caller: {
          select: {
            id: true,
            username: true,
            avatarUrl: true,
            profile: { select: { displayName: true } },
          },
        },
        recipient: {
          select: {
            id: true,
            username: true,
            avatarUrl: true,
            profile: { select: { displayName: true } },
          },
        },
      },
    }),
    db.callSession.count({ where }),
  ]);

  return {
    calls: calls.map((c) => ({
      id: c.id,
      callType: c.callType,
      status: c.status,
      durationSeconds: c.durationSeconds,
      startedAt: c.startedAt,
      endedAt: c.endedAt,
      createdAt: c.createdAt,
      endReason: c.endReason,
      isOutgoing: c.callerId === userId,
      partner: c.callerId === userId ? c.recipient : c.caller,
    })),
    pagination: {
      page: Number(page),
      limit: take,
      total,
      totalPages: Math.ceil(total / take) || 1,
    },
  };
}

/**
 * Administrative operational monitoring for all platform voice calls.
 */
export async function adminGetCalls({ page = 1, limit = 20, status, search, fromDate, toDate }, db = prisma) {
  const skip = (Math.max(1, Number(page)) - 1) * Math.max(1, Number(limit));
  const take = Math.min(100, Math.max(1, Number(limit)));

  const where = {
    ...(status ? { status } : {}),
    ...(fromDate || toDate
      ? {
          createdAt: {
            ...(fromDate ? { gte: new Date(fromDate) } : {}),
            ...(toDate ? { lte: new Date(toDate) } : {}),
          },
        }
      : {}),
    ...(search
      ? {
          OR: [
            { caller: { username: { contains: search, mode: 'insensitive' } } },
            { recipient: { username: { contains: search, mode: 'insensitive' } } },
            { channelName: { contains: search } },
          ],
        }
      : {}),
  };

  const [calls, total] = await Promise.all([
    db.callSession.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take,
      include: {
        caller: { select: { id: true, username: true, avatarUrl: true } },
        recipient: { select: { id: true, username: true, avatarUrl: true } },
      },
    }),
    db.callSession.count({ where }),
  ]);

  return {
    calls,
    pagination: {
      page: Number(page),
      limit: take,
      total,
      totalPages: Math.ceil(total / take) || 1,
    },
  };
}

export default {
  CALL_STATUS,
  CALL_TYPE,
  initiateCall,
  acceptCall,
  rejectCall,
  cancelCall,
  endCall,
  handleTimeout,
  getCallToken,
  getUserCallHistory,
  adminGetCalls,
};

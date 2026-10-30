// ==============================================================================
// HEMI TON — Realtime Call Signaling Socket Handler
// Socket.IO event engine for Voice/Video Calls (Chatta-style Architecture)
// ==============================================================================

import callService, { CALL_STATUS } from '../services/call.service.js';

// Active timeouts map for unanswered calls: callId -> Timeout
const activeCallTimers = new Map();

export function registerCallHandlers(io, socket) {
  const userId = socket.userId;
  if (!userId) return;

  // 1. Initiate Outgoing Call
  socket.on('call:initiate', async (data, callback) => {
    try {
      const { recipientId, callType } = data || {};
      const result = await callService.initiateCall({
        callerId: userId,
        recipientId,
        callType,
      });

      if (result.isBusy) {
        socket.emit('call:busy', {
          callId: result.call.id,
          recipientId,
          message: 'Recipient is currently busy in another call',
        });
        if (typeof callback === 'function') callback({ success: true, busy: true, call: result.call });
        return;
      }

      const call = result.call;

      // Notify caller that recipient device is ringing
      socket.emit('call:ringing', {
        callId: call.id,
        channelName: call.channelName,
        callType: call.callType,
        recipient: call.recipient,
      });

      // Deliver incoming call prompt to recipient user room
      io.to(`user_${recipientId}`).emit('call:incoming', {
        callId: call.id,
        channelName: call.channelName,
        callType: call.callType,
        caller: call.caller,
        createdAt: call.createdAt,
      });

      // Set 45-second timeout for unanswered call
      const timer = setTimeout(async () => {
        try {
          const timedOutCall = await callService.handleTimeout({ callId: call.id });
          if (timedOutCall && timedOutCall.status === CALL_STATUS.MISSED) {
            socket.emit('call:timeout', { callId: call.id, reason: 'UNANSWERED' });
            io.to(`user_${recipientId}`).emit('call:missed', {
              callId: call.id,
              caller: call.caller,
              createdAt: new Date(),
            });
          }
        } catch (_) {} finally {
          activeCallTimers.delete(call.id);
        }
      }, 45000);

      activeCallTimers.set(call.id, timer);

      if (typeof callback === 'function') callback({ success: true, call });
    } catch (err) {
      socket.emit('call:error', { message: err.message, code: err.code || 'CALL_INITIATE_FAILED' });
      if (typeof callback === 'function') callback({ success: false, error: err.message });
    }
  });

  // 2. Accept Incoming Call
  socket.on('call:accept', async (data, callback) => {
    try {
      const { callId } = data || {};
      const timer = activeCallTimers.get(callId);
      if (timer) {
        clearTimeout(timer);
        activeCallTimers.delete(callId);
      }

      const result = await callService.acceptCall({ callId, userId });

      // Send token and channel details to caller
      io.to(`user_${result.call.callerId}`).emit('call:accepted', {
        callId: result.call.id,
        channelName: result.channelName,
        tokenData: result.callerTokens,
        recipient: result.call.recipient,
      });

      // Send token and channel details to answering recipient
      socket.emit('call:connected', {
        callId: result.call.id,
        channelName: result.channelName,
        tokenData: result.recipientTokens,
      });

      if (typeof callback === 'function') callback({ success: true, call: result.call, tokenData: result.recipientTokens });
    } catch (err) {
      socket.emit('call:error', { message: err.message, code: err.code || 'CALL_ACCEPT_FAILED' });
      if (typeof callback === 'function') callback({ success: false, error: err.message });
    }
  });

  // 3. Reject Incoming Call
  socket.on('call:reject', async (data, callback) => {
    try {
      const { callId, reason } = data || {};
      const timer = activeCallTimers.get(callId);
      if (timer) {
        clearTimeout(timer);
        activeCallTimers.delete(callId);
      }

      const call = await callService.rejectCall({ callId, userId, reason });
      if (call.callerId) {
        io.to(`user_${call.callerId}`).emit('call:rejected', {
          callId: call.id,
          reason: call.endReason || 'DECLINED',
        });
      }

      if (typeof callback === 'function') callback({ success: true });
    } catch (err) {
      socket.emit('call:error', { message: err.message, code: err.code || 'CALL_REJECT_FAILED' });
      if (typeof callback === 'function') callback({ success: false, error: err.message });
    }
  });

  // 4. Cancel Outgoing Call
  socket.on('call:cancel', async (data, callback) => {
    try {
      const { callId } = data || {};
      const timer = activeCallTimers.get(callId);
      if (timer) {
        clearTimeout(timer);
        activeCallTimers.delete(callId);
      }

      const call = await callService.cancelCall({ callId, userId });
      if (call.recipientId) {
        io.to(`user_${call.recipientId}`).emit('call:cancelled', {
          callId: call.id,
        });
      }

      if (typeof callback === 'function') callback({ success: true });
    } catch (err) {
      socket.emit('call:error', { message: err.message, code: err.code || 'CALL_CANCEL_FAILED' });
      if (typeof callback === 'function') callback({ success: false, error: err.message });
    }
  });

  // 5. End Call Session
  socket.on('call:end', async (data, callback) => {
    try {
      const { callId, reason } = data || {};
      const timer = activeCallTimers.get(callId);
      if (timer) {
        clearTimeout(timer);
        activeCallTimers.delete(callId);
      }

      const call = await callService.endCall({ callId, userId, reason });
      const payload = {
        callId: call.id,
        durationSeconds: call.durationSeconds,
        endReason: call.endReason,
      };

      if (call.callerId) io.to(`user_${call.callerId}`).emit('call:ended', payload);
      if (call.recipientId) io.to(`user_${call.recipientId}`).emit('call:ended', payload);

      if (typeof callback === 'function') callback({ success: true, call });
    } catch (err) {
      socket.emit('call:error', { message: err.message, code: err.code || 'CALL_END_FAILED' });
      if (typeof callback === 'function') callback({ success: false, error: err.message });
    }
  });

  // 6. Direct Peer Signaling Relay (ICE Candidates / Custom Media Signals)
  socket.on('call:signal', (data) => {
    const { targetUserId, callId, signalData } = data || {};
    if (targetUserId && callId && signalData) {
      io.to(`user_${targetUserId}`).emit('call:signal', {
        callId,
        fromUserId: userId,
        signalData,
      });
    }
  });
}

export default {
  registerCallHandlers,
};

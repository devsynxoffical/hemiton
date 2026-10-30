// ==============================================================================
// HEMI TON — Voice & Video Calling Controller
// REST Endpoints for Call Lifecycle, Tokens, User History & Admin Monitoring
// ==============================================================================

import callService from '../services/call.service.js';

export async function initiateCall(req, res, next) {
  try {
    const callerId = req.auth.userId;
    const { recipientId, callType } = req.body;

    const result = await callService.initiateCall({
      callerId,
      recipientId,
      callType,
    });

    // Notify recipient via Socket.IO if available
    try {
      const { getIO } = await import('../socket/index.js');
      const io = getIO();
      if (io) {
        if (result.isBusy) {
          io.to(`user_${callerId}`).emit('call:busy', {
            callId: result.call.id,
            recipientId,
            message: 'Recipient is currently busy in another call',
          });
        } else {
          io.to(`user_${recipientId}`).emit('call:incoming', {
            callId: result.call.id,
            channelName: result.call.channelName,
            callType: result.call.callType,
            caller: result.call.caller,
            createdAt: result.call.createdAt,
          });
          io.to(`user_${callerId}`).emit('call:ringing', {
            callId: result.call.id,
            channelName: result.call.channelName,
            recipient: result.call.recipient,
          });
        }
      }
    } catch (_) {}

    return res.status(200).json({
      success: true,
      message: result.isBusy ? 'Recipient is busy' : 'Call initiated successfully',
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function acceptCall(req, res, next) {
  try {
    const userId = req.auth.userId;
    const callId = req.params.id;

    const result = await callService.acceptCall({ callId, userId });

    // Notify caller via Socket.IO
    try {
      const { getIO } = await import('../socket/index.js');
      const io = getIO();
      if (io) {
        io.to(`user_${result.call.callerId}`).emit('call:accepted', {
          callId: result.call.id,
          channelName: result.channelName,
          tokenData: result.callerTokens,
          recipient: result.call.recipient,
        });
        io.to(`user_${result.call.recipientId}`).emit('call:connected', {
          callId: result.call.id,
          channelName: result.channelName,
          tokenData: result.recipientTokens,
        });
      }
    } catch (_) {}

    return res.status(200).json({
      success: true,
      message: 'Call accepted',
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function rejectCall(req, res, next) {
  try {
    const userId = req.auth.userId;
    const callId = req.params.id;
    const { reason } = req.body;

    const result = await callService.rejectCall({ callId, userId, reason });

    try {
      const { getIO } = await import('../socket/index.js');
      const io = getIO();
      if (io) {
        io.to(`user_${result.callerId}`).emit('call:rejected', {
          callId: result.id,
          reason: result.endReason,
        });
      }
    } catch (_) {}

    return res.status(200).json({
      success: true,
      message: 'Call rejected',
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function cancelCall(req, res, next) {
  try {
    const userId = req.auth.userId;
    const callId = req.params.id;

    const result = await callService.cancelCall({ callId, userId });

    try {
      const { getIO } = await import('../socket/index.js');
      const io = getIO();
      if (io) {
        io.to(`user_${result.recipientId}`).emit('call:cancelled', {
          callId: result.id,
        });
      }
    } catch (_) {}

    return res.status(200).json({
      success: true,
      message: 'Call cancelled',
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function endCall(req, res, next) {
  try {
    const userId = req.auth.userId;
    const callId = req.params.id;
    const { reason } = req.body;

    const result = await callService.endCall({ callId, userId, reason });

    try {
      const { getIO } = await import('../socket/index.js');
      const io = getIO();
      if (io) {
        const payload = {
          callId: result.id,
          durationSeconds: result.durationSeconds,
          endReason: result.endReason,
        };
        if (result.callerId) io.to(`user_${result.callerId}`).emit('call:ended', payload);
        if (result.recipientId) io.to(`user_${result.recipientId}`).emit('call:ended', payload);
      }
    } catch (_) {}

    return res.status(200).json({
      success: true,
      message: 'Call ended successfully',
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function getCallToken(req, res, next) {
  try {
    const userId = req.auth.userId;
    const callId = req.params.id;

    const result = await callService.getCallToken({ callId, userId });

    return res.status(200).json({
      success: true,
      message: 'Call RTC token issued',
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

export async function getCallHistory(req, res, next) {
  try {
    const userId = req.auth.userId;
    const { page, limit, type } = req.query;

    const result = await callService.getUserCallHistory({
      userId,
      page,
      limit,
      type,
    });

    return res.status(200).json({
      success: true,
      message: 'Call history retrieved',
      data: result.calls,
      pagination: result.pagination,
    });
  } catch (err) {
    next(err);
  }
}

export async function adminGetCalls(req, res, next) {
  try {
    const { page, limit, status, search, fromDate, toDate } = req.query;

    const result = await callService.adminGetCalls({
      page,
      limit,
      status,
      search,
      fromDate,
      toDate,
    });

    return res.status(200).json({
      success: true,
      message: 'Admin call records retrieved',
      data: result.calls,
      pagination: result.pagination,
    });
  } catch (err) {
    next(err);
  }
}

export default {
  initiateCall,
  acceptCall,
  rejectCall,
  cancelCall,
  endCall,
  getCallToken,
  getCallHistory,
  adminGetCalls,
};

// ==============================================================================
// HEMI TON — Hangout Social & Community Controller
// ==============================================================================

import hangoutService from '../services/hangout.service.js';

export async function getFriendsLiveFeed(req, res, next) {
  try {
    const userId = req.auth.userId;
    const data = await hangoutService.getFriendsLiveFeed(userId);
    return res.status(200).json({
      success: true,
      message: 'Friends live stream feed retrieved',
      data,
    });
  } catch (err) {
    next(err);
  }
}

export async function bringMyFriend(req, res, next) {
  try {
    const inviterId = req.auth.userId;
    const { roomId, friendId, seatIndex } = req.body;
    const data = await hangoutService.bringMyFriend({ roomId, inviterId, friendId, seatIndex });

    // Emit live invitation via socket if recipient is online
    try {
      const { getIO } = await import('../socket/index.js');
      const io = getIO();
      if (io) {
        io.to(`user_${friendId}`).emit('hangout:room_invite', data);
      }
    } catch (_) {}

    return res.status(200).json({
      success: true,
      message: 'Friend invitation sent successfully',
      data,
    });
  } catch (err) {
    next(err);
  }
}

export async function startIcebreaker(req, res, next) {
  try {
    const userOneId = req.auth.userId;
    const { roomId, userTwoId } = req.body;
    const data = await hangoutService.startIcebreaker({ roomId, userOneId, userTwoId });

    // Broadcast icebreaker start to room
    try {
      const { getIO } = await import('../socket/index.js');
      const io = getIO();
      if (io) {
        io.to(`room_${roomId}`).emit('hangout:icebreaker_started', data);
      }
    } catch (_) {}

    return res.status(200).json({
      success: true,
      message: 'Icebreaker started',
      data,
    });
  } catch (err) {
    next(err);
  }
}

export async function getFriendshipProfile(req, res, next) {
  try {
    const userId = req.auth.userId;
    const friendId = req.params.friendId;
    const data = await hangoutService.getFriendshipProfile(userId, friendId);
    return res.status(200).json({
      success: true,
      message: 'Friendship profile and journey retrieved',
      data,
    });
  } catch (err) {
    next(err);
  }
}

export async function findSomeoneLikeMe(req, res, next) {
  try {
    const userId = req.auth.userId;
    const { tags, countryCode } = req.query;
    const data = await hangoutService.findSomeoneLikeMe({
      userId,
      tags: tags ? tags.split(',') : [],
      countryCode,
    });
    return res.status(200).json({
      success: true,
      message: 'Matching users found',
      data,
    });
  } catch (err) {
    next(err);
  }
}

export async function getCommunities(req, res, next) {
  try {
    const data = await hangoutService.getHangoutCommunities();
    return res.status(200).json({
      success: true,
      message: 'Hangout communities retrieved',
      data,
    });
  } catch (err) {
    next(err);
  }
}

export async function getChallenges(req, res, next) {
  try {
    const userId = req.auth?.userId;
    const data = await hangoutService.getHangoutChallenges(userId);
    return res.status(200).json({
      success: true,
      message: 'Hangout challenges retrieved',
      data,
    });
  } catch (err) {
    next(err);
  }
}

export default {
  getFriendsLiveFeed,
  bringMyFriend,
  startIcebreaker,
  getFriendshipProfile,
  findSomeoneLikeMe,
  getCommunities,
  getChallenges,
};

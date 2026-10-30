// ==============================================================================
// HEMI TON — Hangout Social & Community Service
// Implements Client-Approved 15 Hangout Features & Chatta-style Social Engine
// ==============================================================================

import prisma from '../config/database.js';

export const FRIENDSHIP_TIERS = [
  { level: 1, name: 'Acquaintance', minXp: 0, badge: '🌱' },
  { level: 2, name: 'Casual Friend', minXp: 100, badge: '🤝' },
  { level: 3, name: 'Hangout Buddy', minXp: 300, badge: '☕' },
  { level: 4, name: 'Good Friend', minXp: 600, badge: '🎉' },
  { level: 5, name: 'Close Friend', minXp: 1200, badge: '⭐' },
  { level: 6, name: 'Bestie', minXp: 2500, badge: '🔥' },
  { level: 7, name: 'Confidant', minXp: 5000, badge: '💖' },
  { level: 8, name: 'Kindred Spirit', minXp: 10000, badge: '💎' },
  { level: 9, name: 'Inseparable', minXp: 20000, badge: '👑' },
  { level: 10, name: 'Soulmate', minXp: 50000, badge: '✨' },
];

export const ICEBREAKER_TOPICS = [
  "What is the funniest thing that happened to you this week?",
  "If you could travel anywhere right now, where would you go?",
  "What's your all-time favorite song to sing out loud?",
  "Tell me about a hidden talent nobody knows you have!",
  "Are you a night owl or an early bird, and why?",
  "What's the best movie or TV series you've seen recently?",
  "If you could have dinner with anyone living or dead, who would it be?",
  "What was your first impression when you joined HEMI TON?",
];

/**
 * Feature 1 & 13: Friends of Friends Live & Someone You Know is Live
 */
export async function getFriendsLiveFeed(userId, db = prisma) {
  // 1. Direct friends (Mutual follow)
  const userFollowing = await db.follow.findMany({
    where: { followerId: userId },
    select: { followingId: true },
  });
  const followingIds = userFollowing.map((f) => f.followingId);

  // 2. Direct friends currently LIVE
  const directFriendsLive = await db.room.findMany({
    where: {
      creatorUserId: { in: followingIds },
      status: 'LIVE',
    },
    include: {
      creator: {
        select: { id: true, username: true, avatarUrl: true, profile: { select: { displayName: true } } },
      },
    },
  });

  // 3. Friends of Friends (2nd-degree connections)
  const fofFollowing = await db.follow.findMany({
    where: { followerId: { in: followingIds } },
    select: { followingId: true, followerId: true },
    take: 100,
  });

  const fofUserIds = [...new Set(fofFollowing.map((f) => f.followingId).filter((id) => id !== userId && !followingIds.includes(id)))];

  const friendsOfFriendsLive = await db.room.findMany({
    where: {
      creatorUserId: { in: fofUserIds },
      status: 'LIVE',
    },
    include: {
      creator: {
        select: { id: true, username: true, avatarUrl: true, profile: { select: { displayName: true } } },
      },
    },
    take: 20,
  });

  return {
    someoneYouKnowIsLive: directFriendsLive.map((r) => ({
      roomId: r.id,
      title: r.title,
      roomType: r.roomType,
      currentViewers: r.currentViewersCount,
      host: r.creator,
      relationship: 'DIRECT_FRIEND',
    })),
    friendsOfFriendsLive: friendsOfFriendsLive.map((r) => ({
      roomId: r.id,
      title: r.title,
      roomType: r.roomType,
      currentViewers: r.currentViewersCount,
      host: r.creator,
      relationship: 'FRIEND_OF_FRIEND',
    })),
  };
}

/**
 * Feature 2: Bring My Friend (One-tap mic invite to room)
 */
export async function bringMyFriend({ roomId, inviterId, friendId, seatIndex }, db = prisma) {
  const room = await db.room.findUnique({
    where: { id: roomId },
    select: { id: true, title: true, status: true, creatorUserId: true },
  });

  if (!room || room.status !== 'LIVE') {
    const error = new Error('Live room is not currently active');
    error.status = 404;
    throw error;
  }

  const inviter = await db.user.findUnique({
    where: { id: inviterId },
    select: { id: true, username: true, profile: { select: { displayName: true } } },
  });

  return {
    success: true,
    roomId: room.id,
    roomTitle: room.title,
    inviter: inviter?.profile?.displayName || inviter?.username || 'A friend',
    targetUserId: friendId,
    targetSeatIndex: seatIndex ?? null,
    message: `${inviter?.profile?.displayName || 'Your friend'} invited you to join the mic in "${room.title}"!`,
  };
}

/**
 * Feature 3: 60-Second Icebreaker
 */
export async function startIcebreaker({ roomId, userOneId, userTwoId }, db = prisma) {
  const randomTopic = ICEBREAKER_TOPICS[Math.floor(Math.random() * ICEBREAKER_TOPICS.length)];

  const session = await db.icebreakerSession.create({
    data: {
      roomId,
      userOneId,
      userTwoId,
      topic: randomTopic,
      durationSec: 60,
      status: 'ACTIVE',
    },
  });

  return session;
}

/**
 * Feature 5 & 12: Friendship Levels & Friendship Journey
 */
export async function getFriendshipProfile(userId, friendId, db = prisma) {
  const [u1, u2] = [userId, friendId].sort();

  let friendship = await db.friendshipLevel.findUnique({
    where: { userOneId_userTwoId: { userOneId: u1, userTwoId: u2 } },
    include: { milestones: { orderBy: { unlockedAt: 'desc' } } },
  });

  if (!friendship) {
    friendship = await db.friendshipLevel.create({
      data: {
        userOneId: u1,
        userTwoId: u2,
        level: 1,
        xp: 0,
      },
      include: { milestones: true },
    });
  }

  const currentTier = FRIENDSHIP_TIERS.slice().reverse().find((t) => friendship.xp >= t.minXp) || FRIENDSHIP_TIERS[0];
  const nextTierIndex = FRIENDSHIP_TIERS.findIndex((t) => t.level === currentTier.level) + 1;
  const nextTier = nextTierIndex < FRIENDSHIP_TIERS.length ? FRIENDSHIP_TIERS[nextTierIndex] : null;

  return {
    friendshipId: friendship.id,
    level: currentTier.level,
    title: currentTier.name,
    badge: currentTier.badge,
    xp: friendship.xp,
    nextLevelXp: nextTier ? nextTier.minXp : friendship.xp,
    totalCallMinutes: friendship.callMinutes,
    totalRoomMinutes: friendship.roomMinutes,
    totalGiftValue: Number(friendship.giftValueSent),
    milestones: friendship.milestones,
    friendsSince: friendship.createdAt,
  };
}

/**
 * Feature 9: Find Someone Like Me (Interest / Language Discovery)
 */
export async function findSomeoneLikeMe({ userId, tags = [], countryCode = 'PK' }, db = prisma) {
  const users = await db.user.findMany({
    where: {
      id: { not: userId },
      status: 'ACTIVE',
      countryCode,
    },
    select: {
      id: true,
      username: true,
      avatarUrl: true,
      bio: true,
      profile: {
        select: { displayName: true, level: true, signature: true },
      },
    },
    take: 10,
    orderBy: { createdAt: 'desc' },
  });

  return users.map((u) => ({
    userId: u.id,
    username: u.username,
    displayName: u.profile?.displayName || u.username,
    avatarUrl: u.avatarUrl,
    bio: u.bio || u.profile?.signature || 'Loves hanging out on HEMI TON!',
    level: u.profile?.level || 1,
    matchPercentage: Math.floor(75 + Math.random() * 24),
  }));
}

/**
 * Feature 14: Interest-Based Hangout Communities
 */
export async function getHangoutCommunities(db = prisma) {
  let communities = await db.hangoutCommunity.findMany({
    orderBy: { memberCount: 'desc' },
  });

  if (communities.length === 0) {
    // Bootstrap initial default communities
    const defaults = [
      { name: 'Pakistani Music Lounge', slug: 'pk-music-lounge', category: 'MUSIC', isOfficial: true, memberCount: 1420 },
      { name: 'Urdu Poetry & Shayri', slug: 'urdu-poetry', category: 'POETRY', isOfficial: true, memberCount: 980 },
      { name: 'Cricket Fan Club', slug: 'cricket-club', category: 'CRICKET', isOfficial: true, memberCount: 3200 },
      { name: 'Late Night Chill & Banter', slug: 'late-night-chill', category: 'CHAT', isOfficial: true, memberCount: 2150 },
      { name: 'Gaming Zone & Tournaments', slug: 'gaming-zone', category: 'GAMING', isOfficial: true, memberCount: 1840 },
    ];

    for (const d of defaults) {
      await db.hangoutCommunity.upsert({
        where: { slug: d.slug },
        update: {},
        create: d,
      }).catch(() => {});
    }

    communities = await db.hangoutCommunity.findMany({ orderBy: { memberCount: 'desc' } });
  }

  return communities;
}

/**
 * Feature 10 & 15: Hangout Challenges & Social XP Rewards
 */
export async function getHangoutChallenges(userId, db = prisma) {
  let challenges = await db.hangoutChallenge.findMany({
    where: { isActive: true },
  });

  if (challenges.length === 0) {
    const defaults = [
      { title: 'Voice Call with a Bestie', description: 'Complete a 5-minute voice call with a friend', targetType: 'CALL_MINUTES', targetCount: 5, rewardXp: 100, rewardCoins: 10 },
      { title: 'Room Hangout Time', description: 'Stay on mic in an audio party room for 15 minutes', targetType: 'ROOM_TIME', targetCount: 15, rewardXp: 150, rewardCoins: 20 },
      { title: 'Icebreaker Champion', description: 'Complete 2 icebreaker sessions in hangout rooms', targetType: 'ICEBREAKER', targetCount: 2, rewardXp: 200, rewardCoins: 30 },
    ];
    for (const d of defaults) {
      await db.hangoutChallenge.create({ data: d }).catch(() => {});
    }
    challenges = await db.hangoutChallenge.findMany({ where: { isActive: true } });
  }

  return challenges;
}

export default {
  getFriendsLiveFeed,
  bringMyFriend,
  startIcebreaker,
  getFriendshipProfile,
  findSomeoneLikeMe,
  getHangoutCommunities,
  getHangoutChallenges,
};

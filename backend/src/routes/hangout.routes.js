// ==============================================================================
// HEMI TON — Hangout Social & Community Routes
// ==============================================================================

import express from 'express';
import authenticate from '../middlewares/authenticate.js';
import hangoutController from '../controllers/hangout.controller.js';

const router = express.Router();

router.use(authenticate);

// Hangout Discovery & Friends Live
router.get('/friends-live', hangoutController.getFriendsLiveFeed);
router.post('/bring-friend', hangoutController.bringMyFriend);

// 60-Second Icebreaker
router.post('/icebreaker/start', hangoutController.startIcebreaker);

// Friendship Levels & Journey
router.get('/friendship/:friendId', hangoutController.getFriendshipProfile);

// Discovery
router.get('/find-someone', hangoutController.findSomeoneLikeMe);

// Communities & Challenges
router.get('/communities', hangoutController.getCommunities);
router.get('/challenges', hangoutController.getChallenges);

export default router;

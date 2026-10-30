// ==============================================================================
// HEMI TON — Voice & Video Calling Routes
// User Calling Lifecycle & Admin Operational Call Logs
// ==============================================================================

import express from 'express';
import authenticate from '../middlewares/authenticate.js';
import callController from '../controllers/call.controller.js';

export const userCallRouter = express.Router();
export const adminCallRouter = express.Router();

// User Call Routes (All require user authentication)
userCallRouter.use(authenticate);

userCallRouter.post('/initiate', callController.initiateCall);
userCallRouter.post('/:id/accept', callController.acceptCall);
userCallRouter.post('/:id/reject', callController.rejectCall);
userCallRouter.post('/:id/cancel', callController.cancelCall);
userCallRouter.post('/:id/end', callController.endCall);
userCallRouter.get('/:id/token', callController.getCallToken);
userCallRouter.get('/history', callController.getCallHistory);

// Admin Call Operational Monitoring Routes
adminCallRouter.use(authenticate);
adminCallRouter.get('/', callController.adminGetCalls);

export default {
  userCallRouter,
  adminCallRouter,
};

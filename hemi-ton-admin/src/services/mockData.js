// ============================================================
// Hemi Ton Admin — Development Placeholder Mock Dataset
// ============================================================
// NOTICE: These datasets are explicitly marked as development-only
// placeholders for local environment UI scaffolding until the
// dedicated Hemi Ton backend endpoints are deployed.
// ============================================================

export const MOCK_METRICS = {
  isDevelopmentPlaceholder: true,
  environmentNotice: 'Simulated Development Data — Hemi Ton Backend Pending',
  totalUsers: 14850,
  totalUsersChange: '+12.4%',
  activeUsers: 3420,
  activeUsersChange: '+8.1%',
  onlineUsers: 840,
  onlineUsersChange: '+15.3%',
  activeRooms: 64,
  activeRoomsChange: '+5.0%',
  liveHosts: 58,
  liveHostsChange: '+3.2%',
  pendingAgencyApplications: 7,
  pendingAgencyUrgent: 2,
  pendingWithdrawals: 19,
  pendingWithdrawalsAmount: 14250.0,
  totalRevenue: 68420.5,
  totalRevenueChange: '+18.6%',
  coinsInCirculation: 48900000,
};

export const MOCK_USER_GROWTH_CHART = [
  { date: 'Mon', registered: 120, active: 1100, online: 320 },
  { date: 'Tue', registered: 145, active: 1350, online: 410 },
  { date: 'Wed', registered: 190, active: 1580, online: 530 },
  { date: 'Thu', registered: 210, active: 1920, online: 610 },
  { date: 'Fri', registered: 290, active: 2450, online: 780 },
  { date: 'Sat', registered: 380, active: 3100, online: 920 },
  { date: 'Sun', registered: 430, active: 3420, online: 840 },
];

export const MOCK_LIVE_ACTIVITY_CHART = [
  { hour: '00:00', rooms: 24, viewers: 420 },
  { hour: '04:00', rooms: 15, viewers: 180 },
  { hour: '08:00', rooms: 28, viewers: 550 },
  { hour: '12:00', rooms: 45, viewers: 1120 },
  { hour: '16:00', rooms: 58, viewers: 1890 },
  { hour: '20:00', rooms: 64, viewers: 2400 },
  { hour: '23:00', rooms: 52, viewers: 1650 },
];

export const MOCK_ROOM_CATEGORY_DISTRIBUTION = [
  { name: 'Multi-Speaker Party', value: 28, percentage: '44%', color: '#5979AC' },
  { name: 'Music & Audio Spaces', value: 16, percentage: '25%', color: '#7894BE' },
  { name: 'PK Battles & Gaming', value: 12, percentage: '19%', color: '#91A9CE' },
  { name: 'VIP & Lounge Rooms', value: 8, percentage: '12%', color: '#B8C7DD' },
];

export const MOCK_REVENUE_SOURCE_DISTRIBUTION = [
  { name: 'In-App Coin Packs', value: 42420, percentage: '62%', color: '#5979AC' },
  { name: 'VIP Subscriptions', value: 13684, percentage: '20%', color: '#7894BE' },
  { name: 'Virtual Gifting Royalty', value: 8210, percentage: '12%', color: '#91A9CE' },
  { name: 'Agency Service Fees', value: 4106, percentage: '6%', color: '#B8C7DD' },
];

export const MOCK_REVENUE_CHART = [
  { date: 'Oct 13', coinRecharges: 4200, agencyPayouts: 1800, netRevenue: 2400 },
  { date: 'Oct 14', coinRecharges: 5100, agencyPayouts: 2100, netRevenue: 3000 },
  { date: 'Oct 15', coinRecharges: 6800, agencyPayouts: 2400, netRevenue: 4400 },
  { date: 'Oct 16', coinRecharges: 7400, agencyPayouts: 3100, netRevenue: 4300 },
  { date: 'Oct 17', coinRecharges: 8900, agencyPayouts: 3600, netRevenue: 5300 },
  { date: 'Oct 18', coinRecharges: 11200, agencyPayouts: 4200, netRevenue: 7000 },
  { date: 'Oct 19', coinRecharges: 12500, agencyPayouts: 4800, netRevenue: 7700 },
];

export const MOCK_RECENT_REGISTRATIONS = [
  {
    id: 'HTU-9021',
    name: 'Aria Thorne',
    username: '@ariathorne',
    email: 'aria.thorne@example.com',
    role: 'HOST_CANDIDATE',
    status: 'ACTIVE',
    createdAt: new Date(Date.now() - 14 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
  {
    id: 'HTU-9022',
    name: 'Marcus Vance',
    username: '@mvance',
    email: 'm.vance@example.com',
    role: 'USER',
    status: 'ACTIVE',
    createdAt: new Date(Date.now() - 42 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
  {
    id: 'HTU-9023',
    name: 'Elena Rostova',
    username: '@elena_live',
    email: 'elena@rostova.io',
    role: 'VERIFIED_HOST',
    status: 'ACTIVE',
    createdAt: new Date(Date.now() - 110 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
  {
    id: 'HTU-9024',
    name: 'Tariq Al-Mansoor',
    username: '@tariq_om',
    email: 'tariq@galaxyagency.com',
    role: 'AGENCY_OWNER',
    status: 'PENDING_KYC',
    createdAt: new Date(Date.now() - 210 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
  {
    id: 'HTU-9025',
    name: 'Kenji Takahashi',
    username: '@kenji_t',
    email: 'kenji@tokyonight.jp',
    role: 'USER',
    status: 'ACTIVE',
    createdAt: new Date(Date.now() - 340 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
];

export const MOCK_RECENT_TRANSACTIONS = [
  {
    id: 'TXN-88192',
    user: 'Aria Thorne',
    type: 'COIN_PURCHASE',
    amount: 150.0,
    coins: 15000,
    status: 'COMPLETED',
    timestamp: new Date(Date.now() - 8 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
  {
    id: 'TXN-88193',
    user: 'Galaxy Agency',
    type: 'HOST_PAYOUT',
    amount: 1240.0,
    coins: 124000,
    status: 'PENDING_APPROVAL',
    timestamp: new Date(Date.now() - 31 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
  {
    id: 'TXN-88194',
    user: 'Marcus Vance',
    type: 'GIFT_TIP_SETTLEMENT',
    amount: 85.0,
    coins: 8500,
    status: 'COMPLETED',
    timestamp: new Date(Date.now() - 56 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
  {
    id: 'TXN-88195',
    user: 'Elena Rostova',
    type: 'WITHDRAWAL',
    amount: 500.0,
    coins: 50000,
    status: 'PROCESSING',
    timestamp: new Date(Date.now() - 89 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
  {
    id: 'TXN-88196',
    user: 'Kenji Takahashi',
    type: 'COIN_PURCHASE',
    amount: 30.0,
    coins: 3000,
    status: 'COMPLETED',
    timestamp: new Date(Date.now() - 145 * 60 * 1000).toISOString(),
    isDevPlaceholder: true,
  },
];

export const MOCK_ADMIN_ACTIVITIES = [
  {
    id: 'ACT-01',
    admin: 'System Root',
    action: 'SYSTEM_BOOTSTRAP',
    target: 'Hemi Ton Admin Portal Initialized',
    time: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
    level: 'INFO',
  },
  {
    id: 'ACT-02',
    admin: 'Security Guard',
    action: 'TOKEN_VALIDATION',
    target: 'Enforced JWT Session Policy',
    time: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
    level: 'SUCCESS',
  },
  {
    id: 'ACT-03',
    admin: 'Finance Admin',
    action: 'SETTLEMENT_REVIEW',
    target: 'Batch #401 Flagged for Manual Review',
    time: new Date(Date.now() - 65 * 60 * 1000).toISOString(),
    level: 'WARNING',
  },
  {
    id: 'ACT-04',
    admin: 'Room Moderator',
    action: 'ROOM_SAFETY_LOCK',
    target: 'Room #HTR-109 Auto-Moderation Alert Cleared',
    time: new Date(Date.now() - 110 * 60 * 1000).toISOString(),
    level: 'INFO',
  },
];

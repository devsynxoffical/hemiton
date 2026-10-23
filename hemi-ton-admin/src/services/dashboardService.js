// ============================================================
// Hemi Ton Admin — Dashboard Service
// ============================================================

import apiClient from './apiClient';
import {
  MOCK_METRICS,
  MOCK_USER_GROWTH_CHART,
  MOCK_LIVE_ACTIVITY_CHART,
  MOCK_ROOM_CATEGORY_DISTRIBUTION,
  MOCK_REVENUE_SOURCE_DISTRIBUTION,
  MOCK_REVENUE_CHART,
  MOCK_RECENT_REGISTRATIONS,
  MOCK_RECENT_TRANSACTIONS,
  MOCK_ADMIN_ACTIVITIES,
} from './mockData';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_API === 'true';

export async function fetchDashboardKPIs() {
  if (USE_MOCK) {
    return { data: MOCK_METRICS, isMock: true };
  }

  try {
    const res = await apiClient.get('/v1/admin/dashboard/stats');
    return { data: res.data.data, isMock: false };
  } catch (err) {
    console.warn('[DashboardService] Live API unavailable, falling back to development placeholder KPIs:', err.message);
    return { data: MOCK_METRICS, isMock: true, fetchError: err.message };
  }
}

export async function fetchDashboardCharts() {
  if (USE_MOCK) {
    return {
      userGrowth: MOCK_USER_GROWTH_CHART,
      liveActivity: MOCK_LIVE_ACTIVITY_CHART,
      roomDistribution: MOCK_ROOM_CATEGORY_DISTRIBUTION,
      revenueDistribution: MOCK_REVENUE_SOURCE_DISTRIBUTION,
      revenueTrends: MOCK_REVENUE_CHART,
      isMock: true,
    };
  }

  try {
    const res = await apiClient.get('/v1/admin/dashboard/charts');
    return {
      userGrowth: res.data.data.userGrowth,
      liveActivity: res.data.data.liveActivity,
      roomDistribution: res.data.data.roomDistribution || MOCK_ROOM_CATEGORY_DISTRIBUTION,
      revenueDistribution: res.data.data.revenueDistribution || MOCK_REVENUE_SOURCE_DISTRIBUTION,
      revenueTrends: res.data.data.revenueTrends,
      isMock: false,
    };
  } catch (err) {
    console.warn('[DashboardService] Live charts API unavailable, falling back to development charts:', err.message);
    return {
      userGrowth: MOCK_USER_GROWTH_CHART,
      liveActivity: MOCK_LIVE_ACTIVITY_CHART,
      roomDistribution: MOCK_ROOM_CATEGORY_DISTRIBUTION,
      revenueDistribution: MOCK_REVENUE_SOURCE_DISTRIBUTION,
      revenueTrends: MOCK_REVENUE_CHART,
      isMock: true,
      fetchError: err.message,
    };
  }
}

export async function fetchRecentRegistrations() {
  if (USE_MOCK) {
    return { data: MOCK_RECENT_REGISTRATIONS, isMock: true };
  }

  try {
    const res = await apiClient.get('/v1/admin/users/recent?limit=5');
    return { data: res.data.data, isMock: false };
  } catch (err) {
    return { data: MOCK_RECENT_REGISTRATIONS, isMock: true, fetchError: err.message };
  }
}

export async function fetchRecentTransactions() {
  if (USE_MOCK) {
    return { data: MOCK_RECENT_TRANSACTIONS, isMock: true };
  }

  try {
    const res = await apiClient.get('/v1/admin/transactions/recent?limit=5');
    return { data: res.data.data, isMock: false };
  } catch (err) {
    return { data: MOCK_RECENT_TRANSACTIONS, isMock: true, fetchError: err.message };
  }
}

export async function fetchAdminActivities() {
  if (USE_MOCK) {
    return { data: MOCK_ADMIN_ACTIVITIES, isMock: true };
  }

  try {
    const res = await apiClient.get('/v1/admin/audit-logs/recent?limit=5');
    return { data: res.data.data, isMock: false };
  } catch (err) {
    return { data: MOCK_ADMIN_ACTIVITIES, isMock: true, fetchError: err.message };
  }
}

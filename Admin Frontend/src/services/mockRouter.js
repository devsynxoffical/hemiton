// ============================================================
// Hemi Ton Admin Console — Offline / Demo Mock Router (JavaScript)
// Provides complete mock data responses when backend is disconnected
// ============================================================

import {
  MOCK_DASHBOARD_STATS,
  MOCK_CHART_DATA,
  MOCK_TOP_HOSTS,
  MOCK_TOP_CONTENT,
  MOCK_RECENT_ACTIVITY,
} from '../mocks/dashboard.mock';
import { MOCK_USERS } from '../mocks/users.mock';
import { MOCK_LIVE_ROOMS } from '../mocks/liveRooms.mock';
import { MOCK_ACTIVE_HOSTS as MOCK_HOSTS } from '../mocks/hosts.mock';
import { generateMockAuditLogs } from '../mocks/auditLogs.mock';
import { MOCK_LEDGER_CHAIN as MOCK_TRANSACTIONS } from '../mocks/transactionLedger.mock';
import { MOCK_GIFTS } from '../mocks/gifts.mock';
import { bannersMock as MOCK_BANNERS } from '../mocks/banners.mock';
import { MOCK_GAMES } from '../mocks/games.mock';
import { MOCK_USER_POSTS as MOCK_POSTS } from '../mocks/posts.mock';
import { supportTicketsMock as MOCK_SUPPORT_TICKETS } from '../mocks/support.mock';
import { MOCK_VIP_ITEMS as MOCK_VIP_TIERS } from '../mocks/vip.mock';
import { storeItemsMock as MOCK_STORE_PACKAGES } from '../mocks/store.mock';
import { getMockEconomyConfigsPayload } from '../mocks/economyPolicy.mock';

let inMemoryEconomyConfigs = getMockEconomyConfigsPayload();

export async function handleMockRequest(config) {
  const url = (config.url || '').toLowerCase();
  const method = (config.method || 'get').toLowerCase();

  // Small synthetic latency (30ms) to feel responsive and natural
  await new Promise((r) => setTimeout(r, 30));

  // Mutations (POST, PUT, PATCH, DELETE)
  if (method !== 'get') {
    let parsedBody = {};
    try {
      if (typeof config.data === 'string') {
        parsedBody = JSON.parse(config.data || '{}');
      } else if (config.data) {
        parsedBody = config.data;
      }
    } catch {
      parsedBody = {};
    }

    if (url.includes('/auth/admin/login')) {
      return {
        status: 200,
        statusText: 'OK',
        headers: {},
        config,
        data: {
          success: true,
          data: {
            admin: {
              id: 'ht_admin_exec_01',
              username: parsedBody.usernameOrEmail || 'HemiTonAdmin',
              displayName: 'Hemi Ton Lead Executive',
              email: parsedBody.usernameOrEmail?.includes('@')
                ? parsedBody.usernameOrEmail
                : 'admin@hemiton.live',
              role: 'super_admin',
              roleId: 'super_admin',
              isSuperAdmin: true,
              isOwner: true,
              avatarUrl: '/ht-logo.jpg',
              permissions: ['*'],
              effectiveModules: ['*'],
            },
            accessToken: 'mock_jwt_token_hemi_ton_' + Date.now(),
            refreshToken: 'mock_refresh_token_hemi_ton_' + Date.now(),
            expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
          },
        },
      };
    }

    if (url.includes('/auth/logout')) {
      return {
        status: 200,
        statusText: 'OK',
        headers: {},
        config,
        data: { success: true, message: 'Logged out successfully.' },
      };
    }

    if (url.includes('/economy/configs') || url.includes('/economy')) {
      const urlParts = url.split('/');
      const keyOrAction = urlParts[urlParts.length - 1];
      const isDisable = url.includes('/disable');
      const isRestore = url.includes('/restore');

      const targetKey = isDisable || isRestore
        ? urlParts[urlParts.length - 2].toUpperCase()
        : keyOrAction.toUpperCase();

      let targetItem = inMemoryEconomyConfigs.find((c) => c.key.toUpperCase() === targetKey);
      if (!targetItem) {
        targetItem = {
          id: `cfg-eco-${Date.now()}`,
          key: targetKey,
          name: targetKey.replace(/_/g, ' '),
          valueJson: parsedBody.valueJson || parsedBody,
          status: 'ACTIVE',
          updatedAt: new Date().toISOString(),
        };
        inMemoryEconomyConfigs.push(targetItem);
      } else {
        if (isDisable) {
          targetItem.status = 'DISABLED';
        } else if (isRestore) {
          targetItem.status = 'ACTIVE';
        } else {
          targetItem.valueJson = parsedBody.valueJson || parsedBody;
          targetItem.updatedAt = new Date().toISOString();
        }
      }

      return {
        status: 200,
        statusText: 'OK',
        headers: {},
        config,
        data: {
          success: true,
          message: 'Economy configuration updated successfully in testing mode.',
          data: targetItem,
        },
      };
    }

    return {
      status: 200,
      statusText: 'OK',
      headers: {},
      config,
      data: {
        success: true,
        message: 'Action completed successfully in testing mode.',
        data: { id: `mock-${Date.now()}`, ...parsedBody, updatedAt: new Date().toISOString() },
      },
    };
  }

  // GET Requests Router
  let responseData = null;

  if (url.includes('/dashboard/stats')) {
    responseData = {
      ...MOCK_DASHBOARD_STATS,
      activeSocialAudioRooms: 68,
      totalAudioListeners: 3420,
      audioRoomDiamondVolume: 4850000,
      fourEyesApprovalsCount: 3,
      revenueGrowthPercent: 18.2,
      roomsGrowthPercent: 14.6,
      viewersGrowthPercent: 21.8,
    };
  } else if (url.includes('/dashboard/charts')) {
    responseData = MOCK_CHART_DATA;
  } else if (url.includes('/dashboard/content')) {
    responseData = {
      topHosts: MOCK_TOP_HOSTS,
      topContent: MOCK_TOP_CONTENT,
      recentActivities: MOCK_RECENT_ACTIVITY,
    };
  } else if (url.includes('/wallet/stats')) {
    responseData = {
      totalRechargedUSD: 284500,
      totalCoins: 12500000,
      totalDiamonds: 4850000,
      revenueGrowthPercent: 18.2,
      pendingSettlementsUSD: 14200,
      reserveFundUSD: 120000,
    };
  } else if (url.includes('/economy/configs') || url.includes('/economy') || url.includes('/policies')) {
    const urlParts = url.split('/');
    const lastPart = (urlParts[urlParts.length - 1] || '').toUpperCase();
    const matchedItem = inMemoryEconomyConfigs.find((c) => c.key.toUpperCase() === lastPart);
    responseData = matchedItem || inMemoryEconomyConfigs;
  } else if (url.includes('/users')) {
    responseData = MOCK_USERS;
  } else if (url.includes('/rooms')) {
    responseData = MOCK_LIVE_ROOMS;
  } else if (url.includes('/hosts')) {
    responseData = MOCK_HOSTS;
  } else if (url.includes('/audit-logs') || url.includes('/audit')) {
    responseData = generateMockAuditLogs();
  } else if (url.includes('/transactions') || url.includes('/ledger')) {
    responseData = MOCK_TRANSACTIONS;
  } else if (url.includes('/gifts')) {
    responseData = MOCK_GIFTS;
  } else if (url.includes('/banners')) {
    responseData = MOCK_BANNERS;
  } else if (url.includes('/games')) {
    responseData = MOCK_GAMES;
  } else if (url.includes('/posts')) {
    responseData = MOCK_POSTS;
  } else if (url.includes('/support')) {
    responseData = MOCK_SUPPORT_TICKETS;
  } else if (url.includes('/vip')) {
    responseData = MOCK_VIP_TIERS;
  } else if (url.includes('/store') || url.includes('/items')) {
    responseData = MOCK_STORE_PACKAGES;
  } else {
    // Generic fallback for any other admin collection
    responseData = [];
  }

  const isArray = Array.isArray(responseData);
  const dataPayload = isArray
    ? {
        success: true,
        data: responseData,
        pagination: {
          total: responseData.length,
          page: 1,
          limit: 20,
          totalPages: 1,
        },
      }
    : {
        success: true,
        data: responseData,
      };

  return {
    status: 200,
    statusText: 'OK',
    headers: { 'content-type': 'application/json' },
    config,
    data: dataPayload,
  };
}

export default handleMockRequest;

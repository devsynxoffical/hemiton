// ============================================================
// Hemi Ton Admin — Authentication Service
// ============================================================

import apiClient from './apiClient';

const TOKEN_KEY = 'hemi_ton_admin_token';
const SESSION_KEY = 'hemi_ton_admin_session';
const USE_MOCK = import.meta.env.VITE_USE_MOCK_API === 'true';

export async function loginAdmin({ usernameOrEmail, password }) {
  // If Mock Mode is enabled or Hemi Ton backend is not ready, simulate safe local auth
  if (USE_MOCK) {
    // Provide safe local simulated admin authentication
    const cleanUser = (usernameOrEmail || '').trim();
    if (cleanUser && password) {
      const mockSession = {
        token: `ht-dev-token-${Date.now()}`,
        admin: {
          id: 'admin-001',
          username: cleanUser,
          email: cleanUser.includes('@') ? cleanUser : `${cleanUser}@hemiton.internal`,
          role: 'SUPER_ADMIN',
          displayName: cleanUser === 'admin' ? 'Hemi Ton Administrator' : cleanUser,
        },
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        isMockDevSession: true,
      };
      saveSession(mockSession);
      return mockSession;
    }
    throw new Error('Please enter both username/email and password.');
  }

  // Live Hemi Ton Backend Auth Call
  try {
    const res = await apiClient.post('/v1/auth/admin/login', {
      usernameOrEmail,
      password,
    });

    if (res.data && res.data.success) {
      const session = {
        token: res.data.data.token || res.data.data.accessToken,
        admin: res.data.data.admin,
        expiresAt: res.data.data.expiresAt,
        isMockDevSession: false,
      };
      saveSession(session);
      return session;
    }
    throw new Error(res.data?.message || 'Invalid server response structure.');
  } catch (err) {
    if (err.isNetworkError) {
      throw new Error(
        'Hemi Ton backend service is currently unreachable at http://localhost:5000. ' +
        'Enable VITE_USE_MOCK_API=true in .env to use local mock mode during UI development.'
      );
    }
    throw err;
  }
}

export function saveSession(session) {
  if (!session) return;
  localStorage.setItem(TOKEN_KEY, session.token);
  localStorage.setItem(SESSION_KEY, JSON.stringify(session));
}

export function getSession() {
  try {
    const raw = localStorage.getItem(SESSION_KEY);
    if (!raw) return null;
    const session = JSON.parse(raw);
    if (session?.expiresAt && new Date(session.expiresAt) < new Date()) {
      clearSession();
      return null;
    }
    return session;
  } catch {
    clearSession();
    return null;
  }
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(SESSION_KEY);
}

export async function logoutAdmin() {
  try {
    if (!USE_MOCK) {
      await apiClient.post('/v1/auth/admin/logout');
    }
  } catch {
    // Non-blocking logout error
  } finally {
    clearSession();
  }
}

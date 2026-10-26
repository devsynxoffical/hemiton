// ============================================================
// Hemi Ton Admin Console — Axios API Client (JavaScript)
// ============================================================
// Backend is disconnected for client presentation / testing.
// Set IS_BACKEND_DISCONNECTED to false to reconnect live backend.
// ============================================================

import axios from 'axios';
import handleMockRequest from './mockRouter';

export const IS_BACKEND_DISCONNECTED = import.meta.env.VITE_BACKEND_DISCONNECTED !== 'false';

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'https://api.hemiton.live/api',
  timeout: 60000,
  headers: {
    'Content-Type': 'application/json',
  },
  adapter: IS_BACKEND_DISCONNECTED ? handleMockRequest : undefined,
});

let isRefreshing = false;
let failedQueue = [];

const processQueue = (error, token = null) => {
  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token);
    }
  });
  failedQueue = [];
};

let refreshPromise = null;

export const isTokenValid = (token) => {
  if (!token || typeof token !== 'string') return false;
  if (token.startsWith('mock_jwt_token_hemi_ton_')) return true;
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return false;
    const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
    if (payload.exp) {
      return payload.exp * 1000 > Date.now() + 5000;
    }
    return true;
  } catch {
    return false;
  }
};

const getValidAccessToken = async () => {
  const token = localStorage.getItem('hemi_ton_admin_token');
  const rawSession = localStorage.getItem('hemi_ton_admin_session');

  if (token && (token.startsWith('mock_jwt_token_hemi_ton_') || isTokenValid(token))) {
    return token;
  }

  let refreshToken = null;
  try {
    if (rawSession) {
      const session = JSON.parse(rawSession);
      refreshToken = session?.refreshToken;
    }
  } catch { }

  if (!refreshToken) {
    if (token) {
      localStorage.removeItem('hemi_ton_admin_token');
      localStorage.removeItem('hemi_ton_admin_session');
    }
    return null;
  }

  if (!refreshPromise) {
    refreshPromise = axios
      .post(
        `${apiClient.defaults.baseURL}/v1/auth/refresh`,
        { refreshToken },
        { headers: { 'Content-Type': 'application/json' } }
      )
      .then((res) => {
        if (res.data?.success && res.data.data?.accessToken) {
          const newAccessToken = res.data.data.accessToken;
          const newRefreshToken = res.data.data.refreshToken || refreshToken;

          localStorage.setItem('hemi_ton_admin_token', newAccessToken);
          if (rawSession) {
            try {
              const session = JSON.parse(rawSession);
              session.token = newAccessToken;
              session.refreshToken = newRefreshToken;
              session.expiresAt = res.data.data.expiresAt || session.expiresAt;
              localStorage.setItem('hemi_ton_admin_session', JSON.stringify(session));
            } catch { }
          }
          return newAccessToken;
        }
        throw new Error('Token refresh failed');
      })
      .catch((err) => {
        localStorage.removeItem('hemi_ton_admin_token');
        localStorage.removeItem('hemi_ton_admin_session');
        if (window.location.pathname !== '/admin/login') {
          window.location.href = '/admin/login';
        }
        return null;
      })
      .finally(() => {
        refreshPromise = null;
      });
  }

  return refreshPromise;
};

// ---- Request interceptor — attach fresh auth token ----
apiClient.interceptors.request.use(
  async (config) => {
    if (config.url?.includes('/auth/admin/login') || config.url?.includes('/auth/refresh') || config.url?.includes('/auth/logout')) {
      const token = localStorage.getItem('hemi_ton_admin_token');
      if (token && !config.headers.Authorization) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    }

    const token = await getValidAccessToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// ---- Response interceptor — handle token refresh and errors ----
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Only attempt refresh on 401 and when not already retrying or logging in / logging out
    if (
      error.response?.status === 401 &&
      originalRequest &&
      !originalRequest._retry &&
      !originalRequest.url?.includes('/auth/admin/login') &&
      !originalRequest.url?.includes('/auth/refresh') &&
      !originalRequest.url?.includes('/auth/logout')
    ) {
      const rawSession = localStorage.getItem('hemi_ton_admin_session');
      let refreshToken = null;
      try {
        if (rawSession) {
          const session = JSON.parse(rawSession);
          refreshToken = session?.refreshToken;
        }
      } catch {
        refreshToken = null;
      }

      if (!refreshToken) {
        localStorage.removeItem('hemi_ton_admin_token');
        localStorage.removeItem('hemi_ton_admin_session');
        if (window.location.pathname !== '/admin/login') {
          window.location.href = '/admin/login';
        }
        return Promise.reject(error);
      }

      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then((token) => {
            originalRequest._retry = true;
            originalRequest.headers.Authorization = `Bearer ${token}`;
            return apiClient(originalRequest);
          })
          .catch((err) => Promise.reject(err));
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const refreshResponse = await axios.post(
          `${apiClient.defaults.baseURL}/v1/auth/refresh`,
          { refreshToken },
          { headers: { 'Content-Type': 'application/json' } }
        );

        if (refreshResponse.data?.success && refreshResponse.data.data?.accessToken) {
          const newAccessToken = refreshResponse.data.data.accessToken;
          const newRefreshToken = refreshResponse.data.data.refreshToken || refreshToken;

          localStorage.setItem('hemi_ton_admin_token', newAccessToken);
          if (rawSession) {
            try {
              const session = JSON.parse(rawSession);
              session.token = newAccessToken;
              session.refreshToken = newRefreshToken;
              session.expiresAt = refreshResponse.data.data.expiresAt || session.expiresAt;
              localStorage.setItem('hemi_ton_admin_session', JSON.stringify(session));
            } catch { }
          }

          processQueue(null, newAccessToken);
          originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
          return apiClient(originalRequest);
        } else {
          throw new Error('Refresh token invalid');
        }
      } catch (refreshError) {
        processQueue(refreshError, null);
        localStorage.removeItem('hemi_ton_admin_token');
        localStorage.removeItem('hemi_ton_admin_session');
        if (window.location.pathname !== '/admin/login') {
          window.location.href = '/admin/login';
        }
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);

export default apiClient;


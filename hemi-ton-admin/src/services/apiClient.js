// ============================================================
// Hemi Ton Admin — Centralized API Client (Axios)
// ============================================================
// Base URL is configured strictly via VITE_API_BASE_URL.
// Dedicated to Hemi Ton backend (default: http://localhost:5000/api).
// NEVER points to ZeParty production or reference backends.
// ============================================================

import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api';
const TIMEOUT_MS = Number(import.meta.env.VITE_API_TIMEOUT) || 30000;

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: TIMEOUT_MS,
  headers: {
    'Content-Type': 'application/json',
    'X-Client-App': 'Hemi-Ton-Admin',
  },
});

// Request Interceptor: Attach Hemi Ton Admin Token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('hemi_ton_admin_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response Interceptor: Normalized Error Handling & Auth Expiration
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response ? error.response.status : null;

    if (status === 401) {
      console.warn('[Hemi Ton API] Unauthorized 401 received. Clearing administrative session.');
      localStorage.removeItem('hemi_ton_admin_token');
      localStorage.removeItem('hemi_ton_admin_session');
      if (window.location.pathname !== '/login') {
        window.location.href = '/login?expired=true';
      }
    }

    const normalizedError = {
      status,
      message:
        error.response?.data?.message ||
        error.response?.data?.error ||
        error.message ||
        'Network error or Hemi Ton backend unreachable.',
      details: error.response?.data || null,
      isNetworkError: !error.response,
    };

    return Promise.reject(normalizedError);
  }
);

export default apiClient;

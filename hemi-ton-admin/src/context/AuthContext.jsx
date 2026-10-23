// ============================================================
// Hemi Ton Admin — Auth Context
// ============================================================

import React, { createContext, useContext, useState, useEffect } from 'react';
import { getSession, loginAdmin, logoutAdmin } from '../services/authService';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const current = getSession();
    if (current) {
      setSession(current);
    }
    setLoading(false);
  }, []);

  const handleLogin = async (credentials) => {
    const newSession = await loginAdmin(credentials);
    setSession(newSession);
    return newSession;
  };

  const handleLogout = async () => {
    await logoutAdmin();
    setSession(null);
  };

  const value = {
    session,
    admin: session?.admin || null,
    isAuthenticated: !!session,
    isMockDevSession: !!session?.isMockDevSession,
    loading,
    login: handleLogin,
    logout: handleLogout,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

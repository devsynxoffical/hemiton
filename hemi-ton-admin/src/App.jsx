// ============================================================
// Hemi Ton App — Complete Routing Architecture
// Public Marketing Landing Website ('/') + Admin Portal ('/admin')
// ============================================================

import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ProtectedRoute } from './components/common/ProtectedRoute';

// Layouts
import { PublicLayout } from './layouts/PublicLayout';
import { AdminLayout } from './layouts/AdminLayout';

// Public Marketing Pages (Strictly 4 Pages: Home, Features, About, Contact)
import { LandingPage } from './pages/public/LandingPage';
import { FeaturesPage } from './pages/public/FeaturesPage';
import { AboutPage } from './pages/public/AboutPage';
import { ContactPage } from './pages/public/ContactPage';

// Admin Auth & Operations Pages
import { LoginPage } from './pages/auth/LoginPage';
import { DashboardPage } from './pages/dashboard/DashboardPage';
import { LiveRoomsPage } from './pages/rooms/LiveRoomsPage';
import { UsersPage } from './pages/users/UsersPage';
import { HostsAgenciesPage } from './pages/hosts/HostsAgenciesPage';
import { WithdrawalsPage } from './pages/finance/WithdrawalsPage';
import { TransactionsPage } from './pages/finance/TransactionsPage';
import { ModerationPage } from './pages/moderation/ModerationPage';
import { SettingsPage } from './pages/settings/SettingsPage';

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* 1. PUBLIC MARKETING WEBSITE (4 Pages: Home, Features, About Us, Contact) */}
          <Route element={<PublicLayout />}>
            <Route path="/" element={<LandingPage />} />
            <Route path="/features" element={<FeaturesPage />} />
            <Route path="/about" element={<AboutPage />} />
            <Route path="/contact" element={<ContactPage />} />
          </Route>

          {/* ======================================================== */}
          {/* 2. ADMIN AUTHENTICATION                                  */}
          {/* ======================================================== */}
          <Route path="/login" element={<LoginPage />} />
          <Route path="/admin/login" element={<LoginPage />} />

          {/* ======================================================== */}
          {/* 3. PROTECTED ADMIN OPERATIONS PORTAL ('/admin')          */}
          {/* ======================================================== */}
          <Route
            path="/admin"
            element={
              <ProtectedRoute>
                <AdminLayout />
              </ProtectedRoute>
            }
          >
            <Route index element={<DashboardPage />} />
            <Route path="rooms" element={<LiveRoomsPage />} />
            <Route path="users" element={<UsersPage />} />
            <Route path="hosts-agencies" element={<HostsAgenciesPage />} />
            <Route path="withdrawals" element={<WithdrawalsPage />} />
            <Route path="transactions" element={<TransactionsPage />} />
            <Route path="moderation" element={<ModerationPage />} />
            <Route path="settings" element={<SettingsPage />} />
          </Route>

          {/* ======================================================== */}
          {/* 4. LEGACY / CONVENIENCE REDIRECTS                        */}
          {/* ======================================================== */}
          <Route path="/dashboard" element={<Navigate to="/admin" replace />} />
          <Route path="/rooms" element={<Navigate to="/admin/rooms" replace />} />
          <Route path="/users" element={<Navigate to="/admin/users" replace />} />
          <Route path="/hosts-agencies" element={<Navigate to="/admin/hosts-agencies" replace />} />
          <Route path="/withdrawals" element={<Navigate to="/admin/withdrawals" replace />} />
          <Route path="/transactions" element={<Navigate to="/admin/transactions" replace />} />
          <Route path="/moderation" element={<Navigate to="/admin/moderation" replace />} />

          {/* Fallback Catch-all -> Landing Page */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

// ============================================================
// Hemi Ton Admin — Admin Main Layout (Cloud Blue + Slate)
// ============================================================

import React, { useState } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Sidebar } from '../components/layout/Sidebar';
import { Header } from '../components/layout/Header';
import { DevModeBanner } from '../components/common/DevModeBanner';
import { ErrorBoundary } from '../components/common/ErrorBoundary';

export function AdminLayout() {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [isMobileOpen, setIsMobileOpen] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);
  const location = useLocation();

  const handleGlobalRefresh = () => {
    setIsRefreshing(true);
    // Remount current page so every page refetches; also notify listeners (notifications)
    setRefreshKey((k) => k + 1);
    window.dispatchEvent(new CustomEvent('hemi_ton_refresh_data'));
    setTimeout(() => setIsRefreshing(false), 800);
  };

  return (
    <div className="flex h-screen flex-col overflow-hidden bg-[#E9EEF7] font-sans text-[#263957]">
      {/* Development status banner across top */}
      <DevModeBanner />

      <div className="flex flex-1 overflow-hidden">
        {/* Left Tinted Blue-Gray Sidebar (#EEF2F8) */}
        <Sidebar
          isCollapsed={isCollapsed}
          onToggleCollapse={() => setIsCollapsed((prev) => !prev)}
          isMobileOpen={isMobileOpen}
          onCloseMobile={() => setIsMobileOpen(false)}
        />

        {/* Content Shell */}
        <div className="flex flex-1 flex-col min-w-0 overflow-hidden bg-[#E9EEF7]">
          <Header onOpenMobile={() => setIsMobileOpen(true)} />

          <main className="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 bg-[#E9EEF7]">
            <ErrorBoundary key={`${location.pathname}-${refreshKey}`}>
              <Outlet />
            </ErrorBoundary>
          </main>
        </div>
      </div>
    </div>
  );
}

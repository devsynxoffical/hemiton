// ============================================================
// Hemi Ton Public — Layout Wrapper (Lighter Cloud Blue Aesthetic)
// ============================================================

import React, { useEffect } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { PublicNavbar } from '../components/public/PublicNavbar';
import { PublicFooter } from '../components/public/PublicFooter';

export function PublicLayout() {
  const location = useLocation();

  // Scroll to top on route change or hash navigation
  useEffect(() => {
    if (!location.hash) {
      window.scrollTo(0, 0);
    } else {
      const id = location.hash.replace('#', '');
      const el = document.getElementById(id);
      if (el) {
        el.scrollIntoView({ behavior: 'smooth' });
      }
    }
  }, [location.pathname, location.hash]);

  return (
    <div className="min-h-screen bg-[#F8FAFC] text-[#263957] font-sans flex flex-col selection:bg-[#5979AC] selection:text-white">
      {/* Top Fixed Header */}
      <PublicNavbar />

      {/* Main Page Content Body */}
      <main className="flex-1 flex flex-col pt-20">
        <Outlet />
      </main>

      {/* Clean Global Footer */}
      <PublicFooter />
    </div>
  );
}

// ============================================================
// Hemi Ton Admin — Top Navigation Header (Cloud Blue + Slate)
// ============================================================

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  Menu,
  Bell,
  CheckCheck,
  ChevronDown,
  LogOut,
  Settings,
  Globe,
  User,
  ShieldCheck,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { fetchAdminActivities } from '../../services/dashboardService';

const READ_KEY = 'hemi_ton_read_notifications';

function loadRead() {
  try {
    return JSON.parse(localStorage.getItem(READ_KEY) || '[]');
  } catch {
    return [];
  }
}

function timeAgo(iso) {
  const mins = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 60000));
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.round(mins / 60);
  return hrs < 24 ? `${hrs}h ago` : `${Math.round(hrs / 24)}d ago`;
}

const LEVEL_COLORS = {
  INFO: 'bg-[#5979AC]',
  SUCCESS: 'bg-[#2E7D52]',
  WARNING: 'bg-[#94601A]',
  ERROR: 'bg-[#9C3838]',
};

export function Header({ onOpenMobile }) {
  const { admin, logout } = useAuth();
  const navigate = useNavigate();

  // Notification state
  const [open, setOpen] = useState(false);
  const [items, setItems] = useState([]);
  const [readIds, setReadIds] = useState(loadRead);
  const [loading, setLoading] = useState(false);
  const wrapRef = useRef(null);

  // Profile dropdown state
  const [profileOpen, setProfileOpen] = useState(false);
  const profileRef = useRef(null);

  const loadNotifications = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetchAdminActivities();
      setItems(res.data || []);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadNotifications();
    window.addEventListener('hemi_ton_refresh_data', loadNotifications);
    return () => window.removeEventListener('hemi_ton_refresh_data', loadNotifications);
  }, [loadNotifications]);

  // Click outside listener for notifications and profile dropdown
  useEffect(() => {
    const onDown = (e) => {
      if (wrapRef.current && !wrapRef.current.contains(e.target)) {
        setOpen(false);
      }
      if (profileRef.current && !profileRef.current.contains(e.target)) {
        setProfileOpen(false);
      }
    };
    document.addEventListener('mousedown', onDown);
    return () => document.removeEventListener('mousedown', onDown);
  }, []);

  const unread = items.filter((n) => !readIds.includes(n.id));

  const persist = (ids) => {
    setReadIds(ids);
    localStorage.setItem(READ_KEY, JSON.stringify(ids));
  };
  const markRead = (id) => !readIds.includes(id) && persist([...readIds, id]);
  const markAllRead = () => persist(Array.from(new Set([...readIds, ...items.map((n) => n.id)])));

  const handleLogout = async () => {
    setProfileOpen(false);
    await logout();
    navigate('/login');
  };

  return (
    <header className="flex h-16 shrink-0 items-center justify-between border-b border-[#D8E0EC] bg-white px-4 md:px-6 shadow-2xs">
      {/* Left: Mobile hamburger + Admin Dashboard title */}
      <div className="flex items-center gap-3">
        <button
          onClick={onOpenMobile}
          className="flex lg:hidden h-9 w-9 items-center justify-center rounded-lg border border-[#D8E0EC] bg-[#F5F7FB] text-[#65738A] hover:text-[#263957]"
        >
          <Menu className="h-5 w-5" />
        </button>

        <span className="font-heading text-sm md:text-base font-bold text-[#263957] tracking-tight">
          Admin Dashboard
        </span>
      </div>

      {/* Right: Notification Bell + Profile Dropdown with Logout */}
      <div className="flex items-center gap-3">
        {/* Notification Bell */}
        <div className="relative" ref={wrapRef}>
          <button
            onClick={() => setOpen((o) => !o)}
            className="relative flex h-9 w-9 items-center justify-center rounded-xl border border-[#D8E0EC] bg-white text-[#65738A] hover:text-[#263957] hover:bg-[#F5F7FB] transition-colors shadow-2xs cursor-pointer"
            title="Notifications"
          >
            <Bell className="h-4 w-4" />
            {unread.length > 0 && (
              <span className="absolute -top-1 -right-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-[#5979AC] px-1 text-[9px] font-bold text-white">
                {unread.length}
              </span>
            )}
          </button>

          {open && (
            <div className="absolute right-0 top-11 z-50 w-80 rounded-xl border border-[#D8E0EC] bg-white shadow-xl">
              <div className="flex items-center justify-between border-b border-[#D8E0EC] px-4 py-2.5">
                <span className="text-xs font-bold text-[#263957]">Notifications</span>
                <button
                  onClick={markAllRead}
                  disabled={unread.length === 0}
                  className="flex items-center gap-1 text-[11px] font-semibold text-[#5979AC] hover:text-[#263957] disabled:opacity-40 cursor-pointer"
                >
                  <CheckCheck className="h-3.5 w-3.5" /> Mark all read
                </button>
              </div>
              <div className="max-h-80 overflow-y-auto">
                {loading && items.length === 0 ? (
                  <p className="px-4 py-6 text-center text-xs text-[#65738A]">Loading...</p>
                ) : items.length === 0 ? (
                  <p className="px-4 py-6 text-center text-xs text-[#65738A]">No notifications</p>
                ) : (
                  items.map((n) => {
                    const isRead = readIds.includes(n.id);
                    return (
                      <button
                        key={n.id}
                        onClick={() => markRead(n.id)}
                        className={`flex w-full items-start gap-2.5 border-b border-[#EEF2F8] px-4 py-3 text-left hover:bg-[#F5F7FB] cursor-pointer ${
                          isRead ? 'opacity-60' : ''
                        }`}
                      >
                        <span
                          className={`mt-1.5 h-2 w-2 shrink-0 rounded-full ${
                            LEVEL_COLORS[n.level] || 'bg-[#5979AC]'
                          }`}
                        />
                        <div className="min-w-0">
                          <p className="text-xs font-semibold text-[#263957]">
                            {n.action?.replace(/_/g, ' ')}
                          </p>
                          <p className="text-[11px] text-[#65738A]">{n.target}</p>
                          <p className="mt-0.5 text-[10px] font-mono text-[#8792A4]">
                            {n.admin} · {timeAgo(n.time)}
                          </p>
                        </div>
                      </button>
                    );
                  })
                )}
              </div>
            </div>
          )}
        </div>

        {/* User Profile Button with Dropdown & Logout */}
        <div className="relative" ref={profileRef}>
          <button
            onClick={() => setProfileOpen((o) => !o)}
            className="flex items-center gap-2 rounded-xl border border-[#D8E0EC] bg-white py-1.5 px-2.5 text-xs font-semibold text-[#263957] hover:border-[#91A9CE] hover:bg-[#F5F7FB] transition-colors shadow-2xs cursor-pointer"
            title="User Profile Menu"
          >
            <div className="flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-[#DCE6F5] border border-[#C8D7EC] font-bold text-xs text-[#263957]">
              {admin?.username ? admin.username.substring(0, 2).toUpperCase() : 'HT'}
            </div>
            <span className="hidden sm:inline font-bold">
              {admin?.displayName || admin?.username || 'Admin'}
            </span>
            <ChevronDown
              className={`h-3.5 w-3.5 text-[#65738A] transition-transform ${
                profileOpen ? 'rotate-180' : ''
              }`}
            />
          </button>

          {profileOpen && (
            <div className="absolute right-0 top-12 z-50 w-64 rounded-xl border border-[#D8E0EC] bg-white shadow-xl py-2 animate-in fade-in slide-in-from-top-2">
              {/* User Details Header */}
              <div className="px-4 py-2.5 border-b border-[#EEF2F8]">
                <p className="text-xs font-bold text-[#263957] truncate">
                  {admin?.displayName || admin?.username || 'Executive Admin'}
                </p>
                <p className="text-[11px] font-mono text-[#65738A] truncate">
                  @{admin?.username || 'admin'}
                </p>
                <span className="inline-block mt-1.5 rounded bg-[#E7F4ED] border border-[#C6E7D5] px-2 py-0.5 text-[9px] font-mono font-bold text-[#2E7D52]">
                  {admin?.role || 'SUPER_ADMIN'}
                </span>
              </div>

              {/* Navigation items */}
              <div className="py-1">
                <Link
                  to="/admin/settings"
                  onClick={() => setProfileOpen(false)}
                  className="flex items-center gap-2.5 px-4 py-2 text-xs text-[#263957] hover:bg-[#F5F7FB] transition-colors"
                >
                  <Settings className="h-4 w-4 text-[#5979AC]" />
                  <span>System Configuration</span>
                </Link>

                <Link
                  to="/"
                  onClick={() => setProfileOpen(false)}
                  className="flex items-center gap-2.5 px-4 py-2 text-xs text-[#263957] hover:bg-[#F5F7FB] transition-colors"
                >
                  <Globe className="h-4 w-4 text-[#5979AC]" />
                  <span>View Public Website</span>
                </Link>
              </div>

              {/* Explicit Logout Button */}
              <div className="border-t border-[#EEF2F8] pt-1 mt-1">
                <button
                  onClick={handleLogout}
                  className="flex w-full items-center gap-2.5 px-4 py-2 text-xs font-semibold text-[#9C3838] hover:bg-[#FCEBEB] transition-colors cursor-pointer"
                >
                  <LogOut className="h-4 w-4 text-[#9C3838]" />
                  <span>Sign Out / Log Out</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}

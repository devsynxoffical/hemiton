// ============================================================
// Hemi Ton Admin — Sidebar Navigation (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  Radio,
  Crown,
  Wallet,
  Receipt,
  ShieldAlert,
  Settings,
  LogOut,
  ChevronLeft,
  ChevronRight,
  Sparkles,
  Globe,
} from 'lucide-react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

export function Sidebar({ isCollapsed, onToggleCollapse, isMobileOpen, onCloseMobile }) {
  const { logout, admin } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  const navSections = [
    {
      title: 'Core Operations',
      items: [
        { label: 'Executive Dashboard', path: '/admin', icon: LayoutDashboard },
        { label: 'Active Live Rooms', path: '/admin/rooms', icon: Radio, count: '64' },
        { label: 'User Directory', path: '/admin/users', icon: Users },
      ],
    },
    {
      title: 'Talent & Network',
      items: [
        { label: 'Hosts & Agencies', path: '/admin/hosts-agencies', icon: Crown, count: '7 req' },
      ],
    },
    {
      title: 'Financial Command',
      items: [
        { label: 'Withdrawal Approvals', path: '/admin/withdrawals', icon: Wallet, count: '19' },
        { label: 'Transaction Ledger', path: '/admin/transactions', icon: Receipt },
      ],
    },
    {
      title: 'Governance & System',
      items: [
        { label: 'Content Moderation', path: '/admin/moderation', icon: ShieldAlert },
        { label: 'System & API Config', path: '/admin/settings', icon: Settings },
      ],
    },
  ];

  const sidebarContent = (
    <div className="flex h-full flex-col justify-between bg-[#EEF2F8] border-r border-[#D8E0EC] text-[#65738A]">
      {/* Brand Header */}
      <div>
        <div
          className={`flex border-b border-[#D8E0EC] ${
            isCollapsed
              ? 'flex-col items-center justify-center gap-1 py-2 px-2 min-h-16'
              : 'h-16 items-center justify-between px-4'
          }`}
        >
          <div className="flex items-center gap-3 overflow-hidden">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl overflow-hidden border border-[#D8E0EC] shadow-2xs bg-black ring-1 ring-[#5979AC]/20">
              <img src="/ht-logo.jpg" alt="HT Hemi Ton" className="h-full w-full object-cover" />
            </div>
            {!isCollapsed && (
              <div className="flex flex-col min-w-0">
                <span className="font-heading text-sm font-extrabold tracking-tight text-[#263957] truncate">
                  HEMI TON
                </span>
                <span className="text-[10px] font-mono tracking-wider text-[#5979AC] font-bold uppercase">
                  Executive Admin
                </span>
              </div>
            )}
          </div>

          <button
            onClick={onToggleCollapse}
            className="hidden lg:flex h-6 w-6 shrink-0 items-center justify-center rounded-lg text-[#65738A] hover:text-[#263957] hover:bg-[#DCE6F5]/50 transition-colors"
            title={isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar'}
          >
            {isCollapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
          </button>
        </div>

        {/* Navigation Items */}
        <div className="space-y-6 px-3 py-4 overflow-y-auto max-h-[calc(100vh-140px)]">
          {navSections.map((section, sIdx) => (
            <div key={sIdx}>
              {!isCollapsed && (
                <h6 className="px-3 pb-2 text-[11px] font-bold uppercase tracking-wider text-[#8792A4] font-mono">
                  {section.title}
                </h6>
              )}
              <div className="space-y-1">
                {section.items.map((item) => {
                  const Icon = item.icon;
                  return (
                    <NavLink
                      key={item.path}
                      to={item.path}
                      end={item.path === '/admin'}
                      onClick={() => onCloseMobile?.()}
                      className={({ isActive }) =>
                        `group relative flex items-center justify-between rounded-lg px-3 py-2.5 text-xs font-medium transition-all ${
                          isActive
                            ? 'bg-[#DCE6F5] text-[#263957] font-semibold border-l-3 border-[#5979AC] shadow-2xs'
                            : 'text-[#65738A] hover:bg-[#E8EDF5] hover:text-[#263957] border-l-3 border-transparent'
                        }`
                      }
                      title={isCollapsed ? item.label : undefined}
                    >
                      <div className="flex items-center gap-2.5 min-w-0">
                        <Icon className="h-4 w-4 shrink-0 transition-colors group-hover:text-[#5979AC]" />
                        {!isCollapsed && <span className="truncate">{item.label}</span>}
                      </div>
                      {!isCollapsed && item.count && (
                        <span className="rounded-full bg-[#E3E9F2] border border-[#D8E0EC] px-2 py-0.5 text-[10px] font-mono font-semibold text-[#263957]">
                          {item.count}
                        </span>
                      )}
                    </NavLink>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* User Session & Logout Footer */}
      <div className="border-t border-[#D8E0EC] p-3 space-y-2">
        {/* Link to public marketing site */}
        {!isCollapsed ? (
          <Link
            to="/"
            className="flex items-center justify-between rounded-lg px-2.5 py-1.5 text-xs text-[#5979AC] hover:bg-[#DCE6F5]/50 transition-colors"
            title="View Public Landing Page"
          >
            <div className="flex items-center gap-2">
              <Globe className="h-3.5 w-3.5" />
              <span className="font-semibold text-[11px]">Public Website</span>
            </div>
            <span className="text-[10px] font-mono text-[#8792A4]">hemiton.live</span>
          </Link>
        ) : (
          <div className="flex justify-center">
            <Link
              to="/"
              className="p-1.5 text-[#5979AC] hover:bg-[#DCE6F5]/50 rounded-lg transition-colors"
              title="View Public Website"
            >
              <Globe className="h-4 w-4" />
            </Link>
          </div>
        )}

        {!isCollapsed ? (
          <div className="space-y-2">
            <div className="flex items-center gap-2.5 rounded-xl bg-[#FFFFFF] p-2.5 border border-[#D8E0EC]">
              <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-[#DCE6F5] border border-[#C8D7EC] font-bold text-xs text-[#263957]">
                {admin?.username ? admin.username.substring(0, 2).toUpperCase() : 'HT'}
              </div>
              <div className="flex flex-col min-w-0">
                <span className="text-xs font-semibold text-[#263957] truncate">
                  {admin?.displayName || admin?.username || 'Admin'}
                </span>
                <span className="text-[10px] font-mono text-[#8792A4] truncate">
                  {admin?.role || 'SUPER_ADMIN'}
                </span>
              </div>
            </div>

            {/* Dedicated prominent Logout Button */}
            <button
              onClick={handleLogout}
              className="flex w-full items-center justify-center gap-2 rounded-xl border border-[#F6CACA] bg-[#FCEBEB]/70 py-2 px-3 text-xs font-semibold text-[#9C3838] hover:bg-[#FCEBEB] hover:border-[#9C3838]/40 transition-colors cursor-pointer shadow-2xs"
              title="Sign Out of Hemi Ton Admin"
            >
              <LogOut className="h-3.5 w-3.5" />
              <span>Log Out</span>
            </button>
          </div>
        ) : (
          <div className="flex justify-center">
            <button
              onClick={handleLogout}
              className="flex h-10 w-10 items-center justify-center rounded-xl border border-[#F6CACA] bg-[#FCEBEB]/70 text-[#9C3838] hover:bg-[#FCEBEB] transition-colors cursor-pointer shadow-2xs"
              title="Log Out"
            >
              <LogOut className="h-5 w-5" />
            </button>
          </div>
        )}
      </div>
    </div>
  );

  return (
    <>
      {/* Desktop Tinted Sidebar */}
      <aside
        className={`hidden lg:block shrink-0 transition-all duration-300 ${
          isCollapsed ? 'w-20' : 'w-64'
        }`}
      >
        {sidebarContent}
      </aside>

      {/* Mobile Drawer */}
      {isMobileOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div
            className="fixed inset-0 bg-[#263957]/30 backdrop-blur-xs"
            onClick={onCloseMobile}
          />
          <div className="fixed inset-y-0 left-0 w-72 shadow-xl">
            {sidebarContent}
          </div>
        </div>
      )}
    </>
  );
}

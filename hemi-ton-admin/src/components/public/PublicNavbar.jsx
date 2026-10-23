// ============================================================
// Hemi Ton Public — Navigation Bar (4 Pages: Home, Features, About Us, Contact)
// ============================================================

import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  Menu,
  X,
  LayoutDashboard,
  Download,
} from 'lucide-react';

export function PublicNavbar() {
  const [isScrolled, setIsScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const location = useLocation();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Close mobile drawer on route change
  useEffect(() => {
    setMobileMenuOpen(false);
  }, [location.pathname]);

  // Strictly 4 public pages
  const navLinks = [
    { label: 'Home', href: '/' },
    { label: 'Features', href: '/features' },
    { label: 'About Us', href: '/about' },
    { label: 'Contact', href: '/contact' },
  ];

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled
          ? 'bg-white/95 backdrop-blur-md shadow-xs border-b border-[#D8E0EC]'
          : 'bg-white/80 backdrop-blur-xs border-b border-[#D8E0EC]/60'
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          {/* Brand Logo */}
          <Link to="/" className="flex items-center gap-3 group">
            <div className="h-10 w-10 rounded-xl overflow-hidden shadow-xs border border-[#D8E0EC] bg-black ring-2 ring-[#5979AC]/20 group-hover:scale-105 transition-transform duration-200">
              <img src="/ht-logo.jpg" alt="Hemi Ton Logo" className="h-full w-full object-cover" />
            </div>
            <div className="flex flex-col">
              <span className="font-heading text-lg font-extrabold tracking-tight text-[#263957] group-hover:text-[#5979AC] transition-colors">
                HEMI TON
              </span>
              <span className="text-[10px] font-mono font-semibold tracking-wider text-[#5979AC] uppercase">
                Live Audio Spaces
              </span>
            </div>
          </Link>

          {/* Desktop 4-Page Navigation */}
          <nav className="hidden md:flex items-center gap-1 lg:gap-2">
            {navLinks.map((link) => {
              const isActive = location.pathname === link.href;
              return (
                <Link
                  key={link.label}
                  to={link.href}
                  className={`px-4 py-2 text-xs font-semibold rounded-lg transition-colors ${
                    isActive
                      ? 'text-[#263957] bg-[#EEF4FB] font-bold border border-[#D8E0EC]/60'
                      : 'text-[#65738A] hover:text-[#263957] hover:bg-[#EEF4FB]'
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
          </nav>

          {/* Right Action: Admin Button + Download App Button */}
          <div className="hidden md:flex items-center gap-2.5">
            <Link
              to="/admin"
              className="flex items-center gap-1.5 px-3.5 py-2 text-xs font-semibold text-[#65738A] hover:text-[#263957] hover:bg-[#EEF4FB] rounded-xl border border-[#D8E0EC] bg-white transition-all shadow-2xs"
              title="Access Administrative Operations Portal"
            >
              <LayoutDashboard className="h-3.5 w-3.5 text-[#5979AC]" />
              <span>Admin Portal</span>
            </Link>

            <a
              href="/#download"
              className="flex items-center gap-1.5 rounded-xl bg-[#5979AC] px-4 py-2 text-xs font-bold text-white shadow-xs hover:bg-[#496A9C] transition-all transform hover:-translate-y-0.5 cursor-pointer"
            >
              <Download className="h-3.5 w-3.5" />
              <span>Download App</span>
            </a>
          </div>

          {/* Mobile Menu Hamburger */}
          <div className="flex md:hidden items-center gap-2">
            <Link
              to="/admin"
              className="p-2 text-[#65738A] hover:text-[#263957] hover:bg-[#EEF4FB] rounded-lg"
              title="Admin"
            >
              <LayoutDashboard className="h-5 w-5" />
            </Link>
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-lg border border-[#D8E0EC] bg-[#F5F7FB] text-[#263957] hover:bg-[#EEF4FB] transition-colors cursor-pointer"
              aria-label="Toggle Navigation Menu"
            >
              {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden border-b border-[#D8E0EC] bg-white px-4 pt-3 pb-6 shadow-xl animate-in slide-in-from-top-3">
          <div className="flex flex-col space-y-2">
            {navLinks.map((link) => {
              const isActive = location.pathname === link.href;
              return (
                <Link
                  key={link.label}
                  to={link.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`px-4 py-2.5 rounded-lg text-sm font-semibold transition-colors ${
                    isActive
                      ? 'text-[#263957] bg-[#EEF4FB] font-bold'
                      : 'text-[#65738A] hover:bg-[#EEF4FB] hover:text-[#263957]'
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
            <div className="pt-3 border-t border-[#D8E0EC] flex flex-col gap-2">
              <a
                href="/#download"
                onClick={() => setMobileMenuOpen(false)}
                className="flex items-center justify-center gap-2 rounded-xl bg-[#5979AC] py-2.5 text-xs font-bold text-white shadow-xs"
              >
                <Download className="h-4 w-4" />
                <span>Download App</span>
              </a>

              <Link
                to="/admin"
                onClick={() => setMobileMenuOpen(false)}
                className="flex items-center justify-center gap-2 rounded-xl border border-[#D8E0EC] bg-[#F5F7FB] py-2 text-xs font-semibold text-[#263957]"
              >
                <LayoutDashboard className="h-4 w-4 text-[#5979AC]" />
                <span>Admin Management Portal</span>
              </Link>
            </div>
          </div>
        </div>
      )}
    </header>
  );
}

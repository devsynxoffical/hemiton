// ============================================================
// Hemi Ton Public — Navbar (JSX)
// ============================================================

import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, Download, ShieldCheck, Sparkles, Smartphone, ArrowDown } from 'lucide-react';
import logoUrl from '../../assets/images/ht-logo.jpg';
import { DownloadModal } from './DownloadModal';

export function PublicNavbar() {
  const [isScrolled, setIsScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [downloadModalOpen, setDownloadModalOpen] = useState(false);
  const location = useLocation();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 15);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Close mobile menu on route change
  useEffect(() => {
    setMobileMenuOpen(false);
  }, [location.pathname]);

  const navLinks = [
    { name: 'Home', path: '/' },
    { name: 'Features', path: '/features' },
    { name: 'About', path: '/about' },
    { name: 'Contact', path: '/contact' },
  ];

  const isActive = (path) => {
    if (path === '/' && location.pathname !== '/') return false;
    return location.pathname === path || (path !== '/' && location.pathname.startsWith(path));
  };

  return (
    <>
      <nav
        className={`fixed top-0 w-full z-40 transition-all duration-300 ${
          isScrolled || mobileMenuOpen
            ? 'bg-[#06090F]/95 backdrop-blur-xl border-b border-[#D4AF37]/20 shadow-[0_10px_30px_-10px_rgba(0,0,0,0.8)]'
            : 'bg-transparent border-b border-transparent'
        }`}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            {/* Logo */}
            <Link to="/" className="flex items-center gap-3 group">
              <div className="relative h-11 w-11 rounded-2xl bg-gradient-to-br from-[#1A1F2C] to-[#0A0D14] p-0.5 border border-[#D4AF37]/40 shadow-[0_0_15px_rgba(212,175,55,0.2)] group-hover:shadow-[0_0_25px_rgba(212,175,55,0.4)] transition-all">
                <img
                  src={logoUrl}
                  alt="Hemi Ton"
                  className="h-full w-full rounded-[14px] object-cover"
                />
              </div>
              <div className="flex flex-col">
                <span className="text-white font-extrabold text-xl tracking-tight font-serif bg-gradient-to-r from-white via-slate-100 to-[#D4AF37] bg-clip-text text-transparent">
                  HEMI TON
                </span>
                <span className="text-[9px] uppercase tracking-widest text-[#D4AF37] font-semibold -mt-1">
                  Live Audio & VIP Lounges
                </span>
              </div>
            </Link>

            {/* Desktop Navigation Links */}
            <div className="hidden md:flex items-center space-x-1 lg:space-x-2 bg-white/[0.03] border border-white/10 px-3 py-1.5 rounded-full backdrop-blur-md">
              {navLinks.map((link) => (
                <Link
                  key={link.name}
                  to={link.path}
                  className={`text-sm font-medium px-4 py-1.5 rounded-full transition-all ${
                    isActive(link.path)
                      ? 'text-black bg-[#D4AF37] font-semibold shadow-[0_0_15px_rgba(212,175,55,0.4)]'
                      : 'text-slate-300 hover:text-white hover:bg-white/5'
                  }`}
                >
                  {link.name}
                </Link>
              ))}
            </div>

            {/* Desktop Actions: Download CTA + Admin Link */}
            <div className="hidden md:flex items-center gap-3">
              {/* Primary Download Button */}
              <button
                onClick={() => setDownloadModalOpen(true)}
                className="relative group overflow-hidden bg-gradient-to-r from-[#D4AF37] via-[#FFF0A0] to-[#E5C158] hover:from-[#E5C158] hover:to-[#D4AF37] text-black font-bold text-xs px-3.5 py-2 rounded-xl transition-all shadow-[0_0_15px_rgba(212,175,55,0.3)] hover:shadow-[0_0_25px_rgba(212,175,55,0.5)] flex items-center gap-1.5"
              >
                <Smartphone className="w-3.5 h-3.5 group-hover:-translate-y-0.5 transition-transform" />
                <span>Download App</span>
                <ArrowDown className="w-3.5 h-3.5 group-hover:translate-y-0.5 transition-transform" />
              </button>

              {/* Admin Portal Button */}
              <Link
                to="/admin/login"
                className="text-xs font-semibold text-slate-300 hover:text-[#D4AF37] border border-white/10 hover:border-[#D4AF37]/50 bg-white/[0.02] hover:bg-[#D4AF37]/10 px-3.5 py-2.5 rounded-xl transition-all flex items-center gap-1.5"
              >
                <ShieldCheck className="w-3.5 h-3.5 text-[#D4AF37]" />
                <span>Console</span>
              </Link>
            </div>

            {/* Mobile Menu Toggle Button */}
            <div className="md:hidden flex items-center gap-2">
              <button
                onClick={() => setDownloadModalOpen(true)}
                className="bg-[#D4AF37] text-black p-2 rounded-xl text-xs font-bold flex items-center gap-1 shadow"
                aria-label="Download App"
              >
                <Download className="w-4 h-4" />
              </button>
              <button
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="text-slate-300 hover:text-white focus:outline-none p-2 rounded-xl bg-white/5 border border-white/10"
                aria-label="Toggle menu"
              >
                {mobileMenuOpen ? <X className="h-6 w-6 text-[#D4AF37]" /> : <Menu className="h-6 w-6" />}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Dropdown Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden bg-[#0A0F1A] border-b border-[#D4AF37]/20 shadow-2xl px-4 pt-3 pb-6 space-y-2 animate-in fade-in slide-in-from-top-3 duration-200">
            {navLinks.map((link) => (
              <Link
                key={link.name}
                to={link.path}
                className={`block px-4 py-3 rounded-xl text-base font-medium transition-colors ${
                  isActive(link.path)
                    ? 'text-black bg-[#D4AF37] font-bold shadow-md'
                    : 'text-slate-300 hover:text-white hover:bg-white/5'
                }`}
              >
                {link.name}
              </Link>
            ))}

            <div className="pt-3 border-t border-white/10 space-y-2">
              <button
                onClick={() => {
                  setMobileMenuOpen(false);
                  setDownloadModalOpen(true);
                }}
                className="w-full bg-gradient-to-r from-[#D4AF37] to-[#E5C158] text-black font-bold py-3 px-4 rounded-xl text-center flex items-center justify-center gap-2 shadow-lg"
              >
                <Download className="w-4 h-4" />
                <span>Download Hemi Ton App</span>
              </button>

              <Link
                to="/admin/login"
                className="block w-full text-center text-slate-300 hover:text-[#D4AF37] border border-white/10 hover:border-[#D4AF37]/40 py-2.5 px-4 rounded-xl text-sm font-semibold transition-colors"
              >
                Admin / Staff Console
              </Link>
            </div>
          </div>
        )}
      </nav>

      {/* Interactive Download Modal */}
      <DownloadModal isOpen={downloadModalOpen} onClose={() => setDownloadModalOpen(false)} />
    </>
  );
}

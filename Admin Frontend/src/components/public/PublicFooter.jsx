// ============================================================
// Hemi Ton Public — Footer (JSX)
// ============================================================

import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Apple, Play, Download, ShieldCheck, Globe, Radio, Sparkles, ExternalLink } from 'lucide-react';
import logoUrl from '../../assets/images/ht-logo.jpg';
import { DownloadModal } from './DownloadModal';

export function PublicFooter() {
  const currentYear = new Date().getFullYear();
  const [downloadModalOpen, setDownloadModalOpen] = useState(false);

  return (
    <>
      <footer className="bg-[#05080E] border-t border-[#D4AF37]/20 pt-16 pb-12 relative overflow-hidden text-slate-400">
        {/* Subtle Ambient Bottom Glow */}
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[700px] h-[250px] bg-[#D4AF37]/5 blur-[120px] rounded-full pointer-events-none" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 mb-14">
            
            {/* 1. Brand & Value Proposition Column (2 Cols wide on desktop) */}
            <div className="lg:col-span-2 space-y-4">
              <Link to="/" className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-[#1A1F2C] to-[#0A0D14] p-0.5 border border-[#D4AF37]/40 shadow-[0_0_15px_rgba(212,175,55,0.2)]">
                  <img src={logoUrl} alt="Hemi Ton" className="h-full w-full rounded-[10px] object-cover" />
                </div>
                <div>
                  <span className="text-white font-extrabold text-xl tracking-tight font-serif">HEMI TON</span>
                  <div className="text-[10px] uppercase tracking-widest text-[#D4AF37] font-semibold -mt-0.5">
                    Live Audio & VIP Lounges
                  </div>
                </div>
              </Link>
              <p className="text-slate-400 text-sm leading-relaxed max-w-sm">
                The next-generation royal entertainment network uniting high-fidelity 12-seat spatial voice lounges, 3D celestial gifts, live PK arenas, and real-time creator monetization across 45+ countries.
              </p>
              
              <div className="pt-2 flex items-center gap-3">
                <button
                  onClick={() => setDownloadModalOpen(true)}
                  className="inline-flex items-center gap-2 bg-[#D4AF37]/10 hover:bg-[#D4AF37]/20 border border-[#D4AF37]/40 hover:border-[#D4AF37] text-[#D4AF37] px-4 py-2 rounded-xl text-xs font-bold transition-all shadow"
                >
                  <Apple className="w-4 h-4" /> App Store
                </button>
                <button
                  onClick={() => setDownloadModalOpen(true)}
                  className="inline-flex items-center gap-2 bg-[#D4AF37]/10 hover:bg-[#D4AF37]/20 border border-[#D4AF37]/40 hover:border-[#D4AF37] text-[#D4AF37] px-4 py-2 rounded-xl text-xs font-bold transition-all shadow"
                >
                  <Play className="w-4 h-4 fill-current" /> Google Play
                </button>
              </div>

              <div className="pt-2 flex items-center gap-2 text-xs text-slate-500">
                <ShieldCheck className="w-4 h-4 text-emerald-400" />
                <span>Agora RTC Certified Audio Engine • ISO 27001</span>
              </div>
            </div>

            {/* 2. Platform Navigation */}
            <div>
              <h4 className="text-white font-semibold text-xs uppercase tracking-widest mb-4 flex items-center gap-1.5">
                <Radio className="w-3.5 h-3.5 text-[#D4AF37]" /> Explore
              </h4>
              <ul className="space-y-2.5 text-sm">
                <li>
                  <Link to="/" className="hover:text-[#D4AF37] transition-colors">Home Experience</Link>
                </li>
                <li>
                  <Link to="/features" className="hover:text-[#D4AF37] transition-colors flex items-center gap-1.5">
                    Platform Features
                    <span className="text-[10px] bg-[#D4AF37]/20 text-[#D4AF37] px-1.5 py-0.5 rounded font-bold">NEW</span>
                  </Link>
                </li>
                <li>
                  <Link to="/about" className="hover:text-[#D4AF37] transition-colors">About Hemi Ton</Link>
                </li>
                <li>
                  <Link to="/contact" className="hover:text-[#D4AF37] transition-colors">Contact Concierge</Link>
                </li>
                <li>
                  <button onClick={() => setDownloadModalOpen(true)} className="text-left hover:text-[#D4AF37] transition-colors">
                    Download Mobile App
                  </button>
                </li>
              </ul>
            </div>

            {/* 3. Community & Creators */}
            <div>
              <h4 className="text-white font-semibold text-xs uppercase tracking-widest mb-4 flex items-center gap-1.5">
                <Sparkles className="w-3.5 h-3.5 text-[#D4AF37]" /> Creators & Guilds
              </h4>
              <ul className="space-y-2.5 text-sm">
                <li>
                  <Link to="/contact?type=host" className="hover:text-[#D4AF37] transition-colors">Host Audition Program</Link>
                </li>
                <li>
                  <Link to="/contact?type=agency" className="hover:text-[#D4AF37] transition-colors">Agency Partnership</Link>
                </li>
                <li>
                  <Link to="/features#economy" className="hover:text-[#D4AF37] transition-colors">Virtual Economy & Coins</Link>
                </li>
                <li>
                  <Link to="/features#games" className="hover:text-[#D4AF37] transition-colors">10-Game Arcade Center</Link>
                </li>
                <li>
                  <Link to="/features#vip" className="hover:text-[#D4AF37] transition-colors">Imperial VIP Aristocracy</Link>
                </li>
              </ul>
            </div>

            {/* 4. Portal & Governance */}
            <div>
              <h4 className="text-white font-semibold text-xs uppercase tracking-widest mb-4 flex items-center gap-1.5">
                <Globe className="w-3.5 h-3.5 text-[#D4AF37]" /> Governance
              </h4>
              <ul className="space-y-2.5 text-sm">
                <li>
                  <Link to="/admin/login" className="text-[#D4AF37] hover:underline font-semibold flex items-center gap-1">
                    Staff & Admin Console <ExternalLink className="w-3 h-3" />
                  </Link>
                </li>
                <li>
                  <Link to="/about#security" className="hover:text-[#D4AF37] transition-colors">Security & AML Shield</Link>
                </li>
                <li>
                  <Link to="/contact?type=support" className="hover:text-[#D4AF37] transition-colors">24/7 VIP Concierge</Link>
                </li>
                <li>
                  <span className="text-slate-500 cursor-not-allowed hover:text-slate-400 transition-colors">Terms of Service</span>
                </li>
                <li>
                  <span className="text-slate-500 cursor-not-allowed hover:text-slate-400 transition-colors">Privacy & Data Policy</span>
                </li>
              </ul>
            </div>

          </div>

          {/* Bottom Bar */}
          <div className="pt-8 border-t border-white/10 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs">
            <div className="flex items-center gap-3">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <span className="text-slate-400">All Global Systems Operational • 99.99% Low-Latency Uptime</span>
            </div>
            <p className="text-slate-500 text-center sm:text-right">
              &copy; {currentYear} Hemi Ton Global Media Ltd. All rights reserved.
            </p>
          </div>
        </div>
      </footer>

      {/* Download Modal */}
      <DownloadModal isOpen={downloadModalOpen} onClose={() => setDownloadModalOpen(false)} />
    </>
  );
}

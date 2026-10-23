// ============================================================
// Hemi Ton Public — Modern Clean Light Footer (Slate + Cloud Blue)
// ============================================================

import React from 'react';
import { Link } from 'react-router-dom';
import {
  Radio,
  ShieldCheck,
  Heart,
  Globe,
  Sparkles,
  ExternalLink,
  Lock,
  Headphones,
  Crown,
} from 'lucide-react';

export function PublicFooter() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-[#D8E0EC] bg-[#F5F8FC] text-[#65738A] text-xs">

      {/* Main Links Grid */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16">
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-8">
          {/* Col 1: Platform Experience */}
          <div className="col-span-2 lg:col-span-2">
            <div className="flex items-center gap-2 mb-3">
              <span className="font-heading text-base font-extrabold text-[#263957] tracking-tight">
                HEMI TON
              </span>
              <span className="rounded bg-[#5979AC]/10 border border-[#5979AC]/20 px-2 py-0.5 text-[10px] font-mono font-bold text-[#5979AC]">
                V2.4 GLOBAL
              </span>
            </div>
            <p className="text-xs text-[#65738A] leading-relaxed max-w-sm mb-6">
              Hemi Ton bridges global voices with ultra-low latency spatial audio rooms, multi-seat mic battles, interactive gifting, and agency talent incubation.
            </p>
            <div className="flex items-center gap-3">
              <span className="inline-flex items-center gap-1.5 rounded-lg border border-[#D8E0EC] bg-white px-2.5 py-1 text-[11px] font-mono text-[#263957] shadow-2xs">
                <ShieldCheck className="h-3.5 w-3.5 text-[#2E7D52]" />
                Bank-Grade Escrow
              </span>
              <span className="inline-flex items-center gap-1.5 rounded-lg border border-[#D8E0EC] bg-white px-2.5 py-1 text-[11px] font-mono text-[#263957] shadow-2xs">
                <Headphones className="h-3.5 w-3.5 text-[#5979AC]" />
                Agora Spatial Audio
              </span>
            </div>
          </div>

          {/* Col 2: Audio & Entertainment */}
          <div>
            <h5 className="font-bold text-[#263957] uppercase tracking-wider text-[11px] font-mono mb-4">
              Spaces & Media
            </h5>
            <ul className="space-y-2.5">
              <li>
                <a href="/#spaces" className="hover:text-[#263957] hover:underline transition-colors">
                  Multi-Seat Party Rooms
                </a>
              </li>
              <li>
                <a href="/#spaces" className="hover:text-[#263957] hover:underline transition-colors">
                  Music & DJ Spaces
                </a>
              </li>
              <li>
                <a href="/#spaces" className="hover:text-[#263957] hover:underline transition-colors">
                  PK Battles & Tournaments
                </a>
              </li>
              <li>
                <a href="/#spaces" className="hover:text-[#263957] hover:underline transition-colors">
                  VIP Lounges
                </a>
              </li>
              <li>
                <a href="/#spaces" className="hover:text-[#263957] hover:underline transition-colors">
                  Interactive Soundboard
                </a>
              </li>
            </ul>
          </div>

          {/* Col 3: Creators & Agencies */}
          <div>
            <h5 className="font-bold text-[#263957] uppercase tracking-wider text-[11px] font-mono mb-4">
              Talent Program
            </h5>
            <ul className="space-y-2.5">
              <li>
                <a href="/#talent" className="hover:text-[#263957] hover:underline transition-colors">
                  Verified Host Perks
                </a>
              </li>
              <li>
                <a href="/#talent" className="hover:text-[#263957] hover:underline transition-colors">
                  Agency Incubation Hub
                </a>
              </li>
              <li>
                <a href="/#talent" className="hover:text-[#263957] hover:underline transition-colors">
                  Creator Revenue Split
                </a>
              </li>
              <li>
                <Link to="/contact" className="hover:text-[#263957] hover:underline transition-colors">
                  Agency Inquiries
                </Link>
              </li>
              <li>
                <a href="/#talent" className="hover:text-[#263957] hover:underline transition-colors">
                  Broadcaster Guidelines
                </a>
              </li>
            </ul>
          </div>

          {/* Col 4: Platform & Support */}
          <div>
            <h5 className="font-bold text-[#263957] uppercase tracking-wider text-[11px] font-mono mb-4">
              Company & Legal
            </h5>
            <ul className="space-y-2.5">
              <li>
                <Link to="/" className="hover:text-[#263957] hover:underline transition-colors">
                  Home
                </Link>
              </li>
              <li>
                <Link to="/features" className="hover:text-[#263957] hover:underline transition-colors">
                  Platform Features
                </Link>
              </li>
              <li>
                <Link to="/about" className="hover:text-[#263957] hover:underline transition-colors">
                  About Hemi Ton
                </Link>
              </li>
              <li>
                <Link to="/contact" className="hover:text-[#263957] hover:underline transition-colors">
                  Contact & Support
                </Link>
              </li>
              <li>
                <Link to="/admin" className="text-[#5979AC] font-semibold hover:underline transition-colors">
                  Admin Command Portal
                </Link>
              </li>
            </ul>
          </div>
        </div>
      </div>

      {/* Bottom Bar: Copyright & Compliance */}
      <div className="border-t border-[#D8E0EC] bg-[#EEF2F8] py-6">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row items-center justify-between gap-3 text-[11px] text-[#8792A4]">
          <div className="flex items-center gap-2">
            <span>© {currentYear} Hemi Ton Operations. All rights reserved.</span>
            <span>•</span>
            <span>Decoupled Global Social Architecture</span>
          </div>
          <div className="flex items-center gap-4">
            <span className="hover:text-[#263957] cursor-pointer">Privacy Policy</span>
            <span>•</span>
            <span className="hover:text-[#263957] cursor-pointer">Terms of Service</span>
            <span>•</span>
            <span className="hover:text-[#263957] cursor-pointer">Community Guidelines</span>
          </div>
        </div>
      </div>
    </footer>
  );
}

// ============================================================
// Hemi Ton Public — About Page (JSX)
// ============================================================

import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  Globe, 
  Radio, 
  ShieldCheck, 
  Sparkles, 
  TrendingUp, 
  Users, 
  Award, 
  ArrowRight, 
  CheckCircle2, 
  Server, 
  HeartHandshake,
  Layers
} from 'lucide-react';

export function AboutPage() {
  useEffect(() => {
    document.title = 'About Hemi Ton — Global Royal Entertainment Network';
    window.scrollTo(0, 0);
  }, []);

  const globalHubs = [
    { city: 'Dubai', country: 'United Arab Emirates', role: 'Global Creator Studio & MENA Operations', hosts: '12,000+ Hosts' },
    { city: 'Singapore', country: 'Singapore', role: 'Agora RTC Audio R&D & Core Latency Engineering', hosts: 'Global Audio Mesh' },
    { city: 'Riyadh', country: 'Kingdom of Saudi Arabia', role: 'VIP Aristocracy & Regional BD Center', hosts: '8,500+ VIP Guilds' },
    { city: 'London', country: 'United Kingdom', role: 'European Agency Governance & Compliance', hosts: 'Enterprise Guilds' },
    { city: 'New York', country: 'United States', role: 'Global Media Alliances & Content Creators', hosts: 'Acoustic Studios' },
  ];

  const milestones = [
    { year: '2024 Q2', title: 'The Genesis', desc: 'Hemi Ton was founded by broadcast engineers and social architects disillusioned with noisy, low-quality legacy streaming apps.' },
    { year: '2025 Q1', title: 'Agora Spatial RTC Integration', desc: 'Developed the proprietary 12-mic acoustic amphitheater engine with sub-60ms directional spatial sound.' },
    { year: '2025 Q4', title: 'MENA & Asia Beta Launch', desc: 'Over 100,000 active users joined private beta rooms, fueling $1.2M in creator gift payouts.' },
    { year: '2026 Q2', title: 'Hemi Ton 2.0 Global Rollout', desc: 'Full public launch featuring 10-Game Arcade Center, 3D Celestial Gifts, and the Imperial VIP Aristocracy.' },
  ];

  return (
    <div className="flex flex-col w-full overflow-hidden bg-[#06090F] text-slate-300">
      
      {/* 1. Hero Section */}
      <section className="relative pt-36 pb-20 lg:pt-44 lg:pb-28 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto w-full text-center">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[500px] bg-[#D4AF37]/10 blur-[150px] rounded-full pointer-events-none" />

        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#D4AF37]/10 border border-[#D4AF37]/30 text-[#D4AF37] text-xs font-semibold uppercase tracking-widest mb-6">
          <Globe className="w-3.5 h-3.5" /> Global Entertainment Network
        </div>

        <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold text-white tracking-tight leading-[1.1] mb-6">
          Empowering Voices. <br />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#D4AF37] via-[#FFF3B0] to-[#E5C158]">
            Architecting Royal Stages.
          </span>
        </h1>

        <p className="text-lg sm:text-xl text-slate-400 max-w-3xl mx-auto leading-relaxed">
          Hemi Ton was born out of a single conviction: live digital communication should be an immersive art form, not chaotic noise. We combine spatial acoustic engineering, 3D visual spectacle, and true creator equity into a single sovereign platform.
        </p>
      </section>

      {/* 2. Global Network Showcase Div (Large Image) */}
      <section className="py-16 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full border-t border-white/5">
        <div className="rounded-3xl overflow-hidden border border-[#D4AF37]/30 bg-[#0A0F1A] shadow-[0_25px_70px_rgba(212,175,55,0.15)] p-6 sm:p-10 relative">
          
          <div className="grid lg:grid-cols-12 gap-8 items-center">
            {/* Visual (7 cols) */}
            <div className="lg:col-span-7">
              <div className="rounded-2xl overflow-hidden border border-white/10 group shadow-2xl">
                <img
                  src="/hemi-global-network.jpg"
                  alt="Hemi Ton Global Social Entertainment Network"
                  className="w-full h-auto object-cover transform group-hover:scale-105 transition-transform duration-700"
                />
              </div>
            </div>

            {/* Hubs List (5 cols) */}
            <div className="lg:col-span-5 space-y-4">
              <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md">
                <Globe className="w-3.5 h-3.5" /> 5 Global Strategic Hubs
              </div>
              <h2 className="text-2xl sm:text-3xl font-bold text-white tracking-tight">
                Connected by High-Speed Neural Audio Nodes
              </h2>
              <p className="text-xs sm:text-sm text-slate-400 leading-relaxed">
                Our distributed edge clusters in the Middle East, Southeast Asia, Europe, and the Americas keep audio latency below 60 milliseconds across continents.
              </p>

              <div className="space-y-2.5 pt-2">
                {globalHubs.map((hub, i) => (
                  <div key={i} className="p-3 rounded-xl bg-white/[0.02] border border-white/5 flex items-center justify-between">
                    <div>
                      <div className="text-xs font-bold text-white flex items-center gap-2">
                        <span>{hub.city}</span>
                        <span className="text-[10px] text-slate-400 font-normal">({hub.country})</span>
                      </div>
                      <div className="text-[10px] text-slate-500 mt-0.5">{hub.role}</div>
                    </div>
                    <span className="text-[11px] font-semibold text-[#D4AF37] bg-[#D4AF37]/10 px-2 py-0.5 rounded">
                      {hub.hosts}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* 3. Three Core Pillars Divs */}
      <section className="py-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20 mb-3">
            <Award className="w-3.5 h-3.5" /> The Hemi Ton Philosophy
          </div>
          <h2 className="text-3xl sm:text-4xl font-bold text-white tracking-tight">
            Built on Three Uncompromising Foundations
          </h2>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {[
            {
              icon: Radio,
              title: 'Acoustic Dignity Over Chaos',
              desc: 'We reject distorted mono screaming. Our 12-seat spatial audio stage gives every participant distinct stereo coordinates, pro-audio filtering, and clear vocal presence.'
            },
            {
              icon: TrendingUp,
              title: 'Unrivaled Creator Economics',
              desc: 'We return 70% of virtual gift value directly to hosts. We empower agencies with real-time audit ledgers, automated daily payouts, and zero hidden platform cuts.'
            },
            {
              icon: ShieldCheck,
              title: 'Prestige Community Standards',
              desc: 'A luxury venue requires vigilant guardianship. We deploy real-time AI audio analysis and permanent hardware-level bans to keep toxic actors completely out.'
            }
          ].map((pillar, i) => (
            <div
              key={i}
              className="p-8 rounded-3xl bg-[#0A0F1A] border border-white/5 hover:border-[#D4AF37]/40 transition-all group flex flex-col justify-between shadow-lg"
            >
              <div>
                <div className="w-12 h-12 rounded-2xl bg-[#D4AF37]/10 border border-[#D4AF37]/20 flex items-center justify-center text-[#D4AF37] mb-6 group-hover:scale-110 transition-transform">
                  <pillar.icon className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-bold text-white mb-3 group-hover:text-[#D4AF37] transition-colors">
                  {pillar.title}
                </h3>
                <p className="text-sm text-slate-400 leading-relaxed">
                  {pillar.desc}
                </p>
              </div>

              <div className="pt-6 mt-6 border-t border-white/5 flex items-center text-xs text-[#D4AF37] font-semibold">
                <span>The Royal Standard</span>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* 4. Journey & Milestones Timeline */}
      <section className="py-20 bg-gradient-to-b from-[#06090F] via-[#0A0E1A] to-[#06090F] border-y border-white/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
          <div className="text-center max-w-2xl mx-auto mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-white tracking-tight mb-2">
              Our Journey & Milestones
            </h2>
            <p className="text-sm text-slate-400">
              From an acoustic engineering prototype to a global multi-million dollar live media network.
            </p>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {milestones.map((m, idx) => (
              <div
                key={idx}
                className="p-6 rounded-2xl bg-[#06090F] border border-white/10 hover:border-[#D4AF37]/30 transition-all flex flex-col justify-between"
              >
                <div>
                  <div className="text-xs font-extrabold uppercase tracking-widest text-[#D4AF37] mb-2 font-mono">
                    {m.year}
                  </div>
                  <h3 className="text-lg font-bold text-white mb-2">{m.title}</h3>
                  <p className="text-xs text-slate-400 leading-relaxed">{m.desc}</p>
                </div>
                <div className="w-8 h-1 bg-[#D4AF37]/40 rounded-full mt-6" />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 5. Enterprise Security & Architecture Specs */}
      <section id="security" className="py-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div className="p-8 sm:p-12 rounded-3xl bg-[#0A0F1A] border border-white/10 shadow-2xl">
          <div className="grid lg:grid-cols-2 gap-10 items-center">
            <div>
              <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-emerald-400 bg-emerald-500/10 px-3 py-1 rounded-md mb-4">
                <Server className="w-3.5 h-3.5" /> High Availability Infrastructure
              </div>
              <h2 className="text-3xl font-bold text-white mb-4">
                Security, Compliance & 99.99% Operational Uptime
              </h2>
              <p className="text-slate-400 text-sm leading-relaxed mb-6">
                Hemi Ton operates under international data privacy standards (GDPR, CCPA) and deploys multi-tiered financial controls to protect user balances and host earnings.
              </p>

              <div className="space-y-3">
                {[
                  'Agora RTC Enterprise Tier with 256-bit AES Media Stream Encryption',
                  'Instant Multi-Currency Wallet Settlements via Bank Wire & Crypto USDT',
                  'Automated Biometric Device MAC Fingerprinting for Banned Malicious Actors',
                  'Dedicated 24/7 VIP Concierge Resolution within 15 Minutes'
                ].map((spec, i) => (
                  <div key={i} className="flex items-center gap-3 text-xs text-slate-300">
                    <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
                    <span>{spec}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="p-5 rounded-2xl bg-[#06090F] border border-white/5 text-center">
                <div className="text-3xl font-black text-white">99.99%</div>
                <div className="text-xs text-[#D4AF37] font-semibold mt-1">Uptime SLA</div>
                <div className="text-[10px] text-slate-500 mt-0.5">Distributed RTC Mesh</div>
              </div>
              <div className="p-5 rounded-2xl bg-[#06090F] border border-white/5 text-center">
                <div className="text-3xl font-black text-white">&lt;60ms</div>
                <div className="text-xs text-[#D4AF37] font-semibold mt-1">Global Latency</div>
                <div className="text-[10px] text-slate-500 mt-0.5">Ultra-low echo</div>
              </div>
              <div className="p-5 rounded-2xl bg-[#06090F] border border-white/5 text-center">
                <div className="text-3xl font-black text-white">256-Bit</div>
                <div className="text-xs text-[#D4AF37] font-semibold mt-1">SSL Security</div>
                <div className="text-[10px] text-slate-500 mt-0.5">Bank-grade vault</div>
              </div>
              <div className="p-5 rounded-2xl bg-[#06090F] border border-white/5 text-center">
                <div className="text-3xl font-black text-white">45+</div>
                <div className="text-xs text-[#D4AF37] font-semibold mt-1">Countries Active</div>
                <div className="text-[10px] text-slate-500 mt-0.5">Zero borders</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 6. Join the Royal Guild CTA */}
      <section className="py-24 max-w-4xl mx-auto px-4 text-center">
        <h2 className="text-3xl sm:text-5xl font-bold text-white mb-4">
          Become Part of the Sovereign Network
        </h2>
        <p className="text-slate-400 text-base max-w-lg mx-auto mb-8">
          Whether you are a live creator ready for a dedicated stage or an agency seeking transparent revenue, Hemi Ton welcomes you.
        </p>

        <div className="flex flex-wrap justify-center gap-4">
          <Link
            to="/contact?type=host"
            className="bg-gradient-to-r from-[#D4AF37] to-[#E5C158] hover:from-[#E5C158] hover:to-[#D4AF37] text-black font-bold px-8 py-3.5 rounded-xl text-sm transition-all shadow-xl"
          >
            Apply for Creator Audition
          </Link>
          <Link
            to="/contact?type=agency"
            className="bg-white/5 hover:bg-white/10 border border-white/15 text-white font-semibold px-8 py-3.5 rounded-xl text-sm transition-colors"
          >
            Partner as Agency Guild
          </Link>
        </div>
      </section>

    </div>
  );
}

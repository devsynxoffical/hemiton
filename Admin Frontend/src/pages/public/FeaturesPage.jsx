// ============================================================
// Hemi Ton Public — Features Page (JSX)
// ============================================================

import React, { useEffect, useState } from 'react';
import { 
  Radio, 
  Gamepad2, 
  Gift, 
  Crown, 
  Coins, 
  ShieldCheck, 
  Users, 
  Zap, 
  Sparkles, 
  Volume2, 
  Flame, 
  Trophy, 
  ArrowRight, 
  Smartphone,
  CheckCircle2,
  Lock,
  Layers,
  ChevronRight
} from 'lucide-react';
import { DownloadModal } from '../../components/public/DownloadModal';

export function FeaturesPage() {
  const [downloadModalOpen, setDownloadModalOpen] = useState(false);
  const [selectedGameTab, setSelectedGameTab] = useState('all');
  const [activeVipTier, setActiveVipTier] = useState('sovereign');

  useEffect(() => {
    document.title = 'Platform Features — Hemi Ton VIP Audio & Live Streaming';
    window.scrollTo(0, 0);
  }, []);

  const gamesList = [
    { id: 1, name: 'Fishing Star', category: 'arcade', multiplier: '500x', desc: 'Deep-sea tactical harpoon fishing with gold kraken boss jackpots.' },
    { id: 2, name: 'Rocket Challenge', category: 'crash', multiplier: '1000x', desc: 'High-adrenaline crash multiplier. Cash out before the rocket reaches warp speed.' },
    { id: 3, name: 'PK Arena', category: 'battle', multiplier: 'Head-to-Head', desc: 'Real-time host vs host battle with live coin gifting power meter.' },
    { id: 4, name: 'Greedy Wheel', category: 'roulette', multiplier: '250x', desc: 'Classic 12-segment lucky spin with gold multiplier gems.' },
    { id: 5, name: 'European Roulette', category: 'roulette', multiplier: '36x', desc: 'High-roller VIP roulette table with live voice commentary.' },
    { id: 6, name: 'Seven Puzzle', category: 'puzzle', multiplier: '150x', desc: 'Fast-paced sequential match-3 arcade with community coin pots.' },
    { id: 7, name: 'Lion Adventure', category: 'arcade', multiplier: '300x', desc: 'Savannah treasure quest with golden lion roar multipliers.' },
    { id: 8, name: 'Football Shootout', category: 'sports', multiplier: '200x', desc: 'Penalty shootout predictor with real-time stadium cheering audio.' },
    { id: 9, name: 'Fruit Match', category: 'puzzle', multiplier: '80x', desc: 'Cascading golden fruit frenzy with combo multiplier cascades.' },
    { id: 10, name: 'Ludo Party', category: 'board', multiplier: '4-Player', desc: 'Multiplayer social board gaming directly inside live voice rooms.' },
  ];

  const filteredGames = selectedGameTab === 'all' 
    ? gamesList 
    : gamesList.filter(g => g.category === selectedGameTab);

  const vipTiers = [
    { id: 'baron', name: 'VIP Baron', color: 'from-amber-700 to-amber-900', requirement: '10,000 Coins', perks: ['Bronze Badge', 'Room Entry Sound', 'Custom Emotes'] },
    { id: 'count', name: 'VIP Count', color: 'from-slate-400 to-slate-600', requirement: '50,000 Coins', perks: ['Silver Aura', 'Priority Voice Seat', 'Animated Namecard'] },
    { id: 'duke', name: 'VIP Duke', color: 'from-yellow-500 to-amber-600', requirement: '200,000 Coins', perks: ['Golden Micro-Animation', 'Supercar Entrance Effect', 'Stealth Mode'] },
    { id: 'monarch', name: 'VIP Monarch', color: 'from-purple-500 to-indigo-700', requirement: '1,000,000 Coins', perks: ['Imperial Banner Alert', 'Full Screen Room Takeover', 'Exclusive Host Gift Room'] },
    { id: 'sovereign', name: 'Imperial Sovereign', color: 'from-[#D4AF37] to-[#FFF0A0]', requirement: '5,000,000 Coins', perks: ['Celestial Dragon Entrance', 'Global App-Wide Broadcast', 'Direct Personal VIP Concierge'] },
  ];

  return (
    <div className="flex flex-col w-full overflow-hidden bg-[#06090F] text-slate-300">
      
      {/* 1. Hero Section */}
      <section className="relative pt-36 pb-20 lg:pt-44 lg:pb-28 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto w-full text-center">
        {/* Glow backdrop */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[500px] bg-[#D4AF37]/10 blur-[140px] rounded-full pointer-events-none" />

        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#D4AF37]/10 border border-[#D4AF37]/30 text-[#D4AF37] text-xs font-semibold uppercase tracking-wider mb-6">
          <Sparkles className="w-4 h-4" /> Next-Generation Platform Architecture
        </div>

        <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold text-white tracking-tight leading-[1.1] mb-6">
          Royal Entertainment, <br className="hidden sm:inline" />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#D4AF37] via-[#FFF3B0] to-[#E5C158]">
            Engineered Without Compromise
          </span>
        </h1>

        <p className="text-lg sm:text-xl text-slate-400 max-w-3xl mx-auto mb-10 leading-relaxed">
          From 12-seat spatial voice lounges powered by Agora RTC to 3D celestial gifting animations and live 10-game arcades, explore the complete feature suite of Hemi Ton.
        </p>

        <div className="flex flex-wrap justify-center gap-4">
          <button
            onClick={() => setDownloadModalOpen(true)}
            className="bg-gradient-to-r from-[#D4AF37] to-[#E5C158] hover:from-[#E5C158] hover:to-[#D4AF37] text-black font-bold px-8 py-4 rounded-xl text-base transition-all shadow-[0_0_25px_rgba(212,175,55,0.4)] hover:shadow-[0_0_35px_rgba(212,175,55,0.6)] flex items-center gap-2"
          >
            <Smartphone className="w-5 h-5" />
            <span>Download Mobile App</span>
          </button>
          <a
            href="#spatial-audio"
            className="bg-white/[0.04] hover:bg-white/[0.08] border border-white/10 hover:border-[#D4AF37]/50 text-white font-semibold px-8 py-4 rounded-xl text-base transition-all flex items-center gap-2"
          >
            <span>Explore All Capabilities</span>
            <ChevronRight className="w-4 h-4 text-[#D4AF37]" />
          </a>
        </div>
      </section>

      {/* 2. Feature 1: Spatial 3D Audio Lounge (Large Image Showcase) */}
      <section id="spatial-audio" className="py-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full border-t border-white/5">
        <div className="grid lg:grid-cols-12 gap-10 items-center">
          {/* Text & Points (5 cols) */}
          <div className="lg:col-span-5 space-y-6">
            <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20">
              <Radio className="w-3.5 h-3.5" /> High-Fidelity Audio
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold text-white tracking-tight leading-tight">
              12-Seat Spatial HD Voice Amphitheater
            </h2>
            <p className="text-slate-400 text-base leading-relaxed">
              Step into an acoustic digital sanctuary. Hemi Ton replaces legacy mono streams with real-time spatial positioning, noise suppression, and Dolby-grade clarity.
            </p>

            <div className="space-y-4 pt-2">
              {[
                { title: 'Sub-60ms Ultra-Low Latency', desc: 'Powered by globally distributed Agora RTC nodes across 45 countries with zero noticeable echo.' },
                { title: 'Dynamic 12-Mic Seat Matrix', desc: 'Configurable host controls: lock mics, mute participants, elevate VIP speakers, and assign co-hosts.' },
                { title: 'Pro Soundboard & Real-Time FX', desc: 'Built-in pitch shifting, applause soundboards, background studio acoustics, and stereo instruments.' }
              ].map((item, idx) => (
                <div key={idx} className="flex items-start gap-3 p-3.5 rounded-xl bg-white/[0.02] border border-white/5 hover:border-[#D4AF37]/30 transition-colors">
                  <div className="w-7 h-7 rounded-lg bg-[#D4AF37]/20 flex items-center justify-center text-[#D4AF37] shrink-0 mt-0.5">
                    <CheckCircle2 className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-white">{item.title}</h4>
                    <p className="text-xs text-slate-400 mt-0.5">{item.desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Large Visual Card (7 cols) */}
          <div className="lg:col-span-7">
            <div className="relative rounded-3xl overflow-hidden border border-[#D4AF37]/30 shadow-[0_20px_50px_rgba(0,0,0,0.8)] group">
              <img 
                src="/hemi-live-stage.jpg" 
                alt="Hemi Ton Live Audio Lounge" 
                className="w-full h-auto object-cover transform group-hover:scale-[1.02] transition-transform duration-700" 
              />
              {/* Overlay Badges */}
              <div className="absolute top-4 left-4 bg-black/70 backdrop-blur-md border border-[#D4AF37]/40 px-3.5 py-1.5 rounded-xl flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-ping" />
                <span className="text-xs font-bold text-white uppercase tracking-wider">Agora RTC • HD Spatial</span>
              </div>
              <div className="absolute bottom-4 right-4 bg-black/80 backdrop-blur-md border border-white/10 px-4 py-2 rounded-xl text-right">
                <div className="text-[10px] text-slate-400 uppercase">Live Capacity</div>
                <div className="text-sm font-bold text-[#D4AF37]">12 Mics • 50,000+ Listeners</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 3. Feature 2: Virtual Economy & 3D Celestial Gifts */}
      <section id="economy" className="py-20 bg-gradient-to-b from-[#06090F] via-[#090D18] to-[#06090F] border-y border-white/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
          <div className="grid lg:grid-cols-12 gap-10 items-center">
            
            {/* Visual Card (7 cols on left) */}
            <div className="lg:col-span-7 order-2 lg:order-1">
              <div className="relative rounded-3xl overflow-hidden border border-[#D4AF37]/30 shadow-[0_20px_50px_rgba(212,175,55,0.15)] group">
                <img 
                  src="/hemi-gifts-economy.jpg" 
                  alt="Hemi Ton Celestial Virtual Gifts" 
                  className="w-full h-auto object-cover transform group-hover:scale-[1.02] transition-transform duration-700" 
                />
                <div className="absolute top-4 right-4 bg-black/80 backdrop-blur-md border border-[#D4AF37]/40 px-3.5 py-1.5 rounded-xl flex items-center gap-2">
                  <Sparkles className="w-4 h-4 text-[#D4AF37]" />
                  <span className="text-xs font-bold text-[#D4AF37]">Golden Dragon Ascent • 10,000 Coins</span>
                </div>
              </div>
            </div>

            {/* Content (5 cols on right) */}
            <div className="lg:col-span-5 space-y-6 order-1 lg:order-2">
              <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20">
                <Gift className="w-3.5 h-3.5" /> Virtual Economy & Gifting
              </div>
              <h2 className="text-3xl sm:text-4xl font-bold text-white tracking-tight leading-tight">
                Imperial 3D Celestial Gifting & Creator Rewards
              </h2>
              <p className="text-slate-400 text-base leading-relaxed">
                Transform live interactions into high-status celebrations. Users unlock 50+ animated 3D gifts that illuminate rooms with screen-filling dragons, gold supercars, and diamond coronets.
              </p>

              <div className="grid sm:grid-cols-2 gap-3 pt-2">
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
                  <Coins className="w-5 h-5 text-[#D4AF37] mb-2" />
                  <div className="text-sm font-bold text-white">Instant Wallet Sync</div>
                  <div className="text-xs text-slate-400 mt-1">Multi-channel recharge via Apple Pay, Google Pay, cards, and crypto USDT.</div>
                </div>
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
                  <Flame className="w-5 h-5 text-amber-400 mb-2" />
                  <div className="text-sm font-bold text-white">Combo Gift Streaks</div>
                  <div className="text-xs text-slate-400 mt-1">Accumulate multiplier combos (x66, x188, x520) with global sound alerts.</div>
                </div>
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
                  <Trophy className="w-5 h-5 text-yellow-400 mb-2" />
                  <div className="text-sm font-bold text-white">Daily Leaderboards</div>
                  <div className="text-xs text-slate-400 mt-1">Top gifters and hosts receive customized app frames and prestigious crowns.</div>
                </div>
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
                  <Zap className="w-5 h-5 text-emerald-400 mb-2" />
                  <div className="text-sm font-bold text-white">70% Host Settlement</div>
                  <div className="text-xs text-slate-400 mt-1">Transparent coin-to-cash conversion with zero hidden deductions.</div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* 4. Feature 3: 10-Game Arcade Center */}
      <section id="games" className="py-24 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div className="text-center max-w-3xl mx-auto mb-12">
          <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20 mb-3">
            <Gamepad2 className="w-3.5 h-3.5" /> Social Gaming Matrix
          </div>
          <h2 className="text-3xl sm:text-5xl font-bold text-white tracking-tight">
            10-Game Live Arcade Center
          </h2>
          <p className="text-slate-400 text-base mt-3">
            Integrated minigames built directly into audio lounges so hosts and listeners can wager coins, celebrate jackpots, and fuel non-stop energy together.
          </p>

          {/* Filter Pills */}
          <div className="flex flex-wrap justify-center gap-2 mt-8">
            {['all', 'arcade', 'crash', 'roulette', 'battle', 'puzzle', 'sports', 'board'].map((tab) => (
              <button
                key={tab}
                onClick={() => setSelectedGameTab(tab)}
                className={`text-xs uppercase font-bold px-4 py-2 rounded-xl transition-all ${
                  selectedGameTab === tab
                    ? 'bg-[#D4AF37] text-black shadow-lg shadow-[#D4AF37]/20'
                    : 'bg-white/[0.04] text-slate-400 hover:text-white hover:bg-white/10 border border-white/5'
                }`}
              >
                {tab}
              </button>
            ))}
          </div>
        </div>

        {/* Games Grid */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-5 gap-4">
          {filteredGames.map((game) => (
            <div
              key={game.id}
              className="bg-[#0A0F1A] border border-white/5 hover:border-[#D4AF37]/40 rounded-2xl p-5 transition-all group hover:-translate-y-1.5 flex flex-col justify-between shadow-lg"
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <div className="w-10 h-10 rounded-xl bg-[#D4AF37]/10 border border-[#D4AF37]/20 flex items-center justify-center text-[#D4AF37] group-hover:bg-[#D4AF37] group-hover:text-black transition-colors">
                    <Gamepad2 className="w-5 h-5" />
                  </div>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-300 border border-amber-500/20">
                    {game.multiplier}
                  </span>
                </div>
                <h3 className="text-base font-bold text-white group-hover:text-[#D4AF37] transition-colors">
                  {game.name}
                </h3>
                <p className="text-xs text-slate-400 mt-1.5 line-clamp-3 leading-relaxed">
                  {game.desc}
                </p>
              </div>

              <div className="pt-4 mt-3 border-t border-white/5 flex items-center justify-between text-[11px] text-slate-500">
                <span className="capitalize">{game.category}</span>
                <span className="text-[#D4AF37] font-semibold flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                  Live in-room &rarr;
                </span>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* 5. Feature 4: Imperial VIP Aristocracy Tiers */}
      <section id="vip" className="py-20 bg-gradient-to-b from-[#06090F] via-[#0D1220] to-[#06090F] border-t border-white/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
          <div className="text-center max-w-3xl mx-auto mb-14">
            <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20 mb-3">
              <Crown className="w-3.5 h-3.5" /> Prestige Aristocracy
            </div>
            <h2 className="text-3xl sm:text-5xl font-bold text-white tracking-tight">
              The Imperial VIP System
            </h2>
            <p className="text-slate-400 text-base mt-3">
              Ascend from Baron to Imperial Sovereign. Command room-wide entrances, golden name styling, and priority mic seating.
            </p>
          </div>

          {/* Interactive VIP Selector */}
          <div className="grid lg:grid-cols-5 gap-4">
            {vipTiers.map((tier) => {
              const isSelected = activeVipTier === tier.id;
              return (
                <div
                  key={tier.id}
                  onClick={() => setActiveVipTier(tier.id)}
                  className={`cursor-pointer rounded-2xl p-6 transition-all border ${
                    isSelected
                      ? 'bg-gradient-to-b from-white/[0.08] to-white/[0.02] border-[#D4AF37] shadow-[0_0_25px_rgba(212,175,55,0.25)] scale-[1.02]'
                      : 'bg-[#0A0F1A] border-white/5 hover:border-white/20'
                  }`}
                >
                  <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${tier.color} p-0.5 flex items-center justify-center text-white mb-4 shadow-md`}>
                    <Crown className="w-6 h-6" />
                  </div>
                  <h3 className="text-lg font-bold text-white">{tier.name}</h3>
                  <div className="text-xs font-semibold text-[#D4AF37] mt-1">{tier.requirement}</div>

                  <div className="pt-4 mt-4 border-t border-white/10 space-y-2">
                    {tier.perks.map((perk, i) => (
                      <div key={i} className="flex items-center gap-2 text-xs text-slate-300">
                        <CheckCircle2 className="w-3.5 h-3.5 text-[#D4AF37] shrink-0" />
                        <span>{perk}</span>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* 6. Feature 5: Agency Guild Infrastructure & Enterprise Security */}
      <section className="py-24 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div className="grid md:grid-cols-2 gap-8">
          
          {/* Agency Div */}
          <div className="p-8 sm:p-10 rounded-3xl bg-[#0A0F1A] border border-white/10 hover:border-[#D4AF37]/30 transition-all flex flex-col justify-between">
            <div>
              <div className="w-12 h-12 rounded-2xl bg-[#D4AF37]/10 flex items-center justify-center text-[#D4AF37] mb-6">
                <Users className="w-6 h-6" />
              </div>
              <h3 className="text-2xl font-bold text-white mb-3">Agency Guild & Host Infrastructure</h3>
              <p className="text-slate-400 text-sm leading-relaxed mb-6">
                Comprehensive guild management consoles for talent managers. Monitor daily host hours, gift volume, commission splits, and automated bank settlements.
              </p>
              <ul className="space-y-2.5 text-xs text-slate-300">
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-[#D4AF37]" /> Multi-Tier Agency Hierarchy (BD Center &rarr; Master Agency &rarr; Sub-Agency)
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-[#D4AF37]" /> Daily settlement logs with zero holdbacks
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-[#D4AF37]" /> Direct BD Center rep assistance in Dubai & Singapore
                </li>
              </ul>
            </div>
            <div className="pt-6 mt-6 border-t border-white/10">
              <a href="/contact?type=agency" className="text-sm font-bold text-[#D4AF37] hover:underline flex items-center gap-2">
                Apply for Agency Guild Program &rarr;
              </a>
            </div>
          </div>

          {/* Security Div */}
          <div className="p-8 sm:p-10 rounded-3xl bg-[#0A0F1A] border border-white/10 hover:border-[#D4AF37]/30 transition-all flex flex-col justify-between">
            <div>
              <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 flex items-center justify-center text-emerald-400 mb-6">
                <ShieldCheck className="w-6 h-6" />
              </div>
              <h3 className="text-2xl font-bold text-white mb-3">Enterprise AML & Security Shield</h3>
              <p className="text-slate-400 text-sm leading-relaxed mb-6">
                Multi-layered risk assessment engine preventing fraudulent recharges, unauthorized chargebacks, bot rings, and harmful speech in live broadcasts.
              </p>
              <ul className="space-y-2.5 text-xs text-slate-300">
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" /> AI Real-time Audio Stream Content Moderation
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" /> Hardware Device Fingerprinting & Permanent MAC Bans
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" /> 256-Bit SSL Encryption with Bank-Grade KYC Verification
                </li>
              </ul>
            </div>
            <div className="pt-6 mt-6 border-t border-white/10">
              <a href="/about#security" className="text-sm font-bold text-emerald-400 hover:underline flex items-center gap-2">
                Read our Security & Compliance charter &rarr;
              </a>
            </div>
          </div>

        </div>
      </section>

      {/* 7. Bottom Call-To-Action Div */}
      <section className="py-24 max-w-5xl mx-auto px-4 text-center">
        <div className="p-10 sm:p-14 rounded-3xl bg-gradient-to-br from-[#121826] via-[#0A0F1A] to-[#06090F] border border-[#D4AF37]/30 shadow-[0_20px_60px_-15px_rgba(212,175,55,0.25)] relative overflow-hidden">
          <div className="absolute top-0 right-0 w-80 h-80 bg-[#D4AF37]/10 blur-[100px] pointer-events-none" />
          
          <h2 className="text-3xl sm:text-5xl font-bold text-white mb-4 relative z-10">
            Ready to Experience Hemi Ton?
          </h2>
          <p className="text-base sm:text-lg text-slate-400 max-w-xl mx-auto mb-8 relative z-10">
            Join thousands of active hosts, VIP listeners, and gaming fans across the world today.
          </p>

          <div className="flex flex-wrap justify-center gap-4 relative z-10">
            <button
              onClick={() => setDownloadModalOpen(true)}
              className="bg-gradient-to-r from-[#D4AF37] to-[#E5C158] hover:from-[#E5C158] hover:to-[#D4AF37] text-black font-bold px-8 py-3.5 rounded-xl text-base transition-all shadow-xl"
            >
              Get Hemi Ton on iOS & Android
            </button>
            <a
              href="/contact?type=host"
              className="bg-white/5 hover:bg-white/10 border border-white/10 text-white font-semibold px-8 py-3.5 rounded-xl text-base transition-colors"
            >
              Apply as Verified Creator
            </a>
          </div>
        </div>
      </section>

      {/* Download Modal */}
      <DownloadModal isOpen={downloadModalOpen} onClose={() => setDownloadModalOpen(false)} />
    </div>
  );
}

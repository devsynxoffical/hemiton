// ============================================================
// Hemi Ton Public — Home Page (JSX)
// ============================================================

import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { 
  Radio, 
  Sparkles, 
  Smartphone, 
  Apple, 
  Play, 
  Download, 
  QrCode, 
  Star, 
  ShieldCheck, 
  Users, 
  Gamepad2, 
  Gift, 
  Crown, 
  Zap, 
  Volume2, 
  VolumeX,
  Flame, 
  ArrowRight, 
  ArrowDown, 
  CheckCircle2,
  TrendingUp,
  Activity,
  Layers
} from 'lucide-react';
import { DownloadModal } from '../../components/public/DownloadModal';

export function HomePage() {
  const [downloadModalOpen, setDownloadModalOpen] = useState(false);
  const [playingRoomId, setPlayingRoomId] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState('all');

  useEffect(() => {
    document.title = 'Hemi Ton — Next-Gen Royal Live Audio & VIP Streaming';
    window.scrollTo(0, 0);
  }, []);

  const liveRooms = [
    {
      id: 'room-1',
      title: 'Vibe & Chill | Global Acoustic Cafe ☕',
      host: 'Aria Vance',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
      listeners: '1,420',
      tag: 'Music & Chill',
      category: 'music',
      hot: true
    },
    {
      id: 'room-2',
      title: 'Crypto & Web3 Sovereign Summit 🚀',
      host: 'Marcus Chen',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      listeners: '890',
      tag: 'Tech & Economy',
      category: 'talk',
      hot: false
    },
    {
      id: 'room-3',
      title: 'Late Night Poetry & Deep House Beats 🌙',
      host: 'Layla Al-Mansoor',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
      listeners: '2,150',
      tag: 'Acoustic Vibe',
      category: 'music',
      hot: true
    },
    {
      id: 'room-4',
      title: 'High Stakes PK Battle: Team Dubai vs Team London 🔥',
      host: 'Captain Alex',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
      listeners: '3,840',
      tag: 'Live PK Arena',
      category: 'pk',
      hot: true
    }
  ];

  const filteredRooms = selectedCategory === 'all' 
    ? liveRooms 
    : liveRooms.filter(r => r.category === selectedCategory);

  const toggleRoomAudio = (id) => {
    if (playingRoomId === id) {
      setPlayingRoomId(null);
    } else {
      setPlayingRoomId(id);
    }
  };

  return (
    <div className="flex flex-col w-full overflow-hidden bg-[#06090F] text-slate-300">
      
      {/* ======================================================== */}
      {/* 1. HERO SECTION                                          */}
      {/* ======================================================== */}
      <section className="relative pt-32 pb-16 lg:pt-44 lg:pb-24 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto w-full flex flex-col items-center text-center">
        {/* Ambient Cosmic Gold Aura */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[550px] bg-[#D4AF37]/10 blur-[150px] rounded-full pointer-events-none" />
        <div className="absolute top-1/4 left-1/4 w-[350px] h-[350px] bg-cyan-500/5 blur-[120px] rounded-full pointer-events-none" />

        {/* Prestige Tag */}
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-gradient-to-r from-[#D4AF37]/15 to-[#D4AF37]/5 border border-[#D4AF37]/30 text-[#D4AF37] text-xs font-semibold uppercase tracking-widest mb-6 relative z-10 shadow-[0_0_15px_rgba(212,175,55,0.15)]">
          <Sparkles className="w-3.5 h-3.5 animate-pulse" /> The Royal Era of Social Streaming
        </div>

        {/* Main Title */}
        <h1 className="text-3xl sm:text-5xl lg:text-5xl font-extrabold text-white tracking-tight leading-[1.12] mb-5 relative z-10 max-w-4xl">
          Where Voices Command The Stage. <br />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#D4AF37] via-[#FFF3B0] to-[#E5C158]">
            Where Royals Gather.
          </span>
        </h1>

        {/* Subtitle */}
        <p className="text-sm sm:text-base text-slate-300 mb-8 max-w-2xl mx-auto relative z-10 leading-relaxed font-normal">
          Immerse in crystal-clear <span className="text-white font-semibold">12-seat spatial audio lounges</span>, 3D celestial gifting animations, real-time live PK arenas, and an electrifying creator economy built for creators who demand excellence.
        </p>

        {/* CTA Button Strip */}
        <div className="flex flex-col sm:flex-row gap-3.5 relative z-10 mb-12 w-full sm:w-auto justify-center">
          <button
            onClick={() => setDownloadModalOpen(true)}
            className="bg-gradient-to-r from-[#D4AF37] via-[#FFF0A0] to-[#E5C158] hover:from-[#E5C158] hover:to-[#D4AF37] text-black font-bold py-2.5 px-6 rounded-xl transition-all shadow-[0_0_20px_rgba(212,175,55,0.35)] hover:shadow-[0_0_30px_rgba(212,175,55,0.55)] flex items-center justify-center gap-2 text-sm group"
          >
            <Smartphone className="w-4 h-4 group-hover:-translate-y-0.5 transition-transform" />
            <span>Download App</span>
            <ArrowDown className="w-4 h-4 group-hover:translate-y-0.5 transition-transform" />
          </button>
          
          <Link
            to="/features"
            className="bg-white/[0.04] hover:bg-white/[0.08] border border-white/10 hover:border-[#D4AF37]/50 text-white font-semibold py-2.5 px-6 rounded-xl transition-all flex items-center justify-center gap-2 text-sm"
          >
            <span>Explore Platform Features</span>
            <ArrowRight className="w-4 h-4 text-[#D4AF37]" />
          </Link>
        </div>

        {/* High-Impact Metric Strip Div */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 w-full max-w-5xl relative z-10">
          {[
            { label: 'Active Streamers & Listeners', value: '500,000+', icon: Users, sub: 'Across 45+ Countries' },
            { label: 'Spatial Voice Capacity', value: '12 Mics', icon: Radio, sub: 'Dolby-Grade Acoustics' },
            { label: 'Audio Engine Latency', value: '< 60ms', icon: Zap, sub: 'Powered by Agora RTC' },
            { label: 'Direct Host Earnings Paid', value: '$2.8M+', icon: TrendingUp, sub: 'Zero Hidden Cuts' },
          ].map((stat, i) => (
            <div 
              key={i} 
              className="p-4 sm:p-5 rounded-2xl bg-gradient-to-b from-white/[0.04] to-white/[0.01] border border-white/10 hover:border-[#D4AF37]/40 transition-all text-left group"
            >
              <div className="w-8 h-8 rounded-lg bg-[#D4AF37]/10 flex items-center justify-center text-[#D4AF37] mb-3 group-hover:scale-110 transition-transform">
                <stat.icon className="w-4 h-4" />
              </div>
              <div className="text-xl sm:text-2xl font-bold text-white tracking-tight">{stat.value}</div>
              <div className="text-xs font-semibold text-slate-300 mt-1">{stat.label}</div>
              <div className="text-[11px] text-slate-500 mt-0.5">{stat.sub}</div>
            </div>
          ))}
        </div>
      </section>

      {/* ======================================================== */}
      {/* 2. THE HERO SHOWCASE DIV: LEANING IPHONE APP STORE SCREEN */}
      {/* ======================================================== */}
      <section className="py-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full relative">
        <div className="relative rounded-3xl bg-gradient-to-br from-[#0D1322] via-[#090D18] to-[#06090F] border border-[#D4AF37]/30 p-8 sm:p-12 lg:p-16 shadow-[0_20px_70px_rgba(212,175,55,0.15)] overflow-hidden">
          
          {/* Subtle Ambient Background Flare */}
          <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-[#D4AF37]/10 blur-[140px] pointer-events-none" />
          <div className="absolute bottom-0 left-0 w-[350px] h-[350px] bg-amber-500/5 blur-[100px] pointer-events-none" />

          <div className="grid lg:grid-cols-12 gap-12 items-center relative z-10">
            
            {/* Left Column: App Store Details & Download Actions (6 cols) */}
            <div className="lg:col-span-6 space-y-6 text-left">
              <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3.5 py-1.5 rounded-full border border-[#D4AF37]/25">
                <Smartphone className="w-4 h-4" /> Official Mobile App Release
              </div>

              <h2 className="text-2xl sm:text-4xl font-extrabold text-white tracking-tight leading-tight">
                Get <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#D4AF37] via-[#FFF0A0] to-[#E5C158]">Hemi Ton</span> on iPhone & Android
              </h2>

              <p className="text-slate-300 text-sm sm:text-base leading-relaxed">
                Take the entire royal entertainment universe wherever you go. Stream in ultra-low latency, send full-screen 3D celestial dragons, and lead your agency guild directly from your phone.
              </p>

              {/* App Store Rating Banner Div */}
              <div className="flex flex-wrap items-center gap-4 p-4 rounded-2xl bg-white/[0.03] border border-white/10">
                <div className="flex items-center gap-1 text-[#D4AF37]">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 fill-current" />
                  ))}
                </div>
                <div className="text-sm">
                  <span className="font-bold text-white">4.9 / 5.0</span>
                  <span className="text-slate-400 text-xs ml-2">12.4K Ratings on Apple App Store</span>
                </div>
              </div>

              {/* App Highlights Checkpoints */}
              <div className="grid sm:grid-cols-2 gap-3 pt-1">
                {[
                  '12-Seat Spatial HD Audio',
                  'Instant Coin Wallet',
                  'Live PK Battles & Arenas',
                  '3D Dragons & Supercar Gifts',
                  'Agora Low-Latency Engine',
                  '24/7 VIP Concierge Support'
                ].map((feat, idx) => (
                  <div key={idx} className="flex items-center gap-2 text-xs text-slate-300">
                    <CheckCircle2 className="w-4 h-4 text-[#D4AF37] shrink-0" />
                    <span>{feat}</span>
                  </div>
                ))}
              </div>

              {/* Download Buttons Strip */}
              <div className="pt-4 flex flex-wrap gap-3 items-center">
                <a
                  href="#app-store"
                  onClick={(e) => { e.preventDefault(); setDownloadModalOpen(true); }}
                  className="inline-flex items-center gap-3 bg-white hover:bg-slate-100 text-black px-5 py-3 rounded-xl font-bold text-sm transition-all shadow-md group"
                >
                  <Apple className="w-5 h-5 group-hover:scale-110 transition-transform" />
                  <div className="text-left leading-tight">
                    <div className="text-[10px] text-slate-600 uppercase font-semibold">Download on</div>
                    <div className="text-sm font-extrabold">App Store</div>
                  </div>
                </a>

                <a
                  href="#google-play"
                  onClick={(e) => { e.preventDefault(); setDownloadModalOpen(true); }}
                  className="inline-flex items-center gap-3 bg-[#111A2E] hover:bg-[#162138] border border-white/15 text-white px-5 py-3 rounded-xl font-bold text-sm transition-all shadow-md group"
                >
                  <Play className="w-5 h-5 fill-current text-emerald-400 group-hover:scale-110 transition-transform" />
                  <div className="text-left leading-tight">
                    <div className="text-[10px] text-slate-400 uppercase font-semibold">Get it on</div>
                    <div className="text-sm font-extrabold">Google Play</div>
                  </div>
                </a>

                <button
                  onClick={() => setDownloadModalOpen(true)}
                  className="inline-flex items-center gap-2 bg-[#D4AF37]/10 hover:bg-[#D4AF37]/20 border border-[#D4AF37]/40 text-[#D4AF37] px-4 py-3 rounded-xl text-xs font-bold transition-all"
                >
                  <Download className="w-4 h-4" />
                  <span>Direct APK</span>
                </button>
              </div>

              {/* QR Code Mini Scan Div */}
              <div className="pt-2 flex items-center gap-3 text-xs text-slate-400">
                <div className="p-1.5 bg-white rounded-lg">
                  <QrCode className="w-5 h-5 text-black" />
                </div>
                <span>Scan with mobile camera for instant one-tap installation</span>
              </div>
            </div>

            {/* Right Column: Leaning iPhone Showcase with 3D Float (6 cols) */}
            <div className="lg:col-span-6 flex justify-center relative">
              <div className="relative max-w-sm sm:max-w-md w-full">
                
                {/* The Leaning iPhone Image */}
                <div className="relative rounded-3xl overflow-hidden shadow-[0_30px_70px_rgba(0,0,0,0.9)] border border-[#D4AF37]/40 group">
                  <img
                    src="/iphone-mockup.jpg"
                    alt="Hemi Ton Leaning iPhone App Store Screen"
                    className="w-full h-auto object-cover transform group-hover:scale-105 transition-transform duration-700"
                  />
                  {/* Glassmorphic Gradient Overlay on edges */}
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent pointer-events-none" />
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* ======================================================== */}
      {/* 3. LIVE AUDIO LOUNGES SIMULATION                         */}
      {/* ======================================================== */}
      <section className="py-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div className="flex flex-col md:flex-row md:items-end justify-between mb-10 gap-4">
          <div>
            <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20 mb-3">
              <Radio className="w-3.5 h-3.5" /> Real-Time Voice Lounges
            </div>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
              Live On Hemi Ton Right Now
            </h2>
            <p className="text-slate-400 text-sm mt-1">
              Join active 12-seat acoustic stages broadcasting across Dubai, London, Riyadh, and Singapore.
            </p>
          </div>

          {/* Category Filter Pills */}
          <div className="flex flex-wrap gap-2">
            {[
              { id: 'all', label: 'All Lounges' },
              { id: 'music', label: 'Music & Beats' },
              { id: 'talk', label: 'Tech & Economy' },
              { id: 'pk', label: 'Live PK Arena' }
            ].map((cat) => (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id)}
                className={`text-xs font-semibold px-3.5 py-1.5 rounded-full transition-all ${
                  selectedCategory === cat.id
                    ? 'bg-[#D4AF37] text-black shadow-md'
                    : 'bg-white/[0.04] text-slate-300 hover:text-white border border-white/5'
                }`}
              >
                {cat.label}
              </button>
            ))}
          </div>
        </div>

        {/* Live Rooms Cards Grid */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {filteredRooms.map((room) => {
            const isPlaying = playingRoomId === room.id;
            return (
              <div
                key={room.id}
                className="bg-[#0A0F1A] border border-white/10 hover:border-[#D4AF37]/40 rounded-2xl p-5 transition-all group hover:-translate-y-1.5 flex flex-col justify-between shadow-lg relative overflow-hidden"
              >
                {/* Hot pill */}
                {room.hot && (
                  <div className="absolute top-3 right-3 bg-red-500/20 border border-red-500/40 text-red-400 text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center gap-1">
                    <Flame className="w-3 h-3 fill-current" /> HOT
                  </div>
                )}

                <div>
                  {/* Host Info */}
                  <div className="flex items-center gap-3 mb-4">
                    <img
                      src={room.avatar}
                      alt={room.host}
                      className="w-12 h-12 rounded-full object-cover border-2 border-[#D4AF37]/40"
                    />
                    <div>
                      <div className="text-sm font-bold text-white flex items-center gap-1">
                        {room.host}
                        <ShieldCheck className="w-3.5 h-3.5 text-[#D4AF37]" />
                      </div>
                      <div className="text-[11px] text-[#D4AF37]">{room.tag}</div>
                    </div>
                  </div>

                  {/* Room Title */}
                  <h3 className="text-base font-bold text-white group-hover:text-[#D4AF37] transition-colors leading-snug mb-3">
                    {room.title}
                  </h3>

                  {/* Animated Soundwave Visualizer if Playing */}
                  <div className="h-8 rounded-lg bg-black/40 border border-white/5 flex items-center justify-center gap-1 px-3 mb-4">
                    {isPlaying ? (
                      <>
                        <div className="w-1 bg-[#D4AF37] rounded h-3 animate-pulse [animation-duration:0.6s]" />
                        <div className="w-1 bg-[#D4AF37] rounded h-6 animate-pulse [animation-duration:0.4s]" />
                        <div className="w-1 bg-[#D4AF37] rounded h-4 animate-pulse [animation-duration:0.8s]" />
                        <div className="w-1 bg-[#D4AF37] rounded h-7 animate-pulse [animation-duration:0.5s]" />
                        <div className="w-1 bg-[#D4AF37] rounded h-3 animate-pulse [animation-duration:0.7s]" />
                        <span className="text-[10px] font-mono text-[#D4AF37] ml-2 font-bold">STREAMING</span>
                      </>
                    ) : (
                      <span className="text-[10px] font-mono text-slate-500">12 Mics Active • Agora RTC</span>
                    )}
                  </div>
                </div>

                {/* Bottom Row: Listeners + Audio Toggle Button */}
                <div className="pt-3 border-t border-white/5 flex items-center justify-between">
                  <div className="text-xs text-slate-400 flex items-center gap-1">
                    <Users className="w-3.5 h-3.5 text-slate-500" />
                    <span className="font-semibold text-white">{room.listeners}</span> listening
                  </div>
                  
                  <button
                    onClick={() => toggleRoomAudio(room.id)}
                    className={`p-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 ${
                      isPlaying
                        ? 'bg-[#D4AF37] text-black shadow-[0_0_15px_rgba(212,175,55,0.4)]'
                        : 'bg-white/5 text-slate-300 hover:text-white hover:bg-white/10'
                    }`}
                  >
                    {isPlaying ? <Volume2 className="w-3.5 h-3.5" /> : <VolumeX className="w-3.5 h-3.5" />}
                    <span>{isPlaying ? 'Mute' : 'Listen'}</span>
                  </button>
                </div>

              </div>
            );
          })}
        </div>
      </section>

      {/* ======================================================== */}
      {/* 4. VISUAL SHOWCASE: 3D LIVE AUDIO STAGE                   */}
      {/* ======================================================== */}
      <section className="py-20 bg-gradient-to-b from-[#06090F] via-[#0B101D] to-[#06090F] border-y border-white/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
          <div className="grid lg:grid-cols-12 gap-10 items-center">
            
            {/* Visual Div (7 cols) */}
            <div className="lg:col-span-7">
              <div className="relative rounded-3xl overflow-hidden border border-[#D4AF37]/40 shadow-[0_20px_60px_rgba(0,0,0,0.8)] group">
                <img
                  src="/hemi-live-stage.jpg"
                  alt="Hemi Ton 12-Seat Live Audio Lounge Stage"
                  className="w-full h-auto object-cover transform group-hover:scale-[1.02] transition-transform duration-700"
                />
                <div className="absolute bottom-4 left-4 right-4 bg-black/80 backdrop-blur-md border border-white/10 p-3 sm:p-4 rounded-2xl flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-3 h-3 rounded-full bg-emerald-400 animate-ping" />
                    <div className="text-xs text-white font-bold">12 VIP Holographic Pods • Spatial Center Equalizer</div>
                  </div>
                  <Link
                    to="/features#spatial-audio"
                    className="text-xs font-bold text-[#D4AF37] hover:underline"
                  >
                    Audio Specs &rarr;
                  </Link>
                </div>
              </div>
            </div>

            {/* Narrative Div (5 cols) */}
            <div className="lg:col-span-5 space-y-5 text-left">
              <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20">
                <Radio className="w-3.5 h-3.5" /> High-Fidelity Infrastructure
              </div>
              <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight leading-tight">
                Architected for Royal Acoustics & High Engagement
              </h2>
              <p className="text-slate-400 text-sm leading-relaxed">
                Legacy live apps suffer from muddy mono compression, delayed voice echoes, and chaotic audio overlap. Hemi Ton re-engineers live conversation with independent directional acoustic panning.
              </p>

              <div className="space-y-3 pt-1">
                {[
                  { title: 'Spatial Positioning Panning', desc: 'Hear each speaker distinctly based on their physical seat position on the 12-mic stage.' },
                  { title: 'Instant Host Floor Controls', desc: 'Pass the digital gold microphone, initiate timed debates, or mute background noise instantly.' },
                  { title: 'In-Room Minigames & Coin Pots', desc: 'Play Ludo, Roulette, and Seven Puzzle with listeners while broadcasting voice.' }
                ].map((item, idx) => (
                  <div key={idx} className="p-3 rounded-xl bg-white/[0.02] border border-white/5">
                    <div className="text-xs font-bold text-white">{item.title}</div>
                    <div className="text-[11px] text-slate-400 mt-0.5">{item.desc}</div>
                  </div>
                ))}
              </div>

              <div className="pt-2">
                <Link
                  to="/features"
                  className="inline-flex items-center gap-2 text-sm font-bold text-[#D4AF37] hover:text-[#FFF0A0] transition-colors"
                >
                  <span>Explore all architectural features</span>
                  <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* ======================================================== */}
      {/* 5. VISUAL SHOWCASE: CELESTIAL GIFTS & ECONOMY            */}
      {/* ======================================================== */}
      <section className="py-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div className="grid lg:grid-cols-12 gap-10 items-center">
          
          {/* Narrative Div (5 cols on left) */}
          <div className="lg:col-span-5 space-y-5 text-left order-2 lg:order-1">
            <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20">
              <Gift className="w-3.5 h-3.5" /> High-Status Virtual Economy
            </div>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight leading-tight">
              3D Celestial Gifts That Command Global Attention
            </h2>
            <p className="text-slate-400 text-sm leading-relaxed">
              When a VIP patron sends the <span className="text-[#D4AF37] font-semibold">Golden Dragon Ascent</span> or an <span className="text-white font-semibold">Imperial Supercar</span>, the entire platform takes notice. Full-screen 3D particle animations cascade across the room with global alert banners.
            </p>

            <div className="grid grid-cols-2 gap-3 pt-1">
              <div className="p-3.5 rounded-xl bg-white/[0.02] border border-white/5">
                <div className="text-xl font-extrabold text-[#D4AF37]">70%</div>
                <div className="text-xs font-semibold text-white mt-0.5">Host Settlement</div>
                <div className="text-[10px] text-slate-500">Fastest payout in the market</div>
              </div>
              <div className="p-3.5 rounded-xl bg-white/[0.02] border border-white/5">
                <div className="text-xl font-extrabold text-[#D4AF37]">50+</div>
                <div className="text-xs font-semibold text-white mt-0.5">3D Virtual Gifts</div>
                <div className="text-[10px] text-slate-500">Dragons, cars, and crowns</div>
              </div>
            </div>

            <div className="pt-2">
              <button
                onClick={() => setDownloadModalOpen(true)}
                className="bg-gradient-to-r from-[#D4AF37] to-[#E5C158] text-black font-bold px-6 py-3 rounded-xl text-xs uppercase tracking-wider shadow-lg flex items-center gap-2"
              >
                <Smartphone className="w-4 h-4" />
                <span>Experience On Mobile</span>
              </button>
            </div>
          </div>

          {/* Visual Div (7 cols on right) */}
          <div className="lg:col-span-7 order-1 lg:order-2">
            <div className="relative rounded-3xl overflow-hidden border border-[#D4AF37]/40 shadow-[0_20px_60px_rgba(212,175,55,0.2)] group">
              <img
                src="/hemi-gifts-economy.jpg"
                alt="Hemi Ton 3D Celestial Gifts"
                className="w-full h-auto object-cover transform group-hover:scale-[1.02] transition-transform duration-700"
              />
              <div className="absolute top-4 left-4 bg-black/80 backdrop-blur-md border border-[#D4AF37]/40 px-3.5 py-1.5 rounded-xl flex items-center gap-2">
                <Crown className="w-4 h-4 text-[#D4AF37]" />
                <span className="text-xs font-bold text-white">VIP Gift Showcase • Golden Dragon</span>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* ======================================================== */}
      {/* 6. COMPARISON MATRIX: HEMI TON VS LEGACY PLATFORMS       */}
      {/* ======================================================== */}
      <section className="py-20 bg-gradient-to-b from-[#06090F] via-[#090E1A] to-[#06090F] border-t border-white/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full text-center">
          <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-[#D4AF37] bg-[#D4AF37]/10 px-3 py-1 rounded-md border border-[#D4AF37]/20 mb-3">
            <Layers className="w-3.5 h-3.5" /> Market Leadership
          </div>
          <h2 className="text-3xl sm:text-5xl font-extrabold text-white tracking-tight mb-4">
            Why Creators & VIPs Choose Hemi Ton
          </h2>
          <p className="text-slate-400 text-sm max-w-2xl mx-auto mb-12">
            See how Hemi Ton outperforms standard live streaming apps in technology, creator monetization, and prestige.
          </p>

          <div className="overflow-x-auto">
            <table className="w-full max-w-4xl mx-auto text-left border-collapse">
              <thead>
                <tr className="border-b border-white/10 text-xs uppercase tracking-wider text-slate-400">
                  <th className="py-4 px-6">Platform Capability</th>
                  <th className="py-4 px-6 text-[#D4AF37] font-bold text-sm bg-[#D4AF37]/10 rounded-t-xl">
                    ✦ HEMI TON
                  </th>
                  <th className="py-4 px-6 text-slate-500">Legacy Live Apps</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5 text-sm">
                {[
                  { feature: 'Audio Engine & Latency', hemi: 'Agora RTC Spatial 3D (<60ms)', others: 'Standard Mono (>250ms delay)' },
                  { feature: 'Audio Seats Capacity', hemi: '12 Dynamic Mics with Spatial Panning', others: '4 to 6 basic mics' },
                  { feature: 'In-Room Minigames', hemi: '10-Game Arcade (Fishing, Rocket, Roulette)', others: 'None or external webview' },
                  { feature: 'Host Revenue Share', hemi: '70% Instant Payout', others: '30% - 50% with monthly delays' },
                  { feature: 'VIP Aristocracy Perks', hemi: 'Full-screen 3D Takeovers & Direct Concierge', others: 'Static text badges' },
                  { feature: 'Security & Anti-Fraud', hemi: 'Biometric MAC Fingerprinting + AI Audio Shield', others: 'Basic automated text filters' },
                ].map((row, i) => (
                  <tr key={i} className="hover:bg-white/[0.02] transition-colors">
                    <td className="py-4 px-6 font-medium text-white">{row.feature}</td>
                    <td className="py-4 px-6 text-[#D4AF37] font-bold bg-[#D4AF37]/5 flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-[#D4AF37] shrink-0" />
                      {row.hemi}
                    </td>
                    <td className="py-4 px-6 text-slate-500">{row.others}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* ======================================================== */}
      {/* 7. BOTTOM APP STORE & DIRECT APK DOWNLOAD BANNER        */}
      {/* ======================================================== */}
      <section className="py-24 max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 w-full text-center">
        <div className="relative rounded-3xl bg-gradient-to-r from-[#1A1F2C] via-[#0D1220] to-[#1A1F2C] border border-[#D4AF37]/40 p-10 sm:p-16 shadow-[0_25px_70px_rgba(212,175,55,0.2)] overflow-hidden">
          
          <div className="absolute top-0 right-1/4 w-96 h-96 bg-[#D4AF37]/15 blur-[120px] pointer-events-none" />

          <div className="relative z-10 max-w-3xl mx-auto space-y-6">
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-[#D4AF37]/15 border border-[#D4AF37]/30 text-[#D4AF37] text-xs font-bold uppercase tracking-wider">
              <Smartphone className="w-4 h-4" /> Instant Mobile Access
            </div>

            <h2 className="text-3xl sm:text-5xl font-black text-white tracking-tight">
              Ready to Step Into The Royal Stage?
            </h2>

            <p className="text-base sm:text-lg text-slate-300 max-w-xl mx-auto leading-relaxed">
              Download Hemi Ton today. Join the world’s most elite audio community and unlock your host potential.
            </p>

            <div className="pt-2 flex flex-wrap justify-center gap-4">
              <button
                onClick={() => setDownloadModalOpen(true)}
                className="bg-gradient-to-r from-[#D4AF37] via-[#FFF0A0] to-[#E5C158] text-black font-extrabold px-8 py-4 rounded-xl text-base transition-all shadow-[0_0_25px_rgba(212,175,55,0.4)] hover:shadow-[0_0_40px_rgba(212,175,55,0.7)] flex items-center gap-2.5"
              >
                <Apple className="w-5 h-5" />
                <span>App Store & Google Play</span>
              </button>

              <Link
                to="/contact?type=host"
                className="bg-white/10 hover:bg-white/15 border border-white/20 text-white font-bold px-8 py-4 rounded-xl text-base transition-colors flex items-center gap-2"
              >
                <span>Apply as Host</span>
                <ArrowRight className="w-4 h-4 text-[#D4AF37]" />
              </Link>
            </div>

            <div className="pt-4 flex items-center justify-center gap-4 text-xs text-slate-400">
              <span className="flex items-center gap-1.5">
                <ShieldCheck className="w-4 h-4 text-emerald-400" /> 100% Free & Secure
              </span>
              <span>•</span>
              <span>Requires iOS 15.0+ or Android 9.0+</span>
            </div>
          </div>
        </div>
      </section>

      {/* Download Modal Component */}
      <DownloadModal isOpen={downloadModalOpen} onClose={() => setDownloadModalOpen(false)} />

    </div>
  );
}

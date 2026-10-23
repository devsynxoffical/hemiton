// ============================================================
// Hemi Ton Public — Modern Light Theme Marketing Landing Page
// ============================================================

import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  Radio,
  Mic,
  MicOff,
  Headphones,
  Sparkles,
  Users,
  Coins,
  Crown,
  ShieldCheck,
  Zap,
  ArrowRight,
  Download,
  Gift,
  Flame,
  Volume2,
  CheckCircle2,
  ChevronDown,
  ChevronUp,
  Apple,
  Play,
  Heart,
  MessageCircle,
  Star,
  Globe2,
} from 'lucide-react';

export function LandingPage() {
  useEffect(() => {
    document.title = 'Hemi Ton — Next-Gen Live Audio Spaces, Social Party & Community';
  }, []);

  const [activeFaq, setActiveFaq] = useState(null);

  const features = [
    {
      icon: Headphones,
      title: 'Ultra Low-Latency Spatial Audio',
      desc: 'Powered by Agora RTC sub-second global streaming with crystal-clear high fidelity acoustics and 3D spatial separation.',
      badge: '<120ms Latency',
    },
    {
      icon: Users,
      title: 'Multi-Speaker Interactive Stages',
      desc: 'Dynamic 8-seat and 12-seat voice party stages with smooth mic handoffs, co-hosting permissions, and soundboard effects.',
      badge: 'Up to 12 Seats',
    },
    {
      icon: Gift,
      title: '3D Virtual Gifting & Leaderboards',
      desc: 'Spectacular animated gifts that illuminate the room, boost broadcaster standings, and fuel an active creator economy.',
      badge: 'Live FX Animations',
    },
    {
      icon: Flame,
      title: 'Live PK Battles & Mini-Games',
      desc: 'Real-time head-to-head audio battles where host fanbases compete to send gifts and claim the room championship trophy.',
      badge: 'Competitive PK',
    },
    {
      icon: Crown,
      title: 'Agency Incubation & Creator Hub',
      desc: 'Dedicated enterprise tooling for talent agencies to contract hosts, monitor broadcast minutes, and split revenue automatically.',
      badge: 'Agency Ready',
    },
    {
      icon: ShieldCheck,
      title: 'Safe & AI-Moderated Community',
      desc: 'Automated acoustic noise filtering, toxic speech detection, and 24/7 human moderation to keep rooms safe and welcoming.',
      badge: '24/7 Protection',
    },
  ];

  const faqs = [
    {
      q: 'What makes Hemi Ton different from traditional live streaming?',
      a: 'Hemi Ton is built voice-first. Instead of one-way video broadcasts that drain battery and demand full camera attention, Hemi Ton audio rooms foster natural multi-way conversations, live soundboard mixing, and social group bonding while using 80% less mobile bandwidth.',
    },
    {
      q: 'How can I become a Verified Hemi Ton Broadcaster?',
      a: 'Any creator can apply directly through the app or by submitting our Talent Application. Verified Hosts receive daily direct-to-bank settlement payouts, custom VIP badge insignias, exclusive room themes, and dedicated platform promotion.',
    },
    {
      q: 'How do Talent Agencies collaborate on Hemi Ton?',
      a: 'We offer an enterprise Agency Management suite where agency owners can onboard host rosters, track live hours and coin revenue in real time, and receive guaranteed monthly commission settlements directly through verified banking rails.',
    },
    {
      q: 'What platforms is Hemi Ton available on?',
      a: 'Hemi Ton is available as a native mobile application on iOS (App Store / TestFlight) and Android (Google Play / Direct APK), as well as an instant Web App for modern desktop and tablet browsers.',
    },
    {
      q: 'How does the virtual coin economy work?',
      a: 'Users can recharge coins safely using secure payment gateways (Apple In-App Purchase, Google Play Billing, Stripe, and localized payment rails). Coins are used to send animated gifts to favorite broadcasters, who can exchange them for real currency withdrawals.',
    },
  ];

  return (
    <div className="flex flex-col w-full overflow-hidden">
      {/* ============================================================ */}
      {/* 1. HERO SECTION WITH ANIMATED SOUNDWAVE BACKGROUND           */}
      {/* ============================================================ */}
      <section className="relative overflow-hidden pt-16 pb-20 md:pt-24 md:pb-28 bg-[#F5F8FC]">
        {/* Animated Hero Background Image with Subtle Ken Burns Breathing Motion */}
        <div className="absolute inset-0 z-0 overflow-hidden pointer-events-none">
          <img
            src="/hero-bg.jpg"
            alt="Luminous 3D Acoustic Waves"
            className="w-full h-full object-cover object-center opacity-85 scale-105 animate-hero-bg"
          />
          {/* Subtle gradient wash to ensure pristine contrast & seamless section transition */}
          <div className="absolute inset-0 bg-gradient-to-b from-white/60 via-white/30 to-[#F5F8FC]" />
        </div>

        {/* Dynamic Floating Glow Orbs & Acoustic Ripple Animation */}
        <div className="absolute -top-20 left-1/4 w-[500px] h-[500px] bg-gradient-to-tr from-[#5979AC]/20 to-[#3B82F6]/15 blur-[120px] rounded-full pointer-events-none z-0 animate-float-1" />
        <div className="absolute top-1/3 -right-20 w-[450px] h-[450px] bg-gradient-to-bl from-[#7894BE]/25 to-[#DCE6F5]/40 blur-[110px] rounded-full pointer-events-none z-0 animate-float-2" />
        <div className="absolute -bottom-10 left-1/2 -translate-x-1/2 w-[700px] h-[300px] bg-[#5979AC]/10 blur-[100px] rounded-full pointer-events-none z-0 animate-wave-pulse" />

        <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col items-center text-center max-w-3xl mx-auto">
            {/* Top Pill Badge */}
            <div className="inline-flex items-center gap-2 rounded-full border border-[#C8D7EC] bg-white/90 backdrop-blur-xs px-3.5 py-1.5 shadow-2xs mb-6">
              <span className="flex h-2 w-2 rounded-full bg-[#2E7D52] animate-pulse" />
              <span className="text-xs font-semibold text-[#263957]">
                Hemi Ton 2.0 Live Audio Spaces
              </span>
              <span className="rounded bg-[#5979AC] px-1.5 py-0.5 text-[9px] font-bold uppercase tracking-wider text-white">
                Global Release
              </span>
            </div>

            {/* Main Headline */}
            <h1 className="font-heading text-4xl sm:text-5xl lg:text-6xl font-extrabold text-[#263957] tracking-tight leading-[1.15] mb-6">
              Where Voice Meets Vibe.{' '}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#5979AC] via-[#3B82F6] to-[#496A9C]">
                Connect, Broadcast & Belong.
              </span>
            </h1>

            {/* Sub-Headline */}
            <p className="text-base sm:text-lg text-[#65738A] leading-relaxed mb-8 max-w-2xl">
              Step into ultra-low latency spatial audio rooms, multi-seat voice parties, interactive gifting battles, and vibrant global communities.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row items-center gap-3.5 w-full sm:w-auto mb-12">
              <Link
                to="/features"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl bg-[#5979AC] px-7 py-3.5 text-sm font-bold text-white shadow-xs hover:bg-[#496A9C] hover:shadow-md transition-all transform hover:-translate-y-0.5 cursor-pointer"
              >
                <Sparkles className="h-4 w-4" />
                <span>Explore All Features</span>
              </Link>

              <a
                href="#download"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl border border-[#D8E0EC] bg-white px-7 py-3.5 text-sm font-semibold text-[#263957] hover:bg-[#F5F7FB] hover:border-[#91A9CE] shadow-2xs transition-all cursor-pointer"
              >
                <Download className="h-4 w-4 text-[#5979AC]" />
                <span>Download App</span>
              </a>

              <Link
                to="/contact"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl bg-[#EEF4FB] px-5 py-3.5 text-sm font-semibold text-[#5979AC] hover:bg-[#DCE6F5] transition-colors"
              >
                <Crown className="h-4 w-4" />
                <span>Become a Host</span>
              </Link>
            </div>

            {/* Live Metrics Row */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 w-full max-w-3xl pt-8 border-t border-[#D8E0EC]/70">
              <div className="flex flex-col items-center p-3.5 rounded-2xl bg-white/80 backdrop-blur-xs border border-[#D8E0EC]/60 shadow-2xs">
                <span className="font-heading text-xl sm:text-2xl font-extrabold text-[#263957]">
                  14,800+
                </span>
                <span className="text-[11px] font-mono text-[#65738A]">Active Community</span>
              </div>
              <div className="flex flex-col items-center p-3.5 rounded-2xl bg-white/80 backdrop-blur-xs border border-[#D8E0EC]/60 shadow-2xs">
                <span className="font-heading text-xl sm:text-2xl font-extrabold text-[#263957]">
                  64+
                </span>
                <span className="text-[11px] font-mono text-[#65738A]">Live Audio Spaces</span>
              </div>
              <div className="flex flex-col items-center p-3.5 rounded-2xl bg-white/80 backdrop-blur-xs border border-[#D8E0EC]/60 shadow-2xs">
                <span className="font-heading text-xl sm:text-2xl font-extrabold text-[#2E7D52]">
                  &lt;120 ms
                </span>
                <span className="text-[11px] font-mono text-[#65738A]">Agora RTC Latency</span>
              </div>
              <div className="flex flex-col items-center p-3.5 rounded-2xl bg-white/80 backdrop-blur-xs border border-[#D8E0EC]/60 shadow-2xs">
                <span className="font-heading text-xl sm:text-2xl font-extrabold text-[#5979AC]">
                  99.98%
                </span>
                <span className="text-[11px] font-mono text-[#65738A]">Global Node Uptime</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================ */}
      {/* 2. PLATFORM FEATURES GRID                                    */}
      {/* ============================================================ */}
      <section className="py-20 md:py-28 bg-white border-y border-[#D8E0EC]" id="features">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="text-xs font-mono font-bold uppercase tracking-wider text-[#5979AC] bg-[#EEF4FB] border border-[#DCE6F5] px-3 py-1 rounded-full">
              Engineered For Live Entertainment
            </span>
            <h2 className="font-heading text-3xl sm:text-4xl font-extrabold text-[#263957] tracking-tight mt-4 mb-4">
              Designed from the Ground Up for Voice, Community & Creators
            </h2>
            <p className="text-base text-[#65738A] leading-relaxed">
              Experience modern audio social spaces without lag, battery drain, or awkward video fatigue. Hemi Ton gives you professional audio broadcast quality in your pocket.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
            {features.map((feat, idx) => {
              const Icon = feat.icon;
              return (
                <div
                  key={idx}
                  className="flex flex-col justify-between rounded-2xl border border-[#D8E0EC] bg-[#F8FAFC] p-7 transition-all duration-200 hover:bg-white hover:border-[#91A9CE] hover:shadow-lg hover:-translate-y-1 group"
                >
                  <div>
                    <div className="flex items-center justify-between mb-5">
                      <div className="h-12 w-12 rounded-xl bg-[#EEF4FB] border border-[#DCE6F5] flex items-center justify-center text-[#5979AC] group-hover:bg-[#5979AC] group-hover:text-white transition-colors shadow-2xs">
                        <Icon className="h-6 w-6" />
                      </div>
                      <span className="rounded-full bg-white border border-[#D8E0EC] px-2.5 py-0.5 text-[10px] font-mono font-semibold text-[#263957] shadow-2xs">
                        {feat.badge}
                      </span>
                    </div>

                    <h3 className="font-heading text-lg font-bold text-[#263957] mb-2.5">
                      {feat.title}
                    </h3>
                    <p className="text-xs sm:text-sm text-[#65738A] leading-relaxed">
                      {feat.desc}
                    </p>
                  </div>

                  <div className="mt-6 pt-4 border-t border-[#D8E0EC]/60 flex items-center gap-1.5 text-xs font-semibold text-[#5979AC] group-hover:text-[#496A9C]">
                    <span>Learn technical specs</span>
                    <ArrowRight className="h-3.5 w-3.5 group-hover:translate-x-1 transition-transform" />
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ============================================================ */}
      {/* 3. TALENT, CREATORS & AGENCY INCUBATION HUB                 */}
      {/* ============================================================ */}
      <section className="py-20 md:py-28 bg-[#EEF4FB] relative overflow-hidden" id="talent">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            {/* Left Content */}
            <div>
              <span className="text-xs font-mono font-bold uppercase tracking-wider text-[#5979AC] bg-white border border-[#D8E0EC] px-3 py-1 rounded-full shadow-2xs">
                Creator & Agency Economy
              </span>
              <h2 className="font-heading text-3xl sm:text-4xl font-extrabold text-[#263957] tracking-tight mt-4 mb-5">
                Turn Your Voice into a Thriving Global Career
              </h2>
              <p className="text-sm sm:text-base text-[#65738A] leading-relaxed mb-6">
                Whether you're a solo vocalist, podcast host, gaming caster, or run a premier talent agency, Hemi Ton provides direct revenue models, VIP status badges, and daily automated settlement payouts.
              </p>

              <div className="space-y-4 mb-8">
                <div className="flex items-start gap-3">
                  <div className="h-6 w-6 rounded-full bg-[#E7F4ED] border border-[#C6E7D5] flex items-center justify-center text-[#2E7D52] shrink-0 mt-0.5">
                    <CheckCircle2 className="h-4 w-4" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-[#263957]">Up to 70% Creator Revenue Share</h4>
                    <p className="text-xs text-[#65738A]">Industry-leading gift payout rates with instant coin-to-cash bank settlements.</p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <div className="h-6 w-6 rounded-full bg-[#E7F4ED] border border-[#C6E7D5] flex items-center justify-center text-[#2E7D52] shrink-0 mt-0.5">
                    <CheckCircle2 className="h-4 w-4" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-[#263957]">Enterprise Agency Control Center</h4>
                    <p className="text-xs text-[#65738A]">Bulk host contracts, sub-account rosters, transparent audit logs, and automated agency commission splits.</p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <div className="h-6 w-6 rounded-full bg-[#E7F4ED] border border-[#C6E7D5] flex items-center justify-center text-[#2E7D52] shrink-0 mt-0.5">
                    <CheckCircle2 className="h-4 w-4" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-[#263957]">Dedicated Talent Manager & 24/7 Priority Support</h4>
                    <p className="text-xs text-[#65738A]">Direct access to Hemi Ton operations staff to assist with room banners, verified badges, and featured discovery placement.</p>
                  </div>
                </div>
              </div>

              <div className="flex flex-col sm:flex-row items-center gap-3">
                <Link
                  to="/contact"
                  className="w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl bg-[#5979AC] px-6 py-3.5 text-xs font-bold text-white shadow-xs hover:bg-[#496A9C] transition-all cursor-pointer"
                >
                  <Crown className="h-4 w-4" />
                  <span>Apply for Verified Host</span>
                </Link>

                <Link
                  to="/contact"
                  className="w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl border border-[#D8E0EC] bg-white px-6 py-3.5 text-xs font-semibold text-[#263957] hover:bg-[#F5F7FB] transition-all shadow-2xs"
                >
                  <span>Agency Partnership Portal</span>
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>
            </div>

            {/* Right Card Presentation */}
            <div className="rounded-3xl border border-[#D8E0EC] bg-white p-6 sm:p-8 shadow-xl">
              <div className="flex items-center justify-between pb-4 border-b border-[#D8E0EC]">
                <div className="flex items-center gap-2.5">
                  <Crown className="h-5 w-5 text-[#94601A]" />
                  <span className="font-heading text-sm font-bold text-[#263957]">
                    Verified Host Profile Card
                  </span>
                </div>
                <span className="rounded-full bg-[#E7F4ED] border border-[#C6E7D5] px-2.5 py-0.5 text-[10px] font-mono font-bold text-[#2E7D52]">
                  PRO HOST STATUS
                </span>
              </div>

              <div className="py-6 flex items-center gap-4">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200"
                  alt="Aria Thorne"
                  className="h-20 w-20 rounded-2xl object-cover border border-[#D8E0EC] shadow-xs"
                />
                <div>
                  <div className="flex items-center gap-1.5">
                    <h3 className="font-heading text-lg font-bold text-[#263957]">Aria Thorne</h3>
                    <Crown className="h-4 w-4 text-[#94601A]" />
                  </div>
                  <p className="text-xs text-[#5979AC] font-mono font-semibold">@ariathorne • Galaxy Talent Agency</p>
                  <div className="flex items-center gap-2 mt-2">
                    <span className="rounded bg-[#F5F7FB] border border-[#D8E0EC] px-2 py-0.5 text-[10px] font-mono text-[#263957]">
                      124 Broadcast Hrs
                    </span>
                    <span className="rounded bg-[#FDF4E7] border border-[#F7E1C0] px-2 py-0.5 text-[10px] font-mono text-[#94601A] font-bold">
                      Rank #3 Monthly
                    </span>
                  </div>
                </div>
              </div>

              {/* Earnings & Settlement Simulation */}
              <div className="grid grid-cols-2 gap-3 pt-4 border-t border-[#D8E0EC]">
                <div className="p-3 rounded-xl bg-[#F8FAFC] border border-[#D8E0EC]">
                  <span className="text-[10px] font-mono uppercase text-[#8792A4]">Current Month Volume</span>
                  <div className="font-heading text-lg font-extrabold text-[#263957] mt-0.5">
                    1.42M Coins
                  </div>
                  <span className="text-[10px] text-[#2E7D52] font-semibold">+18.4% vs last mo</span>
                </div>
                <div className="p-3 rounded-xl bg-[#F8FAFC] border border-[#D8E0EC]">
                  <span className="text-[10px] font-mono uppercase text-[#8792A4]">Next Payout Settlement</span>
                  <div className="font-heading text-lg font-extrabold text-[#2E7D52] mt-0.5">
                    $7,100.00 USD
                  </div>
                  <span className="text-[10px] text-[#65738A] font-mono">Bank Direct Wire</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================ */}
      {/* 4. MOBILE APP DOWNLOAD CTA SECTION                           */}
      {/* ============================================================ */}
      <section className="py-10 md:py-14 bg-white border-b border-[#D8E0EC]" id="download">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="rounded-2xl sm:rounded-3xl bg-gradient-to-br from-[#263957] to-[#1B2A42] text-white p-6 sm:p-8 lg:p-10 relative overflow-hidden shadow-xl">
            {/* Background Ambient Radial Glow */}
            <div className="absolute right-0 top-0 w-64 h-64 bg-[#5979AC]/20 blur-[80px] rounded-full pointer-events-none" />

            <div className="grid grid-cols-1 md:grid-cols-12 gap-6 lg:gap-8 items-center relative z-10">
              <div className="md:col-span-7">
                <span className="inline-flex items-center gap-1.5 rounded-full border border-white/20 bg-white/10 px-2.5 py-0.5 text-[11px] font-mono font-semibold text-white mb-3">
                  <Sparkles className="h-3 w-3 text-[#E5C158]" /> Available Worldwide
                </span>

                <h2 className="font-heading text-2xl sm:text-3xl font-extrabold text-white tracking-tight mb-3 leading-snug">
                  Download Hemi Ton and Jump into the Conversation
                </h2>

                <p className="text-xs sm:text-sm text-[#DCE6F5] leading-relaxed mb-6 max-w-lg">
                  Get the official Hemi Ton mobile app on iOS and Android. Experience HD spatial audio, meet friends around the world, send interactive gifts, and host your own live audio stage.
                </p>

                {/* Download Store Badges */}
                <div className="flex flex-wrap items-center gap-3">
                  <button
                    onClick={() => alert('Hemi Ton iOS TestFlight/App Store build will open.')}
                    className="flex items-center gap-2.5 rounded-xl bg-white px-4 py-2 text-xs font-bold text-[#263957] hover:bg-[#F5F7FB] transition-all shadow-md cursor-pointer"
                  >
                    <Apple className="h-5 w-5 text-black shrink-0" />
                    <div className="text-left">
                      <span className="block text-[8px] font-mono text-[#65738A] uppercase leading-none">Download on the</span>
                      <span className="text-xs font-extrabold leading-tight">Apple App Store</span>
                    </div>
                  </button>

                  <button
                    onClick={() => alert('Hemi Ton Android APK/Google Play installer downloading.')}
                    className="flex items-center gap-2.5 rounded-xl bg-[#5979AC] border border-white/20 px-4 py-2 text-xs font-bold text-white hover:bg-[#496A9C] transition-all shadow-md cursor-pointer"
                  >
                    <Play className="h-5 w-5 fill-white shrink-0" />
                    <div className="text-left">
                      <span className="block text-[8px] font-mono text-white/80 uppercase leading-none">Get it on</span>
                      <span className="text-xs font-extrabold leading-tight">Google Play & APK</span>
                    </div>
                  </button>
                </div>

                <div className="flex flex-wrap items-center gap-x-4 gap-y-1 mt-6 pt-4 border-t border-white/10 text-[11px] text-[#C8D7EC]">
                  <span>• Instant Web App support</span>
                  <span>• No ads or tracking</span>
                  <span>• 100% Free Voice Rooms</span>
                </div>
              </div>

              {/* Compact Leaning iPhone App Store / Play Store Mockup */}
              <div className="md:col-span-5 flex justify-center items-center relative">
                {/* Soft ambient backdrop glow */}
                <div className="absolute inset-0 bg-[#5979AC]/20 blur-2xl rounded-full scale-90 pointer-events-none" />

                <div className="relative z-10 max-w-[200px] sm:max-w-[240px] lg:max-w-[260px] w-full transition-transform duration-300 hover:scale-102">
                  <div className="overflow-hidden rounded-2xl border border-white/20 shadow-xl bg-black/40">
                    <img
                      src="/iphone-mockup.jpg"
                      alt="Hemi Ton on Apple App Store & Google Play"
                      className="w-full max-h-[330px] object-cover object-top rounded-2xl shadow-xl"
                    />
                  </div>
                  <div className="mt-2 text-center">
                    <span className="text-[10px] font-mono text-[#C8D7EC] tracking-wider uppercase">
                      Official Hemi Ton App Store & Play Store Edition
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================ */}
      {/* 5. FREQUENTLY ASKED QUESTIONS (ACCORDION)                    */}
      {/* ============================================================ */}
      <section className="py-20 md:py-28 bg-[#F8FAFC]">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <span className="text-xs font-mono font-bold uppercase tracking-wider text-[#5979AC] bg-[#EEF4FB] border border-[#DCE6F5] px-3 py-1 rounded-full">
              Got Questions?
            </span>
            <h2 className="font-heading text-3xl font-extrabold text-[#263957] tracking-tight mt-3 mb-3">
              Frequently Asked Questions
            </h2>
            <p className="text-sm text-[#65738A]">
              Everything you need to know about broadcasting, agency verification, and audio rooms on Hemi Ton.
            </p>
          </div>

          <div className="space-y-3">
            {faqs.map((faq, idx) => {
              const isOpen = activeFaq === idx;
              return (
                <div
                  key={idx}
                  className="rounded-2xl border border-[#D8E0EC] bg-white overflow-hidden transition-all shadow-2xs"
                >
                  <button
                    onClick={() => setActiveFaq(isOpen ? null : idx)}
                    className="flex w-full items-center justify-between p-5 text-left text-sm font-bold text-[#263957] hover:bg-[#F5F7FB] transition-colors cursor-pointer"
                  >
                    <span>{faq.q}</span>
                    {isOpen ? (
                      <ChevronUp className="h-4 w-4 text-[#5979AC] shrink-0 ml-3" />
                    ) : (
                      <ChevronDown className="h-4 w-4 text-[#8792A4] shrink-0 ml-3" />
                    )}
                  </button>
                  {isOpen && (
                    <div className="px-5 pb-5 pt-1 text-xs text-[#65738A] leading-relaxed border-t border-[#EEF2F8]">
                      {faq.a}
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          <div className="mt-12 text-center p-6 rounded-2xl bg-white border border-[#D8E0EC] shadow-2xs">
            <h4 className="text-sm font-bold text-[#263957] mb-1">
              Have a special agency requirement or talent inquiry?
            </h4>
            <p className="text-xs text-[#65738A] mb-4">
              Our operations team responds to host and agency onboarding questions within 24 hours.
            </p>
            <Link
              to="/contact"
              className="inline-flex items-center gap-1.5 rounded-xl bg-[#5979AC] px-5 py-2.5 text-xs font-bold text-white shadow-2xs hover:bg-[#496A9C] transition-colors"
            >
              <span>Contact Hemi Ton Team</span>
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}

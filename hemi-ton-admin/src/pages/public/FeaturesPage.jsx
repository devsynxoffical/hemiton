// ============================================================
// Hemi Ton Public — Dedicated Features Page (Cloud Blue + Slate)
// ============================================================

import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  Headphones,
  Users,
  Gift,
  Flame,
  Crown,
  ShieldCheck,
  Zap,
  Radio,
  Sparkles,
  ArrowRight,
  Layers,
  Volume2,
  Sliders,
  Award,
  BarChart3,
  CheckCircle2,
  Lock,
} from 'lucide-react';

export function FeaturesPage() {
  useEffect(() => {
    document.title = 'Features — Hemi Ton Live Audio Spaces & Technology';
    window.scrollTo(0, 0);
  }, []);

  const corePillars = [
    {
      category: 'Audio Architecture',
      title: 'Ultra Low-Latency Spatial Sound',
      desc: 'Powered by Agora RTC next-generation real-time voice streaming with 48kHz high-definition acoustics and sub-120ms round-trip latency across global nodes.',
      features: [
        'Global edge network spanning 200+ data centers',
        '3D spatial separation between co-speakers',
        'AI background acoustic noise suppression',
        'Echo cancellation & dynamic packet loss concealment',
      ],
      icon: Headphones,
      badge: '<120ms RTC Latency',
      accent: 'border-[#5979AC]',
    },
    {
      category: 'Interactive Stage',
      title: 'Multi-Speaker 8 & 12-Seat Rooms',
      desc: 'Intuitive multi-seat mic stages engineered for seamless conversation, co-hosting permissions, audience hand-raising queues, and private whisper channels.',
      features: [
        'Flexible 8-seat and 12-seat room layouts',
        'Host & moderator mic control controls',
        'Audience stage request & invite handoffs',
        'Custom themed room backgrounds & badges',
      ],
      icon: Users,
      badge: 'Up to 12 Seats',
      accent: 'border-[#3B82F6]',
    },
    {
      category: 'Live Entertainment',
      title: 'Head-to-Head PK Audio Battles',
      desc: 'Engage listener fanbases with competitive head-to-head host battles. Rooms split into red vs. blue teams where gift points determine the ultimate champion.',
      features: [
        'Configurable 3-minute, 5-minute, and 10-minute battle timers',
        'Live gift progress bar with sound FX',
        'Winner celebration fanfare & room trophies',
        'Audience MVP supporter podiums',
      ],
      icon: Flame,
      badge: 'PK Tournaments',
      accent: 'border-[#94601A]',
    },
    {
      category: 'Virtual Economy',
      title: '3D Animated Gifting & Combos',
      desc: 'Spectacular animated gifts that light up the stage with custom 3D particle animations, combo streaks, and platform-wide broadcast announcements.',
      features: [
        'Over 100+ bespoke handcrafted animated gifts',
        'Full-screen entrance effects for VIP supporters',
        'Automated coin recharge & multi-currency billing',
        'Transparent host wallet & real-time revenue stats',
      ],
      icon: Gift,
      badge: 'Live FX Animations',
      accent: 'border-[#2E7D52]',
    },
    {
      category: 'Broadcaster Tools',
      title: 'Live Soundboard & Voice Modulation',
      desc: 'In-room studio tools that empower creators to mix background beats, trigger real-time sound effects, and customize vocal EQ on the fly.',
      features: [
        'Integrated multi-track background music playback',
        'Studio reverb, warmth, and pitch presets',
        'One-tap cheering, applause, and fanfare sound effects',
        'Bluetooth and external audio interface support',
      ],
      icon: Sliders,
      badge: 'Studio Suite',
      accent: 'border-[#5979AC]',
    },
    {
      category: 'Governance & Safety',
      title: '24/7 AI-Assisted Moderation',
      desc: 'State-of-the-art acoustic monitoring and real-time text analysis keep audio spaces safe, civil, and compliant with international safety standards.',
      features: [
        'Real-time acoustic toxicity detection',
        'Automated room muting and safety locks',
        'Human moderator escalation console',
        'Granular user restriction & IP safety boundaries',
      ],
      icon: ShieldCheck,
      badge: 'Bank-Grade Security',
      accent: 'border-[#2E7D52]',
    },
  ];

  return (
    <div className="flex flex-col w-full overflow-hidden">
      {/* Hero Header */}
      <section className="relative pt-16 pb-20 md:pt-20 md:pb-28 bg-gradient-to-b from-[#F5F8FC] to-[#EEF4FB] border-b border-[#D8E0EC]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center max-w-3xl">
          <span className="text-xs font-mono font-bold uppercase tracking-wider text-[#5979AC] bg-white border border-[#D8E0EC] px-3.5 py-1.5 rounded-full shadow-2xs">
            Platform Capabilities & Architecture
          </span>
          <h1 className="font-heading text-4xl sm:text-5xl lg:text-6xl font-extrabold text-[#263957] tracking-tight mt-6 mb-6">
            Engineered for Crystal-Clear Voice & Immersive Interaction
          </h1>
          <p className="text-base sm:text-lg text-[#65738A] leading-relaxed">
            Discover the technology and features that power Hemi Ton: low-latency spatial audio, dynamic multi-speaker stages, interactive gifting, and enterprise agency tooling.
          </p>
        </div>
      </section>

      {/* Main Features Deep Dive Grid */}
      <section className="py-20 bg-white border-b border-[#D8E0EC]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {corePillars.map((pillar, idx) => {
              const Icon = pillar.icon;
              return (
                <div
                  key={idx}
                  className="flex flex-col justify-between rounded-3xl border border-[#D8E0EC] bg-[#F8FAFC] p-8 transition-all hover:bg-white hover:border-[#91A9CE] hover:shadow-xl hover:-translate-y-1 group"
                >
                  <div>
                    {/* Header with Icon and Badge */}
                    <div className="flex items-center justify-between mb-6">
                      <div className="h-12 w-12 rounded-2xl bg-[#EEF4FB] border border-[#DCE6F5] flex items-center justify-center text-[#5979AC] group-hover:bg-[#5979AC] group-hover:text-white transition-colors shadow-2xs">
                        <Icon className="h-6 w-6" />
                      </div>
                      <span className="rounded-full bg-white border border-[#D8E0EC] px-3 py-1 text-[10px] font-mono font-bold text-[#263957] shadow-2xs">
                        {pillar.badge}
                      </span>
                    </div>

                    <span className="text-[11px] font-mono font-bold uppercase tracking-wider text-[#5979AC]">
                      {pillar.category}
                    </span>
                    <h3 className="font-heading text-xl font-bold text-[#263957] mt-1 mb-3">
                      {pillar.title}
                    </h3>
                    <p className="text-xs sm:text-sm text-[#65738A] leading-relaxed mb-6">
                      {pillar.desc}
                    </p>

                    {/* Bullet Points */}
                    <ul className="space-y-2.5 pt-4 border-t border-[#D8E0EC]/70">
                      {pillar.features.map((item, fIdx) => (
                        <li key={fIdx} className="flex items-start gap-2.5 text-xs text-[#263957]">
                          <CheckCircle2 className="h-4 w-4 text-[#2E7D52] shrink-0 mt-0.5" />
                          <span>{item}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Technical Architecture Comparison Card */}
      <section className="py-20 bg-[#F5F8FC]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="rounded-3xl border border-[#D8E0EC] bg-white p-8 sm:p-12 shadow-lg">
            <div className="text-center max-w-2xl mx-auto mb-12">
              <span className="text-xs font-mono font-bold uppercase tracking-wider text-[#5979AC] bg-[#EEF4FB] border border-[#DCE6F5] px-3 py-1 rounded-full">
                Benchmark Comparison
              </span>
              <h2 className="font-heading text-3xl font-extrabold text-[#263957] mt-3 mb-2">
                Why Voice-First Social Outperforms Video Streams
              </h2>
              <p className="text-xs sm:text-sm text-[#65738A]">
                How Hemi Ton optimizes performance, network bandwidth, and audience engagement.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="p-6 rounded-2xl border border-[#D8E0EC] bg-[#F8FAFC]">
                <span className="text-xs font-mono font-bold text-[#5979AC] uppercase">Bandwidth Consumption</span>
                <div className="font-heading text-3xl font-extrabold text-[#263957] mt-2 mb-1">
                  85% Less
                </div>
                <p className="text-xs text-[#65738A] leading-relaxed">
                  Consumes only 32–64 kbps compared to 1,500+ kbps for HD video streams, enabling smooth audio on unstable mobile data.
                </p>
              </div>

              <div className="p-6 rounded-2xl border border-[#D8E0EC] bg-[#F8FAFC]">
                <span className="text-xs font-mono font-bold text-[#2E7D52] uppercase">Interactive Participation</span>
                <div className="font-heading text-3xl font-extrabold text-[#2E7D52] mt-2 mb-1">
                  4.8x Higher
                </div>
                <p className="text-xs text-[#65738A] leading-relaxed">
                  Removing video stage fright increases audience willingness to speak on stage, resulting in richer, longer broadcast sessions.
                </p>
              </div>

              <div className="p-6 rounded-2xl border border-[#D8E0EC] bg-[#F8FAFC]">
                <span className="text-xs font-mono font-bold text-[#94601A] uppercase">Battery Consumption</span>
                <div className="font-heading text-3xl font-extrabold text-[#94601A] mt-2 mb-1">
                  6+ Hours
                </div>
                <p className="text-xs text-[#65738A] leading-relaxed">
                  Minimal GPU rendering allows mobile devices to stream and listen for hours without thermal throttling or rapid battery drain.
                </p>
              </div>
            </div>

            <div className="mt-12 text-center pt-8 border-t border-[#D8E0EC]">
              <Link
                to="/contact"
                className="inline-flex items-center gap-2 rounded-xl bg-[#5979AC] px-7 py-3 text-xs font-bold text-white shadow-xs hover:bg-[#496A9C] transition-colors"
              >
                <span>Have a Feature Request or Technical Question?</span>
                <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}

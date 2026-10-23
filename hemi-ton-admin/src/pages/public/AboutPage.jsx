// ============================================================
// Hemi Ton Public — About Us Page (Lighter Cloud Blue Theme)
// ============================================================

import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  Radio,
  Headphones,
  Users,
  ShieldCheck,
  Globe2,
  Sparkles,
  ArrowRight,
  Heart,
  Cpu,
  Award,
} from 'lucide-react';

export function AboutPage() {
  useEffect(() => {
    document.title = 'About Hemi Ton — Next-Gen Social Audio Platform';
  }, []);

  const pillars = [
    {
      icon: Headphones,
      title: 'Voice First Philosophy',
      desc: 'We believe real-time human voice conveys emotion, warmth, and spontaneous camaraderie far better than static text or stressful video feeds. Voice brings people together without fatigue.',
    },
    {
      icon: Cpu,
      title: 'Sub-Second Global Architecture',
      desc: 'Built on dedicated Agora Real-Time Communication clusters, Hemi Ton streams low-latency audio across 200+ edge nodes globally with adaptive bitrate smoothing.',
    },
    {
      icon: Award,
      title: 'Creator Prosperity',
      desc: 'Broadcasters are the heartbeat of social spaces. We offer transparent coin-to-fiat conversion rates, automated agency accounting, and reliable banking withdrawals.',
    },
    {
      icon: ShieldCheck,
      title: 'Governance & Community Safety',
      desc: 'Safety is woven into the infrastructure. Advanced acoustic toxicity filters and 24/7 dedicated moderation ensure positive, respectful, and protected interactions.',
    },
  ];

  return (
    <div className="flex flex-col w-full overflow-hidden">
      {/* Hero Header */}
      <section className="relative pt-16 pb-20 md:pt-20 md:pb-28 bg-gradient-to-b from-[#F5F8FC] to-[#EEF4FB] border-b border-[#D8E0EC]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center max-w-3xl">
          <span className="text-xs font-mono font-bold uppercase tracking-wider text-[#5979AC] bg-white border border-[#D8E0EC] px-3.5 py-1.5 rounded-full shadow-2xs">
            Our Mission & Vision
          </span>
          <h1 className="font-heading text-4xl sm:text-5xl font-extrabold text-[#263957] tracking-tight mt-6 mb-6">
            Building the Digital Town Square for Global Voices
          </h1>
          <p className="text-base sm:text-lg text-[#65738A] leading-relaxed">
            Hemi Ton was founded on a simple conviction: modern digital communication should feel as warm, spontaneous, and lively as sitting in the same room with lifelong friends.
          </p>
        </div>
      </section>

      {/* Story & Evolution */}
      <section className="py-20 bg-white border-b border-[#D8E0EC]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <span className="text-xs font-mono font-bold uppercase tracking-wider text-[#5979AC]">
                The Hemi Ton Story
              </span>
              <h2 className="font-heading text-3xl font-extrabold text-[#263957] tracking-tight mt-2 mb-5">
                From Isolated Feeds to Collective Soundscapes
              </h2>
              <div className="space-y-4 text-sm text-[#65738A] leading-relaxed">
                <p>
                  As social media drifted into endless algorithmic video loops, meaningful connection became scarce. People were watching other people live, but rarely participating together.
                </p>
                <p>
                  Hemi Ton was created to reverse that trend. By stripping away camera anxiety and focusing completely on rich spatial audio, interactive soundboards, and synchronized virtual gifting, Hemi Ton turns passive viewers into active participants.
                </p>
                <p>
                  Today, thousands of creators, musicians, gamers, and diaspora communities gather daily across hundreds of active Hemi Ton rooms to debate, sing, compete, and celebrate life in real time.
                </p>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="rounded-2xl border border-[#D8E0EC] bg-[#F8FAFC] p-6 shadow-2xs">
                <span className="font-heading text-3xl font-extrabold text-[#263957]">200+</span>
                <h4 className="text-xs font-bold text-[#5979AC] font-mono mt-1">RTC Edge Nodes</h4>
                <p className="text-[11px] text-[#65738A] mt-2">Global distribution ensuring sub-150ms round-trip latency anywhere on earth.</p>
              </div>

              <div className="rounded-2xl border border-[#D8E0EC] bg-[#F8FAFC] p-6 shadow-2xs">
                <span className="font-heading text-3xl font-extrabold text-[#2E7D52]">14.8k+</span>
                <h4 className="text-xs font-bold text-[#2E7D52] font-mono mt-1">Active Accounts</h4>
                <p className="text-[11px] text-[#65738A] mt-2">Organic community of vetted hosts, talent agencies, and live listeners.</p>
              </div>

              <div className="rounded-2xl border border-[#D8E0EC] bg-[#F8FAFC] p-6 shadow-2xs">
                <span className="font-heading text-3xl font-extrabold text-[#5979AC]">70%</span>
                <h4 className="text-xs font-bold text-[#5979AC] font-mono mt-1">Creator Payouts</h4>
                <p className="text-[11px] text-[#65738A] mt-2">Equitable economic design empowering creators to build sustainable full-time careers.</p>
              </div>

              <div className="rounded-2xl border border-[#D8E0EC] bg-[#F8FAFC] p-6 shadow-2xs">
                <span className="font-heading text-3xl font-extrabold text-[#94601A]">24 / 7</span>
                <h4 className="text-xs font-bold text-[#94601A] font-mono mt-1">Safety Oversight</h4>
                <p className="text-[11px] text-[#65738A] mt-2">Multi-tier content moderation and automated acoustic monitoring.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Core Pillars */}
      <section className="py-20 bg-[#F8FAFC]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-14">
            <h2 className="font-heading text-3xl font-extrabold text-[#263957]">
              Our Guiding Architecture
            </h2>
            <p className="text-sm text-[#65738A] mt-2">
              Every feature on Hemi Ton is designed to elevate human dialogue and community safety.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {pillars.map((item, idx) => {
              const Icon = item.icon;
              return (
                <div key={idx} className="flex gap-4 p-7 rounded-2xl border border-[#D8E0EC] bg-white shadow-2xs">
                  <div className="h-12 w-12 rounded-xl bg-[#EEF4FB] border border-[#DCE6F5] flex items-center justify-center text-[#5979AC] shrink-0">
                    <Icon className="h-6 w-6" />
                  </div>
                  <div>
                    <h3 className="font-heading text-base font-bold text-[#263957] mb-2">{item.title}</h3>
                    <p className="text-xs text-[#65738A] leading-relaxed">{item.desc}</p>
                  </div>
                </div>
              );
            })}
          </div>

          <div className="mt-16 text-center">
            <Link
              to="/contact"
              className="inline-flex items-center gap-2 rounded-xl bg-[#5979AC] px-6 py-3.5 text-xs font-bold text-white shadow-xs hover:bg-[#496A9C] transition-colors"
            >
              <span>Get in Touch with our Executive Team</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}

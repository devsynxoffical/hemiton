// ============================================================
// Hemi Ton Admin Console — Executive Dashboard (JSX)
// Enhanced Visualizations: 2 Standalone Bar Charts, Area Velocity,
// 2 Animated Pi Graphs (animated on load, reload, & page change),
// Dedicated BI Velocity Panels, and Live Telemetry Matrix
// ============================================================

import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  Activity,
  AlertCircle,
  BarChart3,
  CheckCircle,
  Coins,
  Crown,
  DollarSign,
  Gift,
  Megaphone,
  Radio,
  RotateCw,
  Shield,
  Sparkles,
  TrendingUp,
  Users,
  Volume2,
  Wallet,
  Wifi,
  X,
  Zap,
} from 'lucide-react';
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';

import { StatCard } from '../../components/ui/StatCard';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Avatar } from '../../components/common/Avatar';
import { AnimatedPiGraph } from '../../components/ui/AnimatedPiGraph';
import { formatCompact, formatCurrency, timeAgo } from '../../utils/format';
import {
  getDashboardStats,
  getDashboardCharts,
  getDashboardContent,
} from '../../services/modules/dashboard.service';
import hemiTonLogo from '../../assets/images/ht-logo.jpg';

// Dark Minimal Tooltip for Recharts
const ChartTooltip = ({ active, payload, label }) => {
  if (active && payload && payload.length) {
    return (
      <div className="rounded-xl border border-[#1E2B45] bg-[#0A101C]/95 px-3.5 py-2.5 shadow-2xl backdrop-blur-md text-xs">
        <p className="text-slate-400 font-medium mb-1.5">{label}</p>
        {payload.map((p, i) => (
          <div key={i} className="flex items-center justify-between gap-4 py-0.5">
            <span className="text-slate-400 text-[11px] flex items-center gap-1.5">
              <span className="h-2 w-2 rounded-full" style={{ backgroundColor: p.color || p.stroke || p.fill }} />
              {p.name || 'Value'}:
            </span>
            <span className="font-bold text-white text-[11px]">
              {typeof p.value === 'number' && p.value > 999
                ? formatCompact(p.value)
                : p.value}
            </span>
          </div>
        ))}
      </div>
    );
  }
  return null;
};

function getActivityConfig(type) {
  const configs = {
    withdrawal_approved: { icon: CheckCircle, color: 'text-emerald-400', bg: 'bg-emerald-500/10 border-emerald-500/20' },
    host_verified: { icon: Shield, color: 'text-[#D4AF37]', bg: 'bg-[#D4AF37]/10 border-[#D4AF37]/20' },
    agency_verified: { icon: Crown, color: 'text-violet-400', bg: 'bg-violet-500/10 border-violet-500/20' },
    user_banned: { icon: X, color: 'text-rose-400', bg: 'bg-rose-500/10 border-rose-500/20' },
    announcement: { icon: Megaphone, color: 'text-amber-400', bg: 'bg-amber-500/10 border-amber-500/20' },
    room_closed: { icon: Radio, color: 'text-slate-400', bg: 'bg-slate-800 border-slate-700' },
    gift_added: { icon: Gift, color: 'text-pink-400', bg: 'bg-pink-500/10 border-pink-500/20' },
  };
  return configs[type] || { icon: AlertCircle, color: 'text-slate-400', bg: 'bg-slate-800 border-slate-700' };
}

// 7-Day Peak Concurrency Mock Series (Rooms vs Listeners)
const CONCURRENCY_DATA = [
  { hour: '00:00', rooms: 28, listeners: 720 },
  { hour: '04:00', rooms: 19, listeners: 410 },
  { hour: '08:00', rooms: 34, listeners: 980 },
  { hour: '12:00', rooms: 52, listeners: 1640 },
  { hour: '16:00', rooms: 68, listeners: 2310 },
  { hour: '20:00', rooms: 84, listeners: 3420 },
  { hour: '23:00', rooms: 61, listeners: 2150 },
];

// Transaction Density Data for Separate Bar Chart
const TRANSACTION_DENSITY = [
  { day: 'Mon', coinIntake: 12400, cashoutSettled: 4200 },
  { day: 'Tue', coinIntake: 15800, cashoutSettled: 5600 },
  { day: 'Wed', coinIntake: 14200, cashoutSettled: 4900 },
  { day: 'Thu', coinIntake: 18600, cashoutSettled: 6400 },
  { day: 'Fri', coinIntake: 22400, cashoutSettled: 7800 },
  { day: 'Sat', coinIntake: 28900, cashoutSettled: 9200 },
  { day: 'Sun', coinIntake: 21200, cashoutSettled: 7100 },
];

// Donut 1: Revenue Stream Allocation (The Pi)
const REVENUE_STREAM_PI = [
  { name: 'Coin Pack Recharges', value: 58, percent: '58%', color: '#D4AF37', subtext: 'In-app Apple/Google & web store' },
  { name: 'VIP & SVIP Passes', value: 22, percent: '22%', color: '#2563EB', subtext: 'Tier subscriptions & badges' },
  { name: 'Live Social Gifting', value: 12, percent: '12%', color: '#EC4899', subtext: 'Virtual gifts & animated props' },
  { name: 'Agency Commission', value: 8, percent: '8%', color: '#8B5CF6', subtext: 'Host network revenue share' },
];

// Donut 2: Space & Room Category Share (The Pi)
const ROOM_CATEGORY_PI = [
  { name: 'Multi-Speaker Party', value: 42, percent: '42%', color: '#38BDF8', subtext: '8-12 seat interactive voice rooms' },
  { name: 'Live Music & Audio', value: 26, percent: '26%', color: '#D4AF37', subtext: 'Acoustic sessions & DJs' },
  { name: 'PK Battles & Contests', value: 18, percent: '18%', color: '#F43F5E', subtext: 'Real-time host versus host games' },
  { name: 'VIP Audio Lounge', value: 14, percent: '14%', color: '#A855F7', subtext: 'Exclusive subscriber spaces' },
];

export function Dashboard() {
  const location = useLocation();
  const [stats, setStats] = useState(null);
  const [charts, setCharts] = useState(null);
  const [content, setContent] = useState(null);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [lastRefreshed, setLastRefreshed] = useState(new Date());

  const loadDashboardData = async () => {
    setIsRefreshing(true);
    try {
      const results = await Promise.allSettled([
        getDashboardStats(),
        getDashboardCharts(),
        getDashboardContent(),
      ]);
      const [statsRes, chartsRes, contentRes] = results;
      if (statsRes.status === 'fulfilled' && statsRes.value) setStats(statsRes.value);
      if (chartsRes.status === 'fulfilled' && chartsRes.value) setCharts(chartsRes.value);
      if (contentRes.status === 'fulfilled' && contentRes.value) setContent(contentRes.value);
      setLastRefreshed(new Date());
    } catch (err) {
      console.warn('Dashboard fetch fallback:', err);
    } finally {
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    loadDashboardData();
  }, [location.pathname]);

  const s = {
    activeRooms: stats?.activeRooms ?? stats?.activeLiveRooms ?? 1847,
    concurrentViewers: stats?.concurrentViewers ?? 34200,
    coinSalesToday: stats?.coinSalesToday ?? stats?.revenueToday ?? 18740,
    coinsSoldToday: stats?.coinsSoldToday ?? 1850000,
    giftsSentToday: stats?.giftsSentToday ?? 8420,
    giftCoinsVolumeToday: stats?.giftCoinsVolumeToday ?? 420000,
    totalUsers: stats?.totalUsers ?? 284510,
    totalRevenue: stats?.totalRevenue ?? stats?.revenueThisMonth ?? 412830,
    activeHosts: stats?.activeHosts ?? 48,
    pendingHostVerifications: stats?.pendingHostVerifications ?? 5,
    pendingAgencyVerifications: stats?.pendingAgencyVerifications ?? 2,
    activeSocialAudioRooms: stats?.activeSocialAudioRooms ?? 68,
    totalAudioListeners: stats?.totalAudioListeners ?? 3420,
    audioRoomDiamondVolume: stats?.audioRoomDiamondVolume ?? 4850000,
    fourEyesApprovalsCount: stats?.fourEyesApprovalsCount ?? 3,
    revenueGrowthPercent: stats?.revenueGrowthPercent ?? 18.2,
    roomsGrowthPercent: stats?.roomsGrowthPercent ?? 14.6,
    viewersGrowthPercent: stats?.viewersGrowthPercent ?? 21.8,
    ...stats,
  };

  return (
    <div className="space-y-6 max-w-screen-2xl mx-auto animate-page-enter pb-10" aria-label="Hemi Ton Dashboard">
      
      {/* 1. Executive Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 rounded-2xl border border-[#182337] bg-gradient-to-r from-[#0E1524] via-[#0A0F1A] to-[#0E1524] p-5 shadow-xl">
        <div className="flex items-center gap-3.5">
          <div className="relative flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-[#0C121E] border border-[#D4AF37]/35 p-1 shadow-lg shadow-black/80">
            <img
              src={hemiTonLogo}
              alt="Hemi Ton Logo"
              className="h-full w-full rounded-lg object-cover"
            />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-white tracking-tight font-serif">
                HEMI TON COMMAND OVERVIEW
              </h1>
              <span className="hidden sm:inline-block px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-[#D4AF37]/15 text-[#D4AF37] border border-[#D4AF37]/30">
                PROD v2.4
              </span>
            </div>
            <p className="text-xs text-slate-400 mt-0.5">
              Live operational telemetry, social audio concurrency & creator monetization intelligence
            </p>
          </div>
        </div>

        <div className="flex items-center gap-3 self-end sm:self-center">
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl border border-emerald-500/25 bg-emerald-500/10 text-emerald-400 text-xs font-semibold">
            <span className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
            <span>Client Testing Active</span>
          </div>

          <button
            onClick={loadDashboardData}
            disabled={isRefreshing}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-[#1C283F] bg-[#111A2B] hover:bg-[#16233B] text-xs font-semibold text-slate-300 hover:text-white transition-all shadow-sm"
          >
            <RotateCw className={`h-3.5 w-3.5 ${isRefreshing ? 'animate-spin text-[#D4AF37]' : 'text-slate-400'}`} />
            <span>Sync Telemetry</span>
          </button>
        </div>
      </div>

      {/* 2. Key Performance Indicators (2 Rows — 3 Tabs Per Row) */}
      <section aria-labelledby="kpi-heading">
        <h2 id="kpi-heading" className="sr-only">Key Performance Indicators</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          <StatCard
            title="Active Audio Spaces"
            value={s.activeRooms}
            icon={Radio}
            iconColor="text-[#D4AF37]"
            iconBg="bg-[#D4AF37]/10"
            change={s.roomsGrowthPercent}
            changeLabel="vs last week"
          />
          <StatCard
            title="Concurrent Listeners"
            value={s.concurrentViewers}
            icon={Activity}
            iconColor="text-emerald-400"
            iconBg="bg-emerald-500/10"
            change={s.viewersGrowthPercent}
            changeLabel="peak concurrency"
          />
          <StatCard
            title="Today's Coin Sales"
            value={formatCurrency(s.coinSalesToday)}
            icon={Coins}
            iconColor="text-amber-400"
            iconBg="bg-amber-500/10"
            subValue={`${formatCompact(s.coinsSoldToday)} coins issued`}
          />
          <StatCard
            title="Gifts Sent Today"
            value={formatCompact(s.giftsSentToday)}
            icon={Gift}
            iconColor="text-pink-400"
            iconBg="bg-pink-500/10"
            subValue={`${formatCompact(s.giftCoinsVolumeToday)} diamond vol`}
          />
          <StatCard
            title="Total Registered Users"
            value={formatCompact(s.totalUsers)}
            icon={Users}
            iconColor="text-sky-400"
            iconBg="bg-sky-500/10"
            subValue="Verified accounts"
          />
          <StatCard
            title="Gross Treasury Volume"
            value={formatCurrency(s.totalRevenue)}
            icon={Wallet}
            iconColor="text-[#D4AF37]"
            iconBg="bg-[#D4AF37]/10"
            change={s.revenueGrowthPercent}
            changeLabel="monthly intake"
          />
        </div>
      </section>

      {/* 3. PRIMARY VISUALIZATIONS ROW: BAR CHART #1 (Peak Concurrency) & AREA VELOCITY CHART */}
      <section className="grid grid-cols-1 gap-5 lg:grid-cols-12">
        
        {/* GRAPH 1: STANDALONE BAR GRAPH #1 (Room & Viewer Concurrency Dynamics) */}
        <div className="lg:col-span-7 rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-5 shadow-xl">
          <div className="flex items-center justify-between pb-3 border-b border-[#182337] mb-4">
            <div>
              <div className="flex items-center gap-2">
                <BarChart3 className="h-4 w-4 text-[#D4AF37]" />
                <h3 className="text-sm font-bold text-white tracking-wide">
                  Peak Room & Audience Concurrency
                </h3>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                Hourly active broadcast rooms vs concurrent audio audience load
              </p>
            </div>
            <div className="flex items-center gap-3 text-xs">
              <span className="flex items-center gap-1.5 text-slate-300 text-[11px]">
                <span className="h-2.5 w-2.5 rounded bg-[#2563EB]" />
                Rooms
              </span>
              <span className="flex items-center gap-1.5 text-slate-300 text-[11px]">
                <span className="h-2.5 w-2.5 rounded bg-[#D4AF37]" />
                Audience (x50)
              </span>
            </div>
          </div>

          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={CONCURRENCY_DATA} margin={{ top: 10, right: 10, bottom: 0, left: -16 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#162238" vertical={false} />
                <XAxis
                  dataKey="hour"
                  tick={{ fill: '#64748b', fontSize: 11 }}
                  axisLine={{ stroke: '#1C283F' }}
                  tickLine={false}
                />
                <YAxis
                  tick={{ fill: '#64748b', fontSize: 11 }}
                  axisLine={{ stroke: '#1C283F' }}
                  tickLine={false}
                  tickFormatter={formatCompact}
                />
                <Tooltip content={<ChartTooltip />} />
                <Bar
                  dataKey="rooms"
                  name="Active Rooms"
                  fill="#2563EB"
                  radius={[4, 4, 0, 0]}
                  maxBarSize={28}
                />
                <Bar
                  dataKey="listeners"
                  name="Listeners"
                  fill="#D4AF37"
                  radius={[4, 4, 0, 0]}
                  maxBarSize={28}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* GRAPH 2: USER ACQUISITION & GROWTH VELOCITY (AREA CHART) */}
        <div className="lg:col-span-5 rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-5 shadow-xl flex flex-col justify-between">
          <div className="flex items-center justify-between pb-3 border-b border-[#182337] mb-4">
            <div>
              <div className="flex items-center gap-2">
                <TrendingUp className="h-4 w-4 text-emerald-400" />
                <h3 className="text-sm font-bold text-white tracking-wide">
                  User Growth & Acquisition Velocity
                </h3>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                Daily new creators & audience signups — past 7 days
              </p>
            </div>
            <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
              +14.8% Net
            </span>
          </div>

          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart
                data={charts?.userActivity || [
                  { label: 'Mon', value: 4200 },
                  { label: 'Tue', value: 4900 },
                  { label: 'Wed', value: 4700 },
                  { label: 'Thu', value: 5800 },
                  { label: 'Fri', value: 6900 },
                  { label: 'Sat', value: 8100 },
                  { label: 'Sun', value: 7400 },
                ]}
                margin={{ top: 10, right: 10, bottom: 0, left: -20 }}
              >
                <defs>
                  <linearGradient id="growthGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#D4AF37" stopOpacity={0.35} />
                    <stop offset="95%" stopColor="#D4AF37" stopOpacity={0.0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#162238" vertical={false} />
                <XAxis
                  dataKey="label"
                  tick={{ fill: '#64748b', fontSize: 11 }}
                  axisLine={{ stroke: '#1C283F' }}
                  tickLine={false}
                />
                <YAxis
                  tick={{ fill: '#64748b', fontSize: 11 }}
                  axisLine={{ stroke: '#1C283F' }}
                  tickLine={false}
                  tickFormatter={formatCompact}
                />
                <Tooltip content={<ChartTooltip />} />
                <Area
                  type="monotone"
                  dataKey="value"
                  name="New Users"
                  stroke="#D4AF37"
                  strokeWidth={2.5}
                  fill="url(#growthGrad)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

      </section>

      {/* 4. DEDICATED BI SECTION: BUSINESS INTELLIGENCE FINANCIAL VELOCITY PANEL */}
      <section className="rounded-2xl border border-[#223352] bg-gradient-to-r from-[#0C121E] via-[#0E1626] to-[#0A0F1A] p-6 shadow-2xl">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-[#182337]">
          <div>
            <div className="flex items-center gap-2">
              <Zap className="h-4 w-4 text-[#D4AF37]" />
              <h3 className="text-base font-bold text-white tracking-wide">
                Executive Treasury & Financial Velocity BI
              </h3>
            </div>
            <p className="text-xs text-slate-400 mt-1">
              Multi-dimensional cash liquidity telemetry, creator withdrawal settlement ratios, and net cash reserve
            </p>
          </div>
          <div className="flex items-center gap-2 text-xs">
            <span className="px-2.5 py-1 rounded-lg bg-[#D4AF37]/10 border border-[#D4AF37]/25 text-[#D4AF37] font-semibold">
              Treasury Run-Rate: $18,740 / Day
            </span>
            <span className="px-2.5 py-1 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 font-semibold">
              P2P Settlement Ratio: 34.2%
            </span>
          </div>
        </div>

        {/* 4 BI Diagnostic Cards */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 my-5">
          <div className="rounded-xl border border-[#182337] bg-[#0A0F1A]/80 p-3.5">
            <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider block">
              7-Day Net Cash Intake
            </span>
            <span className="text-xl font-extrabold text-white mt-1 block">
              $134,280
            </span>
            <span className="text-[11px] text-emerald-400 font-medium flex items-center gap-1 mt-0.5">
              <TrendingUp className="h-3 w-3" /> +16.2% vs previous week
            </span>
          </div>

          <div className="rounded-xl border border-[#182337] bg-[#0A0F1A]/80 p-3.5">
            <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider block">
              Creator Cashouts Settled
            </span>
            <span className="text-xl font-extrabold text-[#D4AF37] mt-1 block">
              $45,800
            </span>
            <span className="text-[11px] text-slate-400 mt-0.5 block">
              34.1% payout liquidity ratio
            </span>
          </div>

          <div className="rounded-xl border border-[#182337] bg-[#0A0F1A]/80 p-3.5">
            <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider block">
              Avg Intake Per Paying User
            </span>
            <span className="text-xl font-extrabold text-sky-400 mt-1 block">
              $42.80
            </span>
            <span className="text-[11px] text-slate-400 mt-0.5 block">
              ARPPU (Top 8.4% of users)
            </span>
          </div>

          <div className="rounded-xl border border-[#182337] bg-[#0A0F1A]/80 p-3.5">
            <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider block">
              Coin-to-Diamond Burn Rate
            </span>
            <span className="text-xl font-extrabold text-violet-400 mt-1 block">
              1 : 0.86
            </span>
            <span className="text-[11px] text-emerald-400 font-medium mt-0.5 block">
              Platform spread: +14.0%
            </span>
          </div>
        </div>

        {/* 7-Day Net Cashflow Velocity Curve */}
        <div className="h-44 w-full pt-2">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart
              data={charts?.revenue || [
                { label: 'Mon', value: 12400 },
                { label: 'Tue', value: 15800 },
                { label: 'Wed', value: 11200 },
                { label: 'Thu', value: 18600 },
                { label: 'Fri', value: 22100 },
                { label: 'Sat', value: 28400 },
                { label: 'Sun', value: 18740 },
              ]}
              margin={{ top: 5, right: 10, bottom: 0, left: -16 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#162238" vertical={false} />
              <XAxis dataKey="label" tick={{ fill: '#64748b', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#64748b', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={(v) => `$${formatCompact(v)}`} />
              <Tooltip content={<ChartTooltip />} />
              <Line
                type="monotone"
                dataKey="value"
                name="Gross Daily Revenue"
                stroke="#10b981"
                strokeWidth={2.5}
                dot={{ fill: '#10b981', r: 3.5 }}
                activeDot={{ r: 6 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </section>

      {/* 5. VISUALIZATIONS ROW: ANIMATED PI GRAPH #1 + SEPARATE BAR CHART #2 + ANIMATED PI GRAPH #2 */}
      <section className="grid grid-cols-1 gap-5 lg:grid-cols-12">
        
        {/* ANIMATED PI GRAPH 1: Treasury & Revenue Streams Breakdown */}
        <div className="lg:col-span-4">
          <AnimatedPiGraph
            title="Revenue Stream Allocation"
            subtitle="Gross intake breakdown by category"
            data={REVENUE_STREAM_PI}
            centerValue="$148.2k"
            centerLabel="Gross Intake"
            icon={DollarSign}
            height={210}
            innerRadius={56}
            outerRadius={80}
            className="h-full"
          />
        </div>

        {/* STANDALONE BAR CHART #2 (Transaction Volume & Settlement Density) */}
        <div className="lg:col-span-4 rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-5 shadow-xl flex flex-col justify-between">
          <div className="flex items-center justify-between pb-3 border-b border-[#182337] mb-3">
            <div>
              <div className="flex items-center gap-2">
                <BarChart3 className="h-4 w-4 text-[#D4AF37]" />
                <h3 className="text-sm font-bold text-white tracking-wide">
                  Coin Intake vs Settlements
                </h3>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                Daily coin recharge inflow vs creator payout outflow
              </p>
            </div>
            <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-sky-500/10 text-sky-400 border border-sky-500/20">
              Density
            </span>
          </div>

          <div className="h-56 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={TRANSACTION_DENSITY} margin={{ top: 5, right: 5, bottom: 0, left: -20 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#162238" vertical={false} />
                <XAxis dataKey="day" tick={{ fill: '#64748b', fontSize: 11 }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fill: '#64748b', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={(v) => `$${formatCompact(v)}`} />
                <Tooltip content={<ChartTooltip />} />
                <Bar dataKey="coinIntake" name="Coin Intake" fill="#D4AF37" radius={[3, 3, 0, 0]} />
                <Bar dataKey="cashoutSettled" name="Cashouts Settled" fill="#64748B" radius={[3, 3, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="mt-3 pt-3 border-t border-[#182337] flex items-center justify-between text-xs text-slate-400">
            <span className="flex items-center gap-1.5 text-[11px]">
              <span className="h-2 w-2 rounded bg-[#D4AF37]" /> Recharges ($133.8k)
            </span>
            <span className="flex items-center gap-1.5 text-[11px]">
              <span className="h-2 w-2 rounded bg-[#64748B]" /> Settlements ($45.8k)
            </span>
          </div>
        </div>

        {/* ANIMATED PI GRAPH 2: Audio Spaces & Live Category Share */}
        <div className="lg:col-span-4">
          <AnimatedPiGraph
            title="Audio Space & Category Share"
            subtitle="Live room spectrum & audience spread"
            data={ROOM_CATEGORY_PI}
            centerValue="1,847"
            centerLabel="Live Spaces"
            icon={Radio}
            height={210}
            innerRadius={56}
            outerRadius={80}
            className="h-full"
          />
        </div>

      </section>

      {/* 6. PLATFORM AUDIO ENGINE & AGORA TELEMETRY BI MATRIX */}
      <section className="rounded-2xl border border-[#182337] bg-gradient-to-r from-[#0C121E] via-[#0E1524] to-[#0A0F1A] p-5 shadow-xl grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="flex items-start gap-3">
          <div className="p-2.5 rounded-xl bg-sky-500/10 border border-sky-500/20 text-sky-400 flex-shrink-0">
            <Wifi className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs text-slate-400 font-medium">Real-Time Agora Audio Concurrency</p>
            <p className="text-lg font-bold text-white mt-0.5">3,420 Active Channels</p>
            <p className="text-[11px] text-emerald-400 flex items-center gap-1 mt-0.5">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" /> 99.98% uptime SLA
            </p>
          </div>
        </div>

        <div className="flex items-start gap-3">
          <div className="p-2.5 rounded-xl bg-[#D4AF37]/10 border border-[#D4AF37]/20 text-[#D4AF37] flex-shrink-0">
            <Volume2 className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs text-slate-400 font-medium">Voice Codec Stream Latency</p>
            <p className="text-lg font-bold text-white mt-0.5">112ms Ultra-Low Latency</p>
            <p className="text-[11px] text-slate-400 mt-0.5">Opus 48kHz HD Audio</p>
          </div>
        </div>

        <div className="flex items-start gap-3">
          <div className="p-2.5 rounded-xl bg-violet-500/10 border border-violet-500/20 text-violet-400 flex-shrink-0">
            <Crown className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs text-slate-400 font-medium">Verified Agency Creator Roster</p>
            <p className="text-lg font-bold text-white mt-0.5">48 Active Top Creators</p>
            <p className="text-[11px] text-slate-400 mt-0.5">Across 18 Agency Partners</p>
          </div>
        </div>

        <div className="flex items-start gap-3">
          <div className="p-2.5 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-400 flex-shrink-0">
            <Shield className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs text-slate-400 font-medium">4-Eyes Governance Queue</p>
            <p className="text-lg font-bold text-amber-400 mt-0.5">{s.fourEyesApprovalsCount} Actions Pending</p>
            <Link to="/admin/approvals" className="text-[11px] text-[#D4AF37] hover:underline mt-0.5 block">
              Review Dual-Signoff Requests &rarr;
            </Link>
          </div>
        </div>
      </section>

      {/* 7. DATA TABLES: TOP HOSTS & TOP CONTENT */}
      <div className="grid grid-cols-1 gap-5 lg:grid-cols-5">
        <div className="lg:col-span-3 rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-5 shadow-xl">
          <div className="flex items-center justify-between pb-3 border-b border-[#182337] mb-4">
            <div>
              <h3 className="text-sm font-bold text-white tracking-wide">Top Earning Creators & Hosts</h3>
              <p className="text-xs text-slate-400 mt-0.5">Ranked by monthly platform diamond generation</p>
            </div>
            <Link to="/admin/hosts" className="text-xs font-semibold text-[#D4AF37] hover:underline">
              View All Hosts &rarr;
            </Link>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="border-b border-[#182337] text-[11px] uppercase tracking-wider text-slate-400">
                  <th className="pb-3 font-semibold">Rank</th>
                  <th className="pb-3 font-semibold">Creator</th>
                  <th className="pb-3 font-semibold text-right hidden sm:table-cell">Audience</th>
                  <th className="pb-3 font-semibold text-right hidden md:table-cell">Hours</th>
                  <th className="pb-3 font-semibold text-right">Intake</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#151F33]">
                {(content?.topHosts || [
                  { rank: 1, displayName: 'StarQueen Luna', username: '@luna_star', totalViewers: 2840000, hoursStreamed: 312, totalEarnings: 148200, isVerified: true },
                  { rank: 2, displayName: 'NightOwl Kai', username: '@kai_night', totalViewers: 1960000, hoursStreamed: 285, totalEarnings: 112580, isVerified: true },
                  { rank: 3, displayName: 'BlazingRose', username: '@blazing_rose', totalViewers: 1520000, hoursStreamed: 247, totalEarnings: 98300, isVerified: true },
                  { rank: 4, displayName: 'TechWizard Max', username: '@max_techw', totalViewers: 1180000, hoursStreamed: 198, totalEarnings: 74100, isVerified: false },
                  { rank: 5, displayName: 'ZenMaster Aria', username: '@aria_zen', totalViewers: 880000, hoursStreamed: 172, totalEarnings: 61800, isVerified: true },
                ]).slice(0, 5).map((host, idx) => (
                  <tr key={idx} className="hover:bg-[#131D30]/60 transition-colors">
                    <td className="py-3 text-xs font-bold text-slate-400">#{host.rank}</td>
                    <td className="py-3">
                      <div className="flex items-center gap-2.5">
                        <Avatar name={host.displayName} size="sm" />
                        <div>
                          <p className="text-xs font-semibold text-white flex items-center gap-1">
                            {host.displayName}
                            {host.isVerified && <Shield className="h-3 w-3 text-[#D4AF37]" />}
                          </p>
                          <p className="text-[11px] text-slate-400">{host.username}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-3 text-right text-xs text-slate-300 hidden sm:table-cell">
                      {formatCompact(host.totalViewers)}
                    </td>
                    <td className="py-3 text-right text-xs text-slate-400 hidden md:table-cell">
                      {host.hoursStreamed}h
                    </td>
                    <td className="py-3 text-right text-xs font-bold text-emerald-400">
                      {formatCurrency(host.totalEarnings)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="lg:col-span-2 rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-5 shadow-xl flex flex-col justify-between">
          <div className="flex items-center justify-between pb-3 border-b border-[#182337] mb-3">
            <div>
              <h3 className="text-sm font-bold text-white tracking-wide">Top Live Spaces</h3>
              <p className="text-xs text-slate-400 mt-0.5">Highest concurrent listener sessions</p>
            </div>
            <Link to="/admin/live-rooms" className="text-xs font-semibold text-[#D4AF37] hover:underline">
              All Rooms &rarr;
            </Link>
          </div>

          <div className="space-y-3">
            {(content?.topContent || [
              { rank: 1, title: 'Midnight PK Battle Championship', hostName: 'StarQueen Luna', viewers: 48200, category: 'PK Battle' },
              { rank: 2, title: 'Chill Saturday Dance & Acoustic', hostName: 'BlazingRose', viewers: 36700, category: 'Social Audio' },
              { rank: 3, title: 'Trivia Game Night with Cash Prizes', hostName: 'NightOwl Kai', viewers: 29100, category: 'Games' },
              { rank: 4, title: 'Morning Motivation & Life Chat', hostName: 'ZenMaster Aria', viewers: 22400, category: 'Talk Show' },
            ]).slice(0, 4).map((room, idx) => (
              <div key={idx} className="flex items-center justify-between p-2.5 rounded-xl border border-[#162136] bg-[#0A101C]/80 hover:border-[#D4AF37]/30 transition-all">
                <div className="flex items-center gap-3 min-w-0">
                  <span className="text-xs font-bold text-slate-500 w-4">#{room.rank}</span>
                  <div className="min-w-0">
                    <p className="text-xs font-semibold text-white truncate">{room.title}</p>
                    <p className="text-[11px] text-slate-400 flex items-center gap-1.5 mt-0.5">
                      <span>{room.hostName}</span>
                      <span>·</span>
                      <span className="text-[#D4AF37]">{room.category}</span>
                    </p>
                  </div>
                </div>
                <div className="text-right flex-shrink-0 ml-3">
                  <span className="text-xs font-extrabold text-white block">
                    {formatCompact(room.viewers)}
                  </span>
                  <span className="text-[10px] text-slate-400">listeners</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* 8. ADMINISTRATIVE AUDIT & ACTIVITY LOG */}
      <div className="rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-5 shadow-xl">
        <div className="flex items-center justify-between pb-3 border-b border-[#182337] mb-4">
          <div>
            <h3 className="text-sm font-bold text-white tracking-wide">Real-Time Administrative Event Stream</h3>
            <p className="text-xs text-slate-400 mt-0.5">Audited actions, approvals, compliance interventions, and security triggers</p>
          </div>
          <Link to="/admin/audit-logs" className="text-xs font-semibold text-[#D4AF37] hover:underline">
            View Complete Audit Log &rarr;
          </Link>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {(content?.recentActivities || [
            { id: 1, type: 'withdrawal_approved', description: 'Approved creator settlement of $2,400 for @luna_star', adminName: 'Super Admin', timestamp: new Date(Date.now() - 5 * 60 * 1000).toISOString() },
            { id: 2, type: 'host_verified', description: 'Host verification badge approved for @nova_streams', adminName: 'Super Admin', timestamp: new Date(Date.now() - 25 * 60 * 1000).toISOString() },
            { id: 3, type: 'agency_verified', description: 'New social audio agency "StarMedia Ent" verified', adminName: 'Super Admin', timestamp: new Date(Date.now() - 45 * 60 * 1000).toISOString() },
            { id: 4, type: 'user_banned', description: 'Account @spammer_99 restricted for Terms of Service violation', adminName: 'Compliance Lead', timestamp: new Date(Date.now() - 90 * 60 * 1000).toISOString() },
            { id: 5, type: 'announcement', description: 'Platform broadcast: Weekend PK Championship schedule pushed', adminName: 'Operations Lead', timestamp: new Date(Date.now() - 140 * 60 * 1000).toISOString() },
            { id: 6, type: 'gift_added', description: 'New 3D virtual gift "Imperial HT Dragon" activated in catalog', adminName: 'Product Manager', timestamp: new Date(Date.now() - 210 * 60 * 1000).toISOString() },
          ]).slice(0, 6).map((activity) => {
            const { icon: Icon, color, bg } = getActivityConfig(activity.type);
            return (
              <div key={activity.id} className="flex items-start gap-3 p-3 rounded-xl border border-[#162136] bg-[#0A101C]/70">
                <div className={`p-2 rounded-lg border ${bg} flex-shrink-0 mt-0.5`}>
                  <Icon className={`h-3.5 w-3.5 ${color}`} />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-xs font-medium text-slate-200 line-clamp-2 leading-snug">
                    {activity.description}
                  </p>
                  <div className="flex items-center gap-2 mt-1.5 text-[10px] text-slate-400">
                    <span className="font-semibold text-slate-300">{activity.adminName}</span>
                    <span>·</span>
                    <span>{timeAgo(activity.timestamp)}</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

    </div>
  );
}

export default Dashboard;

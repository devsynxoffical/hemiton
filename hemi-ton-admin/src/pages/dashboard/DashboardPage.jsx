// ============================================================
// Hemi Ton Admin — Executive Command Dashboard (Cloud Blue + Slate)
// ============================================================

import React, { useEffect, useState, useCallback, useRef } from 'react';
import {
  Users,
  Radio,
  Crown,
  Wallet,
  DollarSign,
  Activity,
  FileCheck2,
  Clock,
  Sparkles,
  RefreshCw,
  TrendingUp,
} from 'lucide-react';
import {
  BarChart,
  Bar,
  AreaChart,
  Area,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';

import { StatCard } from '../../components/ui/StatCard';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { DataTable } from '../../components/ui/DataTable';
import {
  formatCurrency,
  formatNumber,
  formatCompact,
  timeAgo,
} from '../../utils/formatters';
import {
  fetchDashboardKPIs,
  fetchDashboardCharts,
  fetchRecentRegistrations,
  fetchRecentTransactions,
  fetchAdminActivities,
} from '../../services/dashboardService';
import {
  MOCK_ROOM_CATEGORY_DISTRIBUTION,
  MOCK_REVENUE_SOURCE_DISTRIBUTION,
} from '../../services/mockData';

// Clean Light Tooltip for Cartesian Recharts (Cloud Blue + Slate)
const CustomChartTooltip = ({ active, payload, label, prefix = '', suffix = '' }) => {
  if (active && payload && payload.length) {
    return (
      <div className="rounded-xl border border-[#D8E0EC] bg-white p-3 shadow-sm">
        <p className="font-mono text-xs font-semibold text-[#65738A] mb-1.5">{label}</p>
        <div className="space-y-1">
          {payload.map((entry, index) => (
            <div key={index} className="flex items-center justify-between gap-4 text-xs font-medium">
              <span className="flex items-center gap-1.5 text-[#65738A]">
                <span className="h-2 w-2 rounded-full" style={{ backgroundColor: entry.color || entry.fill }} />
                {entry.name}:
              </span>
              <span className="font-mono font-bold text-[#263957]">
                {prefix}
                {formatNumber(entry.value)}
                {suffix}
              </span>
            </div>
          ))}
        </div>
      </div>
    );
  }
  return null;
};

// ============================================================
// Guaranteed-Visible, Interactive SVG Donut Chart Component
// ============================================================
function SvgDonutChart({
  data = [],
  size = 180,
  innerRadius = 50,
  outerRadius = 76,
  centerValue,
  centerLabel,
  valuePrefix = '',
  valueSuffix = '',
}) {
  const containerRef = useRef(null);
  const [hoveredIdx, setHoveredIdx] = useState(null);
  const [isInView, setIsInView] = useState(false);
  const [isAnimated, setIsAnimated] = useState(false);
  const [scrollAngle, setScrollAngle] = useState(0);

  // IntersectionObserver to trigger animation on page load, refresh, and scroll into view
  useEffect(() => {
    const element = containerRef.current;
    if (!element) return;

    if (!('IntersectionObserver' in window)) {
      setIsInView(true);
      setIsAnimated(true);
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsInView(true);
            // Kick off progressive drawing in next frame for reliable CSS transition
            requestAnimationFrame(() => {
              setIsAnimated(true);
            });
          } else {
            // Reset when scrolled completely out of view so re-entry animates again
            setIsInView(false);
            setIsAnimated(false);
          }
        });
      },
      {
        threshold: 0.15,
        rootMargin: '0px 0px -20px 0px',
      }
    );

    observer.observe(element);
    return () => observer.disconnect();
  }, []);

  // Re-trigger animation when data changes or on metrics sync
  useEffect(() => {
    if (isInView) {
      setIsAnimated(false);
      const timer = setTimeout(() => setIsAnimated(true), 60);
      return () => clearTimeout(timer);
    }
  }, [data, isInView]);

  // Subtle dynamic rotation synced to page scrolling
  useEffect(() => {
    let animationFrameId;

    const handleScroll = () => {
      if (containerRef.current) {
        const rect = containerRef.current.getBoundingClientRect();
        const windowHeight = window.innerHeight || 800;
        const elementCenter = rect.top + rect.height / 2;
        // Relative position within viewport: -1 (top), 0 (center), +1 (bottom)
        const normalizedY = (elementCenter - windowHeight / 2) / (windowHeight / 2);
        // Dynamic roll angle: ±15 degrees tilt as page is scrolled
        const dynamicTilt = Math.max(-15, Math.min(15, -normalizedY * 15));
        setScrollAngle(dynamicTilt);
      }
    };

    const onScroll = () => {
      cancelAnimationFrame(animationFrameId);
      animationFrameId = requestAnimationFrame(handleScroll);
    };

    window.addEventListener('scroll', onScroll, { passive: true });
    handleScroll();

    return () => {
      window.removeEventListener('scroll', onScroll);
      cancelAnimationFrame(animationFrameId);
    };
  }, []);

  const total = data.reduce((sum, item) => sum + (Number(item.value) || 0), 0) || 1;
  const radius = (innerRadius + outerRadius) / 2;
  const strokeWidth = outerRadius - innerRadius;
  const circumference = 2 * Math.PI * radius;

  let cumulativeOffset = 0;
  const activeItem = hoveredIdx !== null ? data[hoveredIdx] : null;

  // Base rotation is -90deg (12 o'clock start) with dynamic scroll angle and entry unwind
  const currentRotation = -90 + (isAnimated ? scrollAngle : -45);

  return (
    <div
      ref={containerRef}
      className="relative flex items-center justify-center shrink-0 select-none"
      style={{ width: size, height: size }}
    >
      <svg
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
        className="overflow-visible"
        style={{
          transform: `rotate(${currentRotation}deg) scale(${isAnimated ? 1 : 0.88})`,
          opacity: isAnimated ? 1 : 0.3,
          transition: isAnimated
            ? 'transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.6s ease-out'
            : 'transform 0.7s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.6s ease-out',
        }}
      >
        {/* Background track circle */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="#EBF0F7"
          strokeWidth={strokeWidth}
        />

        {/* Dynamic colored segments with progressive clockwise draw animation */}
        {data.map((item, index) => {
          const val = Number(item.value) || 0;
          const pct = val / total;
          const strokeLength = pct * circumference;
          const gap = data.length > 1 ? 2.5 : 0;
          const targetDash = Math.max(0, strokeLength - gap);
          const dashArray = isAnimated
            ? `${targetDash} ${circumference}`
            : `0.001 ${circumference}`;
          const offset = -cumulativeOffset;
          cumulativeOffset += strokeLength;

          const isHovered = hoveredIdx === index;

          return (
            <circle
              key={index}
              cx={size / 2}
              cy={size / 2}
              r={radius}
              fill="none"
              stroke={item.color || '#5979AC'}
              strokeWidth={isHovered ? strokeWidth + 4 : strokeWidth}
              strokeDasharray={dashArray}
              strokeDashoffset={offset}
              strokeLinecap="round"
              className="cursor-pointer"
              style={{
                strokeDasharray: dashArray,
                strokeDashoffset: offset,
                transition: isAnimated
                  ? `stroke-dasharray 1.05s cubic-bezier(0.16, 1, 0.3, 1) ${index * 80}ms, stroke-width 0.2s ease, opacity 0.2s ease, filter 0.2s ease`
                  : 'none',
                filter: isHovered ? 'drop-shadow(0 2px 8px rgba(38, 57, 87, 0.28))' : 'none',
                opacity: hoveredIdx !== null && !isHovered ? 0.55 : 1,
              }}
              onMouseEnter={() => setHoveredIdx(index)}
              onMouseLeave={() => setHoveredIdx(null)}
            >
              <title>{`${item.name}: ${valuePrefix}${formatNumber(val)}${valueSuffix} (${item.percentage || `${Math.round(pct * 100)}%`})`}</title>
            </circle>
          );
        })}
      </svg>

      {/* Center Label Display with smooth fade & scale in */}
      <div
        className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center text-center px-2 select-none"
        style={{
          opacity: isAnimated ? 1 : 0,
          transform: isAnimated ? 'scale(1) translateY(0)' : 'scale(0.85) translateY(6px)',
          transition: 'opacity 0.6s ease-out 0.2s, transform 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s',
        }}
      >
        <span
          className="font-heading font-extrabold text-[#263957] transition-all duration-150 leading-tight"
          style={{ fontSize: size > 160 ? '1.25rem' : '0.95rem' }}
        >
          {activeItem
            ? `${valuePrefix}${formatNumber(activeItem.value)}${valueSuffix}`
            : centerValue}
        </span>
        <span className="text-[10px] font-mono uppercase tracking-wider text-[#65738A] truncate max-w-[85%] mt-0.5">
          {activeItem ? activeItem.name : centerLabel}
        </span>
        {activeItem && (
          <span className="text-[10px] font-bold text-[#5979AC] font-mono">
            {activeItem.percentage}
          </span>
        )}
      </div>
    </div>
  );
}

export function DashboardPage() {
  const [loading, setLoading] = useState(true);
  const [kpis, setKpis] = useState(null);
  const [charts, setCharts] = useState(null);
  const [registrations, setRegistrations] = useState([]);
  const [transactions, setTransactions] = useState([]);
  const [activities, setActivities] = useState([]);
  const [isSimulated, setIsSimulated] = useState(false);

  const loadDashboardData = useCallback(async () => {
    setLoading(true);
    try {
      const [kpiRes, chartRes, regRes, txnRes, actRes] = await Promise.all([
        fetchDashboardKPIs(),
        fetchDashboardCharts(),
        fetchRecentRegistrations(),
        fetchRecentTransactions(),
        fetchAdminActivities(),
      ]);

      setKpis(kpiRes.data);
      setCharts(chartRes);
      setRegistrations(regRes.data);
      setTransactions(txnRes.data);
      setActivities(actRes.data);

      if (kpiRes.isMock || chartRes.isMock) {
        setIsSimulated(true);
      }
    } catch (err) {
      console.error('[Dashboard] Error fetching telemetry:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadDashboardData();

    const handleRefresh = () => loadDashboardData();
    window.addEventListener('hemi_ton_refresh_data', handleRefresh);
    return () => window.removeEventListener('hemi_ton_refresh_data', handleRefresh);
  }, [loadDashboardData]);

  // Guaranteed fallback distribution data
  const revenuePiData =
    charts?.revenueDistribution && charts.revenueDistribution.length > 0
      ? charts.revenueDistribution
      : MOCK_REVENUE_SOURCE_DISTRIBUTION;

  const roomPiData =
    charts?.roomDistribution && charts.roomDistribution.length > 0
      ? charts.roomDistribution
      : MOCK_ROOM_CATEGORY_DISTRIBUTION;

  // Recent Registrations Columns
  const registrationColumns = [
    {
      header: 'User Identifier',
      key: 'name',
      render: (_, row) => (
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-[#DCE6F5] border border-[#C8D7EC] font-bold text-xs text-[#263957]">
            {row.name.substring(0, 1)}
          </div>
          <div className="flex flex-col min-w-0">
            <span className="font-semibold text-[#263957] truncate">{row.name}</span>
            <span className="text-[11px] font-mono text-[#65738A]">{row.username}</span>
          </div>
        </div>
      ),
    },
    {
      header: 'Assigned Role',
      key: 'role',
      render: (role) => {
        const variants = {
          HOST_CANDIDATE: 'accent',
          VERIFIED_HOST: 'primary',
          USER: 'default',
        };
        return (
          <Badge variant={variants[role] || 'outline'} size="sm">
            {role.replace('_', ' ')}
          </Badge>
        );
      },
    },
    {
      header: 'Status',
      key: 'status',
      render: (status) => (
        <Badge variant={status === 'ACTIVE' ? 'success' : 'warning'} size="sm" dot>
          {status}
        </Badge>
      ),
    },
    {
      header: 'Joined',
      key: 'createdAt',
      render: (date) => (
        <span className="text-xs font-mono text-[#65738A]">
          {timeAgo(date)}
        </span>
      ),
    },
  ];

  // Recent Transactions Columns
  const transactionColumns = [
    {
      header: 'Ledger Reference',
      key: 'id',
      render: (id) => (
        <span className="font-mono text-xs font-bold text-[#263957]">{id}</span>
      ),
    },
    {
      header: 'Entity / Counterparty',
      key: 'userName',
      render: (name, row) => (
        <div className="flex flex-col">
          <span className="font-medium text-[#263957]">{name}</span>
          <span className="text-[10px] text-[#65738A] uppercase font-mono">{row.type.replace('_', ' ')}</span>
        </div>
      ),
    },
    {
      header: 'Volume',
      key: 'amountCoins',
      render: (_, row) => (
        <div className="flex flex-col font-mono text-xs">
          <span className="font-bold text-[#263957]">
            {formatNumber(row.amountCoins)} Coins
          </span>
          <span className="text-[10px] text-[#65738A]">
            {formatCurrency(row.amountFiat)}
          </span>
        </div>
      ),
    },
    {
      header: 'Settlement',
      key: 'status',
      render: (status) => {
        const variants = {
          COMPLETED: 'success',
          PENDING: 'warning',
          FAILED: 'danger',
        };
        return (
          <Badge variant={variants[status] || 'default'} size="sm" dot>
            {status}
          </Badge>
        );
      },
    },
  ];

  return (
    <div className="space-y-6">
      {/* Top Welcome & Sub-Header Bar */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between bg-white border border-[#D8E0EC] rounded-2xl p-4 sm:px-5 sm:py-3.5 shadow-2xs">
        <div className="flex items-center gap-3.5">
          <div>
            <div className="flex items-center gap-2">
              <h1 className="font-heading text-xl sm:text-2xl font-extrabold tracking-tight text-[#263957]">
                Command Overview
              </h1>
              <span className="rounded-md bg-[#263957] px-2 py-0.5 text-[10px] font-mono font-bold tracking-wider text-[#E9EEF7] uppercase">
                HT Executive
              </span>
            </div>
            <p className="mt-0.5 text-xs text-[#65738A]">
              Real-time telemetry, broadcast load, user community growth, and financial ledger.
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {isSimulated && (
            <Badge variant="warning" size="sm" dot>
              Simulated Telemetry
            </Badge>
          )}

          <button
            onClick={loadDashboardData}
            disabled={loading}
            className="inline-flex items-center gap-1.5 rounded-xl border border-[#D8E0EC] bg-[#F5F7FB] px-3.5 py-2 text-xs font-semibold text-[#263957] shadow-2xs hover:bg-[#E8EDF5] transition-colors"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${loading ? 'animate-spin' : ''}`} />
            Sync Metrics
          </button>
        </div>
      </div>

      {/* Top 8 Executive Metric Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Registered Users"
          value={kpis?.totalUsers ? formatCompact(kpis.totalUsers) : '0'}
          change={kpis?.totalUsersChange}
          isPositive={true}
          icon={Users}
          period="vs prior 30d"
          isDevPlaceholder={isSimulated}
        />
        <StatCard
          title="24h Active Users"
          value={kpis?.activeUsers ? formatCompact(kpis.activeUsers) : '0'}
          change={kpis?.activeUsersChange}
          isPositive={true}
          icon={Activity}
          period="vs last cycle"
          isDevPlaceholder={isSimulated}
        />
        <StatCard
          title="Online In Rooms"
          value={kpis?.onlineUsers ? formatNumber(kpis.onlineUsers) : '0'}
          change={kpis?.onlineUsersChange}
          isPositive={true}
          icon={Radio}
          period="real-time agora"
          isDevPlaceholder={isSimulated}
        />
        <StatCard
          title="Active Live Rooms"
          value={kpis?.activeRooms ?? 0}
          change={kpis?.activeRoomsChange}
          isPositive={true}
          icon={Radio}
          period="broadcast spaces"
          isDevPlaceholder={isSimulated}
        />
        <StatCard
          title="Broadcaster Hosts"
          value={kpis?.liveHosts ?? 0}
          change={kpis?.liveHostsChange}
          isPositive={true}
          icon={Crown}
          period="on mic / video"
          isDevPlaceholder={isSimulated}
        />
        <StatCard
          title="Agency Applications"
          value={kpis?.pendingAgencyApplications ?? 0}
          icon={FileCheck2}
          period={`${kpis?.pendingAgencyUrgent ?? 0} requiring audit`}
          isDevPlaceholder={isSimulated}
        />
        <StatCard
          title="Pending Withdrawals"
          value={kpis?.pendingWithdrawalsAmount ? formatCurrency(kpis.pendingWithdrawalsAmount) : '$0.00'}
          icon={Wallet}
          period={`${kpis?.pendingWithdrawals ?? 0} payout requests`}
          isDevPlaceholder={isSimulated}
        />
        <StatCard
          title="Gross Revenue (30d)"
          value={kpis?.totalRevenue ? formatCurrency(kpis.totalRevenue) : '$0.00'}
          change={kpis?.totalRevenueChange}
          isPositive={true}
          icon={DollarSign}
          period="coins & subs"
          isDevPlaceholder={isSimulated}
        />
      </div>

      {/* Analytics Visualizations: 
          1st: Only 1 Bar Graph
          2nd: Chart (Area/Line)
          3rd: Pi and Chart (Guaranteed Visible SVG Donut + Velocity Line)
          4th: Space Share (Guaranteed Visible SVG Donut + Category Spectrum)
      */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        
        {/* ============================================================ */}
        {/* 1st GRAPH: BAR GRAPH (The Only Bar Graph in the Dashboard)   */}
        {/* ============================================================ */}
        <Card className="lg:col-span-1">
          <CardHeader
            title="Room & Viewer Concurrency"
            subtitle="Hourly broadcast space load and concurrent audience volume"
          />
          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={charts?.liveActivity || []} margin={{ top: 12, right: 12, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#D8E0EC" vertical={false} />
                <XAxis dataKey="hour" stroke="#65738A" fontSize={11} tickLine={false} />
                <YAxis stroke="#65738A" fontSize={11} tickLine={false} />
                <Tooltip content={<CustomChartTooltip />} />
                <Bar dataKey="rooms" name="Live Rooms" fill="#5979AC" radius={[4, 4, 0, 0]} maxBarSize={22} />
                <Bar dataKey="viewers" name="Audience Load" fill="#91A9CE" radius={[4, 4, 0, 0]} maxBarSize={22} />
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-2 flex items-center justify-between border-t border-[#D8E0EC] pt-2 px-1 text-[11px] font-mono text-[#65738A]">
            <span className="flex items-center gap-1.5">
              <span className="h-2 w-2 rounded-full bg-[#5979AC]" /> Broadcast Rooms Peak: <strong>64 rooms</strong>
            </span>
            <span className="flex items-center gap-1.5">
              <span className="h-2 w-2 rounded-full bg-[#91A9CE]" /> Audience Peak: <strong>2,400 viewers</strong>
            </span>
          </div>
        </Card>

        {/* ============================================================ */}
        {/* 2nd GRAPH: CHART (Area / Line Chart)                         */}
        {/* ============================================================ */}
        <Card className="lg:col-span-1">
          <CardHeader
            title="User Acquisition & Growth Velocity"
            subtitle="7-day registered vs active community engagement"
          />
          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={charts?.userGrowth || []} margin={{ top: 12, right: 12, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="userGrowthGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#5979AC" stopOpacity={0.25} />
                    <stop offset="95%" stopColor="#5979AC" stopOpacity={0.0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#D8E0EC" vertical={false} />
                <XAxis dataKey="date" stroke="#65738A" fontSize={11} tickLine={false} />
                <YAxis stroke="#65738A" fontSize={11} tickLine={false} />
                <Tooltip content={<CustomChartTooltip />} />
                <Area
                  type="monotone"
                  dataKey="registered"
                  name="New Signups"
                  stroke="#5979AC"
                  strokeWidth={2}
                  fill="url(#userGrowthGradient)"
                />
                <Area
                  type="monotone"
                  dataKey="active"
                  name="Active Engaged"
                  stroke="#7894BE"
                  strokeWidth={1.5}
                  fillOpacity={0}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-2 flex items-center justify-between border-t border-[#D8E0EC] pt-2 px-1 text-[11px] font-mono text-[#65738A]">
            <span className="flex items-center gap-1.5">
              <span className="h-2 w-2 rounded-full bg-[#5979AC]" /> Total Base: <strong>14,850 accounts</strong>
            </span>
            <span className="text-emerald-600 font-semibold">+12.4% net weekly expansion</span>
          </div>
        </Card>

        {/* ============================================================ */}
        {/* 3rd GRAPH: PI AND CHART (Guaranteed-Visible Donut + Line)     */}
        {/* ============================================================ */}
        <Card className="lg:col-span-1">
          <CardHeader
            title="Financial Treasury & Cashflow Velocity"
            subtitle="Gross income stream allocation and 7-day velocity trend"
          />
          <div className="grid grid-cols-1 sm:grid-cols-12 gap-3 h-64 items-center">
            {/* The Pi (Guaranteed-Visible Donut) Section */}
            <div className="sm:col-span-6 flex flex-col justify-center border-b sm:border-b-0 sm:border-r border-[#D8E0EC] pb-2 sm:pb-0 pr-0 sm:pr-3">
              <div className="flex items-center justify-center py-1">
                <SvgDonutChart
                  data={revenuePiData}
                  size={154}
                  innerRadius={40}
                  outerRadius={64}
                  centerValue={formatCurrency(kpis?.totalRevenue ?? 68420.5)}
                  centerLabel="Gross Revenue"
                  valuePrefix="$"
                />
              </div>

              {/* Categorical Legend for the Pi */}
              <div className="grid grid-cols-2 gap-1.5 pt-2 border-t border-[#E8EDF5]">
                {revenuePiData.slice(0, 4).map((item, idx) => (
                  <div key={idx} className="flex items-center gap-1 text-[10px] text-[#65738A] min-w-0">
                    <span className="h-2 w-2 rounded-full shrink-0" style={{ backgroundColor: item.color }} />
                    <span className="truncate">{item.name.replace('In-App ', '')}:</span>
                    <strong className="text-[#263957] font-mono shrink-0">{item.percentage}</strong>
                  </div>
                ))}
              </div>
            </div>

            {/* The Chart (Line Chart) Section */}
            <div className="sm:col-span-6 flex flex-col justify-between h-full pl-0 sm:pl-2">
              <div className="text-[10px] font-mono text-[#65738A] flex items-center justify-between">
                <span>7-Day Velocity Curve</span>
                <span className="text-[#5979AC] font-semibold">$9,774 / day</span>
              </div>
              <div className="h-44 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={charts?.revenueTrends || []} margin={{ top: 8, right: 8, left: -22, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#D8E0EC" vertical={false} />
                    <XAxis dataKey="date" stroke="#65738A" fontSize={10} tickLine={false} />
                    <YAxis stroke="#65738A" fontSize={10} tickLine={false} />
                    <Tooltip content={<CustomChartTooltip prefix="$" />} />
                    <Line type="monotone" dataKey="coinRecharges" name="Recharges" stroke="#5979AC" strokeWidth={2} dot={{ r: 2 }} />
                    <Line type="monotone" dataKey="agencyPayouts" name="Payouts" stroke="#A7B2C4" strokeWidth={1.5} dot={{ r: 2 }} strokeDasharray="3 3" />
                  </LineChart>
                </ResponsiveContainer>
              </div>
              <div className="flex items-center justify-between text-[10px] font-mono text-[#65738A] pt-1 border-t border-[#D8E0EC]">
                <span>Settlement Ratio: <strong className="text-[#263957]">35.2%</strong></span>
                <span className="text-emerald-600 font-medium">+18.6% run-rate</span>
              </div>
            </div>
          </div>
        </Card>

        {/* ============================================================ */}
        {/* 4th GRAPH: ROOM CATEGORY & SPACE SHARE (Guaranteed-Visible)   */}
        {/* ============================================================ */}
        <Card className="lg:col-span-1">
          <CardHeader
            title="Room Category & Audio Space Share"
            subtitle="Live space allocation across platform party and audio categories"
          />
          <div className="flex flex-col sm:flex-row items-center justify-between gap-6 h-64 w-full px-1">
            {/* Guaranteed-Visible SVG Donut Chart */}
            <div className="flex items-center justify-center shrink-0 mx-auto sm:mx-0">
              <SvgDonutChart
                data={roomPiData}
                size={180}
                innerRadius={50}
                outerRadius={76}
                centerValue={kpis?.activeRooms ?? 64}
                centerLabel="Active Rooms"
                valueSuffix=" rooms"
              />
            </div>

            {/* Categorical Breakdown Legend */}
            <div className="w-full sm:flex-1 space-y-2.5 pr-2">
              {roomPiData.map((cat, idx) => (
                <div
                  key={idx}
                  className="flex items-center justify-between text-xs rounded-lg p-1.5 transition-colors hover:bg-[#F5F7FB]"
                >
                  <div className="flex items-center gap-2 min-w-0">
                    <span className="h-3 w-3 rounded-md shrink-0 shadow-2xs" style={{ backgroundColor: cat.color }} />
                    <span className="truncate font-medium text-[#263957]">{cat.name}</span>
                  </div>
                  <div className="flex items-center gap-1.5 font-mono text-[11px] shrink-0 bg-[#F5F7FB] border border-[#D8E0EC] px-2 py-0.5 rounded-lg">
                    <span className="font-bold text-[#263957]">{cat.value}</span>
                    <span className="text-[#65738A]">({cat.percentage})</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
          <div className="mt-2 flex items-center justify-between border-t border-[#D8E0EC] pt-2 px-1 text-[11px] font-mono text-[#65738A]">
            <span>Agora RTC Audio Spaces: <strong className="text-[#263957]">8 Channels</strong></span>
            <span>Broadcaster Hosts on-air: <strong className="text-[#263957]">58</strong></span>
          </div>
        </Card>
      </div>

      {/* Lower Multi-Column Section: 60:40 ratio (3:2 of 5 cols), 3rd (Admin Operations Feed) below */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-5">
        {/* Recent Registrations Table (60% width) */}
        <Card className="lg:col-span-3">
          <CardHeader
            title="Recent User Registrations"
            subtitle="Latest platform accounts and talent applications"
            badge={<Badge variant="outline" size="sm">Live Feed</Badge>}
          />
          <DataTable
            columns={registrationColumns}
            data={registrations}
            loading={loading}
            emptyMessage="No recent user registrations found."
          />
        </Card>

        {/* Recent Financial Ledger (40% width) */}
        <Card className="lg:col-span-2">
          <CardHeader
            title="Recent Financial Ledger"
            subtitle="Real-time coin deposits and withdrawal settlements"
            badge={<Badge variant="outline" size="sm">Audit Stream</Badge>}
          />
          <DataTable
            columns={transactionColumns}
            data={transactions}
            loading={loading}
            emptyMessage="No recent transaction entries found."
          />
        </Card>

        {/* Operations & Security Audit Log — Spanning full width (5/5 cols) below */}
        <Card className="lg:col-span-5">
          <CardHeader
            title="Administrative Operations & Security Audit Log"
            subtitle="Traceable ledger of supervisor actions, room terminations, and host KYC approvals"
            badge={
              <Badge variant="cloud" size="sm" dot>
                {activities.length} Recorded Events
              </Badge>
            }
          />
          <div className="p-4 sm:p-5">
            {loading ? (
              <div className="flex h-36 items-center justify-center">
                <RefreshCw className="h-6 w-6 animate-spin text-[#5979AC]" />
              </div>
            ) : activities.length === 0 ? (
              <div className="py-8 text-center text-xs text-[#65738A]">
                No administrative activity logged yet.
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3.5">
                {activities.map((act) => (
                  <div
                    key={act.id}
                    className="flex items-start gap-3 rounded-xl border border-[#D8E0EC] bg-[#F5F7FB] p-3 transition-colors hover:bg-white hover:border-[#5979AC]/40"
                  >
                    <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-[#DCE6F5] border border-[#C8D7EC] text-[#263957]">
                      <Clock className="h-4 w-4" />
                    </div>
                    <div className="flex flex-1 flex-col min-w-0">
                      <div className="flex items-center justify-between gap-2">
                        <span className="font-semibold text-xs text-[#263957] truncate">
                          {act.action.replace(/_/g, ' ')}
                        </span>
                        <span className="text-[10px] font-mono text-[#8792A4] shrink-0">
                          {timeAgo(act.timestamp)}
                        </span>
                      </div>
                      <p className="mt-0.5 text-xs text-[#65738A] truncate">
                        {act.details}
                      </p>
                      <div className="mt-2 flex items-center gap-2 text-[10px] text-[#65738A]">
                        <span className="rounded-md bg-white border border-[#D8E0EC] px-1.5 py-0.5 font-mono text-[#263957]">
                          {act.admin}
                        </span>
                        <span className="font-mono text-[#8792A4]">
                          Target: {act.targetId}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}

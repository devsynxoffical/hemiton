// ============================================================
// Hemi Ton Admin Portal — Unified Rooms Management Page (JSX)
// 2026 Developer Specification Alignment
// ============================================================

import React, { useState, useMemo, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import {
  Radio, Search, Eye, StopCircle, Users, Gift, Play, Pause, AlertTriangle, MessageSquare, Flame, Pin, CheckCircle
} from 'lucide-react';
import { DataTable } from '../../components/tables/DataTable';
import { StatusBadge, Badge } from '../../components/ui/Badge';
import { Card } from '../../components/ui/Card';
import { Input } from '../../components/ui/Input';
import { ConfirmDialog } from '../../components/ui/Modal';
import { Button } from '../../components/ui/Button';
import { formatNumber } from '../../utils/format';
import { useAuditLog } from '../../context/AuditLogContext';
import { getLiveRooms, endStream } from '../../services/modules/liveRooms.service';
import { CountrySelect } from '../../components/ui/CountrySelect';
import { CountryFlag } from '../../components/ui/CountryFlag';
import { ALL_COUNTRIES, getCountryShortName } from '../../constants/countries.data';
import { AnimatedPiGraph } from '../../components/ui/AnimatedPiGraph';
import { BarChart, Bar, ResponsiveContainer, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import { formatCompact } from '../../utils/format';

const CATEGORIES = ['All', 'PK Battle', 'Entertainment', 'Games', 'Talk Show'];
const STATUSES = ['all', 'active', 'closed', 'paused'];

const AVAILABLE_COUNTRIES = ALL_COUNTRIES.filter((c) => c.code !== 'All');

export function LiveRoomsPage() {
  const navigate = useNavigate();
  const { logAdminAction } = useAuditLog();
  const [searchParams, setSearchParams] = useSearchParams();
  const typeParam = searchParams.get('type') || 'live';

  const [rooms, setRooms] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [countryFilter, setCountryFilter] = useState('All');
  const [closeModal, setCloseModal] = useState({ open: false, room: null });
  const [pauseModal, setPauseModal] = useState({ open: false, room: null });
  const [isProcessing, setIsProcessing] = useState(false);
  const [feedback, setFeedback] = useState(null);

  // Load rooms from backend with live auto-refresh
  useEffect(() => {
    let isMounted = true;
    const loadRooms = (isInitial = false) => {
      if (isInitial) setIsLoading(true);
      getLiveRooms()
        .then((data) => {
          if (isMounted) setRooms(data || []);
        })
        .catch((err) => {
          console.error('Failed to load rooms:', err);
          if (isMounted && isInitial) setRooms([]);
        })
        .finally(() => {
          if (isMounted && isInitial) setIsLoading(false);
        });
    };

    loadRooms(true);

    const interval = setInterval(() => {
      loadRooms(false);
    }, 3500);

    return () => {
      isMounted = false;
      clearInterval(interval);
    };
  }, []);

  const showFeedback = (msg) => {
    setFeedback(msg);
    setTimeout(() => setFeedback(null), 3500);
  };

  const activeTab = typeParam === 'party' ? 'party' : 'live';

  const filtered = useMemo(() => {
    return rooms.filter((r) => {
      const matchType = r.roomType === activeTab;
      const matchStatus = statusFilter === 'all' || r.status === statusFilter;
      const matchCat = categoryFilter === 'All' || r.category === categoryFilter;
      const matchCountry = countryFilter === 'All' || r.country === countryFilter;

      const q = search.toLowerCase();
      const matchSearch =
        !q ||
        r.id.toLowerCase().includes(q) ||
        r.title.toLowerCase().includes(q) ||
        r.hostName.toLowerCase().includes(q) ||
        r.hostUsername.toLowerCase().includes(q);

      return matchType && matchStatus && matchCat && matchCountry && matchSearch;
    });
  }, [rooms, activeTab, statusFilter, categoryFilter, countryFilter, search]);

  const activeRooms = filtered.filter((r) => r.status === 'active');
  const totalViewers = activeRooms.reduce((sum, r) => sum + (r.viewers || 0), 0);
  const totalGifts = activeRooms.reduce((sum, r) => sum + (r.giftsReceived || 0), 0);

  const handleForceClose = async () => {
    if (!closeModal.room) return;
    setIsProcessing(true);
    try {
      await endStream(closeModal.room.id, 'Force closed by administration');

      await logAdminAction({
        action: 'ROOM_FORCE_CLOSED',
        module: 'Live Rooms',
        targetType: 'live_room',
        targetId: closeModal.room.id,
        targetName: closeModal.room.title,
        reason: 'Violated streaming community terms',
        riskLevel: 'HIGH',
      });

      setRooms((prev) =>
        prev.map((r) =>
          r.id === closeModal.room.id ? { ...r, status: 'ended', viewers: 0 } : r
        )
      );
      showFeedback(`Room ${closeModal.room.id} has been shut down.`);
    } finally {
      setIsProcessing(false);
      setCloseModal({ open: false, room: null });
    }
  };

  const handleTogglePause = async () => {
    if (!pauseModal.room) return;
    setIsProcessing(true);
    const isPaused = pauseModal.room.status === 'paused';
    const newStatus = isPaused ? 'active' : 'paused';
    try {
      await logAdminAction({
        action: isPaused ? 'ROOM_RESUMED' : 'ROOM_PAUSED',
        module: 'Live Rooms',
        targetType: 'live_room',
        targetId: pauseModal.room.id,
        targetName: pauseModal.room.title,
        reason: `Room ${isPaused ? 'resumed' : 'paused'} by administrator`,
        riskLevel: 'MEDIUM',
      });

      setRooms((prev) =>
        prev.map((r) =>
          r.id === pauseModal.room.id ? { ...r, status: newStatus } : r
        )
      );
      showFeedback(`Room status updated to ${newStatus}.`);
    } finally {
      setIsProcessing(false);
      setPauseModal({ open: false, room: null });
    }
  };

  const columns = [
    {
      key: 'room',
      header: 'Room',
      render: (row) => (
        <div className="max-w-xs">
          <p className="font-bold text-white text-sm leading-tight truncate">{row.title}</p>
          <div className="flex flex-wrap items-center gap-1.5 mt-1">
            <Badge variant="default" className="text-[10px] font-mono">{row.id}</Badge>
            <Badge variant="purple" className="text-[10px]">{row.category}</Badge>
            <Badge variant="info" className="text-[10px] font-semibold flex items-center gap-1.5 px-2 py-0.5">
              <CountryFlag code={row.country} className="w-3.5 h-2.5 object-cover rounded-sm shrink-0" />
              <span>{getCountryShortName(row.country)}</span>
            </Badge>
          </div>
        </div>
      ),
    },
    {
      key: 'host',
      header: 'Host Profile',
      render: (row) => (
        <div>
          <p className="text-sm text-white font-semibold">{row.hostName}</p>
          <p className="text-xs text-slate-400">{row.hostUsername}</p>
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (row) => <StatusBadge status={row.status} />,
    },
    {
      key: 'viewers',
      header: 'Audience / Listeners',
      render: (row) => (
        <div className="flex items-center gap-1.5 text-sm">
          <Users className="h-3.5 w-3.5 text-sky-400" />
          <span className="text-sky-300 font-semibold">{formatNumber(row.viewers)}</span>
          <span className="text-[10px] text-slate-500">/ peak {formatNumber(row.peakViewers)}</span>
        </div>
      ),
    },
    {
      key: 'gifts',
      header: 'Coins Volume',
      render: (row) => (
        <div className="flex items-center gap-1.5 text-sm text-gold-400 font-bold">
          <Flame className="h-3.5 w-3.5 text-gold-500" />
          {formatNumber(row.giftsReceived)}
        </div>
      ),
    },
    {
      key: 'duration',
      header: 'Runtime',
      render: (row) => <span className="text-xs text-slate-300 font-mono">{row.duration}</span>,
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (row) => (
        <div className="flex items-center gap-1">
          <button
            title="Inspect Details"
            onClick={() => navigate(`/admin/live-rooms/${row.id}`)}
            className="p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-slate-700 transition-colors"
          >
            <Eye className="h-3.5 w-3.5" />
          </button>
          <button
            title="Pin Room to Top"
            onClick={() => navigate('/admin/room-pin-management')}
            className="p-1.5 rounded-lg text-gold-400 hover:text-gold-300 hover:bg-slate-700 transition-colors"
          >
            <Pin className="h-3.5 w-3.5 fill-gold-400/20" />
          </button>
          {row.status === 'active' && (
            <>
              <button
                title="Pause Stream"
                onClick={() => setPauseModal({ open: true, room: row })}
                className="p-1.5 rounded-lg text-slate-400 hover:text-amber-400 hover:bg-slate-700 transition-colors"
              >
                <Pause className="h-3.5 w-3.5" />
              </button>
              <button
                title="Force Close Stream"
                onClick={() => setCloseModal({ open: true, room: row })}
                className="p-1.5 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700 transition-colors"
              >
                <StopCircle className="h-3.5 w-3.5" />
              </button>
            </>
          )}
          {row.status === 'paused' && (
            <button
              title="Resume Stream"
              onClick={() => setPauseModal({ open: true, room: row })}
              className="p-1.5 rounded-lg text-slate-400 hover:text-emerald-400 hover:bg-slate-700 transition-colors"
            >
              <Play className="h-3.5 w-3.5" />
            </button>
          )}
        </div>
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-6">
      {/* Tab Header Selector */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            <Radio className="h-6 w-6 text-red-500 animate-pulse" />
            Unified Rooms & Party Portal
          </h1>
          <p className="text-sm text-slate-400 mt-0.5">
            Oversight and streaming moderation for video broadcasts and audio rooms.
          </p>
        </div>

        {/* Tab Buttons & Pin Management Shortcut */}
        <div className="flex flex-wrap items-center gap-3">
          <Button
            variant="outline"
            size="sm"
            onClick={() => navigate('/admin/room-pin-management')}
            className="border-gold-500/30 text-gold-400 hover:bg-gold-500/10"
          >
            <Pin className="h-4 w-4 mr-1.5 fill-gold-400/20" /> Room Pin Management
          </Button>

          <div className="flex bg-slate-900 rounded-xl p-1 border border-slate-800">
            <button
              onClick={() => setSearchParams({ type: 'live' })}
              className={`px-4 py-1.5 text-xs font-bold rounded-lg transition-colors ${activeTab === 'live' ? 'bg-red-600 text-white shadow-lg shadow-red-600/10' : 'text-slate-400 hover:text-white'
                }`}
            >
              Live Video Rooms
            </button>
            <button
              onClick={() => setSearchParams({ type: 'party' })}
              className={`px-4 py-1.5 text-xs font-bold rounded-lg transition-colors ${activeTab === 'party' ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-600/10' : 'text-slate-400 hover:text-white'
                }`}
            >
              Social Audio / Party Rooms
            </button>
          </div>
        </div>
      </div>

      {feedback && (
        <div className="p-3.5 rounded-xl bg-emerald-500/20 border border-emerald-500/40 text-emerald-400 text-xs font-medium flex items-center gap-2">
          <CheckCircle className="h-4 w-4" />
          <span>{feedback}</span>
        </div>
      )}

      {/* Summary Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        {[
          { label: `Active ${activeTab === 'live' ? 'Video' : 'Audio'} Rooms`, value: activeRooms.length, color: 'text-[#D4AF37]' },
          { label: `Total Filtered`, value: filtered.length, color: 'text-white' },
          { label: 'Active Listeners/Viewers', value: formatNumber(totalViewers), color: 'text-sky-400' },
          { label: 'Gifts Flow (Coins)', value: formatNumber(totalGifts), color: 'text-emerald-400' }
        ].map((s) => (
          <Card key={s.label} className="p-4 text-center border-[#182337] bg-[#0E1524]">
            <p className={`text-2xl font-black tracking-tight ${s.color}`}>{s.value}</p>
            <p className="text-[10px] uppercase font-bold text-slate-400 mt-1">{s.label}</p>
          </Card>
        ))}
      </div>

      {/* Visualizers: Animated Pi Graph & Category Bar Chart */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
        <div className="lg:col-span-5">
          <AnimatedPiGraph
            title="Room Category Distribution"
            subtitle="Active broadcast allocation by genre"
            data={[
              { name: 'PK Battles', value: 36, percent: '36%', color: '#F43F5E', subtext: 'Host contests' },
              { name: 'Social Audio Party', value: 28, percent: '28%', color: '#38BDF8', subtext: 'Multi-speaker lounges' },
              { name: 'Games & Trivia', value: 20, percent: '20%', color: '#D4AF37', subtext: 'Interactive mini-games' },
              { name: 'Acoustic / Talk Show', value: 16, percent: '16%', color: '#A855F7', subtext: 'Music and chat' },
            ]}
            centerValue={`${filtered.length} Spaces`}
            centerLabel="Live Rooms"
            icon={Radio}
            height={200}
            innerRadius={52}
            outerRadius={76}
            className="h-full"
          />
        </div>

        <div className="lg:col-span-7 rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-5 shadow-xl flex flex-col justify-between">
          <div className="flex items-center justify-between pb-3 border-b border-[#182337] mb-3">
            <div>
              <h3 className="text-sm font-bold text-white tracking-wide">Audience Concurrency by Category</h3>
              <p className="text-xs text-slate-400 mt-0.5">Real-time listeners across room genres</p>
            </div>
            <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-sky-500/10 text-sky-400 border border-sky-500/20">
              Live Audience
            </span>
          </div>

          <div className="h-52 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                data={[
                  { category: 'PK Battle', viewers: 48200 },
                  { category: 'Social Audio', viewers: 36700 },
                  { category: 'Games', viewers: 29100 },
                  { category: 'Talk Show', viewers: 22400 },
                  { category: 'Educational', viewers: 18900 },
                ]}
                margin={{ top: 5, right: 10, bottom: 0, left: -16 }}
              >
                <CartesianGrid strokeDasharray="3 3" stroke="#182337" vertical={false} />
                <XAxis dataKey="category" tick={{ fill: '#64748b', fontSize: 11 }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fill: '#64748b', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={formatCompact} />
                <Tooltip
                  content={({ active, payload, label }) => {
                    if (active && payload && payload.length) {
                      return (
                        <div className="rounded-xl border border-[#1E2B45] bg-[#0A101C]/95 px-3 py-2 shadow-2xl text-xs">
                          <p className="text-slate-400 font-medium mb-1">{label}</p>
                          <p className="font-bold text-sky-400">{formatCompact(payload[0].value)} Listeners</p>
                        </div>
                      );
                    }
                    return null;
                  }}
                />
                <Bar dataKey="viewers" fill="#2563EB" radius={[4, 4, 0, 0]} maxBarSize={36} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Filter and Search controls */}
      <Card className="p-4 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <Input
          placeholder="Search by Room ID, title, host..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          leftIcon={Search}
          containerClassName="max-w-md w-full"
        />

        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="text-xs text-slate-500 font-bold">Status:</span>
            {STATUSES.map((s) => (
              <button
                key={s}
                onClick={() => setStatusFilter(s)}
                className={`px-2.5 py-1 rounded text-xs font-semibold uppercase border transition-colors ${statusFilter === s
                    ? 'bg-red-500/20 border-red-500/50 text-red-400'
                    : 'bg-slate-800 border-slate-700 text-slate-400 hover:text-white'
                  }`}
              >
                {s}
              </button>
            ))}
          </div>

          <div className="flex items-center gap-1.5">
            <span className="text-xs text-slate-500 font-bold">Category:</span>
            {CATEGORIES.map((c) => (
              <button
                key={c}
                onClick={() => setCategoryFilter(c)}
                className={`px-2.5 py-1 rounded text-xs font-semibold border transition-colors ${categoryFilter === c
                    ? 'bg-indigo-500/20 border-indigo-500/50 text-indigo-400'
                    : 'bg-slate-800 border-slate-700 text-slate-400 hover:text-white'
                  }`}
              >
                {c}
              </button>
            ))}
          </div>

          <div className="flex items-center gap-1.5">
            <span className="text-xs text-slate-500 font-bold">Country:</span>
            <CountrySelect
              value={countryFilter}
              onChange={(code) => setCountryFilter(code)}
            />
          </div>
        </div>
      </Card>

      {/* Table */}
      <DataTable
        columns={columns}
        data={filtered}
        isLoading={isLoading}
        emptyTitle={`No ${activeTab === 'live' ? 'Live' : 'Party'} Rooms Found`}
        emptyDescription="Change your search queries or category filters to locate other active streams."
        pagination={{ page: 1, totalPages: 1, total: filtered.length }}
      />

      {/* Force Close Confirmation Dialog */}
      <ConfirmDialog
        isOpen={closeModal.open}
        onClose={() => setCloseModal({ open: false, room: null })}
        onConfirm={handleForceClose}
        title="Force Close Stream"
        description={`Are you sure you want to shut down room "${closeModal.room?.title}"? The stream will be terminated immediately.`}
        confirmLabel="Shut Down Room"
        confirmVariant="danger"
        isLoading={isProcessing}
      />

      {/* Pause Confirmation Dialog */}
      <ConfirmDialog
        isOpen={pauseModal.open}
        onClose={() => setPauseModal({ open: false, room: null })}
        onConfirm={handleTogglePause}
        title={pauseModal.room?.status === 'paused' ? 'Resume Stream' : 'Pause Stream'}
        description={`Are you sure you want to ${pauseModal.room?.status === 'paused' ? 'resume' : 'pause'} room "${pauseModal.room?.title}"?`}
        confirmLabel={pauseModal.room?.status === 'paused' ? 'Resume' : 'Pause'}
        confirmVariant={pauseModal.room?.status === 'paused' ? 'primary' : 'warning'}
        isLoading={isProcessing}
      />
    </div>
  );
}

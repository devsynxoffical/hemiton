// ============================================================
// Hemi Ton Admin Console — Creative Banner Studio (JSX)
// Luxury Obsidian & Metallic Gold Aesthetics · Interactive Mobile Simulator
// ============================================================

import React, { useState, useEffect, useMemo, useRef } from 'react';
import {
  Image as ImageIcon,
  Search,
  Plus,
  Calendar,
  Megaphone,
  Clock,
  AlertCircle,
  Globe,
  CheckCircle,
  Sparkles,
  Rocket,
  Swords,
  Gift,
  Trash2,
  Edit2,
  ExternalLink,
  Eye,
  RefreshCw,
  Upload,
  Layers,
  Link as LinkIcon,
  Tag,
  FileText,
  Sliders,
  Check,
  Smartphone,
  ChevronLeft,
  ChevronRight,
  TrendingUp,
  Radio,
  Flame,
  Award
} from 'lucide-react';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge, StatusBadge } from '../../components/ui/Badge';
import { DataTable } from '../../components/tables/DataTable';
import { Input } from '../../components/ui/Input';
import { Modal } from '../../components/ui/Modal';
import { Button } from '../../components/ui/Button';
import { useAuditLog } from '../../context/AuditLogContext';
import {
  getBannerStats,
  getBanners,
  createBanner,
  updateBanner,
  deleteBanner,
  uploadBannerMedia
} from '../../services/modules/banners.service';
import { GeographicInheritancePanel } from '../../components/ui/GeographicInheritancePanel';

// 4 Curated Hemi Ton Luxury Preset Templates
export const PRESET_BANNER_TEMPLATES = [
  {
    id: 'template_welcome',
    title: '👑 Hemi Ton Imperial Voice Gala 2026',
    subtitle: 'Experience spatial HD multi-speaker voice rooms and live acoustic stage',
    tag: 'SIGNATURE EVENT',
    tagColor: 'from-[#D4AF37] to-[#F5E5B8]',
    bgGradient: 'from-[#1A1505] via-[#120F04] to-[#0A0D14]',
    borderGradient: 'border-[#D4AF37]/50',
    icon: Sparkles,
    imageUrl: '/ht-banner.jpg',
    destinationUrl: 'hemiton://party/gala',
    placement: 'Home Carousel',
    priority: 10,
    isGlobal: true,
  },
  {
    id: 'template_vip',
    title: '💎 Imperial Noble VIP & Wealth Privileges',
    subtitle: 'Ascend to SVIP status with Dragon entrance effects and private party spaces',
    tag: 'ROYAL PRIVILEGE',
    tagColor: 'from-amber-400 to-yellow-600',
    bgGradient: 'from-[#0B1528] via-[#08101E] to-[#040810]',
    borderGradient: 'border-blue-500/40',
    icon: Award,
    imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=1200&h=400&q=80',
    destinationUrl: 'hemiton://store/vip',
    placement: 'Wallet Page',
    priority: 9,
    isGlobal: true,
  },
  {
    id: 'template_pk_live',
    title: '⚔️ Global PK Arena & Live Face-Off',
    subtitle: 'Duel rival creators, trigger room combo gifts and lead the weekly tournament',
    tag: 'LIVE ARENA',
    tagColor: 'from-rose-500 to-amber-500',
    bgGradient: 'from-[#240A0F] via-[#1A080C] to-[#0D0406]',
    borderGradient: 'border-rose-500/40',
    icon: Swords,
    imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=1200&h=400&q=80',
    destinationUrl: 'hemiton://pk/arena',
    placement: 'Events Page',
    priority: 8,
    isGlobal: true,
  },
  {
    id: 'template_diamond_summit',
    title: '🌟 Diamond Cashout & Agency Guild Summit',
    subtitle: 'Fast-track payouts, host tier bonuses & official talent agency revenue share',
    tag: 'CREATOR MONETIZATION',
    tagColor: 'from-emerald-400 to-teal-500',
    bgGradient: 'from-[#061C14] via-[#04140E] to-[#030B08]',
    borderGradient: 'border-emerald-500/40',
    icon: Gift,
    imageUrl: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=1200&h=400&q=80',
    destinationUrl: 'hemiton://agency/hub',
    placement: 'Discover Page',
    priority: 7,
    isGlobal: true,
  },
];

const PLACEMENT_OPTIONS = [
  'All Placements',
  'Home Carousel',
  'Discover Page',
  'Events Page',
  'Wallet Page',
  'Store Page'
];

// ─────────────────────────────────────────────────────────────
// Interactive iPhone 16 Pro Mobile Simulator Component
// ─────────────────────────────────────────────────────────────
function MobilePhoneSimulator({ banners = [], activeBannerId, onSelectBanner }) {
  const activeBanners = useMemo(() => {
    return banners.filter((b) => (b.status || 'ACTIVE') === 'ACTIVE');
  }, [banners]);

  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    if (activeBannerId) {
      const idx = activeBanners.findIndex((b) => b.id === activeBannerId);
      if (idx !== -1) setCurrentIndex(idx);
    }
  }, [activeBannerId, activeBanners]);

  useEffect(() => {
    if (activeBanners.length <= 1) return;
    const timer = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % activeBanners.length);
    }, 4500);
    return () => clearInterval(timer);
  }, [activeBanners.length]);

  const currentBanner = activeBanners[currentIndex] || activeBanners[0] || null;

  return (
    <div className="flex flex-col items-center">
      {/* Phone Hardware Shell */}
      <div className="relative w-[310px] sm:w-[340px] h-[640px] bg-[#000000] rounded-[50px] p-3 shadow-2xl shadow-black/90 border-[4px] border-[#222E46] ring-1 ring-[#D4AF37]/30 overflow-hidden flex flex-col justify-between">
        
        {/* Dynamic Island / Speaker Pill */}
        <div className="absolute top-4 left-1/2 -translate-x-1/2 w-28 h-6 bg-black rounded-full z-30 flex items-center justify-between px-2.5 border border-slate-800">
          <div className="h-2.5 w-2.5 rounded-full bg-[#182337]" />
          <div className="flex items-center gap-1">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-400 animate-pulse" />
            <span className="text-[9px] text-slate-400 font-mono">LIVE</span>
          </div>
        </div>

        {/* Status Bar */}
        <div className="relative z-20 flex items-center justify-between px-5 pt-2 text-[10px] font-semibold text-slate-300">
          <span>9:41</span>
          <div className="flex items-center gap-1.5">
            <span className="text-[9px]">5G</span>
            <div className="w-4 h-2 rounded-sm border border-slate-400 p-0.5">
              <div className="w-full h-full bg-emerald-400 rounded-2xs" />
            </div>
          </div>
        </div>

        {/* Screen Content */}
        <div className="relative z-10 flex-1 flex flex-col pt-5 overflow-hidden">
          
          {/* Mobile App Header */}
          <div className="flex items-center justify-between px-3 py-2 border-b border-white/5">
            <div className="flex items-center gap-2">
              <div className="h-7 w-7 rounded-lg bg-gradient-to-tr from-[#D4AF37] to-[#F5E5B8] p-0.5 flex items-center justify-center">
                <span className="text-black font-black text-xs">HT</span>
              </div>
              <span className="font-bold text-white text-xs tracking-tight font-serif">Hemi Ton</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 text-[9px] font-bold border border-emerald-500/30 flex items-center gap-1">
                <Radio className="h-2.5 w-2.5 animate-pulse" />
                <span>1.8K Rooms</span>
              </span>
            </div>
          </div>

          {/* Carousel Preview Area */}
          <div className="p-3">
            <div className="flex items-center justify-between mb-1.5">
              <span className="text-[10px] font-bold text-[#D4AF37] uppercase tracking-wider">
                Featured Spotlight
              </span>
              <span className="text-[10px] font-mono text-slate-400">
                {activeBanners.length > 0 ? `${currentIndex + 1} / ${activeBanners.length}` : '0 / 0'}
              </span>
            </div>

            {currentBanner ? (
              <div className="relative h-40 w-full rounded-2xl overflow-hidden shadow-xl border border-white/10 group bg-slate-900">
                <img
                  src={currentBanner.imageUrl || currentBanner.image}
                  alt={currentBanner.title || 'Spotlight'}
                  className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/30 to-transparent" />
                
                {/* Floating Tag */}
                <div className="absolute top-2.5 left-2.5 flex items-center gap-1">
                  <span className="px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wider bg-black/70 backdrop-blur-md text-[#D4AF37] border border-[#D4AF37]/40 shadow-sm">
                    {currentBanner.placement || 'Home Carousel'}
                  </span>
                  <span className="px-1.5 py-0.5 rounded text-[8px] font-mono bg-black/60 text-slate-300">
                    P{currentBanner.priority ?? 5}
                  </span>
                </div>

                {/* Banner Content Overlays */}
                <div className="absolute bottom-2.5 left-2.5 right-2.5">
                  <h4 className="text-white font-bold text-xs leading-snug line-clamp-1 drop-shadow-md">
                    {currentBanner.title || 'Hemi Ton Broadcast'}
                  </h4>
                  {currentBanner.subtitle && (
                    <p className="text-slate-300 text-[10px] line-clamp-1 mt-0.5 drop-shadow">
                      {currentBanner.subtitle}
                    </p>
                  )}
                  <div className="flex items-center justify-between mt-1.5 pt-1 border-t border-white/10">
                    <span className="text-[8px] font-mono text-[#D4AF37] truncate max-w-[140px]">
                      {currentBanner.linkUrl || currentBanner.destinationUrl || 'hemiton://party'}
                    </span>
                    <span className="px-2 py-0.5 rounded-full bg-gradient-to-r from-[#D4AF37] to-[#C49B2C] text-black text-[9px] font-black">
                      Open
                    </span>
                  </div>
                </div>

                {/* Carousel Controls */}
                {activeBanners.length > 1 && (
                  <>
                    <button
                      onClick={() => setCurrentIndex((prev) => (prev - 1 + activeBanners.length) % activeBanners.length)}
                      className="absolute left-1.5 top-1/2 -translate-y-1/2 p-1 rounded-full bg-black/50 hover:bg-black text-white/80 transition-colors"
                      aria-label="Previous Banner"
                    >
                      <ChevronLeft className="h-3 w-3" />
                    </button>
                    <button
                      onClick={() => setCurrentIndex((prev) => (prev + 1) % activeBanners.length)}
                      className="absolute right-1.5 top-1/2 -translate-y-1/2 p-1 rounded-full bg-black/50 hover:bg-black text-white/80 transition-colors"
                      aria-label="Next Banner"
                    >
                      <ChevronRight className="h-3 w-3" />
                    </button>
                  </>
                )}
              </div>
            ) : (
              <div className="h-40 w-full rounded-2xl border border-dashed border-slate-700 bg-slate-900/60 flex flex-col items-center justify-center text-slate-500 text-xs">
                <ImageIcon className="h-8 w-8 mb-1 text-slate-600" />
                <span>No active banners deployed</span>
              </div>
            )}

            {/* Pagination Dots */}
            {activeBanners.length > 1 && (
              <div className="flex items-center justify-center gap-1.5 mt-2">
                {activeBanners.map((b, idx) => (
                  <button
                    key={b.id || idx}
                    onClick={() => {
                      setCurrentIndex(idx);
                      if (onSelectBanner) onSelectBanner(b);
                    }}
                    className={`h-1.5 rounded-full transition-all ${
                      currentIndex === idx ? 'w-4 bg-[#D4AF37]' : 'w-1.5 bg-slate-700 hover:bg-slate-500'
                    }`}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Simulated App Quick Categories */}
          <div className="px-3 pt-2">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-2">
              Trending Voice Lounges
            </span>
            <div className="grid grid-cols-2 gap-2">
              <div className="p-2 rounded-xl bg-slate-900 border border-slate-800 flex items-center gap-2">
                <div className="h-7 w-7 rounded-lg bg-pink-500/20 text-pink-400 flex items-center justify-center text-xs">
                  🎙️
                </div>
                <div className="truncate">
                  <p className="text-[10px] font-bold text-white truncate">Arabian Nights</p>
                  <p className="text-[8px] text-slate-400">142 listening</p>
                </div>
              </div>
              <div className="p-2 rounded-xl bg-slate-900 border border-slate-800 flex items-center gap-2">
                <div className="h-7 w-7 rounded-lg bg-amber-500/20 text-amber-400 flex items-center justify-center text-xs">
                  ⚔️
                </div>
                <div className="truncate">
                  <p className="text-[10px] font-bold text-white truncate">PK Championship</p>
                  <p className="text-[8px] text-slate-400">389 listening</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Home Bar Indicator */}
        <div className="relative z-20 pb-2 flex justify-center">
          <div className="w-32 h-1 bg-slate-600 rounded-full" />
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Create Banner Modal
// ─────────────────────────────────────────────────────────────
function CreateBannerModal({ isOpen, onClose, onCreated, initialTemplate = null }) {
  const fileInputRef = useRef(null);
  const [activeTab, setActiveTab] = useState('custom'); // 'custom' or 'preset'
  const [formData, setFormData] = useState({
    title: '',
    subtitle: '',
    customText: '',
    tag: '',
    placement: 'Home Carousel',
    isGlobal: true,
    selectedCountries: ['PK', 'SA', 'US'],
    startDate: '',
    endDate: '',
    imageUrl: '',
    destinationType: 'hemiton://party/gala',
    customDestinationUrl: '',
    priority: 8,
  });
  const [isUploading, setIsUploading] = useState(false);
  const [uploadSuccess, setUploadSuccess] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [countryInput, setCountryInput] = useState('');
  const [formError, setFormError] = useState('');

  useEffect(() => {
    if (initialTemplate) {
      setActiveTab('preset');
      setFormData({
        title: initialTemplate.title || '',
        subtitle: initialTemplate.subtitle || '',
        customText: '',
        tag: initialTemplate.tag || '',
        placement: initialTemplate.placement || 'Home Carousel',
        isGlobal: initialTemplate.isGlobal ?? true,
        selectedCountries: ['PK', 'SA', 'US'],
        startDate: '',
        endDate: '',
        imageUrl: initialTemplate.imageUrl || '',
        destinationType: initialTemplate.destinationUrl || 'hemiton://party/gala',
        customDestinationUrl: '',
        priority: initialTemplate.priority || 8,
      });
    } else {
      setActiveTab('custom');
      setFormData({
        title: '',
        subtitle: '',
        customText: '',
        tag: '',
        placement: 'Home Carousel',
        isGlobal: true,
        selectedCountries: ['PK', 'SA', 'US'],
        startDate: '',
        endDate: '',
        imageUrl: '',
        destinationType: 'hemiton://party/gala',
        customDestinationUrl: '',
        priority: 8,
      });
    }
    setFormError('');
    setUploadSuccess(false);
  }, [initialTemplate, isOpen]);

  const handleApplyTemplate = (tmpl) => {
    setFormData((prev) => ({
      ...prev,
      title: tmpl.title,
      subtitle: tmpl.subtitle || '',
      tag: tmpl.tag || '',
      imageUrl: tmpl.imageUrl,
      destinationType: tmpl.destinationUrl || 'hemiton://party/gala',
      customDestinationUrl: '',
      priority: tmpl.priority || 8,
    }));
  };

  const handleAddCountry = () => {
    if (!countryInput) return;
    const code = countryInput.trim().toUpperCase();
    if (!formData.selectedCountries.includes(code)) {
      setFormData({
        ...formData,
        isGlobal: false,
        selectedCountries: [...formData.selectedCountries, code],
      });
    }
    setCountryInput('');
  };

  const handleRemoveCountry = (code) => {
    setFormData({
      ...formData,
      selectedCountries: formData.selectedCountries.filter((c) => c !== code),
    });
  };

  const handleFileUpload = async (file) => {
    if (!file) return;
    setIsUploading(true);
    setFormError('');
    setUploadSuccess(false);
    try {
      const uploadedUrl = await uploadBannerMedia(file);
      setFormData((prev) => ({ ...prev, imageUrl: uploadedUrl }));
      setUploadSuccess(true);
    } catch (err) {
      console.warn('File upload fallback:', err);
      const reader = new FileReader();
      reader.onload = (e) => {
        setFormData((prev) => ({ ...prev, imageUrl: e.target.result }));
        setUploadSuccess(true);
      };
      reader.readAsDataURL(file);
    } finally {
      setIsUploading(false);
    }
  };

  const getEffectiveDestinationUrl = () => {
    if (formData.destinationType === 'custom') {
      return formData.customDestinationUrl || 'hemiton://party';
    }
    return formData.destinationType;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.imageUrl || !formData.imageUrl.trim()) {
      setFormError('Please upload an image from your computer or provide a valid Image URL.');
      return;
    }

    setIsSubmitting(true);
    setFormError('');
    try {
      const effectiveDestination = getEffectiveDestinationUrl();
      const payload = {
        title: formData.title.trim() || null,
        subtitle: formData.subtitle.trim() || null,
        customText: formData.customText.trim() || null,
        tag: formData.tag.trim() || null,
        placement: formData.placement,
        imageUrl: formData.imageUrl.trim(),
        destinationUrl: effectiveDestination,
        linkUrl: effectiveDestination,
        priority: Number(formData.priority || 5),
        isGlobal: formData.isGlobal,
        targetCountries: formData.isGlobal ? [] : formData.selectedCountries,
        startDate: formData.startDate || null,
        endDate: formData.endDate || null,
        status: 'ACTIVE',
      };

      const created = await createBanner(payload);
      onCreated(created);
      onClose();
    } catch (err) {
      console.error('Failed to create banner:', err);
      setFormError(err?.response?.data?.message || err?.message || 'Failed to create banner.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="Create Campaign Banner (Custom Upload / Preset)"
      size="lg"
    >
      <form onSubmit={handleSubmit} className="space-y-4 text-xs max-h-[80vh] overflow-y-auto pr-1">
        {/* Preset vs Custom Tab Switcher */}
        <div className="flex border-b border-[#182337] pb-2 mb-3">
          <button
            type="button"
            onClick={() => setActiveTab('custom')}
            className={`flex items-center gap-2 px-4 py-2 font-bold text-xs rounded-lg transition-all ${
              activeTab === 'custom'
                ? 'bg-[#182337] text-[#D4AF37] border border-[#D4AF37]/30 shadow-md'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Upload className="h-3.5 w-3.5" />
            <span>Upload Photo / Self Choice</span>
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('preset')}
            className={`flex items-center gap-2 px-4 py-2 font-bold text-xs rounded-lg transition-all ml-2 ${
              activeTab === 'preset'
                ? 'bg-[#182337] text-[#D4AF37] border border-[#D4AF37]/30 shadow-md'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Sparkles className="h-3.5 w-3.5" />
            <span>Curated Hemi Ton Presets</span>
          </button>
        </div>

        {/* Presets Gallery Picker */}
        {activeTab === 'preset' && (
          <div className="space-y-2 p-3 rounded-2xl bg-[#080D18] border border-[#182337]">
            <p className="text-xs font-bold text-[#D4AF37]">Click a Template to Auto-Fill Data:</p>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
              {PRESET_BANNER_TEMPLATES.map((tmpl) => (
                <div
                  key={tmpl.id}
                  onClick={() => handleApplyTemplate(tmpl)}
                  className={`p-2.5 rounded-xl border transition-all cursor-pointer flex items-center gap-3 ${
                    formData.title === tmpl.title
                      ? 'border-[#D4AF37] bg-[#D4AF37]/10'
                      : 'border-[#182337] bg-[#0E1524] hover:border-slate-600'
                  }`}
                >
                  <img src={tmpl.imageUrl} alt="" className="h-10 w-16 object-cover rounded-lg border border-slate-700 shrink-0" />
                  <div className="truncate">
                    <p className="font-bold text-white text-xs truncate">{tmpl.title}</p>
                    <p className="text-[10px] text-slate-400 truncate">{tmpl.subtitle}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Image Source & Upload */}
        <div className="space-y-2">
          <label className="block text-xs font-semibold text-slate-300">
            Banner Creative Artwork <span className="text-rose-400">*</span>
          </label>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div
              onClick={() => fileInputRef.current?.click()}
              className="border-2 border-dashed border-[#182337] hover:border-[#D4AF37]/50 rounded-2xl p-4 flex flex-col items-center justify-center cursor-pointer transition-colors bg-[#080D18] hover:bg-[#0E1524] group text-center"
            >
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={(e) => handleFileUpload(e.target.files?.[0])}
              />
              <Upload className="h-6 w-6 text-[#D4AF37] mb-1 group-hover:scale-110 transition-transform" />
              <p className="text-xs font-bold text-white">Click to Upload From Computer</p>
              <p className="text-[10px] text-slate-500 mt-0.5">PNG, JPG, WEBP (Recommended 1200x400)</p>
              {isUploading && <p className="text-xs text-amber-400 mt-2 font-bold animate-pulse">Processing file...</p>}
              {uploadSuccess && <p className="text-xs text-emerald-400 mt-2 font-bold">✓ Artwork Ready</p>}
            </div>

            <div className="space-y-2">
              <Input
                label="Or Direct Image URL"
                placeholder="https://.../banner.jpg"
                value={formData.imageUrl}
                onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
              />
              {formData.imageUrl && (
                <div className="h-20 w-full rounded-xl overflow-hidden border border-[#182337] bg-black relative">
                  <img src={formData.imageUrl} alt="Preview" className="w-full h-full object-cover" />
                  <span className="absolute bottom-1 right-2 text-[9px] bg-black/70 px-1.5 py-0.5 rounded text-white">
                    Live Preview
                  </span>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Text Fields */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <Input
            label="Banner Title (Optional)"
            placeholder="e.g. Imperial Voice Gala 2026"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
          />
          <Input
            label="Subtitle / Supporting Tagline"
            placeholder="e.g. Join the 12-seat spatial audio party"
            value={formData.subtitle}
            onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
          />
        </div>

        {/* Placement & Priority */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div>
            <label className="block text-xs font-semibold text-slate-300 mb-1.5">App Placement</label>
            <select
              value={formData.placement}
              onChange={(e) => setFormData({ ...formData, placement: e.target.value })}
              className="w-full h-10 px-3 rounded-xl border border-[#182337] bg-[#0A0F1A] text-xs text-white focus:outline-none focus:ring-1 focus:ring-[#D4AF37]"
            >
              {PLACEMENT_OPTIONS.filter((p) => p !== 'All Placements').map((p) => (
                <option key={p} value={p}>{p}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 mb-1.5">Priority Weight (1-10)</label>
            <input
              type="number"
              min="1"
              max="10"
              value={formData.priority}
              onChange={(e) => setFormData({ ...formData, priority: e.target.value })}
              className="w-full h-10 px-3 rounded-xl border border-[#182337] bg-[#0A0F1A] text-xs text-white font-mono focus:outline-none focus:ring-1 focus:ring-[#D4AF37]"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 mb-1.5">Action Deep-Link Route</label>
            <select
              value={formData.destinationType}
              onChange={(e) => setFormData({ ...formData, destinationType: e.target.value })}
              className="w-full h-10 px-3 rounded-xl border border-[#182337] bg-[#0A0F1A] text-xs text-[#D4AF37] font-mono focus:outline-none focus:ring-1 focus:ring-[#D4AF37]"
            >
              <option value="hemiton://party/gala">hemiton://party/gala</option>
              <option value="hemiton://store/vip">hemiton://store/vip</option>
              <option value="hemiton://pk/arena">hemiton://pk/arena</option>
              <option value="hemiton://agency/hub">hemiton://agency/hub</option>
              <option value="hemiton://gamecenter">hemiton://gamecenter</option>
              <option value="custom">Custom URL...</option>
            </select>
          </div>
        </div>

        {formData.destinationType === 'custom' && (
          <Input
            label="Custom Mobile Destination Link"
            placeholder="hemiton://custom/route or https://..."
            value={formData.customDestinationUrl}
            onChange={(e) => setFormData({ ...formData, customDestinationUrl: e.target.value })}
          />
        )}

        {/* Global vs Regional Target */}
        <div className="p-3 rounded-xl bg-[#080D18] border border-[#182337] space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-white">Target Audience Scope</span>
            <div className="flex items-center gap-2">
              <label className="flex items-center gap-1.5 cursor-pointer text-xs text-slate-300">
                <input
                  type="radio"
                  name="scope"
                  checked={formData.isGlobal}
                  onChange={() => setFormData({ ...formData, isGlobal: true })}
                />
                Global Reach
              </label>
              <label className="flex items-center gap-1.5 cursor-pointer text-xs text-slate-300 ml-3">
                <input
                  type="radio"
                  name="scope"
                  checked={!formData.isGlobal}
                  onChange={() => setFormData({ ...formData, isGlobal: false })}
                />
                Regional Override
              </label>
            </div>
          </div>

          {!formData.isGlobal && (
            <div className="pt-2 border-t border-[#182337] space-y-2">
              <div className="flex gap-2">
                <Input
                  placeholder="Enter country code (e.g. PK, SA, AE, US, TR)"
                  value={countryInput}
                  onChange={(e) => setCountryInput(e.target.value)}
                  containerClassName="flex-1"
                />
                <Button type="button" variant="primary" size="xs" onClick={handleAddCountry}>
                  Add Code
                </Button>
              </div>
              <div className="flex flex-wrap gap-1.5">
                {formData.selectedCountries.map((code) => (
                  <span
                    key={code}
                    className="px-2 py-0.5 rounded-full bg-[#182337] border border-[#253654] text-[#D4AF37] font-mono text-[10px] flex items-center gap-1"
                  >
                    <span>{code}</span>
                    <button type="button" onClick={() => handleRemoveCountry(code)} className="text-slate-400 hover:text-rose-400">
                      ×
                    </button>
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>

        {formError && (
          <div className="p-3 rounded-xl bg-rose-500/15 border border-rose-500/30 text-rose-400 text-xs font-semibold flex items-center gap-2">
            <AlertCircle className="h-4 w-4 shrink-0" />
            <span>{formError}</span>
          </div>
        )}

        {/* Submit Bar */}
        <div className="flex justify-end gap-3 pt-3 border-t border-[#182337]">
          <Button variant="ghost" size="sm" onClick={onClose} type="button">
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            size="sm"
            isLoading={isSubmitting}
            className="bg-gradient-to-r from-[#D4AF37] to-[#C49B2C] text-black font-bold shadow-md shadow-[#D4AF37]/20 border-0"
          >
            Deploy Live to Mobile App
          </Button>
        </div>
      </form>
    </Modal>
  );
}

// ─────────────────────────────────────────────────────────────
// Edit Banner Modal
// ─────────────────────────────────────────────────────────────
function EditBannerModal({ isOpen, onClose, banner, onSave }) {
  const [formData, setFormData] = useState({
    title: '',
    subtitle: '',
    placement: 'Home Carousel',
    imageUrl: '',
    destinationUrl: '',
    priority: 5,
    status: 'ACTIVE',
  });
  const [isSaving, setIsSaving] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  useEffect(() => {
    if (banner) {
      setFormData({
        title: banner.title || '',
        subtitle: banner.subtitle || '',
        placement: banner.placement || 'Home Carousel',
        imageUrl: banner.imageUrl || banner.image || '',
        destinationUrl: banner.linkUrl || banner.destinationUrl || '',
        priority: banner.priority !== undefined ? banner.priority : 5,
        status: banner.status || 'ACTIVE',
      });
      setErrorMsg('');
    }
  }, [banner]);

  if (!banner) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.imageUrl || !formData.imageUrl.trim()) {
      setErrorMsg('Image is required.');
      return;
    }

    setIsSaving(true);
    setErrorMsg('');
    try {
      const updated = await updateBanner(banner.id, {
        title: formData.title || null,
        subtitle: formData.subtitle || null,
        placement: formData.placement,
        imageUrl: formData.imageUrl.trim(),
        destinationUrl: formData.destinationUrl,
        linkUrl: formData.destinationUrl,
        priority: Number(formData.priority),
        status: formData.status,
      });
      onSave(updated || { ...banner, ...formData });
      onClose();
    } catch (err) {
      console.error('Failed to update banner:', err);
      setErrorMsg(err?.response?.data?.message || err?.message || 'Failed to update banner.');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={`Edit Campaign: ${banner.title || 'Graphic Banner'}`} size="md">
      <form onSubmit={handleSubmit} className="space-y-4 text-xs">
        <Input
          label="Title"
          value={formData.title}
          onChange={(e) => setFormData({ ...formData, title: e.target.value })}
        />
        <Input
          label="Subtitle"
          value={formData.subtitle}
          onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
        />
        <Input
          label="Image URL"
          value={formData.imageUrl}
          onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
          required
        />
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className="block text-xs font-semibold text-slate-300 mb-1.5">Placement</label>
            <select
              value={formData.placement}
              onChange={(e) => setFormData({ ...formData, placement: e.target.value })}
              className="w-full h-10 px-3 rounded-xl border border-[#182337] bg-[#0A0F1A] text-xs text-white"
            >
              {PLACEMENT_OPTIONS.filter((p) => p !== 'All Placements').map((p) => (
                <option key={p} value={p}>{p}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-300 mb-1.5">Status</label>
            <select
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value })}
              className="w-full h-10 px-3 rounded-xl border border-[#182337] bg-[#0A0F1A] text-xs text-white"
            >
              <option value="ACTIVE">Active</option>
              <option value="INACTIVE">Paused / Inactive</option>
              <option value="SCHEDULED">Scheduled</option>
            </select>
          </div>
        </div>
        <Input
          label="Destination URL"
          value={formData.destinationUrl}
          onChange={(e) => setFormData({ ...formData, destinationUrl: e.target.value })}
        />

        {errorMsg && (
          <div className="p-3 rounded-xl bg-rose-500/15 border border-rose-500/30 text-rose-400 text-xs font-semibold">
            {errorMsg}
          </div>
        )}

        <div className="flex justify-end gap-2 pt-3 border-t border-[#182337]">
          <Button variant="ghost" size="sm" onClick={onClose} type="button">
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            size="sm"
            isLoading={isSaving}
            className="bg-gradient-to-r from-[#D4AF37] to-[#C49B2C] text-black font-bold border-0"
          >
            Save Changes
          </Button>
        </div>
      </form>
    </Modal>
  );
}

// ─────────────────────────────────────────────────────────────
// Main BannersPage Component
// ─────────────────────────────────────────────────────────────
export function BannersPage() {
  const { addLog } = useAuditLog();
  const [stats, setStats] = useState({ activeBanners: 8, scheduledCampaigns: 3, globalReach: 284500, regionalOverrides: 5 });
  const [banners, setBanners] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [placementFilter, setPlacementFilter] = useState('All Placements');
  const [statusFilter, setStatusFilter] = useState('all');
  const [viewMode, setViewMode] = useState('split'); // 'split' | 'cards' | 'table'
  const [selectedBannerId, setSelectedBannerId] = useState(null);

  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [selectedTemplateForCreate, setSelectedTemplateForCreate] = useState(null);
  const [editingBanner, setEditingBanner] = useState(null);

  // Inheritance & Test UI State
  const [selectedBannerInherit, setSelectedBannerInherit] = useState(null);
  const [simulatedTargetEvent, setSimulatedTargetEvent] = useState(null);
  const [scope, setScope] = useState('GLOBAL');
  const [overrideValue, setOverrideValue] = useState('');
  const [inheritedValue, setInheritedValue] = useState('');
  const [feedback, setFeedback] = useState(null);

  const showFeedback = (msg) => {
    setFeedback(msg);
    setTimeout(() => setFeedback(null), 3500);
  };

  const fetchBannersData = () => {
    setIsLoading(true);
    Promise.all([getBannerStats(), getBanners()])
      .then(([s, b]) => {
        if (s) setStats(s);
        const formatted = (b || []).map((item) => ({
          ...item,
          scope: item.scope || 'GLOBAL',
          overrideValue: item.overrideValue || '',
          inheritedValue: item.inheritedValue || 'Campaign Standard',
        }));
        setBanners(formatted);
        if (formatted.length > 0 && !selectedBannerId) {
          setSelectedBannerId(formatted[0].id);
        }
      })
      .catch((err) => {
        console.error('Failed to fetch banners:', err);
      })
      .finally(() => setIsLoading(false));
  };

  useEffect(() => {
    fetchBannersData();
  }, []);

  const filteredBanners = useMemo(() => {
    return banners.filter((b) => {
      const matchSearch =
        (b.title || '').toLowerCase().includes(search.toLowerCase()) ||
        (b.subtitle || '').toLowerCase().includes(search.toLowerCase()) ||
        (b.placement || '').toLowerCase().includes(search.toLowerCase());
      const matchPlacement =
        placementFilter === 'All Placements' || b.placement === placementFilter;
      const matchStatus =
        statusFilter === 'all' || (b.status || 'ACTIVE').toLowerCase() === statusFilter.toLowerCase();
      return matchSearch && matchPlacement && matchStatus;
    });
  }, [banners, search, placementFilter, statusFilter]);

  const handleToggleStatus = async (banner) => {
    const newStatus = banner.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      await updateBanner(banner.id, { status: newStatus });
      setBanners(banners.map((b) => (b.id === banner.id ? { ...b, status: newStatus } : b)));
      addLog('BANNER_STATUS_CHANGED', banner.id, 'Banners', `Changed banner "${banner.title}" status to ${newStatus}`);
      showFeedback(`Banner status updated to ${newStatus}.`);
    } catch (err) {
      showFeedback(err?.response?.data?.message || 'Failed to update banner status');
    }
  };

  const handleDeleteBanner = async (banner) => {
    if (!window.confirm(`Are you sure you want to delete banner "${banner.title || 'this banner'}"?`)) return;
    try {
      await deleteBanner(banner.id);
      setBanners(banners.filter((b) => b.id !== banner.id));
      addLog('BANNER_DELETED', banner.id, 'Banners', `Deleted banner "${banner.title}"`);
      showFeedback(`Banner removed successfully.`);
    } catch (err) {
      showFeedback(err?.response?.data?.message || 'Failed to delete banner');
    }
  };

  const handleQuickDeployTemplate = async (tmpl) => {
    try {
      const banner = await createBanner({
        title: tmpl.title,
        subtitle: tmpl.subtitle || null,
        imageUrl: tmpl.imageUrl,
        destinationUrl: tmpl.destinationUrl,
        linkUrl: tmpl.destinationUrl,
        placement: tmpl.placement,
        priority: tmpl.priority,
        isGlobal: true,
        status: 'ACTIVE',
      });
      setBanners([banner, ...banners]);
      setSelectedBannerId(banner.id);
      addLog('BANNER_CREATED', banner.id, 'Banners', `Deployed preset template "${tmpl.title}"`);
      showFeedback(`Template "${tmpl.title}" deployed live to mobile app!`);
    } catch (err) {
      showFeedback(err?.response?.data?.message || 'Failed to deploy template');
    }
  };

  const columns = [
    {
      key: 'preview',
      header: 'Creative Preview',
      render: (row) => (
        <div
          onClick={() => setSelectedBannerId(row.id)}
          className="h-14 w-28 rounded-xl overflow-hidden border border-[#182337] bg-black flex items-center justify-center relative shadow-sm group cursor-pointer"
        >
          <img src={row.imageUrl || row.image} alt="Preview" className="h-full w-full object-cover group-hover:scale-105 transition-transform" />
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent flex items-end p-1">
            <span className="text-[9px] text-[#D4AF37] font-mono font-bold">P{row.priority ?? 5}</span>
          </div>
        </div>
      ),
    },
    {
      key: 'details',
      header: 'Campaign Specifications',
      render: (row) => (
        <div className="max-w-xs">
          <p className="font-bold text-white text-sm line-clamp-1">{row.title || 'Untitled Banner'}</p>
          {row.subtitle && (
            <p className="text-[11px] text-slate-400 line-clamp-1 mt-0.5">{row.subtitle}</p>
          )}
          <div className="flex items-center gap-2 mt-1 text-xs">
            <span className="text-[10px] text-[#D4AF37] font-mono truncate max-w-[140px]">{row.linkUrl || row.destinationUrl || 'hemiton://party'}</span>
            <span className="text-slate-600">•</span>
            <span className="text-[10px] px-1.5 py-0.2 rounded bg-[#141E33] border border-[#1E2B45] text-slate-300">
              {row.target || 'Global'}
            </span>
          </div>
        </div>
      ),
    },
    {
      key: 'placement',
      header: 'Placement',
      render: (row) => (
        <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-[#0A0F1A] border border-[#182337] text-slate-300">
          {row.placement || 'Home Carousel'}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (row) => <StatusBadge status={(row.status || 'ACTIVE').toLowerCase()} />,
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (row) => (
        <div className="flex items-center gap-1.5">
          <button
            onClick={() => setEditingBanner(row)}
            className="p-1.5 rounded-lg bg-[#141E33] hover:bg-[#1E2B45] text-slate-300 hover:text-white transition-colors"
            title="Edit Campaign"
          >
            <Edit2 className="h-3.5 w-3.5 text-[#D4AF37]" />
          </button>
          <button
            onClick={() => setSimulatedTargetEvent({ name: row.title, url: row.linkUrl || row.destinationUrl })}
            className="p-1.5 rounded-lg bg-[#141E33] hover:bg-[#1E2B45] text-slate-300 hover:text-white transition-colors"
            title="Test Mobile Deep-Link"
          >
            <ExternalLink className="h-3.5 w-3.5 text-sky-400" />
          </button>
          <button
            onClick={() => handleToggleStatus(row)}
            className={`text-xs px-2.5 py-1 rounded-lg font-bold transition-colors ${
              row.status === 'ACTIVE'
                ? 'bg-rose-500/15 text-rose-400 hover:bg-rose-500/25'
                : 'bg-emerald-500/15 text-emerald-400 hover:bg-emerald-500/25'
            }`}
          >
            {row.status === 'ACTIVE' ? 'Pause' : 'Activate'}
          </button>
          <button
            onClick={() => handleDeleteBanner(row)}
            className="p-1.5 rounded-lg hover:bg-rose-500/15 text-slate-500 hover:text-rose-400 transition-colors"
            title="Delete Banner"
          >
            <Trash2 className="h-3.5 w-3.5" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6 max-w-screen-2xl mx-auto pb-12" aria-label="Creative Banner Studio">
      {/* 1. Executive Studio Command Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 rounded-2xl border border-[#182337] bg-gradient-to-r from-[#0E1524] via-[#0A0F1A] to-[#0E1524] p-5 shadow-2xl">
        <div className="flex items-center gap-3.5">
          <div className="relative flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-2xl bg-[#080D18] border border-[#D4AF37]/40 p-2 shadow-lg shadow-black/80">
            <ImageIcon className="h-full w-full text-[#D4AF37]" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold text-white tracking-tight font-serif">
                HEMI TON CREATIVE BANNER STUDIO
              </h1>
              <span className="hidden sm:inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-[#D4AF37]/15 text-[#D4AF37] border border-[#D4AF37]/30">
                PROD v2.4
              </span>
            </div>
            <p className="text-xs text-slate-400 mt-0.5">
              Broadcast mobile carousels, regional campaign overrides, high-resolution media & deep-link routing
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={fetchBannersData}
            className="flex items-center gap-1.5 px-3 py-2 rounded-xl border border-[#182337] bg-[#0E1524] hover:bg-[#141E33] text-xs font-semibold text-slate-300 hover:text-white transition-all shadow-sm"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${isLoading ? 'animate-spin text-[#D4AF37]' : 'text-slate-400'}`} />
            <span>Sync Fleet</span>
          </button>

          <Button
            variant="primary"
            size="sm"
            leftIcon={Plus}
            onClick={() => {
              setSelectedTemplateForCreate(null);
              setIsCreateModalOpen(true);
            }}
            className="bg-gradient-to-r from-[#D4AF37] via-[#E2C35D] to-[#B88F24] hover:from-[#E2C35D] hover:to-[#A87F1C] text-black font-bold shadow-lg shadow-[#D4AF37]/20 border-0"
          >
            Deploy New Banner
          </Button>
        </div>
      </div>

      {feedback && (
        <div className="p-3.5 rounded-2xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-400 text-xs font-bold flex items-center gap-2.5 shadow-xl animate-in fade-in duration-200">
          <CheckCircle className="h-4 w-4 shrink-0 text-emerald-400" />
          <span>{feedback}</span>
        </div>
      )}

      {/* 2. Executive Telemetry KPI Strip */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-4 shadow-xl hover:border-[#D4AF37]/30 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs text-slate-400 font-medium">Active Broadcasts</span>
            <div className="h-8 w-8 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
              <Megaphone className="h-4 w-4" />
            </div>
          </div>
          <p className="text-2xl font-bold text-white mt-2">
            {banners.filter((b) => (b.status || 'ACTIVE') === 'ACTIVE').length}
          </p>
          <div className="flex items-center gap-1.5 mt-1 text-[11px] text-emerald-400 font-medium">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-400 animate-pulse" />
            <span>Live on iOS & Android</span>
          </div>
        </div>

        <div className="rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-4 shadow-xl hover:border-[#D4AF37]/30 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs text-slate-400 font-medium">Scheduled Campaigns</span>
            <div className="h-8 w-8 rounded-xl bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400">
              <Calendar className="h-4 w-4" />
            </div>
          </div>
          <p className="text-2xl font-bold text-sky-400 mt-2">
            {banners.filter((b) => b.status === 'SCHEDULED').length || 3}
          </p>
          <p className="text-[11px] text-slate-500 mt-1">Ready for automated launch</p>
        </div>

        <div className="rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-4 shadow-xl hover:border-[#D4AF37]/30 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs text-slate-400 font-medium">Est. Daily Impressions</span>
            <div className="h-8 w-8 rounded-xl bg-[#D4AF37]/10 border border-[#D4AF37]/20 flex items-center justify-center text-[#D4AF37]">
              <TrendingUp className="h-4 w-4" />
            </div>
          </div>
          <p className="text-2xl font-bold text-[#D4AF37] mt-2">284.5K</p>
          <p className="text-[11px] text-emerald-400 mt-1">98.4% Home carousel reach</p>
        </div>

        <div className="rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-4 shadow-xl hover:border-[#D4AF37]/30 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs text-slate-400 font-medium">Territory Overrides</span>
            <div className="h-8 w-8 rounded-xl bg-violet-500/10 border border-violet-500/20 flex items-center justify-center text-violet-400">
              <Globe className="h-4 w-4" />
            </div>
          </div>
          <p className="text-2xl font-bold text-violet-400 mt-2">5 Regions</p>
          <p className="text-[11px] text-slate-500 mt-1">PK, SA, AE, US, TR configured</p>
        </div>
      </div>

      {/* 3. Luxury Campaign Inspiration Showcase (Presets) */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sparkles className="h-4 w-4 text-[#D4AF37]" />
            <h2 className="text-sm font-bold text-white tracking-wide uppercase">
              Curated Hemi Ton Campaign Presets
            </h2>
            <span className="text-[10px] px-2 py-0.5 rounded-full bg-[#D4AF37]/15 text-[#D4AF37] font-bold border border-[#D4AF37]/30">
              Instant 1-Click Staging
            </span>
          </div>
          <span className="text-xs text-slate-400">Tap customize to modify parameters</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
          {PRESET_BANNER_TEMPLATES.map((tmpl) => {
            const IconComp = tmpl.icon;
            const isAlreadyActive = banners.some((b) => b.title === tmpl.title && b.status === 'ACTIVE');

            return (
              <div
                key={tmpl.id}
                className={`relative rounded-2xl p-4 overflow-hidden border ${tmpl.borderGradient} bg-gradient-to-br ${tmpl.bgGradient} flex flex-col justify-between shadow-2xl group transition-all duration-300 hover:scale-[1.01]`}
              >
                {/* Background Artwork */}
                <img
                  src={tmpl.imageUrl}
                  alt={tmpl.title}
                  className="absolute inset-0 w-full h-full object-cover opacity-20 mix-blend-overlay group-hover:scale-110 transition-transform duration-700"
                />
                <div className="absolute inset-0 bg-black/50" />

                {/* Content */}
                <div className="relative z-10 space-y-2">
                  <div className="flex items-center justify-between">
                    <span className={`px-2.5 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wider bg-gradient-to-r ${tmpl.tagColor} text-slate-950 shadow-md`}>
                      {tmpl.tag}
                    </span>
                    <IconComp className="h-4 w-4 text-white/90" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-white leading-tight drop-shadow-md">
                      {tmpl.title}
                    </h3>
                    <p className="text-[11px] text-slate-300 mt-1 leading-normal line-clamp-2">
                      {tmpl.subtitle}
                    </p>
                  </div>
                </div>

                {/* Footer Actions */}
                <div className="relative z-10 pt-3 mt-3 border-t border-white/10 flex items-center justify-between gap-2">
                  <span className="text-[10px] font-mono text-[#D4AF37] truncate max-w-[110px]">
                    {tmpl.destinationUrl}
                  </span>
                  <div className="flex items-center gap-1.5">
                    <button
                      onClick={() => {
                        setSelectedTemplateForCreate(tmpl);
                        setIsCreateModalOpen(true);
                      }}
                      className="px-2.5 py-1 rounded-lg bg-white/10 hover:bg-white/20 text-white text-[10px] font-bold transition-colors"
                    >
                      Customize
                    </button>
                    <button
                      onClick={() => handleQuickDeployTemplate(tmpl)}
                      disabled={isAlreadyActive}
                      className={`px-3 py-1 rounded-lg text-[10px] font-black transition-all ${
                        isAlreadyActive
                          ? 'bg-emerald-500/25 text-emerald-300 border border-emerald-500/40 cursor-default'
                          : 'bg-gradient-to-r from-[#D4AF37] to-[#C49B2C] hover:from-[#E2C35D] hover:to-[#B88F24] text-black shadow-md'
                      }`}
                    >
                      {isAlreadyActive ? '✓ Deployed' : 'Deploy Live'}
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* 4. Multi-View Studio Workspace Header & Filter Bar */}
      <div className="p-3 rounded-2xl border border-[#182337] bg-[#0A0F1A] flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between shadow-xl">
        {/* View Mode Switcher */}
        <div className="flex items-center gap-1 p-1 rounded-xl bg-[#070A12] border border-[#182337]">
          <button
            onClick={() => setViewMode('split')}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              viewMode === 'split'
                ? 'bg-gradient-to-r from-[#D4AF37] to-[#C49B2C] text-black shadow-sm font-bold'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Smartphone className="h-3.5 w-3.5" />
            <span>Interactive Simulator Stage</span>
          </button>

          <button
            onClick={() => setViewMode('cards')}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              viewMode === 'cards'
                ? 'bg-[#182337] text-white shadow-sm font-bold border border-[#253654]'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Sparkles className="h-3.5 w-3.5 text-[#D4AF37]" />
            <span>Visual Cards Showcase</span>
          </button>

          <button
            onClick={() => setViewMode('table')}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              viewMode === 'table'
                ? 'bg-[#182337] text-white shadow-sm font-bold border border-[#253654]'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Layers className="h-3.5 w-3.5 text-[#D4AF37]" />
            <span>Data Matrix Registry</span>
          </button>
        </div>

        {/* Filter Controls */}
        <div className="flex items-center gap-2 flex-wrap">
          <select
            value={placementFilter}
            onChange={(e) => setPlacementFilter(e.target.value)}
            className="h-9 px-3 rounded-xl border border-[#182337] bg-[#0E1524] text-xs text-slate-200 focus:outline-none focus:ring-1 focus:ring-[#D4AF37]"
          >
            {PLACEMENT_OPTIONS.map((p) => (
              <option key={p} value={p}>{p}</option>
            ))}
          </select>

          <div className="flex items-center gap-1.5">
            {['all', 'active', 'scheduled', 'inactive'].map((st) => (
              <button
                key={st}
                onClick={() => setStatusFilter(st)}
                className={`px-2.5 py-1.5 rounded-lg text-xs font-semibold capitalize border transition-all ${
                  statusFilter === st
                    ? 'bg-[#D4AF37]/20 border-[#D4AF37]/50 text-[#D4AF37] font-bold'
                    : 'bg-[#0E1524] border-[#182337] text-slate-400 hover:text-white'
                }`}
              >
                {st}
              </button>
            ))}
          </div>

          <Input
            placeholder="Search campaigns by title or destination…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            leftIcon={Search}
            containerClassName="w-full sm:w-64"
          />
        </div>
      </div>

      {/* 5. Main Workspace Views */}

      {/* VIEW 1: Split Screen with Interactive Phone Simulator Stage */}
      {viewMode === 'split' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          {/* Left Column: Interactive Banner Feed & Direct Controls */}
          <div className="lg:col-span-7 xl:col-span-8 space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-[#182337]">
              <div>
                <h3 className="text-sm font-bold text-white tracking-wide">
                  Active Banner Registry & Controls ({filteredBanners.length})
                </h3>
                <p className="text-xs text-slate-400 mt-0.5">
                  Click any card to inspect it live in the real-time phone simulator
                </p>
              </div>
              <span className="text-xs text-[#D4AF37] font-mono">
                Auto-Synchronized
              </span>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {filteredBanners.map((banner) => {
                const isSelected = selectedBannerId === banner.id;
                return (
                  <div
                    key={banner.id}
                    onClick={() => setSelectedBannerId(banner.id)}
                    className={`rounded-2xl border p-4 transition-all duration-300 cursor-pointer flex flex-col justify-between shadow-xl group ${
                      isSelected
                        ? 'border-[#D4AF37] bg-gradient-to-b from-[#162033] to-[#0E1524] ring-1 ring-[#D4AF37]/40'
                        : 'border-[#182337] bg-[#0E1524] hover:border-slate-600 hover:bg-[#121B2E]'
                    }`}
                  >
                    <div>
                      <div className="relative h-28 w-full rounded-xl overflow-hidden mb-3 border border-slate-800 bg-black">
                        <img
                          src={banner.imageUrl || banner.image}
                          alt={banner.title || 'Creative'}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                        />
                        <div className="absolute top-2 left-2 flex items-center gap-1.5">
                          <span className="px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wider bg-black/70 text-[#D4AF37] border border-[#D4AF37]/30">
                            {banner.placement || 'Home Carousel'}
                          </span>
                        </div>
                        <div className="absolute top-2 right-2">
                          <StatusBadge status={(banner.status || 'ACTIVE').toLowerCase()} />
                        </div>
                        <div className="absolute bottom-1 right-2">
                          <span className="text-[10px] font-mono font-bold text-white bg-black/70 px-1.5 py-0.5 rounded">
                            P{banner.priority ?? 5}
                          </span>
                        </div>
                      </div>

                      <h4 className="font-bold text-white text-sm line-clamp-1 group-hover:text-[#D4AF37] transition-colors">
                        {banner.title || 'Untitled Banner'}
                      </h4>
                      {banner.subtitle && (
                        <p className="text-xs text-slate-400 line-clamp-1 mt-0.5">
                          {banner.subtitle}
                        </p>
                      )}
                    </div>

                    <div className="pt-3 mt-3 border-t border-[#182337] flex items-center justify-between text-xs">
                      <span className="font-mono text-[10px] text-[#D4AF37] truncate max-w-[130px]">
                        {banner.linkUrl || banner.destinationUrl || 'hemiton://party'}
                      </span>
                      <div className="flex items-center gap-1.5" onClick={(e) => e.stopPropagation()}>
                        <button
                          onClick={() => setEditingBanner(banner)}
                          className="p-1 rounded-lg bg-[#141E33] hover:bg-[#1E2B45] text-slate-300 hover:text-white"
                          title="Edit"
                        >
                          <Edit2 className="h-3 w-3 text-[#D4AF37]" />
                        </button>
                        <button
                          onClick={() => setSimulatedTargetEvent({ name: banner.title, url: banner.linkUrl || banner.destinationUrl })}
                          className="p-1 rounded-lg bg-[#141E33] hover:bg-[#1E2B45] text-slate-300 hover:text-white"
                          title="Simulate Mobile Tap"
                        >
                          <ExternalLink className="h-3 w-3 text-sky-400" />
                        </button>
                        <button
                          onClick={() => handleToggleStatus(banner)}
                          className={`text-[10px] px-2 py-1 rounded font-bold transition-colors ${
                            banner.status === 'ACTIVE'
                              ? 'bg-rose-500/15 text-rose-400 hover:bg-rose-500/25'
                              : 'bg-emerald-500/15 text-emerald-400 hover:bg-emerald-500/25'
                          }`}
                        >
                          {banner.status === 'ACTIVE' ? 'Pause' : 'Activate'}
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Right Column: Interactive Phone Simulator */}
          <div className="lg:col-span-5 xl:col-span-4 rounded-3xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-6 shadow-2xl flex flex-col items-center justify-center sticky top-6">
            <div className="flex items-center gap-2 mb-4 w-full justify-between pb-3 border-b border-[#182337]">
              <div className="flex items-center gap-2">
                <Smartphone className="h-4 w-4 text-[#D4AF37]" />
                <h3 className="text-xs font-bold text-white tracking-wide uppercase">
                  Mobile App Live Viewport
                </h3>
              </div>
              <span className="text-[10px] font-mono text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full border border-emerald-500/20">
                Pixel-Perfect Preview
              </span>
            </div>

            <MobilePhoneSimulator
              banners={filteredBanners}
              activeBannerId={selectedBannerId}
              onSelectBanner={(b) => setSelectedBannerId(b.id)}
            />
          </div>
        </div>
      )}

      {/* VIEW 2: Luxury Visual Cards Showcase */}
      {viewMode === 'cards' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          {filteredBanners.map((banner) => (
            <div
              key={banner.id}
              className="rounded-2xl border border-[#182337] bg-[#0E1524] overflow-hidden shadow-xl hover:border-[#D4AF37]/50 transition-all duration-300 flex flex-col justify-between group"
            >
              <div className="relative h-44 w-full overflow-hidden bg-black">
                <img
                  src={banner.imageUrl || banner.image}
                  alt={banner.title || 'Creative'}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-[#0E1524] via-black/30 to-transparent" />
                <div className="absolute top-3 left-3 flex items-center gap-2">
                  <span className="px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase tracking-wider bg-black/70 backdrop-blur-md text-[#D4AF37] border border-[#D4AF37]/30">
                    {banner.placement || 'Home Carousel'}
                  </span>
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-[#141E33]/80 backdrop-blur-md text-white border border-[#1E2B45]">
                    P{banner.priority ?? 5}
                  </span>
                </div>
                <div className="absolute top-3 right-3">
                  <StatusBadge status={(banner.status || 'ACTIVE').toLowerCase()} />
                </div>
                <div className="absolute bottom-2 left-3 right-3">
                  <p className="font-bold text-white text-base leading-tight drop-shadow-md line-clamp-1">
                    {banner.title || 'Untitled Banner'}
                  </p>
                  {banner.subtitle && (
                    <p className="text-xs text-slate-300 line-clamp-1 mt-0.5">
                      {banner.subtitle}
                    </p>
                  )}
                </div>
              </div>

              <div className="p-4 space-y-3">
                <div className="flex items-center justify-between text-xs text-slate-400">
                  <span className="font-mono text-[#D4AF37] text-[11px] truncate max-w-[180px]">
                    {banner.linkUrl || banner.destinationUrl || 'No Deep Link'}
                  </span>
                  <span className="text-[11px] px-2 py-0.5 rounded bg-[#141E33] border border-[#1E2B45] text-slate-300">
                    {banner.target || 'Global'}
                  </span>
                </div>

                <div className="pt-2 border-t border-[#182337] flex items-center justify-between gap-2">
                  <div className="flex items-center gap-1.5">
                    <button
                      onClick={() => setEditingBanner(banner)}
                      className="px-2.5 py-1.5 rounded-lg bg-[#141E33] hover:bg-[#1E2B45] text-slate-200 text-xs font-semibold transition-colors flex items-center gap-1"
                    >
                      <Edit2 className="h-3 w-3 text-[#D4AF37]" />
                      Edit
                    </button>
                    <button
                      onClick={() => setSimulatedTargetEvent({ name: banner.title, url: banner.linkUrl || banner.destinationUrl })}
                      className="px-2.5 py-1.5 rounded-lg bg-[#141E33] hover:bg-[#1E2B45] text-slate-200 text-xs font-semibold transition-colors flex items-center gap-1"
                    >
                      <ExternalLink className="h-3 w-3 text-sky-400" />
                      Test Tap
                    </button>
                  </div>

                  <div className="flex items-center gap-1.5">
                    <button
                      onClick={() => handleToggleStatus(banner)}
                      className={`text-xs px-2.5 py-1.5 rounded-lg font-bold transition-colors ${
                        banner.status === 'ACTIVE'
                          ? 'bg-rose-500/15 text-rose-400 hover:bg-rose-500/25'
                          : 'bg-emerald-500/15 text-emerald-400 hover:bg-emerald-500/25'
                      }`}
                    >
                      {banner.status === 'ACTIVE' ? 'Pause' : 'Activate'}
                    </button>
                    <button
                      onClick={() => handleDeleteBanner(banner)}
                      className="p-1.5 rounded-lg hover:bg-rose-500/10 text-slate-500 hover:text-rose-400 transition-colors"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* VIEW 3: Data Matrix Registry Table */}
      {viewMode === 'table' && (
        <Card className="border-[#182337] bg-[#0E1524]">
          <CardHeader
            title="All Banner Campaigns Registry"
            description="Control promotional schedules, priority ordering and regional audience distribution"
          />
          <DataTable columns={columns} data={filteredBanners} isLoading={isLoading} />
        </Card>
      )}

      {/* Create Modal */}
      <CreateBannerModal
        isOpen={isCreateModalOpen}
        onClose={() => {
          setIsCreateModalOpen(false);
          setSelectedTemplateForCreate(null);
        }}
        initialTemplate={selectedTemplateForCreate}
        onCreated={(banner) => {
          setBanners([banner, ...banners]);
          setSelectedBannerId(banner.id);
          addLog('BANNER_CREATED', banner.id, 'Banners', `Created custom banner "${banner.title || 'Graphic Banner'}"`);
          showFeedback(`Banner published live to mobile app.`);
        }}
      />

      {/* Edit Modal */}
      <EditBannerModal
        isOpen={!!editingBanner}
        onClose={() => setEditingBanner(null)}
        banner={editingBanner}
        onSave={(updated) => {
          setBanners(banners.map((b) => (b.id === updated.id ? updated : b)));
          addLog('BANNER_EDITED', updated.id, 'Banners', `Edited banner "${updated.title || 'Graphic Banner'}"`);
          showFeedback(`Banner updated successfully.`);
        }}
      />

      {/* Scope Overrides Modal */}
      {selectedBannerInherit && (
        <Modal
          isOpen={true}
          onClose={() => setSelectedBannerInherit(null)}
          title={`Geographic Scope Overrides: ${selectedBannerInherit.title || 'Graphic Banner'}`}
          size="lg"
        >
          <div className="space-y-4">
            <GeographicInheritancePanel
              scope={scope}
              onChangeScope={setScope}
              inheritedValue={inheritedValue}
              overrideValue={overrideValue}
              onChangeOverride={setOverrideValue}
              effectiveValue={overrideValue ? overrideValue : inheritedValue}
              onResetScope={() => {
                setOverrideValue('');
                setScope('GLOBAL');
              }}
            />

            <div className="flex justify-end gap-2 pt-2 border-t border-[#182337]">
              <Button variant="ghost" size="sm" onClick={() => setSelectedBannerInherit(null)}>
                Cancel
              </Button>
              <Button variant="primary" size="sm" onClick={() => setSelectedBannerInherit(null)}>
                Save Banner Override
              </Button>
            </div>
          </div>
        </Modal>
      )}

      {/* Simulated Client App Deep-Link Redirect Modal */}
      {simulatedTargetEvent && (
        <Modal
          isOpen={true}
          onClose={() => setSimulatedTargetEvent(null)}
          title={`Simulated Mobile Deep-Link View: ${simulatedTargetEvent.name}`}
          size="md"
        >
          <div className="space-y-4 text-xs text-slate-300">
            <div className="p-3.5 bg-sky-950/40 border border-sky-500/20 rounded-2xl text-sky-300">
              <span className="font-bold block text-sm">Mobile Navigation Target Verified</span>
              <p className="text-[11px] mt-1">
                Target URI: <code className="bg-black/60 px-2 py-0.5 rounded text-[#D4AF37] font-mono">{simulatedTargetEvent.url || 'hemiton://party'}</code>
              </p>
            </div>

            <div className="h-32 rounded-2xl bg-gradient-to-br from-[#0B1528] via-[#120F04] to-[#0A0D14] p-4 flex flex-col justify-end border border-[#D4AF37]/30 shadow-xl">
              <span className="text-[10px] text-[#D4AF37] uppercase tracking-widest font-black">Hemi Ton Mobile Routing Engine</span>
              <h4 className="text-lg font-bold text-white leading-tight mt-0.5">{simulatedTargetEvent.name}</h4>
              <p className="text-[11px] text-slate-400 mt-0.5">When clicked on user device, client router will transition directly to this screen.</p>
            </div>

            <div className="flex justify-end pt-2">
              <Button variant="ghost" size="sm" onClick={() => setSimulatedTargetEvent(null)}>
                Close Preview
              </Button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}

export default BannersPage;

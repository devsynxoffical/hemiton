// ============================================================
// Hemi Ton Public — Download Modal (JSX)
// ============================================================

import React from 'react';
import { X, Apple, Play, Download, QrCode, CheckCircle2, ShieldCheck, Sparkles } from 'lucide-react';
import iphoneMockupUrl from '../../assets/images/ht-logo.jpg';

export function DownloadModal({ isOpen, onClose }) {
  const [copied, setCopied] = React.useState(false);

  if (!isOpen) return null;

  const copyDownloadLink = () => {
    navigator.clipboard.writeText(window.location.origin + '/download');
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-black/80 backdrop-blur-md transition-opacity"
        onClick={onClose}
      />

      {/* Modal Dialog */}
      <div className="relative bg-[#0A0F1A] border border-[#D4AF37]/30 rounded-3xl max-w-2xl w-full p-6 sm:p-8 shadow-[0_25px_60px_-15px_rgba(212,175,55,0.25)] z-10 overflow-hidden">
        {/* Ambient Top Glow */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-80 h-32 bg-[#D4AF37]/15 blur-3xl rounded-full pointer-events-none" />

        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-5 right-5 p-2 rounded-xl bg-white/5 hover:bg-white/10 text-slate-400 hover:text-white transition-colors"
          aria-label="Close modal"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header */}
        <div className="text-center mb-6">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#D4AF37]/10 border border-[#D4AF37]/30 text-[#D4AF37] text-xs font-semibold uppercase tracking-wider mb-3">
            <Sparkles className="w-3.5 h-3.5" /> Mobile Application
          </div>
          <h3 className="text-2xl sm:text-3xl font-bold text-white tracking-tight">
            Download <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#D4AF37] via-[#FFF3B0] to-[#E5C158]">Hemi Ton</span>
          </h3>
          <p className="text-slate-400 text-sm mt-1 max-w-md mx-auto">
            Experience royal 12-seat spatial audio lounges, 3D celestial gifts, and live entertainment on iOS and Android.
          </p>
        </div>

        {/* Grid: Stores + QR */}
        <div className="grid sm:grid-cols-2 gap-5 mb-6">
          {/* Left Column: Direct App Store buttons */}
          <div className="space-y-3 flex flex-col justify-center">
            {/* iOS */}
            <a
              href="#app-store"
              onClick={(e) => { e.preventDefault(); alert('Redirecting to Apple App Store (Hemi Ton: Live Audio Spaces)...'); }}
              className="flex items-center gap-4 p-3.5 rounded-2xl bg-white/[0.04] hover:bg-white/[0.08] border border-white/10 hover:border-[#D4AF37]/40 transition-all group shadow-md"
            >
              <div className="w-11 h-11 rounded-xl bg-white/10 flex items-center justify-center text-white group-hover:scale-105 transition-transform">
                <Apple className="w-6 h-6" />
              </div>
              <div className="text-left">
                <div className="text-[11px] text-slate-400 uppercase tracking-wider">Download on the</div>
                <div className="text-base font-bold text-white tracking-tight">Apple App Store</div>
              </div>
            </a>

            {/* Android / Play Store */}
            <a
              href="#google-play"
              onClick={(e) => { e.preventDefault(); alert('Redirecting to Google Play Store (Hemi Ton: Live Audio Spaces)...'); }}
              className="flex items-center gap-4 p-3.5 rounded-2xl bg-white/[0.04] hover:bg-white/[0.08] border border-white/10 hover:border-[#D4AF37]/40 transition-all group shadow-md"
            >
              <div className="w-11 h-11 rounded-xl bg-emerald-500/10 flex items-center justify-center text-emerald-400 group-hover:scale-105 transition-transform">
                <Play className="w-6 h-6 fill-current" />
              </div>
              <div className="text-left">
                <div className="text-[11px] text-slate-400 uppercase tracking-wider">Get it on</div>
                <div className="text-base font-bold text-white tracking-tight">Google Play</div>
              </div>
            </a>

            {/* Direct APK */}
            <a
              href="#direct-apk"
              onClick={(e) => { e.preventDefault(); alert('Downloading Hemi Ton Direct APK v2.4.0 (SHA-256 Verified)...'); }}
              className="flex items-center gap-4 p-3.5 rounded-2xl bg-[#D4AF37]/10 hover:bg-[#D4AF37]/20 border border-[#D4AF37]/30 transition-all group shadow-md"
            >
              <div className="w-11 h-11 rounded-xl bg-[#D4AF37]/20 flex items-center justify-center text-[#D4AF37] group-hover:scale-105 transition-transform">
                <Download className="w-6 h-6" />
              </div>
              <div className="text-left">
                <div className="text-[11px] text-[#D4AF37] uppercase tracking-wider font-semibold">Direct Download</div>
                <div className="text-base font-bold text-white tracking-tight">Android APK (v2.4.0)</div>
              </div>
            </a>
          </div>

          {/* Right Column: QR Code Scan Container */}
          <div className="p-5 rounded-2xl bg-[#06090F] border border-white/10 flex flex-col items-center justify-center text-center">
            <div className="relative p-3 bg-white rounded-2xl shadow-xl mb-3">
              {/* High-fidelity CSS/SVG QR Code Mockup */}
              <div className="w-32 h-32 flex flex-col items-center justify-center bg-black rounded-lg p-2 relative overflow-hidden">
                <div className="absolute inset-2 border-2 border-dashed border-[#D4AF37]/60 rounded" />
                <QrCode className="w-20 h-20 text-[#D4AF37]" />
                <span className="text-[9px] font-mono text-[#D4AF37] mt-1 font-bold">HEMI TON APP</span>
              </div>
              <div className="absolute -bottom-2 -right-2 bg-[#D4AF37] text-black text-[10px] font-bold px-2 py-0.5 rounded-full shadow">
                SCAN ME
              </div>
            </div>
            <span className="text-xs font-medium text-slate-300">Point phone camera to install</span>
            <span className="text-[11px] text-slate-500 mt-0.5">Compatible with iOS 15+ & Android 9+</span>
          </div>
        </div>

        {/* Footer info & copy link */}
        <div className="pt-4 border-t border-white/10 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-400">
          <div className="flex items-center gap-2">
            <ShieldCheck className="w-4 h-4 text-[#D4AF37]" />
            <span>Official Verified Package • 100% Secure & Ad-Free</span>
          </div>
          <button
            onClick={copyDownloadLink}
            className="flex items-center gap-1.5 text-slate-300 hover:text-[#D4AF37] transition-colors"
          >
            {copied ? (
              <>
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                <span className="text-emerald-400 font-medium">Link Copied!</span>
              </>
            ) : (
              <span>Copy Direct Link</span>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}

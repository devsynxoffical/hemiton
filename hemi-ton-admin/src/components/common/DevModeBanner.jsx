// ============================================================
// Hemi Ton Admin — Development Mode / API Status Banner (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { ShieldAlert, Radio, CheckCircle2 } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export function DevModeBanner() {
  const { isMockDevSession } = useAuth();
  const isMockEnv = import.meta.env.VITE_USE_MOCK_API === 'true';
  const apiUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api';

  if (!isMockDevSession && !isMockEnv) {
    return (
      <div className="flex items-center justify-between border-b border-[#C6E7D5] bg-[#E7F4ED] px-4 py-2 text-xs text-[#2E7D52]">
        <div className="flex items-center gap-2">
          <CheckCircle2 className="h-4 w-4 text-[#2E7D52] shrink-0" />
          <span className="font-semibold">Live Backend Connected:</span>
          <code className="rounded bg-[#FFFFFF] px-2 py-0.5 text-[11px] font-mono text-[#263957] border border-[#C6E7D5]">
            {apiUrl}
          </code>
        </div>
      </div>
    );
  }

  return (
    <div className="flex items-center justify-between border-b border-[#F7E1C0] bg-[#FDF4E7] px-4 py-2 text-xs text-[#94601A]">
      <div className="flex items-center gap-2.5">
        <ShieldAlert className="h-4 w-4 shrink-0 text-[#94601A]" />
        <div>
          <span className="font-bold text-[#94601A]">DEVELOPMENT MOCK MODE:</span>{' '}
          <span className="text-[#845517]">
            Hemi Ton backend not yet running. Displaying UI layout with clearly identified development placeholders.
          </span>
        </div>
      </div>
      <div className="flex items-center gap-2.5">
        <span className="hidden sm:inline-flex items-center gap-1 rounded bg-[#FFFFFF] border border-[#F7E1C0] px-2 py-0.5 text-[11px] font-mono text-[#94601A]">
          Target: {apiUrl}
        </span>
        <span className="inline-flex items-center gap-1 rounded-full border border-[#E9C899] bg-[#F9EAD4] px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider text-[#94601A]">
          <Radio className="h-3 w-3 text-[#94601A] animate-pulse" /> Simulated
        </span>
      </div>
    </div>
  );
}

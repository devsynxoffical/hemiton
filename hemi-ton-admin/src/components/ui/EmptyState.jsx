// ============================================================
// Hemi Ton Admin — Empty State Component (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { Inbox, AlertCircle } from 'lucide-react';

export function EmptyState({
  title = 'No Data Found',
  description = 'No records match the selected parameters or query.',
  icon: Icon = Inbox,
  action,
  isDevPlaceholder = false,
}) {
  return (
    <div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-[#D8E0EC] bg-[#F5F7FB] px-6 py-12 text-center">
      <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#DCE6F5] text-[#5979AC] border border-[#C8D7EC] shadow-2xs">
        <Icon className="h-6 w-6" />
      </div>
      <h5 className="mt-3 font-heading text-sm font-semibold text-[#263957]">{title}</h5>
      <p className="mt-1 max-w-sm text-xs text-[#65738A]">{description}</p>
      {isDevPlaceholder && (
        <span className="mt-3 inline-flex items-center gap-1.5 rounded-md border border-[#F7E1C0] bg-[#FDF4E7] px-2.5 py-1 text-[11px] font-mono text-[#94601A]">
          <AlertCircle className="h-3.5 w-3.5 text-[#94601A]" /> Backend Endpoint Under Construction
        </span>
      )}
      {action && <div className="mt-4">{action}</div>}
    </div>
  );
}

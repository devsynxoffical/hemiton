// ============================================================
// Hemi Ton Admin — Card UI Component (Cloud Blue + Slate)
// ============================================================

import React from 'react';

export function Card({ children, className = '', highlight = false }) {
  return (
    <div
      className={`rounded-xl border border-[#D8E0EC] bg-white p-5 shadow-2xs transition-shadow hover:shadow-xs ${
        highlight ? 'border-[#91A9CE] ring-2 ring-[#DCE6F5]' : ''
      } ${className}`}
    >
      {children}
    </div>
  );
}

export function CardHeader({ title, subtitle, action, badge }) {
  return (
    <div className="mb-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between border-b border-[#E8EDF5] pb-3.5">
      <div>
        <div className="flex items-center gap-2">
          <h4 className="font-heading text-base font-bold tracking-tight text-[#263957]">{title}</h4>
          {badge}
        </div>
        {subtitle && <p className="mt-0.5 text-xs text-[#65738A]">{subtitle}</p>}
      </div>
      {action && <div className="flex items-center gap-2">{action}</div>}
    </div>
  );
}

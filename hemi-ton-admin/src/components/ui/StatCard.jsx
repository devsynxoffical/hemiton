// ============================================================
// Hemi Ton Admin — StatCard UI Component (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { TrendingUp, TrendingDown } from 'lucide-react';

export function StatCard({
  title,
  value,
  icon: Icon,
  change,
  changeLabel = 'vs last period',
  isPositive = true,
  accent = 'cloud', // 'cloud' | 'secondary' | 'amber' | 'soft'
  isPlaceholder = false,
}) {
  const accentConfigs = {
    cloud: {
      iconBg: 'bg-[#DCE6F5] text-[#5979AC] border-[#C8D7EC]',
      hoverBorder: 'hover:border-[#91A9CE]',
    },
    secondary: {
      iconBg: 'bg-[#E3E9F2] text-[#7894BE] border-[#D8E0EC]',
      hoverBorder: 'hover:border-[#7894BE]',
    },
    amber: {
      iconBg: 'bg-[#FDF4E7] text-[#94601A] border-[#F7E1C0]',
      hoverBorder: 'hover:border-[#E9C899]',
    },
    soft: {
      iconBg: 'bg-[#E7F4ED] text-[#2E7D52] border-[#C6E7D5]',
      hoverBorder: 'hover:border-[#A4D4B9]',
    },
  };

  const style = accentConfigs[accent] || accentConfigs.cloud;

  return (
    <div
      className={`relative overflow-hidden rounded-xl border border-[#D8E0EC] bg-white p-5 shadow-2xs transition-all duration-200 hover:-translate-y-0.5 hover:shadow-xs ${style.hoverBorder}`}
    >
      <div className="flex items-start justify-between">
        <div>
          <span className="text-xs font-medium text-[#65738A] tracking-wide">
            {title}
          </span>
          <div className="mt-2 flex items-baseline gap-2">
            <h3 className="font-heading text-2xl font-bold tracking-tight text-[#263957] lg:text-3xl">
              {value}
            </h3>
            {isPlaceholder && (
              <span className="rounded bg-[#E3E9F2] px-1.5 py-0.5 text-[10px] font-mono text-[#65738A] border border-[#D8E0EC]">
                Simulated
              </span>
            )}
          </div>
        </div>

        {Icon && (
          <div className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-xl border ${style.iconBg}`}>
            <Icon className="h-5 w-5" />
          </div>
        )}
      </div>

      {(change || changeLabel) && (
        <div className="mt-4 flex items-center gap-1.5 text-xs">
          {change && (
            <span
              className={`inline-flex items-center gap-0.5 font-semibold ${
                isPositive ? 'text-[#2E7D52]' : 'text-[#9C3838]'
              }`}
            >
              {isPositive ? <TrendingUp className="h-3.5 w-3.5" /> : <TrendingDown className="h-3.5 w-3.5" />}
              {change}
            </span>
          )}
          <span className="text-[#65738A]">{changeLabel}</span>
        </div>
      )}
    </div>
  );
}

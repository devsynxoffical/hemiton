// ============================================================
// Hemi Ton Admin Console — Animated Pi / Donut Visualizer (JSX)
// Dynamic clockwise sweep animations on initial load, reload & page change
// ============================================================

import React, { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import { RotateCw, Sparkles } from 'lucide-react';
import { formatCompact } from '../../utils/format';

const CustomPiTooltip = ({ active, payload }) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    return (
      <div className="rounded-xl border border-[#243554] bg-[#0A101C]/95 p-3 shadow-2xl backdrop-blur-md text-xs z-50 min-w-[140px]">
        <div className="flex items-center gap-2 mb-1">
          <span
            className="h-2.5 w-2.5 rounded-full"
            style={{ backgroundColor: data.color }}
          />
          <p className="font-bold text-white">{data.name}</p>
        </div>
        <p className="text-slate-300 font-semibold text-sm">
          {typeof data.value === 'number' && data.value > 1000
            ? formatCompact(data.value)
            : data.value}
          <span className="text-slate-400 font-normal text-xs ml-1.5">
            ({data.percent || `${Math.round(data.value)}%`})
          </span>
        </p>
        {data.subtext && (
          <p className="text-[10px] text-slate-500 mt-1 border-t border-slate-800/80 pt-1">
            {data.subtext}
          </p>
        )}
      </div>
    );
  }
  return null;
};

export function AnimatedPiGraph({
  title,
  subtitle,
  data = [],
  centerValue,
  centerLabel,
  icon: Icon,
  badge = 'Live Spectrum',
  height = 240,
  innerRadius = 62,
  outerRadius = 88,
  className = '',
}) {
  const location = useLocation();
  const [animKey, setAnimKey] = useState(0);
  const [activeIndex, setActiveIndex] = useState(null);

  // Re-trigger animation on reload or page/route change
  useEffect(() => {
    setAnimKey((prev) => prev + 1);
  }, [location.pathname, location.key]);

  const handleRefresh = (e) => {
    e.stopPropagation();
    setAnimKey((prev) => prev + 1);
  };

  return (
    <div
      className={`rounded-2xl border border-[#182337] bg-gradient-to-b from-[#0E1524] to-[#0A0F1A] p-5 shadow-xl hover:border-[#D4AF37]/30 transition-all duration-300 flex flex-col justify-between ${className}`}
    >
      {/* Header */}
      <div className="flex items-start justify-between gap-3 mb-2">
        <div>
          <div className="flex items-center gap-2">
            {Icon && <Icon className="h-4 w-4 text-[#D4AF37]" />}
            <h3 className="text-sm font-bold text-white tracking-wide">{title}</h3>
          </div>
          {subtitle && (
            <p className="text-xs text-slate-400 mt-0.5">{subtitle}</p>
          )}
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={handleRefresh}
            title="Re-animate graph"
            className="p-1 rounded-lg text-slate-500 hover:text-white hover:bg-[#1A253B] transition-colors"
          >
            <RotateCw className="h-3.5 w-3.5" />
          </button>
        </div>
      </div>

      {/* Donut Container with centered animated metrics */}
      <div className="relative my-auto" style={{ height: `${height}px` }}>
        <ResponsiveContainer width="100%" height="100%">
          <PieChart key={animKey}>
            <Tooltip content={<CustomPiTooltip />} />
            <Pie
              data={data}
              dataKey="value"
              nameKey="name"
              cx="50%"
              cy="50%"
              innerRadius={innerRadius}
              outerRadius={outerRadius}
              paddingAngle={4}
              cornerRadius={5}
              isAnimationActive={true}
              animationBegin={100}
              animationDuration={1100}
              animationEasing="ease-out"
              onMouseEnter={(_, index) => setActiveIndex(index)}
              onMouseLeave={() => setActiveIndex(null)}
            >
              {data.map((entry, index) => (
                <Cell
                  key={`cell-${index}`}
                  fill={entry.color}
                  stroke="#0E1524"
                  strokeWidth={2}
                  className="transition-all duration-200 cursor-pointer"
                  style={{
                    filter:
                      activeIndex === index
                        ? `drop-shadow(0 0 8px ${entry.color}90)`
                        : 'none',
                    transform: activeIndex === index ? 'scale(1.03)' : 'scale(1)',
                    transformOrigin: 'center center',
                  }}
                />
              ))}
            </Pie>
          </PieChart>
        </ResponsiveContainer>

        {/* Center Indicator */}
        <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center text-center">
          <div key={`center-${animKey}`} className="animate-pi-center">
            <span className="text-lg font-black text-white tracking-tight drop-shadow-sm font-sans block">
              {centerValue}
            </span>
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest block mt-0.5">
              {centerLabel}
            </span>
          </div>
        </div>
      </div>

      {/* Legend Grid */}
      <div className="mt-3 pt-3 border-t border-[#182337] grid grid-cols-2 gap-2 text-xs">
        {data.map((item, idx) => (
          <div
            key={idx}
            className={`flex items-center justify-between p-1.5 rounded-lg transition-colors cursor-pointer ${
              activeIndex === idx
                ? 'bg-[#152033] border border-[#223352]'
                : 'hover:bg-[#121A2B]'
            }`}
            onMouseEnter={() => setActiveIndex(idx)}
            onMouseLeave={() => setActiveIndex(null)}
          >
            <div className="flex items-center gap-2 min-w-0">
              <span
                className="h-2.5 w-2.5 rounded-full flex-shrink-0"
                style={{ backgroundColor: item.color }}
              />
              <span className="text-slate-300 font-medium truncate text-[11px]">
                {item.name}
              </span>
            </div>
            <span className="text-white font-bold ml-2 text-[11px]">
              {item.percent || `${item.value}%`}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

export default AnimatedPiGraph;

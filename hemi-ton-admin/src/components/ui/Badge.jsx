// ============================================================
// Hemi Ton Admin — Badge UI Component (Cloud Blue + Slate)
// ============================================================

import React from 'react';

export function Badge({
  children,
  variant = 'default', // 'default' | 'cloud' | 'secondary' | 'success' | 'warning' | 'danger' | 'outline'
  size = 'md', // 'sm' | 'md'
  dot = false,
  className = '',
}) {
  const variantStyles = {
    default: 'bg-[#E3E9F2] text-[#263957] border-[#D8E0EC]',
    cloud: 'bg-[#DCE6F5] text-[#263957] border-[#C8D7EC]',
    secondary: 'bg-[#F0F4FA] text-[#5979AC] border-[#D8E0EC]',
    success: 'bg-[#E7F4ED] text-[#2E7D52] border-[#C6E7D5]',
    warning: 'bg-[#FDF4E7] text-[#94601A] border-[#F7E1C0]',
    danger: 'bg-[#FCEBEB] text-[#9C3838] border-[#F6CACA]',
    outline: 'border-[#D8E0EC] text-[#65738A] bg-white',
  };

  const dotColors = {
    default: 'bg-[#65738A]',
    cloud: 'bg-[#5979AC]',
    secondary: 'bg-[#7894BE]',
    success: 'bg-[#2E7D52]',
    warning: 'bg-[#94601A]',
    danger: 'bg-[#9C3838]',
    outline: 'bg-[#8792A4]',
  };

  const sizeStyles = {
    sm: 'text-[11px] px-2 py-0.5 font-medium',
    md: 'text-xs px-2.5 py-1 font-semibold',
  };

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full border tracking-wide font-medium ${
        variantStyles[variant] || variantStyles.default
      } ${sizeStyles[size]} ${className}`}
    >
      {dot && <span className={`h-1.5 w-1.5 rounded-full ${dotColors[variant] || 'bg-[#65738A]'}`} />}
      {children}
    </span>
  );
}

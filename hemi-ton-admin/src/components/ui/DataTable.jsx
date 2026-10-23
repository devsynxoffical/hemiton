// ============================================================
// Hemi Ton Admin — DataTable Component (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { EmptyState } from './EmptyState';

export function DataTable({
  columns = [],
  data = [],
  keyField = 'id',
  isLoading = false,
  emptyTitle = 'No records available',
  emptyDescription = 'There are currently no items in this ledger.',
  isDevPlaceholder = false,
}) {
  if (isLoading) {
    return (
      <div className="flex h-44 w-full items-center justify-center rounded-xl bg-[#F5F7FB] border border-[#D8E0EC]">
        <div className="flex items-center gap-2.5 text-[#5979AC]">
          <div className="h-5 w-5 animate-spin rounded-full border-2 border-[#5979AC] border-t-transparent" />
          <span className="text-xs font-medium text-[#65738A]">Retrieving dataset...</span>
        </div>
      </div>
    );
  }

  if (!data || data.length === 0) {
    return (
      <EmptyState
        title={emptyTitle}
        description={emptyDescription}
        isDevPlaceholder={isDevPlaceholder}
      />
    );
  }

  return (
    <div className="overflow-x-auto rounded-xl border border-[#D8E0EC] bg-white">
      <table className="w-full text-left text-xs text-[#263957]">
        <thead className="border-b border-[#D8E0EC] bg-[#F5F7FB] text-[11px] font-semibold uppercase tracking-wider text-[#65738A] font-mono">
          <tr>
            {columns.map((col, idx) => (
              <th
                key={col.key || idx}
                className={`px-4 py-3 ${col.className || ''}`}
              >
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-[#E8EDF5]">
          {data.map((row, rowIdx) => (
            <tr
              key={row[keyField] || rowIdx}
              className="transition-colors hover:bg-[#E8EDF5]"
            >
              {columns.map((col, colIdx) => (
                <td
                  key={col.key || colIdx}
                  className={`px-4 py-3.5 ${col.className || ''}`}
                >
                  {col.render ? col.render(row[col.key], row, rowIdx) : row[col.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

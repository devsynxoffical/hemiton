// ============================================================
// Hemi Ton Admin — Live Rooms Operations (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { Radio, Plus } from 'lucide-react';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { EmptyState } from '../../components/ui/EmptyState';

export function LiveRoomsPage() {
  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="font-heading text-2xl font-extrabold tracking-tight text-[#263957]">
            Active Live Rooms & Audio Spaces
          </h1>
          <p className="mt-1 text-xs text-[#65738A]">
            Real-time multi-speaker party rooms, agora audio monitoring, and room lock management.
          </p>
        </div>
        <button
          disabled
          className="inline-flex items-center gap-2 rounded-xl bg-[#5979AC]/60 px-4 py-2 text-xs font-semibold text-white cursor-not-allowed opacity-60 shadow-2xs"
        >
          <Plus className="h-4 w-4" /> Create Broadcast Room
        </button>
      </div>

      <Card>
        <CardHeader
          title="Room Management Spectrum"
          subtitle="Awaiting Hemi Ton backend socket service deployment"
          badge={<Badge variant="warning" size="sm" dot>Backend Endpoint Pending</Badge>}
        />
        <EmptyState
          icon={Radio}
          title="Live Rooms Telemetry Offline"
          description="The Hemi Ton real-time room dispatch service has not yet been registered. Once the dedicated backend socket server is running on port 5000, active party rooms and microphone statuses will populate here automatically."
          isDevPlaceholder={true}
        />
      </Card>
    </div>
  );
}

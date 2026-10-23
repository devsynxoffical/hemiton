// ============================================================
// Hemi Ton Admin — Hosts & Agency Talent Operations (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { Crown } from 'lucide-react';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { EmptyState } from '../../components/ui/EmptyState';

export function HostsAgenciesPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-extrabold tracking-tight text-[#263957]">
          Hosts & Agency Talent Management
        </h1>
        <p className="mt-1 text-xs text-[#65738A]">
          Agency tier governance, host verification approvals, commission rate adjustments, and BD centers.
        </p>
      </div>

      <Card>
        <CardHeader
          title="Talent Verification Queue"
          subtitle="Pending agency applications and host auditions"
          badge={<Badge variant="warning" size="sm" dot>Backend Endpoint Pending</Badge>}
        />
        <EmptyState
          icon={Crown}
          title="Talent Pipeline Pending Backend"
          description="Verification workflows and agency commission policies will be wired once the Hemi Ton talent management API endpoints are established."
          isDevPlaceholder={true}
        />
      </Card>
    </div>
  );
}

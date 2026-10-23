// ============================================================
// Hemi Ton Admin — Moderation & Trust Center (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { ShieldAlert } from 'lucide-react';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { EmptyState } from '../../components/ui/EmptyState';

export function ModerationPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-extrabold tracking-tight text-[#263957]">
          Content Moderation & Trust Center
        </h1>
        <p className="mt-1 text-xs text-[#65738A]">
          User reports, automated keyword flaggers, ban suspensions, and safety audits.
        </p>
      </div>

      <Card>
        <CardHeader
          title="Moderation Incident Feed"
          subtitle="Flagged messages, inappropriate broadcasts & user reports"
          badge={<Badge variant="warning" size="sm" dot>Backend Endpoint Pending</Badge>}
        />
        <EmptyState
          icon={ShieldAlert}
          title="Moderation Queue Offline"
          description="Content violation events and AI flag triggers will connect to this console when the Hemi Ton moderation pipeline is activated."
          isDevPlaceholder={true}
        />
      </Card>
    </div>
  );
}

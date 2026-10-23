// ============================================================
// Hemi Ton Admin — User & Talent Directory (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { Users } from 'lucide-react';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { EmptyState } from '../../components/ui/EmptyState';

export function UsersPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-extrabold tracking-tight text-[#263957]">
          User Accounts & Profiles
        </h1>
        <p className="mt-1 text-xs text-[#65738A]">
          Account moderation, role provisioning, wallet balances, and user restriction states.
        </p>
      </div>

      <Card>
        <CardHeader
          title="Global User Registry"
          subtitle="Awaiting Hemi Ton user directory schema & endpoints"
          badge={<Badge variant="warning" size="sm" dot>Backend Endpoint Pending</Badge>}
        />
        <EmptyState
          icon={Users}
          title="User Directory Unconnected"
          description="Dedicated user management endpoints (/v1/admin/users) will connect here once the Hemi Ton backend is established. To avoid cross-contamination, user records from ZeParty are strictly decoupled."
          isDevPlaceholder={true}
        />
      </Card>
    </div>
  );
}

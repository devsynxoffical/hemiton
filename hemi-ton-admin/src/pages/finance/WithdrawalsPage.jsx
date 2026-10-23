// ============================================================
// Hemi Ton Admin — Withdrawal Approvals (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { Wallet } from 'lucide-react';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { EmptyState } from '../../components/ui/EmptyState';

export function WithdrawalsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-extrabold tracking-tight text-[#263957]">
          Withdrawal Requests & Payout Approvals
        </h1>
        <p className="mt-1 text-xs text-[#65738A]">
          Executive settlement approvals, manual payout verifications, and fraud score inspection.
        </p>
      </div>

      <Card>
        <CardHeader
          title="Pending Withdrawal Queue"
          subtitle="Awaiting Hemi Ton financial settlement domain endpoints"
          badge={<Badge variant="warning" size="sm" dot>Backend Endpoint Pending</Badge>}
        />
        <EmptyState
          icon={Wallet}
          title="Financial Queue Offline"
          description="Settlement approval pipelines and banking webhook handlers will integrate with this view upon deployment of the Hemi Ton financial service."
          isDevPlaceholder={true}
        />
      </Card>
    </div>
  );
}

// ============================================================
// Hemi Ton Admin — Transaction Ledger (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { Receipt } from 'lucide-react';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { EmptyState } from '../../components/ui/EmptyState';

export function TransactionsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-extrabold tracking-tight text-[#263957]">
          Transaction Ledger & Coin Economy
        </h1>
        <p className="mt-1 text-xs text-[#65738A]">
          Double-entry financial journal, coin purchases, virtual gift tipping, and chargeback logs.
        </p>
      </div>

      <Card>
        <CardHeader
          title="Global Financial Journal"
          subtitle="Audit ledger of all monetary movements"
          badge={<Badge variant="warning" size="sm" dot>Backend Endpoint Pending</Badge>}
        />
        <EmptyState
          icon={Receipt}
          title="Ledger Service Pending"
          description="Real-time transaction entries will stream directly into this view as soon as the Hemi Ton ledger and payment gateway webhooks are established."
          isDevPlaceholder={true}
        />
      </Card>
    </div>
  );
}

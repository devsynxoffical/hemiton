// ============================================================
// Hemi Ton Admin — System & Environment Settings (Cloud Blue + Slate)
// ============================================================

import React, { useState } from 'react';
import { Settings, Server, Shield, CheckCircle2, AlertCircle, RefreshCw } from 'lucide-react';
import { Card, CardHeader } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import apiClient from '../../services/apiClient';

export function SettingsPage() {
  const [testingHealth, setTestingHealth] = useState(false);
  const [healthStatus, setHealthStatus] = useState(null);

  const checkBackendHealth = async () => {
    setTestingHealth(true);
    setHealthStatus(null);
    try {
      const res = await apiClient.get('/health', { timeout: 3000 });
      setHealthStatus({
        ok: true,
        data: res.data,
        message: 'Hemi Ton backend service responded successfully.',
      });
    } catch (err) {
      setHealthStatus({
        ok: false,
        message: err.message || 'Hemi Ton backend unreachable at configured endpoint.',
      });
    } finally {
      setTestingHealth(false);
    }
  };

  const envVars = [
    { name: 'VITE_APP_TITLE', value: import.meta.env.VITE_APP_TITLE || 'Hemi Ton Admin', desc: 'Application header title' },
    { name: 'VITE_API_BASE_URL', value: import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api', desc: 'Hemi Ton backend API base URL' },
    { name: 'VITE_BACKEND_PROXY_TARGET', value: import.meta.env.VITE_BACKEND_PROXY_TARGET || 'http://localhost:5000', desc: 'Vite reverse proxy target' },
    { name: 'VITE_USE_MOCK_API', value: import.meta.env.VITE_USE_MOCK_API || 'true', desc: 'Mock simulation switch for offline local dev' },
    { name: 'VITE_API_TIMEOUT', value: `${import.meta.env.VITE_API_TIMEOUT || 30000} ms`, desc: 'HTTP request timeout threshold' },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-heading text-2xl font-extrabold tracking-tight text-[#263957]">
          System & Environment Configuration
        </h1>
        <p className="mt-1 text-xs text-[#65738A]">
          Environment inspection, runtime diagnostics, and architectural boundaries.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Environment Variables Inspection */}
        <Card>
          <CardHeader
            title="Local Environment Parameters"
            subtitle="Current Vite runtime configuration variables"
            badge={<Badge variant="cloud" size="sm">Config</Badge>}
          />
          <div className="space-y-3">
            {envVars.map((item, idx) => (
              <div
                key={idx}
                className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-1 rounded-xl border border-[#D8E0EC] bg-[#F5F7FB] p-3"
              >
                <div>
                  <span className="font-mono text-xs font-semibold text-[#5979AC]">{item.name}</span>
                  <p className="text-[11px] text-[#65738A]">{item.desc}</p>
                </div>
                <code className="rounded bg-white border border-[#D8E0EC] px-2 py-1 font-mono text-xs text-[#263957] shadow-2xs">
                  {item.value}
                </code>
              </div>
            ))}
          </div>
        </Card>

        {/* Backend Health Diagnostics */}
        <Card>
          <CardHeader
            title="Backend Connectivity Diagnostics"
            subtitle="Ping target Hemi Ton backend health endpoint"
            badge={<Badge variant="outline" size="sm">Diagnostics</Badge>}
          />
          <div className="space-y-4">
            <p className="text-xs text-[#65738A] leading-relaxed">
              Verifies if a dedicated Hemi Ton API service is running on the local target address. In accordance with architectural safety rules, the admin panel never connects to ZeParty production or reference backends.
            </p>

            <button
              onClick={checkBackendHealth}
              disabled={testingHealth}
              className="inline-flex items-center gap-2 rounded-xl bg-[#5979AC] px-4 py-2.5 text-xs font-bold uppercase tracking-wider text-white shadow-2xs hover:bg-[#496A9C] disabled:opacity-50 transition-all cursor-pointer"
            >
              <RefreshCw className={`h-4 w-4 ${testingHealth ? 'animate-spin' : ''}`} />
              <span>{testingHealth ? 'Pinging Endpoint...' : 'Run Connectivity Check'}</span>
            </button>

            {healthStatus && (
              <div
                className={`flex items-start gap-3 rounded-xl border p-4 text-xs ${
                  healthStatus.ok
                    ? 'border-[#C6E7D5] bg-[#E7F4ED] text-[#2E7D52]'
                    : 'border-[#F7E1C0] bg-[#FDF4E7] text-[#94601A]'
                }`}
              >
                {healthStatus.ok ? (
                  <CheckCircle2 className="h-5 w-5 shrink-0 text-[#2E7D52]" />
                ) : (
                  <AlertCircle className="h-5 w-5 shrink-0 text-[#94601A]" />
                )}
                <div>
                  <h6 className="font-bold">
                    {healthStatus.ok ? 'Connection Established' : 'Endpoint Offline (Expected)'}
                  </h6>
                  <p className="mt-1 text-[#263957]">{healthStatus.message}</p>
                  {!healthStatus.ok && (
                    <p className="mt-2 text-[11px] text-[#65738A]">
                      Recommendation: Keep <code className="text-[#5979AC] font-mono">VITE_USE_MOCK_API=true</code> active while building UI features until the new Hemi Ton backend is ready.
                    </p>
                  )}
                </div>
              </div>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}

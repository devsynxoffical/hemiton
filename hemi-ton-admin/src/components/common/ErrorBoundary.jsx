// ============================================================
// Hemi Ton Admin — Error Boundary (Cloud Blue + Slate)
// ============================================================

import React from 'react';
import { AlertTriangle, RefreshCw } from 'lucide-react';

export class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('[Hemi Ton ErrorBoundary Caught]', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="m-6 rounded-xl border border-[#F6CACA] bg-[#FCEBEB] p-6 text-[#263957] shadow-2xs">
          <div className="flex items-center gap-3 text-[#9C3838]">
            <AlertTriangle className="h-5 w-5 shrink-0" />
            <h3 className="text-base font-bold">Component Render Error</h3>
          </div>
          <p className="mt-2 text-xs text-[#802D2D]">
            {this.state.error?.message || 'An unexpected error occurred while rendering this section.'}
          </p>
          <button
            onClick={() => {
              this.setState({ hasError: false, error: null });
              window.location.reload();
            }}
            className="mt-4 inline-flex items-center gap-2 rounded-lg bg-white border border-[#F6CACA] px-3.5 py-2 text-xs font-semibold text-[#9C3838] hover:bg-[#F9DDDD] transition-colors shadow-2xs"
          >
            <RefreshCw className="h-3.5 w-3.5" /> Reload View
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

// ============================================================
// Hemi Ton Admin — Executive Sign In Page (Cloud Blue + Slate)
// ============================================================

import React, { useState } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { ShieldCheck, Lock, User, AlertCircle, Sparkles, ArrowRight } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export function LoginPage() {
  const [username, setUsername] = useState('admin');
  const [password, setPassword] = useState('admin123');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const from = location.state?.from?.pathname || '/admin';

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setLoading(true);

    try {
      await login({
        usernameOrEmail: username,
        password: password,
      });
      navigate(from, { replace: true });
    } catch (err) {
      setErrorMessage(err.message || 'Authentication failed. Please verify credentials.');
    } finally {
      setLoading(false);
    }
  };

  const handleQuickDemoFill = () => {
    setUsername('admin');
    setPassword('admin123');
  };

  return (
    <div className="relative flex min-h-screen items-center justify-center bg-[#E9EEF7] p-4 selection:bg-[#5979AC] selection:text-white">
      {/* Background Subtle Soft Aura */}
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute -top-32 -left-32 h-96 w-96 rounded-full bg-[#DCE6F5]/70 blur-3xl"></div>
        <div className="absolute -bottom-32 -right-32 h-96 w-96 rounded-full bg-[#E3E9F2]/80 blur-3xl"></div>
      </div>

      <div className="relative w-full max-w-md">
        {/* Brand Card */}
        <div className="rounded-2xl border border-[#D8E0EC] bg-white p-8 shadow-xs">
          {/* Logo & Header */}
          <div className="flex flex-col items-center text-center">
            <div className="flex h-20 w-20 items-center justify-center rounded-2xl overflow-hidden border border-[#D8E0EC] shadow-md bg-black ring-2 ring-[#5979AC]/20">
              <img src="/ht-logo.jpg" alt="HT Hemi Ton" className="h-full w-full object-cover" />
            </div>
            <h1 className="mt-4 font-heading text-2xl font-extrabold tracking-tight text-[#263957]">
              HEMI TON
            </h1>
            <p className="mt-1 text-xs font-mono tracking-widest text-[#5979AC] font-semibold uppercase">
              Operations & Admin Console
            </p>
            <p className="mt-2 text-xs text-[#65738A]">
              Authorized personnel only. All access attempts are recorded.
            </p>
          </div>

          {/* Error Message */}
          {errorMessage && (
            <div className="mt-6 flex items-start gap-2.5 rounded-xl border border-[#F6CACA] bg-[#FCEBEB] p-3 text-xs text-[#9C3838]">
              <AlertCircle className="h-4 w-4 shrink-0 text-[#9C3838]" />
              <span>{errorMessage}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} className="mt-6 space-y-4">
            <div>
              <label className="block text-xs font-medium text-[#263957]">
                Username or Email
              </label>
              <div className="relative mt-1.5">
                <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 text-[#65738A]">
                  <User className="h-4 w-4" />
                </div>
                <input
                  type="text"
                  required
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  className="w-full rounded-xl border border-[#D8E0EC] bg-white py-2.5 pl-10 pr-3.5 text-xs text-[#263957] placeholder-[#8792A4] focus:border-[#5979AC] focus:outline-none focus:ring-2 focus:ring-[#DCE6F5] transition-all shadow-2xs"
                  placeholder="Enter administrator username"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-medium text-[#263957]">
                Password
              </label>
              <div className="relative mt-1.5">
                <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 text-[#65738A]">
                  <Lock className="h-4 w-4" />
                </div>
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full rounded-xl border border-[#D8E0EC] bg-white py-2.5 pl-10 pr-3.5 text-xs text-[#263957] placeholder-[#8792A4] focus:border-[#5979AC] focus:outline-none focus:ring-2 focus:ring-[#DCE6F5] transition-all shadow-2xs"
                  placeholder="••••••••••••"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="mt-6 flex w-full items-center justify-center gap-2 rounded-xl bg-[#5979AC] py-2.5 text-xs font-bold uppercase tracking-wider text-white shadow-2xs transition-all hover:bg-[#496A9C] disabled:opacity-60 cursor-pointer"
            >
              {loading ? (
                <div className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
              ) : (
                <>
                  <span>Sign In to Console</span>
                  <ArrowRight className="h-4 w-4" />
                </>
              )}
            </button>
          </form>

          {/* Quick Demo Assist */}
          <div className="mt-6 border-t border-[#E8EDF5] pt-4 text-center">
            <button
              type="button"
              onClick={handleQuickDemoFill}
              className="inline-flex items-center gap-1.5 text-xs font-medium text-[#5979AC] hover:text-[#263957] transition-colors"
            >
              <ShieldCheck className="h-3.5 w-3.5" />
              <span>Fill Default Local Admin Credentials</span>
            </button>
          </div>
        </div>

        {/* Footer info */}
        <div className="mt-6 flex flex-col items-center gap-2 font-mono text-[11px] text-[#8792A4]">
          <Link
            to="/"
            className="text-[#5979AC] hover:underline font-sans font-semibold text-xs"
          >
            ← Return to Hemi Ton Public Website
          </Link>
          <span>Hemi Ton Operations Center • Cloud Blue + Slate Theme</span>
        </div>
      </div>
    </div>
  );
}

// ============================================================
// Hemi Ton Admin Console — Executive Sign In (JSX)
// Client Verification Mode with Decoupled Backend & 1-Click Login
// ============================================================

import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Eye, EyeOff, Lock, User, Shield, ArrowRight } from 'lucide-react';
import { useAuth } from '../../hooks/useAuth';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import hemiTonLogo from '../../assets/images/ht-logo.jpg';

export function AdminLogin() {
  const { login, isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const from = '/admin';

  const [credentials, setCredentials] = useState({ username: 'admin', password: 'password' });
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  useEffect(() => {
    if (isAuthenticated) {
      navigate(from, { replace: true });
    }
  }, [isAuthenticated, navigate, from]);

  const handleSignIn = async (creds) => {
    const target = creds || credentials;
    setError(null);
    setIsLoading(true);
    try {
      await login(target);
      navigate(from, { replace: true });
    } catch (err) {
      setError(err.message || 'Authentication failed. Please verify credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    await handleSignIn(credentials);
  };

  return (
    <div className="min-h-screen bg-[#070A12] flex items-center justify-center p-4 relative overflow-hidden selection:bg-[#D4AF37] selection:text-black">
      {/* Ambient background glows matching Hemi Ton Gold & Deep Blue */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage: `radial-gradient(circle at 50% 15%, rgba(212,175,55,0.09) 0%, transparent 45%),
                            radial-gradient(circle at 85% 75%, rgba(37,99,235,0.06) 0%, transparent 45%),
                            radial-gradient(circle at 15% 85%, rgba(212,175,55,0.04) 0%, transparent 50%)`,
        }}
        aria-hidden="true"
      />

      {/* Subtle grid mesh overlay */}
      <div 
        className="absolute inset-0 opacity-[0.03] pointer-events-none"
        style={{
          backgroundImage: 'linear-gradient(#fff 1px, transparent 1px), linear-gradient(90deg, #fff 1px, transparent 1px)',
          backgroundSize: '40px 40px'
        }}
      />

      <div className="relative w-full max-w-md z-10">
        {/* Emblem & Branding Header */}
        <div className="mb-8 flex flex-col items-center text-center">
          <div className="relative mb-4 group">
            <div className="absolute -inset-1 rounded-2xl bg-gradient-to-r from-[#D4AF37] to-[#F5E5B8] opacity-30 blur-md group-hover:opacity-60 transition duration-500" />
            <div className="relative flex h-24 w-24 items-center justify-center rounded-2xl bg-[#0C121E] border border-[#D4AF37]/40 p-1.5 shadow-2xl shadow-black/80">
              <img
                src={hemiTonLogo}
                alt="Hemi Ton 3D Emblem"
                className="h-full w-full rounded-xl object-cover"
              />
            </div>
          </div>

          <h1 className="text-3xl font-extrabold text-white tracking-tight font-serif flex items-center justify-center gap-2">
            <span>HEMI TON</span>
          </h1>
          <p className="mt-1 text-xs font-semibold text-[#D4AF37] uppercase tracking-widest bg-[#D4AF37]/10 px-3 py-1 rounded-full border border-[#D4AF37]/25 flex items-center gap-1.5">
            <Shield className="h-3 w-3" />
            Operations & Intelligence Console
          </p>

          <div className="mt-2.5 flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[11px] font-medium">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-400 animate-pulse" />
            <span>Client Testing Mode · Backend Decoupled</span>
          </div>
        </div>

        {/* Login Box */}
        <div className="rounded-2xl border border-[#1A2438] bg-[#0E1524]/90 p-7 shadow-2xl shadow-black/90 backdrop-blur-xl">
          <div className="mb-6">
            <h2 className="text-lg font-bold text-white tracking-wide">Executive Sign In</h2>
            <p className="mt-1 text-xs text-slate-400">
              Enter your administrator credentials to access the console.
            </p>
          </div>

          <form onSubmit={handleSubmit} noValidate>
            <div className="space-y-4">
              <Input
                id="username"
                label="Administrator ID / Email"
                type="text"
                autoComplete="username"
                placeholder="admin or email"
                leftIcon={User}
                value={credentials.username}
                onChange={(e) =>
                  setCredentials((prev) => ({ ...prev, username: e.target.value }))
                }
                required
                disabled={isLoading}
              />

              <div className="flex flex-col gap-1.5">
                <label htmlFor="password" className="text-xs font-medium text-slate-300">
                  Password<span className="ml-0.5 text-red-400">*</span>
                </label>
                <div className="relative">
                  <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                    <Lock className="h-4 w-4 text-slate-500" aria-hidden="true" />
                  </div>
                  <input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    autoComplete="current-password"
                    placeholder="Enter password"
                    className="w-full rounded-lg border border-[#1E2B45] bg-[#0A0F1A] px-3 py-2 pl-9 pr-10 h-10 text-sm text-white placeholder:text-slate-600 focus:outline-none focus:ring-2 focus:ring-[#D4AF37] focus:border-transparent transition-colors disabled:opacity-50"
                    value={credentials.password}
                    onChange={(e) =>
                      setCredentials((prev) => ({ ...prev, password: e.target.value }))
                    }
                    required
                    disabled={isLoading}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((v) => !v)}
                    className="absolute inset-y-0 right-0 flex items-center pr-3 text-slate-500 hover:text-white transition-colors"
                    aria-label={showPassword ? 'Hide password' : 'Show password'}
                  >
                    {showPassword ? (
                      <EyeOff className="h-4 w-4" aria-hidden="true" />
                    ) : (
                      <Eye className="h-4 w-4" aria-hidden="true" />
                    )}
                  </button>
                </div>
              </div>
            </div>

            {error && (
              <div
                role="alert"
                className="mt-4 rounded-lg border border-red-500/30 bg-red-500/10 px-3 py-2.5 text-xs text-red-400"
              >
                {error}
              </div>
            )}

            <div className="mt-6">
              <Button
                type="submit"
                variant="primary"
                size="md"
                isLoading={isLoading}
                className="w-full h-11 bg-gradient-to-r from-[#D4AF37] via-[#DFBF58] to-[#C49B2C] hover:from-[#DFBF58] hover:to-[#B88F24] text-black font-bold shadow-lg shadow-[#D4AF37]/15 border-0"
              >
                Sign In to Console
                <ArrowRight className="h-4 w-4 ml-1.5" />
              </Button>
            </div>
          </form>

          <div className="mt-5 pt-4 border-t border-[#182337] flex items-center justify-between text-[11px] text-slate-500">
            <span>Test User: <code className="text-slate-300">admin</code></span>
            <span>Test Pass: <code className="text-slate-300">password</code></span>
          </div>
        </div>

        <p className="mt-6 text-center text-xs text-slate-600">
          &copy; {new Date().getFullYear()} Hemi Ton. All rights reserved.
        </p>
      </div>
    </div>
  );
}

export default AdminLogin;

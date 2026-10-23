// ============================================================
// Hemi Ton Public — Contact & Partnership Page (Light Cloud Blue)
// ============================================================

import React, { useState, useEffect } from 'react';
import {
  Mail,
  Send,
  Building2,
  Crown,
  ShieldAlert,
  CheckCircle2,
  MessageSquare,
  HelpCircle,
  ExternalLink,
} from 'lucide-react';

export function ContactPage() {
  useEffect(() => {
    document.title = 'Contact & Talent Inquiries — Hemi Ton';
  }, []);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    category: 'agency',
    subject: '',
    message: '',
  });

  const [submitted, setSubmitted] = useState(false);
  const [refId, setRefId] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.name || !formData.email || !formData.message) {
      alert('Please fill out all required fields.');
      return;
    }
    const generatedRef = `HT-INQ-${Math.floor(10000 + Math.random() * 90000)}`;
    setRefId(generatedRef);
    setSubmitted(true);
  };

  return (
    <div className="flex flex-col w-full overflow-hidden">
      {/* Header */}
      <section className="pt-16 pb-16 bg-gradient-to-b from-[#F5F8FC] to-[#EEF4FB] border-b border-[#D8E0EC]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center max-w-3xl">
          <span className="text-xs font-mono font-bold uppercase tracking-wider text-[#5979AC] bg-white border border-[#D8E0EC] px-3.5 py-1.5 rounded-full shadow-2xs">
            Direct Communication Channels
          </span>
          <h1 className="font-heading text-4xl sm:text-5xl font-extrabold text-[#263957] tracking-tight mt-6 mb-4">
            Connect with the Hemi Ton Team
          </h1>
          <p className="text-sm sm:text-base text-[#65738A] leading-relaxed">
            Whether you are an aspiring verified broadcaster, an agency looking to onboard rosters, or require technical support, our team is ready to assist.
          </p>
        </div>
      </section>

      {/* Main Grid: Form + Direct Contact Cards */}
      <section className="py-20 bg-[#F8FAFC]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
            {/* Direct Cards (1 Col) */}
            <div className="space-y-4">
              <div className="rounded-2xl border border-[#D8E0EC] bg-white p-6 shadow-2xs">
                <div className="flex items-center gap-3 mb-3">
                  <div className="h-10 w-10 rounded-xl bg-[#EEF4FB] border border-[#DCE6F5] flex items-center justify-center text-[#5979AC]">
                    <Crown className="h-5 w-5" />
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-[#263957] font-heading">
                      Agency & Talent Onboarding
                    </h4>
                    <p className="text-[11px] text-[#65738A]">For agencies with 5+ broadcasters</p>
                  </div>
                </div>
                <p className="text-xs text-[#65738A] leading-relaxed mb-3">
                  Fast-track contract verifications, bulk host badge approvals, and enterprise settlement setup.
                </p>
                <code className="text-xs font-mono text-[#5979AC] font-semibold">agencies@hemiton.live</code>
              </div>

              <div className="rounded-2xl border border-[#D8E0EC] bg-white p-6 shadow-2xs">
                <div className="flex items-center gap-3 mb-3">
                  <div className="h-10 w-10 rounded-xl bg-[#E7F4ED] border border-[#C6E7D5] flex items-center justify-center text-[#2E7D52]">
                    <Building2 className="h-5 w-5" />
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-[#263957] font-heading">
                      Business & Developer Relations
                    </h4>
                    <p className="text-[11px] text-[#65738A]">Agora integration & API access</p>
                  </div>
                </div>
                <p className="text-xs text-[#65738A] leading-relaxed mb-3">
                  Custom SDK partnerships, payment gateway integrations, and institutional inquiries.
                </p>
                <code className="text-xs font-mono text-[#2E7D52] font-semibold">partners@hemiton.live</code>
              </div>

              <div className="rounded-2xl border border-[#D8E0EC] bg-white p-6 shadow-2xs">
                <div className="flex items-center gap-3 mb-3">
                  <div className="h-10 w-10 rounded-xl bg-[#FCEBEB] border border-[#F6CACA] flex items-center justify-center text-[#9C3838]">
                    <ShieldAlert className="h-5 w-5" />
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-[#263957] font-heading">
                      Trust, Safety & Moderation
                    </h4>
                    <p className="text-[11px] text-[#65738A]">Urgent reports & compliance</p>
                  </div>
                </div>
                <p className="text-xs text-[#65738A] leading-relaxed mb-3">
                  Report room violations, copyright inquiries, or account security concerns.
                </p>
                <code className="text-xs font-mono text-[#9C3838] font-semibold">safety@hemiton.live</code>
              </div>
            </div>

            {/* Interactive Form (2 Cols) */}
            <div className="lg:col-span-2">
              <div className="rounded-3xl border border-[#D8E0EC] bg-white p-8 sm:p-10 shadow-lg">
                {submitted ? (
                  <div className="text-center py-12">
                    <div className="h-16 w-16 rounded-full bg-[#E7F4ED] border border-[#C6E7D5] flex items-center justify-center text-[#2E7D52] mx-auto mb-4">
                      <CheckCircle2 className="h-8 w-8" />
                    </div>
                    <h3 className="font-heading text-2xl font-extrabold text-[#263957] mb-2">
                      Inquiry Received Successfully!
                    </h3>
                    <p className="text-xs sm:text-sm text-[#65738A] max-w-md mx-auto mb-6">
                      Thank you for contacting Hemi Ton. Your ticket reference ID is{' '}
                      <strong className="text-[#263957] font-mono">{refId}</strong>. A dedicated operations manager will review your submission and respond within 24 hours.
                    </p>
                    <button
                      onClick={() => {
                        setSubmitted(false);
                        setFormData({ name: '', email: '', category: 'agency', subject: '', message: '' });
                      }}
                      className="rounded-xl bg-[#5979AC] px-6 py-2.5 text-xs font-bold text-white hover:bg-[#496A9C] transition-colors"
                    >
                      Send Another Message
                    </button>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-6">
                    <div>
                      <h3 className="font-heading text-xl font-bold text-[#263957] mb-1">
                        Send a Message to Hemi Ton
                      </h3>
                      <p className="text-xs text-[#65738A]">
                        Please fill in the details below. All fields marked with an asterisk are required.
                      </p>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-bold text-[#263957] uppercase tracking-wider font-mono mb-2">
                          Your Full Name *
                        </label>
                        <input
                          type="text"
                          required
                          value={formData.name}
                          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                          placeholder="e.g. Alex Morgan"
                          className="w-full rounded-xl border border-[#D8E0EC] bg-[#F8FAFC] px-4 py-2.5 text-xs text-[#263957] placeholder-[#8792A4] focus:outline-none focus:ring-2 focus:ring-[#5979AC]/30 focus:border-[#5979AC]"
                        />
                      </div>

                      <div>
                        <label className="block text-xs font-bold text-[#263957] uppercase tracking-wider font-mono mb-2">
                          Email Address *
                        </label>
                        <input
                          type="email"
                          required
                          value={formData.email}
                          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                          placeholder="alex@example.com"
                          className="w-full rounded-xl border border-[#D8E0EC] bg-[#F8FAFC] px-4 py-2.5 text-xs text-[#263957] placeholder-[#8792A4] focus:outline-none focus:ring-2 focus:ring-[#5979AC]/30 focus:border-[#5979AC]"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-bold text-[#263957] uppercase tracking-wider font-mono mb-2">
                          Inquiry Type
                        </label>
                        <select
                          value={formData.category}
                          onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                          className="w-full rounded-xl border border-[#D8E0EC] bg-[#F8FAFC] px-4 py-2.5 text-xs text-[#263957] focus:outline-none focus:ring-2 focus:ring-[#5979AC]/30 focus:border-[#5979AC]"
                        >
                          <option value="agency">Agency Partnership & Host Roster</option>
                          <option value="host">Solo Broadcaster / Verified Badge</option>
                          <option value="support">Technical & Audio Helpdesk</option>
                          <option value="business">Institutional & Media Relations</option>
                        </select>
                      </div>

                      <div>
                        <label className="block text-xs font-bold text-[#263957] uppercase tracking-wider font-mono mb-2">
                          Subject Line
                        </label>
                        <input
                          type="text"
                          value={formData.subject}
                          onChange={(e) => setFormData({ ...formData, subject: e.target.value })}
                          placeholder="Brief summary of inquiry"
                          className="w-full rounded-xl border border-[#D8E0EC] bg-[#F8FAFC] px-4 py-2.5 text-xs text-[#263957] placeholder-[#8792A4] focus:outline-none focus:ring-2 focus:ring-[#5979AC]/30 focus:border-[#5979AC]"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-[#263957] uppercase tracking-wider font-mono mb-2">
                        Message / Details *
                      </label>
                      <textarea
                        required
                        rows={5}
                        value={formData.message}
                        onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                        placeholder="Please describe your broadcaster background, agency roster size, or technical issue..."
                        className="w-full rounded-xl border border-[#D8E0EC] bg-[#F8FAFC] px-4 py-3 text-xs text-[#263957] placeholder-[#8792A4] focus:outline-none focus:ring-2 focus:ring-[#5979AC]/30 focus:border-[#5979AC]"
                      />
                    </div>

                    <button
                      type="submit"
                      className="inline-flex items-center gap-2 rounded-xl bg-[#5979AC] px-7 py-3 text-xs font-bold text-white shadow-xs hover:bg-[#496A9C] transition-all cursor-pointer"
                    >
                      <Send className="h-4 w-4" />
                      <span>Transmit Inquiry to Operations</span>
                    </button>
                  </form>
                )}
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}

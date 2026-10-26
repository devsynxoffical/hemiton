// ============================================================
// Hemi Ton Public — Contact Page (JSX)
// ============================================================

import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { 
  Mail, 
  LifeBuoy, 
  Briefcase, 
  CheckCircle2, 
  MapPin, 
  Phone, 
  Clock, 
  ShieldCheck, 
  Sparkles, 
  Send,
  MessageSquare,
  HelpCircle,
  Building2,
  ChevronDown,
  ChevronUp
} from 'lucide-react';

export function ContactPage() {
  const [searchParams] = useSearchParams();
  const initialType = searchParams.get('type') || 'host';

  const [selectedTopic, setSelectedTopic] = useState(
    initialType === 'agency' ? 'agency' : initialType === 'host' ? 'host' : initialType === 'support' ? 'support' : 'general'
  );

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    region: 'Dubai / MENA',
    subject: '',
    message: ''
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);
  const [ticketId, setTicketId] = useState('');
  const [errors, setErrors] = useState({});
  const [openFaq, setOpenFaq] = useState(0);

  useEffect(() => {
    document.title = 'Contact Concierge — Hemi Ton';
    window.scrollTo(0, 0);
  }, []);

  useEffect(() => {
    if (selectedTopic === 'host') {
      setFormData(prev => ({ ...prev, subject: 'Host / Creator Audition Application' }));
    } else if (selectedTopic === 'agency') {
      setFormData(prev => ({ ...prev, subject: 'Agency Guild Partnership Inquiry' }));
    } else if (selectedTopic === 'support') {
      setFormData(prev => ({ ...prev, subject: 'VIP Concierge Resolution Request' }));
    } else {
      setFormData(prev => ({ ...prev, subject: 'General Partnership / Media Inquiry' }));
    }
  }, [selectedTopic]);

  const validate = () => {
    const newErrors = {};
    if (!formData.name.trim()) newErrors.name = 'Full name is required';
    if (!formData.email.trim()) {
      newErrors.email = 'Official email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Please provide a valid email';
    }
    if (!formData.subject.trim()) newErrors.subject = 'Subject line is required';
    if (!formData.message.trim() || formData.message.length < 15) {
      newErrors.message = 'Please provide a detailed message (at least 15 characters)';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validate()) {
      setIsSubmitting(true);
      // Simulate high-reliability API submission
      setTimeout(() => {
        setIsSubmitting(false);
        setTicketId(`HT-${Math.floor(100000 + Math.random() * 900000)}`);
        setSuccess(true);
      }, 1000);
    }
  };

  const faqs = [
    {
      q: 'What are the requirements to audition as a verified Hemi Ton host?',
      a: 'We evaluate audio presence, broadcast consistency, and community charisma. Applicants should have a clean microphone setup, reliable high-speed internet, and a commitment to broadcast at least 15 hours per week.'
    },
    {
      q: 'How does the Agency Guild partnership model operate?',
      a: 'Agency Guilds receive a master management console, multi-level commission tracking, and direct access to regional BD Centers in Dubai and Singapore. Settlements occur daily with automated bank or USDT transfers.'
    },
    {
      q: 'How fast will my inquiry or support request be resolved?',
      a: 'VIP Concierge tickets are answered within 15 minutes 24/7. Host audition applications and agency contracts receive initial evaluation within 24 business hours.'
    },
    {
      q: 'Can coin sellers and third-party merchants apply for official certification?',
      a: 'Yes. Official Hemi Ton Coin Sellers undergo bank-grade KYC and must maintain a security escrow deposit. Inquire via the "Agency & Business" category.'
    }
  ];

  return (
    <div className="flex flex-col w-full overflow-hidden bg-[#06090F] text-slate-300">
      
      {/* 1. Hero */}
      <section className="relative pt-36 pb-16 lg:pt-44 lg:pb-24 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto w-full text-center">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[500px] bg-[#D4AF37]/10 blur-[150px] rounded-full pointer-events-none" />

        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#D4AF37]/10 border border-[#D4AF37]/30 text-[#D4AF37] text-xs font-semibold uppercase tracking-widest mb-6">
          <Sparkles className="w-3.5 h-3.5" /> 24/7 Global Concierge & Talent Relations
        </div>

        <h1 className="text-4xl sm:text-6xl font-extrabold text-white tracking-tight leading-[1.1] mb-6">
          Connect With The <br />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#D4AF37] via-[#FFF3B0] to-[#E5C158]">
            Hemi Ton Royal Concierge
          </span>
        </h1>

        <p className="text-lg sm:text-xl text-slate-400 max-w-2xl mx-auto leading-relaxed">
          Whether applying for host verification, establishing an agency guild, or resolving high-priority VIP inquiries, our desks in Dubai, Singapore, Riyadh, and London are active around the clock.
        </p>

        {/* Live Status indicator */}
        <div className="mt-8 inline-flex items-center gap-3 px-4 py-2 rounded-full bg-white/[0.03] border border-white/10 text-xs text-slate-300">
          <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse" />
          <span>Concierge Desks Online • Current Average Response Time: <strong className="text-white">7 Minutes</strong></span>
        </div>
      </section>

      {/* 2. Direct Specialized Channels Cards Div */}
      <section className="py-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div className="grid md:grid-cols-3 gap-6">
          {[
            {
              icon: Sparkles,
              title: 'Host & Creator Auditions',
              desc: 'Apply for official blue check verification, guaranteed lounge traffic, and talent incubator funding.',
              direct: 'auditions@hemi-ton.app',
              aux: 'Telegram: @HemiTonTalent'
            },
            {
              icon: Briefcase,
              title: 'Agency Guilds & BD Centers',
              desc: 'Contract negotiations, 70% revenue share setups, and multi-tier agency master console onboarding.',
              direct: 'guilds@hemi-ton.app',
              aux: 'Dubai Desk: +971 4 800 HEMI'
            },
            {
              icon: LifeBuoy,
              title: '24/7 VIP Concierge & Security',
              desc: 'High-priority transaction reconciliation, coin refund appeals, and hardware account protection.',
              direct: 'concierge@hemi-ton.app',
              aux: 'Response SLA: < 15 Mins'
            }
          ].map((channel, i) => (
            <div
              key={i}
              className="p-8 rounded-3xl bg-[#0A0F1A] border border-white/5 hover:border-[#D4AF37]/40 transition-all group flex flex-col justify-between shadow-xl"
            >
              <div>
                <div className="w-12 h-12 rounded-2xl bg-[#D4AF37]/10 border border-[#D4AF37]/20 flex items-center justify-center text-[#D4AF37] mb-6 group-hover:scale-110 transition-transform">
                  <channel.icon className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-bold text-white mb-2 group-hover:text-[#D4AF37] transition-colors">
                  {channel.title}
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed mb-6">
                  {channel.desc}
                </p>
              </div>

              <div className="pt-4 border-t border-white/5 space-y-1">
                <div className="text-xs font-bold text-white font-mono">{channel.direct}</div>
                <div className="text-[11px] text-[#D4AF37]">{channel.aux}</div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* 3. Form & FAQ Section */}
      <section className="py-16 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full mb-16">
        <div className="grid lg:grid-cols-12 gap-12 items-start">
          
          {/* Contact Form Div (7 cols) */}
          <div className="lg:col-span-7 bg-[#0A0F1A] border border-[#D4AF37]/30 rounded-3xl p-8 sm:p-10 shadow-2xl relative">
            <h2 className="text-2xl sm:text-3xl font-bold text-white mb-2">Send Dispatch to Concierge</h2>
            <p className="text-xs text-slate-400 mb-6">
              Select your inquiry domain to route directly to our specialized regional leads.
            </p>

            {/* Topic Selector Pills */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mb-6">
              {[
                { id: 'host', label: 'Host Audition' },
                { id: 'agency', label: 'Agency Guild' },
                { id: 'support', label: 'VIP Support' },
                { id: 'general', label: 'Partnership' }
              ].map(t => (
                <button
                  key={t.id}
                  type="button"
                  onClick={() => setSelectedTopic(t.id)}
                  className={`text-xs font-bold py-2.5 px-3 rounded-xl transition-all ${
                    selectedTopic === t.id
                      ? 'bg-[#D4AF37] text-black shadow-md'
                      : 'bg-white/[0.04] text-slate-400 hover:text-white border border-white/5'
                  }`}
                >
                  {t.label}
                </button>
              ))}
            </div>

            {success ? (
              <div className="p-8 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-center space-y-4">
                <div className="w-14 h-14 rounded-full bg-emerald-500/20 flex items-center justify-center text-emerald-400 mx-auto">
                  <CheckCircle2 className="w-8 h-8" />
                </div>
                <h3 className="text-xl font-bold text-white">Inquiry Dispatched Successfully</h3>
                <div className="text-xs text-slate-300 max-w-md mx-auto">
                  Your reference ticket number is <strong className="text-[#D4AF37] font-mono text-sm">{ticketId}</strong>. A dedicated concierge officer has received your file.
                </div>
                <div className="pt-2">
                  <button
                    onClick={() => {
                      setSuccess(false);
                      setFormData({ name: '', email: '', region: 'Dubai / MENA', subject: '', message: '' });
                    }}
                    className="text-xs font-bold text-[#D4AF37] hover:underline"
                  >
                    Send another inquiry &rarr;
                  </button>
                </div>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-slate-300 mb-1">Your Full Name</label>
                    <input
                      type="text"
                      value={formData.name}
                      onChange={(e) => { setFormData({ ...formData, name: e.target.value }); setErrors({ ...errors, name: '' }); }}
                      placeholder="e.g. Tariq Al-Sabah"
                      className={`w-full bg-[#06090F] border ${errors.name ? 'border-red-500' : 'border-white/10'} rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors`}
                    />
                    {errors.name && <p className="text-[11px] text-red-400 mt-1">{errors.name}</p>}
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-slate-300 mb-1">Official Email Address</label>
                    <input
                      type="email"
                      value={formData.email}
                      onChange={(e) => { setFormData({ ...formData, email: e.target.value }); setErrors({ ...errors, email: '' }); }}
                      placeholder="name@company.com"
                      className={`w-full bg-[#06090F] border ${errors.email ? 'border-red-500' : 'border-white/10'} rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors`}
                    />
                    {errors.email && <p className="text-[11px] text-red-400 mt-1">{errors.email}</p>}
                  </div>
                </div>

                <div className="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-slate-300 mb-1">Operating Region</label>
                    <select
                      value={formData.region}
                      onChange={(e) => setFormData({ ...formData, region: e.target.value })}
                      className="w-full bg-[#06090F] border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    >
                      <option value="Dubai / MENA">Dubai / GCC & Middle East</option>
                      <option value="South Asia">South Asia (Pakistan, India, Bangladesh)</option>
                      <option value="Southeast Asia">Southeast Asia (Singapore, Malaysia, Indonesia)</option>
                      <option value="Europe / UK">Europe & United Kingdom</option>
                      <option value="Americas">Americas (US, Canada, LatAm)</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-slate-300 mb-1">Subject Header</label>
                    <input
                      type="text"
                      value={formData.subject}
                      onChange={(e) => { setFormData({ ...formData, subject: e.target.value }); setErrors({ ...errors, subject: '' }); }}
                      className={`w-full bg-[#06090F] border ${errors.subject ? 'border-red-500' : 'border-white/10'} rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors`}
                    />
                    {errors.subject && <p className="text-[11px] text-red-400 mt-1">{errors.subject}</p>}
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Detailed Message / Portfolio Links</label>
                  <textarea
                    rows={4}
                    value={formData.message}
                    onChange={(e) => { setFormData({ ...formData, message: e.target.value }); setErrors({ ...errors, message: '' }); }}
                    placeholder="Provide your background, current streaming handles, agency talent roster size, or specifics of your inquiry..."
                    className={`w-full bg-[#06090F] border ${errors.message ? 'border-red-500' : 'border-white/10'} rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors resize-none`}
                  />
                  {errors.message && <p className="text-[11px] text-red-400 mt-1">{errors.message}</p>}
                </div>

                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="w-full bg-gradient-to-r from-[#D4AF37] to-[#E5C158] hover:from-[#E5C158] hover:to-[#D4AF37] text-black font-extrabold py-3.5 px-6 rounded-xl transition-all shadow-[0_0_20px_rgba(212,175,55,0.35)] flex items-center justify-center gap-2 text-sm disabled:opacity-50"
                >
                  {isSubmitting ? (
                    <div className="w-5 h-5 border-2 border-black/30 border-t-black rounded-full animate-spin" />
                  ) : (
                    <>
                      <Send className="w-4 h-4" />
                      <span>Transmit Message to Desk</span>
                    </>
                  )}
                </button>
              </form>
            )}
          </div>

          {/* FAQ & Physical Office Divs (5 cols) */}
          <div className="lg:col-span-5 space-y-6">
            
            {/* FAQ Accordion */}
            <div className="p-6 rounded-3xl bg-[#0A0F1A] border border-white/10">
              <h3 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
                <HelpCircle className="w-5 h-5 text-[#D4AF37]" /> Frequently Clarified
              </h3>

              <div className="space-y-3">
                {faqs.map((faq, idx) => {
                  const isOpen = openFaq === idx;
                  return (
                    <div
                      key={idx}
                      className="p-3.5 rounded-xl bg-white/[0.02] border border-white/5 transition-all"
                    >
                      <button
                        type="button"
                        onClick={() => setOpenFaq(isOpen ? -1 : idx)}
                        className="w-full text-left flex items-center justify-between text-xs font-bold text-white gap-2"
                      >
                        <span>{faq.q}</span>
                        {isOpen ? <ChevronUp className="w-4 h-4 text-[#D4AF37] shrink-0" /> : <ChevronDown className="w-4 h-4 text-slate-500 shrink-0" />}
                      </button>
                      {isOpen && (
                        <p className="text-xs text-slate-400 mt-2.5 leading-relaxed pt-2 border-t border-white/5">
                          {faq.a}
                        </p>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Physical Headquarters Card */}
            <div className="p-6 rounded-3xl bg-[#0A0F1A] border border-white/10 space-y-4">
              <h4 className="text-sm font-bold uppercase tracking-wider text-[#D4AF37] flex items-center gap-2">
                <Building2 className="w-4 h-4" /> Strategic Operations
              </h4>

              <div className="space-y-3 text-xs">
                <div className="flex items-start gap-3">
                  <MapPin className="w-4 h-4 text-[#D4AF37] shrink-0 mt-0.5" />
                  <div>
                    <div className="font-bold text-white">Dubai Hub (Creator Studio & BD)</div>
                    <div className="text-slate-400">Level 24, Innovation Tower, Dubai Internet City, UAE</div>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <MapPin className="w-4 h-4 text-[#D4AF37] shrink-0 mt-0.5" />
                  <div>
                    <div className="font-bold text-white">Singapore Hub (Audio Engineering R&D)</div>
                    <div className="text-slate-400">Tower 2, Marina Bay Financial Centre, Singapore</div>
                  </div>
                </div>
              </div>
            </div>

          </div>

        </div>
      </section>

    </div>
  );
}

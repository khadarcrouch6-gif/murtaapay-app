"use client";

import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Image from "next/image";
import {
  CheckCircle2,
  ShieldCheck,
  Zap,
  Globe,
  Users,
  TrendingUp,
  ArrowRight,
  Sparkles,
  BadgeCheck,
  Lock,
  HeartHandshake,
} from "lucide-react";
import { useTranslations } from "next-intl";

export default function AboutPage() {
  const t = useTranslations("AboutPage");

  const values = [
    {
      icon: Zap,
      title: "Fast Transfers",
      desc: "Money arrives in seconds — not days. We leverage real-time networks to ensure speed.",
      gradient: "from-emerald-500 to-teal-600",
      shadow: "shadow-emerald-500/25",
    },
    {
      icon: ShieldCheck,
      title: "Secure Payments",
      desc: "Bank-grade encryption and multi-factor authentication protect every transaction.",
      gradient: "from-blue-500 to-cyan-500",
      shadow: "shadow-blue-500/25",
    },
    {
      icon: TrendingUp,
      title: "Low Fees",
      desc: "Transparent pricing with no hidden costs. We keep more money in your family's hands.",
      gradient: "from-teal-500 to-emerald-600",
      shadow: "shadow-teal-500/25",
    },
    {
      icon: Globe,
      title: "Local Integration",
      desc: "Seamlessly connected to the Somali banking and mobile money infrastructure.",
      gradient: "from-violet-500 to-blue-600",
      shadow: "shadow-violet-500/25",
    },
  ];

  const stats = [
    { value: "10K+", label: "Active Users", color: "text-emerald-500" },
    { value: "$1M+", label: "Transactions", color: "text-teal-500" },
    { value: "99.9%", label: "Uptime Rate", color: "text-blue-500" },
    { value: "24/7", label: "Global Support", color: "text-emerald-400" },
  ];

  const points = [t("point1"), t("point2"), t("point3")];

  return (
    <main className="min-h-screen bg-gradient-to-b from-[#f4f9fb] to-white dark:from-[#040D1F] dark:to-[#020617] transition-colors duration-300">
      <Navbar />

      {/* ── HERO ── */}
      <section className="relative overflow-hidden pt-28 pb-20">
        {/* Brand orbs — matching HeroSection */}
        <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-emerald-300/20 dark:bg-emerald-900/30 rounded-full blur-[120px] pointer-events-none mix-blend-multiply dark:mix-blend-screen" />
        <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-cyan-300/20 dark:bg-cyan-900/30 rounded-full blur-[120px] pointer-events-none mix-blend-multiply dark:mix-blend-screen" />
        <div className="absolute top-1/2 left-1/2 w-[500px] h-[500px] bg-blue-300/20 dark:bg-blue-900/30 rounded-full blur-[100px] pointer-events-none mix-blend-multiply dark:mix-blend-screen -translate-x-1/2 -translate-y-1/2" />

        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative z-10">
          {/* Badge */}
          <div className="inline-flex items-center gap-3 px-2 py-2 pr-5 rounded-full bg-white/60 dark:bg-slate-900/60 backdrop-blur-xl border border-white dark:border-white/10 shadow-sm mb-8">
            <span className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white text-[10px] font-black px-3 py-1.5 rounded-full uppercase tracking-widest shadow-md">
              About Us
            </span>
            <span className="text-slate-600 dark:text-slate-300 text-sm font-semibold flex items-center gap-1.5">
              <Sparkles size={13} className="text-emerald-500" />
              Our Story
            </span>
          </div>

          <h1 className="text-6xl sm:text-7xl font-black text-slate-900 dark:text-white tracking-tighter leading-[1.05] mb-6">
            {t("heroTitle")}{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 via-teal-500 to-blue-600">
              {t("heroHighlight")}
            </span>
          </h1>

          <p className="text-lg md:text-xl text-slate-500 dark:text-slate-400 max-w-2xl mx-auto leading-relaxed font-medium mb-10">
            {t("heroSubtitle")}
          </p>

          {/* Trust badges */}
          <div className="flex flex-wrap items-center justify-center gap-4">
            {[
              { icon: BadgeCheck, label: "Licensed Financial Institution" },
              { icon: Lock, label: "PCI DSS Compliant" },
              { icon: HeartHandshake, label: "Trusted by 10K+ Users" },
            ].map((b, i) => {
              const Icon = b.icon;
              return (
                <div
                  key={i}
                  className="inline-flex items-center gap-2 px-4 py-2.5 rounded-full bg-white dark:bg-slate-900/70 border border-slate-200 dark:border-white/10 shadow-sm text-slate-600 dark:text-slate-300 text-sm font-semibold"
                >
                  <Icon size={15} className="text-emerald-500" />
                  {b.label}
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ── OUR MISSION + PHONE MOCKUP ── */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">

            {/* Left text */}
            <div>
              <h2 className="text-4xl md:text-5xl font-black text-slate-900 dark:text-white tracking-tight mb-6 leading-tight">
                Our{" "}
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 to-teal-500">
                  Mission
                </span>
              </h2>
              <p className="text-lg text-slate-500 dark:text-slate-400 mb-5 leading-relaxed font-medium">
                {t("storyP1")}
              </p>
              <p className="text-lg text-slate-500 dark:text-slate-400 mb-10 leading-relaxed font-medium">
                {t("storyP2")}
              </p>

              <ul className="space-y-4 mb-10">
                {points.map((item, idx) => (
                  <li key={idx} className="flex items-center gap-3">
                    <div className="w-6 h-6 rounded-full bg-emerald-50 dark:bg-emerald-900/30 flex items-center justify-center flex-shrink-0">
                      <CheckCircle2 className="text-emerald-500" size={16} />
                    </div>
                    <span className="font-semibold text-slate-700 dark:text-slate-300">
                      {item}
                    </span>
                  </li>
                ))}
              </ul>

              {/* Trust pils */}
              <div className="flex flex-wrap gap-3 mb-10">
                {[
                  { icon: BadgeCheck, label: "Licensed Financial Institution" },
                  { icon: Lock, label: "PCI DSS Compliant" },
                ].map((b, i) => {
                  const Icon = b.icon;
                  return (
                    <div
                      key={i}
                      className="inline-flex items-center gap-2 px-4 py-2.5 rounded-full bg-white dark:bg-slate-900/70 border border-slate-200 dark:border-white/10 shadow-sm text-slate-600 dark:text-slate-300 text-sm font-semibold"
                    >
                      <Icon size={14} className="text-emerald-500" />
                      {b.label}
                    </div>
                  );
                })}
              </div>

              <a
                href="/signup"
                className="inline-flex items-center gap-2 px-7 py-3.5 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-black rounded-2xl transition-all shadow-xl shadow-emerald-500/25 text-sm uppercase tracking-wide"
              >
                Get Started <ArrowRight size={16} />
              </a>
            </div>

            {/* Right — REAL phone app mockup */}
            <div className="relative flex items-center justify-center">
              {/* Glow behind phone */}
              <div className="absolute w-80 h-80 bg-gradient-to-br from-emerald-400/30 to-teal-500/30 rounded-full blur-[80px] pointer-events-none" />

              {/* Phone frame */}
              <div className="relative z-10 w-[280px] sm:w-[320px]">
                <div className="relative rounded-[40px] overflow-hidden shadow-2xl shadow-emerald-500/20 border-4 border-slate-800 dark:border-white/10">
                  <Image
                    src="/images/app.png"
                    alt="MurtaaxPay App"
                    width={320}
                    height={640}
                    className="w-full h-auto object-cover"
                    priority
                  />
                  {/* Screen overlay shine */}
                  <div className="absolute inset-0 bg-gradient-to-b from-white/5 via-transparent to-black/10 pointer-events-none rounded-[36px]" />
                </div>

                {/* Floating badge — Transfer sent */}
                <div className="absolute -right-8 top-20 bg-white dark:bg-slate-900 rounded-2xl shadow-xl border border-slate-100 dark:border-white/10 px-4 py-3 flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center flex-shrink-0">
                    <TrendingUp size={14} className="text-white" />
                  </div>
                  <div>
                    <div className="text-slate-900 dark:text-white text-xs font-black">Transfer sent</div>
                    <div className="text-emerald-500 text-[10px] font-bold">Instant · $0 fee</div>
                  </div>
                </div>

                {/* Floating badge — Balance */}
                <div className="absolute -left-8 bottom-28 bg-white dark:bg-slate-900 rounded-2xl shadow-xl border border-slate-100 dark:border-white/10 px-4 py-3">
                  <div className="text-slate-400 text-[10px] font-semibold uppercase tracking-wide mb-0.5">USD Balance</div>
                  <div className="text-slate-900 dark:text-white font-black text-lg tracking-tight">$4,250.00</div>
                  <div className="text-emerald-500 text-[10px] font-bold flex items-center gap-1 mt-0.5">
                    <TrendingUp size={10} /> +2.4% this month
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* ── CORE VALUES ── */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-14">
            <h2 className="text-4xl md:text-5xl font-black text-slate-900 dark:text-white tracking-tight mb-4">
              Core{" "}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 to-teal-500">
                Values
              </span>
            </h2>
            <p className="text-slate-500 dark:text-slate-400 font-medium max-w-xl mx-auto">
              Everything we build is grounded in these four principles.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {values.map((v, i) => {
              const Icon = v.icon;
              return (
                <div
                  key={i}
                  className="group p-7 rounded-3xl bg-white dark:bg-slate-900/50 border border-slate-200 dark:border-white/[0.07] hover:border-emerald-300 dark:hover:border-emerald-800/50 hover:shadow-2xl hover:shadow-emerald-50 dark:hover:shadow-emerald-900/20 transition-all duration-500"
                >
                  <div
                    className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${v.gradient} flex items-center justify-center mb-5 shadow-lg ${v.shadow} group-hover:scale-110 transition-transform duration-500`}
                  >
                    <Icon size={24} className="text-white" strokeWidth={1.8} />
                  </div>
                  <h3 className="text-slate-900 dark:text-white font-bold text-lg mb-2 tracking-tight">
                    {v.title}
                  </h3>
                  <p className="text-slate-500 dark:text-slate-400 text-sm leading-relaxed">
                    {v.desc}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ── STATS ROW ── */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
            {stats.map((s, i) => (
              <div
                key={i}
                className="text-center p-8 rounded-3xl bg-white dark:bg-slate-900/50 border border-slate-200 dark:border-white/[0.07] hover:border-emerald-300 dark:hover:border-emerald-800/50 hover:shadow-xl transition-all duration-500"
              >
                <div className={`text-5xl font-black tracking-tighter mb-2 ${s.color}`}>
                  {s.value}
                </div>
                <div className="text-slate-500 dark:text-slate-400 text-sm font-semibold uppercase tracking-wide">
                  {s.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── PAYMENT METHODS ── */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="relative rounded-[32px] bg-white dark:bg-slate-900/50 border border-slate-200 dark:border-white/[0.07] overflow-hidden px-10 py-12">
            {/* Subtle bg glow */}
            <div className="absolute top-0 right-0 w-72 h-72 bg-emerald-400/5 rounded-full blur-[80px] pointer-events-none" />

            <div className="relative z-10">
              <div className="text-center mb-10">
                <p className="text-slate-400 dark:text-slate-500 text-xs font-bold uppercase tracking-widest mb-2">
                  Trusted Payment Partners
                </p>
                <h3 className="text-2xl md:text-3xl font-black text-slate-900 dark:text-white tracking-tight">
                  Supported{" "}
                  <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 to-teal-500">
                    Payment Methods
                  </span>
                </h3>
              </div>

              {/* Local Mobile Money */}
              <div className="mb-8">
                <p className="text-slate-400 text-xs font-semibold uppercase tracking-widest text-center mb-5">
                  Local Mobile Money
                </p>
                <div className="flex flex-wrap items-center justify-center gap-6">
                  {[
                    { src: "/images/zaad.png", name: "Zaad", color: "from-emerald-500 to-teal-600" },
                    { src: "/images/evc.png", name: "EVC Plus", color: "from-blue-500 to-cyan-600" },
                    { src: "/images/edahab.png", name: "eDahab", color: "from-amber-500 to-orange-500" },
                  ].map((m, i) => (
                    <div
                      key={i}
                      className="group flex flex-col items-center gap-3"
                    >
                      <div className="w-20 h-20 rounded-2xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200 dark:border-white/[0.08] flex items-center justify-center p-3 group-hover:border-emerald-300 dark:group-hover:border-emerald-700/50 group-hover:shadow-lg group-hover:shadow-emerald-100 dark:group-hover:shadow-emerald-900/20 transition-all duration-300">
                        <Image
                          src={m.src}
                          alt={m.name}
                          width={56}
                          height={56}
                          className="w-full h-full object-contain"
                        />
                      </div>
                      <span className="text-slate-500 dark:text-slate-400 text-xs font-bold">{m.name}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Divider */}
              <div className="flex items-center gap-4 mb-8">
                <div className="flex-1 h-px bg-slate-100 dark:bg-white/[0.05]" />
                <span className="text-slate-300 dark:text-slate-600 text-xs font-semibold uppercase tracking-widest">
                  Also Supported
                </span>
                <div className="flex-1 h-px bg-slate-100 dark:bg-white/[0.05]" />
              </div>

              {/* International cards — real logos */}
              <div className="flex flex-wrap items-center justify-center gap-6">

                {/* Visa */}
                <div className="group flex flex-col items-center gap-3">
                  <div className="w-20 h-20 rounded-2xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200 dark:border-white/[0.08] flex items-center justify-center p-4 group-hover:border-emerald-300 dark:group-hover:border-emerald-700/50 group-hover:shadow-lg group-hover:shadow-emerald-100 dark:group-hover:shadow-emerald-900/20 transition-all duration-300">
                    <svg viewBox="0 0 216 68" className="w-full h-auto" xmlns="http://www.w3.org/2000/svg">
                      <path d="M90.3 3.1L59.7 64.4H38.8L23.9 16.5c-.9-3.5-1.7-4.8-4.5-6.3C14.6 7.7 7 5.5 0 4.2L.5 3.1h33.3c4.2 0 8 2.8 9 7.3l8.2 43.6L71.4 3.1h18.9zm74.8 41.3c.1-18.4-25.5-19.4-25.3-27.6.1-2.5 2.4-5.1 7.6-5.8 2.6-.3 9.6-.6 17.6 3.1l3.1-14.6c-4.3-1.6-9.8-3.1-16.7-3.1-17.6 0-29.9 9.4-30 22.8-.1 9.9 8.9 15.4 15.6 18.7 7 3.3 9.3 5.5 9.3 8.4-.1 4.5-5.6 6.5-10.7 6.6-9 .2-14.2-2.4-18.4-4.3l-3.2 15.2c4.2 1.9 11.9 3.6 19.9 3.7 18.8 0 31.1-9.3 31.2-23.1zM216 64.4h-17.3l-14.1-61.3h17.3L216 64.4zm-66.7 0h-17.9L144.7 3.1h17.9L149.3 64.4z" className="fill-[#1a1f71] dark:fill-white"/>
                    </svg>
                  </div>
                  <span className="text-slate-500 dark:text-slate-400 text-xs font-bold">Visa</span>
                </div>

                {/* Mastercard */}
                <div className="group flex flex-col items-center gap-3">
                  <div className="w-20 h-20 rounded-2xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200 dark:border-white/[0.08] flex items-center justify-center p-3 group-hover:border-emerald-300 dark:group-hover:border-emerald-700/50 group-hover:shadow-lg group-hover:shadow-emerald-100 dark:group-hover:shadow-emerald-900/20 transition-all duration-300">
                    <svg viewBox="0 0 152.4 108" className="w-full h-auto" xmlns="http://www.w3.org/2000/svg">
                      <circle cx="54" cy="54" r="54" fill="#EB001B"/>
                      <circle cx="98.4" cy="54" r="54" fill="#F79E1B"/>
                      <path d="M76.2 19.4c10.3 7.8 17 19.9 17 33.6s-6.7 25.8-17 33.6c-10.3-7.8-17-19.9-17-33.6s6.7-25.8 17-33.6z" fill="#FF5F00"/>
                    </svg>
                  </div>
                  <span className="text-slate-500 dark:text-slate-400 text-xs font-bold">Mastercard</span>
                </div>

                {/* Premier Bank */}
                <div className="group flex flex-col items-center gap-3">
                  <div className="w-20 h-20 rounded-2xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200 dark:border-white/[0.08] flex items-center justify-center p-3 group-hover:border-emerald-300 dark:group-hover:border-emerald-700/50 group-hover:shadow-lg group-hover:shadow-emerald-100 dark:group-hover:shadow-emerald-900/20 transition-all duration-300">
                    <Image
                      src="/images/bank.png"
                      alt="Premier Bank"
                      width={56}
                      height={56}
                      className="w-full h-full object-contain"
                    />
                  </div>
                  <span className="text-slate-500 dark:text-slate-400 text-xs font-bold">Premier Bank</span>
                </div>

                {/* Bank Transfer */}
                <div className="group flex flex-col items-center gap-3">
                  <div className="w-20 h-20 rounded-2xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200 dark:border-white/[0.08] flex items-center justify-center p-4 group-hover:border-emerald-300 dark:group-hover:border-emerald-700/50 group-hover:shadow-lg group-hover:shadow-emerald-100 dark:group-hover:shadow-emerald-900/20 transition-all duration-300">
                    <svg viewBox="0 0 24 24" className="w-full h-auto" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M3 21h18M3 10h18M5 6l7-3 7 3M4 10v11M20 10v11M8 10v11M12 10v11M16 10v11" stroke="url(#bankGrad)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
                      <defs>
                        <linearGradient id="bankGrad" x1="3" y1="3" x2="21" y2="21" gradientUnits="userSpaceOnUse">
                          <stop stopColor="#10b981"/>
                          <stop offset="1" stopColor="#0d9488"/>
                        </linearGradient>
                      </defs>
                    </svg>
                  </div>
                  <span className="text-slate-500 dark:text-slate-400 text-xs font-bold">Bank Transfer</span>
                </div>

              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── CTA ── */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="relative rounded-[40px] bg-gradient-to-br from-[#0f172a] via-[#1a2744] to-[#0f172a] dark:from-[#040D1F] dark:via-[#0B1628] dark:to-[#040D1F] border border-white/[0.06] overflow-hidden p-12 md:p-20 text-center">
            <div className="absolute top-0 right-0 w-[600px] h-[400px] bg-emerald-500/10 rounded-full blur-[100px] pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-[400px] h-[300px] bg-teal-600/10 rounded-full blur-[80px] pointer-events-none" />

            <div className="relative z-10">
              <h2 className="text-4xl md:text-5xl font-black text-white tracking-tight mb-4">
                Join{" "}
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-teal-400">
                  MurtaaxPay
                </span>{" "}
                Today
              </h2>
              <p className="text-slate-400 font-medium max-w-xl mx-auto mb-10 leading-relaxed">
                Experience a smarter way to send money home. Secure, instant, and built for our community.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <a
                  href="/signup"
                  className="inline-flex items-center justify-center gap-2 px-8 py-4 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-black rounded-2xl transition-all shadow-xl shadow-emerald-500/25 text-sm uppercase tracking-wide"
                >
                  Get Started <ArrowRight size={16} />
                </a>
                <a
                  href="/contact"
                  className="inline-flex items-center justify-center px-8 py-4 bg-white/10 hover:bg-white/15 border border-white/20 text-white font-bold rounded-2xl transition-all text-sm uppercase tracking-wide backdrop-blur-sm"
                >
                  Learn More
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}

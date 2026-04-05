"use client";

import { motion } from "framer-motion";
import {
  ShieldCheck,
  Zap,
  BadgeCheck,
  Globe,
  Users,
  TrendingUp,
  ArrowRight,
  Sparkles,
  Lock,
  CheckCircle2,
} from "lucide-react";
import { useTranslations } from "next-intl";

const fadeUp = (delay = 0) => ({
  initial: { opacity: 0, y: 24 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true },
  transition: { duration: 0.6, delay, ease: [0.22, 1, 0.36, 1] },
});

const fadeLeft = {
  initial: { opacity: 0, x: -32 },
  whileInView: { opacity: 1, x: 0 },
  viewport: { once: true },
  transition: { duration: 0.7, ease: [0.22, 1, 0.36, 1] },
};

const fadeRight = {
  initial: { opacity: 0, x: 32 },
  whileInView: { opacity: 1, x: 0 },
  viewport: { once: true },
  transition: { duration: 0.7, ease: [0.22, 1, 0.36, 1] },
};

export default function AboutSection() {
  const t = useTranslations("About");

  const pillars = [
    {
      icon: ShieldCheck,
      title: t("securityTitle"),
      desc: t("securityDesc"),
      gradient: "from-emerald-500 to-teal-600",
      glow: "shadow-emerald-500/20",
      checks: ["256-bit AES encryption", "Biometric authentication", "Real-time fraud detection"],
    },
    {
      icon: Zap,
      title: t("fastTitle"),
      desc: t("fastDesc"),
      gradient: "from-blue-500 to-cyan-500",
      glow: "shadow-blue-500/20",
      checks: ["Sub-second transfers", "40+ currencies", "Zero hidden fees"],
    },
    {
      icon: BadgeCheck,
      title: t("guaranteedTitle"),
      desc: t("guaranteedDesc"),
      gradient: "from-violet-500 to-purple-600",
      glow: "shadow-violet-500/20",
      checks: ["Fully licensed & regulated", "Annual audits", "24/7 compliance monitoring"],
    },
  ];

  const metrics = [
    { value: "2M+", label: "Trusted Transactions", icon: TrendingUp },
    { value: "50K+", label: "Active Users", icon: Users },
    { value: "40+", label: "Countries Reached", icon: Globe },
    { value: "99.9%", label: "Platform Uptime", icon: Zap },
  ];

  return (
    <section
      id="about"
      className="py-32 bg-slate-50 dark:bg-[#020813] transition-colors duration-300 relative overflow-hidden"
    >
      {/* Background decoration */}
      <div className="absolute top-0 right-0 w-[700px] h-[700px] bg-emerald-300/10 dark:bg-emerald-900/20 rounded-full blur-[130px] pointer-events-none" />
      <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bg-blue-300/10 dark:bg-blue-900/20 rounded-full blur-[100px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">

        {/* ── HEADER ── */}
        <motion.div {...fadeUp()} className="max-w-3xl mx-auto text-center mb-20">
          <div className="inline-flex items-center gap-2 px-2 py-2 pr-5 rounded-full bg-white dark:bg-slate-900/60 backdrop-blur-xl border border-slate-200 dark:border-white/10 shadow-sm mb-6">
            <span className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white text-[10px] font-black px-3 py-1.5 rounded-full uppercase tracking-widest shadow-md">
              {t("badge")}
            </span>
            <span className="text-slate-600 dark:text-slate-300 text-sm font-semibold flex items-center gap-1.5">
              <Sparkles size={13} className="text-emerald-500" />
              MurtaaxPay
            </span>
          </div>

          <h2 className="text-5xl md:text-6xl font-black text-slate-900 dark:text-white tracking-tighter leading-[1.05] mb-6">
            {t("title").split(" ").slice(0, -2).join(" ")}{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 via-teal-500 to-blue-600">
              {t("title").split(" ").slice(-2).join(" ")}
            </span>
          </h2>

          <p className="text-lg md:text-xl text-slate-500 dark:text-slate-400 leading-relaxed font-medium">
            {t("subtitle")}
          </p>
        </motion.div>

        {/* ── METRICS ROW ── */}
        <motion.div {...fadeUp(0.1)} className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-20">
          {metrics.map((m, i) => {
            const Icon = m.icon;
            return (
              <div
                key={i}
                className="group flex flex-col items-center text-center p-6 rounded-3xl bg-white dark:bg-slate-900/50 border border-slate-200 dark:border-white/[0.07] hover:border-emerald-300 dark:hover:border-emerald-800/50 hover:shadow-xl hover:shadow-emerald-50 dark:hover:shadow-emerald-900/20 transition-all duration-500"
              >
                <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center mb-4 shadow-lg shadow-emerald-500/20 group-hover:scale-110 transition-transform duration-500">
                  <Icon size={20} className="text-white" strokeWidth={2} />
                </div>
                <div className="text-4xl font-black text-slate-900 dark:text-white tracking-tighter mb-1">
                  {m.value}
                </div>
                <div className="text-slate-500 dark:text-slate-400 text-sm font-semibold">
                  {m.label}
                </div>
              </div>
            );
          })}
        </motion.div>

        {/* ── MAIN CONTENT ── */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center mb-20">

          {/* Left — Visual card stack */}
          <motion.div {...fadeLeft} className="relative">
            {/* Outer glow */}
            <div className="absolute inset-0 bg-gradient-to-tr from-emerald-400/20 to-cyan-500/20 rounded-[3rem] blur-3xl pointer-events-none" />

            <div className="relative space-y-4">
              {/* Main card */}
              <div className="relative bg-white dark:bg-slate-900 rounded-[28px] border border-slate-200 dark:border-white/[0.08] shadow-2xl p-8 overflow-hidden">
                <div className="absolute top-0 right-0 w-48 h-48 bg-gradient-to-br from-emerald-400/10 to-teal-500/5 rounded-bl-[80px] pointer-events-none" />
                <div className="flex items-start gap-5 relative z-10">
                  <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center shadow-lg shadow-emerald-500/30 flex-shrink-0">
                    <Lock size={24} className="text-white" />
                  </div>
                  <div>
                    <h3 className="text-xl font-black text-slate-900 dark:text-white mb-1 tracking-tight">
                      {t("builtForYou")}
                    </h3>
                    <p className="text-slate-500 dark:text-slate-400 text-sm font-medium leading-relaxed">
                      {t("transactions")}
                    </p>
                  </div>
                </div>

                <div className="mt-6 pt-6 border-t border-slate-100 dark:border-slate-800 grid grid-cols-3 gap-4">
                  {[
                    { label: "Security", value: "A+" },
                    { label: "Speed", value: "<1s" },
                    { label: "Trust", value: "★★★★★" },
                  ].map((stat, i) => (
                    <div key={i} className="text-center">
                      <div className="text-lg font-black text-emerald-600 dark:text-emerald-400">
                        {stat.value}
                      </div>
                      <div className="text-slate-500 dark:text-slate-400 text-xs font-medium mt-0.5">
                        {stat.label}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Users card */}
              <div className="bg-gradient-to-r from-[#0f172a] to-[#1e293b] dark:from-[#040D1F] dark:to-[#0B1628] rounded-[22px] p-6 flex items-center gap-5 shadow-xl">
                <div className="flex -space-x-3 flex-shrink-0">
                  {["bg-emerald-400", "bg-blue-400", "bg-violet-400", "bg-amber-400"].map((c, i) => (
                    <div
                      key={i}
                      className={`w-10 h-10 rounded-full ${c} border-2 border-[#0f172a] dark:border-[#040D1F] flex items-center justify-center`}
                    >
                      <Users size={12} className="text-white" />
                    </div>
                  ))}
                  <div className="w-10 h-10 rounded-full bg-white/10 border-2 border-[#0f172a] dark:border-[#040D1F] flex items-center justify-center">
                    <span className="text-white text-[9px] font-black">+50k</span>
                  </div>
                </div>
                <div>
                  <div className="text-white font-bold text-sm">{t("activeUsers")}</div>
                  <div className="text-emerald-400 text-xs font-semibold flex items-center gap-1 mt-0.5">
                    <TrendingUp size={11} />
                    {t("growingDaily")}
                  </div>
                </div>
              </div>

              {/* Global reach card */}
              <div className="bg-white dark:bg-slate-900 rounded-[22px] border border-slate-200 dark:border-white/[0.08] p-6 flex items-center gap-5 shadow-lg">
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center shadow-lg shadow-blue-500/25 flex-shrink-0">
                  <Globe size={22} className="text-white" />
                </div>
                <div>
                  <div className="text-slate-900 dark:text-white font-bold text-sm">Global Coverage</div>
                  <div className="text-slate-500 dark:text-slate-400 text-xs font-medium mt-0.5">
                    Send money to 40+ countries instantly
                  </div>
                </div>
                <div className="ml-auto">
                  <div className="w-8 h-8 rounded-full bg-emerald-50 dark:bg-emerald-900/30 flex items-center justify-center">
                    <CheckCircle2 size={16} className="text-emerald-500" />
                  </div>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Right — Pillar features */}
          <motion.div {...fadeRight} className="space-y-5">
            {pillars.map((p, idx) => {
              const Icon = p.icon;
              return (
                <motion.div
                  key={idx}
                  {...fadeUp(0.15 + idx * 0.1)}
                  className="group flex gap-5 p-6 rounded-3xl bg-white dark:bg-slate-900/50 border border-slate-200 dark:border-white/[0.07] hover:border-emerald-300 dark:hover:border-emerald-800/50 hover:shadow-xl hover:shadow-emerald-50 dark:hover:shadow-emerald-900/20 transition-all duration-500 cursor-default"
                >
                  <div
                    className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${p.gradient} flex items-center justify-center shadow-lg ${p.glow} flex-shrink-0 group-hover:scale-110 transition-transform duration-500`}
                  >
                    <Icon size={22} className="text-white" strokeWidth={1.8} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="text-slate-900 dark:text-white font-bold text-lg mb-1 tracking-tight">
                      {p.title}
                    </h4>
                    <p className="text-slate-500 dark:text-slate-400 text-sm leading-relaxed mb-4">
                      {p.desc}
                    </p>
                    <ul className="space-y-1.5">
                      {p.checks.map((c, i) => (
                        <li key={i} className="flex items-center gap-2 text-xs text-slate-600 dark:text-slate-400 font-medium">
                          <CheckCircle2 size={13} className="text-emerald-500 flex-shrink-0" />
                          {c}
                        </li>
                      ))}
                    </ul>
                  </div>
                </motion.div>
              );
            })}
          </motion.div>
        </div>

        {/* ── BOTTOM CTA STRIP ── */}
        <motion.div {...fadeUp(0.2)}>
          <div className="relative rounded-[32px] bg-gradient-to-r from-[#0f172a] via-[#1a2744] to-[#0f172a] dark:from-[#040D1F] dark:via-[#0B1628] dark:to-[#040D1F] border border-white/[0.06] overflow-hidden p-10 md:px-16 md:py-12 flex flex-col md:flex-row items-center justify-between gap-8">
            <div className="absolute top-0 right-0 w-[400px] h-[300px] bg-emerald-500/10 rounded-full blur-[80px] pointer-events-none" />
            <div className="absolute bottom-0 left-20 w-[300px] h-[200px] bg-blue-600/10 rounded-full blur-[60px] pointer-events-none" />

            <div className="relative z-10 text-center md:text-left">
              <div className="text-white font-black text-2xl md:text-3xl tracking-tight mb-2">
                Join the{" "}
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-teal-400">
                  MurtaaxPay
                </span>{" "}
                community
              </div>
              <p className="text-slate-400 font-medium">
                Trusted by 50,000+ users across the global diaspora
              </p>
            </div>

            <div className="relative z-10 flex flex-col sm:flex-row gap-3 flex-shrink-0">
              <a
                href="/signup"
                className="inline-flex items-center justify-center gap-2 px-7 py-3.5 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-black rounded-2xl transition-all shadow-xl shadow-emerald-500/25 text-sm uppercase tracking-wide"
              >
                Get Started <ArrowRight size={15} />
              </a>
              <a
                href="/contact"
                className="inline-flex items-center justify-center gap-2 px-7 py-3.5 bg-white/10 hover:bg-white/15 border border-white/15 text-white font-bold rounded-2xl transition-all text-sm uppercase tracking-wide backdrop-blur-sm"
              >
                Learn More
              </a>
            </div>
          </div>
        </motion.div>

      </div>
    </section>
  );
}

"use client";

import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import {
  Check,
  X,
  Zap,
  ArrowRight,
  Globe,
  Lock,
  ShieldCheck,
  Sparkles,
  Star,
  CreditCard,
  Users,
  Headphones,
  TrendingUp,
  BadgeCheck,
  Infinity,
} from "lucide-react";
import { useState } from "react";
import { motion } from "framer-motion";
import NextImage from "next/image";
import { useTranslations } from "next-intl";

const fadeUp = (delay = 0) => ({
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.6, delay, ease: [0.22, 1, 0.36, 1] },
});

export default function PricingPage() {
  const [hoveredPlan, setHoveredPlan] = useState<string | null>(null);
  const t = useTranslations("PricingPage");

  const freeFeatures = [
    { icon: Globe, text: t("checkPoints.idTransfer") },
    { icon: Zap, text: t("checkPoints.mobileMoney") },
    { icon: CreditCard, text: t("checkPoints.virtualCard") },
    { icon: Headphones, text: t("checkPoints.standardSupport") },
  ];

  const proFeatures = [
    { icon: CreditCard, text: t("checkPoints.steelCard") },
    { icon: Infinity, text: t("checkPoints.unlimitedAtm") },
    { icon: Users, text: t("checkPoints.priorityManager") },
    { icon: TrendingUp, text: t("checkPoints.cryptoAccess") },
  ];

  const tableRows = [
    {
      icon: Lock,
      label: t("table.maintenance"),
      free: t("table.noFee"),
      pro: t("table.noFee"),
      freeGood: true,
      proGood: true,
    },
    {
      icon: Zap,
      label: t("table.transfers"),
      free: t("table.instant"),
      pro: t("table.instant"),
      freeGood: true,
      proGood: true,
    },
    {
      icon: CreditCard,
      label: t("table.withdrawal"),
      free: "$5k /mo",
      pro: t("table.unlimited"),
      freeGood: false,
      proGood: true,
    },
    {
      icon: Globe,
      label: t("table.wireFees"),
      free: "0.5% Flat",
      pro: "0% Free",
      freeGood: false,
      proGood: true,
    },
    {
      icon: Headphones,
      label: t("table.concierge"),
      free: null,
      pro: true,
      freeGood: false,
      proGood: true,
    },
    {
      icon: TrendingUp,
      label: t("table.investments"),
      free: null,
      pro: true,
      freeGood: false,
      proGood: true,
    },
  ];

  const trustItems = [
    { icon: ShieldCheck, label: "Bank-grade security" },
    { icon: BadgeCheck, label: "Fully licensed" },
    { icon: Globe, label: "40+ countries" },
    { icon: Star, label: "4.9★ rated" },
  ];

  return (
    <main className="min-h-screen bg-gradient-to-b from-[#f4f9fb] to-white dark:from-[#040D1F] dark:to-[#020617] transition-colors duration-300 overflow-hidden">
      <Navbar />

      {/* ── HERO ── */}
      <section className="relative pt-28 pb-20 overflow-hidden">
        {/* Orbs — brand standard */}
        <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-emerald-300/20 dark:bg-emerald-900/30 rounded-full blur-[130px] pointer-events-none mix-blend-multiply dark:mix-blend-screen" />
        <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-cyan-300/20 dark:bg-cyan-900/30 rounded-full blur-[120px] pointer-events-none mix-blend-multiply dark:mix-blend-screen" />
        <div className="absolute top-1/2 left-1/2 w-[500px] h-[500px] bg-blue-300/20 dark:bg-blue-900/20 rounded-full blur-[100px] pointer-events-none -translate-x-1/2 -translate-y-1/2 mix-blend-multiply dark:mix-blend-screen" />

        <div className="max-w-4xl mx-auto px-4 text-center relative z-10">
          <motion.div {...fadeUp()}>
            {/* Badge */}
            <div className="inline-flex items-center gap-3 px-2 py-2 pr-5 rounded-full bg-white/60 dark:bg-slate-900/60 backdrop-blur-xl border border-white dark:border-white/10 shadow-sm mb-8">
              <span className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white text-[10px] font-black px-3 py-1.5 rounded-full uppercase tracking-widest shadow-md">
                {t("badge")}
              </span>
              <span className="text-slate-600 dark:text-slate-300 text-sm font-semibold flex items-center gap-1.5">
                <Sparkles size={13} className="text-emerald-500" />
                Simple, Transparent Pricing
              </span>
            </div>

            <h1 className="text-6xl sm:text-7xl font-black text-slate-900 dark:text-white tracking-tighter leading-[1.05] mb-6">
              {t("titlePart1")}
              <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 via-teal-500 to-blue-600">
                {t("titleHighlight")}
              </span>
            </h1>
            <p className="text-lg md:text-xl text-slate-500 dark:text-slate-400 max-w-2xl mx-auto leading-relaxed font-medium">
              {t("subtitle")}
            </p>
          </motion.div>
        </div>
      </section>

      {/* ── PLAN CARDS ── */}
      <section className="pb-24 px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="max-w-5xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-6 lg:gap-8">

          {/* FREE PLAN */}
          <motion.div
            {...fadeUp(0.1)}
            onMouseEnter={() => setHoveredPlan("free")}
            onMouseLeave={() => setHoveredPlan(null)}
            className="relative group flex flex-col p-8 rounded-[32px] bg-white dark:bg-slate-900/60 border border-slate-200 dark:border-white/[0.08] hover:border-emerald-200 dark:hover:border-emerald-800/50 hover:shadow-2xl hover:shadow-emerald-50 dark:hover:shadow-emerald-900/20 transition-all duration-500 backdrop-blur-sm"
          >
            {/* Header */}
            <div className="flex items-start justify-between mb-6">
              <div>
                <span className="inline-block px-3 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-400 text-[10px] font-black uppercase tracking-widest mb-3">
                  {t("freeBadge")}
                </span>
                <h2 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight">
                  {t("freePlanName")}
                </h2>
              </div>
              <div className="text-right">
                <div className="text-5xl font-black text-slate-900 dark:text-white tracking-tighter leading-none">
                  $0
                </div>
                <div className="text-slate-400 text-xs font-semibold uppercase tracking-wide mt-1">
                  / {t("monthly")}
                </div>
              </div>
            </div>

            <p className="text-slate-500 dark:text-slate-400 text-sm leading-relaxed mb-8 font-medium">
              {t("freePlanDesc")}
            </p>

            {/* Card visual */}
            <div className="relative h-44 mb-8 rounded-2xl overflow-hidden bg-gradient-to-br from-slate-100 to-slate-200 dark:from-slate-800 dark:to-slate-900 border border-slate-200 dark:border-white/[0.06] p-5 flex flex-col justify-between group-hover:shadow-lg transition-all duration-500">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <NextImage src="/images/app_logo.png" alt="Logo" width={24} height={24} />
                  <span className="text-slate-700 dark:text-slate-300 font-black text-xs tracking-wide">MURTAAX PAY</span>
                </div>
                <div className="w-8 h-5 bg-gradient-to-r from-yellow-400 to-amber-500 rounded-sm shadow-sm" />
              </div>
              <div>
                <div className="text-slate-400 dark:text-slate-500 font-mono text-sm tracking-[0.2em] mb-1">•••• •••• •••• 8842</div>
                <div className="text-slate-600 dark:text-slate-400 text-[10px] font-black uppercase tracking-widest">Free Explorer</div>
              </div>
              {/* Shine */}
              <div className="absolute inset-0 bg-gradient-to-br from-white/30 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none" />
            </div>

            {/* Features */}
            <ul className="space-y-3.5 mb-8 flex-grow">
              {freeFeatures.map((f, i) => {
                const Icon = f.icon;
                return (
                  <li key={i} className="flex items-center gap-3">
                    <div className="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/40 flex items-center justify-center flex-shrink-0">
                      <Check size={12} className="text-emerald-600 dark:text-emerald-400" strokeWidth={3} />
                    </div>
                    <span className="text-slate-700 dark:text-slate-300 text-sm font-semibold">{f.text}</span>
                  </li>
                );
              })}
            </ul>

            {/* CTA */}
            <a
              href="/signup"
              className="w-full py-4 rounded-2xl font-black text-sm flex items-center justify-center gap-2 border-2 border-slate-200 dark:border-slate-700 text-slate-800 dark:text-white hover:border-emerald-400 dark:hover:border-emerald-600 hover:text-emerald-600 dark:hover:text-emerald-400 transition-all duration-300 uppercase tracking-wide"
            >
              {t("freePlanCta")} <ArrowRight size={16} />
            </a>
          </motion.div>

          {/* PRO PLAN — Featured */}
          <motion.div
            {...fadeUp(0.2)}
            onMouseEnter={() => setHoveredPlan("pro")}
            onMouseLeave={() => setHoveredPlan(null)}
            className="relative group flex flex-col p-8 rounded-[32px] bg-gradient-to-br from-[#0f172a] via-[#1a2744] to-[#0f172a] dark:from-[#040D1F] dark:via-[#0B1628] dark:to-[#040D1F] border border-white/[0.08] hover:border-emerald-500/30 shadow-xl shadow-slate-900/20 dark:shadow-black/40 hover:shadow-emerald-500/10 transition-all duration-500"
          >
            {/* Popular badge */}
            <div className="absolute -top-4 left-1/2 -translate-x-1/2">
              <div className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full bg-gradient-to-r from-emerald-500 to-teal-600 text-white text-[10px] font-black uppercase tracking-widest shadow-lg shadow-emerald-500/30">
                <Star size={11} fill="white" />
                {t("proBadge")}
              </div>
            </div>

            {/* Orb */}
            <div className="absolute top-0 right-0 w-48 h-48 bg-emerald-500/10 rounded-full blur-[60px] pointer-events-none" />

            {/* Header */}
            <div className="flex items-start justify-between mb-6 mt-4 relative z-10">
              <div>
                <span className="inline-block px-3 py-1 rounded-full bg-emerald-500/15 text-emerald-400 text-[10px] font-black uppercase tracking-widest mb-3 border border-emerald-500/20">
                  Premium
                </span>
                <h2 className="text-2xl font-black text-white tracking-tight">
                  {t("proPlanName")}
                </h2>
              </div>
              <div className="text-right">
                <div className="text-5xl font-black text-white tracking-tighter leading-none">
                  $12<span className="text-2xl">.99</span>
                </div>
                <div className="text-slate-400 text-xs font-semibold uppercase tracking-wide mt-1">
                  / {t("monthly")}
                </div>
              </div>
            </div>

            <p className="text-slate-400 text-sm leading-relaxed mb-8 font-medium relative z-10">
              {t("proPlanDesc")}
            </p>

            {/* Card visual — dark premium */}
            <div className="relative h-44 mb-8 rounded-2xl overflow-hidden bg-gradient-to-br from-[#1e293b] to-[#0f172a] border border-white/[0.08] p-5 flex flex-col justify-between group-hover:border-emerald-500/20 transition-all duration-500 z-10">
              <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-500/10 rounded-full blur-[40px] pointer-events-none" />
              <div className="flex items-center justify-between relative z-10">
                <div className="flex items-center gap-2">
                  <NextImage src="/images/weblogowhite.png" alt="Logo" width={24} height={24} className="brightness-0 invert" />
                  <span className="text-white font-black text-xs tracking-wide">MURTAAX PAY</span>
                </div>
                <div className="w-8 h-5 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-sm shadow-sm" />
              </div>
              <div className="relative z-10">
                <div className="text-slate-500 font-mono text-sm tracking-[0.2em] mb-1">•••• •••• •••• 8824</div>
                <div className="text-emerald-400 text-[10px] font-black uppercase tracking-widest">Platinum Pro</div>
              </div>
              <div className="absolute inset-0 bg-gradient-to-br from-white/5 via-transparent to-transparent pointer-events-none" />
            </div>

            {/* Features */}
            <ul className="space-y-3.5 mb-8 flex-grow relative z-10">
              {proFeatures.map((f, i) => {
                const Icon = f.icon;
                return (
                  <li key={i} className="flex items-center gap-3">
                    <div className="w-6 h-6 rounded-full bg-emerald-500/20 flex items-center justify-center flex-shrink-0">
                      <Check size={12} className="text-emerald-400" strokeWidth={3} />
                    </div>
                    <span className="text-slate-300 text-sm font-semibold">{f.text}</span>
                  </li>
                );
              })}
            </ul>

            {/* CTA */}
            <a
              href="/signup"
              className="relative z-10 w-full py-4 rounded-2xl font-black text-sm flex items-center justify-center gap-2 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white shadow-xl shadow-emerald-500/25 transition-all duration-300 uppercase tracking-wide overflow-hidden group/btn"
            >
              <div className="absolute inset-0 bg-white/10 translate-x-[-100%] group-hover/btn:translate-x-[100%] transition-transform duration-700 pointer-events-none" />
              {t("proPlanCta")} <ArrowRight size={16} />
            </a>
          </motion.div>
        </div>

        {/* Trust row */}
        <motion.div {...fadeUp(0.3)} className="max-w-5xl mx-auto mt-10 flex flex-wrap justify-center gap-6">
          {trustItems.map((item, i) => {
            const Icon = item.icon;
            return (
              <div key={i} className="flex items-center gap-2 text-slate-500 dark:text-slate-400 text-sm font-semibold">
                <Icon size={15} className="text-emerald-500" />
                {item.label}
              </div>
            );
          })}
        </motion.div>
      </section>

      {/* ── COMPARISON TABLE ── */}
      <section className="py-24 px-4 sm:px-6 lg:px-8">
        <div className="max-w-5xl mx-auto">
          <motion.div {...fadeUp()} className="text-center mb-14">
            <h2 className="text-4xl md:text-5xl font-black text-slate-900 dark:text-white tracking-tight mb-4">
              {t("matrixTitle")}{" "}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 to-teal-500">
                {t("matrixHighlight")}
              </span>
            </h2>
            <p className="text-slate-500 dark:text-slate-400 font-medium max-w-xl mx-auto">
              Everything side by side — no hidden fees, no surprises.
            </p>
          </motion.div>

          {/* Table header */}
          <div className="rounded-[28px] overflow-hidden border border-slate-200 dark:border-white/[0.07] bg-white dark:bg-slate-900/50 backdrop-blur-sm">
            {/* Column headers */}
            <div className="grid grid-cols-3 bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-white/[0.07] px-6 py-5">
              <div className="text-slate-400 text-xs font-bold uppercase tracking-widest">Feature</div>
              <div className="text-center">
                <span className="text-slate-600 dark:text-slate-300 font-black text-sm">Free Explorer</span>
              </div>
              <div className="text-center">
                <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-gradient-to-r from-emerald-500 to-teal-600 text-white font-black text-xs shadow-lg shadow-emerald-500/20">
                  <Star size={10} fill="white" />
                  Platinum Pro
                </span>
              </div>
            </div>

            {/* Rows */}
            {tableRows.map((row, i) => {
              const Icon = row.icon;
              return (
                <div
                  key={i}
                  className={`grid grid-cols-3 px-6 py-5 items-center ${i < tableRows.length - 1 ? "border-b border-slate-100 dark:border-white/[0.04]" : ""} hover:bg-slate-50/50 dark:hover:bg-white/[0.02] transition-colors duration-200`}
                >
                  {/* Feature label */}
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center flex-shrink-0">
                      <Icon size={15} className="text-slate-400 dark:text-slate-500" />
                    </div>
                    <span className="text-slate-700 dark:text-slate-300 text-sm font-semibold">{row.label}</span>
                  </div>

                  {/* Free value */}
                  <div className="text-center">
                    {row.free === null ? (
                      <div className="inline-flex items-center justify-center w-7 h-7 rounded-full bg-red-50 dark:bg-red-900/20">
                        <X size={14} className="text-red-400" strokeWidth={2.5} />
                      </div>
                    ) : (
                      <span className="text-slate-500 dark:text-slate-400 text-sm font-semibold">{row.free}</span>
                    )}
                  </div>

                  {/* Pro value */}
                  <div className="text-center">
                    {row.pro === true ? (
                      <div className="inline-flex items-center justify-center w-7 h-7 rounded-full bg-emerald-100 dark:bg-emerald-900/30">
                        <Check size={14} className="text-emerald-600 dark:text-emerald-400" strokeWidth={3} />
                      </div>
                    ) : (
                      <span className="text-emerald-600 dark:text-emerald-400 text-sm font-black">{row.pro}</span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ── BOTTOM CTA ── */}
      <section className="pb-24 px-4 sm:px-6 lg:px-8">
        <div className="max-w-5xl mx-auto">
          <div className="relative rounded-[40px] bg-gradient-to-br from-[#0f172a] via-[#1a2744] to-[#0f172a] dark:from-[#040D1F] dark:via-[#0B1628] dark:to-[#040D1F] border border-white/[0.06] overflow-hidden p-12 md:p-20 text-center">
            <div className="absolute top-0 right-0 w-[500px] h-[400px] bg-emerald-500/10 rounded-full blur-[100px] pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-[400px] h-[300px] bg-teal-600/10 rounded-full blur-[80px] pointer-events-none" />

            <div className="relative z-10">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 border border-white/15 text-emerald-400 text-xs font-bold uppercase tracking-widest mb-8">
                <Sparkles size={12} /> No commitment required
              </div>
              <h2 className="text-4xl md:text-5xl font-black text-white tracking-tight mb-4">
                Start for{" "}
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-teal-400">
                  free today
                </span>
              </h2>
              <p className="text-slate-400 font-medium max-w-lg mx-auto mb-10 leading-relaxed">
                Open your account in 2 minutes. Upgrade anytime — no lock-in, cancel anytime.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <a href="/signup" className="inline-flex items-center justify-center gap-2 px-8 py-4 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-black rounded-2xl transition-all shadow-xl shadow-emerald-500/25 text-sm uppercase tracking-wide">
                  Get Started Free <ArrowRight size={16} />
                </a>
                <a href="/contact" className="inline-flex items-center justify-center px-8 py-4 bg-white/10 hover:bg-white/15 border border-white/20 text-white font-bold rounded-2xl transition-all text-sm uppercase tracking-wide backdrop-blur-sm">
                  Talk to Sales
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

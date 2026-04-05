"use client";

import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import {
  ArrowRight,
  HandCoins,
  TrendingUp,
  PiggyBank,
  Briefcase,
  HeartHandshake,
  Ticket,
  Users,
  Gift,
  Sparkles,
  ShieldCheck,
  Zap,
  BadgeCheck,
} from "lucide-react";
import { useTranslations } from "next-intl";

export default function ServicesPage() {
  const t = useTranslations("ServicesPage");

  const services = [
    {
      icon: HandCoins,
      gradient: "from-emerald-500 to-teal-500",
      lightBg: "bg-emerald-50",
      darkBg: "dark:bg-emerald-900/20",
      border: "border-emerald-100 dark:border-emerald-800/30",
      hoverBorder: "hover:border-emerald-300 dark:hover:border-emerald-600/50",
      iconColor: "text-emerald-600 dark:text-emerald-400",
      glow: "hover:shadow-emerald-100 dark:hover:shadow-emerald-900/30",
      title: t("items.request.title"),
      desc: t("items.request.desc"),
      href: "/services/request",
    },
    {
      icon: TrendingUp,
      gradient: "from-blue-500 to-cyan-500",
      lightBg: "bg-blue-50",
      darkBg: "dark:bg-blue-900/20",
      border: "border-blue-100 dark:border-blue-800/30",
      hoverBorder: "hover:border-blue-300 dark:hover:border-blue-600/50",
      iconColor: "text-blue-600 dark:text-blue-400",
      glow: "hover:shadow-blue-100 dark:hover:shadow-blue-900/30",
      title: t("items.exchange.title"),
      desc: t("items.exchange.desc"),
      href: "/services/exchange",
    },
    {
      icon: PiggyBank,
      gradient: "from-violet-500 to-purple-600",
      lightBg: "bg-violet-50",
      darkBg: "dark:bg-violet-900/20",
      border: "border-violet-100 dark:border-violet-800/30",
      hoverBorder: "hover:border-violet-300 dark:hover:border-violet-600/50",
      iconColor: "text-violet-600 dark:text-violet-400",
      glow: "hover:shadow-violet-100 dark:hover:shadow-violet-900/30",
      title: t("items.savings.title"),
      desc: t("items.savings.desc"),
      href: "/services/savings",
    },
    {
      icon: Briefcase,
      gradient: "from-teal-500 to-emerald-600",
      lightBg: "bg-teal-50",
      darkBg: "dark:bg-teal-900/20",
      border: "border-teal-100 dark:border-teal-800/30",
      hoverBorder: "hover:border-teal-300 dark:hover:border-teal-600/50",
      iconColor: "text-teal-600 dark:text-teal-400",
      glow: "hover:shadow-teal-100 dark:hover:shadow-teal-900/30",
      title: t("items.investments.title"),
      desc: t("items.investments.desc"),
      href: "/services/investments",
    },
    {
      icon: HeartHandshake,
      gradient: "from-rose-500 to-pink-500",
      lightBg: "bg-rose-50",
      darkBg: "dark:bg-rose-900/20",
      border: "border-rose-100 dark:border-rose-800/30",
      hoverBorder: "hover:border-rose-300 dark:hover:border-rose-600/50",
      iconColor: "text-rose-600 dark:text-rose-400",
      glow: "hover:shadow-rose-100 dark:hover:shadow-rose-900/30",
      title: t("items.sadaqah.title"),
      desc: t("items.sadaqah.desc"),
      href: "/services/sadaqah",
    },
    {
      icon: Gift,
      gradient: "from-amber-500 to-orange-500",
      lightBg: "bg-amber-50",
      darkBg: "dark:bg-amber-900/20",
      border: "border-amber-100 dark:border-amber-800/30",
      hoverBorder: "hover:border-amber-300 dark:hover:border-amber-600/50",
      iconColor: "text-amber-600 dark:text-amber-400",
      glow: "hover:shadow-amber-100 dark:hover:shadow-amber-900/30",
      title: t("items.giftcards.title"),
      desc: t("items.giftcards.desc"),
      href: "/services/giftcards",
    },
    {
      icon: Users,
      gradient: "from-cyan-500 to-sky-500",
      lightBg: "bg-cyan-50",
      darkBg: "dark:bg-cyan-900/20",
      border: "border-cyan-100 dark:border-cyan-800/30",
      hoverBorder: "hover:border-cyan-300 dark:hover:border-cyan-600/50",
      iconColor: "text-cyan-600 dark:text-cyan-400",
      glow: "hover:shadow-cyan-100 dark:hover:shadow-cyan-900/30",
      title: t("items.refer.title"),
      desc: t("items.refer.desc"),
      href: "/services/refer",
    },
    {
      icon: Ticket,
      gradient: "from-fuchsia-500 to-purple-600",
      lightBg: "bg-fuchsia-50",
      darkBg: "dark:bg-fuchsia-900/20",
      border: "border-fuchsia-100 dark:border-fuchsia-800/30",
      hoverBorder: "hover:border-fuchsia-300 dark:hover:border-fuchsia-600/50",
      iconColor: "text-fuchsia-600 dark:text-fuchsia-400",
      glow: "hover:shadow-fuchsia-100 dark:hover:shadow-fuchsia-900/30",
      title: t("items.vouchers.title"),
      desc: t("items.vouchers.desc"),
      href: "/services/vouchers",
    },
  ];

  const pillars = [
    { icon: Zap, label: t("pillarInstant") },
    { icon: ShieldCheck, label: t("pillarSecurity") },
    { icon: BadgeCheck, label: t("pillarLicensed") },
  ];

  return (
    <main className="min-h-screen bg-gradient-to-b from-[#f4f9fb] to-white dark:from-[#040D1F] dark:to-[#020617] transition-colors duration-300">
      <Navbar />

      {/* ── HERO ── */}
      <section className="relative overflow-hidden pt-28 pb-24">
        {/* Same orb pattern as HeroSection */}
        <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-emerald-300/20 dark:bg-emerald-900/30 rounded-full blur-[120px] pointer-events-none mix-blend-multiply dark:mix-blend-screen" />
        <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-cyan-300/20 dark:bg-cyan-900/30 rounded-full blur-[120px] pointer-events-none mix-blend-multiply dark:mix-blend-screen" />
        <div className="absolute top-1/2 left-1/2 w-[500px] h-[500px] bg-blue-300/20 dark:bg-blue-900/30 rounded-full blur-[100px] pointer-events-none mix-blend-multiply dark:mix-blend-screen -translate-x-1/2 -translate-y-1/2" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative z-10">
          {/* Badge — matching HeroSection badge style */}
          <div className="inline-flex items-center gap-3 px-2 py-2 pr-5 rounded-full bg-white/60 dark:bg-slate-900/60 backdrop-blur-xl border border-white dark:border-white/10 mb-8 shadow-sm">
            <span className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white text-[10px] font-black px-3 py-1.5 rounded-full uppercase tracking-widest shadow-md">
              {t("badgeLabel")}
            </span>
            <span className="text-slate-600 dark:text-slate-300 text-sm font-semibold flex items-center gap-1.5">
              <Sparkles size={13} className="text-emerald-500" />
              {t("badgeSub")}
            </span>
          </div>

          {/* Headline — matching HeroSection font weight & gradient */}
          <h1 className="text-6xl sm:text-7xl font-black text-slate-900 dark:text-slate-50 tracking-tighter mb-6 leading-[1.05]">
            {t("title")}
            <br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 via-teal-500 to-blue-600">
              {t("titleHighlight")}
            </span>
          </h1>

          <p className="text-lg md:text-xl text-slate-500 dark:text-slate-400 max-w-2xl mx-auto mb-10 leading-relaxed font-medium">
            {t("subtitle")}
          </p>

          {/* Pillars */}
          <div className="flex flex-wrap items-center justify-center gap-4">
            {pillars.map((p, i) => {
              const Icon = p.icon;
              return (
                <div
                  key={i}
                  className="inline-flex items-center gap-2 px-4 py-2.5 rounded-full bg-white dark:bg-slate-900/70 backdrop-blur-md border border-slate-200 dark:border-white/10 text-slate-600 dark:text-slate-300 text-sm font-semibold shadow-sm"
                >
                  <Icon size={15} className="text-emerald-500" />
                  {p.label}
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ── SERVICES GRID ── */}
      <section className="pb-28 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {services.map((service, idx) => {
              const Icon = service.icon;
              return (
                <a
                  key={idx}
                  href={service.href}
                  className={`group relative flex flex-col p-7 rounded-3xl bg-white dark:bg-slate-900/50 border ${service.border} ${service.hoverBorder} hover:shadow-2xl ${service.glow} transition-all duration-500 overflow-hidden cursor-pointer backdrop-blur-sm`}
                >
                  {/* Icon */}
                  <div
                    className={`relative w-14 h-14 rounded-2xl bg-gradient-to-br ${service.gradient} flex items-center justify-center mb-5 shadow-lg group-hover:scale-110 transition-transform duration-500`}
                  >
                    <Icon
                      size={24}
                      className="text-white"
                      strokeWidth={1.8}
                    />
                  </div>

                  {/* Text */}
                  <h3 className="text-slate-900 dark:text-slate-50 font-bold text-lg mb-2 tracking-tight">
                    {service.title}
                  </h3>
                  <p className="text-slate-500 dark:text-slate-400 text-sm leading-relaxed flex-grow">
                    {service.desc}
                  </p>

                  {/* CTA */}
                  <div className="flex items-center gap-2 mt-6 text-emerald-600 dark:text-emerald-400 text-xs font-bold uppercase tracking-widest group-hover:gap-3 transition-all duration-300">
                    {t("explore")}
                    <ArrowRight size={13} />
                  </div>

                  {/* Subtle corner gradient */}
                  <div
                    className={`absolute -bottom-6 -right-6 w-24 h-24 bg-gradient-to-tl ${service.gradient} opacity-0 group-hover:opacity-10 rounded-full transition-opacity duration-500`}
                  />
                </a>
              );
            })}
          </div>
        </div>
      </section>

      {/* ── CTA BANNER ── matching CtaBanner style from the site */}
      <section className="pb-28 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="relative rounded-[40px] overflow-hidden bg-gradient-to-br from-[#0f172a] via-[#1e293b] to-[#0f172a] dark:from-[#040D1F] dark:via-[#0B1628] dark:to-[#040D1F] p-12 md:p-20 text-center">
            {/* Orbs */}
            <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-emerald-500/10 rounded-full blur-[120px] pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-blue-600/10 rounded-full blur-[100px] pointer-events-none" />

            <div className="relative z-10">
              {/* Badge */}
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 border border-white/15 text-emerald-400 text-xs font-bold uppercase tracking-widest mb-8">
                <Sparkles size={12} />
                MurtaaxPay
              </div>

              <h2 className="text-4xl md:text-5xl font-black text-white mb-6 tracking-tight leading-tight">
                {t("ctaTitle")}
              </h2>

              <p className="text-slate-400 text-lg max-w-xl mx-auto mb-10 leading-relaxed">
                {t("subtitle")}
              </p>

              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <a
                  href="/signup"
                  className="inline-flex items-center justify-center gap-2 px-8 py-4 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-black rounded-2xl transition-all duration-300 shadow-xl shadow-emerald-500/25 text-sm uppercase tracking-wide"
                >
                  {t("ctaPrimary")}
                  <ArrowRight size={16} />
                </a>
                <a
                  href="/contact"
                  className="inline-flex items-center justify-center gap-2 px-8 py-4 bg-white/10 hover:bg-white/15 border border-white/20 text-white font-bold rounded-2xl transition-all duration-300 text-sm uppercase tracking-wide backdrop-blur-sm"
                >
                  {t("ctaSecondary")}
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

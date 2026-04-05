"use client";

import NextImage from "next/image";
import { ArrowRight, PlayCircle, BadgeCheck, CreditCard } from "lucide-react";
import { useState, useEffect } from "react";
import { toast } from "sonner";
import { useTranslations } from "next-intl";

export default function HeroSection() {
  const screenshots = ["/images/app.png", "/images/app1.png", "/images/app2.png"];
  const [currentIndex, setCurrentIndex] = useState(0);
  const t = useTranslations("Hero");

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % screenshots.length);
    }, 3500);
    return () => clearInterval(timer);
  }, [screenshots.length]);

  return (
    <section id="home" className="relative overflow-hidden bg-gradient-to-b from-[#f4f9fb] to-white dark:from-[#040D1F] dark:to-[#020617] pt-24 pb-32 transition-colors duration-300">
      {/* Dynamic Gradient Lighting Effects */}
      <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-emerald-300/20 dark:bg-emerald-900/30 rounded-full blur-[120px] pointer-events-none mix-blend-multiply dark:mix-blend-screen" />
      <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-cyan-300/20 dark:bg-cyan-900/30 rounded-full blur-[120px] pointer-events-none mix-blend-multiply dark:mix-blend-screen" />
      <div className="absolute top-1/2 left-1/2 w-[500px] h-[500px] bg-blue-300/20 dark:bg-blue-900/30 rounded-full blur-[100px] pointer-events-none mix-blend-multiply dark:mix-blend-screen transform -translate-x-1/2 -translate-y-1/2" />

      {/* Grid Pattern Texture */}
      <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20 dark:opacity-10 pointer-events-none" style={{ mixBlendMode: 'overlay' }} />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 mt-12">
        <div className="grid grid-cols-1 xl:grid-cols-2 gap-20 items-center">
          
          {/* Left Text Content */}
          <div className="max-w-2xl">
            {/* Glassmorphism Badge */}
            <div className="inline-flex items-center gap-3 px-2 py-2 pr-4 rounded-full bg-white/60 dark:bg-slate-900/60 backdrop-blur-xl border border-white dark:border-white/10 mb-8 shadow-sm">
              <span className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white text-[10px] sm:text-xs font-black px-3 py-1.5 rounded-full uppercase tracking-widest shadow-md">
                {t('badgeNew')}
              </span>
              <span className="text-slate-700 dark:text-slate-300 text-xs sm:text-sm font-semibold">
                {t('badgeText')}
              </span>
            </div>

            {/* Headline */}
            <h1 className="text-6xl sm:text-7xl lg:text-[5.5rem] font-black text-slate-900 dark:text-slate-50 tracking-tighter mb-8 leading-[1.05]">
              {t('titlePrefix')} <br/>
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 via-teal-500 to-blue-600">
                {t('titleHighlight')}
              </span>
            </h1>

            {/* Description */}
            <p className="text-lg md:text-xl text-slate-500 dark:text-slate-400 mb-12 max-w-xl leading-relaxed font-medium">
              {t('subtitle')}
            </p>

            {/* Solid CTA Area */}
            <div className="flex flex-col sm:flex-row items-start sm:items-center gap-6">
              <a href="/signup" className="bg-[#10b981] dark:bg-emerald-500 hover:bg-emerald-600 text-white dark:text-slate-950 px-8 py-4 rounded-full font-bold text-lg transition-all flex items-center gap-2 shadow-lg shadow-emerald-500/20 hover:-translate-y-1">
                {t('ctaPrimary')} <ArrowRight size={20} />
              </a>
              
              <button 
                onClick={() => document.getElementById('services')?.scrollIntoView({ behavior: 'smooth' })} 
                className="flex items-center gap-3 text-slate-600 dark:text-slate-300 font-semibold hover:text-slate-900 dark:hover:text-white transition-colors group"
              >
                <div className="w-12 h-12 rounded-full bg-white dark:bg-slate-800 shadow-sm border border-gray-200 dark:border-white/10 flex items-center justify-center group-hover:scale-105 transition-transform">
                  <PlayCircle size={18} className="fill-current text-emerald-500 ml-1" />
                </div>
                {t('ctaSecondary')}
              </button>
            </div>

            {/* Trust Logos */}
            <div className="pt-8 border-t border-gray-200/60 dark:border-white/10 mt-12">
              <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mb-6">{t('trustText')}</p>
              <div className="flex flex-wrap items-center gap-8 opacity-50 dark:opacity-30 grayscale hover:grayscale-0 dark:hover:opacity-100 transition-all duration-500">
                <NextImage src="/images/zaad.png" alt="ZAAD" width={80} height={30} className="h-6 w-auto object-contain dark:invert" />
                <NextImage src="/images/evc.png" alt="EVC Plus" width={80} height={30} className="h-7 w-auto object-contain dark:invert" />
                <NextImage src="/images/edahab.png" alt="eDahab" width={80} height={30} className="h-6 w-auto object-contain dark:invert" />
                <NextImage src="/images/bank.png" alt="Premier Bank" width={100} height={30} className="h-6 w-auto object-contain dark:invert" />
              </div>
            </div>
          </div>

          {/* Right Hero Image / Mockups */}
          <div className="relative mx-auto xl:ml-auto w-full max-w-[420px] mt-24 xl:mt-0">
            
            {/* The Floating Transfer Badge (Glassmorphism) */}
            <div className="absolute top-24 -left-8 sm:-left-24 bg-white/70 dark:bg-slate-900/70 backdrop-blur-2xl p-4 pr-8 rounded-2xl shadow-[0_20px_40px_-15px_rgba(0,0,0,0.1)] border border-white dark:border-white/10 z-30 flex items-center gap-5 transition-transform hover:-translate-y-2 duration-500">
              <div className="w-12 h-12 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center shadow-inner">
                <BadgeCheck size={24} stroke="url(#emerald-gradient)" strokeWidth={2.5} className="drop-shadow-sm" />
              </div>
              <div>
                <p className="text-[10px] text-slate-500 dark:text-slate-400 font-bold uppercase tracking-widest mb-0.5">{t('floatingTransferLabel')}</p>
                <p className="text-slate-900 dark:text-slate-50 font-black text-xl">$ 1,450.00</p>
              </div>
            </div>

            {/* The Floating Balance Card (Glassmorphism) */}
            <div className="absolute bottom-40 -right-6 sm:-right-20 bg-white/70 dark:bg-slate-900/70 backdrop-blur-2xl p-6 rounded-2xl shadow-[0_20px_40px_-15px_rgba(0,0,0,0.1)] border border-white dark:border-white/10 z-30 flex flex-col gap-2 transition-transform hover:-translate-y-2 duration-500 delay-100">
              <div className="flex items-center gap-3 mb-1">
                <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900/50 flex items-center justify-center">
                  <CreditCard size={18} stroke="url(#blue-gradient)" strokeWidth={2.5} className="drop-shadow-sm" />
                </div>
                <span className="text-slate-600 dark:text-slate-400 text-xs font-bold uppercase tracking-wider">{t('floatingBalanceLabel')}</span>
              </div>
              <p className="text-slate-900 dark:text-slate-50 font-black text-3xl tracking-tight">$ 8,240.50</p>
              <p className="text-emerald-500 dark:text-emerald-400 text-xs font-bold flex items-center gap-1 mt-1 bg-emerald-50 dark:bg-emerald-900/30 w-fit px-2 py-1 rounded-md">
                {t('floatingMonthBadge')}
              </p>
            </div>

            {/* The Phone Device Mockup with Frame */}
            <div className="relative w-[320px] md:w-[350px] h-[680px] md:h-[720px] mx-auto transform xl:rotate-[-5deg] xl:hover:rotate-0 transition-transform duration-700 bg-slate-900 dark:bg-slate-950 rounded-[3rem] border-[8px] border-slate-800 shadow-[0_0_80px_rgba(16,185,129,0.15)] p-1 z-20">
              {/* Inner Screen holding the screenshot */}
              <div className="relative w-full h-full rounded-[2.5rem] bg-[#0f172a] shadow-inner">
                {screenshots.map((src, index) => (
                  <div
                    key={src}
                    className={`absolute inset-0 rounded-[2.5rem] overflow-hidden transform-gpu transition-opacity duration-1000 ${
                      index === currentIndex ? "opacity-100 z-10" : "opacity-0 z-0"
                    }`}
                    style={{ WebkitMaskImage: '-webkit-radial-gradient(white, black)' }}
                  >
                    <NextImage 
                      src={src}
                      alt={`MurtaaxPay App Interface ${index + 1}`}
                      fill
                      className={`object-cover object-top ${index === 0 ? "scale-100" : "scale-[1.08]"}`}
                      priority={index === 0}
                    />
                  </div>
                ))}
              </div>
            </div>
            
            {/* Base Floor Shadow */}
            <div className="absolute -bottom-8 left-1/2 -translate-x-1/2 w-[140%] h-16 bg-slate-900/10 dark:bg-black/40 blur-2xl rounded-[100%] z-10 pointer-events-none"></div>
            <div className="absolute -bottom-8 left-1/2 -translate-x-1/2 w-[80%] h-12 bg-emerald-500/15 dark:bg-emerald-500/10 blur-2xl rounded-[100%] z-10 pointer-events-none"></div>
            
          </div>
        </div>
      </div>
    </section>
  );
}

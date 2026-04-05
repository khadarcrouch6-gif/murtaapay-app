"use client";

import { LockKeyhole, ShieldCheck } from "lucide-react";
import { useTranslations } from "next-intl";

export default function SecurityDNA() {
  const t = useTranslations("Security");

  return (
    <section className="py-24 bg-white dark:bg-[#040D1F] px-4 sm:px-6 lg:px-8 transition-colors duration-300">
      <div className="max-w-6xl mx-auto bg-[#0f172a] dark:bg-[#0a0f1c] rounded-[3rem] p-12 md:p-20 text-center relative overflow-hidden">
        
        {/* Glow Effects */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[400px] bg-emerald-500/10 blur-[100px] rounded-full pointer-events-none"></div>

        <div className="relative z-10">
          <h2 className="text-4xl md:text-5xl font-extrabold text-white mb-6 tracking-tight">
            {t('title')}
          </h2>
          <p className="text-slate-400 text-lg max-w-2xl mx-auto mb-16 leading-relaxed">
            {t('subtitle')}
          </p>

          {/* Timeline UI */}
          <div className="max-w-2xl mx-auto bg-[#1e293b]/50 border border-white/10 rounded-[2rem] p-10 backdrop-blur-md">
            
            {/* Steps */}
            <div className="flex justify-between items-center relative mb-12">
              {/* Line behind */}
              <div className="absolute top-1/2 left-0 right-0 h-0.5 bg-slate-700 -translate-y-1/2 z-0"></div>
              <div className="absolute top-1/2 left-0 w-1/2 h-0.5 bg-emerald-500 -translate-y-1/2 z-0"></div>
              
              <div className="w-10 h-10 rounded-full bg-emerald-500 border-4 border-[#0f172a] relative z-10 flex items-center justify-center">
                 <ShieldCheck size={14} stroke="url(#emerald-gradient)" strokeWidth={2.5} className="text-white" />
              </div>
              <div className="w-10 h-10 rounded-full bg-emerald-500 border-4 border-[#0f172a] relative z-10"></div>
              <div className="w-10 h-10 rounded-full bg-slate-700 border-4 border-[#0f172a] relative z-10"></div>
            </div>

            {/* Shield Graphic */}
            <div className="w-32 h-32 mx-auto bg-gradient-to-br from-slate-700 to-slate-800 rounded-3xl p-1 shadow-2xl rotate-45 mb-10 overflow-hidden relative">
              <div className="w-full h-full bg-[#0f172a] rounded-[1.4rem] flex items-center justify-center -rotate-45 relative z-10">
                <LockKeyhole stroke="url(#amber-gradient)" strokeWidth={2.5} size={32} />
              </div>
              
              {/* Scanner Line */}
              <div className="absolute inset-0 bg-emerald-500/20 z-20 animate-pulse"></div>
            </div>

            <h3 className="text-white font-bold text-2xl mb-2">{t('liveProtection')}</h3>
            <p className="text-slate-400 max-w-sm mx-auto">
              {t('protectionDesc')}
            </p>

            <button className="mt-8 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 px-6 py-2.5 rounded-full font-medium transition-all text-sm">
               {t('report')}
            </button>
          </div>
        </div>
      </div>
    </section>
  );
}

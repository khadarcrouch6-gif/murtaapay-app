"use client";

import { SmartphoneNfc, SquareArrowUpRight } from "lucide-react";
import { useTranslations } from "next-intl";

export default function FeaturesGrid() {
  const t = useTranslations("Features");

  return (
    <section id="features" className="py-24 bg-zinc-50 dark:bg-[#040D1F] transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 className="text-4xl md:text-5xl font-extrabold text-[#0f172a] dark:text-white mb-16 max-w-xl leading-tight">
          {t('sectionTitle')}
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
          
          {/* Card 1: 0% Fee Murtaax Wallet (Dark) - Spans 8 cols */}
          <div className="md:col-span-8 bg-[#0f172a] rounded-[2rem] p-10 md:p-12 relative overflow-hidden group">
            {/* Abstract background rings */}
            <div className="absolute right-0 top-1/2 -translate-y-1/2 w-[400px] h-[400px] border border-[#1e293b] rounded-full opacity-20 group-hover:scale-110 transition-transform duration-700 pointer-events-none"></div>
            <div className="absolute right-10 top-1/2 -translate-y-1/2 w-[300px] h-[300px] border-[2px] border-[#1e293b] rounded-full opacity-40 group-hover:scale-110 transition-transform duration-700 pointer-events-none"></div>
            <div className="absolute right-20 top-1/2 -translate-y-1/2 w-[200px] h-[200px] border-[4px] border-[#334155] rounded-full group-hover:scale-110 transition-transform duration-700 shadow-[0_0_60px_rgba(16,185,129,0.15)] flex items-center justify-center overflow-hidden bg-[#0f172a]/80 backdrop-blur-md z-0">
              <img src="/images/app_logo.png" alt="MurtaaxPay Logo" className="w-[120px] h-[120px] object-contain drop-shadow-2xl group-hover:scale-105 transition-transform duration-500" />
            </div>

            <div className="relative z-10 max-w-md h-full flex flex-col justify-between">
              <div>
                <div className="inline-flex items-center px-3 py-1 rounded-full bg-white/10 text-emerald-400 text-xs font-bold mb-6 backdrop-blur-md">
                  {t('card1Badge')}
                </div>
                <h3 className="text-3xl font-bold text-white mb-4">{t('card1Title')}</h3>
                <p className="text-slate-300 text-lg leading-relaxed mb-10">
                  {t('card1Desc')}
                </p>
              </div>
              <button className="bg-emerald-500 hover:bg-emerald-400 text-white px-6 py-3 rounded-full font-medium transition-colors w-fit">
                {t('card1Cta')}
              </button>
            </div>
          </div>

          {/* Card 2: Mobile Money Integration (Light) - Spans 4 cols */}
          <div className="md:col-span-4 bg-indigo-50/50 dark:bg-indigo-900/20 rounded-[2rem] p-10 relative overflow-hidden flex flex-col justify-between hover:shadow-xl hover:shadow-indigo-100/50 dark:hover:shadow-indigo-900/50 transition-shadow border border-transparent dark:border-indigo-500/10">
            <div>
              <div className="w-10 h-10 rounded-full bg-indigo-100 dark:bg-indigo-900/50 flex items-center justify-center mb-6">
                <SmartphoneNfc stroke="url(#indigo-gradient)" strokeWidth={2.5} size={24} className="drop-shadow-md" />
              </div>
              <h3 className="text-2xl font-bold text-[#0f172a] dark:text-white mb-3">{t('card2Title')}</h3>
              <p className="text-slate-500 dark:text-slate-400">
                {t('card2Desc')}
              </p>
            </div>
            <button className="text-indigo-600 dark:text-indigo-400 font-semibold flex items-center gap-2 mt-8 hover:gap-3 transition-all">
              {t('card2Cta')} <SquareArrowUpRight size={18} />
            </button>
          </div>

          {/* Card 3: Multi-language Support (Green) - Spans 4 cols */}
          <div className="md:col-span-4 bg-emerald-300 rounded-[2rem] p-10 relative overflow-hidden text-[#064e3b]">
            <div className="w-10 h-10 rounded-full bg-emerald-200/50 flex items-center justify-center mb-6 backdrop-blur-sm">
              <span className="font-bold">Aa</span>
            </div>
            <h3 className="text-2xl font-bold mb-3">{t('card3Title')}</h3>
            <p className="text-emerald-800 font-medium mb-10 opacity-90">
              {t('card3Desc')}
            </p>
            <button className="bg-white/20 hover:bg-white/30 text-emerald-950 font-semibold px-5 py-2.5 rounded-full transition-colors backdrop-blur-md text-sm cursor-pointer inline-flex items-center gap-2">
              {t('card3Cta')} <SquareArrowUpRight size={16} />
            </button>
          </div>

          {/* Card 4: Free to All Nationals (White) - Spans 8 cols */}
          <div className="md:col-span-8 bg-white dark:bg-slate-900/40 border border-gray-100 dark:border-white/10 shadow-sm rounded-[2rem] p-10 flex flex-col md:flex-row items-center justify-between gap-8 h-full backdrop-blur-md">
            <div className="max-w-sm">
              <h3 className="text-2xl font-bold text-[#0f172a] dark:text-white mb-3">{t('card4Title')}</h3>
              <p className="text-slate-500 dark:text-slate-400">
                {t('card4Desc')}
              </p>
              <button className="mt-6 border border-gray-200 dark:border-white/20 text-[#0f172a] dark:text-white font-medium px-6 py-2.5 rounded-full hover:bg-gray-50 dark:hover:bg-white/5 transition-colors">
                {t('card4Cta')}
              </button>
            </div>
            
            {/* Avatars cluster */}
            <div className="flex -space-x-4 relative">
              <div className="w-16 h-16 rounded-full border-4 border-white dark:border-slate-800 overflow-hidden bg-slate-200 shadow-md">
                <img src={`https://i.pravatar.cc/150?u=a042581f4e29026704d`} alt="User 1" />
              </div>
              <div className="w-16 h-16 rounded-full border-4 border-white dark:border-slate-800 overflow-hidden bg-slate-200 shadow-md">
                <img src={`https://i.pravatar.cc/150?u=a042581f4e2902670dd`} alt="User 2" />
              </div>
              <div className="w-16 h-16 rounded-full border-4 border-white dark:border-slate-800 overflow-hidden bg-emerald-500 dark:bg-emerald-600 shadow-md flex items-center justify-center text-white font-bold text-sm">
                +2M
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

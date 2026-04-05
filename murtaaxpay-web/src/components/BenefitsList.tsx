"use client";

import { ShieldCheck, Timer, UsersRound, SmartphoneNfc } from "lucide-react";
import { useTranslations } from "next-intl";

export default function BenefitsList() {
  const t = useTranslations("Benefits");

  const benefits = [
    {
      icon: <ShieldCheck stroke="url(#emerald-gradient)" strokeWidth={2.5} size={24} />,
      title: t('fastSafe'),
      desc: t('fastSafeDesc'),
      link: t('fastSafeLink'),
    },
    {
      icon: <Timer stroke="url(#emerald-gradient)" strokeWidth={2.5} size={24} />,
      title: t('support'),
      desc: t('supportDesc'),
      link: t('supportLink'),
    },
    {
      icon: <UsersRound stroke="url(#emerald-gradient)" strokeWidth={2.5} size={24} />,
      title: t('murtaaxId'),
      desc: t('murtaaxIdDesc'),
      link: t('murtaaxIdLink'),
    },
    {
      icon: <SmartphoneNfc stroke="url(#emerald-gradient)" strokeWidth={2.5} size={24} />,
      title: t('virtualWallet'),
      desc: t('virtualWalletDesc'),
      link: t('virtualWalletLink'),
    },
  ];

  return (
    <section id="benefits" className="py-24 bg-white dark:bg-[#040D1F] transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center pt-8">
        <h2 className="text-4xl md:text-5xl font-extrabold text-[#0f172a] dark:text-white mb-6">
          {t('title')}
        </h2>
        <p className="text-lg text-slate-500 dark:text-slate-400 mb-16 max-w-2xl mx-auto">
          {t('subtitle')}
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {benefits.map((item, idx) => (
            <div key={idx} className="bg-white dark:bg-slate-900 border border-gray-100 dark:border-white/10 rounded-[2rem] p-8 hover:shadow-xl hover:shadow-emerald-100/50 dark:hover:shadow-emerald-900/50 transition-all text-left group">
              <div className="w-14 h-14 rounded-2xl bg-emerald-50 dark:bg-emerald-900/30 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                {item.icon}
              </div>
              <h3 className="text-xl font-bold text-[#0f172a] dark:text-white mb-4">{item.title}</h3>
              <p className="text-slate-500 dark:text-slate-400 mb-8 flex-1">{item.desc}</p>
              <a href="#" className="text-emerald-500 font-medium hover:underline flex items-center gap-1 text-sm">
                {item.link} 
              </a>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

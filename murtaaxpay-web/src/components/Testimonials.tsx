"use client";

import { Star } from "lucide-react";
import { useTranslations } from "next-intl";

export default function Testimonials() {
  const t = useTranslations("Testimonials");

  return (
    <section className="py-24 bg-white dark:bg-[#040D1F] transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
          <div>
            <h2 className="text-5xl font-extrabold text-[#0f172a] dark:text-white leading-tight">
              {t('title')}<br />
              <span className="text-emerald-500">{t('highlight')}</span>
            </h2>
          </div>

          <div className="bg-white dark:bg-slate-900 rounded-[2rem] p-10 shadow-[0_20px_50px_rgba(0,0,0,0.05)] dark:shadow-none border border-gray-50 dark:border-white/10">
            <div className="flex gap-1 text-yellow-400 mb-6">
              <Star fill="currentColor" size={20} />
              <Star fill="currentColor" size={20} />
              <Star fill="currentColor" size={20} />
              <Star fill="currentColor" size={20} />
              <Star fill="currentColor" size={20} />
            </div>
            <p className="text-xl text-slate-700 dark:text-slate-300 font-medium leading-relaxed mb-8 italic">
              "{t('quote')}"
            </p>
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-full overflow-hidden bg-slate-200">
                <img src="https://i.pravatar.cc/150?u=a042581f4e2902670dd" alt="User Avatar" className="w-full h-full object-cover" />
              </div>
              <div>
                <p className="font-bold text-[#0f172a] dark:text-white">{t('name')}</p>
                <p className="text-slate-500 dark:text-slate-400 text-sm">{t('role')}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

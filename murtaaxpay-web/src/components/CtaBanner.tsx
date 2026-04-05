"use client";

import { useTranslations } from "next-intl";

export default function CtaBanner() {
  const t = useTranslations("Cta");

  return (
    <section id="cta" className="py-24 bg-white dark:bg-[#040D1F] px-4 sm:px-6 lg:px-8 transition-colors duration-300">
      <div className="max-w-6xl mx-auto rounded-[3rem] bg-gradient-to-br from-teal-800 via-emerald-700 to-emerald-400 p-12 md:p-24 text-center text-white relative overflow-hidden shadow-2xl shadow-emerald-900/20">
        
        {/* Decorative elements */}
        <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-5 rounded-full blur-3xl transform translate-x-1/2 -translate-y-1/2"></div>
        <div className="absolute bottom-0 left-0 w-64 h-64 bg-teal-900 opacity-20 rounded-full blur-3xl transform -translate-x-1/2 translate-y-1/2"></div>

        <div className="relative z-10">
          <h2 className="text-4xl md:text-6xl font-extrabold mb-6 tracking-tight">
            {t('title')}
          </h2>
          <p className="text-emerald-100 text-lg md:text-xl max-w-2xl mx-auto mb-10">
            {t('subtitle')}
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button className="bg-white text-emerald-800 hover:bg-emerald-50 px-8 py-4 rounded-full font-bold text-lg transition-colors w-full sm:w-auto shadow-lg">
              {t('signup')}
            </button>
            <button className="bg-[#0f172a] text-white hover:bg-[#1e293b] px-8 py-4 rounded-full font-bold text-lg transition-colors w-full sm:w-auto shadow-lg">
              {t('download')}
            </button>
          </div>
        </div>
      </div>
    </section>
  );
}

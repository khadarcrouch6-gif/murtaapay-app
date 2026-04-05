"use client";

import Image from "next/image";

export default function PartnersCarousel() {
  const partners = [
    { name: "MurtaaxPay Wallet", src: "/images/walletlogo.png", h: 40, extraClass: "scale-150 transform origin-center" },
    { name: "ZAAD", src: "/images/zaad.png", h: 40, extraClass: "" },
    { name: "EVC Plus", src: "/images/evc.png", h: 48, extraClass: "" },
    { name: "eDahab", src: "/images/edahab.png", h: 40, extraClass: "" },
    { name: "Premier Bank", src: "/images/bank.png", h: 40, extraClass: "" },
    { name: "Visa", isCustom: true, type: "visa" },
    { name: "Mastercard", isCustom: true, type: "mastercard" },
    { name: "Stripe", isCustom: true, type: "stripe" },
  ];

  const allPartners = [...partners, ...partners];

  return (
    <section className="py-12 border-b border-gray-100 dark:border-white/5 bg-white dark:bg-[#040D1F] transition-colors duration-300 overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <p className="text-center text-xs font-bold text-slate-400 dark:text-slate-500 tracking-[0.2em] uppercase mb-12">
          TRUSTED BY 1M+ SOMALIS AND LEADING ORGANIZATIONS
        </p>
        
        <div className="relative overflow-hidden group pause-marquee">
          <div className="flex items-center gap-12 md:gap-20 animate-marquee py-4">
            {allPartners.map((partner, index) => (
              <div key={`${partner.name}-${index}`} className="flex items-center justify-center transition-all duration-300 hover:scale-110 cursor-default shrink-0">
                {partner.isCustom ? (
                  <div className="flex items-center">
                    {partner.type === 'visa' && (
                      <span className="text-xl md:text-2xl font-black italic tracking-tighter text-slate-300 dark:text-slate-600 group-hover:text-blue-700 dark:group-hover:text-blue-400 transition-colors">VISA</span>
                    )}
                    {partner.type === 'mastercard' && (
                      <div className="flex -space-x-3 md:-space-x-4 opacity-40 dark:opacity-30 group-hover:opacity-100 transition-opacity">
                        <div className="w-5 h-5 md:w-8 md:h-8 rounded-full bg-slate-400 group-hover:bg-red-500 transition-colors"></div>
                        <div className="w-5 h-5 md:w-8 md:h-8 rounded-full bg-slate-500 group-hover:bg-amber-500 transition-colors"></div>
                      </div>
                    )}
                    {partner.type === 'stripe' && (
                      <span className="text-xl md:text-2xl font-black tracking-tighter text-slate-300 dark:text-slate-600 group-hover:text-[#635bff] dark:group-hover:text-indigo-400 transition-colors uppercase">stripe</span>
                    )}
                  </div>
                ) : (
                  <Image 
                    src={partner.src!} 
                    alt={partner.name} 
                    width={120} 
                    height={partner.h} 
                    className={`object-contain h-7 md:h-10 w-auto grayscale dark:invert opacity-40 dark:opacity-30 group-hover:grayscale-0 dark:group-hover:invert-0 group-hover:opacity-100 transition-all duration-300 ${partner.extraClass}`}
                  />
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

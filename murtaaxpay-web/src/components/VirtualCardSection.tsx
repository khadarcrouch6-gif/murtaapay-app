"use client";

import { ArrowRight, Wallet, BadgeCheck, CreditCard } from "lucide-react";
import { toast } from "sonner";
import Image from "next/image";
import { useTranslations } from "next-intl";

export default function VirtualCardSection() {
  const t = useTranslations("VirtualCard");

  return (
    <section id="card" className="py-24 bg-[#0f172a] dark:bg-[#020813] text-white overflow-hidden relative transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          
          {/* Left Text */}
          <div className="order-last lg:order-last">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 text-emerald-400 font-semibold text-sm mb-6 backdrop-blur-md">
              <CreditCard size={16} /> {t('badge')}
            </div>
            <h2 className="text-4xl md:text-5xl font-extrabold mb-6 leading-tight">
              {t('title')}
            </h2>
            <p className="text-slate-400 text-lg mb-10 max-w-lg leading-relaxed">
              {t('description')}
            </p>
            <div className="flex flex-col sm:flex-row items-center gap-8">
              <button onClick={() => toast.success("Virtual Card issuing system connected!")} className="bg-emerald-500 hover:bg-emerald-400 text-white px-8 py-4 rounded-full font-semibold transition-all flex items-center gap-2">
                {t('cta')}
              </button>
              <div className="flex items-center gap-3 flex-nowrap shrink-0">
                <div className="flex gap-2 items-center">
                  <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center shadow-md z-30 shrink-0">
                    <span className="text-[10px] font-black text-blue-700 italic tracking-tighter">VISA</span>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center shadow-md z-20 shrink-0">
                    <div className="flex -space-x-1.5 opacity-90">
                      <div className="w-3 h-3 rounded-full bg-red-500"></div>
                      <div className="w-3 h-3 rounded-full bg-amber-400"></div>
                    </div>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center shadow-md z-10 shrink-0">
                    <span className="text-[10px] font-black text-[#635bff] tracking-tighter uppercase">stripe</span>
                  </div>
                </div>
                <span className="text-slate-400 text-xs whitespace-nowrap">{t('supported')}</span>
              </div>
            </div>
          </div>

          {/* Right Card Graphic */}
          <div className="relative mx-auto mt-12 lg:mt-0 w-full max-w-[500px] aspect-[1.6/1] order-first lg:order-first">
            <div className="absolute inset-0 bg-gradient-to-r from-emerald-500/20 to-teal-800/20 blur-3xl transform -rotate-6"></div>
            
            {/* The actual Virtual Card UI */}
            <div className="absolute inset-0 bg-gradient-to-br from-[#10b981] via-[#059669] to-[#047857] shadow-2xl rounded-3xl p-8 flex flex-col justify-between transform rotate-[-4deg] border border-white/20 overflow-hidden hover:rotate-0 transition-transform duration-500">
              
              {/* Card texture overlay */}
              <div className="absolute inset-0 opacity-10 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-white to-transparent pointer-events-none"></div>

              <div className="flex justify-between items-start relative z-10 w-full">
                <div></div>
                <div className="flex items-center">
                  <Image 
                    src="/images/weblogowhite.png" 
                    alt="MurtaaxPay Logo" 
                    width={220} 
                    height={55} 
                    className="h-14 w-auto object-contain opacity-100"
                  />
                </div>
              </div>

              <div className="relative z-10 text-white/90 font-mono tracking-[0.2em] text-2xl mt-8">
                4000 1234 5678 9010
              </div>

              <div className="flex justify-between items-end relative z-10 text-white/80 mt-6">
                <div className="flex gap-6 text-sm uppercase tracking-wider">
                  <div>
                    <div className="text-[10px] mb-1 opacity-70">VALID THRU</div>
                    <div className="font-semibold text-xs flex items-center gap-1">
                      12 / 26 <BadgeCheck stroke="url(#emerald-gradient)" strokeWidth={2.5} size={14} />
                    </div>
                  </div>
                  <div>
                    <div className="text-[10px] mb-1 opacity-70">CARDHOLDER</div>
                    <div className="font-semibold">AHMED ALI</div>
                  </div>
                </div>
                
                {/* Mastercard-like overlapping circles */}
                <div className="flex -space-x-3 opacity-90">
                  <div className="w-10 h-10 rounded-full bg-red-500/80 mix-blend-multiply"></div>
                  <div className="w-10 h-10 rounded-full bg-yellow-400/80 mix-blend-multiply"></div>
                </div>
              </div>
            </div>

            {/* Small floating tooltip */}
            <div className="absolute -bottom-8 -left-8 bg-white dark:bg-slate-800 text-[#0f172a] dark:text-white p-4 rounded-xl shadow-xl flex items-center gap-3 animate-bounce-slow">
              <div className="w-8 h-8 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center text-emerald-600 dark:text-emerald-400">
                    <BadgeCheck stroke="url(#emerald-gradient)" strokeWidth={2.5} size={24} />
              </div>
              <div className="text-sm font-bold">{t('label')}</div>
            </div>
            
          </div>
        </div>
      </div>
    </section>
  );
}

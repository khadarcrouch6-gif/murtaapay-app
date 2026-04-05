"use client";

import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { 
  Smartphone, 
  Globe, 
  Zap, 
  ShieldCheck, 
  ArrowRight,
  Plus,
  Lock,
  Search,
  Check
} from "lucide-react";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import NextImage from "next/image";
import { useTranslations } from "next-intl";

export default function CardsPage() {
  const t = useTranslations("CardsPage");
  
  const CARD_COLORS = [
    { id: "midnight", name: t('midnightBlack'), color: "from-[#0f172a] to-[#1e293b]", accent: "white" },
    { id: "emerald", name: t('murtaaxEmerald'), color: "from-[#11998E] to-[#38EF7D]", accent: "white" },
    { id: "titanium", name: t('titaniumSilver'), color: "from-[#d1d5db] to-[#9ca3af]", accent: "slate" },
  ];

  const [selectedColor, setSelectedColor] = useState(CARD_COLORS[0]);

  return (
    <main className="min-h-screen bg-white dark:bg-[#040D1F] transition-colors duration-500 selection:bg-emerald-500/30">
      <Navbar />

      {/* Modern Hero - Wallester Inspired */}
      <section className="relative pt-32 pb-40 overflow-hidden border-b border-slate-100 dark:border-white/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="flex flex-col lg:flex-row items-center gap-24">
            
            <motion.div 
              initial={{ opacity: 0, x: -30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              className="lg:w-1/2"
            >
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-100 dark:bg-white/5 text-slate-500 dark:text-slate-400 font-bold text-[10px] tracking-[0.2em] mb-8 border border-slate-200 dark:border-white/10 uppercase">
                {t('badge')}
              </div>
              <h1 className="text-6xl md:text-8xl font-black text-slate-900 dark:text-white mb-8 leading-[0.95] tracking-tighter">
                {t('titlePrefix')} <br />
                <span className="text-emerald-500">{t('titleHighlight')}</span>
              </h1>
              <p className="text-xl text-slate-500 dark:text-slate-400 mb-12 leading-relaxed max-w-lg font-medium">
                {t('subtitle')}
              </p>
              <div className="flex flex-col sm:flex-row gap-6">
                <button className="px-10 py-5 bg-[#0f172a] dark:bg-emerald-500 text-white dark:text-slate-950 font-black rounded-2xl transition-all shadow-2xl hover:scale-105 active:scale-95 flex items-center justify-center gap-3">
                  {t('cta')} <ArrowRight size={20} />
                </button>
                <div className="flex items-center gap-4 px-6 text-slate-400 font-medium text-sm">
                    <Check className="text-emerald-500" size={18} /> {t('noMonthlyFees')}
                </div>
              </div>
            </motion.div>

            {/* 3D Fanned Cards Visual */}
            <div className="lg:w-1/2 relative h-[500px] flex items-center justify-center">
                <motion.div 
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ duration: 1, delay: 0.2 }}
                    className="relative w-full h-full"
                >
                    {/* Background Cards */}
                    <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-sm aspect-[1.58/1] rounded-[32px] bg-gradient-to-br from-emerald-500 to-emerald-700 shadow-2xl rotate-[-15deg] -translate-x-24 opacity-40 blur-[2px]" />
                    <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-sm aspect-[1.58/1] rounded-[32px] bg-gradient-to-br from-slate-300 to-slate-400 shadow-2xl rotate-[10deg] translate-x-20 opacity-40 blur-[1px]" />
                    
                    {/* Main Focus Card */}
                    <motion.div 
                        whileHover={{ y: -20, rotateY: -10, rotateX: 10 }}
                        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md aspect-[1.58/1] rounded-[40px] bg-gradient-to-br from-[#0f172a] to-[#1e293b] shadow-[0_50px_100px_-15px_rgba(0,0,0,0.5)] border border-white/10 p-10 flex flex-col justify-between overflow-hidden cursor-pointer transition-transform duration-500 preserve-3d"
                    >
                         <div className="absolute top-0 right-0 w-[300px] h-[300px] bg-emerald-500/10 rounded-full blur-[80px] -mr-40 -mt-40 pointer-events-none" />
                         <div className="flex justify-between items-start relative z-10">
                            <div className="flex items-center gap-3">
                                <NextImage 
                                    src="/images/app_logo.png" 
                                    alt="Logo" 
                                    width={48} 
                                    height={48} 
                                    className="" 
                                />
                                <span className="text-white font-black text-3xl tracking-tighter italic">MURTAAX PAY</span>
                            </div>
                            <Zap className="text-emerald-400" size={32} />
                         </div>
                         <div className="relative z-10">
                            <div className="mb-8">
                                <div className="w-14 h-10 bg-gradient-to-br from-yellow-400 to-yellow-600 rounded-lg border border-yellow-300/50 shadow-inner" />
                            </div>
                            <div className="flex justify-between items-end">
                                <div className="flex flex-col">
                                    <p className="text-white/40 font-mono tracking-[0.2em] text-lg">•••• •••• •••• 8842</p>
                                    <span className="text-white/30 text-[10px] font-black uppercase tracking-[0.2em] mt-2">GUDOOMIYE</span>
                                </div>
                                <div className="flex -space-x-4">
                                    <div className="w-10 h-10 rounded-full bg-red-500/80" />
                                    <div className="w-10 h-10 rounded-full bg-yellow-500/80" />
                                </div>
                            </div>
                         </div>
                    </motion.div>
                </motion.div>
            </div>
          </div>
        </div>
      </section>

      {/* Interactive Customizer Section */}
      <section className="py-40 bg-slate-50 dark:bg-black/20">
        <div className="max-w-7xl mx-auto px-4">
            <div className="flex flex-col lg:flex-row items-center gap-24">
                
                <div className="lg:w-1/2 order-2 lg:order-1">
                    <AnimatePresence mode="wait">
                        <motion.div 
                            key={selectedColor.id}
                            initial={{ opacity: 0, scale: 0.9, rotateY: 45 }}
                            animate={{ opacity: 1, scale: 1, rotateY: 0 }}
                            exit={{ opacity: 0, scale: 1.1, rotateY: -45 }}
                            transition={{ type: "spring", stiffness: 100, damping: 20 }}
                            className={`w-full max-w-lg aspect-[1.58/1] rounded-[48px] bg-gradient-to-br ${selectedColor.color} shadow-2xl p-12 flex flex-col justify-between border border-white/10`}
                        >
                            <div className="flex justify-between items-center relative z-10">
                                <div className="flex items-center gap-3">
                                    <NextImage 
                                        src="/images/app_logo.png" 
                                        alt="Logo" 
                                        width={40} 
                                        height={40} 
                                        className={selectedColor.id === "midnight" ? "brightness-0 invert" : ""} 
                                    />
                                    <span className={`font-black text-2xl italic tracking-tighter ${selectedColor.accent === "white" ? "text-white" : "text-slate-900"}`}>MURTAAX PAY</span>
                                </div>
                                <div className="w-5 h-5 rounded-full bg-white/30 animate-pulse border border-white/20" />
                            </div>
                            <div className={`font-mono text-2xl tracking-[0.3em] ${selectedColor.id === "midnight" || selectedColor.id === "emerald" ? "text-white/80" : "text-slate-900/60"}`}>
                                •••• •••• •••• 8842
                            </div>
                            <div className="flex justify-between items-end">
                                <span className={`text-sm font-black uppercase tracking-widest ${selectedColor.id === "midnight" || selectedColor.id === "emerald" ? "text-white/50" : "text-slate-900/40"}`}>GUDOOMIYE</span>
                                <Globe className={selectedColor.id === "midnight" || selectedColor.id === "emerald" ? "text-white/40" : "text-slate-900/30"} size={24} />
                            </div>
                        </motion.div>
                    </AnimatePresence>
                </div>

                <div className="lg:w-1/2 order-1 lg:order-2">
                    <h2 className="text-4xl md:text-5xl font-black text-slate-900 dark:text-white mb-8 tracking-tight">{t('interactiveTitle')}</h2>
                    <p className="text-lg text-slate-500 mb-12 max-w-md font-medium">{t('interactiveP')}</p>
                    
                    <div className="flex flex-col gap-6">
                        {CARD_COLORS.map((style) => (
                            <button 
                                key={style.id}
                                onClick={() => setSelectedColor(style)}
                                className={`flex items-center justify-between p-6 rounded-[24px] transition-all border-2 ${selectedColor.id === style.id ? "bg-white dark:bg-white/5 border-emerald-500 shadow-xl" : "bg-transparent border-transparent hover:bg-slate-100 dark:hover:bg-white/5"}`}
                            >
                                <div className="flex items-center gap-4">
                                    <div className={`w-12 h-8 rounded-lg bg-gradient-to-br ${style.color}`} />
                                    <span className="font-bold text-slate-900 dark:text-white uppercase tracking-wider text-xs">{style.name}</span>
                                </div>
                                {selectedColor.id === style.id && <div className="w-6 h-6 rounded-full bg-emerald-50 flex items-center justify-center text-white"><Check size={14} /></div>}
                            </button>
                        ))}
                    </div>
                </div>

            </div>
        </div>
      </section>

      {/* Feature Bento Grid */}
      <section className="py-40">
        <div className="max-w-7xl mx-auto px-4">
            <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
                
                <div className="md:col-span-8 p-12 rounded-[48px] bg-slate-900 text-white relative overflow-hidden group">
                     <div className="absolute top-0 right-0 w-[400px] h-[400px] bg-emerald-500/20 rounded-full blur-[120px] pointer-events-none" />
                     <div className="relative z-10">
                        <Smartphone size={48} className="text-emerald-500 mb-8 animate-bounce" />
                        <h3 className="text-4xl font-black mb-6">{t('syncTitle')}</h3>
                        <p className="text-lg text-slate-400 max-w-md leading-relaxed mb-10">{t('syncP')}</p>
                        <div className="flex gap-4">
                            <div className="p-4 bg-white/5 rounded-2xl border border-white/10 flex flex-col gap-2">
                                <span className="text-3xl font-black">99.9%</span>
                                <span className="text-[10px] text-slate-500 uppercase tracking-widest font-bold">{t('uptime')}</span>
                            </div>
                            <div className="p-4 bg-white/5 rounded-2xl border border-white/10 flex flex-col gap-2">
                                <span className="text-3xl font-black">0.0s</span>
                                <span className="text-[10px] text-slate-500 uppercase tracking-widest font-bold">{t('latency')}</span>
                            </div>
                        </div>
                     </div>
                </div>

                <div className="md:col-span-4 p-12 rounded-[48px] bg-emerald-500 text-slate-950 flex flex-col justify-between group">
                    <div>
                        <Lock size={40} className="mb-8" />
                        <h3 className="text-3xl font-black mb-4 tracking-tighter leading-none">{t('guardTitle')}</h3>
                        <p className="text-slate-900/60 font-medium">{t('guardP')}</p>
                    </div>
                    <ArrowRight size={32} className="group-hover:translate-x-4 transition-transform duration-500" />
                </div>

                <div className="md:col-span-4 p-12 rounded-[48px] border-2 border-slate-100 dark:border-white/5 flex flex-col justify-between group">
                    <div className="w-16 h-16 rounded-full bg-slate-100 dark:bg-white/5 flex items-center justify-center mb-8">
                         <Globe size={32} className="text-emerald-500" />
                    </div>
                    <div>
                        <h3 className="text-2xl font-black text-slate-900 dark:text-white mb-4">{t('ibanTitle')}</h3>
                        <p className="text-slate-500 text-sm font-medium leading-relaxed">{t('ibanP')}</p>
                    </div>
                </div>

                <div className="md:col-span-8 p-12 rounded-[48px] bg-slate-50 dark:bg-white/5 border border-slate-100 dark:border-white/5 flex flex-col md:flex-row items-center gap-12 group">
                    <div className="w-full md:w-1/3 flex justify-center">
                         <div className="relative">
                            <div className="absolute inset-0 bg-emerald-500/20 blur-3xl rounded-full" />
                            <NextImage 
                                src="/images/app_logo.png" 
                                alt="Modern Pay" 
                                width={120} 
                                height={120} 
                                className="relative z-10 drop-shadow-2xl grayscale group-hover:grayscale-0 transition-all duration-700"
                            />
                         </div>
                    </div>
                    <div className="w-full md:w-2/3">
                        <h3 className="text-3xl font-black text-slate-900 dark:text-white mb-6">{t('syncWalletTitle')}</h3>
                        <p className="text-slate-500 font-medium mb-8">{t('syncWalletP')}</p>
                        <div className="flex gap-4">
                            <span className="text-xs font-black uppercase tracking-[0.2em] px-4 py-2 bg-white dark:bg-white/10 rounded-full border border-slate-200 dark:border-white/10 shadow-sm"> Pay</span>
                            <span className="text-xs font-black uppercase tracking-[0.2em] px-4 py-2 bg-white dark:bg-white/10 rounded-full border border-slate-200 dark:border-white/10 shadow-sm">Google Pay</span>
                        </div>
                    </div>
                </div>

            </div>
        </div>
      </section>

      {/* Final Action */}
      <section className="py-40 bg-slate-950 text-white relative overflow-hidden">
        <div className="max-w-4xl mx-auto px-4 text-center relative z-10">
            <h2 className="text-5xl md:text-7xl font-black mb-12 tracking-tighter">{t('finalTitle')}</h2>
            <div className="flex flex-col sm:flex-row gap-6 justify-center">
                <button className="px-12 py-6 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black rounded-[24px] transition-all shadow-2xl shadow-emerald-500/30 text-lg">
                    {t('orderPlatinum')}
                </button>
                <button className="px-12 py-6 bg-white/5 hover:bg-white/10 border border-white/10 text-white font-black rounded-[24px] transition-all text-lg">
                    {t('instantVirtual')}
                </button>
            </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}

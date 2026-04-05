"use client";

import { motion } from "framer-motion";
import { SendHorizonal, ArrowRightLeft, WalletCards, CircleDollarSign, HandHeart, Gift, UsersRound, Ticket, ArrowRight } from "lucide-react";
import { useTranslations } from "next-intl";
import { Link } from "@/i18n/routing";

export default function ServicesSection() {
  const t = useTranslations("Services");

  const services = [
    { id: "request", title: t('request.title'), desc: t('request.description'), icon: (props: any) => <SendHorizonal {...props} stroke="url(#blue-gradient)" strokeWidth={2.5} />, color: "bg-blue-500/10 text-blue-500" },
    { id: "exchange", title: t('exchange.title'), desc: t('exchange.description'), icon: (props: any) => <ArrowRightLeft {...props} stroke="url(#emerald-gradient)" strokeWidth={2.5} />, color: "bg-emerald-500/10 text-emerald-500" },
    { id: "savings", title: t('savings.title'), desc: t('savings.description'), icon: (props: any) => <WalletCards {...props} stroke="url(#indigo-gradient)" strokeWidth={2.5} />, color: "bg-purple-500/10 text-purple-500" },
    { id: "investments", title: t('investments.title'), desc: t('investments.description'), icon: (props: any) => <CircleDollarSign {...props} stroke="url(#amber-gradient)" strokeWidth={2.5} />, color: "bg-amber-500/10 text-amber-500" },
    { id: "sadaqah", title: t('sadaqah.title'), desc: t('sadaqah.description'), icon: (props: any) => <HandHeart {...props} stroke="url(#rose-gradient)" strokeWidth={2.5} />, color: "bg-red-500/10 text-red-500" },
    { id: "giftcards", title: t('giftcards.title'), desc: t('giftcards.description'), icon: (props: any) => <Gift {...props} stroke="url(#rose-gradient)" strokeWidth={2.5} />, color: "bg-pink-500/10 text-pink-500" },
    { id: "refer", title: t('refer.title'), desc: t('refer.description'), icon: (props: any) => <UsersRound {...props} stroke="url(#indigo-gradient)" strokeWidth={2.5} />, color: "bg-indigo-500/10 text-indigo-500" },
    { id: "vouchers", title: t('vouchers.title'), desc: t('vouchers.description'), icon: (props: any) => <Ticket {...props} stroke="url(#amber-gradient)" strokeWidth={2.5} />, color: "bg-orange-500/10 text-orange-500" },
  ];

  return (
    <section id="services" className="py-24 bg-white dark:bg-[#040D1F] transition-colors duration-300 relative overflow-hidden">
      {/* Background aesthetics */}
      <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-slate-50 dark:bg-emerald-900/10 rounded-full blur-[100px] -z-10" />
      <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bg-slate-50 dark:bg-blue-900/10 rounded-full blur-[100px] -z-10" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center max-w-2xl mx-auto mb-16">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-slate-100 dark:bg-slate-800/50 mb-6 border border-slate-200 dark:border-white/10"
          >
            <span className="w-2 h-2 rounded-full bg-emerald-500" />
            <span className="text-xs font-bold uppercase tracking-wider text-slate-600 dark:text-slate-300">{t('badge')}</span>
          </motion.div>
          <motion.h2 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="text-4xl md:text-5xl font-black text-slate-900 dark:text-white mb-6 tracking-tight"
          >
            {t('title')}
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }} 
            className="text-lg text-slate-500 dark:text-slate-400 font-medium leading-relaxed"
          >
            {t('subtitle')}
          </motion.p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {services.map((service, idx) => (
            <Link 
              key={service.id}
              href={`/services/${service.id}`}
            >
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: idx * 0.1 }}
                className="group relative h-full bg-white dark:bg-slate-900/40 backdrop-blur-sm border border-slate-200 dark:border-white/10 rounded-3xl p-6 hover:shadow-[0_8px_30px_rgb(0,0,0,0.04)] dark:hover:shadow-[0_8px_30px_rgba(16,185,129,0.1)] hover:-translate-y-1 transition-all duration-300"
              >
                <div className={`w-14 h-14 rounded-2xl flex items-center justify-center mb-6 transition-transform group-hover:scale-110 duration-300 ${service.color}`}>
                  <service.icon size={28} />
                </div>
                <h3 className="text-xl font-bold text-slate-900 dark:text-white mb-3 tracking-tight group-hover:text-emerald-500 transition-colors">
                  {service.title}
                </h3>
                <p className="text-slate-500 dark:text-slate-400 text-sm font-medium leading-relaxed mb-6">
                  {service.desc}
                </p>
                
                {/* Visual arrow pointer as feedback */}
                <div className="absolute bottom-6 right-6 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <div className="w-8 h-8 rounded-full bg-emerald-50 dark:bg-emerald-500/10 flex items-center justify-center">
                    <ArrowRight size={16} className="text-emerald-500" />
                  </div>
                </div>
              </motion.div>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}

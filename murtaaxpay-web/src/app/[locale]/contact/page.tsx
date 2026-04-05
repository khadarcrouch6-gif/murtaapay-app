"use client";

import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { Mail, Phone, MapPin, MessageCircle } from "lucide-react";
import { useTranslations } from "next-intl";

export default function ContactPage() {
  const t = useTranslations("ContactPage");

  return (
    <main className="min-h-screen bg-zinc-50 dark:bg-[#040D1F] transition-colors duration-300">
      <Navbar />
      
      <section className="py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16 max-w-2xl mx-auto">
            <h1 className="text-5xl font-black text-[#0f172a] dark:text-slate-50 mb-6">{t('title')}</h1>
            <p className="text-lg text-slate-500 dark:text-slate-400">
              {t('subtitle')}
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16">
            
            {/* Contact Info */}
            <div className="space-y-8">
              <div className="bg-white dark:bg-slate-900/50 rounded-3xl p-8 shadow-sm border border-gray-100 dark:border-white/10 flex items-start gap-6 transition-colors duration-300">
                <div className="bg-emerald-100 dark:bg-emerald-900/40 w-14 h-14 rounded-2xl flex items-center justify-center shrink-0">
                  <Mail className="text-emerald-600 dark:text-emerald-400 w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-[#0f172a] dark:text-slate-50 mb-2">{t('emailTitle')}</h3>
                  <p className="text-slate-500 dark:text-slate-400 mb-2">{t('emailDesc')}</p>
                  <a href="mailto:support@murtaaxpay.com" className="text-emerald-600 dark:text-emerald-400 font-bold hover:underline">support@murtaaxpay.com</a>
                </div>
              </div>

              <div className="bg-white dark:bg-slate-900/50 rounded-3xl p-8 shadow-sm border border-gray-100 dark:border-white/10 flex items-start gap-6 transition-colors duration-300">
                <div className="bg-blue-100 dark:bg-blue-900/40 w-14 h-14 rounded-2xl flex items-center justify-center shrink-0">
                  <Phone className="text-blue-600 dark:text-blue-400 w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-[#0f172a] dark:text-slate-50 mb-2">{t('callTitle')}</h3>
                  <p className="text-slate-500 dark:text-slate-400 mb-2">{t('callDesc')}</p>
                  <a href="tel:+252610000000" className="text-emerald-600 dark:text-emerald-400 font-bold hover:underline">+252 61 000 0000 (SO)</a>
                </div>
              </div>

              <div className="bg-white dark:bg-slate-900/50 rounded-3xl p-8 shadow-sm border border-gray-100 dark:border-white/10 flex items-start gap-6 transition-colors duration-300">
                <div className="bg-indigo-100 dark:bg-indigo-900/40 w-14 h-14 rounded-2xl flex items-center justify-center shrink-0">
                  <MessageCircle className="text-indigo-600 dark:text-indigo-400 w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-[#0f172a] dark:text-slate-50 mb-2">{t('chatTitle')}</h3>
                  <p className="text-slate-500 dark:text-slate-400 mb-2">{t('chatDesc')}</p>
                  <span className="text-emerald-600 dark:text-emerald-400 font-bold">{t('availableInApp')}</span>
                </div>
              </div>
            </div>

            {/* Contact Form */}
            <div className="bg-white dark:bg-slate-900/50 rounded-[2.5rem] p-10 shadow-xl border border-gray-100 dark:border-white/10 relative overflow-hidden transition-colors duration-300">
               <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-100 dark:bg-emerald-900/30 rounded-full blur-[60px] pointer-events-none" />
               <h2 className="text-2xl font-bold text-[#0f172a] dark:text-slate-50 mb-8 relative z-10">{t('formTitle')}</h2>
               <form className="space-y-6 relative z-10">
                 <div className="grid grid-cols-2 gap-6">
                   <div>
                     <label className="block text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">{t('firstName')}</label>
                     <input type="text" className="w-full bg-slate-50 dark:bg-slate-800/60 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-emerald-400 transition-colors" placeholder={t('placeholderFirstName')} />
                   </div>
                   <div>
                     <label className="block text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">{t('lastName')}</label>
                     <input type="text" className="w-full bg-slate-50 dark:bg-slate-800/60 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-emerald-400 transition-colors" placeholder={t('placeholderLastName')} />
                   </div>
                 </div>
                 <div>
                   <label className="block text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">{t('emailAddress')}</label>
                   <input type="email" className="w-full bg-slate-50 dark:bg-slate-800/60 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-emerald-400 transition-colors" placeholder={t('placeholderEmail')} />
                 </div>
                 <div>
                   <label className="block text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">{t('message')}</label>
                   <textarea rows={4} className="w-full bg-slate-50 dark:bg-slate-800/60 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-emerald-400 resize-none transition-colors" placeholder={t('placeholderMessage')}></textarea>
                 </div>
                 <button type="button" className="w-full bg-[#0f172a] dark:bg-emerald-500 hover:bg-[#1e293b] dark:hover:bg-emerald-400 text-white dark:text-slate-950 py-4 rounded-xl font-bold text-lg transition-all hover:-translate-y-0.5 shadow-lg">
                   {t('submit')}
                 </button>
               </form>
            </div>

          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}

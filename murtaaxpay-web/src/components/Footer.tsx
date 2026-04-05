"use client";

import Image from "next/image";
import { Link } from "@/i18n/routing";
import { SendHorizonal, Apple, Play } from "lucide-react";
import { useTranslations } from "next-intl";

// Social Icons as simple SVG components for compatibility
const FacebookIcon = (props: any) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z" />
  </svg>
);

const TwitterIcon = (props: any) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <path d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6 2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4-.9-4.2 4-6.6 7-3.8 1.1 0 3-1.2 3-1.2z" />
  </svg>
);

const InstagramIcon = (props: any) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <rect x="2" y="2" width="20" height="20" rx="5" ry="5" />
    <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
    <line x1="17.5" y1="6.5" x2="17.51" y2="6.5" />
  </svg>
);

const LinkedinIcon = (props: any) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z" />
    <rect x="2" y="9" width="4" height="12" />
    <circle cx="4" cy="4" r="2" />
  </svg>
);

export default function Footer() {
  const t = useTranslations();

  return (
    <footer className="bg-white dark:bg-[#040D1F] pt-20 pb-10 border-t border-gray-100 dark:border-white/10 transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-12 gap-12 mb-16">
          
          {/* Brand & Socials (4 columns) */}
          <div className="lg:col-span-4">
            <Link href="/" className="inline-block mb-6">
              <Image 
                src="/images/weblogo.png" 
                alt="MurtaaxPay" 
                width={180} 
                height={48} 
                className="h-10 w-auto dark:hidden"
              />
              <Image 
                src="/images/weblogowhite.png" 
                alt="MurtaaxPay" 
                width={180} 
                height={48} 
                className="h-10 w-auto hidden dark:block"
              />
            </Link>
            <p className="text-slate-500 dark:text-slate-400 text-sm leading-relaxed mb-8 max-w-xs">
              {t('Footer.about')}
            </p>
            <div className="flex gap-3">
              {[
                { icon: FacebookIcon, href: "#" },
                { icon: TwitterIcon, href: "#" },
                { icon: InstagramIcon, href: "#" },
                { icon: LinkedinIcon, href: "#" }
              ].map((social, i) => (
                <a key={i} href={social.href} className="w-9 h-9 rounded-xl bg-slate-50 dark:bg-slate-900 border border-gray-100 dark:border-white/5 flex items-center justify-center text-slate-400 hover:text-emerald-500 hover:border-emerald-500/30 transition-all shadow-sm">
                  <social.icon className="w-4 h-4" />
                </a>
              ))}
            </div>
          </div>

          {/* Quick Links (2 columns) */}
          <div className="lg:col-span-2">
            <h4 className="font-bold text-[#0f172a] dark:text-white text-sm mb-6">{t('Footer.services')}</h4>
            <ul className="space-y-3 text-slate-500 dark:text-slate-400 text-sm">
              <li><Link href="/services" className="hover:text-emerald-500 transition-colors">{t('Footer.digitalWallet')}</Link></li>
              <li><Link href="/services" className="hover:text-emerald-500 transition-colors">{t('Footer.virtualCards')}</Link></li>
              <li><Link href="/services" className="hover:text-emerald-500 transition-colors">{t('Footer.moneyTransfer')}</Link></li>
              <li><Link href="/services" className="hover:text-emerald-500 transition-colors">{t('Footer.savings')}</Link></li>
            </ul>
          </div>

          {/* Company (2 columns) */}
          <div className="lg:col-span-2">
            <h4 className="font-bold text-[#0f172a] dark:text-white text-sm mb-6">{t('Footer.company')}</h4>
            <ul className="space-y-3 text-slate-500 dark:text-slate-400 text-sm">
              <li><Link href="/about" className="hover:text-emerald-500 transition-colors">{t('Footer.aboutUs')}</Link></li>
              <li><Link href="/about" className="hover:text-emerald-500 transition-colors">{t('Footer.careers')}</Link></li>
              <li><Link href="/contact" className="hover:text-emerald-500 transition-colors">{t('Navigation.contact')}</Link></li>
              <li><Link href="/about" className="hover:text-emerald-500 transition-colors">{t('Footer.partners')}</Link></li>
            </ul>
          </div>

          {/* Newsletter (4 columns) */}
          <div className="lg:col-span-4">
            <h4 className="font-bold text-[#0f172a] dark:text-white text-sm mb-6">{t('Footer.newsletter')}</h4>
            <p className="text-slate-500 dark:text-slate-400 text-sm mb-4">{t('Footer.newsletterDesc')}</p>
            <div className="flex gap-2 p-1.5 bg-slate-50 dark:bg-slate-900 rounded-xl border border-gray-100 dark:border-white/5">
              <input type="email" placeholder={t('Footer.placeholder')} className="flex-1 bg-transparent px-3 py-1.5 text-xs outline-none dark:text-white" />
              <button className="bg-emerald-500 hover:bg-emerald-600 text-white p-2 rounded-lg transition-colors">
                <SendHorizonal size={16} />
              </button>
            </div>
            
            <div className="mt-8 flex items-center gap-4">
               <a href="#" className="flex items-center gap-2 bg-[#0f172a] dark:bg-slate-800 text-white px-3 py-1.5 rounded-lg border border-white/10 hover:bg-slate-800 transition-colors text-xs font-bold uppercase tracking-widest italic">
                 <Apple size={14} /> {t('Footer.idAppStore')}
               </a>
               <a href="#" className="flex items-center gap-2 bg-[#0f172a] dark:bg-slate-800 text-white px-3 py-1.5 rounded-lg border border-white/10 hover:bg-slate-800 transition-colors text-xs font-bold uppercase tracking-widest italic">
                 <Play size={14} fill="currentColor" /> {t('Footer.idPlayStore')}
               </a>
            </div>
          </div>

        </div>

        <div className="pt-8 border-t border-gray-100 dark:border-white/10 flex flex-col md:flex-row justify-between items-center gap-4 text-xs text-slate-400">
          <p>&copy; {new Date().getFullYear()} {t('Footer.rights')}</p>
          <div className="flex gap-6">
            <Link href="/about" className="hover:text-emerald-500 transition-colors">{t('Footer.privacy')}</Link>
            <Link href="/about" className="hover:text-emerald-500 transition-colors">{t('Footer.terms')}</Link>
            <Link href="/about" className="hover:text-emerald-500 transition-colors">{t('Footer.cookies')}</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}

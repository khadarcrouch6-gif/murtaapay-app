"use client";
// i18n: de.json updated with Navigation.cards + Navigation.prices
import Image from "next/image";
import { toast } from "sonner";
import { useTranslations } from "next-intl";
import { useTheme } from "next-themes";
import { Link, usePathname, useRouter } from "@/i18n/routing";
import { MoonStar, Sun, Languages, Menu, X, ChevronDown, UserCircle } from "lucide-react";
import { useState, useEffect } from "react";
import { useParams } from "next/navigation";

export default function Navbar() {
  const t = useTranslations("Navigation");
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);
  const router = useRouter();
  const pathname = usePathname();
  const params = useParams();

  useEffect(() => setMounted(true), []);

  const changeLanguage = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const nextLocale = e.target.value;
    router.replace(pathname, { locale: nextLocale });
  };

  return (
    <header className="sticky top-0 z-50 w-full bg-white/80 dark:bg-[#040D1F]/80 backdrop-blur-lg border-b border-slate-100 dark:border-white/10 transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-20">
          {/* Logo */}
          <Link href="/" onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })} className="flex-shrink-0 flex items-center gap-2 cursor-pointer transition-transform hover:scale-105">
            <Image 
              src="/images/weblogo.png" 
              alt="MurtaaxPay Logo" 
              width={240} 
              height={64} 
              className="w-auto h-12 md:h-16 dark:hidden"
              priority
            />
            <Image 
              src="/images/weblogowhite.png" 
              alt="MurtaaxPay Logo (Dark Mode)" 
              width={240} 
              height={64} 
              className="w-auto h-12 md:h-16 hidden dark:block"
              priority
            />
          </Link>

          {/* Center Navigation Links */}
          <nav className="hidden md:flex space-x-8">
            <Link href="/" onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })} className="text-slate-900 dark:text-slate-50 font-bold hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors">{t('home')}</Link>
            <Link href="/services" className="text-slate-600 dark:text-slate-300 font-medium hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors">{t('services')}</Link>
            <Link href="/cards" className="text-slate-600 dark:text-slate-300 font-medium hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors">{t('cards')}</Link>
            <Link href="/pricing" className="text-slate-600 dark:text-slate-300 font-medium hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors">{t('prices')}</Link>
            <Link href="/about" className="text-slate-600 dark:text-slate-300 font-medium hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors">{t('about')}</Link>
            <Link href="/contact" className="text-slate-600 dark:text-slate-300 font-medium hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors">{t('contact')}</Link>
          </nav>

          {/* Right Action Buttons */}
          <div className="hidden md:flex items-center space-x-4">
            {/* Language Switcher */}
            <div className="flex items-center gap-1 text-slate-600 dark:text-slate-300 bg-slate-100 dark:bg-white/5 px-3 py-1.5 rounded-full border border-slate-200 dark:border-white/10">
              <select 
                onChange={changeLanguage}
                defaultValue={(params?.locale as string) || "en"}
                className="bg-transparent border-none text-sm font-bold focus:ring-0 cursor-pointer outline-none dark:bg-transparent dark:text-white"
              >
                <option className="dark:bg-[#040D1F]" value="en">🇺🇸 EN</option>
                <option className="dark:bg-[#040D1F]" value="so">🇸🇴 SO</option>
                <option className="dark:bg-[#040D1F]" value="ar">🇸🇦 AR</option>
                <option className="dark:bg-[#040D1F]" value="de">🇩🇪 DE</option>
              </select>
            </div>

            {/* Theme Toggle */}
            <button
              onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
              className="p-2 rounded-full overflow-hidden text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/10 transition-colors border border-slate-200 dark:border-white/10"
              aria-label="Toggle Dark Mode"
            >
              {mounted && (
                theme === "dark" ? <Sun className="w-4 h-4" /> : <MoonStar className="w-4 h-4 text-slate-600" />
              )}
            </button>

            <div className="h-6 w-px bg-slate-200 dark:bg-white/20 mx-1"></div>

            <Link href="/login" className="text-slate-900 dark:text-slate-50 font-bold hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors px-2">
              {t('login')}
            </Link>
            <Link href="/signup" className="bg-[#0f172a] dark:bg-emerald-500 text-white dark:text-slate-950 px-6 py-2.5 rounded-full font-bold hover:bg-[#1e293b] dark:hover:bg-emerald-400 transition-all shadow-md hover:shadow-lg transform hover:-translate-y-0.5">
              {t('signup')}
            </Link>
          </div>

          {/* Mobile menu button */}
          <div className="md:hidden flex items-center pr-2 gap-2">
            <select 
              onChange={changeLanguage}
              defaultValue={(params?.locale as string) || "en"}
              className="bg-transparent text-sm font-bold border-none outline-none dark:text-white"
            >
              <option className="dark:bg-[#040D1F]" value="en">🇺🇸 EN</option>
              <option className="dark:bg-[#040D1F]" value="so">🇸🇴 SO</option>
              <option className="dark:bg-[#040D1F]" value="ar">🇸🇦 AR</option>
              <option className="dark:bg-[#040D1F]" value="de">🇩🇪 DE</option>
            </select>
            <button
              onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
              className="p-2 rounded-full text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-white/10 transition-colors"
            >
              {mounted && (
                theme === "dark" ? <Sun className="w-5 h-5" /> : <MoonStar className="w-5 h-5" />
              )}
            </button>
            <button onClick={() => toast("Mobile menu opened")} className="text-slate-900 dark:text-slate-50 hover:text-emerald-600 dark:hover:text-emerald-400 focus:outline-none transition-colors ml-2">
              <Menu className="h-6 w-6" />
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}

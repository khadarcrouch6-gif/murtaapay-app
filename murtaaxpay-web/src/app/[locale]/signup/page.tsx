"use client";

import { Link } from "@/i18n/routing";
import { ArrowLeft, Mail, Lock, User, Globe, Loader2 } from "lucide-react";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";
import { useTranslations } from "next-intl";

export default function SignupPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const t = useTranslations("Auth");

  const handleSignup = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    toast.loading(t('signingUp'), { id: "signup" });
    
    setTimeout(() => {
      setIsLoading(false);
      toast.success(t('signupSuccess'), { id: "signup" });
      router.push("/dashboard");
    }, 2000);
  };

  return (
    <div className="min-h-screen bg-zinc-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* Background Gradients */}
      <div className="absolute top-0 left-0 w-[500px] h-[500px] bg-emerald-300/20 rounded-full blur-[100px] pointer-events-none mix-blend-multiply" />
      <div className="absolute bottom-0 right-0 w-[400px] h-[400px] bg-blue-300/20 rounded-full blur-[100px] pointer-events-none mix-blend-multiply" />

      <div className="sm:mx-auto sm:w-full sm:max-w-md z-10">
        <Link href="/" className="flex justify-center mb-6 hover:opacity-80 transition-opacity">
          <Image src="/images/weblogo.png" alt="MurtaaxPay" width={200} height={50} className="h-12 w-auto" />
        </Link>
        <h2 className="mt-2 text-center text-3xl font-extrabold text-gray-900 tracking-tight italic uppercase">
          {t('getStarted')}
        </h2>
        <p className="mt-2 text-center text-sm text-gray-600 font-medium italic">
          {t('alreadyHaveAccount')}{" "}
          <Link href="/login" className="font-extrabold text-emerald-600 hover:text-emerald-500 transition-colors uppercase tracking-tighter">
            {t('signInHere')}
          </Link>
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md z-10">
        <div className="bg-white/80 backdrop-blur-xl py-8 px-4 shadow-2xl sm:rounded-[2rem] sm:px-10 border border-white">
          <form className="space-y-5" onSubmit={handleSignup}>
            <div>
              <label className="block text-xs font-black text-gray-700 uppercase tracking-widest italic">{t('fullName')}</label>
              <div className="mt-1 relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <User className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="text"
                  required
                  className="appearance-none block w-full pl-10 px-3 py-3 border border-gray-200 rounded-xl shadow-sm placeholder-gray-400 focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 sm:text-sm bg-white"
                  placeholder="Ali Hasan"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-black text-gray-700 uppercase tracking-widest italic">{t('featureGlobal')}</label>
              <div className="mt-1 relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Globe className="h-5 w-5 text-gray-400" />
                </div>
                <select className="appearance-none block w-full pl-10 px-3 py-3 border border-gray-200 rounded-xl shadow-sm text-gray-700 focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 sm:text-sm bg-white cursor-pointer font-bold italic">
                  <option>Somalia</option>
                  <option>Kenya</option>
                  <option>United Kingdom</option>
                  <option>United States</option>
                  <option>Other</option>
                </select>
              </div>
            </div>

            <div>
              <label className="block text-xs font-black text-gray-700 uppercase tracking-widest italic">{t('emailLabel')}</label>
              <div className="mt-1 relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Mail className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="email"
                  required
                  className="appearance-none block w-full pl-10 px-3 py-3 border border-gray-200 rounded-xl shadow-sm placeholder-gray-400 focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 sm:text-sm bg-white"
                  placeholder="you@example.com"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-black text-gray-700 uppercase tracking-widest italic">{t('passwordLabel')}</label>
              <div className="mt-1 relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="password"
                  required
                  className="appearance-none block w-full pl-10 px-3 py-3 border border-gray-200 rounded-xl shadow-sm placeholder-gray-400 focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 sm:text-sm bg-white"
                  placeholder="••••••••"
                />
              </div>
            </div>

            <div className="pt-2">
              <button
                type="submit"
                disabled={isLoading}
                className="w-full flex justify-center items-center gap-2 py-4 px-4 border border-transparent rounded-full shadow-lg text-sm font-black text-white bg-emerald-500 hover:bg-emerald-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 transition-all hover:-translate-y-0.5 disabled:opacity-80 italic uppercase tracking-widest shadow-emerald-500/20"
              >
                {isLoading ? <Loader2 size={18} className="animate-spin" /> : t('createAccount')}
              </button>
            </div>
          </form>

          <p className="mt-6 text-center text-[10px] text-gray-500 max-w-xs mx-auto font-medium italic">
            {t('agreeTermsPrefix')} <Link href="/about" className="text-emerald-600 font-bold underline">{t('terms')}</Link> {t('and')} <Link href="/about" className="text-emerald-600 font-bold underline">{t('privacy')}.</Link>
          </p>

          <div className="mt-6 border-t border-gray-100 pt-6">
            <Link href="/" className="flex items-center justify-center gap-2 text-[10px] text-gray-500 hover:text-gray-900 font-black italic uppercase tracking-[0.2em] transition-colors">
              <ArrowLeft size={16} /> {t('backHome')}
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

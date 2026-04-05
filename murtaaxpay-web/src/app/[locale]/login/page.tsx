"use client";

import { Link } from "@/i18n/routing";
import { ArrowLeft, Mail, Lock, Loader2 } from "lucide-react";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";
import { useTranslations } from "next-intl";

export default function LoginPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const t = useTranslations("Auth");

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    toast.loading(t('signingIn'), { id: "login" });

    setTimeout(() => {
      setIsLoading(false);
      toast.success(t('loginSuccess'), { id: "login" });
      router.push("/dashboard");
    }, 1500);
  };

  return (
    <div className="min-h-screen bg-zinc-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* Background Gradients */}
      <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-emerald-300/20 rounded-full blur-[100px] pointer-events-none mix-blend-multiply" />
      <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-cyan-300/20 rounded-full blur-[100px] pointer-events-none mix-blend-multiply" />

      <div className="sm:mx-auto sm:w-full sm:max-w-md z-10">
        <Link href="/" className="flex justify-center mb-6 hover:opacity-80 transition-opacity">
          <Image src="/images/weblogo.png" alt="MurtaaxPay" width={200} height={50} className="h-12 w-auto" />
        </Link>
        <h2 className="mt-2 text-center text-3xl font-extrabold text-gray-900 tracking-tight italic uppercase">
          {t('welcomeBack')}
        </h2>
        <p className="mt-2 text-center text-sm text-gray-600 font-medium">
          {t('or')}{" "}
          <Link href="/signup" className="font-bold text-emerald-600 hover:text-emerald-500 transition-colors">
            {t('createAccount')}
          </Link>
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md z-10">
        <div className="bg-white/80 backdrop-blur-xl py-8 px-4 shadow-2xl sm:rounded-[2rem] sm:px-10 border border-white">
          <form className="space-y-6" onSubmit={handleLogin}>
            <div>
              <label htmlFor="email" className="block text-sm font-bold text-gray-700 italic uppercase tracking-wider">
                {t('emailLabel')}
              </label>
              <div className="mt-2 relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Mail className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  className="appearance-none block w-full pl-10 px-3 py-3 border border-gray-200 rounded-xl shadow-sm placeholder-gray-400 focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 sm:text-sm bg-white"
                  placeholder="you@example.com"
                />
              </div>
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-bold text-gray-700 italic uppercase tracking-wider">
                {t('passwordLabel')}
              </label>
              <div className="mt-2 relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="current-password"
                  required
                  className="appearance-none block w-full pl-10 px-3 py-3 border border-gray-200 rounded-xl shadow-sm placeholder-gray-400 focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 sm:text-sm bg-white"
                  placeholder="••••••••"
                />
              </div>
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <input
                  id="remember-me"
                  name="remember-me"
                  type="checkbox"
                  className="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-gray-300 rounded"
                />
                <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-900 font-bold italic uppercase tracking-tighter">
                  {t('rememberMe')}
                </label>
              </div>

              <div className="text-sm">
                <a href="#" className="font-bold text-emerald-600 hover:text-emerald-500 italic uppercase tracking-tighter">
                  {t('forgotPassword')}
                </a>
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={isLoading}
                className="w-full flex justify-center items-center gap-2 py-3.5 px-4 border border-transparent rounded-full shadow-lg text-sm font-black text-white bg-[#0f172a] hover:bg-[#1e293b] focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 transition-all hover:-translate-y-0.5 disabled:opacity-80 italic uppercase tracking-widest"
              >
                {isLoading ? <Loader2 size={18} className="animate-spin" /> : t('signInSecurely')}
              </button>
            </div>
          </form>

          <div className="mt-8">
            <Link href="/" className="flex items-center justify-center gap-2 text-xs text-gray-500 hover:text-gray-900 font-bold italic uppercase tracking-widest transition-colors">
              <ArrowLeft size={16} /> {t('backHome')}
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

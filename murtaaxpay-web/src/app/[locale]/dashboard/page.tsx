"use client";

import { ArrowRight, ArrowUpRight, ArrowDownRight, Plus, RefreshCcw, Wallet } from "lucide-react";
import { Link } from "@/i18n/routing";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";
import { useTranslations } from "next-intl";

export default function DashboardHome() {
  const router = useRouter();
  const [isSyncing, setIsSyncing] = useState(false);
  const t = useTranslations("Dashboard");

  const handleSync = () => {
    setIsSyncing(true);
    toast.loading(t('syncMsg'), { id: 'sync' });
    setTimeout(() => {
      setIsSyncing(false);
      toast.success(t('syncSuccess'), { id: 'sync' });
    }, 1200);
  };

  const recentTransactions = [
    { id: 1, name: "Amazon Web Services", date: "Today, 10:24 AM", amount: "-$45.00", type: "debit", category: t('categories.software') },
    { id: 2, name: "Salary Deposit (Company Ltd)", date: "Yesterday, 04:30 PM", amount: "+$4,850.00", type: "credit", category: t('categories.income') },
    { id: 3, name: "Uber Ride", date: "May 12, 09:15 AM", amount: "-$14.50", type: "debit", category: t('categories.transport') },
    { id: 4, name: "Transfer to Hasan A.", date: "May 10, 08:00 PM", amount: "-$850.00", type: "debit", category: t('categories.transfer') },
  ];

  return (
    <div className="max-w-6xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      {/* Welcome Banner */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a] uppercase italic tracking-tighter">{t('overview')}</h1>
          <p className="text-slate-500 mt-1 font-medium">{t('overviewDesc')}</p>
        </div>
        <div className="hidden sm:flex items-center gap-3">
          <button 
            onClick={handleSync}
            disabled={isSyncing}
            className="bg-white border border-gray-200 text-slate-700 px-4 py-2 rounded-lg text-xs font-bold uppercase tracking-widest hover:bg-slate-50 transition-all flex items-center gap-2 shadow-sm disabled:opacity-70"
          >
            <RefreshCcw size={16} className={isSyncing ? "animate-spin" : ""} /> {isSyncing ? t('syncing') : t('sync')}
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Main Balance Card */}
        <div className="lg:col-span-2 bg-[#0f172a] rounded-[2rem] p-8 text-white relative overflow-hidden shadow-2xl">
          <div className="absolute top-0 right-0 w-64 h-64 bg-emerald-500/20 rounded-full blur-[80px] pointer-events-none" />
          
          <div className="relative z-10">
            <p className="text-slate-400 font-bold uppercase tracking-[0.2em] text-[10px] mb-1 flex items-center gap-2">
              <Wallet size={16} /> {t('totalBalance')}
            </p>
            <h2 className="text-5xl font-black mb-8 tracking-tight italic">$13,450.00</h2>
            
            <div className="flex flex-wrap gap-4">
              <Link href="/dashboard/wallet" className="bg-emerald-500 hover:bg-emerald-400 text-[#0f172a] px-6 py-3 rounded-xl font-black transition-all shadow-lg shadow-emerald-500/20 flex items-center gap-2 uppercase tracking-widest text-xs">
                <Plus size={20} /> {t('addMoney')}
              </Link>
              <Link href="/dashboard/transfers" className="bg-white/10 hover:bg-white/20 text-white px-6 py-3 rounded-xl font-black transition-all flex items-center gap-2 backdrop-blur-sm uppercase tracking-widest text-xs">
                {t('sendMoney')} <ArrowRight size={20} />
              </Link>
            </div>
          </div>
        </div>

        {/* Mini Cards Grid */}
        <div className="flex flex-col gap-6">
          <div className="bg-white border border-gray-100 rounded-[1.5rem] p-6 shadow-sm flex-1 flex flex-col justify-center">
            <p className="text-[10px] text-slate-500 font-black uppercase tracking-widest mb-2">{t('monthlyIncome')}</p>
            <div className="flex items-end justify-between">
              <h3 className="text-2xl font-black text-[#0f172a] italic">$4,850.00</h3>
              <div className="flex items-center gap-1 text-emerald-500 text-xs font-bold bg-emerald-50 px-2 py-1 rounded-md">
                <ArrowUpRight size={16} /> 12%
              </div>
            </div>
          </div>
          
          <div className="bg-white border border-gray-100 rounded-[1.5rem] p-6 shadow-sm flex-1 flex flex-col justify-center">
            <p className="text-[10px] text-slate-500 font-black uppercase tracking-widest mb-2">{t('monthlySpending')}</p>
            <div className="flex items-end justify-between">
              <h3 className="text-2xl font-black text-[#0f172a] italic">$1,240.50</h3>
              <div className="flex items-center gap-1 text-red-500 text-xs font-bold bg-red-50 px-2 py-1 rounded-md">
                <ArrowDownRight size={16} /> 4.2%
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Activity List */}
      <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm">
        <div className="flex items-center justify-between mb-8 pb-4 border-b border-gray-100">
          <h3 className="text-lg font-black text-[#0f172a] uppercase tracking-tighter italic">{t('recentActivity')}</h3>
          <Link href="/dashboard/history" className="text-emerald-600 font-black hover:underline text-xs uppercase tracking-widest">{t('viewAll')}</Link>
        </div>

        <div className="space-y-6">
          {recentTransactions.map((tx) => (
            <div 
              key={tx.id} 
              onClick={() => toast(`Showing details for ${tx.name}`)}
              className="flex items-center justify-between group cursor-pointer hover:bg-slate-50 p-2 -m-2 rounded-xl transition-colors"
            >
              <div className="flex items-center gap-4">
                <div className={`w-12 h-12 rounded-full flex items-center justify-center ${tx.type === 'credit' ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-100 text-slate-600'}`}>
                  {tx.type === 'credit' ? <ArrowDownRight size={20} /> : <ArrowUpRight size={20} />}
                </div>
                <div>
                  <p className="font-bold text-[#0f172a] mb-0.5">{tx.name}</p>
                  <div className="flex items-center gap-2 text-[10px] text-slate-500 font-bold uppercase tracking-wider">
                    <span>{tx.date}</span>
                    <span className="w-1 h-1 bg-gray-300 rounded-full"></span>
                    <span>{tx.category}</span>
                  </div>
                </div>
              </div>
              <div className={`font-black italic ${tx.type === 'credit' ? 'text-emerald-600' : 'text-[#0f172a]'}`}>
                {tx.amount}
              </div>
            </div>
          ))}
        </div>
      </div>

    </div>
  );
}

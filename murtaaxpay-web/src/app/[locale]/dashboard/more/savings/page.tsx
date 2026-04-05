"use client";

import { ArrowLeft, Target, PlusCircle, ArrowUpRight, CheckCircle2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

export default function SavingsPage() {
  const router = useRouter();

  const goals = [
    { title: "Hajj Fund", icon: "🕋", saved: 1200, target: 5000, color: "text-emerald-500", bg: "bg-emerald-100", progressColor: "bg-emerald-500" },
    { title: "New Car", icon: "🚘", saved: 4500, target: 15000, color: "text-indigo-500", bg: "bg-indigo-100", progressColor: "bg-indigo-500" },
    { title: "Emergency", icon: "🛡️", saved: 850, target: 2000, color: "text-rose-500", bg: "bg-rose-100", progressColor: "bg-rose-500" },
  ];

  return (
    <div className="max-w-4xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex items-center gap-4 mb-8">
        <button onClick={() => router.back()} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
          <ArrowLeft size={24} className="text-slate-700" />
        </button>
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Savings & Goals</h1>
          <p className="text-slate-500 mt-1">Track and manage your financial savings targets.</p>
        </div>
      </div>

      {/* Total Savings Hero */}
      <div className="bg-gradient-to-r from-emerald-600 to-teal-500 rounded-[2rem] p-8 sm:p-10 text-white shadow-xl shadow-emerald-500/20 mb-10 relative overflow-hidden">
        <div className="absolute top-0 right-0 p-10 opacity-10">
          <Target size={160} />
        </div>
        <div className="relative z-10">
           <div className="flex justify-between items-start mb-4">
             <span className="text-emerald-50 font-medium">Total Savings</span>
             <span className="bg-white/20 px-3 py-1 rounded-full text-xs font-bold">+2.5% Yield</span>
           </div>
           <h2 className="text-4xl sm:text-5xl font-black mb-8 tracking-tight">$6,550.00</h2>
           
           <div className="flex gap-4">
             <button onClick={() => toast("Deposit modal opened")} className="bg-white text-emerald-700 px-6 py-3 rounded-xl font-bold hover:bg-emerald-50 transition-colors shadow-sm flex-1 sm:flex-none justify-center flex items-center gap-2">
               Deposit
             </button>
             <button onClick={() => toast("Withdraw modal opened")} className="bg-white/10 hover:bg-white/20 text-white px-6 py-3 rounded-xl font-bold transition-colors border border-white/20 flex-1 sm:flex-none justify-center flex items-center gap-2">
               Withdraw
             </button>
           </div>
        </div>
      </div>

      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-bold text-[#0f172a]">Active Goals</h2>
        <button className="text-emerald-600 font-bold hover:underline py-2">See All</button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
        {goals.map((goal, idx) => {
          const progress = (goal.saved / goal.target) * 100;
          return (
            <div key={idx} className="bg-white border border-gray-100 rounded-3xl p-6 shadow-sm hover:shadow-md transition-shadow cursor-pointer">
              <div className="flex justify-between items-start mb-6">
                <div className="flex items-center gap-4">
                  <div className={`w-14 h-14 rounded-2xl flex items-center justify-center text-2xl ${goal.bg}`}>
                    {goal.icon}
                  </div>
                  <div>
                    <h3 className="font-bold text-[#0f172a] text-lg">{goal.title}</h3>
                    <p className="text-sm text-slate-500 font-medium">Goal: ${goal.target.toLocaleString()}</p>
                  </div>
                </div>
                {progress >= 100 && <CheckCircle2 className="text-emerald-500" />}
              </div>
              
              <div className="mb-2 flex justify-between items-end">
                <span className="font-black text-2xl text-[#0f172a]">${goal.saved.toLocaleString()}</span>
                <span className={`font-bold ${goal.color}`}>{progress.toFixed(0)}%</span>
              </div>
              
              <div className="w-full bg-slate-100 rounded-full h-2.5 overflow-hidden">
                <div className={`h-2.5 rounded-full ${goal.progressColor}`} style={{ width: `${Math.min(progress, 100)}%` }}></div>
              </div>
            </div>
          )
        })}
        
        {/* Add New Goal Card */}
        <div 
          onClick={() => toast("Create Goal form opened")}
          className="bg-slate-50 border-2 border-dashed border-gray-200 rounded-3xl p-6 flex flex-col items-center justify-center gap-4 cursor-pointer hover:bg-emerald-50 hover:border-emerald-200 transition-colors group h-full min-h-[160px]"
        >
          <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-sm text-slate-400 group-hover:text-emerald-500 group-hover:bg-emerald-100 transition-colors">
            <PlusCircle size={24} />
          </div>
          <span className="font-bold text-slate-500 group-hover:text-emerald-600">Create New Goal</span>
        </div>
      </div>
    </div>
  );
}

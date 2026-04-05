"use client";

import { ArrowLeft, Share2, Copy, Users, DollarSign, Wallet } from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

export default function ReferPage() {
  const router = useRouter();

  const handleCopy = () => {
    toast.success("Referral link copied to clipboard!");
  };

  return (
    <div className="max-w-3xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex items-center gap-4 mb-8">
        <button onClick={() => router.back()} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
          <ArrowLeft size={24} className="text-slate-700" />
        </button>
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Refer & Earn</h1>
          <p className="text-slate-500 mt-1">Invite friends and earn a $10 bonus for every signup.</p>
        </div>
      </div>

      <div className="bg-white border border-gray-100 rounded-[2rem] overflow-hidden shadow-sm mb-8">
        <div className="bg-gradient-to-r from-indigo-600 to-purple-600 p-8 sm:p-12 text-center text-white relative">
          <div className="absolute top-0 right-0 p-8 opacity-20">
            <Users size={120} />
          </div>
          <div className="relative z-10 max-w-lg mx-auto">
            <h2 className="text-3xl sm:text-4xl font-black mb-4 tracking-tight">Give $5, Get $10</h2>
            <p className="text-indigo-100 text-lg mb-8 leading-relaxed">
              When your friend signs up with your link and makes their first transfer of $50 or more, you both get a reward!
            </p>
            
            <div className="bg-white/10 backdrop-blur-md border border-white/20 p-4 rounded-2xl flex items-center justify-between gap-4">
              <span className="text-white font-mono font-bold text-sm sm:text-base truncate pl-2">
                pay.murtaax.com/join/alihsn
              </span>
              <button onClick={handleCopy} className="bg-white text-indigo-600 px-6 py-3 rounded-xl font-bold hover:bg-indigo-50 transition-colors flex items-center gap-2 shrink-0 shadow-sm">
                <Copy size={18} /> Copy
              </button>
            </div>
          </div>
        </div>
        
        <div className="p-8 sm:p-12 text-center sm:text-left">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-8 divide-y sm:divide-y-0 sm:divide-x divide-gray-100">
            <div className="flex flex-col items-center sm:items-start pt-4 sm:pt-0">
              <div className="w-12 h-12 bg-indigo-50 text-indigo-600 rounded-full flex items-center justify-center mb-4">
                <Users size={24} />
              </div>
              <p className="text-slate-500 font-bold uppercase tracking-wider text-xs mb-1">Friends Invited</p>
              <p className="text-4xl font-black text-[#0f172a]">12</p>
            </div>
            <div className="flex flex-col items-center sm:items-start pt-8 sm:pt-0 sm:pl-8">
              <div className="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-full flex items-center justify-center mb-4">
                <DollarSign size={24} />
              </div>
              <p className="text-slate-500 font-bold uppercase tracking-wider text-xs mb-1">Total Earned</p>
              <p className="text-4xl font-black text-emerald-600">$120.00</p>
              <button onClick={() => toast("Transferring balance to Wallet")} className="mt-4 text-emerald-600 font-bold text-sm hover:underline flex items-center justify-center sm:justify-start gap-1">
                <Wallet size={16} /> Transfer to Wallet
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <h3 className="text-lg font-bold text-[#0f172a] mb-4">How it works</h3>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {[
          { step: 1, title: "Share link", desc: "Send your unique link to family or friends." },
          { step: 2, title: "They sign up", desc: "Your friend creates a verified MurtaaxPay account." },
          { step: 3, title: "You both earn", desc: "Earn rewards instantly after their first transaction." },
        ].map(item => (
          <div key={item.step} className="bg-slate-50 rounded-2xl p-6 text-center border border-gray-100">
            <div className="w-10 h-10 bg-[#0f172a] text-white rounded-full flex items-center justify-center mx-auto mb-4 font-black">
              {item.step}
            </div>
            <h4 className="font-bold text-[#0f172a] mb-2">{item.title}</h4>
            <p className="text-sm text-slate-500">{item.desc}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

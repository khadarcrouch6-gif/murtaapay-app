"use client";

import { ArrowLeft, Ticket, Search, Copy, CheckCircle2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

export default function VouchersPage() {
  const router = useRouter();
  const [copied, setCopied] = useState("");

  const vouchers = [
    { code: "WELCOME50", title: "50% Off Transfer Fees", desc: "Valid for your first 3 international transfers.", exp: "Ends in 2 days", active: true },
    { code: "CASHBACK10", title: "$10 Cashback Bonus", desc: "Spend $100 using your Virtual Card to redeem.", exp: "Valid until Dec 2026", active: true },
    { code: "FREEBILL", title: "Zero Bill Payment Fees", desc: "Automatically blocks service fees for your next utility bill.", exp: "Used", active: false },
  ];

  const handleCopy = (code: string) => {
    setCopied(code);
    toast.success(`Coupon ${code} copied!`);
    setTimeout(() => setCopied(""), 2000);
  };

  return (
    <div className="max-w-4xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div className="flex items-center gap-4">
          <button onClick={() => router.back()} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
            <ArrowLeft size={24} className="text-slate-700" />
          </button>
          <div>
            <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">My Vouchers</h1>
            <p className="text-slate-500 mt-1">Manage and redeem your promo codes.</p>
          </div>
        </div>
        
        <button onClick={() => toast("Input field to add voucher code")} className="bg-[#0f172a] hover:bg-[#1e293b] text-white px-5 py-2.5 rounded-full font-bold transition-colors shadow-sm hidden sm:block">
          + Add Voucher Code
        </button>
      </div>

      <div className="space-y-4">
        {vouchers.map((v, idx) => (
          <div key={idx} className={`bg-white border ${v.active ? 'border-gray-200' : 'border-gray-100 opacity-60'} rounded-[1.5rem] p-6 flex flex-col sm:flex-row justify-between items-center sm:items-start gap-6 shadow-sm overflow-hidden relative`}>
             <div className="absolute left-0 top-0 bottom-0 w-2 bg-yellow-400"></div>
             
             <div className="flex items-center gap-4 pl-4 self-start sm:self-auto">
               <div className={`w-14 h-14 rounded-full flex items-center justify-center shrink-0 ${v.active ? 'bg-yellow-100 text-yellow-600' : 'bg-slate-100 text-slate-400'}`}>
                 <Ticket size={24} />
               </div>
               <div>
                 <div className="flex items-center gap-2 mb-1">
                   <h3 className="font-bold text-[#0f172a] text-lg">{v.title}</h3>
                   {!v.active && <span className="bg-slate-100 text-slate-500 text-[10px] font-bold px-2 py-0.5 rounded-sm uppercase tracking-wider">Used</span>}
                 </div>
                 <p className="text-sm text-slate-500 mb-2 leading-relaxed">{v.desc}</p>
                 <span className={`text-xs font-bold ${v.active ? 'text-red-500' : 'text-slate-400'}`}>{v.exp}</span>
               </div>
             </div>
             
             <div className="w-full sm:w-auto">
               <div className="bg-slate-50 border border-slate-200/60 rounded-xl p-1 flex items-center justify-between sm:justify-start gap-2">
                 <span className="font-mono font-bold text-slate-700 px-3 tracking-widest">{v.code}</span>
                 <button 
                   disabled={!v.active}
                   onClick={() => handleCopy(v.code)}
                   className={`p-2.5 rounded-lg flex items-center justify-center transition-colors ${copied === v.code ? 'bg-emerald-500 text-white' : v.active ? 'bg-white border border-gray-200 text-slate-700 hover:bg-slate-100' : 'bg-transparent text-slate-300'}`}
                 >
                   {copied === v.code ? <CheckCircle2 size={16} /> : <Copy size={16} />}
                 </button>
               </div>
             </div>
          </div>
        ))}
      </div>
    </div>
  );
}

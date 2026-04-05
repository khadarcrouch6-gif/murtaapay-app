"use client";

import { ArrowLeft, TrendingUp, Briefcase } from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

export default function InvestmentsPage() {
  const router = useRouter();

  const opps = [
    { name: "Mogadishu Real Estate Fund", type: "Murasi", return: "12% p.a.", risk: "Moderate", min: "$500" },
    { name: "SME Tech Venture 2026", type: "Equity", return: "18% p.a.", risk: "High", min: "$1,000" },
    { name: "Halal Sukuk Bonds (Somalia)", type: "Fixed", return: "6% p.a.", risk: "Low", min: "$100" },
  ];

  return (
    <div className="max-w-4xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex items-center gap-4 mb-8">
        <button onClick={() => router.back()} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
          <ArrowLeft size={24} className="text-slate-700" />
        </button>
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Investments Dashboard</h1>
          <p className="text-slate-500 mt-1">Grow your wealth with Sharia-compliant opportunities.</p>
        </div>
      </div>

      <div className="bg-[#0f172a] rounded-[2rem] p-8 sm:p-10 text-white mb-10 shadow-2xl overflow-hidden relative">
        <div className="absolute top-0 right-0 w-64 h-64 bg-purple-500/20 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2"></div>
        <div className="relative z-10">
          <p className="text-slate-400 font-medium mb-2">My Portfolio Value</p>
          <div className="flex items-center gap-4 mb-6">
            <h2 className="text-4xl sm:text-5xl font-black tracking-tight">$0.00</h2>
            <div className="bg-emerald-500/20 text-emerald-400 px-3 py-1 rounded-full text-sm font-bold flex items-center gap-1 border border-emerald-500/30">
              <TrendingUp size={14} /> +0.0%
            </div>
          </div>
          <p className="text-slate-400 text-sm max-w-sm mb-8 leading-relaxed">
            You currently have no active investments. Explore the opportunities below to start earning Halal returns.
          </p>
          <button className="bg-purple-600 hover:bg-purple-500 text-white px-8 py-3 rounded-xl font-bold transition-colors flex items-center gap-2">
            <Briefcase size={18} /> Take Risk Assessment
          </button>
        </div>
      </div>

      <h2 className="text-xl font-bold text-[#0f172a] mb-6">Curated Opportunities</h2>
      
      <div className="space-y-4">
        {opps.map((opp, idx) => (
          <div key={idx} className="bg-white border border-gray-100 rounded-3xl p-6 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-6 hover:shadow-md transition-shadow">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <span className="bg-slate-100 text-slate-600 px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider">{opp.type}</span>
                <span className={`px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider ${opp.risk === 'Low' ? 'bg-emerald-100 text-emerald-700' : opp.risk === 'Moderate' ? 'bg-amber-100 text-amber-700' : 'bg-red-100 text-red-700'}`}>
                  {opp.risk} Risk
                </span>
              </div>
              <h3 className="text-lg font-bold text-[#0f172a] mb-1">{opp.name}</h3>
              <p className="text-slate-500 text-sm">Min. Investment: {opp.min}</p>
            </div>
            
            <div className="flex items-center gap-6 justify-between md:justify-end border-t border-gray-100 md:border-none pt-4 md:pt-0">
              <div className="text-left md:text-right">
                <p className="text-xs text-slate-500 uppercase font-bold tracking-wider mb-1">Expected Return</p>
                <p className="text-xl font-black text-emerald-600">{opp.return}</p>
              </div>
              <button onClick={() => toast("Prospectus opened")} className="bg-[#0f172a] text-white px-6 py-3 rounded-xl font-bold hover:bg-[#1e293b] transition-colors whitespace-nowrap">
                Invest Now
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

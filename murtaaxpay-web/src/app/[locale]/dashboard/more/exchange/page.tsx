"use client";

import { ArrowLeft, RefreshCcw, ArrowDownUp, TrendingUp, TrendingDown } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

export default function ExchangeRatesPage() {
  const router = useRouter();
  const [amount, setAmount] = useState("100");
  const [fromCurr, setFromCurr] = useState("USD");
  const [toCurr, setToCurr] = useState("SOS");

  const rates: Record<string, number> = {
    "USD_SOS": 571.50,
    "SOS_USD": 0.0017,
    "USD_EUR": 0.92,
    "EUR_USD": 1.09,
  };

  const getRate = () => {
    return rates[`${fromCurr}_${toCurr}`] || 1;
  };

  const calculate = () => {
    return (parseFloat(amount || "0") * getRate()).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  };

  const handleSwap = () => {
    setFromCurr(toCurr);
    setToCurr(fromCurr);
  };

  return (
    <div className="max-w-4xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex items-center gap-4 mb-8">
        <button onClick={() => router.back()} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
          <ArrowLeft size={24} className="text-slate-700" />
        </button>
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Exchange Rates</h1>
          <p className="text-slate-500 mt-1">Live mid-market rates for fast conversions.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Converter Tool */}
        <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm h-fit">
          <h2 className="text-xl font-bold text-[#0f172a] mb-6">Currency Converter</h2>
          
          <div className="space-y-6">
            <div className="bg-slate-50 border border-gray-200 rounded-2xl p-4 flex items-center justify-between">
              <div>
                <p className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">You Send</p>
                <input 
                  type="number" 
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  className="bg-transparent text-2xl font-black text-[#0f172a] focus:outline-none w-32" 
                />
              </div>
              <select 
                value={fromCurr}
                onChange={(e) => setFromCurr(e.target.value)}
                className="bg-white border border-gray-200 rounded-xl px-4 py-2 font-bold focus:outline-none focus:ring-2 focus:ring-amber-500"
              >
                <option value="USD">🇺🇸 USD</option>
                <option value="SOS">🇸🇴 SOS</option>
                <option value="EUR">🇪🇺 EUR</option>
              </select>
            </div>

            <div className="relative flex justify-center -my-3 z-10">
              <button onClick={handleSwap} className="bg-amber-100 hover:bg-amber-200 text-amber-600 p-2 rounded-full border-4 border-white transition-colors">
                <ArrowDownUp size={20} />
              </button>
            </div>

            <div className="bg-amber-50 border border-amber-100/50 rounded-2xl p-4 flex items-center justify-between">
              <div>
                <p className="text-xs font-bold text-amber-700/60 uppercase tracking-wider mb-2">Recipient Gets</p>
                <p className="text-2xl font-black text-amber-600">{calculate()}</p>
              </div>
              <select 
                value={toCurr}
                onChange={(e) => setToCurr(e.target.value)}
                className="bg-white border border-gray-200 rounded-xl px-4 py-2 font-bold focus:outline-none focus:ring-2 focus:ring-amber-500"
              >
                <option value="USD">🇺🇸 USD</option>
                <option value="SOS">🇸🇴 SOS</option>
                <option value="EUR">🇪🇺 EUR</option>
              </select>
            </div>
            
            <div className="pt-4 flex justify-between items-center text-sm font-medium">
              <span className="text-slate-500">Indicative Exchange Rate</span>
              <span className="text-[#0f172a] font-bold tracking-tight">1 {fromCurr} = {getRate().toFixed(4)} {toCurr}</span>
            </div>

            <button 
              onClick={() => toast.success("Conversion locked. Redirecting to transfer...")}
              className="w-full mt-4 bg-[#0f172a] hover:bg-[#1e293b] text-white py-4 rounded-xl font-bold transition-transform hover:-translate-y-0.5"
            >
              Continue to Transfer
            </button>
          </div>
        </div>

        {/* Live Rates Table */}
        <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm">
           <div className="flex justify-between items-center mb-6">
             <h2 className="text-xl font-bold text-[#0f172a]">Live Market Rates</h2>
             <span className="flex items-center gap-1.5 text-xs font-bold text-emerald-600 bg-emerald-50 px-3 py-1.5 rounded-full">
               <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span> Live
             </span>
           </div>
           
           <div className="space-y-4">
             {[
               { pair: "USD / SOS", rate: "571.50", change: "+0.15%", up: true },
               { pair: "EUR / USD", rate: "1.0924", change: "-0.04%", up: false },
               { pair: "GBP / USD", rate: "1.2640", change: "+0.22%", up: true },
               { pair: "AED / SOS", rate: "155.60", change: "0.00%", up: null },
               { pair: "KES / SOS", rate: "4.35", change: "-1.12%", up: false },
             ].map((item, idx) => (
               <div key={idx} className="flex items-center justify-between p-4 bg-slate-50 rounded-xl">
                 <div className="flex items-center gap-3">
                   <div className="w-10 h-10 rounded-full bg-white shadow-sm flex items-center justify-center font-bold text-slate-700 text-xs text-center leading-tight">
                     {item.pair.split(' / ')[0]}<br/>{item.pair.split(' / ')[1]}
                   </div>
                   <span className="font-bold text-[#0f172a]">{item.pair}</span>
                 </div>
                 <div className="text-right">
                   <p className="font-bold text-[#0f172a]">{item.rate}</p>
                   <p className={`text-xs font-bold flex items-center justify-end gap-1 ${item.up === true ? 'text-emerald-500' : item.up === false ? 'text-red-500' : 'text-slate-400'}`}>
                     {item.up === true && <TrendingUp size={12} />}
                     {item.up === false && <TrendingDown size={12} />}
                     {item.change}
                   </p>
                 </div>
               </div>
             ))}
           </div>
        </div>
      </div>
    </div>
  );
}

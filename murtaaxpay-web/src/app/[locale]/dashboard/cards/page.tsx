"use client";

import { CreditCard, Settings, Eye, EyeOff, Snowflake, Copy, RefreshCw } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import Image from "next/image";

export default function VirtualCardsPage() {
  const [showNumbers, setShowNumbers] = useState(false);
  const [isFrozen, setIsFrozen] = useState(false);

  // Settings Toggles
  const [toggles, setToggles] = useState({
    online: true,
    international: true,
    atm: false
  });

  const handleCopy = () => {
    toast.success("Card number copied to clipboard!", { id: "copy" });
  };

  const toggleFreeze = () => {
    setIsFrozen(!isFrozen);
    toast(isFrozen ? "Card unfrozen successfully." : "Card has been frozen.", {
      icon: isFrozen ? '🔥' : '❄️',
      style: { backgroundColor: isFrozen ? '' : '#eff6ff', color: isFrozen ? '' : '#2563eb' }
    });
  };

  return (
    <div className="max-w-5xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      <div className="mb-8 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Virtual Cards</h1>
          <p className="text-slate-500 mt-1">Manage your active cards and limits.</p>
        </div>
        <button onClick={() => toast.loading('Generating your new secure virtual card...', { duration: 2000 })} className="bg-[#0f172a] hover:bg-[#1e293b] text-white px-6 py-2.5 rounded-full font-bold transition-all shadow-md flex items-center justify-center gap-2">
          <CreditCard size={18} /> Create New Card
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-10">
        
        {/* Card Display Col */}
        <div className="space-y-6">
          {/* Mock Virtual Card CSS */}
          <div className={`relative h-64 w-full rounded-2xl p-8 overflow-hidden transition-all duration-500 shadow-2xl ${isFrozen ? 'bg-slate-400 grayscale' : 'bg-gradient-to-br from-[#0f172a] to-emerald-900'}`}>
            {/* Glossy Overlay */}
            <div className="absolute inset-0 bg-gradient-to-b from-white/20 to-transparent opacity-50 pointer-events-none" />
            <div className={`absolute -right-20 -top-20 w-64 h-64 bg-emerald-500/30 rounded-full blur-[60px] pointer-events-none transition-opacity ${isFrozen ? 'opacity-0' : 'opacity-100'}`} />
            
            <div className="relative z-10 h-full flex flex-col justify-between">
              <div className="flex justify-between items-start">
                <div>
                   <span className="text-white/80 font-bold tracking-widest text-sm mb-1 block">Virtual</span>
                   <Image src="/images/weblogo.png" alt="Logo" width={100} height={24} className="h-6 w-auto brightness-0 invert opacity-90" />
                </div>
                {/* Simulated Visa Logo text */}
                <div className="text-white font-black italic text-2xl tracking-tighter mix-blend-overlay">VISA</div>
              </div>
              
              <div>
                <div className="text-white font-mono text-xl sm:text-2xl tracking-[0.2em] mb-4 flex items-center justify-between">
                  <span>{showNumbers ? "4532  8192  3042  1942" : "••••  ••••  ••••  1942"}</span>
                </div>
                <div className="flex justify-between items-end">
                  <div>
                    <span className="text-white/60 text-xs uppercase tracking-wider block mb-1">Card Holder</span>
                    <span className="text-white font-semibold uppercase tracking-widest">Ali Hasan</span>
                  </div>
                  <div>
                    <span className="text-white/60 text-xs uppercase tracking-wider block mb-1">Valid Thru</span>
                    <span className="text-white font-semibold font-mono">{showNumbers ? "12/28" : "••/••"}</span>
                  </div>
                  <div>
                    <span className="text-white/60 text-xs uppercase tracking-wider block mb-1">CVV</span>
                    <span className="text-white font-semibold font-mono">{showNumbers ? "892" : "•••"}</span>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Frozen Overlay */}
            {isFrozen && (
              <div className="absolute inset-0 bg-white/30 backdrop-blur-[2px] z-20 flex items-center justify-center">
                <div className="bg-slate-900/80 text-white px-6 py-2 rounded-full font-bold flex items-center gap-2 backdrop-blur-md">
                  <Snowflake size={18} /> Card Frozen
                </div>
              </div>
            )}
          </div>

          {/* Quick Actions */}
          <div className="bg-white rounded-[2rem] p-4 shadow-sm border border-gray-100 flex justify-between px-6">
            <button onClick={() => setShowNumbers(!showNumbers)} className="flex flex-col items-center gap-2 p-2 text-slate-600 hover:text-[#0f172a] transition-colors">
              <div className="w-12 h-12 bg-slate-50 rounded-full flex items-center justify-center"><Eye size={20} /></div>
              <span className="text-xs font-bold">{showNumbers ? "Hide" : "Show"} details</span>
            </button>
            <button onClick={handleCopy} className="flex flex-col items-center gap-2 p-2 text-slate-600 hover:text-[#0f172a] transition-colors">
              <div className="w-12 h-12 bg-slate-50 rounded-full flex items-center justify-center"><Copy size={20} /></div>
              <span className="text-xs font-bold">Copy number</span>
            </button>
            <button onClick={toggleFreeze} className="flex flex-col items-center gap-2 p-2 text-slate-600 hover:text-blue-600 transition-colors">
              <div className={`w-12 h-12 rounded-full flex items-center justify-center ${isFrozen ? 'bg-blue-100 text-blue-600' : 'bg-slate-50'}`}><Snowflake size={20} /></div>
              <span className="text-xs font-bold">{isFrozen ? "Unfreeze" : "Freeze"} card</span>
            </button>
            <button onClick={() => toast("Card settings menu opened.")} className="flex flex-col items-center gap-2 p-2 text-slate-600 hover:text-[#0f172a] transition-colors">
              <div className="w-12 h-12 bg-slate-50 rounded-full flex items-center justify-center"><Settings size={20} /></div>
              <span className="text-xs font-bold">Settings</span>
            </button>
          </div>
        </div>

        {/* Card Details & Settings Col */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm">
            <h3 className="font-bold text-[#0f172a] mb-6 flex items-center gap-2"><RefreshCw size={20} /> Billing & Limits</h3>
            
            <div className="space-y-6">
              <div>
                <div className="flex justify-between text-sm mb-2">
                  <span className="text-slate-500 font-medium">Monthly Spending Limit</span>
                  <span className="font-bold text-[#0f172a]">$1,240 / $5,000</span>
                </div>
                <div className="w-full bg-gray-100 rounded-full h-2.5">
                  <div className="bg-emerald-500 h-2.5 rounded-full" style={{ width: '25%' }}></div>
                </div>
              </div>

              <div className="pt-6 border-t border-gray-100 flex items-center justify-between">
                <div>
                  <p className="font-bold text-[#0f172a]">Online Payments</p>
                  <p className="text-sm text-slate-500">Allow transactions online</p>
                </div>
                {/* Toggle Switch */}
                <div 
                  onClick={() => setToggles({...toggles, online: !toggles.online})}
                  className={`w-14 h-8 rounded-full relative cursor-pointer transition-colors shadow-inner ${toggles.online ? 'bg-emerald-500' : 'bg-slate-200'}`}
                >
                  <div className={`w-6 h-6 bg-white rounded-full absolute top-1 shadow-sm transition-transform ${toggles.online ? 'right-1' : 'left-1'}`}></div>
                </div>
              </div>

              <div className="pt-4 flex items-center justify-between">
                <div>
                  <p className="font-bold text-[#0f172a]">International Use</p>
                  <p className="text-sm text-slate-500">Allow payments abroad</p>
                </div>
                {/* Toggle Switch */}
                <div 
                  onClick={() => setToggles({...toggles, international: !toggles.international})}
                  className={`w-14 h-8 rounded-full relative cursor-pointer transition-colors shadow-inner ${toggles.international ? 'bg-emerald-500' : 'bg-slate-200'}`}
                >
                  <div className={`w-6 h-6 bg-white rounded-full absolute top-1 shadow-sm transition-transform ${toggles.international ? 'right-1' : 'left-1'}`}></div>
                </div>
              </div>

              <div className="pt-4 flex items-center justify-between">
                <div>
                  <p className="font-bold text-[#0f172a]">ATM Withdrawals</p>
                  <p className="text-sm text-slate-500">Allow cash withdrawals</p>
                </div>
                {/* Toggle Switch Off */}
                <div 
                  onClick={() => setToggles({...toggles, atm: !toggles.atm})}
                  className={`w-14 h-8 rounded-full relative cursor-pointer transition-colors shadow-inner ${toggles.atm ? 'bg-emerald-500' : 'bg-slate-200'}`}
                >
                  <div className={`w-6 h-6 bg-white rounded-full absolute top-1 shadow-sm transition-transform ${toggles.atm ? 'right-1' : 'left-1'}`}></div>
                </div>
              </div>
            </div>
            
          </div>
        </div>

      </div>
    </div>
  );
}

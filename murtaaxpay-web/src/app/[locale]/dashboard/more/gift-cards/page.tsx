"use client";

import { ArrowLeft, Search, Star, Gift, Smartphone } from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

export default function GiftCardsPage() {
  const router = useRouter();

  const cards = [
    { name: "Netflix", brandInfo: "Entertainment", color: "from-red-600 to-red-900", logo: "N" },
    { name: "iTunes & App Store", brandInfo: "Apple", color: "from-blue-500 to-indigo-600", logo: "" },
    { name: "Amazon", brandInfo: "Shopping", color: "from-amber-400 to-orange-500", logo: "a" },
    { name: "PlayStation Store", brandInfo: "Gaming", color: "from-blue-700 to-blue-900", logo: "PS" },
    { name: "Spotify Premium", brandInfo: "Music", color: "from-green-500 to-emerald-700", logo: "S" },
    { name: "Roblox", brandInfo: "Gaming", color: "from-slate-700 to-slate-900", logo: "R" },
  ];

  return (
    <div className="max-w-5xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div className="flex items-center gap-4">
          <button onClick={() => router.back()} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
            <ArrowLeft size={24} className="text-slate-700" />
          </button>
          <div>
            <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Gift Cards</h1>
            <p className="text-slate-500 mt-1">Buy digital gift cards instantly from popular brands.</p>
          </div>
        </div>
        
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
          <input 
            type="text" 
            placeholder="Search brands..." 
            className="w-full md:w-64 bg-white border border-gray-200 rounded-full py-2.5 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 shadow-sm"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
        {cards.map((card, idx) => (
          <div key={idx} className="bg-white border border-gray-100 rounded-3xl p-4 shadow-sm hover:shadow-lg transition-all cursor-pointer group">
            <div className={`h-40 w-full rounded-2xl bg-gradient-to-br ${card.color} flex items-center justify-center p-6 relative overflow-hidden mb-4 group-hover:scale-[1.02] transition-transform`}>
              <div className="absolute top-3 right-3 bg-black/20 backdrop-blur-md rounded-full px-2 py-1 flex items-center gap-1">
                 <Star size={10} className="text-yellow-400 fill-yellow-400" />
                 <span className="text-[10px] font-bold text-white">Digital</span>
              </div>
              <span className="text-white font-black text-6xl opacity-90 drop-shadow-lg">{card.logo}</span>
            </div>
            
            <div className="px-2">
              <div className="flex justify-between items-start mb-3">
                <div>
                  <h3 className="font-bold text-[#0f172a] text-lg leading-tight">{card.name}</h3>
                  <p className="text-xs text-slate-500 font-bold uppercase tracking-wider">{card.brandInfo}</p>
                </div>
              </div>
              
              <div className="flex flex-wrap gap-2 mb-4">
                {['$10', '$25', '$50', '$100'].map(amt => (
                  <span key={amt} className="bg-slate-50 border border-slate-200 text-slate-600 text-xs font-bold px-3 py-1.5 rounded-lg">{amt}</span>
                ))}
              </div>
              
              <button 
                onClick={() => toast.success(`Selected ${card.name} Gift Card`)}
                className="w-full bg-[#0f172a] hover:bg-[#1e293b] text-white py-2.5 rounded-xl font-bold transition-colors text-sm"
              >
                Buy Now
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

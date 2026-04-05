"use client";

import { ArrowLeft, Heart, CheckCircle2, ShieldCheck } from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

export default function SadaqahPage() {
  const router = useRouter();

  const campaigns = [
    { 
      id: "1", 
      title: "Medical Emergency", 
      desc: "Help Ahmed cover his heart surgery expenses.",
      raised: 3250, 
      goal: 5000, 
      creator: "Ali Abdi", 
      tag: "Health",
      color: "text-rose-500",
      bg: "bg-rose-100"
    },
    { 
      id: "2", 
      title: "Village Water Well", 
      desc: "Building a permanent water source for a village in Gedo.",
      raised: 1800, 
      goal: 2000, 
      creator: "Community Fund", 
      tag: "Community",
      color: "text-blue-500",
      bg: "bg-blue-100"
    },
    { 
      id: "3", 
      title: "Education Support", 
      desc: "Scholarships for 10 orphans in Mogadishu.",
      raised: 450, 
      goal: 3000, 
      creator: "Sahra Jama", 
      tag: "Education",
      color: "text-amber-500",
      bg: "bg-amber-100"
    },
  ];

  return (
    <div className="max-w-4xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-4">
          <button onClick={() => router.back()} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
            <ArrowLeft size={24} className="text-slate-700" />
          </button>
          <div>
            <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Sadaqah & Community</h1>
            <p className="text-slate-500 mt-1">Donate directly to verified fundraisers and causes.</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
        {campaigns.map((campaign, idx) => {
          const progress = (campaign.raised / campaign.goal) * 100;
          return (
            <div key={idx} className="bg-white border border-gray-100 rounded-[2rem] overflow-hidden shadow-sm hover:shadow-lg transition-all group cursor-pointer flex flex-col">
              <div className="h-40 bg-slate-100 relative w-full flex items-center justify-center overflow-hidden">
                {/* Simulated Image Background */}
                <div className="absolute inset-0 bg-gradient-to-tr from-slate-200 to-slate-100 opacity-50 group-hover:scale-105 transition-transform duration-700"></div>
                
                <Heart size={48} className="text-slate-300 relative z-10" />
                
                <div className="absolute top-4 left-4 bg-white/90 backdrop-blur-sm px-3 py-1.5 rounded-full flex items-center gap-1.5 shadow-sm">
                   <ShieldCheck size={14} className="text-emerald-500" />
                   <span className="text-xs font-bold text-[#0f172a]">Verified</span>
                </div>
                <div className="absolute top-4 right-4 bg-[#0f172a]/80 backdrop-blur-sm px-3 py-1.5 rounded-full">
                   <span className="text-xs font-bold text-white uppercase tracking-wider">{campaign.tag}</span>
                </div>
              </div>
              
              <div className="p-6 flex-1 flex flex-col">
                <h3 className="text-xl font-bold text-[#0f172a] mb-1">{campaign.title}</h3>
                <p className="text-xs text-slate-500 font-medium mb-4 flex items-center gap-1">
                  <span className="w-4 h-4 rounded-full bg-slate-200"></span> By {campaign.creator}
                </p>
                <p className="text-sm text-slate-600 leading-relaxed mb-6 flex-1 line-clamp-2">{campaign.desc}</p>
                
                <div className="mb-2 flex justify-between items-end">
                   <div>
                      <span className="font-black text-xl text-[#0f172a]">${campaign.raised.toLocaleString()}</span>
                      <span className="text-xs text-slate-500 font-bold ml-1">Raised</span>
                   </div>
                   <div className="text-right">
                      <span className="font-bold text-[#0f172a]">{progress.toFixed(0)}%</span>
                      <p className="text-xs font-bold text-slate-500">Goal: ${campaign.goal.toLocaleString()}</p>
                   </div>
                </div>
                
                <div className="w-full bg-slate-100 rounded-full h-2 mb-6 overflow-hidden">
                  <div className="h-2 rounded-full bg-emerald-500 transition-all duration-1000" style={{ width: `${Math.min(progress, 100)}%` }}></div>
                </div>
                
                <button 
                  onClick={() => toast("Redirecting to payment via MurtaaxPay...")}
                  className="w-full py-3.5 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-xl font-bold transition-colors"
                >
                  Donate Now
                </button>
              </div>
            </div>
          )
        })}
      </div>
      
      <div className="bg-[#0f172a] rounded-3xl p-8 text-white text-center shadow-xl shadow-slate-900/10">
        <h2 className="text-2xl font-bold mb-3">Start a Fundraiser</h2>
        <p className="text-slate-400 text-sm mb-6 max-w-sm mx-auto">Create your own verified campaign to raise funds for medical, community, or personal causes securely.</p>
        <button onClick={() => toast("Campaign form opened")} className="bg-white text-[#0f172a] px-8 py-3 rounded-xl font-bold hover:bg-slate-50 transition-colors inline-block">
          Create Campaign
        </button>
      </div>
    </div>
  );
}

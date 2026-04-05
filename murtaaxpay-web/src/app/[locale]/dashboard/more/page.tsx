"use client";

import { QrCode, Coins, PiggyBank, TrendingUp, Heart, Gift, Users, Ticket, Star, ChevronRight } from "lucide-react";
import { toast } from "sonner";
import { useRouter } from "next/navigation";

export default function MoreServicesPage() {
  const router = useRouter();

  const financialServices = [
    { title: "Request Money", icon: QrCode, color: "text-blue-500", bg: "bg-blue-100", border: "hover:border-blue-500" },
    { title: "Exchange Rates", icon: Coins, color: "text-amber-500", bg: "bg-amber-100", border: "hover:border-amber-500" },
    { title: "Savings", icon: PiggyBank, color: "text-emerald-500", bg: "bg-emerald-100", border: "hover:border-emerald-500" },
    { title: "Investments", icon: TrendingUp, color: "text-purple-500", bg: "bg-purple-100", border: "hover:border-purple-500" },
  ];

  const lifestyleServices = [
    { title: "Sadaqah", icon: Heart, color: "text-red-500", bg: "bg-red-100", border: "hover:border-red-500" },
    { title: "Gift Cards", icon: Gift, color: "text-cyan-500", bg: "bg-cyan-100", border: "hover:border-cyan-500" },
    { title: "Refer & Earn", icon: Users, color: "text-indigo-500", bg: "bg-indigo-100", border: "hover:border-indigo-500" },
    { title: "Vouchers", icon: Ticket, color: "text-yellow-500", bg: "bg-yellow-100", border: "hover:border-yellow-500" },
  ];

  const handleServiceClick = (title: string) => {
    const routeMap: Record<string, string> = {
      "Request Money": "request",
      "Exchange Rates": "exchange",
      "Savings": "savings",
      "Investments": "investments",
      "Sadaqah": "sadaqah",
      "Gift Cards": "gift-cards",
      "Refer & Earn": "refer",
      "Vouchers": "vouchers",
    };
    
    if (routeMap[title]) {
      router.push(`/dashboard/more/${routeMap[title]}`);
    } else {
      toast.info(`Opening ${title} module...`);
    }
  };

  return (
    <div className="max-w-5xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">More Services</h1>
          <p className="text-slate-500 mt-1">Explore additional financial and lifestyle features.</p>
        </div>
      </div>

      {/* Financial Services Section */}
      <div className="mb-10">
        <h2 className="text-lg font-bold text-[#0f172a] mb-6">Financial Services</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6">
          {financialServices.map((service, idx) => (
            <div 
              key={idx}
              onClick={() => handleServiceClick(service.title)}
              className={`bg-white border-2 border-transparent p-6 rounded-[2rem] shadow-sm flex flex-col items-center justify-center gap-4 cursor-pointer transition-all hover:shadow-md hover:-translate-y-1 ${service.border}`}
            >
              <div className={`w-14 h-14 rounded-full flex items-center justify-center ${service.bg} ${service.color}`}>
                <service.icon size={26} />
              </div>
              <span className="font-bold text-[#0f172a] text-sm text-center">{service.title}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Lifestyle & Rewards Section */}
      <div className="mb-10">
        <h2 className="text-lg font-bold text-[#0f172a] mb-6">Lifestyle & Rewards</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6">
          {lifestyleServices.map((service, idx) => (
            <div 
              key={idx}
              onClick={() => handleServiceClick(service.title)}
              className={`bg-white border-2 border-transparent p-6 rounded-[2rem] shadow-sm flex flex-col items-center justify-center gap-4 cursor-pointer transition-all hover:shadow-md hover:-translate-y-1 ${service.border}`}
            >
              <div className={`w-14 h-14 rounded-full flex items-center justify-center ${service.bg} ${service.color}`}>
                <service.icon size={26} />
              </div>
              <span className="font-bold text-[#0f172a] text-sm text-center">{service.title}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Refer & Earn Promo Card */}
      <div 
        onClick={() => handleServiceClick("Refer & Earn")}
        className="w-full relative overflow-hidden bg-gradient-to-br from-[#0f172a] via-[#1e293b] to-[#0f172a] rounded-[2rem] p-8 sm:p-10 shadow-2xl cursor-pointer group transition-transform hover:-translate-y-1"
      >
        <div className="absolute top-0 right-0 p-8 opacity-10 group-hover:opacity-20 transition-opacity">
          <Star size={160} className="text-yellow-400 rotate-12" />
        </div>
        
        <div className="relative z-10 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-8">
          <div className="text-white max-w-lg">
            <div className="flex items-center gap-3 mb-3">
              <h2 className="text-2xl sm:text-3xl font-bold">Invite your friends!</h2>
              <Star className="text-yellow-400 fill-yellow-400 max-w-[28px]" />
            </div>
            <p className="text-slate-300 leading-relaxed text-sm sm:text-base mb-6">
              Get $10 for every friend who joins MurtaaxPay using your unique referral link.
            </p>
            <button className="bg-emerald-500 hover:bg-emerald-400 text-white px-8 py-3 rounded-xl font-bold transition-colors shadow-lg shadow-emerald-500/30 flex items-center gap-2">
              Invite Now <ChevronRight size={18} />
            </button>
          </div>
        </div>
      </div>

    </div>
  );
}

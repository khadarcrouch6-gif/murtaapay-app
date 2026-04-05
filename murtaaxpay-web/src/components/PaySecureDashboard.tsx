"use client";

import { LayoutDashboard, ArrowLeftRight, FileText, Activity, RefreshCw, ArrowRight, Search, HandHeart, Gift, Fingerprint, Coins, WalletCards, BadgeCheck } from "lucide-react";
import { toast } from "sonner";

export default function PaySecureDashboard() {
  return (
    <section id="dashboard" className="py-24 bg-zinc-50 dark:bg-[#020813] overflow-hidden transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Header Title */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-extrabold text-[#0f172a] dark:text-white mb-6">
            PaySecure Interface
          </h2>
          <p className="text-slate-500 dark:text-slate-400 text-lg max-w-2xl mx-auto">
            Manage everything in a single, intuitive, military-grade secure dashboard.
          </p>
        </div>

        {/* Dashboard Mockup Container */}
        <div className="max-w-5xl mx-auto bg-white dark:bg-slate-900 rounded-3xl shadow-2xl overflow-hidden border border-gray-100 dark:border-white/10 flex flex-col md:flex-row min-h-[500px]">
          
          {/* Sidebar */}
          <div className="w-full md:w-64 border-r border-gray-100 dark:border-white/10 p-6 flex flex-col bg-gray-50/50 dark:bg-slate-800/30">
            <div className="font-bold text-xl text-[#0f172a] dark:text-white mb-12 flex items-center gap-2">
              <div className="w-8 h-8 bg-emerald-500 rounded-lg flex justify-center items-center text-white">M</div>
              Murtaax
            </div>
            
            <nav className="flex-1 space-y-2">
              <a href="#" className="flex items-center gap-3 px-4 py-3 rounded-xl bg-emerald-50 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400 font-medium">
                <LayoutDashboard size={20} /> Dashboard
              </a>
              <a href="#" className="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-gray-100 dark:hover:bg-white/5 font-medium transition-colors">
                <ArrowLeftRight size={20} /> Transfers
              </a>
              <a href="#" className="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-gray-100 dark:hover:bg-white/5 font-medium transition-colors">
                <FileText size={20} /> Invoices
              </a>
              <a href="#" className="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 dark:text-slate-400 hover:bg-gray-100 dark:hover:bg-white/5 font-medium transition-colors">
                <Activity size={20} /> All Activity
              </a>
            </nav>

            {/* Support User snippet inside sidebar */}
            <div className="mt-auto border-t border-gray-200 dark:border-white/10 pt-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-emerald-100 dark:bg-emerald-900/50 text-emerald-700 dark:text-emerald-400 font-bold flex items-center justify-center">RD</div>
                <div>
                  <div className="text-sm font-bold text-slate-800 dark:text-slate-200">Support Pin</div>
                  <div className="text-xs text-emerald-600 dark:text-emerald-500 font-medium">8492</div>
                </div>
              </div>
            </div>
          </div>

          {/* Main Dashboard Area */}
          <div className="flex-1 p-8 bg-white dark:bg-slate-900">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
              
              {/* Total Balance Card */}
              <div className="lg:col-span-2 bg-gradient-to-br from-[#0f172a] to-[#1e293b] rounded-2xl p-6 text-white relative overflow-hidden">
                <div className="absolute top-0 right-0 p-4 opacity-10">
                  <LayoutDashboard size={120} />
                </div>
                <p className="text-slate-300 font-medium mb-2">Total Balance</p>
                <h3 className="text-4xl font-bold mb-6">$13,450.00</h3>
                <div className="flex gap-4">
                  <a href="#add-funds" className="bg-emerald-500 text-white px-5 py-2.5 rounded-full text-sm font-semibold flex items-center gap-2 transition-transform hover:scale-105">
                    + Add Money
                  </a>
                  <a href="#add-funds" className="bg-white/10 hover:bg-white/20 text-white px-5 py-2.5 rounded-full text-sm font-semibold flex items-center gap-2 transition-colors">
                    Send <ArrowRight size={16} />
                  </a>
                </div>
              </div>

              {/* FX Accounts mini card */}
              <div className="bg-slate-50 dark:bg-slate-800/30 rounded-2xl p-6 border border-gray-100 dark:border-white/10">
                <p className="font-semibold text-slate-800 dark:text-white border-b border-gray-200 dark:border-white/10 pb-3 mb-3">Multiple FX Accounts</p>
                <div className="space-y-4">
                  <div className="flex justify-between items-center text-sm">
                    <span className="flex items-center gap-2 text-slate-600 dark:text-slate-300 font-medium"><div className="w-2 h-2 rounded-full bg-emerald-500"/> USD Acc</span>
                    <span className="font-bold text-emerald-600 dark:text-emerald-400">Active</span>
                  </div>
                  <div className="flex justify-between items-center text-sm">
                    <span className="flex items-center gap-2 text-slate-600 dark:text-slate-300 font-medium"><div className="w-2 h-2 rounded-full bg-gray-300 dark:bg-slate-600"/> GBP Acc</span>
                    <span className="font-bold text-slate-400">Setup</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Recent Activity */}
            <div>
              <div className="flex justify-between items-center mb-6">
                <h4 className="font-bold text-lg text-slate-800 dark:text-white">Recent Activity</h4>
                <a href="#" className="text-emerald-500 text-sm font-medium hover:underline">View All</a>
              </div>
              <div className="space-y-4">
                {[
                  { name: "Sent to Hasan A.", date: "Today, 10:24 AM", amount: "-$850.00", color: "text-red-500 dark:text-red-400", icon: ArrowLeftRight },
                  { name: "Salary Deposit", date: "Yesterday, 04:30 PM", amount: "+$4,150.00", color: "text-emerald-500 dark:text-emerald-400", icon: Coins },
                  { name: "Uber Ride", date: "May 12, 09:15 AM", amount: "-$14.50", color: "text-red-500 dark:text-red-400", icon: Activity }
                ].map((item, idx) => (
                  <div key={idx} className="flex justify-between items-center py-3 border-b border-gray-50 dark:border-white/5 last:border-0 hover:bg-gray-50 dark:hover:bg-white/5 p-2 rounded-xl transition-colors">
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-10 rounded-full bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-slate-500 dark:text-slate-400">
                        <item.icon size={18} />
                      </div>
                      <div>
                        <p className="font-bold text-slate-800 dark:text-white">{item.name}</p>
                        <p className="text-xs text-slate-500 dark:text-slate-400">{item.date}</p>
                      </div>
                    </div>
                    <div className={`font-bold ${item.color}`}>
                      {item.amount}
                    </div>
                  </div>
                ))}
              </div>
            </div>

          </div>
        </div>
        </div>

        {/* 4 Feature Highlights Grid */}
        <div className="max-w-7xl mx-auto mt-20 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
          
          <div className="bg-[#f0f4f8] dark:bg-slate-800/40 rounded-[2.5rem] p-10 hover:shadow-lg transition-all border border-transparent hover:border-gray-100 dark:hover:border-white/10 group">
            <Search className="text-[#064e3b] dark:text-emerald-400 w-8 h-8 mb-6 group-hover:scale-110 transition-transform" />
            <h3 className="font-bold text-[#0f172a] dark:text-white text-lg mb-3">Murtaax ID Lookup</h3>
            <p className="text-[15px] text-slate-500 dark:text-slate-400 leading-relaxed font-medium">Find friends instantly using their unique Murtaax ID.</p>
          </div>

          <div className="bg-[#f0f4f8] dark:bg-slate-800/40 rounded-[2.5rem] p-10 hover:shadow-lg transition-all border border-transparent hover:border-gray-100 dark:hover:border-white/10 group">
            <HandHeart className="text-[#064e3b] dark:text-emerald-400 w-8 h-8 mb-6 group-hover:scale-110 transition-transform" />
            <h3 className="font-bold text-[#0f172a] dark:text-white text-lg mb-3">Sadaqah & Zakat</h3>
            <p className="text-[15px] text-slate-500 dark:text-slate-400 leading-relaxed font-medium">Donate directly to verified charities in Somalia with one tap.</p>
          </div>

          <div className="bg-[#f0f4f8] dark:bg-slate-800/40 rounded-[2.5rem] p-10 hover:shadow-lg transition-all border border-transparent hover:border-gray-100 dark:hover:border-white/10 group">
            <Gift className="text-[#064e3b] dark:text-emerald-400 w-8 h-8 mb-6 group-hover:scale-110 transition-transform" />
            <h3 className="font-bold text-[#0f172a] dark:text-white text-lg mb-3">Gift Cards</h3>
            <p className="text-[15px] text-slate-500 dark:text-slate-400 leading-relaxed font-medium">Purchase Amazon, iTunes, and Google Play vouchers instantly.</p>
          </div>

          <div className="bg-[#f0f4f8] dark:bg-slate-800/40 rounded-[2.5rem] p-10 hover:shadow-lg transition-all border border-transparent hover:border-gray-100 dark:hover:border-white/10 group">
            <Fingerprint stroke="url(#cyan-gradient)" strokeWidth={2.5} size={32} className="mb-6 group-hover:scale-110 transition-transform" />
            <h3 className="font-bold text-[#0f172a] dark:text-white text-lg mb-3">KYC Simplified</h3>
            <p className="text-[15px] text-slate-500 dark:text-slate-400 leading-relaxed font-medium">Verification in minutes using just your ID and a quick selfie.</p>
          </div>

        </div>
    </section>
  );
}

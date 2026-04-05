"use client";

import { Wallet, ArrowDownToLine, ArrowUpFromLine, Building2, Smartphone, Loader2, CheckCircle2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function WalletPage() {
  const [activeTab, setActiveTab] = useState<'deposit' | 'withdraw'>('deposit');
  const [isProcessing, setIsProcessing] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsProcessing(true);
    toast.loading(`Processing ${activeTab}...`, { id: "process" });
    
    setTimeout(() => {
      setIsProcessing(false);
      toast.success(`${activeTab === 'deposit' ? 'Funds added' : 'Withdrawal initiated'} successfully!`, { id: "process" });
    }, 2000);
  };

  return (
    <div className="max-w-4xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      <div className="mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Wallet Management</h1>
        <p className="text-slate-500 mt-1">Deposit funds or withdraw cash to your local bank or mobile.</p>
      </div>

      <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm">
        
        {/* Toggle Tabs */}
        <div className="flex bg-slate-100 p-1.5 rounded-full mb-8 max-w-sm mx-auto">
          <button 
            onClick={() => setActiveTab('deposit')}
            className={`flex-1 py-3 rounded-full font-bold text-sm transition-colors flex items-center justify-center gap-2 ${activeTab === 'deposit' ? 'bg-white shadow-sm text-emerald-600' : 'text-slate-500 hover:text-slate-700'}`}
          >
            <ArrowDownToLine size={18} /> Deposit
          </button>
          <button 
            onClick={() => setActiveTab('withdraw')}
            className={`flex-1 py-3 rounded-full font-bold text-sm transition-colors flex items-center justify-center gap-2 ${activeTab === 'withdraw' ? 'bg-white shadow-sm text-blue-600' : 'text-slate-500 hover:text-slate-700'}`}
          >
            <ArrowUpFromLine size={18} /> Withdraw
          </button>
        </div>

        <form onSubmit={handleSubmit} className="max-w-xl mx-auto space-y-8">
          
          <div className="space-y-4">
            <h3 className="font-bold text-slate-700">1. Select Method</h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="border-2 border-emerald-500 bg-emerald-50 rounded-xl p-4 cursor-pointer relative">
                <div className="absolute top-3 right-3 text-emerald-500"><CheckCircle2 size={18} /></div>
                <Building2 className="text-emerald-600 mb-2" size={24} />
                <p className="font-bold text-emerald-800 text-sm">Bank Account</p>
                <p className="text-xs text-emerald-600">Free • 1-2 mins</p>
              </div>
              <div className="border-2 border-transparent hover:border-gray-200 bg-slate-50 rounded-xl p-4 cursor-pointer transition-colors">
                <Smartphone className="text-slate-600 mb-2" size={24} />
                <p className="font-bold text-slate-700 text-sm">Mobile Money</p>
                <p className="text-xs text-slate-500">1% Fee • Instant</p>
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h3 className="font-bold text-slate-700">2. {activeTab === 'deposit' ? 'Source Details' : 'Destination Details'}</h3>
            <select className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 px-4 focus:outline-none focus:ring-2 focus:ring-emerald-500 font-medium">
              <option>Premier Bank (**** 0192)</option>
              <option>Salaam Somali Bank (**** 8841)</option>
              <option>Link new bank account...</option>
            </select>
          </div>

          <div className="space-y-4">
            <h3 className="font-bold text-slate-700">3. Amount (USD)</h3>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <span className="text-2xl font-bold text-slate-400">$</span>
              </div>
              <input type="number" min="10" required className="w-full bg-slate-50 border border-gray-200 rounded-xl py-6 pl-12 pr-4 text-3xl font-bold text-[#0f172a] focus:outline-none focus:ring-2 focus:ring-emerald-500" placeholder="0.00" />
            </div>
            {activeTab === 'withdraw' && (
              <p className="text-sm text-slate-500 text-right">Available to withdraw: <strong className="text-[#0f172a]">$13,450.00</strong></p>
            )}
          </div>

          <button 
            type="submit" 
            disabled={isProcessing}
            className={`w-full py-4 rounded-xl font-bold text-lg transition-transform hover:-translate-y-0.5 shadow-xl flex items-center justify-center gap-2 disabled:opacity-80 disabled:hover:translate-y-0 text-white ${activeTab === 'deposit' ? 'bg-emerald-500 hover:bg-emerald-400 shadow-emerald-500/20' : 'bg-[#0f172a] hover:bg-[#1e293b] shadow-slate-900/20'}`}
          >
            {isProcessing ? (
              <><Loader2 size={24} className="animate-spin" /> Processing...</>
            ) : (
              <>{activeTab === 'deposit' ? 'Add Funds Now' : 'Withdraw Funds'}</>
            )}
          </button>
        </form>

      </div>
    </div>
  );
}

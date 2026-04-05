"use client";

import { CheckCircle2, Lock, Loader2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function AddFundsSection() {
  const [isLoading, setIsLoading] = useState(false);

  const handleDeposit = () => {
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      toast.success("Successfully deposited $1,450.00 to your wallet!", {
        description: "Your balance has been updated instantly.",
      });
    }, 1500);
  };

  return (
    <section id="add-funds" className="py-24 bg-zinc-50 dark:bg-[#040D1F] border-t border-gray-100 dark:border-white/5 overflow-hidden transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          
          {/* Left Text */}
          <div className="max-w-lg">
            <h2 className="text-4xl md:text-5xl font-extrabold text-[#0f172a] dark:text-white mb-6">
              Add funds effortlessly.
            </h2>
            <p className="text-lg text-slate-500 dark:text-slate-400 mb-10 leading-relaxed">
              Whether you're using a debit card, bank transfer, or mobile money like EVC or ZAAD Plus, adding money to your Murtaax wallet is instantaneous and secure.
            </p>

            <ul className="space-y-6">
              {[
                "Add instantly free for allowed transfers.",
                "Real-time exchange integrations.",
                "Military-grade encryption and security."
              ].map((item, idx) => (
                <li key={idx} className="flex items-start gap-4">
                  <CheckCircle2 className="text-emerald-500 mt-1 shrink-0" size={24} />
                  <span className="text-slate-700 dark:text-slate-300 font-medium text-lg">{item}</span>
                </li>
              ))}
            </ul>
          </div>

          {/* Right Deposit Form Mockup */}
          <div className="w-full max-w-[480px] mx-auto lg:ml-auto">
            <div className="bg-white dark:bg-slate-900 rounded-[2rem] shadow-xl border border-gray-100 dark:border-white/10 p-8 relative">
              
              {/* Tabs */}
              <div className="flex bg-slate-100 dark:bg-slate-800/50 p-1 rounded-xl mb-8 border dark:border-white/5">
                <button className="flex-1 bg-white dark:bg-slate-700 py-2.5 rounded-lg text-sm font-bold text-[#0f172a] dark:text-white shadow-sm transition-colors">Card Deposit</button>
                <button 
                  onClick={() => toast.info("Bank transfers are coming in v2.0")}
                  className="flex-1 py-2.5 rounded-lg text-sm font-medium text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-colors"
                >
                  Bank Transfer
                </button>
              </div>

              {/* Amount Input */}
              <div className="mb-6">
                <label className="block text-xs font-semibold uppercase text-slate-400 dark:text-slate-500 mb-2">AMOUNT TO DEPOSIT</label>
                <div className="relative border-b-2 border-emerald-500 pb-2">
                  <span className="absolute left-0 top-0 text-xl font-bold text-slate-800 dark:text-white">$</span>
                  <input type="text" value="1,450.00" readOnly className="w-full pl-6 text-2xl font-bold text-[#0f172a] dark:text-white outline-none bg-transparent" />
                </div>
              </div>

              {/* Card Details Input */}
              <div className="mb-8">
                <label className="block text-xs font-semibold uppercase text-slate-400 dark:text-slate-500 mb-2">CARD DETAILS</label>
                <div className="border border-gray-200 dark:border-white/10 rounded-xl overflow-hidden focus-within:border-emerald-500 dark:focus-within:border-emerald-500 transition-all cursor-text" onClick={() => toast("Card details are securely locked for this demo.", { icon: "🔒" })}>
                  <div className="p-3 border-b border-gray-200 dark:border-white/10 flex items-center justify-between bg-slate-50/50 dark:bg-slate-800/80">
                    <span className="text-slate-700 dark:text-slate-300 font-mono tracking-widest text-sm">4242 4242 4242 4242</span>
                    <span className="w-8 h-5 bg-gradient-to-r from-blue-600 to-indigo-800 rounded flex items-center justify-center text-[8px] font-bold text-white italic">VISA</span>
                  </div>
                  <div className="flex bg-slate-50/50 dark:bg-slate-800/80">
                    <div className="p-3 w-1/2 border-r border-gray-200 dark:border-white/10 text-center">
                      <span className="text-slate-400 font-mono text-sm">12 / 28</span>
                    </div>
                    <div className="p-3 w-1/2 text-center">
                      <span className="text-slate-400 font-mono text-sm">***</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* CTA */}
              <button 
                onClick={handleDeposit}
                disabled={isLoading}
                className="w-full bg-[#0f172a] dark:bg-emerald-500 hover:bg-[#1e293b] dark:hover:bg-emerald-400 text-white dark:text-slate-900 py-4 rounded-xl font-bold text-lg shadow-lg flex justify-center items-center gap-2 transition-all disabled:opacity-80"
              >
                {isLoading ? (
                  <><Loader2 className="animate-spin" size={20} /> Processing...</>
                ) : (
                  <>Top up $1,450.00</>
                )}
              </button>

              <div className="mt-4 flex justify-center items-center gap-2 text-xs text-slate-400">
                <Lock size={12} className="text-emerald-500" /> Your data is securely encrypted
              </div>

            </div>
          </div>

        </div>
      </div>
    </section>
  );
}

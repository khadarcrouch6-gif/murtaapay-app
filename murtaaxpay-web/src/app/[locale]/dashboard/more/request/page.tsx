"use client";

import { ArrowLeft, QrCode, Copy, CheckCircle2, User, Loader2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

export default function RequestMoneyPage() {
  const router = useRouter();
  const [amount, setAmount] = useState("");
  const [phone, setPhone] = useState("");
  const [isSending, setIsSending] = useState(false);

  const handleRequest = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSending(true);
    toast.loading("Sending request...", { id: "req" });
    setTimeout(() => {
      setIsSending(false);
      toast.success("Payment request sent to " + phone, { id: "req" });
      setAmount("");
      setPhone("");
    }, 1500);
  };

  return (
    <div className="max-w-3xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      <div className="flex items-center gap-4 mb-8">
        <button onClick={() => router.back()} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
          <ArrowLeft size={24} className="text-slate-700" />
        </button>
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Request Money</h1>
          <p className="text-slate-500 mt-1">Ask friends or family for a payment securely.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
        <div className="md:col-span-3 bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm">
          <h2 className="text-xl font-bold text-[#0f172a] mb-6">Create Request</h2>
          <form onSubmit={handleRequest} className="space-y-6">
            <div>
              <label className="block text-sm font-bold text-slate-700 mb-2">Amount (USD)</label>
              <div className="relative">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 font-bold">$</span>
                <input 
                  type="number" 
                  required 
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 pl-8 pr-4 focus:outline-none focus:ring-2 focus:ring-blue-500 font-bold text-lg" 
                  placeholder="0.00" 
                />
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-bold text-slate-700 mb-2">Request From</label>
              <div className="relative">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"><User size={20} /></span>
                <input 
                  type="tel" 
                  required 
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 pl-12 pr-4 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm" 
                  placeholder="Enter Phone Number" 
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-bold text-slate-700 mb-2">Note (Optional)</label>
              <input 
                type="text" 
                className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 px-4 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm" 
                placeholder="What is this for?" 
              />
            </div>

            <button 
              disabled={isSending || !amount || !phone}
              className="w-full py-4 rounded-xl font-bold transition-all flex justify-center items-center gap-2 text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50"
            >
              {isSending ? <Loader2 size={20} className="animate-spin" /> : "Send Request"}
            </button>
          </form>
        </div>

        <div className="md:col-span-2 space-y-6">
          <div className="bg-gradient-to-br from-slate-900 to-slate-800 rounded-[2rem] p-8 text-center text-white shadow-lg relative overflow-hidden">
            <div className="absolute top-0 right-0 p-4 opacity-10">
              <QrCode size={120} />
            </div>
            <div className="relative z-10">
              <div className="w-16 h-16 bg-white/10 backdrop-blur-md rounded-full flex items-center justify-center mx-auto mb-4 border border-white/20">
                <QrCode size={28} className="text-white" />
              </div>
              <h3 className="font-bold text-lg mb-2">My QR Code</h3>
              <p className="text-sm text-slate-300 mb-6 leading-relaxed">Let others scan this code to pay you instantly, no phone number required.</p>
              
              <div className="bg-white rounded-xl p-4 inline-block shadow-inner mb-6">
                 {/* Mock QR image */}
                 <div className="w-32 h-32 bg-slate-200 rounded-lg flex items-center justify-center border-4 border-dashed border-slate-300">
                    <QrCode size={48} className="text-slate-400" />
                 </div>
              </div>
              
              <button 
                onClick={() => toast.success("QR Code saved to gallery!")}
                className="w-full py-3 bg-white/10 hover:bg-white/20 border border-white/20 rounded-xl font-bold transition-colors text-sm"
              >
                Download QR Code
              </button>
            </div>
          </div>
          
          <div className="bg-blue-50 border border-blue-100 rounded-2xl p-6">
            <h4 className="font-bold text-blue-900 text-sm mb-2">Payment Link</h4>
            <div className="flex items-center gap-2 bg-white p-2 rounded-xl border border-blue-200/50">
              <span className="text-xs text-slate-500 truncate flex-1 pl-2 font-mono">pay.murtaax.com/ali</span>
              <button onClick={() => toast.success("Link copied!")} className="p-2 bg-blue-100 text-blue-600 rounded-lg hover:bg-blue-200 transition-colors">
                <Copy size={16} />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

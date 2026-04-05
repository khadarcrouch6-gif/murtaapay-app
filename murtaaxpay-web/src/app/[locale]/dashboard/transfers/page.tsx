"use client";

import { ArrowRight, Wallet, User, Phone, CheckCircle2, RotateCcw, Loader2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function TransfersPage() {
  const [isSending, setIsSending] = useState(false);
  const [success, setSuccess] = useState(false);
  
  // Interactive Form State
  const [method, setMethod] = useState<'mobile' | 'bank'>('mobile');
  const [recipient, setRecipient] = useState({ name: '', phone: '' });

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSending(true);
    toast.loading("Initiating secure transfer...", { id: "transfer" });

    setTimeout(() => {
      setIsSending(false);
      setSuccess(true);
      toast.success("Transfer completed successfully!", { id: "transfer" });
      
      // Reset form after 3 seconds
      setTimeout(() => setSuccess(false), 3000);
    }, 2000);
  };

  return (
    <div className="max-w-5xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      <div className="mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Send Money</h1>
        <p className="text-slate-500 mt-1">Instant, zero-fee transfers globally.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* Transfer Form Col */}
        <div className="lg:col-span-2">
          <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm">
            {success ? (
              <div className="py-16 flex flex-col items-center justify-center text-center">
                <div className="w-20 h-20 bg-emerald-100text-emerald-500 rounded-full flex items-center justify-center mb-6 animate-bounce">
                  <CheckCircle2 size={40} className="text-emerald-500" />
                </div>
                <h3 className="text-3xl font-black text-[#0f172a] mb-2">Sent Successfully!</h3>
                <p className="text-slate-500 max-w-sm mb-8">
                  Your funds are on the way to the recipient's mobile wallet. They will receive an SMS notification shortly.
                </p>
                <button 
                  onClick={() => setSuccess(false)}
                  className="bg-[#0f172a] text-white px-8 py-3 rounded-full font-bold flex items-center gap-2 hover:bg-[#1e293b] transition-colors"
                >
                  <RotateCcw size={18} /> Send Another
                </button>
              </div>
            ) : (
              <form onSubmit={handleSend} className="space-y-8">
                {/* Method & Dest */}
                <div className="space-y-4">
                  <h3 className="font-bold text-slate-700">1. Destination</h3>
                  <div className="grid grid-cols-2 gap-4">
                    <div 
                      onClick={() => setMethod('mobile')}
                      className={`p-4 rounded-xl cursor-pointer relative overflow-hidden transition-all border-2 ${method === 'mobile' ? 'border-emerald-500 bg-emerald-50' : 'border-gray-200 hover:border-emerald-500 bg-white'}`}
                    >
                      {method === 'mobile' && <div className="absolute top-2 right-2 text-emerald-500"><CheckCircle2 size={16} /></div>}
                      <p className={`font-bold text-sm ${method === 'mobile' ? 'text-emerald-800' : 'text-slate-700'}`}>Mobile Wallet</p>
                      <p className={`text-xs mt-1 ${method === 'mobile' ? 'text-emerald-600' : 'text-slate-500'}`}>EVC, ZAAD, eDahab</p>
                    </div>
                    
                    <div 
                      onClick={() => setMethod('bank')}
                      className={`p-4 rounded-xl cursor-pointer relative transition-all border-2 ${method === 'bank' ? 'border-emerald-500 bg-emerald-50' : 'border-gray-200 hover:border-emerald-500 bg-white'}`}
                    >
                      {method === 'bank' && <div className="absolute top-2 right-2 text-emerald-500"><CheckCircle2 size={16} /></div>}
                      <p className={`font-bold text-sm ${method === 'bank' ? 'text-emerald-800' : 'text-slate-700'}`}>Bank Transfer</p>
                      <p className={`text-xs mt-1 ${method === 'bank' ? 'text-emerald-600' : 'text-slate-500'}`}>Premier, Salaam</p>
                    </div>
                  </div>
                </div>

                {/* Recipient Info */}
                <div className="space-y-4">
                  <h3 className="font-bold text-slate-700">2. Recipient</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <User className="h-5 w-5 text-gray-400" />
                      </div>
                      <input 
                        type="text" 
                        required 
                        value={recipient.name}
                        onChange={(e) => setRecipient({...recipient, name: e.target.value})}
                        className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-emerald-500" 
                        placeholder="Recipient Name" 
                      />
                    </div>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <Phone className="h-5 w-5 text-gray-400" />
                      </div>
                      <input 
                        type="tel" 
                        required 
                        value={recipient.phone}
                        onChange={(e) => setRecipient({...recipient, phone: e.target.value})}
                        className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-emerald-500" 
                        placeholder={method === 'mobile' ? "+252 61..." : "Account Number"} 
                      />
                    </div>
                  </div>
                </div>

                {/* Amount */}
                <div className="space-y-4">
                  <h3 className="font-bold text-slate-700">3. Amount</h3>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                      <span className="text-2xl font-bold text-slate-400">$</span>
                    </div>
                    <input type="number" min="1" step="0.01" required className="w-full bg-slate-50 border border-gray-200 rounded-xl py-6 pl-12 pr-4 text-3xl font-bold text-[#0f172a] focus:outline-none focus:ring-2 focus:ring-emerald-500" placeholder="0.00" />
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Available Balance: <strong className="text-[#0f172a]">$13,450.00</strong></span>
                    <span className="text-emerald-600 font-bold">Fee: $0.00</span>
                  </div>
                </div>

                <div className="pt-4 border-t border-gray-100">
                  <button 
                    type="submit" 
                    disabled={isSending}
                    className="w-full bg-emerald-500 hover:bg-emerald-400 text-white py-4 rounded-xl font-bold text-lg transition-transform hover:-translate-y-0.5 shadow-xl shadow-emerald-500/20 flex items-center justify-center gap-2 disabled:opacity-80 disabled:hover:translate-y-0"
                  >
                    {isSending ? (
                      <><Loader2 size={24} className="animate-spin" /> Processing...</>
                    ) : (
                      <>Send Money Securely <ArrowRight size={20} /></>
                    )}
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>

        {/* Saved & Recent Col */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-100 rounded-[2rem] p-6 shadow-sm">
            <h3 className="font-bold text-[#0f172a] mb-6">Recent Recipients</h3>
            <div className="space-y-4">
              {[
                { name: "Hawa Jama", phone: "+252 61 555 0192", color: "bg-purple-100 text-purple-600", initial: "HJ", type: 'mobile' },
                { name: "Ali Ahmed", phone: "+252 61 234 5678", color: "bg-blue-100 text-blue-600", initial: "AA", type: 'mobile' },
                { name: "Dahabshiil Bank", phone: "ACC: 100492819", color: "bg-orange-100 text-orange-600", initial: "DB", type: 'bank' },
              ].map((rec, idx) => (
                <div 
                  key={idx} 
                  onClick={() => {
                    setMethod(rec.type as 'mobile' | 'bank');
                    setRecipient({ name: rec.name, phone: rec.phone.replace('ACC: ', '') });
                    toast.info(`Filled details for ${rec.name}`);
                  }}
                  className="flex items-center gap-4 cursor-pointer hover:bg-slate-50 p-2 -m-2 rounded-xl transition-colors"
                >
                  <div className={`w-12 h-12 rounded-full flex items-center justify-center font-bold ${rec.color}`}>
                    {rec.initial}
                  </div>
                  <div>
                    <p className="font-bold text-sm text-[#0f172a]">{rec.name}</p>
                    <p className="text-xs text-slate-500">{rec.phone}</p>
                  </div>
                </div>
              ))}
            </div>
            
            <button onClick={() => toast("Add recipient modal opened.")} className="w-full mt-6 py-3 border-2 border-dashed border-gray-200 rounded-xl text-slate-500 font-bold text-sm hover:border-emerald-500 hover:text-emerald-600 transition-colors">
              + Add New Recipient
            </button>
          </div>

          <div className="bg-gradient-to-br from-slate-900 to-[#0f172a] border border-slate-800 rounded-[2rem] p-8 text-center relative overflow-hidden">
            <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-500/20 rounded-full blur-[40px] pointer-events-none" />
            <Wallet className="text-emerald-400 w-10 h-10 mx-auto mb-4" />
            <h3 className="text-white font-bold mb-2">Need to load funds?</h3>
            <p className="text-slate-400 text-sm mb-6">Deposit money instantly via Bank or Crypto before sending.</p>
            <button onClick={() => toast("Add Funds modal opening...")} className="bg-white/10 hover:bg-white/20 text-white w-full py-2.5 rounded-full font-bold text-sm transition-colors">
              Deposit Now
            </button>
          </div>
        </div>

      </div>

    </div>
  );
}

"use client";

import { MessageSquare, PhoneCall, Mail, ChevronRight, Send, User } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function SupportPage() {
  const [msg, setMsg] = useState("");
  const [openFaq, setOpenFaq] = useState<number | null>(null);

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    if(!msg) return;
    toast.success("Message sent to live agent!", { id: "chat" });
    setMsg("");
  };

  return (
    <div className="max-w-5xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      <div className="mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Help & Support</h1>
        <p className="text-slate-500 mt-1">We're here to help you 24/7.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        
        {/* Live Chat Mockup */}
        <div className="bg-white border border-gray-100 rounded-[2rem] flex flex-col h-[600px] shadow-sm overflow-hidden">
          <div className="bg-[#0f172a] p-6 flex justify-between items-center">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-emerald-500 flex items-center justify-center text-white font-bold relative">
                MA
                <div className="absolute bottom-0 right-0 w-3 h-3 bg-green-400 border-2 border-[#0f172a] rounded-full"></div>
              </div>
              <div>
                <h3 className="text-white font-bold text-lg">Murtaax Agent</h3>
                <p className="text-slate-400 text-xs text-emerald-400 font-medium">Online. Replies typically in 2 mins</p>
              </div>
            </div>
          </div>

          <div className="flex-1 p-6 bg-slate-50 overflow-y-auto space-y-6">
            <p className="text-center text-xs font-bold text-slate-400 uppercase tracking-widest my-4">Today 10:45 AM</p>
            
            <div className="flex gap-4">
              <div className="w-8 h-8 rounded-full bg-emerald-500 flex-shrink-0 flex items-center justify-center text-white text-xs font-bold">MA</div>
              <div className="bg-white p-4 rounded-2xl rounded-tl-none border border-gray-100 shadow-sm max-w-[80%]">
                <p className="text-sm text-slate-700 leading-relaxed">Hello Ali! Thank you for contacting MurtaaxPay support. How can I help you today?</p>
              </div>
            </div>

            <div className="flex gap-4 flex-row-reverse">
              <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-emerald-500 to-teal-400 flex-shrink-0 flex items-center justify-center text-white text-xs font-bold">AH</div>
              <div className="bg-emerald-500 p-4 rounded-2xl rounded-tr-none shadow-sm max-w-[80%] text-white">
                <p className="text-sm leading-relaxed">Hi, I want to know the limit for virtual cards?</p>
              </div>
            </div>

             <div className="flex gap-4">
              <div className="w-8 h-8 rounded-full bg-emerald-500 flex-shrink-0 flex items-center justify-center text-white text-xs font-bold">MA</div>
              <div className="bg-white p-4 rounded-2xl rounded-tl-none border border-gray-100 shadow-sm max-w-[80%]">
                <p className="text-sm text-slate-700 leading-relaxed">Virtual cards on the verified tier have a limit of $5,000 per month. You can adjust this from your Cards tab settings!</p>
              </div>
            </div>
          </div>

          <div className="p-4 bg-white border-t border-gray-100">
            <form onSubmit={handleSend} className="relative">
              <input 
                type="text" 
                value={msg}
                onChange={(e) => setMsg(e.target.value)}
                placeholder="Type your message..." 
                className="w-full bg-slate-50 border border-gray-200 rounded-full py-3.5 pl-6 pr-14 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500"
              />
              <button type="submit" className="absolute right-2 top-1.5 w-10 h-10 bg-emerald-500 hover:bg-emerald-400 text-white rounded-full flex items-center justify-center transition-colors">
                <Send size={18} className="translate-x-0.5" />
              </button>
            </form>
          </div>
        </div>

        {/* FAQ & Contact Methods */}
        <div className="space-y-6">
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-white border border-gray-100 rounded-2xl p-6 text-center cursor-pointer hover:border-emerald-500 hover:shadow-md transition-all group">
              <div className="w-12 h-12 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                <PhoneCall size={20} />
              </div>
              <h4 className="font-bold text-[#0f172a] text-sm">Call Us</h4>
              <p className="text-xs text-slate-500 mt-1">+252 61 000 0000</p>
            </div>
            
            <div className="bg-white border border-gray-100 rounded-2xl p-6 text-center cursor-pointer hover:border-emerald-500 hover:shadow-md transition-all group">
              <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                <Mail size={20} />
              </div>
              <h4 className="font-bold text-[#0f172a] text-sm">Email Support</h4>
              <p className="text-xs text-slate-500 mt-1">help@murtaax.com</p>
            </div>
          </div>

          <div className="bg-white border border-gray-100 rounded-[2rem] p-6 shadow-sm">
            <h3 className="font-bold text-[#0f172a] mb-6">Frequently Asked Questions</h3>
            <div className="space-y-3">
              {[
                { q: "How do I increase my daily limits?", a: "You can increase your limits by navigating to Settings > Identity Verified and submitting your KYC documents (Passport or ID)." },
                { q: "What forms of ID are accepted for KYC?", a: "We accept Passports, National ID Cards, and valid Driver's Licenses." },
                { q: "How long do international transfers take?", a: "Most mobile wallet transfers are instant. Bank transfers may take 1-2 business days depending on the routing." },
                { q: "Are there zero fees for wallet-to-wallet?", a: "Yes! All MurtaaxPay wallet-to-wallet transactions are completely 100% free of charge." },
                { q: "Can I lock my virtual card temporarily?", a: "Yes, you can toggle the 'Freeze' option directly from your Virtual Cards dashboard." }
              ].map((item, idx) => (
                <div key={idx} className="bg-slate-50 rounded-xl overflow-hidden transition-all">
                  <div 
                    onClick={() => setOpenFaq(openFaq === idx ? null : idx)}
                    className="flex items-center justify-between p-4 cursor-pointer hover:bg-slate-100 transition-colors"
                  >
                    <span className="text-sm font-bold text-slate-700">{item.q}</span>
                    <ChevronRight size={18} className={`text-slate-400 transition-transform ${openFaq === idx ? 'rotate-90' : ''}`} />
                  </div>
                  {openFaq === idx && (
                    <div className="p-4 pt-0 text-sm text-slate-500 leading-relaxed border-t border-gray-100/50 mt-1">
                      {item.a}
                    </div>
                  )}
                </div>
              ))}
            </div>
            <button onClick={() => toast('Opening full knowledge base...')} className="w-full mt-4 py-3 text-emerald-600 font-bold text-sm hover:bg-emerald-50 rounded-xl transition-colors">
              View All Topics
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}

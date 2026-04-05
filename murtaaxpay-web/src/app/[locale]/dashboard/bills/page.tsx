"use client";

import { Lightbulb, Droplets, Wifi, Smartphone, Loader2, Download, X } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function BillsPage() {
  const [selectedService, setSelectedService] = useState<string | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [selectedBillTx, setSelectedBillTx] = useState<any>(null);

  const services = [
    { id: 'power', name: 'Electricity', icon: Lightbulb, color: 'text-amber-500', bg: 'bg-amber-100', provider: 'BECO' },
    { id: 'water', name: 'Water Bill', icon: Droplets, color: 'text-blue-500', bg: 'bg-blue-100', provider: 'Mogadishu Water' },
    { id: 'internet', name: 'Internet', icon: Wifi, color: 'text-purple-500', bg: 'bg-purple-100', provider: 'Hormuud Fiber' },
    { id: 'airtime', name: 'Airtime', icon: Smartphone, color: 'text-emerald-500', bg: 'bg-emerald-100', provider: 'Mobile Top-up' },
  ];

  const handlePay = (e: React.FormEvent) => {
    e.preventDefault();
    setIsProcessing(true);
    toast.loading("Processing payment...", { id: "bill" });
    
    setTimeout(() => {
      setIsProcessing(false);
      setSelectedService(null);
      toast.success("Bill paid successfully!", { id: "bill" });
    }, 2000);
  };

  return (
    <div className="max-w-5xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      <div className="mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Bills & Airtime</h1>
        <p className="text-slate-500 mt-1">Pay your local utilities and recharge mobile airtime instantly.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        {services.map((svc) => (
          <div 
            key={svc.id}
            onClick={() => setSelectedService(svc.id)}
            className={`bg-white border rounded-[1.5rem] p-6 cursor-pointer transition-all hover:-translate-y-1 ${
              selectedService === svc.id ? 'border-emerald-500 shadow-md ring-2 ring-emerald-50' : 'border-gray-100 hover:shadow-sm'
            }`}
          >
            <div className={`w-14 h-14 ${svc.bg} ${svc.color} rounded-2xl flex items-center justify-center mb-4`}>
              <svc.icon size={26} />
            </div>
            <h3 className="font-bold text-[#0f172a] text-lg">{svc.name}</h3>
            <p className="text-slate-500 text-sm">{svc.provider}</p>
          </div>
        ))}
      </div>

      {selectedService && (
        <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm max-w-2xl mx-auto animate-in fade-in slide-in-from-bottom-4">
          <h2 className="text-xl font-bold text-[#0f172a] mb-6 border-b border-gray-100 pb-4">Pay {services.find(s => s.id === selectedService)?.name}</h2>
          
          <form onSubmit={handlePay} className="space-y-6">
            <div>
              <label className="block text-sm font-bold text-slate-700 mb-2">Account / Phone Number</label>
              <input type="text" required className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 px-4 focus:outline-none focus:ring-2 focus:ring-emerald-500" placeholder="Enter account details..." />
            </div>
            
            <div>
              <label className="block text-sm font-bold text-slate-700 mb-2">Amount (USD)</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <span className="font-bold text-slate-400">$</span>
                </div>
                <input type="number" step="0.01" required className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 pl-8 pr-4 font-bold text-[#0f172a] focus:outline-none focus:ring-2 focus:ring-emerald-500" placeholder="0.00" />
              </div>
            </div>

            <button 
              type="submit" 
              disabled={isProcessing}
              className="w-full bg-[#0f172a] hover:bg-[#1e293b] text-white py-4 rounded-xl font-bold text-lg transition-all shadow-lg flex items-center justify-center gap-2 disabled:opacity-80"
            >
              {isProcessing ? <><Loader2 size={24} className="animate-spin" /> Processing...</> : "Confirm Payment"}
            </button>
          </form>
        </div>
      )}

      {/* Recent Bills History */}
      <div className="mt-12 bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm">
        <div className="flex items-center justify-between mb-6 pb-4 border-b border-gray-100">
          <h3 className="text-lg font-bold text-[#0f172a]">Recent Bill Payments</h3>
          <button className="text-emerald-600 font-bold hover:underline text-sm">View Full History</button>
        </div>
        
        <div className="space-y-4">
          {[
            { name: "Hormuud Internet", ref: "INT-84920", date: "May 20, 2026", amount: "$30.00", status: "Paid", icon: Wifi, color: "text-purple-500", bg: "bg-purple-100" },
            { name: "BECO Electricity", ref: "PWR-11029", date: "May 15, 2026", amount: "$15.50", status: "Paid", icon: Lightbulb, color: "text-amber-500", bg: "bg-amber-100" },
            { name: "Mobile Top-up (Hormuud)", ref: "AIR-00214", date: "May 10, 2026", amount: "$5.00", status: "Paid", icon: Smartphone, color: "text-emerald-500", bg: "bg-emerald-100" },
          ].map((bill, idx) => (
            <div 
              key={idx} 
              onClick={() => setSelectedBillTx(bill)}
              className="flex items-center justify-between p-4 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors cursor-pointer group"
            >
              <div className="flex items-center gap-4">
                <div className={`w-12 h-12 rounded-full flex items-center justify-center ${bill.bg} ${bill.color}`}>
                  <bill.icon size={20} />
                </div>
                <div>
                  <p className="font-bold text-[#0f172a] text-sm group-hover:text-emerald-600 transition-colors">{bill.name}</p>
                  <p className="text-xs text-slate-500">{bill.date} • Ref: {bill.ref}</p>
                </div>
              </div>
              <div className="flex items-center gap-6">
                <div className="text-right">
                  <p className="font-bold text-[#0f172a]">{bill.amount}</p>
                  <p className="text-xs text-emerald-600 font-bold flex items-center justify-end gap-1 mt-0.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> {bill.status}
                  </p>
                </div>
                <button 
                  onClick={(e) => {
                    e.stopPropagation();
                    toast.success(`Downloading PDF receipt for ${bill.ref}...`);
                  }}
                  className="p-2 text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 rounded-lg transition-colors border border-transparent hover:border-emerald-100"
                  title="Download PDF Receipt"
                >
                  <Download size={18} />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Bill Receipt Modal */}
      {selectedBillTx && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white rounded-[2rem] w-full max-w-sm overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200" onClick={(e) => e.stopPropagation()}>
            <div className="p-6 bg-slate-50 border-b border-gray-100 flex justify-between items-center">
              <h3 className="font-bold text-[#0f172a]">Bill Receipt</h3>
              <button onClick={() => setSelectedBillTx(null)} className="p-2 text-slate-400 hover:text-slate-700 bg-white rounded-full shadow-sm hover:bg-gray-50 transition-colors">
                <X size={18} />
              </button>
            </div>
            
            <div className="p-8 text-center max-h-[80vh] overflow-y-auto">
              <div className={`w-16 h-16 rounded-full mx-auto flex items-center justify-center mb-4 border-[4px] border-white shadow-lg ${selectedBillTx.bg} ${selectedBillTx.color}`}>
                 <selectedBillTx.icon size={28} />
              </div>
              <h2 className={`text-3xl font-black mb-1 text-[#0f172a]`}>{selectedBillTx.amount}</h2>
              <p className="text-slate-500 font-medium mb-8">Paid to <strong className="text-[#0f172a]">{selectedBillTx.name}</strong></p>
              
              <div className="bg-slate-50 rounded-2xl p-5 space-y-4 text-left border border-gray-100">
                <div className="flex justify-between items-center border-b border-gray-200/50 pb-3">
                  <span className="text-sm font-medium text-slate-500">Status</span>
                  <span className="text-sm font-bold text-emerald-600 flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> {selectedBillTx.status}
                  </span>
                </div>
                <div className="flex justify-between items-center border-b border-gray-200/50 pb-3">
                  <span className="text-sm font-medium text-slate-500">Date</span>
                  <span className="text-sm font-bold text-[#0f172a]">{selectedBillTx.date}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm font-medium text-slate-500">Reference ID</span>
                  <span className="text-sm font-bold font-mono text-slate-700">{selectedBillTx.ref}</span>
                </div>
              </div>
              
              <button 
                 onClick={() => {
                   toast.success(`PDF receipt generated for ${selectedBillTx.ref}`);
                   setSelectedBillTx(null);
                 }}
                 className="w-full mt-8 bg-[#0f172a] hover:bg-[#1e293b] text-white py-4 rounded-xl font-bold flex items-center justify-center gap-2 transition-transform hover:-translate-y-0.5 shadow-xl shadow-slate-900/10"
              >
                <Download size={20} /> Download PDF
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}

"use client";

import { Search, Filter, ArrowUpRight, ArrowDownRight, Download, Loader2, X } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function HistoryPage() {
  const [isExporting, setIsExporting] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [selectedTx, setSelectedTx] = useState<any>(null);

  const handleExport = () => {
    setIsExporting(true);
    toast.loading("Compiling your statement...", { id: "export" });
    setTimeout(() => {
      setIsExporting(false);
      toast.success("Statement downloaded successfully as CSV.", { id: "export" });
    }, 1500);
  };

  const handleLoadMore = () => {
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      toast("Older transactions loaded.");
    }, 1000);
  };

  const allTransactions = [
    { id: 'TRX-101', name: "Amazon Web Services", date: "May 25, 2026 - 10:24 AM", amount: "-$45.00", type: "debit", status: "Completed" },
    { id: 'TRX-102', name: "Salary Deposit (Company)", date: "May 24, 2026 - 04:30 PM", amount: "+$4,850.00", type: "credit", status: "Completed" },
    { id: 'TRX-103', name: "Uber Ride", date: "May 23, 2026 - 09:15 AM", amount: "-$14.50", type: "debit", status: "Completed" },
    { id: 'TRX-104', name: "Transfer to Hasan A.", date: "May 22, 2026 - 08:00 PM", amount: "-$850.00", type: "debit", status: "Completed" },
    { id: 'TRX-105', name: "Hormuud Internet Bill", date: "May 20, 2026 - 11:10 AM", amount: "-$30.00", type: "debit", status: "Completed" },
    { id: 'TRX-106', name: "Refund from Apple", date: "May 18, 2026 - 02:20 PM", amount: "+$12.99", type: "credit", status: "Completed" },
    { id: 'TRX-107', name: "ATM Withdrawal", date: "May 15, 2026 - 01:00 PM", amount: "-$100.00", type: "debit", status: "Completed" },
    { id: 'TRX-108', name: "Money Received from UK", date: "May 10, 2026 - 08:45 AM", amount: "+$1,200.00", type: "credit", status: "Completed" },
  ];

  return (
    <div className="max-w-6xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      <div className="mb-8 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Transaction History</h1>
          <p className="text-slate-500 mt-1">Review all your past and pending activities.</p>
        </div>
        <button 
          onClick={handleExport}
          disabled={isExporting}
          className="bg-white border border-gray-200 text-slate-700 px-5 py-2.5 rounded-full font-bold hover:bg-slate-50 transition-colors flex items-center justify-center gap-2 shadow-sm text-sm disabled:opacity-70 min-w-[140px]"
        >
          {isExporting ? <Loader2 size={18} className="animate-spin" /> : <Download size={18} />} 
          {isExporting ? "Exporting..." : "Export CSV"}
        </button>
      </div>

      <div className="bg-white border border-gray-100 rounded-[2rem] overflow-hidden shadow-sm">
        
        {/* Toolbar */}
        <div className="p-6 border-b border-gray-100 flex flex-col md:flex-row gap-4 justify-between items-center bg-slate-50/50">
          <div className="relative w-full md:w-96">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input 
              type="text" 
              placeholder="Search by name, ID, or amount..." 
              className="w-full bg-white border border-gray-200 rounded-full py-2.5 pl-11 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>
          <div className="flex gap-3 w-full md:w-auto">
            <select className="bg-white border border-gray-200 text-slate-700 text-sm rounded-full px-4 py-2.5 outline-none cursor-pointer w-full md:w-auto">
              <option>All Types</option>
              <option>Credits (+)</option>
              <option>Debits (-)</option>
            </select>
            <select className="bg-white border border-gray-200 text-slate-700 text-sm rounded-full px-4 py-2.5 outline-none cursor-pointer w-full md:w-auto">
              <option>Last 30 Days</option>
              <option>Last 3 Months</option>
              <option>This Year</option>
            </select>
            <button onClick={() => toast("Advanced filters opened.")} className="bg-white border border-gray-200 text-slate-700 p-2.5 rounded-full hover:bg-slate-50 transition-colors flex-shrink-0">
              <Filter size={20} />
            </button>
          </div>
        </div>

        {/* Table/List */}
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                <th className="px-6 py-4 font-bold">Transaction</th>
                <th className="px-6 py-4 font-bold hidden md:table-cell">ID / Ref</th>
                <th className="px-6 py-4 font-bold hidden sm:table-cell">Date & Time</th>
                <th className="px-6 py-4 font-bold">Status</th>
                <th className="px-6 py-4 font-bold text-right">Amount</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {allTransactions.map((tx, idx) => (
                <tr 
                  key={idx} 
                  onClick={() => setSelectedTx(tx)}
                  className="hover:bg-slate-50/80 transition-colors cursor-pointer group"
                >
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-4">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${tx.type === 'credit' ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-100 text-slate-600'}`}>
                        {tx.type === 'credit' ? <ArrowDownRight size={18} /> : <ArrowUpRight size={18} />}
                      </div>
                      <p className="font-bold text-[#0f172a] text-sm group-hover:text-emerald-600 transition-colors">{tx.name}</p>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-xs font-mono text-slate-500 hidden md:table-cell">
                    {tx.id}
                  </td>
                  <td className="px-6 py-4 text-sm text-slate-500 hidden sm:table-cell">
                    {tx.date}
                  </td>
                  <td className="px-6 py-4">
                    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-100">
                      <div className="w-1.5 h-1.5 rounded-full bg-emerald-500"></div>
                      {tx.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-4">
                      <span className={`font-bold whitespace-nowrap ${tx.type === 'credit' ? 'text-emerald-600' : 'text-[#0f172a]'}`}>
                        {tx.amount}
                      </span>
                      <button 
                        onClick={(e) => {
                          e.stopPropagation();
                          toast.success(`PDF receipt generated for ${tx.id}`);
                        }}
                        className="text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 p-1.5 rounded-md transition-all"
                        title="Download PDF Receipt"
                      >
                        <Download size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

      </div>

      <div className="mt-6 text-center">
        <button 
          onClick={handleLoadMore}
          disabled={isLoading}
          className="text-emerald-600 font-bold text-sm hover:underline flex items-center justify-center gap-2 mx-auto disabled:opacity-50 disabled:no-underline"
        >
          {isLoading ? <><Loader2 size={16} className="animate-spin" /> Loading...</> : "Load More Transactions"}
        </button>
      </div>

      {/* Transaction Receipt Modal */}
      {selectedTx && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white rounded-[2rem] w-full max-w-sm overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200" onClick={(e) => e.stopPropagation()}>
            <div className="p-6 bg-slate-50 border-b border-gray-100 flex justify-between items-center">
              <h3 className="font-bold text-[#0f172a]">Transaction Receipt</h3>
              <button onClick={() => setSelectedTx(null)} className="p-2 text-slate-400 hover:text-slate-700 bg-white rounded-full shadow-sm hover:bg-gray-50 transition-colors">
                <X size={18} />
              </button>
            </div>
            
            <div className="p-8 text-center max-h-[80vh] overflow-y-auto">
              <div className={`w-16 h-16 rounded-full mx-auto flex items-center justify-center mb-4 border-[4px] border-white shadow-lg ${selectedTx.type === 'credit' ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-100 text-slate-600'}`}>
                 {selectedTx.type === 'credit' ? <ArrowDownRight size={28} /> : <ArrowUpRight size={28} />}
              </div>
              <h2 className={`text-3xl font-black mb-1 ${selectedTx.type === 'credit' ? 'text-emerald-600' : 'text-[#0f172a]'}`}>{selectedTx.amount}</h2>
              <p className="text-slate-500 font-medium mb-8">Paid to <strong className="text-[#0f172a]">{selectedTx.name}</strong></p>
              
              <div className="bg-slate-50 rounded-2xl p-5 space-y-4 text-left border border-gray-100">
                <div className="flex justify-between items-center border-b border-gray-200/50 pb-3">
                  <span className="text-sm font-medium text-slate-500">Status</span>
                  <span className="text-sm font-bold text-emerald-600 flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> {selectedTx.status}
                  </span>
                </div>
                <div className="flex justify-between items-center border-b border-gray-200/50 pb-3">
                  <span className="text-sm font-medium text-slate-500">Date & Time</span>
                  <span className="text-sm font-bold text-[#0f172a]">{selectedTx.date}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm font-medium text-slate-500">Reference ID</span>
                  <span className="text-sm font-bold font-mono text-slate-700">{selectedTx.id}</span>
                </div>
              </div>
              
              <button 
                 onClick={() => {
                   toast.success(`PDF receipt generated for ${selectedTx.id}`);
                   setSelectedTx(null);
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

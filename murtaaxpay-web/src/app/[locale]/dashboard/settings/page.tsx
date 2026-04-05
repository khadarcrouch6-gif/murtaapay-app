"use client";

import { User, Shield, Bell, HelpCircle, LogOut, CheckCircle2, Loader2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import { useRouter } from "next/navigation";

export default function SettingsPage() {
  const [isSaving, setIsSaving] = useState(false);
  const router = useRouter();

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    toast.loading("Saving your preferences...", { id: "save" });
    
    setTimeout(() => {
      setIsSaving(false);
      toast.success("Settings updated successfully!", { id: "save" });
    }, 1200);
  };

  return (
    <div className="max-w-5xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
      
      <div className="mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold text-[#0f172a]">Profile & Settings</h1>
        <p className="text-slate-500 mt-1">Manage your personal information and preferences.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* Left Col: Menu & Profile Summary */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm text-center">
            <div className="w-24 h-24 rounded-full bg-gradient-to-tr from-emerald-500 to-teal-400 text-white flex items-center justify-center font-bold text-3xl mx-auto mb-4 shadow-xl shadow-emerald-500/20 ring-4 ring-emerald-50">
              AH
            </div>
            <h2 className="text-xl font-bold text-[#0f172a]">Ali Hasan</h2>
            <p className="text-slate-500 mb-6">ali@example.com</p>
            <div className="bg-emerald-50 text-emerald-700 text-sm font-bold py-2 rounded-xl flex items-center justify-center gap-2 border border-emerald-100 mb-6">
              <CheckCircle2 size={16} /> Identity Verified
            </div>
          </div>

          <div className="bg-white border border-gray-100 rounded-[2rem] p-4 shadow-sm">
            <nav className="space-y-1">
              <a href="#" className="flex items-center gap-3 px-4 py-3 bg-emerald-50 text-emerald-700 rounded-xl font-bold transition-colors">
                <User size={20} /> Personal Info
              </a>
              <a href="#" className="flex items-center gap-3 px-4 py-3 text-slate-600 hover:bg-slate-50 rounded-xl font-medium transition-colors">
                <Shield size={20} /> Security & Passwords
              </a>
              <a href="#" className="flex items-center gap-3 px-4 py-3 text-slate-600 hover:bg-slate-50 rounded-xl font-medium transition-colors">
                <Bell size={20} /> Notifications
              </a>
              <a href="/dashboard/support" className="flex items-center gap-3 px-4 py-3 text-slate-600 hover:bg-slate-50 rounded-xl font-medium transition-colors">
                <HelpCircle size={20} /> Help & Support
              </a>
              <div className="h-px bg-gray-100 my-2 mx-4"></div>
              <button 
                onClick={() => {
                  toast.success('Signed out securely.');
                  router.push('/login');
                }}
                className="w-full flex items-center gap-3 px-4 py-3 text-red-500 hover:bg-red-50 rounded-xl font-bold transition-colors"
              >
                <LogOut size={20} /> Sign Out
              </button>
            </nav>
          </div>
        </div>

        {/* Right Col: Personal Info Form */}
        <div className="lg:col-span-2">
          <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm">
            <h3 className="text-xl font-bold text-[#0f172a] mb-6">Personal Information</h3>
            
            <form onSubmit={handleSave} className="space-y-6">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-2">First Name</label>
                  <input type="text" defaultValue="Ali" className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 px-4 focus:outline-none focus:ring-2 focus:ring-emerald-500 text-[#0f172a] font-medium" />
                </div>
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-2">Last Name</label>
                  <input type="text" defaultValue="Hasan" className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 px-4 focus:outline-none focus:ring-2 focus:ring-emerald-500 text-[#0f172a] font-medium" />
                </div>
              </div>

              <div>
                <label className="block text-sm font-bold text-slate-700 mb-2">Email Address</label>
                <input type="email" defaultValue="ali@example.com" disabled className="w-full bg-gray-100 border border-gray-200 rounded-xl py-3 px-4 text-slate-500 font-medium cursor-not-allowed" />
                <p className="text-xs text-slate-500 mt-2">Email cannot be changed directly. Contact support.</p>
              </div>

              <div>
                <label className="block text-sm font-bold text-slate-700 mb-2">Phone Number</label>
                <div className="flex">
                  <span className="inline-flex items-center px-4 rounded-l-xl border border-r-0 border-gray-200 bg-gray-50 text-slate-500 font-bold sm:text-sm">
                    +252
                  </span>
                  <input type="tel" defaultValue="61 000 0000" className="flex-1 min-w-0 block w-full px-4 py-3 rounded-none rounded-r-xl bg-slate-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-emerald-500 text-[#0f172a] font-medium" />
                </div>
              </div>

              <div>
                <label className="block text-sm font-bold text-slate-700 mb-2">Address</label>
                <textarea rows={3} defaultValue="Maka Al Mukarama Road, Mogadishu, Somalia" className="w-full bg-slate-50 border border-gray-200 rounded-xl py-3 px-4 focus:outline-none focus:ring-2 focus:ring-emerald-500 text-[#0f172a] font-medium resize-none" />
              </div>

              <div className="pt-4 border-t border-gray-100 flex justify-end">
                <button 
                  type="submit" 
                  disabled={isSaving}
                  className="bg-[#0f172a] hover:bg-[#1e293b] text-white px-8 py-3 rounded-full font-bold transition-all shadow-lg flex items-center gap-2 hover:-translate-y-0.5 disabled:opacity-80 disabled:hover:translate-y-0 min-w-[160px] justify-center"
                >
                  {isSaving ? <Loader2 size={20} className="animate-spin" /> : "Save Changes"}
                </button>
              </div>
            </form>
          </div>
        </div>

      </div>

    </div>
  );
}

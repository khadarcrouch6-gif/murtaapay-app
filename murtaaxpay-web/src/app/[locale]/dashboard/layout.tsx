"use client";

import { useTranslations } from "next-intl";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, ArrowLeftRight, CreditCard, Activity, Settings, Bell, Search, LogOut, Wallet, Receipt, LifeBuoy, X, LayoutGrid } from "lucide-react";
import Image from "next/image";
import { toast } from "sonner";
import { useState } from "react";
import { Link } from "@/i18n/routing";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const t = useTranslations("Dashboard");
  const [showNotifications, setShowNotifications] = useState(false);
  const [selectedNotif, setSelectedNotif] = useState<any>(null);
  
  const [notifications, setNotifications] = useState([
    { id: 1, title: "Incoming Transfer 💰", desc: "You received $1,200.00 from Abdi Ali via EVC Plus.", time: "Just now", read: false },
    { id: 2, title: "Security Alert 🛡️", desc: "New login block from unknown device in Dubai.", time: "4 hours ago", read: false },
    { id: 3, title: "Limits Increased 🚀", desc: "Your passport verification was successful. Enjoy $5,000 limits.", time: "Yesterday", read: false }
  ]);

  const unreadCount = notifications.filter(n => !n.read).length;

  const markAllAsRead = () => {
    setNotifications(notifications.map(n => ({ ...n, read: true })));
    setShowNotifications(false);
  };

  const readNotification = (id: number) => {
    setNotifications(notifications.map(n => n.id === id ? { ...n, read: true } : n));
  };

  const navigation = [
    { name: t('nav.overview'), href: "/dashboard", icon: LayoutDashboard },
    { name: t('nav.transfers'), href: "/dashboard/transfers", icon: ArrowLeftRight },
    { name: t('nav.wallet'), href: "/dashboard/wallet", icon: Wallet },
    { name: t('nav.bills'), href: "/dashboard/bills", icon: Receipt },
    { name: t('nav.cards'), href: "/dashboard/cards", icon: CreditCard },
    { name: t('nav.history'), href: "/dashboard/history", icon: Activity },
    { name: t('nav.more'), href: "/dashboard/more", icon: LayoutGrid },
    { name: t('nav.settings'), href: "/dashboard/settings", icon: Settings },
    { name: t('nav.support'), href: "/dashboard/support", icon: LifeBuoy },
  ];

  return (
    <div className="min-h-screen bg-[#f4f7fb] flex">
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex w-72 flex-col bg-white border-r border-gray-100 z-10 shadow-sm relative">
        <div className="p-6">
          <Link href="/dashboard" className="flex items-center gap-2 mb-10 hover:opacity-80 transition-opacity">
            <Image src="/images/weblogo.png" alt="MurtaaxPay Logo" width={160} height={40} className="h-8 w-auto" />
          </Link>

          <nav className="flex-1 space-y-2">
            {navigation.map((item) => {
              const isActive = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`flex items-center gap-3 px-4 py-3.5 rounded-xl font-medium transition-all ${
                    isActive
                       ? "bg-emerald-50 text-emerald-700 shadow-sm"
                       : "text-slate-500 hover:bg-slate-50 hover:text-slate-900"
                  }`}
                >
                  <item.icon size={20} className={isActive ? "text-emerald-600" : "text-slate-400"} />
                  {item.name}
                </Link>
              );
            })}
          </nav>
        </div>

        <div className="mt-auto p-6 border-t border-gray-100">
          <div 
            onClick={() => toast.info('Redirecting to KYC verification process...')}
            className="bg-slate-50 rounded-2xl p-4 border border-gray-100 mb-4 cursor-pointer hover:bg-slate-100 transition-colors"
          >
            <p className="text-xs text-slate-500 font-bold uppercase mb-1">{t('verifyIdentity')}</p>
            <p className="text-sm text-[#0f172a] font-medium mb-3">{t('increaseLimits')}</p>
            <div className="w-full bg-gray-200 rounded-full h-1.5 mb-2">
              <div className="bg-emerald-500 h-1.5 rounded-full" style={{ width: '40%' }}></div>
            </div>
          </div>
          <button 
            onClick={() => {
              toast.success('Signed out securely.');
              router.push('/login');
            }}
            className="w-full flex items-center gap-3 px-4 py-3 text-red-500 hover:bg-red-50 rounded-xl transition-colors font-medium"
          >
            <LogOut size={20} />
            {t('signOut')}
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col relative min-h-screen overflow-hidden">
        {/* Top Header */}
        <header className="h-20 bg-white/80 backdrop-blur-md border-b border-gray-100 flex items-center justify-between px-8 sticky top-0 z-20">
          
          <div className="flex-1 max-w-xl">
            <div className="relative group">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5 group-focus-within:text-emerald-500 transition-colors" />
              <input 
                type="text" 
                placeholder={t('searchPlaceholder')}
                className="w-full bg-slate-50 border border-gray-200 rounded-full py-2.5 pl-11 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all shadow-sm"
              />
            </div>
          </div>

          <div className="flex items-center gap-6 ml-8">
            <div className="relative">
              <button 
                onClick={() => setShowNotifications(!showNotifications)} 
                className="relative p-2 text-slate-400 hover:text-slate-700 transition-colors rounded-full hover:bg-slate-50"
              >
                <Bell size={22} />
                {unreadCount > 0 && (
                  <span className="absolute top-1.5 right-1.5 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white"></span>
                )}
              </button>

              {/* Notifications Dropdown */}
              {showNotifications && (
                <>
                  <div className="fixed inset-0 z-40" onClick={() => setShowNotifications(false)}></div>
                  <div className="absolute right-0 mt-3 w-80 bg-white border border-gray-100 rounded-2xl shadow-2xl z-50 overflow-hidden animate-in fade-in slide-in-from-top-2 duration-200">
                    <div className="p-4 border-b border-gray-100 flex justify-between items-center bg-slate-50">
                      <h4 className="font-bold text-[#0f172a]">{t('notifications')}</h4>
                      {unreadCount > 0 && (
                        <span className="text-xs font-bold text-emerald-600 bg-emerald-100 px-2.5 py-1 rounded-full">{unreadCount} {t('newNotifs')}</span>
                      )}
                    </div>
                    <div className="max-h-80 overflow-y-auto">
                      {notifications.map((notif) => (
                        <div 
                          key={notif.id}
                          onClick={() => {
                            readNotification(notif.id);
                            setSelectedNotif(notif);
                            setShowNotifications(false);
                          }}
                          className={`p-4 border-b border-gray-50 hover:bg-slate-50 transition-colors cursor-pointer ${notif.read ? 'bg-white' : 'bg-emerald-50/30 relative'}`}
                        >
                          {!notif.read && <div className="absolute left-2 top-1/2 -translate-y-1/2 w-1.5 h-1.5 bg-emerald-500 rounded-full"></div>}
                          <p className={`text-sm mb-1 ${notif.read ? 'font-medium text-slate-700' : 'font-bold text-[#0f172a]'}`}>{notif.title}</p>
                          <p className="text-xs text-slate-600 leading-relaxed">{notif.desc}</p>
                          <p className="text-[10px] text-slate-400 mt-2 font-medium uppercase tracking-wider">{notif.time}</p>
                        </div>
                      ))}
                    </div>
                    {unreadCount > 0 && (
                      <div 
                        onClick={() => {
                          markAllAsRead();
                          toast("All notifications marked as read.");
                        }} 
                        className="p-3 text-center border-t border-gray-100 bg-slate-50 hover:bg-slate-100 cursor-pointer transition-colors"
                      >
                        <span className="text-xs font-bold text-emerald-600">{t('markRead')}</span>
                      </div>
                    )}
                  </div>
                </>
              )}
            </div>

            <div className="h-8 w-[1px] bg-gray-200"></div>
            <div 
              onClick={() => router.push('/dashboard/settings')}
              className="flex items-center gap-3 cursor-pointer group"
            >
              <div className="text-right hidden sm:block">
                <p className="text-sm font-bold text-[#0f172a] group-hover:text-emerald-600 transition-colors">Ali Hasan</p>
                <p className="text-xs text-slate-500">{t('freePlan')}</p>
              </div>
              <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-emerald-500 to-teal-400 text-white flex items-center justify-center font-bold shadow-md ring-2 ring-white">
                AH
              </div>
            </div>
          </div>
        </header>

        {/* Dynamic Page Content */}
        <div className="flex-1 overflow-auto p-4 sm:p-8">
          {children}
        </div>
      </main>
      
      {/* Mobile Bottom Navigation (optional but good for PWA) */}
      <div className="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-gray-100 flex justify-around p-3 z-50 pb-safe">
        {navigation.slice(0, 4).map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link key={item.href} href={item.href} className={`flex flex-col items-center p-2 rounded-lg ${isActive ? "text-emerald-600" : "text-slate-400"}`}>
              <item.icon size={24} />
              <span className="text-[10px] mt-1 font-medium">{item.name}</span>
            </Link>
          );
        })}
      </div>

      {/* Notification Detail Modal */}
      {selectedNotif && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white rounded-[2rem] w-full max-w-sm overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200" onClick={(e) => e.stopPropagation()}>
            <div className="p-6 bg-slate-50 border-b border-gray-100 flex justify-between items-center">
              <h3 className="font-bold text-[#0f172a]">{t('notifications')}</h3>
              <button onClick={() => setSelectedNotif(null)} className="p-2 text-slate-400 hover:text-slate-700 bg-white rounded-full shadow-sm hover:bg-gray-50 transition-colors">
                <X size={18} />
              </button>
            </div>
            
            <div className="p-8 text-center pt-10 pb-10">
              <div className="w-16 h-16 rounded-full mx-auto flex items-center justify-center mb-6 bg-emerald-100 text-3xl shadow-inner border-[4px] border-white">
                {selectedNotif.title.includes('Transfer') ? '💰' : selectedNotif.title.includes('Security') ? '🛡️' : '🚀'}
              </div>
              <h2 className="text-xl font-bold text-[#0f172a] mb-2">{selectedNotif.title.replace(/💰|🛡️|🚀/g, '').trim()}</h2>
              <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mb-6">{selectedNotif.time}</p>
              
              <div className="bg-slate-50 border border-gray-100 p-6 rounded-2xl text-left relative overflow-hidden">
                <div className="absolute top-0 left-0 w-1 h-full bg-emerald-500"></div>
                <p className="text-slate-600 leading-relaxed text-sm">
                  {selectedNotif.desc}
                </p>
              </div>
              
              <button 
                 onClick={() => setSelectedNotif(null)}
                 className="w-full mt-8 bg-[#0f172a] hover:bg-[#1e293b] text-white py-3.5 rounded-xl font-bold transition-transform hover:-translate-y-0.5 shadow-xl shadow-slate-900/10 hover:shadow-slate-900/20"
              >
                {t('close')}
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}

import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { 
  HandCoins, 
  TrendingUp, 
  PiggyBank, 
  Briefcase, 
  HeartHandshake, 
  Ticket, 
  Users, 
  Gift,
  ShieldCheck,
  Zap
} from "lucide-react";
import { notFound } from "next/navigation";
import { getTranslations } from "next-intl/server";

const iconMap: Record<string, any> = {
  "request": <HandCoins className="text-emerald-500" size={48} />,
  "exchange": <TrendingUp className="text-blue-500" size={48} />,
  "savings": <PiggyBank className="text-indigo-500" size={48} />,
  "investments": <Briefcase className="text-teal-500" size={48} />,
  "sadaqah": <HeartHandshake className="text-rose-500" size={48} />,
  "giftcards": <Gift className="text-amber-500" size={48} />,
  "refer": <Users className="text-cyan-500" size={48} />,
  "vouchers": <Ticket className="text-purple-500" size={48} />,
};

export default async function ServiceDetailPage({ params }: { params: Promise<{ slug: string, locale: string }> }) {
  const { slug, locale } = await params;
  const t = await getTranslations({ locale, namespace: "Services" });

  // Use a try-catch or check if the key exists to avoid crash
  let title = "";
  try {
     title = t(`${slug}.title`);
  } catch (e) {
     notFound();
  }

  if (!title || title === `Services.${slug}.title`) {
    notFound();
  }

  const icon = iconMap[slug] || <ShieldCheck className="text-emerald-500" size={48} />;
  const description = t(`${slug}.description`);
  const content = t(`${slug}.content`);
  
  // Handling array translations in next-intl can be tricky with t.raw or just manual keys
  // For simplicity and since we know there are 3 features:
  const features = t.raw(`${slug}.features`) as string[];

  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      
      {/* Hero */}
      <section className="pt-32 pb-20 px-4 bg-slate-50 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-emerald-100/30 rounded-full blur-[100px] pointer-events-none" />
        <div className="max-w-4xl mx-auto relative z-10 text-center">
            <div className="inline-flex p-4 bg-white rounded-3xl shadow-xl shadow-slate-200/50 border border-slate-100 mb-8">
                {icon}
            </div>
            <h1 className="text-4xl md:text-6xl font-black text-[#0f172a] mb-6 capitalize">{title}</h1>
            <p className="text-xl text-emerald-600 font-bold mb-4">{description}</p>
            <p className="text-lg text-slate-500 leading-relaxed max-w-2xl mx-auto">{content}</p>
        </div>
      </section>

      {/* Features */}
      <section className="py-24 px-4">
        <div className="max-w-7xl mx-auto">
            <h2 className="text-3xl font-bold text-center mb-16 underline decoration-emerald-500 decoration-4 underline-offset-8">{t('keyCapabilities')}</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {features.map((feature: string, idx: number) => (
                    <div key={idx} className="p-8 rounded-3xl bg-white border border-slate-100 hover:border-emerald-200 hover:shadow-xl hover:shadow-emerald-50 transition-all text-center">
                        <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto mb-6">
                            <ShieldCheck size={24} />
                        </div>
                        <h4 className="text-xl font-black text-[#0f172a] mb-2">{feature}</h4>
                        <p className="text-slate-500 text-sm">{t('capabilityDesc', { service: title })}</p>
                    </div>
                ))}
            </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-24 bg-emerald-600 text-white">
        <div className="max-w-4xl mx-auto px-4 text-center">
            <Zap className="mx-auto mb-8 text-emerald-200" size={48} />
            <h2 className="text-4xl font-black mb-6 tracking-tight">{t('ctaTitle', { service: title })}</h2>
            <p className="text-xl text-emerald-50 mb-10 opacity-80">{t('ctaDesc', { service: title })}</p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <a href="/signup" className="px-10 py-5 bg-[#0f172a] hover:bg-black text-white font-black rounded-2xl transition-all shadow-xl">
                    {t('ctaPrimary')}
                </a>
                <a href="/services" className="px-10 py-5 bg-white text-emerald-600 font-black rounded-2xl transition-all border-2 border-transparent hover:border-emerald-200">
                    {t('viewAll')}
                </a>
            </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}

import Navbar from "@/components/Navbar";
import HeroSection from "@/components/HeroSection";
import PartnersCarousel from "@/components/PartnersCarousel";
import FeaturesGrid from "@/components/FeaturesGrid";
import VirtualCardSection from "@/components/VirtualCardSection";
import PaySecureDashboard from "@/components/PaySecureDashboard";
import AddFundsSection from "@/components/AddFundsSection";
import BenefitsList from "@/components/BenefitsList";
import SecurityDNA from "@/components/SecurityDNA";
import Testimonials from "@/components/Testimonials";
import CtaBanner from "@/components/CtaBanner";
import Footer from "@/components/Footer";
import AboutSection from "@/components/AboutSection";
import ServicesSection from "@/components/ServicesSection";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col font-sans">
      <Navbar />
      <main className="flex-1">
        <HeroSection />
        <AboutSection />
        <ServicesSection />
        <PartnersCarousel />
        <FeaturesGrid />
        <VirtualCardSection />
        <PaySecureDashboard />
        <AddFundsSection />
        <BenefitsList />
        <SecurityDNA />
        <Testimonials />
        <CtaBanner />
      </main>
      <Footer />
    </div>
  );
}

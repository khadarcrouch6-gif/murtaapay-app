<x-filament-widgets::widget>
    <x-filament::section class="overflow-hidden !border-none !bg-transparent !p-0 shadow-none">
        <div class="relative overflow-hidden rounded-[2rem] bg-gradient-to-br from-teal-600 via-teal-500 to-emerald-400 p-8 shadow-2xl shadow-teal-500/20 dark:from-slate-900 dark:via-teal-900/40 dark:to-emerald-900/20">
            <!-- Glassmorphism Orbs -->
            <div class="absolute -right-20 -top-20 h-64 w-64 rounded-full bg-white/10 blur-3xl"></div>
            <div class="absolute -bottom-20 -left-20 h-64 w-64 rounded-full bg-emerald-300/10 blur-3xl"></div>

            <div class="relative flex flex-col gap-y-6 lg:flex-row lg:items-center lg:justify-between">
                <div class="flex-1">
                    <div class="flex items-center gap-x-3 text-white/80">
                        <x-heroicon-o-clock class="h-5 w-5 animate-pulse" />
                        <span class="text-sm font-medium uppercase tracking-widest text-teal-50">
                            {{ $this->getGreeting() }} — MurtaaxPay HQ
                        </span>
                    </div>
                    <h1 class="mt-2 text-4xl font-black tracking-tight text-white lg:text-5xl">
                        Elite Management <span class="text-white/70">Console</span>
                    </h1>
                    <p class="mt-4 max-w-xl text-lg font-medium leading-relaxed text-teal-50/80">
                        Halkan ayaad ka xakamayn kartaa xawaaladaha Yurub iyo Soomaaliya. Hubi liquidity-ga, adjust-garee rates-ka, oo ansixi KYC-yada cusub.
                    </p>
                </div>

                <div class="flex shrink-0 flex-wrap gap-4 lg:flex-col lg:items-end">
                    <a href="{{ route('filament.admin.resources.fx-rates.index') }}" 
                       class="flex items-center gap-x-2 rounded-2xl bg-white/20 px-6 py-3 text-sm font-bold text-white backdrop-blur-md transition-all hover:bg-white/30 hover:scale-105 active:scale-95 shadow-lg">
                        <x-heroicon-o-bolt class="h-5 w-5" />
                        Adjust FX Rates
                    </a>
                    <a href="{{ route('filament.admin.resources.kyc-verifications.index') }}" 
                       class="flex items-center gap-x-2 rounded-2xl bg-white px-6 py-3 text-sm font-black text-teal-600 shadow-xl transition-all hover:bg-teal-50 hover:scale-105 active:scale-95">
                        <x-heroicon-o-shield-check class="h-5 w-5" />
                        Review 5 Pendings
                    </a>
                </div>
            </div>
            
            <!-- Quick Stats Ticker -->
            <div class="mt-8 grid grid-cols-2 gap-4 border-t border-white/10 pt-8 sm:grid-cols-4 lg:grid-cols-4">
                <div class="flex flex-col">
                    <span class="text-xs font-bold uppercase tracking-widest text-white/50">System Status</span>
                    <span class="mt-1 flex items-center gap-x-2 font-bold text-white">
                        <span class="h-2 w-2 animate-ping rounded-full bg-emerald-400"></span>
                        Operational
                    </span>
                </div>
                <div class="flex flex-col border-l border-white/10 pl-4 lg:pl-8">
                    <span class="text-xs font-bold uppercase tracking-widest text-white/50">Today's Volume</span>
                    <span class="mt-1 font-bold text-white">$4,289.00</span>
                </div>
                <div class="flex flex-col border-l border-white/10 pl-4 lg:pl-8">
                    <span class="text-xs font-bold uppercase tracking-widest text-white/50">Success Rate</span>
                    <span class="mt-1 font-bold text-white">99.8%</span>
                </div>
                <div class="flex flex-col border-l border-white/10 pl-4 lg:pl-8">
                    <span class="text-xs font-bold uppercase tracking-widest text-white/50">EUR Reserve</span>
                    <span class="mt-1 font-bold text-white">€12,500</span>
                </div>
            </div>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>

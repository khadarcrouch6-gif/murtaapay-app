<x-filament-panels::page>
<div id="control-panel-wrapper">
<style>
.cp-header {
    background: linear-gradient(135deg, #002147 0%, #003370 60%, #0D9488 100%);
    border-radius: 16px;
    padding: 32px 36px;
    color: white;
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 28px;
    position: relative;
    overflow: hidden;
}
.cp-header::before {
    content: '';
    position: absolute;
    top: -40px; right: -40px;
    width: 180px; height: 180px;
    background: rgba(255,255,255,0.04);
    border-radius: 50%;
}
.cp-header::after {
    content: '';
    position: absolute;
    bottom: -60px; right: 100px;
    width: 240px; height: 240px;
    background: rgba(13,148,136,0.15);
    border-radius: 50%;
}
.cp-header-title { font-size: 26px; font-weight: 800; letter-spacing: -0.5px; }
.cp-header-sub   { font-size: 13px; color: rgba(255,255,255,0.65); margin-top: 4px; }

.cp-status-pill {
    display: inline-flex; align-items: center; gap: 8px;
    background: rgba(255,255,255,0.12);
    backdrop-filter: blur(6px);
    border: 1px solid rgba(255,255,255,0.2);
    border-radius: 999px;
    padding: 8px 16px;
    font-size: 12px; font-weight: 700; color: white;
    z-index: 1; position: relative;
}

.cp-dot-green { width: 8px; height: 8px; border-radius: 50%; background: #4ade80; box-shadow: 0 0 0 3px rgba(74,222,128,0.25); flex-shrink:0; }
.cp-dot-red { width: 8px; height: 8px; border-radius: 50%; background: #ef4444; box-shadow: 0 0 0 3px rgba(239,68,68,0.25); flex-shrink:0; animation: pulse-red 2s infinite; }

@keyframes pulse-red {
    0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); }
    70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(239, 68, 68, 0); }
    100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
}

.cp-section-label {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.09em;
    text-transform: uppercase;
    color: #94a3b8;
    margin: 24px 0 12px;
    padding-left: 4px;
}

.cp-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 16px;
}

.cp-card {
    background: white;
    border-radius: 14px;
    padding: 22px;
    border: 1px solid #f1f5f9;
    box-shadow: 0 1px 4px rgba(0,0,0,0.05);
    display: flex;
    align-items: flex-start;
    gap: 16px;
    cursor: pointer;
    transition: all 0.2s ease;
    text-decoration: none;
    color: inherit;
    position: relative;
    overflow: hidden;
}
.dark .cp-card { background: #1e293b; border-color: rgba(255,255,255,0.07); }
.cp-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0,0,0,0.1);
    border-color: #14b8a6;
}
.dark .cp-card:hover { border-color: #0d9488; box-shadow: 0 8px 24px rgba(0,0,0,0.35); }

.cp-card-accent {
    position: absolute;
    top: 0; left: 0;
    width: 4px; height: 100%;
    border-radius: 14px 0 0 14px;
    background: linear-gradient(180deg, #14b8a6, #002147);
    opacity: 0;
    transition: opacity 0.2s;
}
.cp-card:hover .cp-card-accent { opacity: 1; }

.cp-icon-wrap {
    width: 46px; height: 46px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}

.cp-card-title {
    font-size: 14px;
    font-weight: 700;
    color: #0f172a;
    margin-bottom: 4px;
}
.dark .cp-card-title { color: #f1f5f9; }

.cp-card-desc {
    font-size: 12px;
    color: #94a3b8;
    line-height: 1.55;
}

.cp-card-link {
    margin-top: 14px;
    font-size: 12px;
    font-weight: 700;
    color: #0d9488;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    transition: gap 0.15s;
}
.cp-card:hover .cp-card-link { gap: 8px; }

.cp-quick-bar {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
    margin-bottom: 24px;
}
.cp-quick-item {
    background: white;
    border: 1px solid #f1f5f9;
    border-radius: 12px;
    padding: 16px 18px;
    display: flex;
    align-items: center;
    gap: 12px;
}
.dark .cp-quick-item { background: #1e293b; border-color: rgba(255,255,255,0.07); }
.cp-quick-label { font-size: 11px; color: #94a3b8; font-weight: 600; }
.cp-quick-value { font-size: 18px; font-weight: 800; color: #0f172a; margin-top: 2px; }
.dark .cp-quick-value { color: #f1f5f9; }
</style>

{{-- ── HEADER ─────────────────────────────────────────────────────────────── --}}
<div class="cp-header">
    <div style="z-index:1; position:relative;">
        <div class="cp-header-title">⚙️ {{ $site_name }} Control Panel</div>
        <div class="cp-header-sub">Configure all {{ $site_name }} platform settings from one place.</div>
    </div>
    <div class="cp-status-pill" style="{{ $maintenance_mode == '1' ? 'background:rgba(239,68,68,0.15); border-color:rgba(239,68,68,0.3);' : '' }}">
        <div class="{{ $maintenance_mode == '1' ? 'cp-dot-red' : 'cp-dot-green' }}"></div>
        {{ $maintenance_mode == '1' ? 'System in Maintenance' : 'System Operational' }}
    </div>
</div>

{{-- ── QUICK STATS ──────────────────────────────────────────────────────────── --}}
<div class="cp-quick-bar">
    <div class="cp-quick-item">
        <div style="width:38px;height:38px;border-radius:10px;background:#e0fdf4;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#14b8a6" style="width:18px;height:18px"><path fill-rule="evenodd" d="M4.5 3.75a3 3 0 0 0-3 3v.75h21v-.75a3 3 0 0 0-3-3h-15Z"/><path fill-rule="evenodd" d="M22.5 9.75h-21v7.5a3 3 0 0 0 3 3h15a3 3 0 0 0 3-3v-7.5Zm-18 3.75a.75.75 0 0 1 .75-.75h6a.75.75 0 0 1 0 1.5h-6a.75.75 0 0 1-.75-.75Zm.75 2.25a.75.75 0 0 0 0 1.5h3a.75.75 0 0 0 0-1.5h-3Z" clip-rule="evenodd"/></svg>
        </div>
        <div>
            <div class="cp-quick-label">Base Currency</div>
            <div class="cp-quick-value">{{ $default_currency }}</div>
        </div>
    </div>
    <div class="cp-quick-item">
        <div style="width:38px;height:38px;border-radius:10px;background:#ede9fe;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#8b5cf6" style="width:18px;height:18px"><path fill-rule="evenodd" d="M12 1.5a5.25 5.25 0 0 0-5.25 5.25v3a3 3 0 0 0-3 3v6.75a3 3 0 0 0 3 3h10.5a3 3 0 0 0 3-3v-6.75a3 3 0 0 0-3-3v-3c0-2.9-2.35-5.25-5.25-5.25Zm3.75 8.25v-3a3.75 3.75 0 1 0-7.5 0v3h7.5Z" clip-rule="evenodd"/></svg>
        </div>
        <div>
            <div class="cp-quick-label">Software Version</div>
            <div class="cp-quick-value">v{{ $app_version }}</div>
        </div>
    </div>
    <div class="cp-quick-item">
        <div style="width:38px;height:38px;border-radius:10px;background:{{ $maintenance_mode == '1' ? '#fef2f2' : '#fef3c7' }};display:flex;align-items:center;justify-content:center;flex-shrink:0;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="{{ $maintenance_mode == '1' ? '#ef4444' : '#f59e0b' }}" style="width:18px;height:18px"><path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"/><path fill-rule="evenodd" d="M1.323 11.447C2.811 6.976 7.028 3.75 12.001 3.75c4.97 0 9.185 3.223 10.675 7.69.12.362.12.752 0 1.113-1.487 4.471-5.705 7.697-10.677 7.697-4.97 0-9.186-3.223-10.675-7.69a1.762 1.762 0 0 1 0-1.113ZM17.25 12a5.25 1.1 1-10.5 0 5.25 5.25 0 0 1 10.5 0Z" clip-rule="evenodd"/></svg>
        </div>
        <div>
            <div class="cp-quick-label">Maintenance Mode</div>
            <div class="cp-quick-value" style="font-size:14px;color:{{ $maintenance_mode == '1' ? '#ef4444' : '#16a34a' }};">
                {{ $maintenance_mode == '1' ? 'ACTIVE ⚠️' : 'OFF ✓' }}
            </div>
        </div>
    </div>
</div>

{{-- ── WEBSITE MANAGEMENT ─────────────────────────────────────────────────── --}}
<div class="cp-section-label">🌐 Website Management (CMS)</div>
<div class="cp-grid">
    @foreach([
        [
            'title' => 'Hero & Landing',
            'desc'  => 'Manage the main home page title, subtitle, and CTA buttons in all languages.',
            'icon'  => 'heroicon-o-sparkles',
            'color' => '#fff7ed', 'icon_color' => '#f97316',
            'link'  => route('filament.admin.pages.website-hero-settings'),
            'badge' => 'Active',
        ],
        [
            'title' => 'Services Settings',
            'desc'  => 'Enable / disable transfer, request, exchange & bill payment services.',
            'icon'  => 'heroicon-o-squares-2x2',
            'color' => '#f0f9ff', 'icon_color' => '#0ea5e9',
            'link'  => route('filament.admin.pages.services-settings'),
            'badge' => '8 Active',
        ],
        [
            'title' => 'Branding & Logo',
            'desc'  => 'Update site logo, admin logo, app icon, and favicon.',
            'icon'  => 'heroicon-o-photo',
            'color' => '#f0fdf4', 'icon_color' => '#16a34a',
            'link'  => route('filament.admin.pages.branding-settings'),
            'badge' => null,
        ],
    ] as $card)
    <a href="{{ $card['link'] }}" class="cp-card">
        <div class="cp-card-accent"></div>
        <div class="cp-icon-wrap" style="background:{{ $card['color'] }}">
            @svg($card['icon'], 'w-5 h-5', ['style' => 'color:' . $card['icon_color']])
        </div>
        <div style="flex:1;">
            <div style="display:flex;align-items:center;gap:8px;">
                <div class="cp-card-title">{{ $card['title'] }}</div>
                @if($card['badge'])
                <span style="font-size:10px;font-weight:700;background:{{ $card['color'] }};color:{{ $card['icon_color'] }};padding:1px 8px;border-radius:999px;">{{ $card['badge'] }}</span>
                @endif
            </div>
            <div class="cp-card-desc">{{ $card['desc'] }}</div>
            <div class="cp-card-link">
                Manage Content
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:14px;height:14px"><path fill-rule="evenodd" d="M3 10a.75.75 0 0 1 .75-.75h10.638L10.23 5.29a.75.75 0 1 1 1.04-1.08l5.5 5.25a.75.75 0 0 1 0 1.08l-5.5 5.25a.75.75 0 1 1-1.04-1.08l4.158-3.96H3.75A.75.75 0 0 1 3 10Z" clip-rule="evenodd"/></svg>
            </div>
        </div>
    </a>
    @endforeach
</div>

{{-- ── CORE SETTINGS ────────────────────────────────────────────────────────── --}}
<div class="cp-section-label">🏛️ Platform Core</div>
<div class="cp-grid">
    @foreach([
        [
            'title' => 'Basic Control',
            'desc'  => 'Site title, timezone, language, currency defaults, notification settings.',
            'icon'  => 'heroicon-o-adjustments-horizontal',
            'color' => '#e0f2fe', 'icon_color' => '#0ea5e9',
            'link'  => route('filament.admin.pages.basic-control-settings'),
            'badge' => null,
        ],
        [
            'title' => 'Currencies & FX',
            'desc'  => 'Configure supported currencies, set charges & transaction limits.',
            'icon'  => 'heroicon-o-currency-dollar',
            'color' => '#fef3c7', 'icon_color' => '#f59e0b',
            'link'  => route('filament.admin.resources.fx-rates.index'),
            'badge' => null,
        ],
        [
            'title' => 'Charge & Fees',
            'desc'  => 'Show and edit charges & limits for deposits, withdrawals, and transfers.',
            'icon'  => 'heroicon-o-scale',
            'color' => '#fdf2f8', 'icon_color' => '#ec4899',
            'link'  => route('filament.admin.resources.fee-settings.index'),
            'badge' => null,
        ],
    ] as $card)
    <a href="{{ $card['link'] }}" class="cp-card">
        <div class="cp-card-accent"></div>
        <div class="cp-icon-wrap" style="background:{{ $card['color'] }}">
            @svg($card['icon'], 'w-5 h-5', ['style' => 'color:' . $card['icon_color']])
        </div>
        <div style="flex:1;">
            <div style="display:flex;align-items:center;gap:8px;">
                <div class="cp-card-title">{{ $card['title'] }}</div>
                @if($card['badge'])
                <span style="font-size:10px;font-weight:700;background:#e0fdf4;color:#0d9488;padding:1px 8px;border-radius:999px;">{{ $card['badge'] }}</span>
                @endif
            </div>
            <div class="cp-card-desc">{{ $card['desc'] }}</div>
            <div class="cp-card-link">
                Configure
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:14px;height:14px"><path fill-rule="evenodd" d="M3 10a.75.75 0 0 1 .75-.75h10.638L10.23 5.29a.75.75 0 1 1 1.04-1.08l5.5 5.25a.75.75 0 0 1 0 1.08l-5.5 5.25a.75.75 0 1 1-1.04-1.08l4.158-3.96H3.75A.75.75 0 0 1 3 10Z" clip-rule="evenodd"/></svg>
            </div>
        </div>
    </a>
    @endforeach
</div>

{{-- ── PAYMENT & INFRA ──────────────────────────────────────────────────────── --}}
<div class="cp-section-label">💳 Payments & Infrastructure</div>
<div class="cp-grid">
    @foreach([
        [
            'title' => 'Virtual Card',
            'desc'  => 'Virtual Wallester card settings: issuance fees, limits & KYC.',
            'icon'  => 'heroicon-m-credit-card',
            'color' => '#ede9fe', 'icon_color' => '#8b5cf6',
            'link'  => route('filament.admin.pages.virtual-card-settings'),
            'badge' => 'Wallester',
        ],
        [
            'title' => 'Notifications',
            'desc'  => 'Firebase (FCM) and Pusher/Ably configuration for App & Web.',
            'icon'  => 'heroicon-o-bell-alert',
            'color' => '#fff7ed', 'icon_color' => '#f97316',
            'link'  => route('filament.admin.pages.notification-settings'),
            'badge' => 'Active',
        ],
        [
            'title' => 'Storage & API',
            'desc'  => 'Amazon S3, Cloudflare R2, and External Exchange APIs.',
            'icon'  => 'heroicon-o-server-stack',
            'color' => '#f0f9ff', 'icon_color' => '#0369a1',
            'link'  => route('filament.admin.pages.storage-settings'),
            'badge' => null,
        ],
    ] as $card)
    <a href="{{ $card['link'] }}" class="cp-card">
        <div class="cp-card-accent"></div>
        <div class="cp-icon-wrap" style="background:{{ $card['color'] }}">
            @svg($card['icon'], 'w-5 h-5', ['style' => 'color:' . $card['icon_color']])
        </div>
        <div style="flex:1;">
            <div style="display:flex;align-items:center;gap:8px;">
                <div class="cp-card-title">{{ $card['title'] }}</div>
                @if($card['badge'])
                <span style="font-size:10px;font-weight:700;background:{{ $card['color'] }};color:{{ $card['icon_color'] }};padding:1px 8px;border-radius:999px;">{{ $card['badge'] }}</span>
                @endif
            </div>
            <div class="cp-card-desc">{{ $card['desc'] }}</div>
            <div class="cp-card-link">
                Configure
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:14px;height:14px"><path fill-rule="evenodd" d="M3 10a.75.75 0 0 1 .75-.75h10.638L10.23 5.29a.75.75 0 1 1 1.04-1.08l5.5 5.25a.75.75 0 0 1 0 1.08l-5.5 5.25a.75.75 0 1 1-1.04-1.08l4.158-3.96H3.75A.75.75 0 0 1 3 10Z" clip-rule="evenodd"/></svg>
            </div>
        </div>
    </a>
    @endforeach
</div>
</x-filament-panels::page>

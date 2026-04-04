<x-filament-panels::page>
<style>
:root {
    --navy: #002147;
    --teal: #0D9488;
    --teal-light: #14b8a6;
    --teal-dark: #0f766e;
}

.mp-stat-card {
    background: white;
    border-radius: 12px;
    padding: 20px 24px;
    border: 1px solid #f1f5f9;
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
    display: flex;
    flex-direction: column;
    gap: 8px;
}
.dark .mp-stat-card { background: #1e293b; border-color: rgba(255,255,255,0.08); }

.mp-stat-label {
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: #94a3b8;
}
.mp-stat-value {
    font-size: 28px;
    font-weight: 800;
    color: #0f172a;
    letter-spacing: -0.5px;
}
.dark .mp-stat-value { color: #f1f5f9; }

.mp-stat-change {
    font-size: 12px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 4px;
}
.mp-stat-icon {
    width: 36px; height: 36px;
    border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
    align-self: flex-start;
    margin-left: auto;
    margin-top: -40px;
}

.mp-alert-banner {
    background: #fff8f0;
    border-left: 4px solid #f59e0b;
    border-radius: 10px;
    padding: 14px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    font-size: 14px;
    font-weight: 500;
    color: #92400e;
    margin-bottom: 20px;
}
.dark .mp-alert-banner { background: rgba(245,158,11,0.15); color: #fde68a; }

.mp-chart-card {
    background: white;
    border-radius: 14px;
    padding: 24px;
    border: 1px solid #f1f5f9;
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}
.dark .mp-chart-card { background: #1e293b; border-color: rgba(255,255,255,0.08); }

.mp-vault-card {
    background: var(--navy);
    border-radius: 14px;
    padding: 24px;
    color: white;
}

.mp-vault-balance {
    font-size: 24px;
    font-weight: 800;
    margin: 6px 0;
}
.mp-vault-label {
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: rgba(255,255,255,0.5);
}

.mp-badge {
    display: inline-flex;
    align-items: center;
    padding: 2px 10px;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 700;
}
.mp-badge-stable { background: rgba(20,184,166,0.2); color: #14b8a6; }
.mp-badge-critical { background: rgba(239,68,68,0.2); color: #ef4444; }
.mp-badge-completed { background: rgba(20,184,166,0.15); color: var(--teal); }
.mp-badge-pending { background: rgba(251,191,36,0.15); color: #d97706; }
.mp-badge-failed { background: rgba(239,68,68,0.12); color: #ef4444; }

.mp-rebalance-btn {
    width: 100%;
    background: var(--teal);
    color: white;
    border: none;
    border-radius: 8px;
    padding: 12px;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    margin-top: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: background 0.2s;
}
.mp-rebalance-btn:hover { background: var(--teal-dark); }

.mp-insights-card {
    background: #f0f9ff;
    border-radius: 14px;
    padding: 20px;
    margin-top: 16px;
}
.dark .mp-insights-card { background: rgba(14,165,233,0.1); }

.mp-insight-item {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13px;
    color: #1e3a5f;
    padding: 7px 0;
    border-bottom: 1px solid rgba(0,0,0,0.05);
}
.dark .mp-insight-item { color: #bae6fd; border-color: rgba(255,255,255,0.05); }
.mp-insight-item:last-child { border-bottom: none; }
.mp-dot { width: 8px; height: 8px; border-radius: 999px; flex-shrink: 0; }

.mp-tx-row {
    display: grid;
    grid-template-columns: 1.4fr 1.2fr 1fr 1fr 0.9fr;
    gap: 8px;
    padding: 12px 16px;
    border-bottom: 1px solid #f1f5f9;
    font-size: 13px;
    align-items: center;
}
.dark .mp-tx-row { border-bottom-color: rgba(255,255,255,0.06); }
.mp-tx-head { font-size: 10px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; color: #94a3b8; }
.mp-tx-row:last-child { border-bottom: none; }

.mp-avatar {
    width: 32px; height: 32px;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 12px; font-weight: 800;
    color: white;
    flex-shrink: 0;
}

.mp-progress-bar {
    height: 5px;
    background: rgba(255,255,255,0.15);
    border-radius: 999px;
    margin-top: 8px;
    overflow: hidden;
}
.mp-progress-fill {
    height: 100%;
    border-radius: 999px;
    transition: width 0.5s ease;
}

/* ELITE GLASSMORPHISM ADDITIONS */
.mp-glass-header {
    background: linear-gradient(135deg, rgba(0, 33, 71, 0.95) 0%, rgba(13, 148, 136, 0.8) 100%);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 16px;
    padding: 24px 32px;
    margin-bottom: 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: relative;
    overflow: hidden;
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
}
.mp-logo-pulse {
    width: 12px; height: 12px;
    background: #4ade80;
    border-radius: 50%;
    box-shadow: 0 0 0 0 rgba(74, 222, 128, 0.7);
    animation: mp-pulse 2s infinite;
}
@keyframes mp-pulse {
    0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(74, 222, 128, 0.7); }
    70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(74, 222, 128, 0); }
    100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(74, 222, 128, 0); }
}
.mp-btn-glass {
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    color: white;
    padding: 8px 16px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s;
    text-decoration: none;
}
.mp-btn-glass:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: translateY(-1px);
}
</style>

@php
    $data = $this->getDashboardData();
    $lowAccounts = $data['lowAccounts'];
@endphp

{{-- ── ELITE BRANDING HEADER ─────────────────────────────────────────────────── --}}
<div class="mp-glass-header">
    <div style="display:flex; align-items:center; gap:20px; z-index:1;">
        {{-- Elite Logo Component --}}
        <div style="background: white; padding: 10px; border-radius: 14px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
            @include('filament.branding.logo', ['size' => 40])
        </div>
        <div>
            <div style="color: white; font-size: 22px; font-weight: 800; letter-spacing: -0.5px;">MurtaaxPay Command Center</div>
            <div style="display:flex; align-items:center; gap:8px; margin-top:4px;">
                <div class="mp-logo-pulse"></div>
                <div style="color: rgba(255,255,255,0.7); font-size: 12px; font-weight: 600;">System Online • v{{ $data['app_version'] }}</div>
            </div>
        </div>
    </div>
    
    <div style="display:flex; gap:12px; z-index:1;">
        <a href="{{ route('filament.admin.resources.kyc-verifications.index') }}" class="mp-btn-glass">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 1a4.5 4.5 0 0 0-4.5 4.5V9H5a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-6a2 2 0 0 0-2-2h-.5V5.5A4.5 4.5 0 0 0 10 1Zm3 8V5.5a3 3 0 1 0-6 0V9h6Z" clip-rule="evenodd" /></svg>
            Review KYC ({{ $data['pendingKyc'] }})
        </a>
        <a href="{{ route('filament.admin.pages.control-panel') }}" class="mp-btn-glass" style="background:#14b8a6; border-color:#2dd4bf;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 2a.75.75 0 0 1 .75.75v1.5a.75.75 0 0 1-1.5 0v-1.5A.75.75 0 0 1 10 2ZM10 15a.75.75 0 0 1 .75.75v1.5a.75.75 0 0 1-1.5 0v-1.5A.75.75 0 0 1 10 15ZM10 7a3 3 0 1 0 0 6 3 3 0 0 0 0-6ZM15.657 5.404a.75.75 0 1 0-1.06-1.06l-1.061 1.06a.75.75 0 0 0 1.06 1.06l1.06-1.06ZM6.464 14.596a.75.75 0 1 0-1.06-1.06l-1.06 1.06a.75.75 0 0 0 1.06 1.06l1.06-1.06ZM18 10a.75.75 0 0 1-.75.75h-1.5a.75.75 0 0 1 0-1.5h1.5A.75.75 0 0 1 18 10ZM5 10a.75.75 0 0 1-.75.75h-1.5a.75.75 0 0 1 0-1.5h1.5A.75.75 0 0 1 5 10ZM14.596 13.536a.75.75 0 0 1 1.06 1.06l-1.06 1.06a.75.75 0 0 1-1.06-1.06l1.06-1.06ZM5.404 4.343a.75.75 0 0 1 1.06 1.06L5.404 6.464a.75.75 0 1 1-1.06-1.06l1.06-1.06Z" clip-rule="evenodd" /></svg>
            System Control
        </a>
    </div>
</div>

{{-- ── LOW BALANCE ALERTS ─────────────────────────────────────────────── --}}
@foreach($lowAccounts as $account)
<div class="mp-alert-banner">
    <div style="display:flex; align-items:center; gap:10px;">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" style="width:20px;height:20px;flex-shrink:0">
            <path fill-rule="evenodd" d="M9.401 3.003c1.155-2 4.043-2 5.197 0l7.355 12.748c1.154 2-.29 4.5-2.599 4.5H4.645c-2.309 0-3.752-2.5-2.598-4.5L9.4 3.003ZM12 8.25a.75.75 0 0 1 .75.75v3.75a.75.75 0 0 1-1.5 0V9a.75.75 0 0 1 .75-.75Zm0 8.25a.75.75 0 1 0 0-1.5.75.75 0 0 0 0 1.5Z" clip-rule="evenodd" />
        </svg>
        <span>
            <strong>Low Balance Alert:</strong>
            <span style="color:#d97706">{{ $account->name }}</span>
            is currently at
            <strong>{{ $account->currency }} {{ number_format($account->balance / 100, 2) }}</strong>
            (Threshold: {{ $account->currency }} {{ number_format($account->alert_threshold / 100, 2) }})
        </span>
    </div>
    <a href="{{ route('filament.admin.resources.float-accounts.index') }}" style="white-space:nowrap; font-weight:700; color:var(--teal); text-decoration:none; font-size:13px;">
        Fund Now →
    </a>
</div>
@endforeach

{{-- ── STATS GRID ────────────────────────────────────────────────────────── --}}
<div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px;">

    <div class="mp-stat-card">
        <div style="display:flex; align-items:start; justify-content:space-between;">
            <div>
                <div class="mp-stat-label">Total Volume (EUR)</div>
                <div class="mp-stat-value">€{{ number_format($data['totalVolumeEur'], 2) }}</div>
            </div>
            <div class="mp-stat-icon" style="background:#e0fdf4; margin-top:0; margin-left:0;">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#14b8a6" style="width:18px;height:18px"><path d="M4.5 3.75a3 3 0 0 0-3 3v.75h21v-.75a3 3 0 0 0-3-3h-15Z" /><path fill-rule="evenodd" d="M22.5 9.75h-21v7.5a3 3 0 0 0 3 3h15a3 3 0 0 0 3-3v-7.5Zm-18 3.75a.75.75 0 0 1 .75-.75h6a.75.75 0 0 1 0 1.5h-6a.75.75 0 0 1-.75-.75Zm.75 2.25a.75.75 0 0 0 0 1.5h3a.75.75 0 0 0 0-1.5h-3Z" clip-rule="evenodd" /></svg>
            </div>
        </div>
        <div class="mp-stat-change" style="color:#16a34a;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:14px;height:14px"><path fill-rule="evenodd" d="M12.577 4.878a.75.75 0 0 1 .919-.53l4.78 1.281a.75.75 0 0 1 .531.919l-1.281 4.78a.75.75 0 0 1-1.449-.387l.81-3.022a19.407 19.407 0 0 0-5.594 5.203.75.75 0 0 1-1.139.093L7 10.06l-4.72 4.72a.75.75 0 0 1-1.06-1.061l5.25-5.25a.75.75 0 0 1 1.06 0l3.074 3.073a20.923 20.923 0 0 1 5.545-4.931l-3.042-.815a.75.75 0 0 1-.53-.918Z" clip-rule="evenodd" /></svg>
            +12.4% vs last month
        </div>
    </div>

    <div class="mp-stat-card">
        <div style="display:flex; align-items:start; justify-content:space-between;">
            <div>
                <div class="mp-stat-label">Total Payout (USD)</div>
                <div class="mp-stat-value">${{ number_format($data['totalPayoutUsd'], 2) }}</div>
            </div>
            <div class="mp-stat-icon" style="background:#f0fdf4; margin-top:0; margin-left:0;">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#22c55e" style="width:18px;height:18px"><path d="M2.273 5.625A4.483 4.483 0 0 1 5.25 4.5h13.5c1.141 0 2.183.425 2.977 1.125A3 3 0 0 0 18.75 3H5.25a3 3 0 0 0-2.977 2.625ZM2.273 8.625A4.483 4.483 0 0 1 5.25 7.5h13.5c1.141 0 2.183.425 2.977 1.125A3 3 0 0 0 18.75 6H5.25a3 3 0 0 0-2.977 2.625ZM5.25 9a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h13.5a3 3 0 0 0 3-3v-6a3 3 0 0 0-3-3H15a.75.75 0 0 0-.75.75 2.25 2.25 0 0 1-4.5 0A.75.75 0 0 0 9 9H5.25Z" /></svg>
            </div>
        </div>
        <div class="mp-stat-change" style="color:#16a34a;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:14px;height:14px"><path fill-rule="evenodd" d="M12.577 4.878a.75.75 0 0 1 .919-.53l4.78 1.281a.75.75 0 0 1 .531.919l-1.281 4.78a.75.75 0 0 1-1.449-.387l.81-3.022a19.407 19.407 0 0 0-5.594 5.203.75.75 0 0 1-1.139.093L7 10.06l-4.72 4.72a.75.75 0 0 1-1.06-1.061l5.25-5.25a.75.75 0 0 1 1.06 0l3.074 3.073a20.923 20.923 0 0 1 5.545-4.931l-3.042-.815a.75.75 0 0 1-.53-.918Z" clip-rule="evenodd" /></svg>
            +8.2% vs last month
        </div>
    </div>

    <div class="mp-stat-card">
        <div style="display:flex; align-items:start; justify-content:space-between;">
            <div>
                <div class="mp-stat-label">Total Revenue</div>
                <div class="mp-stat-value">${{ number_format($data['totalRevenue'], 2) }}</div>
            </div>
            <div class="mp-stat-icon" style="background:#fef3c7; margin-top:0; margin-left:0;">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#f59e0b" style="width:18px;height:18px"><path fill-rule="evenodd" d="M2.25 13.5a8.25 8.25 0 0 1 8.25-8.25.75.75 0 0 1 .75.75v6.75H18a.75.75 0 0 1 .75.75 8.25 8.25 0 0 1-16.5 0Z" clip-rule="evenodd" /><path fill-rule="evenodd" d="M12.75 3a.75.75 0 0 1 .75-.75 8.25 8.25 0 0 1 8.25 8.25.75.75 0 0 1-.75.75h-7.5a.75.75 0 0 1-.75-.75V3Z" clip-rule="evenodd" /></svg>
            </div>
        </div>
        <div class="mp-stat-change" style="color:#16a34a;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:14px;height:14px"><path fill-rule="evenodd" d="M12.577 4.878a.75.75 0 0 1 .919-.53l4.78 1.281a.75.75 0 0 1 .531.919l-1.281 4.78a.75.75 0 0 1-1.449-.387l.81-3.022a19.407 19.407 0 0 0-5.594 5.203.75.75 0 0 1-1.139.093L7 10.06l-4.72 4.72a.75.75 0 0 1-1.06-1.061l5.25-5.25a.75.75 0 0 1 1.06 0l3.074 3.073a20.923 20.923 0 0 1 5.545-4.931l-3.042-.815a.75.75 0 0 1-.53-.918Z" clip-rule="evenodd" /></svg>
            +5.1% vs last month
        </div>
    </div>

    <div class="mp-stat-card">
        <div style="display:flex; align-items:start; justify-content:space-between;">
            <div>
                <div class="mp-stat-label">Active Users</div>
                <div class="mp-stat-value">{{ number_format($data['activeUsers']) }}</div>
            </div>
            <div class="mp-stat-icon" style="background:#ede9fe; margin-top:0; margin-left:0;">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#8b5cf6" style="width:18px;height:18px"><path fill-rule="evenodd" d="M8.25 6.75a3.75 3.75 0 1 1 7.5 0 3.75 3.75 0 0 1-7.5 0ZM15.75 9.75a3 3 0 1 1 6 0 3 3 0 0 1-6 0ZM2.25 9.75a3 3 0 1 1 6 0 3 3 0 0 1-6 0ZM6.31 15.117A6.745 6.745 0 0 1 12 12a6.745 6.745 0 0 1 6.709 7.498.75.75 0 0 1-.372.568A12.696 12.696 0 0 1 12 21.75c-2.305 0-4.47-.612-6.337-1.684a.75.75 0 0 1-.372-.568 6.787 6.787 0 0 1 1.019-4.38Z" clip-rule="evenodd" /></svg>
            </div>
        </div>
        <div class="mp-stat-change" style="color:#dc2626;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:14px;height:14px"><path fill-rule="evenodd" d="M1.22 5.222a.75.75 0 0 1 1.06 0L7 9.942l3.768-3.769a.75.75 0 0 1 1.113.058 20.908 20.908 0 0 1 3.813 7.254l1.574-2.727a.75.75 0 0 1 1.3.75l-2.475 4.286a.75.75 0 0 1-.978.29l-4.502-2.25a.75.75 0 1 1 .67-1.34l2.598 1.298a19.422 19.422 0 0 0-3.188-5.774L7.06 11.03l-4.5-4.5a.75.75 0 0 1-.34-1.309Z" clip-rule="evenodd" /></svg>
            -1.2% vs last week
        </div>
    </div>
</div>

{{-- ── MAIN CONTENT GRID: Chart + Vaults & Insights ─────────────────────── --}}
<div style="display: grid; grid-template-columns: 1fr 300px; gap: 20px; margin-bottom: 24px;">

    {{-- Chart --}}
    <div class="mp-chart-card">
        <div style="margin-bottom:16px;">
            <div style="display:flex; align-items:center; justify-content:space-between;">
                <div>
                    <div style="font-size:16px; font-weight:700; color:#0f172a;" class="dark:text-slate-100">Transaction Volume</div>
                    <div style="font-size:12px; color:#94a3b8; margin-top:2px;">Real-time throughput across all nodes (24h)</div>
                </div>
                <div style="display:flex; gap:6px;">
                    @foreach(['Live','1H','24H'] as $tab)
                    <button style="padding: 5px 12px; border-radius:6px; font-size:12px; font-weight:600; border:1px solid #e2e8f0; background:{{ $tab === 'Live' ? 'var(--navy)' : 'white' }}; color:{{ $tab === 'Live' ? 'white' : '#64748b' }}; cursor:pointer;">
                        {{ $tab }}
                    </button>
                    @endforeach
                </div>
            </div>
        </div>
        <div id="txVolumeChart" style="min-height:220px;"></div>
    </div>

    {{-- Global Vaults + Insights --}}
    <div style="display:flex; flex-direction:column; gap:16px;">

        {{-- Vault Card --}}
        <div class="mp-vault-card">
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:18px;">
                <div style="font-size:11px; font-weight:700; letter-spacing:0.1em; text-transform:uppercase; color:rgba(255,255,255,0.6);">Global Vaults</div>
                <div style="width:28px;height:28px;background:rgba(255,255,255,0.1);border-radius:999px;display:flex;align-items:center;justify-content:center;">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="rgba(255,255,255,0.7)" style="width:14px;height:14px"><path fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm4.28 10.28a.75.75 0 0 0 0-1.06l-3-3a.75.75 0 1 0-1.06 1.06l1.72 1.72H8.25a.75.75 0 0 0 0 1.5h5.69l-1.72 1.72a.75.75 0 1 0 1.06 1.06l3-3Z" clip-rule="evenodd" /></svg>
                </div>
            </div>

            @if($data['wallesterAccount'])
            <div style="margin-bottom:16px;">
                <div class="mp-vault-label">Wallester EUR</div>
                <div style="display:flex;align-items:center;gap:10px;margin-top:4px;">
                    <div class="mp-vault-balance">€{{ number_format($data['wallesterAccount']->balance / 100, 2) }}</div>
                    <span class="mp-badge {{ $data['wallesterAccount']->is_low ? 'mp-badge-critical' : 'mp-badge-stable' }}">
                        {{ $data['wallesterAccount']->is_low ? 'Critical' : 'Stable' }}
                    </span>
                </div>
                <div class="mp-progress-bar">
                    <div class="mp-progress-fill" style="width:{{ $data['wallesterAccount']->threshold_percent }}%; background:{{ $data['wallesterAccount']->is_low ? '#ef4444' : '#14b8a6' }};"></div>
                </div>
            </div>
            @endif

            @if($data['waafiAccount'])
            <div style="margin-bottom:4px;">
                <div class="mp-vault-label">WAAFI USD</div>
                <div style="display:flex;align-items:center;gap:10px;margin-top:4px;">
                    <div class="mp-vault-balance">${{ number_format($data['waafiAccount']->balance / 100, 2) }}</div>
                    <span class="mp-badge {{ $data['waafiAccount']->is_low ? 'mp-badge-critical' : 'mp-badge-stable' }}">
                        {{ $data['waafiAccount']->is_low ? 'Critical' : 'Stable' }}
                    </span>
                </div>
                <div class="mp-progress-bar">
                    <div class="mp-progress-fill" style="width:{{ $data['waafiAccount']->threshold_percent }}%; background:{{ $data['waafiAccount']->is_low ? '#ef4444' : '#14b8a6' }};"></div>
                </div>
            </div>
            @endif

            <button class="mp-rebalance-btn" onclick="window.location='{{ route('filament.admin.resources.float-accounts.index') }}'">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" style="width:15px;height:15px"><path fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm4.28 10.28a.75.75 0 0 0 0-1.06l-3-3a.75.75 0 1 0-1.06 1.06l1.72 1.72H8.25a.75.75 0 0 0 0 1.5h5.69l-1.72 1.72a.75.75 0 1 0 1.06 1.06l3-3Z" clip-rule="evenodd" /></svg>
                Rebalance Liquidity
            </button>
        </div>

        {{-- System Insights --}}
        <div class="mp-insights-card">
            <div style="font-size:11px; font-weight:700; letter-spacing:0.1em; text-transform:uppercase; color:#0369a1; margin-bottom:10px;">System Insights</div>
            <div class="mp-insight-item">
                <div class="mp-dot" style="background:#22c55e;"></div>
                Node processing latency at optimal
            </div>
            <div class="mp-insight-item">
                <div class="mp-dot" style="background:#22c55e;"></div>
                Auto-reconciliation scheduled
            </div>
            <div class="mp-insight-item">
                <div class="mp-dot" style="background:#f59e0b;"></div>
                {{ $data['pendingKyc'] }} KYC pending review
            </div>
            <div class="mp-insight-item">
                <div class="mp-dot" style="background:#3b82f6;"></div>
                {{ $data['todayTxCount'] }} transactions today
            </div>
            @if($data['activeRate'])
            <div class="mp-insight-item">
                <div class="mp-dot" style="background:#14b8a6;"></div>
                FX Rate: 1 EUR = {{ number_format($data['activeRate']->effective_rate, 4) }} USD
            </div>
            @endif
        </div>
    </div>
</div>

{{-- ── RECENT TRANSACTIONS ───────────────────────────────────────────────── --}}
<div class="mp-chart-card">
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:16px;">
        <div style="font-size:16px; font-weight:700; color:#0f172a;" class="dark:text-slate-100">Recent Transactions</div>
        <a href="{{ route('filament.admin.resources.transactions.index') }}"
           style="font-size:12px; font-weight:600; color:var(--teal); text-decoration:none;">
            View All Transactions →
        </a>
    </div>

    {{-- Header --}}
    <div class="mp-tx-row mp-tx-head">
        <div>Reference</div>
        <div>User</div>
        <div>Amount</div>
        <div>Status</div>
        <div>Timestamp</div>
    </div>

    @forelse($data['recentTx'] as $tx)
    @php
        $colors = ['#14b8a6','#6366f1','#f59e0b','#ec4899','#0ea5e9'];
        $initials = strtoupper(substr($tx->user->name ?? 'U', 0, 2));
        $color = $colors[$loop->index % count($colors)];
    @endphp
    <div class="mp-tx-row">
        <div style="font-family:monospace; font-size:12px; color:#64748b; font-weight:600;">
            #{{ substr($tx->reference, 0, 10) }}
        </div>
        <div style="display:flex; align-items:center; gap:8px;">
            <div class="mp-avatar" style="background:{{ $color }}; font-size:10px;">{{ $initials }}</div>
            <span style="font-size:13px; font-weight:500; color:#1e293b;" class="dark:text-slate-200">
                {{ Str::limit($tx->user->name ?? 'Unknown', 16) }}
            </span>
        </div>
        <div style="font-weight:700; font-size:13px; color:#0f172a;" class="dark:text-slate-100">
            {{ $tx->currency }} {{ number_format($tx->amount / 100, 2) }}
        </div>
        <div>
            @if($tx->status === 'completed')
                <span class="mp-badge mp-badge-completed">Completed</span>
            @elseif($tx->status === 'pending')
                <span class="mp-badge mp-badge-pending">Pending</span>
            @else
                <span class="mp-badge mp-badge-failed">{{ ucfirst($tx->status) }}</span>
            @endif
        </div>
        <div style="font-size:12px; color:#94a3b8;">{{ $tx->created_at->diffForHumans() }}</div>
    </div>
    @empty
    <div style="padding:40px; text-align:center; color:#94a3b8; font-size:14px;">
        No transactions yet. They will appear here once the system processes pay-ins.
    </div>
    @endforelse
</div>

{{-- ── RECENT SIGNUPS & KYC (ELITE VISIBILITY) ────────────────────────────── --}}
<div class="mp-chart-card" style="margin-top: 24px;">
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:16px;">
        <div>
            <div style="font-size:16px; font-weight:700; color:#0f172a;" class="dark:text-slate-100">🛡️ Recent Signups & KYC Reviews</div>
            <div style="font-size:12px; color:#94a3b8; margin-top:2px;">Identify and verify new users to increase liquidity limits.</div>
        </div>
        <a href="{{ route('filament.admin.resources.kyc-verifications.index') }}"
           style="font-size:12px; font-weight:600; color:var(--teal); text-decoration:none;">
            View All Reviews →
        </a>
    </div>

    <div class="mp-tx-row mp-tx-head">
        <div>Name & Email</div>
        <div>Joined</div>
        <div>KYC Status</div>
        <div>Current Tier</div>
        <div style="text-align:right;">Actions</div>
    </div>

    @forelse($data['recentSignups'] as $user)
    <div class="mp-tx-row">
        <div>
            <div style="font-weight:700; color:#1e293b;" class="dark:text-slate-200">{{ $user->name }}</div>
            <div style="font-size:11px; color:#94a3b8;">{{ $user->email }}</div>
        </div>
        <div style="font-size:12px; color:#64748b;">{{ $user->created_at->diffForHumans() }}</div>
        <div>
            @php $kycStatus = optional($user->kycVerification)->status ?? 'none'; @endphp
            <span class="mp-badge {{ $kycStatus === 'verified' ? 'mp-badge-completed' : ($kycStatus === 'pending' ? 'mp-badge-pending' : 'mp-badge-failed') }}">
                {{ ucfirst($kycStatus) }}
            </span>
        </div>
        <div>
            <span class="mp-badge mp-badge-stable" style="background:#f1f5f9; color:#475569; border:1px solid #e2e8f0;">
                {{ ucfirst($user->tier) }}
            </span>
        </div>
        <div style="text-align:right;">
            <a href="{{ $user->kycVerification ? route('filament.admin.resources.kyc-verifications.edit', $user->kycVerification->id) : route('filament.admin.resources.users.edit', $user->id) }}" 
               style="display:inline-flex; align-items:center; gap:4px; font-size:12px; font-weight:700; color:var(--teal); text-decoration:none; background:rgba(13,148,136,0.1); padding:4px 10px; border-radius:6px;">
                Review Info
            </a>
        </div>
    </div>
    @empty
    <div style="padding:20px; text-align:center; color:#94a3b8; font-size:13px;">No recent signups found.</div>
    @endforelse
</div>

{{-- ── ApexCharts ────────────────────────────────────────────────────────── --}}
<script src="https://cdn.jsdelivr.net/npm/apexcharts@latest/dist/apexcharts.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    const labels = {!! $data['chartLabels'] !!};
    const values = {!! $data['chartValues'] !!};

    const options = {
        series: [{ name: 'Volume (EUR)', data: values }],
        chart: {
            type: 'bar',
            height: 220,
            toolbar: { show: false },
            background: 'transparent',
            fontFamily: 'Outfit, sans-serif',
        },
        plotOptions: {
            bar: {
                borderRadius: 5,
                columnWidth: '55%',
                colors: {
                    ranges: [{ from: 0, to: 999999, color: '#0D9488' }]
                }
            }
        },
        dataLabels: { enabled: false },
        xaxis: {
            categories: labels,
            labels: { style: { fontSize: '11px', colors: '#94a3b8' } },
            axisBorder: { show: false },
            axisTicks: { show: false },
        },
        yaxis: {
            labels: {
                formatter: val => '€' + val.toLocaleString(),
                style: { fontSize: '11px', colors: '#94a3b8' }
            }
        },
        grid: { borderColor: '#f1f5f9', strokeDashArray: 4 },
        tooltip: {
            y: { formatter: val => '€' + val.toLocaleString() }
        },
        theme: { mode: document.documentElement.classList.contains('dark') ? 'dark' : 'light' }
    };

    const chart = new ApexCharts(document.querySelector('#txVolumeChart'), options);
    chart.render();
});
</script>

</x-filament-panels::page>

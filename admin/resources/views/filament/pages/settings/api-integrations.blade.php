<x-filament-panels::page>
<style>
.sp-header { background: linear-gradient(135deg, #002147 0%, #003370 60%, #0D9488 100%); border-radius: 14px; padding: 28px 32px; color: white; display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.sp-header-title { font-size: 22px; font-weight: 800; }
.sp-header-sub { font-size: 12px; color: rgba(255,255,255,0.6); margin-top: 3px; }
.sp-card { background: white; border-radius: 14px; border: 1px solid #f1f5f9; box-shadow: 0 1px 4px rgba(0,0,0,0.05); margin-bottom: 20px; overflow: hidden; }
.dark .sp-card { background: #1e293b; border-color: rgba(255,255,255,0.07); }
.sp-card-header { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
.dark .sp-card-header { border-bottom-color: rgba(255,255,255,0.06); }
.sp-card-title { font-size: 14px; font-weight: 700; color: #0f172a; }
.dark .sp-card-title { color: #f1f5f9; }
.sp-card-body { padding: 24px; }
.sp-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.sp-field { display: flex; flex-direction: column; gap: 6px; }
.sp-label { font-size: 12px; font-weight: 600; color: #64748b; }
.sp-input { border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px; font-size: 14px; color: #0f172a; background: white; outline: none; transition: border-color 0.2s; width: 100%; font-family: 'Outfit', sans-serif; }
.sp-input:focus { border-color: #14b8a6; box-shadow: 0 0 0 3px rgba(20,184,166,0.12); }
.dark .sp-input { background: #0f172a; border-color: rgba(255,255,255,0.1); color: #f1f5f9; }
.sp-input-secret { font-family: monospace; letter-spacing: 0.1em; }
.sp-select { appearance: none; -webkit-appearance: none; -moz-appearance: none; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px; padding-right: 40px; font-size: 14px; color: #0f172a; background: white; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748b'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 12px center; background-size: 16px; outline: none; width: 100%; font-family: 'Outfit', sans-serif; cursor: pointer; transition: border-color 0.2s, box-shadow 0.2s; }
.sp-select:focus { border-color: #14b8a6; box-shadow: 0 0 0 3px rgba(20,184,166,0.12); }
.dark .sp-select { background-color: #0f172a; border-color: rgba(255,255,255,0.1); color: #f1f5f9; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2394a3b8'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E"); }
.sp-save-btn { background: linear-gradient(135deg, #0d9488, #0f766e); color: white; border: none; border-radius: 10px; padding: 12px 28px; font-size: 14px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: opacity 0.2s; font-family: 'Outfit', sans-serif; }
.sp-save-btn:hover { opacity: 0.9; }
</style>

<div class="sp-header">
    <div>
        <div class="sp-header-title">🔗 API & Integration Settings</div>
        <div class="sp-header-sub">Manage connections to Wallester, WAAFI, E-Dahab, and External FX Providers.</div>
    </div>
</div>

<form wire:submit.prevent="save">

{{-- WALLESTER --}}
<div class="sp-card">
    <div class="sp-card-header">
        <div style="width:32px;height:32px;border-radius:8px;background:#e0f2fe;display:flex;align-items:center;justify-content:center;">
             <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#0284c7" style="width:16px;height:16px"><path d="M12 7.5a2.25 2.25 0 1 0 0 4.5 2.25 2.25 0 0 0 0-4.5Z" /><path fill-rule="evenodd" d="M1.5 4.875C1.5 3.839 2.34 3 3.375 3h17.25c1.035 0 1.875.84 1.875 1.875v14.25c0 1.036-.84 1.875-1.875 1.875H3.375A1.875 1.875 0 0 1 1.5 19.125V4.875ZM21 9.75H3V18h18V9.75Z" clip-rule="evenodd" /></svg>
        </div>
        <div class="sp-card-title">Wallester (Cards & Issuing)</div>
        <span style="font-size:10px;font-weight:700;background:#e0fdf4;color:#0d9488;padding:2px 10px;border-radius:999px;margin-left:auto;">ACTIVE</span>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">API Key</label>
                <input class="sp-input sp-input-secret" wire:model="settings.wallester_api_key" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">Secret Token</label>
                <input class="sp-input sp-input-secret" wire:model="settings.wallester_secret_token" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">Endpoint URL</label>
                <input class="sp-input" wire:model="settings.wallester_endpoint" type="text" placeholder="https://api.wallester.com/v1">
            </div>
             <div class="sp-field">
                <label class="sp-label">Webhook Secret</label>
                <input class="sp-input sp-input-secret" wire:model="settings.wallester_webhook_secret" type="password" placeholder="••••••••••••">
            </div>
        </div>
    </div>
</div>

{{-- WAAFI --}}
<div class="sp-card">
    <div class="sp-card-header">
        <div style="width:32px;height:32px;border-radius:8px;background:#f0fdf4;display:flex;align-items:center;justify-content:center;">
             <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#16a34a" style="width:16px;height:16px"><path fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25ZM12.75 6a.75.75 0 0 0-1.5 0v6c0 .414.336.75.75.75h4.5a.75.75 0 0 0 0-1.5h-3.75V6Z" clip-rule="evenodd" /></svg>
        </div>
        <div class="sp-card-title">WAAFI (Somalia Payouts)</div>
        <span style="font-size:10px;font-weight:700;background:#f0fdf4;color:#16a34a;padding:2px 10px;border-radius:999px;margin-left:auto;">WAAFI</span>
    </div>
    <div class="sp-card-body">
         <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">Merchant UID</label>
                <input class="sp-input" wire:model="settings.waafi_merchant_uid" type="text" placeholder="M-12345">
            </div>
            <div class="sp-field">
                <label class="sp-label">API User ID</label>
                <input class="sp-input" wire:model="settings.waafi_api_user_id" type="text" placeholder="U-67890">
            </div>
            <div class="sp-field">
                <label class="sp-label">API Key</label>
                <input class="sp-input sp-input-secret" wire:model="settings.waafi_api_key" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">Endpoint URL</label>
                <input class="sp-input" wire:model="settings.waafi_endpoint" type="text" placeholder="https://api.waafipay.net/asm">
            </div>
        </div>
    </div>
</div>

{{-- E-DAHAB --}}
<div class="sp-card">
    <div class="sp-card-header">
        <div style="width:32px;height:32px;border-radius:8px;background:#fefce8;display:flex;align-items:center;justify-content:center;">
             <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#a16207" style="width:16px;height:16px"><path fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25ZM12.75 6a.75.75 0 0 0-1.5 0v6c0 .414.336.75.75.75h4.5a.75.75 0 0 0 0-1.5h-3.75V6Z" clip-rule="evenodd" /></svg>
        </div>
        <div class="sp-card-title">e-Dahab / Dahab Plus (Somalia Payouts)</div>
        <span style="font-size:10px;font-weight:700;background:#fefce8;color:#a16207;padding:2px 10px;border-radius:999px;margin-left:auto;">E-DAHAB</span>
    </div>
    <div class="sp-card-body">
         <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">Merchant PID (Portal ID)</label>
                <input class="sp-input" wire:model="settings.edahab_merchant_pid" type="text" placeholder="P-54321">
            </div>
            <div class="sp-field">
                <label class="sp-label">API Key</label>
                <input class="sp-input sp-input-secret" wire:model="settings.edahab_api_key" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">Secret Key</label>
                <input class="sp-input sp-input-secret" wire:model="settings.edahab_secret_key" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">Endpoint URL</label>
                <input class="sp-input" wire:model="settings.edahab_endpoint" type="text" placeholder="https://api.edahab.so/transfer">
            </div>
        </div>
    </div>
</div>

{{-- FX ENGINE --}}
<div class="sp-card">
    <div class="sp-card-header">
        <div style="width:32px;height:32px;border-radius:8px;background:#fef3c7;display:flex;align-items:center;justify-content:center;">
             <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#f59e0b" style="width:16px;height:16px"><path fill-rule="evenodd" d="M4.755 10.059a7.5 7.5 0 0 1 12.548-3.364l1.903 1.903h-3.183a.75.75 0 1 0 0 1.5h4.992a.75.75 0 0 0 .75-.75V4.356a.75.75 0 0 0-1.5 0v3.18l-1.9-1.9A9 9 0 0 0 3.306 9.67a.75.75 0 1 0 1.45.388Zm15.408 3.352a.75.75 0 0 0-.919.53 7.5 7.5 0 0 1-12.548 3.364l-1.902-1.903h3.183a.75.75 0 0 0 0-1.5H2.984a.75.75 0 0 0-.75.75v4.992a.75.75 0 0 0 1.5 0v-3.18l1.9 1.9a9 9 0 0 0 15.059-4.035.75.75 0 0 0-.53-.918Z" clip-rule="evenodd" /></svg>
        </div>
        <div class="sp-card-title">FX Engine Settings</div>
    </div>
    <div class="sp-card-body">
         <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">FX Provider</label>
                <select class="sp-select" wire:model="settings.fx_api_provider">
                    <option value="exchangerate-api">ExchangeRate-API</option>
                    <option value="currencylayer">CurrencyLayer</option>
                    <option value="fixer">Fixer.io</option>
                </select>
            </div>
            <div class="sp-field">
                <label class="sp-label">API Access Key</label>
                <input class="sp-input sp-input-secret" wire:model="settings.fx_api_key" type="password" placeholder="••••••••••••">
            </div>
             <div class="sp-field">
                <label class="sp-label">Auto Sync Interval (Minutes)</label>
                <input class="sp-input" wire:model="settings.fx_sync_interval_minutes" type="number" placeholder="60">
            </div>
        </div>
    </div>
</div>

<div style="display:flex;justify-content:flex-end;padding-bottom:16px;">
    <button type="submit" class="sp-save-btn">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
        Update API Credentials
    </button>
</div>

</form>
</x-filament-panels::page>

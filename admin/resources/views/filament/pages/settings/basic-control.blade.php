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
.sp-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.sp-field { display: flex; flex-direction: column; gap: 6px; }
.sp-label { font-size: 12px; font-weight: 600; color: #64748b; }
.sp-input { border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px; font-size: 14px; color: #0f172a; background: white; outline: none; transition: border-color 0.2s, box-shadow 0.2s; font-family: 'Outfit', sans-serif; width: 100%; }
.sp-input:focus { border-color: #14b8a6; box-shadow: 0 0 0 3px rgba(20,184,166,0.12); }
.dark .sp-input { background: #0f172a; border-color: rgba(255,255,255,0.1); color: #f1f5f9; }
.sp-select { appearance: none !important; -webkit-appearance: none !important; -moz-appearance: none !important; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px; padding-right: 48px !important; font-size: 14px; color: #0f172a; background: white; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748b'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E") !important; background-repeat: no-repeat !important; background-position: right 14px center !important; background-size: 16px !important; outline: none; width: 100%; font-family: 'Outfit', sans-serif; cursor: pointer; transition: border-color 0.2s, box-shadow 0.2s; }
.sp-select:focus { border-color: #14b8a6; box-shadow: 0 0 0 3px rgba(20,184,166,0.12); }
.dark .sp-select { background-color: #0f172a; border-color: rgba(255,255,255,0.1); color: #f1f5f9; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2394a3b8'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E") !important; }
.sp-save-btn { background: linear-gradient(135deg, #0d9488, #0f766e); color: white; border: none; border-radius: 10px; padding: 12px 28px; font-size: 14px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: opacity 0.2s; font-family: 'Outfit', sans-serif; }
.sp-save-btn:hover { opacity: 0.9; }
.sp-footer { padding: 20px 24px; border-top: 1px solid #f1f5f9; display: flex; justify-content: flex-end; gap: 10px; }
.dark .sp-footer { border-top-color: rgba(255,255,255,0.06); }
.sp-toggle-row { display: flex; align-items: center; justify-content: space-between; padding: 14px 0; border-bottom: 1px solid #f8fafc; }
.dark .sp-toggle-row { border-bottom-color: rgba(255,255,255,0.05); }
.sp-toggle-label { font-size: 13px; font-weight: 500; color: #1e293b; }
.dark .sp-toggle-label { color: #e2e8f0; }
.sp-toggle-desc { font-size: 11px; color: #94a3b8; margin-top: 2px; }
</style>

{{-- HEADER --}}
<div class="sp-header">
    <div>
        <div class="sp-header-title">⚙️ Basic Control Settings</div>
        <div class="sp-header-sub">Manage core platform configuration — name, timezone, currency, and support info.</div>
    </div>
    <div style="display:inline-flex;align-items:center;gap:8px;background:rgba(255,255,255,0.12);border:1px solid rgba(255,255,255,0.2);border-radius:999px;padding:8px 16px;font-size:12px;font-weight:700;color:white;">
        <div style="width:8px;height:8px;border-radius:50%;background:#4ade80;"></div>
        Operational
    </div>
</div>

<form wire:submit.prevent="save">

{{-- PLATFORM INFO --}}
<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#14b8a6" style="width:18px;height:18px"><path fill-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm11.378-3.917c-.89-.777-2.366-.777-3.255 0a.75.75 0 0 1-.988-1.129c1.454-1.272 3.776-1.272 5.23 0 1.454 1.272 1.454 3.329 0 4.601-.42.368-.903.574-1.228.756v.75a.75.75 0 0 1-1.5 0v-1.5a.75.75 0 0 1 .75-.75c.526 0 1.249-.194 1.501-.427.504-.441.504-1.157 0-1.598Z" clip-rule="evenodd"/></svg>
        <div class="sp-card-title">Platform Information</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid">
            <div class="sp-field">
                <label class="sp-label">Site Name</label>
                <input class="sp-input" wire:model="settings.site_name" type="text" placeholder="MurtaaxPay">
            </div>
            <div class="sp-field">
                <label class="sp-label">Site Tagline</label>
                <input class="sp-input" wire:model="settings.site_tagline" type="text" placeholder="Send Money Home, Instantly">
            </div>
            <div class="sp-field">
                <label class="sp-label">App Version</label>
                <input class="sp-input" wire:model="settings.app_version" type="text" placeholder="2.4.1">
            </div>
            <div class="sp-field">
                <label class="sp-label">Default Currency</label>
                <select class="sp-select" wire:model="settings.default_currency">
                    <option value="USD">🇺🇸 USD – US Dollar</option>
                    <option value="EUR">🇪🇺 EUR – Euro</option>
                    <option value="SOS">🇸🇴 SOS – Somali Shilling</option>
                    <option value="GBP">🇬🇧 GBP – British Pound</option>
                </select>
            </div>
            <div class="sp-field">
                <label class="sp-label">Default Language</label>
                <select class="sp-select" wire:model="settings.default_language">
                    <option value="en">🇬🇧 English</option>
                    <option value="so">🇸🇴 Somali</option>
                    <option value="ar">🇸🇦 Arabic</option>
                    <option value="de">🇩🇪 German</option>
                </select>
            </div>
            <div class="sp-field">
                <label class="sp-label">Timezone</label>
                <select class="sp-select" wire:model="settings.timezone">
                    <option value="Africa/Mogadishu">Africa/Mogadishu (EAT +3)</option>
                    <option value="Europe/Berlin">Europe/Berlin (CET +1)</option>
                    <option value="UTC">UTC</option>
                    <option value="America/New_York">America/New_York (EST -5)</option>
                </select>
            </div>
        </div>
    </div>
</div>

{{-- SUPPORT INFO --}}
<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#0d9488" style="width:18px;height:18px"><path fill-rule="evenodd" d="M1.5 4.5a3 3 0 0 1 3-3h1.372c.86 0 1.61.586 1.819 1.42l1.105 4.423a1.875 1.875 0 0 1-.694 1.955l-1.293.97c-.135.101-.164.249-.126.352a11.285 11.285 0 0 0 6.697 6.697c.103.038.25.009.352-.126l.97-1.293a1.875 1.875 0 0 1 1.955-.694l4.423 1.105c.834.209 1.42.959 1.42 1.82V19.5a3 3 0 0 1-3 3h-2.25C8.552 22.5 1.5 15.448 1.5 6.75V4.5Z" clip-rule="evenodd"/></svg>
        <div class="sp-card-title">Support Contact</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid">
            <div class="sp-field">
                <label class="sp-label">Support Email</label>
                <input class="sp-input" wire:model="settings.support_email" type="email" placeholder="support@murtaaxpay.com">
            </div>
            <div class="sp-field">
                <label class="sp-label">Support Phone</label>
                <input class="sp-input" wire:model="settings.support_phone" type="text" placeholder="+252 61 000 0000">
            </div>
        </div>
    </div>
</div>

{{-- MAINTENANCE MODE --}}
<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#dc2626" style="width:18px;height:18px"><path fill-rule="evenodd" d="M11.078 2.25c-.917 0-1.699.663-1.85 1.567L9.05 4.889c-.02.12-.115.26-.297.348a7.493 7.493 0 0 0-.986.57c-.166.115-.334.126-.45.083L6.3 5.508a1.875 1.875 0 0 0-2.282.819l-.922 1.597a1.875 1.875 0 0 0 .432 2.385l.84.692c.095.078.17.229.154.43a7.598 7.598 0 0 0 0 1.139c.015.2-.059.352-.153.43l-.841.692a1.875 1.875 0 0 0-.432 2.385l.922 1.597a1.875 1.875 0 0 0 2.282.818l1.019-.382c.115-.043.283-.031.45.082.312.214.641.405.985.57.182.088.277.228.297.35l.178 1.071c.151.904.933 1.567 1.85 1.567h1.844c.916 0 1.699-.663 1.85-1.567l.178-1.072c.02-.12.114-.26.297-.349.344-.165.673-.356.985-.57.167-.114.335-.125.45-.082l1.02.382a1.875 1.875 0 0 0 2.28-.819l.923-1.597a1.875 1.875 0 0 0-.432-2.385l-.84-.692c-.095-.078-.17-.229-.154-.43a7.614 7.614 0 0 0 0-1.139c-.016-.2.059-.352.153-.43l.841-.692c.708-.582.891-1.59.433-2.385l-.922-1.597a1.875 1.875 0 0 0-2.282-.818l-1.02.382c-.114.043-.282.031-.449-.083a7.49 7.49 0 0 0-.985-.57c-.183-.087-.277-.227-.297-.348l-.179-1.072a1.875 1.875 0 0 0-1.85-1.567h-1.843ZM12 15.75a3.75 3.75 0 1 0 0-7.5 3.75 3.75 0 0 0 0 7.5Z" clip-rule="evenodd"/></svg>
        <div class="sp-card-title" style="color:#dc2626;">⚠️ Maintenance Mode</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-toggle-row" style="border-bottom:none;">
            <div>
                <div class="sp-toggle-label">Enable Maintenance Mode</div>
                <div class="sp-toggle-desc">When ON, all users will see a maintenance notice. Admin access remains active.</div>
            </div>
            <label style="position:relative;display:inline-block;width:46px;height:26px;cursor:pointer;">
                <input type="checkbox" wire:model="settings.maintenance_mode" value="1" style="opacity:0;width:0;height:0;">
                <span style="position:absolute;top:0;left:0;right:0;bottom:0;background:{{ ($settings['maintenance_mode'] ?? '0') === '1' ? '#dc2626' : '#e2e8f0' }};border-radius:999px;transition:0.3s;">
                    <span style="position:absolute;content:'';height:20px;width:20px;left:3px;bottom:3px;background:white;border-radius:50%;transition:0.3s;transform:{{ ($settings['maintenance_mode'] ?? '0') === '1' ? 'translateX(20px)' : 'translateX(0)' }};"></span>
                </span>
            </label>
        </div>
    </div>
</div>

<div class="sp-footer" style="background:transparent;border:none;padding:0 0 16px;">
    <button type="submit" class="sp-save-btn">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path d="M10.75 2.75a.75.75 0 0 0-1.5 0v8.614L6.295 8.235a.75.75 0 1 0-1.09 1.03l4.25 4.5a.75.75 0 0 0 1.09 0l4.25-4.5a.75.75 0 0 0-1.09-1.03l-2.955 3.129V2.75Z"/></svg>
        Save All Settings
    </button>
</div>

</form>
</x-filament-panels::page>

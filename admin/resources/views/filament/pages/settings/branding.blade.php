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
.sp-save-btn { background: linear-gradient(135deg, #0d9488, #0f766e); color: white; border: none; border-radius: 10px; padding: 12px 28px; font-size: 14px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: opacity 0.2s; font-family: 'Outfit', sans-serif; }
.sp-save-btn:hover { opacity: 0.9; }
.sp-logo-preview { width: 100px; height: 100px; border-radius: 8px; border: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: center; background: #f8fafc; overflow: hidden; }
.dark .sp-logo-preview { background: #0f172a; border-color: rgba(255,255,255,0.1); }
</style>

<div class="sp-header">
    <div>
        <div class="sp-header-title">🎨 Branding & Identity Settings</div>
        <div class="sp-header-sub">Customize the look and feel of MurtaaxPay across all channels.</div>
    </div>
</div>

<form wire:submit.prevent="save">

<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#9333ea" style="width:18px;height:18px"><path d="M11.644 3.066a2.25 2.25 0 0 0-3.288 0l-4.72 4.72a.75.75 0 0 0 0 1.06l4.72 4.72a2.25 2.25 0 0 0 3.288 0l4.72-4.72a.75.75 0 0 0 0-1.06l-4.72-4.72Z" /><path d="M14.22 8.28a.75.75 0 1 1-1.06 1.06l-4.72-4.72a2.25 2.25 0 0 1 0-3.182l4.72 4.72.105-.105a2.25 2.25 0 0 1 3.182 0l-1.061 1.06-.106 1.06Z" /></svg>
        <div class="sp-card-title">Logo Assets & Identity</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-2">
            {{-- LOGO --}}
            <div class="sp-field">
                <label class="sp-label">Main Platform Logo (URL)</label>
                <div style="display:flex;gap:16px;align-items:center;">
                    <div class="sp-logo-preview">
                        <img src="{{ Str::startsWith($settings['logo_url'], 'http') ? $settings['logo_url'] : asset($settings['logo_url']) }}" style="max-width:100%;max-height:100%;">
                    </div>
                    <input class="sp-input" wire:model="settings.logo_url" type="text" placeholder="/images/logo.png">
                </div>
            </div>
            {{-- ADMIN LOGO --}}
            <div class="sp-field">
                <label class="sp-label">Admin Panel Logo (URL)</label>
                <div style="display:flex;gap:16px;align-items:center;">
                    <div class="sp-logo-preview">
                        <img src="{{ Str::startsWith($settings['admin_logo_url'], 'http') ? $settings['admin_logo_url'] : asset($settings['admin_logo_url']) }}" style="max-width:100%;max-height:100%;">
                    </div>
                    <input class="sp-input" wire:model="settings.admin_logo_url" type="text" placeholder="/images/admin-logo.png">
                </div>
            </div>
             {{-- FAVICON --}}
            <div class="sp-field">
                <label class="sp-label">Favicon (URL)</label>
                <div style="display:flex;gap:16px;align-items:center;">
                    <div class="sp-logo-preview">
                        <img src="{{ Str::startsWith($settings['favicon_url'], 'http') ? $settings['favicon_url'] : asset($settings['favicon_url']) }}" style="max-width:32px;max-height:32px;">
                    </div>
                    <input class="sp-input" wire:model="settings.favicon_url" type="text" placeholder="/favicon.ico">
                </div>
            </div>
            {{-- EMAIL LOGO --}}
            <div class="sp-field">
                <label class="sp-label">Email Template Logo (URL)</label>
                 <div style="display:flex;gap:16px;align-items:center;">
                    <div class="sp-logo-preview">
                        <img src="{{ Str::startsWith($settings['email_logo_url'], 'http') ? $settings['email_logo_url'] : asset($settings['email_logo_url']) }}" style="max-width:100%;max-height:100%;">
                    </div>
                    <input class="sp-input" wire:model="settings.email_logo_url" type="text" placeholder="/images/email-logo.png">
                </div>
            </div>
        </div>
    </div>
</div>

{{-- COLORS --}}
<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#0d9488" style="width:18px;height:18px"><path fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25ZM9 12.75a.75.75 0 1 0 0-1.5.75.75 0 0 0 0 1.5Zm6.75-1.5a.75.75 0 1 1 0 1.5.75.75 0 0 1 0-1.5ZM12 18.75a.75.75 0 0 1-.75-.75 3 3 0 0 0-6 0 .75.75 0 0 1-1.5 0 4.5 4.5 0 0 1 9 0 .75.75 0 0 1-.75.75Z" clip-rule="evenodd" /></svg>
        <div class="sp-card-title">Brand Aesthetics</div>
    </div>
    <div class="sp-card-body">
         <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">Primary Brand Color</label>
                <div style="display:flex;gap:12px;align-items:center;">
                    <div style="width:40px;height:40px;border-radius:8px;background:{{ $settings['primary_color'] }};border:1px solid #e2e8f0;"></div>
                    <input class="sp-input" wire:model="settings.primary_color" type="text" placeholder="#0d9488">
                </div>
            </div>
        </div>
    </div>
</div>

<div style="display:flex;justify-content:flex-end;padding-bottom:16px;">
    <button type="submit" class="sp-save-btn">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
        Save Identity Settings
    </button>
</div>

</form>
</x-filament-panels::page>

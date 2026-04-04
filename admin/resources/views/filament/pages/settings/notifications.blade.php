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
.sp-grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; }
.sp-field { display: flex; flex-direction: column; gap: 6px; }
.sp-label { font-size: 12px; font-weight: 600; color: #64748b; }
.sp-input { border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px; font-size: 14px; color: #0f172a; background: white; outline: none; transition: border-color 0.2s; width: 100%; font-family: 'Outfit', sans-serif; }
.sp-input:focus { border-color: #14b8a6; box-shadow: 0 0 0 3px rgba(20,184,166,0.12); }
.dark .sp-input { background: #0f172a; border-color: rgba(255,255,255,0.1); color: #f1f5f9; }
.sp-input-secret { font-family: monospace; letter-spacing: 0.1em; }
.sp-section-divider { font-size: 11px; font-weight: 700; letter-spacing: 0.09em; text-transform: uppercase; color: #94a3b8; margin: 20px 0 12px; }
.sp-hint { font-size: 11px; color: #94a3b8; margin-top: 4px; }
.sp-save-btn { background: linear-gradient(135deg, #0d9488, #0f766e); color: white; border: none; border-radius: 10px; padding: 12px 28px; font-size: 14px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: opacity 0.2s; font-family: 'Outfit', sans-serif; }
.sp-save-btn:hover { opacity: 0.9; }
.sp-provider-tab { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; font-size: 12px; font-weight: 700; margin-right: 6px; background: #f8fafc; color: #64748b; border: 1px solid #e2e8f0; }
.sp-provider-tab-active { background: #002147; color: white; border-color: #002147; }
</style>

<div class="sp-header">
    <div>
        <div class="sp-header-title">📣 Notification Settings</div>
        <div class="sp-header-sub">Configure Push (FCM), In-App (Pusher), Email (SMTP), and SMS gateways.</div>
    </div>
</div>

<form wire:submit.prevent="save">

{{-- PUSH NOTIFICATIONS (FCM) --}}
<div class="sp-card">
    <div class="sp-card-header">
        <div style="width:32px;height:32px;border-radius:8px;background:#fff7ed;display:flex;align-items:center;justify-content:center;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#f97316" style="width:16px;height:16px"><path d="M5.85 3.5a.75.75 0 0 0-1.117-1 9.719 9.719 0 0 0-2.348 4.876.75.75 0 0 0 1.479.248A8.219 8.219 0 0 1 5.85 3.5ZM19.267 2.5a.75.75 0 1 0-1.118 1 8.22 8.22 0 0 1 1.987 4.124.75.75 0 0 0 1.48-.248A9.72 9.72 0 0 0 19.266 2.5Z"/><path fill-rule="evenodd" d="M12 2.25A6.75 6.75 0 0 0 5.25 9v.75a8.217 8.217 0 0 1-2.119 5.52.75.75 0 0 0 .298 1.206c1.544.57 3.16.99 4.831 1.243a3.75 3.75 0 1 0 7.48 0 24.583 24.583 0 0 0 4.83-1.244.75.75 0 0 0 .298-1.205 8.217 8.217 0 0 1-2.118-5.52V9A6.75 6.75 0 0 0 12 2.25ZM9.75 18c0-.034 0-.067.002-.1a25.05 25.05 0 0 0 4.496 0l.002.1a2.25 2.25 0 1 1-4.5 0Z" clip-rule="evenodd"/></svg>
        </div>
        <div class="sp-card-title">🔥 Push Notifications (Firebase FCM)</div>
        <span style="font-size:10px;font-weight:700;background:#fff7ed;color:#ea580c;padding:2px 10px;border-radius:999px;margin-left:auto;">FCM</span>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">FCM Project ID</label>
                <input class="sp-input" wire:model="settings.fcm_project_id" type="text" placeholder="murtaaxpay-app">
            </div>
            <div class="sp-field">
                <label class="sp-label">FCM Server Key</label>
                <input class="sp-input sp-input-secret" wire:model="settings.fcm_server_key" type="password" placeholder="AAAA•••••••••••••••••••••••">
                <div class="sp-hint">Get from Firebase Console → Project Settings → Cloud Messaging</div>
            </div>
        </div>
    </div>
</div>

{{-- IN-APP (PUSHER) --}}
<div class="sp-card">
    <div class="sp-card-header">
        <div style="width:32px;height:32px;border-radius:8px;background:#e0f2fe;display:flex;align-items:center;justify-content:center;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#0284c7" style="width:16px;height:16px"><path d="M4.913 2.658c2.075-.27 4.19-.408 6.337-.408 2.147 0 4.262.139 6.337.408 1.922.25 3.291 1.861 3.405 3.727a4.403 4.403 0 0 0-1.032-.211 50.89 50.89 0 0 0-8.42 0c-2.358.196-4.04 2.19-4.04 4.434v4.286a4.47 4.47 0 0 0 2.433 3.984L7.28 21.53A.75.75 0 0 1 6 21v-4.03a48.527 48.527 0 0 1-1.087-.128C2.905 16.58 1.5 14.833 1.5 12.862V6.638c0-1.97 1.405-3.718 3.413-3.979Z"/></svg>
        </div>
        <div class="sp-card-title">💬 In-App Notifications (Pusher)</div>
        <span style="font-size:10px;font-weight:700;background:#e0f2fe;color:#0284c7;padding:2px 10px;border-radius:999px;margin-left:auto;">Pusher</span>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-3">
            <div class="sp-field">
                <label class="sp-label">App ID</label>
                <input class="sp-input" wire:model="settings.pusher_app_id" type="text" placeholder="1234567">
            </div>
            <div class="sp-field">
                <label class="sp-label">App Key</label>
                <input class="sp-input sp-input-secret" wire:model="settings.pusher_app_key" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">App Secret</label>
                <input class="sp-input sp-input-secret" wire:model="settings.pusher_app_secret" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">Cluster</label>
                <input class="sp-input" wire:model="settings.pusher_cluster" type="text" placeholder="eu">
            </div>
        </div>
    </div>
</div>

{{-- EMAIL --}}
<div class="sp-card">
    <div class="sp-card-header">
        <div style="width:32px;height:32px;border-radius:8px;background:#f0fdf4;display:flex;align-items:center;justify-content:center;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#16a34a" style="width:16px;height:16px"><path d="M1.5 8.67v8.58a3 3 0 0 0 3 3h15a3 3 0 0 0 3-3V8.67l-8.928 5.493a3 3 0 0 1-3.144 0L1.5 8.67Z"/><path d="M22.5 6.908V6.75a3 3 0 0 0-3-3h-15a3 3 0 0 0-3 3v.158l9.714 5.978a1.5 1.5 0 0 0 1.572 0L22.5 6.908Z"/></svg>
        </div>
        <div class="sp-card-title">✉️ Email / SMTP Settings</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-3">
            <div class="sp-field">
                <label class="sp-label">Mail Driver</label>
                <input class="sp-input" wire:model="settings.mail_driver" type="text" placeholder="smtp">
            </div>
            <div class="sp-field">
                <label class="sp-label">SMTP Host</label>
                <input class="sp-input" wire:model="settings.mail_host" type="text" placeholder="smtp.mailtrap.io">
            </div>
            <div class="sp-field">
                <label class="sp-label">SMTP Port</label>
                <input class="sp-input" wire:model="settings.mail_port" type="text" placeholder="587">
            </div>
            <div class="sp-field">
                <label class="sp-label">Username</label>
                <input class="sp-input" wire:model="settings.mail_username" type="text" placeholder="your@email.com">
            </div>
            <div class="sp-field">
                <label class="sp-label">Password</label>
                <input class="sp-input sp-input-secret" wire:model="settings.mail_password" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">From Address</label>
                <input class="sp-input" wire:model="settings.mail_from_address" type="email" placeholder="noreply@murtaaxpay.com">
            </div>
        </div>
    </div>
</div>

{{-- SMS --}}
<div class="sp-card">
    <div class="sp-card-header">
        <div style="width:32px;height:32px;border-radius:8px;background:#fef9c3;display:flex;align-items:center;justify-content:center;">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#ca8a04" style="width:16px;height:16px"><path fill-rule="evenodd" d="M4.848 2.771A49.144 49.144 0 0 1 12 2.25c2.43 0 4.817.178 7.152.52 1.978.292 3.348 2.024 3.348 3.97v6.02c0 1.946-1.37 3.678-3.348 3.97a48.901 48.901 0 0 1-3.476.383.39.39 0 0 0-.297.17l-2.755 3.443a.75.75 0 0 1-1.248 0l-2.755-3.443a.39.39 0 0 0-.297-.17 48.9 48.9 0 0 1-3.476-.384c-1.978-.29-3.348-2.024-3.348-3.97V6.741c0-1.946 1.37-3.68 3.348-3.97Z" clip-rule="evenodd"/></svg>
        </div>
        <div class="sp-card-title">📱 SMS Settings</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-3">
            <div class="sp-field">
                <label class="sp-label">SMS Driver</label>
                <input class="sp-input" wire:model="settings.sms_driver" type="text" placeholder="twilio">
                <div class="sp-hint">twilio / nexmo / africas-talking</div>
            </div>
            <div class="sp-field">
                <label class="sp-label">Account SID</label>
                <input class="sp-input sp-input-secret" wire:model="settings.sms_account_sid" type="password" placeholder="AC••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">Auth Token</label>
                <input class="sp-input sp-input-secret" wire:model="settings.sms_auth_token" type="password" placeholder="••••••••••••">
            </div>
            <div class="sp-field">
                <label class="sp-label">From Number</label>
                <input class="sp-input" wire:model="settings.sms_from_number" type="text" placeholder="+1 415 555 0000">
            </div>
        </div>
    </div>
</div>

<div style="display:flex;justify-content:flex-end;padding-bottom:16px;">
    <button type="submit" class="sp-save-btn">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
        Save Notification Settings
    </button>
</div>

</form>
</x-filament-panels::page>

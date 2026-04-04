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
.sp-select { appearance: none; -webkit-appearance: none; -moz-appearance: none; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px; padding-right: 40px; font-size: 14px; color: #0f172a; background: white; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748b'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 12px center; background-size: 16px; outline: none; width: 100%; font-family: 'Outfit', sans-serif; cursor: pointer; transition: border-color 0.2s, box-shadow 0.2s; }
.sp-select:focus { border-color: #14b8a6; box-shadow: 0 0 0 3px rgba(20,184,166,0.12); }
.dark .sp-select { background-color: #0f172a; border-color: rgba(255,255,255,0.1); color: #f1f5f9; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2394a3b8'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E"); }
.sp-save-btn { background: linear-gradient(135deg, #0d9488, #0f766e); color: white; border: none; border-radius: 10px; padding: 12px 28px; font-size: 14px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: opacity 0.2s; font-family: 'Outfit', sans-serif; }
.sp-save-btn:hover { opacity: 0.9; }
</style>

<div class="sp-header">
    <div>
        <div class="sp-header-title">📃 Invoice Settings</div>
        <div class="sp-header-sub">Configure user and merchant invoice preferences.</div>
    </div>
</div>

<form wire:submit.prevent="save">

<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#ea580c" style="width:18px;height:18px"><path d="M5.625 1.5c-1.036 0-1.875.84-1.875 1.875v17.25c0 1.035.84 1.875 1.875 1.875h12.75c1.035 0 1.875-.84 1.875-1.875V12.75A3.75 3.75 0 0 0 16.5 9h-1.875V1.5H5.625Z" /><path d="M12.75 1.5v6.75a2.25 2.25 0 0 0 2.25 2.25h6.75l-9-9Z" /></svg>
        <div class="sp-card-title">Default Settings</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">Invoice Prefix</label>
                <input class="sp-input" wire:model="settings.invoice_prefix" type="text" placeholder="INV-">
            </div>
             <div class="sp-field">
                <label class="sp-label">Default Due Period (Days)</label>
                <input class="sp-input" wire:model="settings.invoice_due_days" type="number" placeholder="7">
            </div>
            <div class="sp-field" style="grid-column: span 2;">
                <label class="sp-label">Footer Text</label>
                <textarea class="sp-input" wire:model="settings.invoice_footer_text" style="height: 100px;" placeholder="Thank you for using MurtaaxPay."></textarea>
            </div>
        </div>
    </div>
</div>

<div class="sp-card">
    <div class="sp-card-header">
         <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#14b8a6" style="width:18px;height:18px"><path fill-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm11.378-3.917c-.89-.777-2.366-.777-3.255 0a.75.75 0 0 1-.988-1.129c1.454-1.272 3.776-1.272 5.23 0 1.454 1.272 1.454 3.329 0 4.601-.42.368-.903.574-1.228.756v.75a.75.75 0 0 1-1.5 0v-1.5a.75.75 0 0 1 .75-.75c.526 0 1.249-.194 1.501-.427.504-.441.504-1.157 0-1.598Z" clip-rule="evenodd"/></svg>
        <div class="sp-card-title">Payment Options & Automations</div>
    </div>
    <div class="sp-card-body">
         <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">Allow Partial Payments</label>
                <select class="sp-select" wire:model="settings.allow_partial_payment">
                    <option value="1">YES – Activated</option>
                    <option value="0">NO – Deactivated</option>
                </select>
            </div>
            <div class="sp-field">
                <label class="sp-label">Automatic Payment Reminders</label>
                <select class="sp-select" wire:model="settings.enable_automatic_reminders">
                    <option value="1">ENABLED</option>
                    <option value="0">DISABLED</option>
                </select>
            </div>
        </div>
    </div>
</div>

<div style="display:flex;justify-content:flex-end;padding-bottom:16px;">
    <button type="submit" class="sp-save-btn">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
        Save Invoice Settings
    </button>
</div>

</form>
</x-filament-panels::page>

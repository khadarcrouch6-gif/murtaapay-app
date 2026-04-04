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
        <div class="sp-header-title">💳 Virtual Card Settings</div>
        <div class="sp-header-sub">Configure Wallester card fees, limits, and KYC requirements.</div>
    </div>
</div>

<form wire:submit.prevent="save">

<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#8b5cf6" style="width:18px;height:18px"><path d="M4.5 3.75a3 3 0 0 0-3 3v.75h21v-.75a3 3 0 0 0-3-3h-15Z" /><path fill-rule="evenodd" d="M22.5 9.75h-21v7.5a3 3 0 0 0 3 3h15a3 3 0 0 0 3-3v-7.5Zm-18 3.75a.75.75 0 0 1 .75-.75h6a.75.75 0 0 1 0 1.5h-6a.75.75 0 0 1-.75-.75Zm.75 2.25a.75.75 0 0 0 0 1.5h3a.75.75 0 0 0 0-1.5h-3Z" clip-rule="evenodd" /></svg>
        <div class="sp-card-title">Card Fees & Limits</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">Issuance Fee (USD)</label>
                <input class="sp-input" wire:model="settings.card_issuance_fee" type="text" placeholder="5.00">
            </div>
            <div class="sp-field">
                <label class="sp-label">Monthly Maintenance Fee (USD)</label>
                <input class="sp-input" wire:model="settings.card_monthly_fee" type="text" placeholder="1.00">
            </div>
            <div class="sp-field">
                <label class="sp-label">Transaction Fee (USD)</label>
                <input class="sp-input" wire:model="settings.card_transaction_fee" type="text" placeholder="0.50">
            </div>
             <div class="sp-field">
                <label class="sp-label">Min. Initial Load (USD)</label>
                <input class="sp-input" wire:model="settings.card_min_load" type="text" placeholder="10.00">
            </div>
            <div class="sp-field">
                <label class="sp-label">Max. Monthly Load (USD)</label>
                <input class="sp-input" wire:model="settings.card_max_load" type="text" placeholder="5000.00">
            </div>
        </div>
    </div>
</div>

<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#0d9488" style="width:18px;height:18px"><path fill-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm-2.625 11.375L6.75 11l-.75.75 3.375 3.375 7.5-7.5-.75-.75-6.75 6.75Z" clip-rule="evenodd" /></svg>
        <div class="sp-card-title">Compliance & Provider</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-2">
            <div class="sp-field">
                <label class="sp-label">Card Provider</label>
                <select class="sp-select" wire:model="settings.card_provider">
                    <option value="wallester">Wallester (Mastercard)</option>
                    <option value="stripe">Stripe Issuing (Visa)</option>
                    <option value="marqeta">Marqeta</option>
                </select>
            </div>
             <div class="sp-field">
                <label class="sp-label">Require KYC Verification</label>
                <select class="sp-select" wire:model="settings.require_kyc_for_card">
                    <option value="1">YES – Required</option>
                    <option value="0">NO – Optional</option>
                </select>
                <div style="font-size:11px;color:#94a3b8;margin-top:4px;">Strongly recommended for Wallester.</div>
            </div>
        </div>
    </div>
</div>

<div style="display:flex;justify-content:flex-end;padding-bottom:16px;">
    <button type="submit" class="sp-save-btn">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
        Save Card Settings
    </button>
</div>

</form>
</x-filament-panels::page>

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
.sp-card-body { padding: 20px 24px; }
.sp-service-row { display: flex; align-items: center; justify-content: space-between; padding: 14px 0; border-bottom: 1px solid #f8fafc; }
.dark .sp-service-row { border-bottom-color: rgba(255,255,255,0.04); }
.sp-service-row:last-child { border-bottom: none; }
.sp-service-icon { width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.sp-service-name { font-size: 14px; font-weight: 600; color: #0f172a; }
.dark .sp-service-name { color: #f1f5f9; }
.sp-service-desc { font-size: 11px; color: #94a3b8; margin-top: 2px; }
.sp-toggle { position: relative; display: inline-block; width: 46px; height: 26px; cursor: pointer; flex-shrink: 0; }
.sp-toggle input { opacity: 0; width: 0; height: 0; }
.sp-toggle-track { position: absolute; top: 0; left: 0; right: 0; bottom: 0; border-radius: 999px; transition: 0.2s; }
.sp-toggle-thumb { position: absolute; height: 20px; width: 20px; left: 3px; bottom: 3px; background: white; border-radius: 50%; transition: 0.2s; }
.sp-save-btn { background: linear-gradient(135deg, #0d9488, #0f766e); color: white; border: none; border-radius: 10px; padding: 12px 28px; font-size: 14px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: opacity 0.2s; font-family: 'Outfit', sans-serif; }
.sp-save-btn:hover { opacity: 0.9; }
.sp-badge-on  { background: #e0fdf4; color: #0d9488; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 999px; }
.sp-badge-off { background: #f8fafc; color: #94a3b8; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 999px; border: 1px solid #e2e8f0; }
</style>

<div class="sp-header">
    <div>
        <div class="sp-header-title">🔌 Services Configuration</div>
        <div class="sp-header-sub">Enable or disable platform features for all users across mobile app and web.</div>
    </div>
    <div style="display:inline-flex;align-items:center;gap:8px;background:rgba(255,255,255,0.12);border:1px solid rgba(255,255,255,0.2);border-radius:999px;padding:8px 16px;font-size:12px;font-weight:700;color:white;">
        {{ collect($settings)->filter(fn($v) => $v == '1')->count() }} / {{ count($settings) }} Active
    </div>
</div>

<form wire:submit.prevent="save">

<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#14b8a6" style="width:18px;height:18px"><path d="M19.5 22.5a3 3 0 0 0 3-3v-8.174l-6.879 4.022 3.485 1.876a.75.75 0 1 1-.712 1.321l-5.683-3.06a1.5 1.5 0 0 0-1.422 0l-5.683 3.06a.75.75 0 0 1-.712-1.32l3.485-1.877L1.5 11.326V19.5a3 3 0 0 0 3 3h15Z"/><path d="M1.5 9.589v-.745a3 3 0 0 1 1.578-2.641l7.5-4.039a3 3 0 0 1 2.844 0l7.5 4.039A3 3 0 0 1 22.5 8.844v.745l-8.426 4.926-.652-.351a3 3 0 0 0-2.844 0l-.652.351L1.5 9.589Z"/></svg>
        <div class="sp-card-title">Money Services</div>
    </div>
    <div class="sp-card-body">
        @foreach([
            ['key' => 'enable_send_money',    'name' => 'Send Money',     'desc' => 'EUR → USD cross-border transfer via Wallester & WAAFI', 'bg' => '#e0fdf4', 'color' => '#0d9488'],
            ['key' => 'enable_request_money', 'name' => 'Request Money',  'desc' => 'Allow users to request payments from contacts', 'bg' => '#ede9fe', 'color' => '#8b5cf6'],
            ['key' => 'enable_exchange',      'name' => 'Currency Exchange', 'desc' => 'In-app FX conversion between supported currencies', 'bg' => '#fef3c7', 'color' => '#f59e0b'],
            ['key' => 'enable_bill_payment',  'name' => 'Bill Payment',   'desc' => 'Pay utilities, internet, and mobile bills', 'bg' => '#f0f9ff', 'color' => '#0284c7'],
            ['key' => 'enable_mobile_topup',  'name' => 'Mobile Top-Up',  'desc' => 'Recharge mobile airtime for Somali networks', 'bg' => '#fff7ed', 'color' => '#ea580c'],
        ] as $svc)
        <div class="sp-service-row">
            <div style="display:flex;align-items:center;gap:12px;flex:1;">
                <div class="sp-service-icon" style="background:{{ $svc['bg'] }}">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="{{ $svc['color'] }}" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
                </div>
                <div>
                    <div class="sp-service-name">{{ $svc['name'] }}</div>
                    <div class="sp-service-desc">{{ $svc['desc'] }}</div>
                </div>
            </div>
            <div style="display:flex;align-items:center;gap:12px;">
                <span class="{{ ($settings[$svc['key']] ?? '0') === '1' ? 'sp-badge-on' : 'sp-badge-off' }}">
                    {{ ($settings[$svc['key']] ?? '0') === '1' ? '● Enabled' : '○ Disabled' }}
                </span>
                <label class="sp-toggle">
                    <input type="checkbox" wire:model="settings.{{ $svc['key'] }}" value="1">
                    <div class="sp-toggle-track" style="background:{{ ($settings[$svc['key']] ?? '0') === '1' ? '#14b8a6' : '#e2e8f0' }};"></div>
                    <div class="sp-toggle-thumb" style="transform:{{ ($settings[$svc['key']] ?? '0') === '1' ? 'translateX(20px)' : 'translateX(0)' }};"></div>
                </label>
            </div>
        </div>
        @endforeach
    </div>
</div>

<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#6366f1" style="width:18px;height:18px"><path d="M12 .75a8.25 8.25 0 0 0-4.135 15.39c.686.398 1.115 1.008 1.134 1.623a.75.75 0 0 0 .577.706c.352.083.71.148 1.074.195.323.041.6-.218.6-.544v-4.661a6.714 6.714 0 0 1-.937-.171.75.75 0 1 1 .374-1.453 5.261 5.261 0 0 0 2.626 0 .75.75 0 1 1 .374 1.453 6.533 6.533 0 0 1-.937.171v4.66c0 .327.277.586.6.545.364-.047.722-.112 1.074-.195a.75.75 0 0 0 .577-.706c.02-.615.448-1.225 1.134-1.623A8.25 8.25 0 0 0 12 .75Z"/></svg>
        <div class="sp-card-title">Advanced Features</div>
    </div>
    <div class="sp-card-body">
        @foreach([
            ['key' => 'enable_virtual_card',  'name' => 'Virtual Cards',    'desc' => 'Issue Wallester Mastercard virtual cards to verified users', 'bg' => '#ede9fe', 'color' => '#7c3aed'],
            ['key' => 'enable_savings',       'name' => 'Savings Goals',    'desc' => 'Let users set and track savings targets', 'bg' => '#e0fdf4', 'color' => '#16a34a'],
            ['key' => 'enable_investments',   'name' => 'Investments',      'desc' => 'In-app investment portfolio tracking (coming soon)', 'bg' => '#fef3c7', 'color' => '#d97706'],
            ['key' => 'enable_refer_earn',    'name' => 'Refer & Earn',     'desc' => 'Referral program with reward bonuses', 'bg' => '#fff7ed', 'color' => '#ea580c'],
            ['key' => 'enable_gift_cards',    'name' => 'Gift Cards',       'desc' => 'Buy & send digital gift cards', 'bg' => '#fdf2f8', 'color' => '#db2777'],
            ['key' => 'enable_sadaqah',       'name' => 'Sadaqah Module',   'desc' => 'Charitable giving and zakat calculation', 'bg' => '#f0f9ff', 'color' => '#0284c7'],
            ['key' => 'enable_voucher',       'name' => 'Vouchers',         'desc' => 'Create and redeem payment vouchers', 'bg' => '#fef9c3', 'color' => '#ca8a04'],
        ] as $svc)
        <div class="sp-service-row">
            <div style="display:flex;align-items:center;gap:12px;flex:1;">
                <div class="sp-service-icon" style="background:{{ $svc['bg'] }}">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="{{ $svc['color'] }}" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
                </div>
                <div>
                    <div class="sp-service-name">{{ $svc['name'] }}</div>
                    <div class="sp-service-desc">{{ $svc['desc'] }}</div>
                </div>
            </div>
            <div style="display:flex;align-items:center;gap:12px;">
                <span class="{{ ($settings[$svc['key']] ?? '0') === '1' ? 'sp-badge-on' : 'sp-badge-off' }}">
                    {{ ($settings[$svc['key']] ?? '0') === '1' ? '● Enabled' : '○ Disabled' }}
                </span>
                <label class="sp-toggle">
                    <input type="checkbox" wire:model="settings.{{ $svc['key'] }}" value="1">
                    <div class="sp-toggle-track" style="background:{{ ($settings[$svc['key']] ?? '0') === '1' ? '#14b8a6' : '#e2e8f0' }};"></div>
                    <div class="sp-toggle-thumb" style="transform:{{ ($settings[$svc['key']] ?? '0') === '1' ? 'translateX(20px)' : 'translateX(0)' }};"></div>
                </label>
            </div>
        </div>
        @endforeach
    </div>
</div>

<div style="display:flex;justify-content:flex-end;padding-bottom:16px;">
    <button type="submit" class="sp-save-btn">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
        Save Service Settings
    </button>
</div>

</form>
</x-filament-panels::page>

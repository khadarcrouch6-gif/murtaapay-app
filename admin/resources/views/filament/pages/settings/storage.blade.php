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
        <div class="sp-header-title">☁️ Storage Settings</div>
        <div class="sp-header-sub">Configure where your user uploads, KYC documents, and media are stored.</div>
    </div>
</div>

<form wire:submit.prevent="save">

<div class="sp-card">
    <div class="sp-card-header">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#0369a1" style="width:18px;height:18px"><path fill-rule="evenodd" d="M12 2.25a.75.75 0 0 1 .75.75v11.69l3.22-3.22a.75.75 0 1 1 1.06 1.06l-4.5 4.5a.75.75 0 0 1-1.06 0l-4.5-4.5a.75.75 0 1 1 1.06-1.06l3.22 3.22V3a.75.75 0 0 1 .75-.75Zm-9 13.5a.75.75 0 0 1 .75.75v2.25a3.375 3.375 0 0 0 3.375 3.375h10.51c1.864 0 3.375-1.511 3.375-3.375V16.5a.75.75 0 0 1 1.5 0v2.25a4.875 4.875 0 0 1-4.875 4.875H7.125A4.875 4.875 0 0 1 2.25 18.75V16.5a.75.75 0 0 1 .75-.75Z" clip-rule="evenodd" /></svg>
        <div class="sp-card-title">Storage Provider</div>
    </div>
    <div class="sp-card-body">
        <div class="sp-grid-2">
            <div class="sp-field" style="grid-column: span 2;">
                <label class="sp-label">Current Storage Driver</label>
                <select class="sp-select" wire:model="settings.storage_driver">
                    <option value="local">LOCAL DISK – /storage/app</option>
                    <option value="s3">AMAZON S3 – Scalable Cloud Storage</option>
                    <option value="r2">CLOUDFLARE R2 – Low-Cost S3 Compatible</option>
                </select>
            </div>
        </div>

        @if(($settings['storage_driver'] ?? 'local') !== 'local')
        <div style="margin-top: 24px; padding-top: 24px; border-top: 1px solid #f1f5f9;" class="dark:border-slate-800">
             <div class="sp-grid-2">
                <div class="sp-field">
                    <label class="sp-label">Access Key ID</label>
                    <input class="sp-input" wire:model="settings.aws_access_key_id" type="text" placeholder="AKIA...">
                </div>
                 <div class="sp-field">
                    <label class="sp-label">Secret Access Key</label>
                    <input class="sp-input" wire:model="settings.aws_secret_access_key" type="password" placeholder="••••••••••••">
                </div>
                <div class="sp-field">
                    <label class="sp-label">Region</label>
                    <input class="sp-input" wire:model="settings.aws_default_region" type="text" placeholder="us-east-1">
                </div>
                 <div class="sp-field">
                    <label class="sp-label">Bucket Name</label>
                    <input class="sp-input" wire:model="settings.aws_bucket" type="text" placeholder="murtaaxpay-uploads">
                </div>
                @if(($settings['storage_driver'] ?? 'local') === 'r2')
                <div class="sp-field" style="grid-column: span 2;">
                    <label class="sp-label">R2 Endpoint URL</label>
                    <input class="sp-input" wire:model="settings.cloudflare_r2_endpoint" type="text" placeholder="https://<account_id>.r2.cloudflarestorage.com">
                </div>
                @endif
            </div>
        </div>
        @endif
    </div>
</div>

<div style="display:flex;justify-content:flex-end;padding-bottom:16px;">
    <button type="submit" class="sp-save-btn">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
        Update Storage Config
    </button>
</div>

</form>
</x-filament-panels::page>

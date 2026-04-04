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
.sp-field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 16px; }
.sp-label { font-size: 12px; font-weight: 600; color: #64748b; }
.sp-input { border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px; font-size: 14px; color: #0f172a; background: white; outline: none; transition: border-color 0.2s; width: 100%; font-family: 'Outfit', sans-serif; }
.sp-input:focus { border-color: #14b8a6; box-shadow: 0 0 0 3px rgba(20,184,166,0.12); }
.dark .sp-input { background: #0f172a; border-color: rgba(255,255,255,0.1); color: #f1f5f9; }
.sp-save-btn { background: linear-gradient(135deg, #0d9488, #0f766e); color: white; border: none; border-radius: 10px; padding: 12px 28px; font-size: 14px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: opacity 0.2s; font-family: 'Outfit', sans-serif; }
.sp-save-btn:hover { opacity: 0.9; }

.lang-tabs { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; }
.lang-tab { padding: 8px 16px; border-radius: 8px; font-size: 12px; font-weight: 700; cursor: pointer; border: 1px solid #e2e8f0; background: white; color: #64748b; transition: all 0.2s; }
.lang-tab.active { background: #0d9488; color: white; border-color: #0d9488; }
.dark .lang-tab { background: #0f172a; border-color: rgba(255,255,255,0.1); color: #94a3b8; }
.dark .lang-tab.active { background: #14b8a6; color: white; border-color: #14b8a6; }
</style>

<div class="sp-header">
    <div>
        <div class="sp-header-title">✨ Hero & Landing Settings</div>
        <div class="sp-header-sub">Manage the main website hero section and call-to-action in all languages.</div>
    </div>
</div>

<form wire:submit.prevent="save">
    <div x-data="{ lang: 'en' }">
        <div class="lang-tabs">
            <div class="lang-tab" :class="lang === 'en' ? 'active' : ''" @click="lang = 'en'">🇺🇸 English</div>
            <div class="lang-tab" :class="lang === 'so' ? 'active' : ''" @click="lang = 'so'">🇸🇴 Somali</div>
            <div class="lang-tab" :class="lang === 'ar' ? 'active' : ''" @click="lang = 'ar'">🇸🇦 Arabic</div>
            <div class="lang-tab" :class="lang === 'de' ? 'active' : ''" @click="lang = 'de'">🇩🇪 German</div>
        </div>

        {{-- English --}}
        <div x-show="lang === 'en'" class="sp-card">
            <div class="sp-card-header">
                <div class="sp-card-title">English Hero Content</div>
            </div>
            <div class="sp-card-body">
                <div class="sp-field">
                    <label class="sp-label">Hero Title (EN)</label>
                    <input class="sp-input" wire:model="settings.hero_title_en" placeholder="Send Money Home, Instantly">
                </div>
                <div class="sp-field">
                    <label class="sp-label">Hero Subtitle (EN)</label>
                    <textarea class="sp-input" wire:model="settings.hero_subtitle_en" rows="3"></textarea>
                </div>
                <div class="sp-field">
                    <label class="sp-label">CTA Label (EN)</label>
                    <input class="sp-input" wire:model="settings.hero_cta_en" placeholder="Get Started">
                </div>
            </div>
        </div>

        {{-- Somali --}}
        <div x-show="lang === 'so'" class="sp-card">
            <div class="sp-card-header">
                <div class="sp-card-title">Somali Hero Content (Af-Soomaali)</div>
            </div>
            <div class="sp-card-body">
                <div class="sp-field">
                    <label class="sp-label">Hero Title (SO)</label>
                    <input class="sp-input" wire:model="settings.hero_title_so" placeholder="Lacag Ku Dir Guriga">
                </div>
                <div class="sp-field">
                    <label class="sp-label">Hero Subtitle (SO)</label>
                    <textarea class="sp-input" wire:model="settings.hero_subtitle_so" rows="3"></textarea>
                </div>
                <div class="sp-field">
                    <label class="sp-label">CTA Label (SO)</label>
                    <input class="sp-input" wire:model="settings.hero_cta_so" placeholder="Hadda Bilow">
                </div>
            </div>
        </div>

        {{-- Arabic --}}
        <div x-show="lang === 'ar'" class="sp-card">
            <div class="sp-card-header">
                <div class="sp-card-title">Arabic Hero Content (العربية)</div>
            </div>
            <div class="sp-card-body" dir="rtl">
                <div class="sp-field">
                    <label class="sp-label">Hero Title (AR)</label>
                    <input class="sp-input" wire:model="settings.hero_title_ar">
                </div>
                <div class="sp-field">
                    <label class="sp-label">Hero Subtitle (AR)</label>
                    <textarea class="sp-input" wire:model="settings.hero_subtitle_ar" rows="3"></textarea>
                </div>
                <div class="sp-field">
                    <label class="sp-label">CTA Label (AR)</label>
                    <input class="sp-input" wire:model="settings.hero_cta_ar">
                </div>
            </div>
        </div>

        {{-- German --}}
        <div x-show="lang === 'de'" class="sp-card">
            <div class="sp-card-header">
                <div class="sp-card-title">German Hero Content (Deutsch)</div>
            </div>
            <div class="sp-card-body">
                <div class="sp-field">
                    <label class="sp-label">Hero Title (DE)</label>
                    <input class="sp-input" wire:model="settings.hero_title_de">
                </div>
                <div class="sp-field">
                    <label class="sp-label">Hero Subtitle (DE)</label>
                    <textarea class="sp-input" wire:model="settings.hero_subtitle_de" rows="3"></textarea>
                </div>
                <div class="sp-field">
                    <label class="sp-label">CTA Label (DE)</label>
                    <input class="sp-input" wire:model="settings.hero_cta_de">
                </div>
            </div>
        </div>

        {{-- Common --}}
        <div class="sp-card">
            <div class="sp-card-header">
                <div class="sp-card-title">Global Component Settings</div>
            </div>
            <div class="sp-card-body">
                <div class="sp-field">
                    <label class="sp-label">Hero Image URL (Optional)</label>
                    <input class="sp-input" wire:model="settings.hero_image" placeholder="https://...">
                </div>
                <div class="sp-field">
                    <label class="sp-label">CTA Redirect URL</label>
                    <input class="sp-input" wire:model="settings.hero_cta_url" placeholder="/signup">
                </div>
            </div>
        </div>
    </div>

    <div style="display:flex;justify-content:flex-end;padding-bottom:16px;">
        <button type="submit" class="sp-save-btn">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" style="width:16px;height:16px"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd"/></svg>
            Update Landing Content
        </button>
    </div>
</form>
</x-filament-panels::page>

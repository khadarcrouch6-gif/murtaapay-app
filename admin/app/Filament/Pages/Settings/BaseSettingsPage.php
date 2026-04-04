<?php

namespace App\Filament\Pages\Settings;

use Filament\Pages\Page;
use Filament\Notifications\Notification;
use App\Models\CmsSetting;
use App\Models\ActivityLog;
use Livewire\Attributes\Computed;

abstract class BaseSettingsPage extends Page
{
    public array $settings = [];

    /**
     * Define settings keys and their defaults for this page.
     * [ 'key' => 'default_value', ... ]
     */
    abstract protected function settingsKeys(): array;

    /** The CMS group name for this settings page */
    abstract protected function settingsGroup(): string;

    public function mount(): void
    {
        $saved = CmsSetting::group($this->settingsGroup());
        $this->settings = array_merge($this->settingsKeys(), $saved);
    }

    public function save(): void
    {
        foreach ($this->settings as $key => $value) {
            CmsSetting::set($key, $value, 'text', $this->settingsGroup());
        }

        ActivityLog::record('settings_updated', null, [], [
            'group' => $this->settingsGroup(),
            'keys'  => array_keys($this->settings),
        ]);

        Notification::make()
            ->title('Settings saved successfully!')
            ->success()
            ->send();
    }
}

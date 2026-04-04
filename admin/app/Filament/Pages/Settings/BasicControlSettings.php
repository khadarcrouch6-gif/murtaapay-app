<?php
namespace App\Filament\Pages\Settings;
use App\Models\ActivityLog;
class BasicControlSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-adjustments-horizontal';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Basic Control';
    protected static ?string $title           = 'Basic Control Settings';
    protected static ?int    $navigationSort  = 2;
    protected static string  $view            = 'filament.pages.settings.basic-control';
    protected function settingsGroup(): string { return 'basic'; }
    protected function settingsKeys(): array {
        return [
            'site_name'        => 'MurtaaxPay',
            'site_tagline'     => 'Send Money Home, Instantly',
            'timezone'         => 'Africa/Mogadishu',
            'default_currency' => 'USD',
            'default_language' => 'en',
            'support_email'    => 'support@murtaaxpay.com',
            'support_phone'    => '+252 61 000 0000',
            'app_version'      => '2.4.1',
            'maintenance_mode' => '0',
        ];
    }
}

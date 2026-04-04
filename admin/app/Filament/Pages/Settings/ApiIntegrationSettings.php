<?php
namespace App\Filament\Pages\Settings;
class ApiIntegrationSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-arrow-path';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'API Integrations';
    protected static ?string $title           = 'API & Integration Settings';
    protected static ?int    $navigationSort  = 5;
    protected static string  $view            = 'filament.pages.settings.api-integrations';
    protected function settingsGroup(): string { return 'api'; }
    protected function settingsKeys(): array {
        return [
            // Wallester
            'wallester_api_key'        => '',
            'wallester_secret_token'   => '',
            'wallester_endpoint'       => 'https://api.wallester.com/v1',
            'wallester_webhook_secret' => '',
            // WAAFI (Somalia Payouts)
            'waafi_merchant_uid' => '',
            'waafi_api_user_id'  => '',
            'waafi_api_key'      => '',
            'waafi_endpoint'     => 'https://api.waafipay.net/asm',

            // e-Dahab / Dahab Plus (Somalia Payouts)
            'edahab_merchant_pid' => '',
            'edahab_api_key'      => '',
            'edahab_secret_key'   => '',
            'edahab_endpoint'     => 'https://api.edahab.so/transfer',
            // Exchange Rate API
            'fx_api_provider' => 'exchangerate-api',
            'fx_api_key'      => '',
            'fx_api_endpoint' => 'https://v6.exchangerate-api.com/v6',
            'fx_auto_sync'    => '1',
            'fx_sync_interval_minutes' => '60',
        ];
    }
}

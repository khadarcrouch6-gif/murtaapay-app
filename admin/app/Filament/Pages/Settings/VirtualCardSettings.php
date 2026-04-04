<?php
namespace App\Filament\Pages\Settings;
class VirtualCardSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-m-credit-card';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Virtual Card';
    protected static ?string $title           = 'Virtual Card Settings';
    protected static ?int    $navigationSort  = 6;
    protected static string  $view            = 'filament.pages.settings.virtual-card';
    protected function settingsGroup(): string { return 'virtual_card'; }
    protected function settingsKeys(): array {
        return [
            'card_issuance_fee'      => '5.00',
            'card_monthly_fee'       => '1.00',
            'card_transaction_fee'   => '0.50',
            'card_min_load'          => '10.00',
            'card_max_load'          => '5000.00',
            'card_provider'          => 'wallester',
            'require_kyc_for_card'   => '1',
            'allow_withdrawal_to_card' => '0',
        ];
    }
}

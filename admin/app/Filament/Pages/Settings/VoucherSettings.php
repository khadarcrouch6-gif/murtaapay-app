<?php
namespace App\Filament\Pages\Settings;
class VoucherSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-ticket';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Voucher';
    protected static ?string $title           = 'Voucher Settings';
    protected static ?int    $navigationSort  = 7;
    protected static string  $view            = 'filament.pages.settings.vouchers';
    protected function settingsGroup(): string { return 'vouchers'; }
    protected function settingsKeys(): array {
        return [
            'allow_user_create_voucher' => '1',
            'voucher_create_fee'       => '0.50',
            'min_voucher_amount'       => '1.00',
            'max_voucher_amount'       => '1000.00',
            'voucher_expiration_days'  => '30',
        ];
    }
}

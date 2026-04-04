<?php
namespace App\Filament\Pages\Settings;
class ServicesSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-squares-2x2';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Services';
    protected static ?string $title           = 'Services Settings';
    protected static ?int    $navigationSort  = 3;
    protected static string  $view            = 'filament.pages.settings.services';
    protected function settingsGroup(): string { return 'services'; }
    protected function settingsKeys(): array {
        return [
            'enable_send_money'      => '1',
            'enable_request_money'   => '1',
            'enable_exchange'        => '1',
            'enable_bill_payment'    => '1',
            'enable_mobile_topup'    => '1',
            'enable_virtual_card'    => '1',
            'enable_savings'         => '0',
            'enable_investments'     => '0',
            'enable_refer_earn'      => '1',
            'enable_gift_cards'      => '0',
            'enable_sadaqah'         => '1',
            'enable_voucher'         => '1',
        ];
    }
}

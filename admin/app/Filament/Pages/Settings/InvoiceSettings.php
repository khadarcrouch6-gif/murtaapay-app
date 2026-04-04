<?php
namespace App\Filament\Pages\Settings;
class InvoiceSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-document-duplicate';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Invoice';
    protected static ?string $title           = 'Invoice Settings';
    protected static ?int    $navigationSort  = 8;
    protected static string  $view            = 'filament.pages.settings.invoices';
    protected function settingsGroup(): string { return 'invoices'; }
    protected function settingsKeys(): array {
        return [
            'invoice_prefix'         => 'INV-',
            'invoice_due_days'       => '7',
            'invoice_footer_text'    => 'Thank you for using MurtaaxPay.',
            'allow_partial_payment'  => '0',
            'enable_automatic_reminders' => '1',
        ];
    }
}

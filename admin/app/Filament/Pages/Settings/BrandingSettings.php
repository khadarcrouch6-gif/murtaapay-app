<?php
namespace App\Filament\Pages\Settings;
class BrandingSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-photo';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Branding';
    protected static ?string $title           = 'Branding & Identity';
    protected static ?int    $navigationSort  = 10;
    protected static string  $view            = 'filament.pages.settings.branding';
    protected function settingsGroup(): string { return 'branding'; }
    protected function settingsKeys(): array {
        return [
            'logo_url'        => '/images/logo.png',
            'admin_logo_url'  => '/images/admin-logo.png',
            'favicon_url'     => '/favicon.ico',
            'email_logo_url'  => '/images/email-logo.png',
            'primary_color'   => '#0d9488',
        ];
    }
}

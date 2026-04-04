<?php
namespace App\Filament\Pages\Settings;
class StorageSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-server-stack';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Storage';
    protected static ?string $title           = 'Storage Settings';
    protected static ?int    $navigationSort  = 9;
    protected static string  $view            = 'filament.pages.settings.storage';
    protected function settingsGroup(): string { return 'storage'; }
    protected function settingsKeys(): array {
        return [
            'storage_driver'         => 'local',
            'aws_access_key_id'      => '',
            'aws_secret_access_key'  => '',
            'aws_default_region'     => 'us-east-1',
            'aws_bucket'             => '',
            'cloudflare_r2_endpoint' => '',
        ];
    }
}

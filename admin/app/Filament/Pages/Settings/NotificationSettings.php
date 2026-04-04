<?php
namespace App\Filament\Pages\Settings;
class NotificationSettings extends BaseSettingsPage {
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-bell-alert';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Notifications';
    protected static ?string $title           = 'Notification Settings';
    protected static ?int    $navigationSort  = 4;
    protected static string  $view            = 'filament.pages.settings.notifications';
    protected function settingsGroup(): string { return 'notifications'; }
    protected function settingsKeys(): array {
        return [
            'fcm_server_key'       => '',
            'fcm_project_id'       => '',
            'pusher_app_id'        => '',
            'pusher_app_key'       => '',
            'pusher_app_secret'    => '',
            'pusher_cluster'       => 'eu',
            'mail_driver'          => 'smtp',
            'mail_host'            => 'smtp.mailtrap.io',
            'mail_port'            => '587',
            'mail_username'        => '',
            'mail_password'        => '',
            'mail_from_address'    => 'noreply@murtaaxpay.com',
            'mail_from_name'       => 'MurtaaxPay',
            'sms_driver'           => 'twilio',
            'sms_account_sid'      => '',
            'sms_auth_token'       => '',
            'sms_from_number'      => '',
        ];
    }
}

<?php

namespace App\Filament\Pages;

use App\Models\CmsSetting;
use Filament\Pages\Page;

class ControlPanel extends Page
{
    protected static ?string $navigationIcon  = 'heroicon-o-adjustments-vertical';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Control Panel';
    protected static ?string $title           = 'Control Panel';
    protected static ?int    $navigationSort  = 1;

    protected static string $view = 'filament.pages.control-panel';

    protected function getViewData(): array
    {
        return [
            'app_version'      => CmsSetting::get('app_version', '2.4.1'),
            'maintenance_mode' => CmsSetting::get('maintenance_mode', '0'),
            'default_currency' => CmsSetting::get('default_currency', 'USD'),
            'site_name'        => CmsSetting::get('site_name', 'MurtaaxPay'),
        ];
    }
}

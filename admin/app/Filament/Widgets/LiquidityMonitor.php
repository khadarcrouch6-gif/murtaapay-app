<?php

namespace App\Filament\Widgets;

use App\Models\FloatAccount;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class LiquidityMonitor extends BaseWidget
{
    protected static ?int $sort = -1;

    protected function getStats(): array
    {
        $waafi     = FloatAccount::where('provider', 'waafi')->first();
        $wallester = FloatAccount::where('provider', 'wallester')->first();
        $edahab    = FloatAccount::where('provider', 'edahab')->first();

        return [
            Stat::make('WAAFI Float (USD)', $waafi ? '$' . number_format($waafi->balance / 100, 0) : '$0')
                ->description($waafi?->is_low ? '🔴 Low Liquidity' : '🟢 Healthy Float')
                ->descriptionIcon($waafi?->is_low ? 'heroicon-m-arrow-trending-down' : 'heroicon-m-check-badge')
                ->chart([7, 3, 4, 5, 6, 3, 4])
                ->color($waafi?->is_low ? 'danger' : 'success'),

            Stat::make('Wallester Pool (EUR)', $wallester ? '€' . number_format($wallester->balance / 100, 0) : '€0')
                ->description('Settlement Balance')
                ->descriptionIcon('heroicon-m-banknotes')
                ->chart([10, 15, 12, 14, 18, 20, 22])
                ->color('info'),

            Stat::make('e-Dahab Float (USD)', $edahab ? '$' . number_format($edahab->balance / 100, 0) : '$0')
                ->description($edahab?->is_low ? '⚠️ Low Reserve' : '🟢 Ready for Payout')
                ->descriptionIcon($edahab?->is_low ? 'heroicon-m-exclamation-triangle' : 'heroicon-m-bolt')
                ->color($edahab?->is_low ? 'warning' : 'success'),
        ];
    }
}

<?php

namespace App\Filament\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use App\Models\User;
use App\Models\Wallet;
use App\Models\Transaction;
use App\Models\KycVerification;

class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 0;

    protected function getStats(): array
    {
        $totalUsers      = User::count();
        $lastMonthUsers  = User::where('created_at', '<', now()->subMonth())->count();
        $userGrowth      = $lastMonthUsers > 0
            ? round((($totalUsers - $lastMonthUsers) / $lastMonthUsers) * 100, 1)
            : 0;

        $activeWallets   = Wallet::where('status', 'active')->count();
        $totalRevenue    = Transaction::where('status', 'completed')->sum('fee_amount'); // total fees collected
        $pendingKycs     = KycVerification::where('status', 'pending')->count();
        $todayTx         = Transaction::whereDate('created_at', today())->count();

        return [
            Stat::make('Total Users', number_format($totalUsers))
                ->description($userGrowth . '% vs last month')
                ->descriptionIcon($userGrowth >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->chart(
                    collect(range(6, 0))->map(fn($i) =>
                        User::where('created_at', '>=', now()->subDays($i + 1))
                            ->where('created_at', '<', now()->subDays($i))
                            ->count()
                    )->toArray()
                )
                ->color($userGrowth >= 0 ? 'success' : 'danger'),

            Stat::make('Active Wallets', number_format($activeWallets))
                ->description('Total Balance: $' . number_format(Wallet::sum('balance') / 100, 2))
                ->descriptionIcon('heroicon-m-wallet')
                ->color('info'),

            Stat::make('Revenue Collected', '$' . number_format($totalRevenue / 100, 2))
                ->description('From completed transactions')
                ->descriptionIcon('heroicon-m-presentation-chart-line')
                ->chart(
                    collect(range(5, 0))->map(fn($i) =>
                        (int)(Transaction::where('status', 'completed')
                            ->whereMonth('created_at', now()->subMonths($i)->month)
                            ->sum('fee_amount') / 100)
                    )->toArray()
                )
                ->color('primary'),

            Stat::make('Pending KYCs', $pendingKycs)
                ->description($todayTx . ' transactions today')
                ->descriptionIcon('heroicon-m-shield-check')
                ->color($pendingKycs > 10 ? 'danger' : 'warning'),
        ];
    }
}

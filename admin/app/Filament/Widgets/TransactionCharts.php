<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;

use App\Models\Transaction;
use Carbon\Carbon;

class TransactionCharts extends ChartWidget
{
    protected static ?string $heading = 'Monthly Financial Overview';

    protected static ?int $sort = 3;

    protected function getData(): array
    {
        return [
            'datasets' => [
                [
                    'label' => 'Volume ($)',
                    'data' => [4500, 6200, 5800, 7500, 9200, 11000],
                    'backgroundColor' => '#14B8A6',
                    'borderColor' => '#0F766E',
                    'borderRadius' => 4,
                ],
                [
                    'label' => 'Revenue / Fees ($)',
                    'data' => [450, 620, 580, 750, 920, 1100],
                    'backgroundColor' => '#6366F1',
                    'borderColor' => '#4338CA',
                    'borderRadius' => 4,
                ],
            ],
            'labels' => ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}

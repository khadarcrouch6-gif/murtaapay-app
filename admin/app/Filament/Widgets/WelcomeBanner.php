<?php

namespace App\Filament\Widgets;

use Filament\Widgets\Widget;

class WelcomeBanner extends Widget
{
    protected static string $view = 'filament.widgets.welcome-banner';

    protected static ?int $sort = -2; // Always on top

    protected int | string | array $columnSpan = 'full';

    public function getGreeting(): string
    {
        $hour = now()->format('H');

        if ($hour < 12) {
            return 'Subax Wanaagsan';
        } elseif ($hour < 17) {
            return 'Galab Wanaagsan';
        } else {
            return 'Habeen Wanaagsan';
        }
    }
}

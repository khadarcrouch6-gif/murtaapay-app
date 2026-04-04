<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\KycVerification;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Filament\Tables\Actions\Action;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;

class RecentSignupsWidget extends BaseWidget
{
    protected static ?int $sort = 2; // Below the main stats

    protected int | string | array $columnSpan = 'full';

    protected static ?string $heading = '🛡️ Recent Signups & KYC Status';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                User::query()
                    ->where('is_admin', false)
                    ->with('kycVerification')
                    ->latest()
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->description(fn (User $record): string => $record->email)
                    ->searchable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Joined')
                    ->dateTime()
                    ->since()
                    ->sortable(),
                Tables\Columns\TextColumn::make('kycVerification.status')
                    ->label('KYC Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending'  => 'warning',
                        'verified' => 'success',
                        'rejected' => 'danger',
                        default    => 'gray',
                    })
                    ->default('none'),
                Tables\Columns\TextColumn::make('tier')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'basic'  => 'gray',
                        'silver' => 'info',
                        'gold'   => 'success',
                    }),
            ])
            ->actions([
                Action::make('quickVerify')
                    ->label('Verify & Upgrade')
                    ->icon('heroicon-m-check-badge')
                    ->color('success')
                    ->visible(fn (User $record) => optional($record->kycVerification)->status === 'pending')
                    ->action(function (User $record) {
                        $record->kycVerification()->update(['status' => 'verified']);
                        $record->update([
                            'tier' => 'silver',
                            'daily_limit' => 500000,
                            'monthly_limit' => 2500000,
                        ]);

                        Notification::make()
                            ->title('User Verified!')
                            ->body("{$record->name} upgraded to Silver Tier.")
                            ->success()
                            ->send();
                    }),
                Action::make('viewKYC')
                    ->label('Review Docs')
                    ->icon('heroicon-m-eye')
                    ->url(fn (User $record): string => $record->kycVerification 
                        ? route('filament.admin.resources.kyc-verifications.edit', $record->kycVerification->id)
                        : route('filament.admin.resources.users.edit', $record->id)
                    )
            ]);
    }
}

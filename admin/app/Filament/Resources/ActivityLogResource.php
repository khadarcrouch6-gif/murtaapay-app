<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ActivityLogResource\Pages;
use App\Models\ActivityLog;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ActivityLogResource extends Resource
{
    protected static ?string $model = ActivityLog::class;

    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';

    protected static ?string $navigationGroup = 'System';

    protected static ?string $navigationLabel = 'Audit Log';

    protected static ?int $navigationSort = 10;

    public static function canCreate(): bool
    {
        return false; // Read-only resource
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Time')
                    ->dateTime()
                    ->since()
                    ->sortable(),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Admin')
                    ->default('System')
                    ->searchable(),
                Tables\Columns\TextColumn::make('action')
                    ->badge()
                    ->color(fn (string $state): string => match (true) {
                        str_contains($state, 'create') => 'success',
                        str_contains($state, 'update') => 'info',
                        str_contains($state, 'delete') => 'danger',
                        str_contains($state, 'login')  => 'warning',
                        default                        => 'gray',
                    }),
                Tables\Columns\TextColumn::make('model_type')
                    ->label('Resource')
                    ->badge()
                    ->color('gray'),
                Tables\Columns\TextColumn::make('model_id')
                    ->label('Record ID')
                    ->fontFamily('mono'),
                Tables\Columns\TextColumn::make('ip_address')
                    ->label('IP Address')
                    ->fontFamily('mono')
                    ->toggleable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('model_type')
                    ->options([
                        'User'        => 'User',
                        'Transaction' => 'Transaction',
                        'FxRate'      => 'FX Rate',
                        'FeeSetting'  => 'Fee Setting',
                        'FloatAccount'=> 'Float Account',
                        'KycVerification' => 'KYC',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListActivityLogs::route('/'),
        ];
    }
}

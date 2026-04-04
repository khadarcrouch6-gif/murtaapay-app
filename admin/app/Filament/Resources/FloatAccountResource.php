<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FloatAccountResource\Pages;
use App\Models\FloatAccount;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;

class FloatAccountResource extends Resource
{
    protected static ?string $model = FloatAccount::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-library';

    protected static ?string $navigationGroup = 'Liquidity';

    protected static ?string $navigationLabel = 'Float Accounts';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Account Details')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->placeholder('e.g. Wallester Business EUR Account'),
                        Forms\Components\Select::make('provider')
                            ->options([
                                'wallester' => '🏦 Wallester (Europe)',
                                'waafi'     => '📱 WAAFI (Somalia)',
                                'edahab'    => '📱 E-Dahab',
                                'evcplus'   => '📱 EVC Plus',
                                'other'     => 'Other',
                            ])
                            ->required(),
                        Forms\Components\Select::make('currency')
                            ->options(['EUR' => 'EUR – Euro', 'USD' => 'USD – Dollar', 'SOS' => 'SOS – Shilling'])
                            ->required(),
                        Forms\Components\TextInput::make('account_identifier')
                            ->label('Account ID / Phone Number')
                            ->nullable(),
                        Forms\Components\Toggle::make('is_active')
                            ->default(true),
                    ])->columns(2),

                Forms\Components\Section::make('Balance & Alerts')
                    ->schema([
                        Forms\Components\TextInput::make('balance')
                            ->label('Current Balance (cents)')
                            ->numeric()
                            ->required()
                            ->helperText('e.g. 500000 = €5,000.00'),
                        Forms\Components\TextInput::make('alert_threshold')
                            ->label('Low Balance Alert Threshold (cents)')
                            ->numeric()
                            ->required()
                            ->default(100000)
                            ->helperText('Send alert when balance drops below this value'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->weight('bold')
                    ->searchable(),
                Tables\Columns\TextColumn::make('provider')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'wallester' => 'info',
                        'waafi'     => 'success',
                        'edahab'    => 'warning',
                        'evcplus'   => 'warning',
                        default     => 'gray',
                    }),
                Tables\Columns\TextColumn::make('currency')
                    ->badge(),
                Tables\Columns\TextColumn::make('balance')
                    ->label('Balance')
                    ->getStateUsing(fn ($record) => $record->currency . ' ' . number_format($record->balance / 100, 2))
                    ->fontFamily('mono')
                    ->weight('bold')
                    ->color(fn ($record) => $record->is_low ? 'danger' : 'success'),
                Tables\Columns\TextColumn::make('alert_threshold')
                    ->label('Alert At')
                    ->getStateUsing(fn ($record) => $record->currency . ' ' . number_format($record->alert_threshold / 100, 2))
                    ->fontFamily('mono')
                    ->color('warning'),
                Tables\Columns\IconColumn::make('is_low')
                    ->label('⚠️ Low')
                    ->getStateUsing(fn ($record) => $record->is_low)
                    ->boolean()
                    ->trueColor('danger')
                    ->falseColor('success'),
                Tables\Columns\TextColumn::make('last_synced_at')
                    ->label('Last Synced')
                    ->since()
                    ->placeholder('Never'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean(),
            ])
            ->defaultSort('provider')
            ->actions([
                Tables\Actions\Action::make('sync')
                    ->label('Sync Balance')
                    ->icon('heroicon-o-arrow-path')
                    ->color('info')
                    ->action(function (FloatAccount $record) {
                        // TODO: Call Wallester/WAAFI API to fetch real balance
                        $record->update(['last_synced_at' => now()]);
                        Notification::make()
                            ->title('Sync triggered')
                            ->body('Balance sync request sent for ' . $record->name)
                            ->info()
                            ->send();
                    }),
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListFloatAccounts::route('/'),
            'create' => Pages\CreateFloatAccount::route('/create'),
            'edit'   => Pages\EditFloatAccount::route('/{record}/edit'),
        ];
    }
}

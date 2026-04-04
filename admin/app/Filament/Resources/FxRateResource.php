<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FxRateResource\Pages;
use App\Models\FxRate;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;

class FxRateResource extends Resource
{
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $model = FxRate::class;

    protected static ?string $navigationIcon = 'heroicon-o-currency-euro';

    protected static ?string $navigationGroup = 'FX & Fees';

    protected static ?string $navigationLabel = 'Exchange Rates';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Currency Pair')
                    ->schema([
                        Forms\Components\Select::make('currency_from')
                            ->options(['EUR' => '🇪🇺 EUR – Euro', 'GBP' => '🇬🇧 GBP – Pound'])
                            ->default('EUR')
                            ->required(),
                        Forms\Components\Select::make('currency_to')
                            ->options(['USD' => '🇺🇸 USD – Dollar', 'SOS' => '🇸🇴 SOS – Shilling'])
                            ->default('USD')
                            ->required(),
                    ])->columns(2),

                Forms\Components\Section::make('Rate Configuration')
                    ->schema([
                        Forms\Components\TextInput::make('rate')
                            ->label('Mid-Market Rate')
                            ->numeric()
                            ->required()
                            ->prefix('1 FROM =')
                            ->suffix('TO')
                            ->helperText('e.g. 1.0850 means 1 EUR = 1.0850 USD'),
                        Forms\Components\TextInput::make('spread_percent')
                            ->label('Spread / Margin (%)')
                            ->numeric()
                            ->suffix('%')
                            ->default(1.50)
                            ->helperText('Applied on top of mid-market rate. Effective rate = rate × (1 - spread%)'),
                        Forms\Components\Select::make('source')
                            ->options(['manual' => '✏️ Manual', 'api' => '🤖 Auto (API)'])
                            ->default('manual')
                            ->required()
                            ->reactive(),
                        Forms\Components\TextInput::make('api_provider')
                            ->label('API Provider')
                            ->placeholder('e.g. exchangerate-api.com')
                            ->visible(fn ($get) => $get('source') === 'api'),
                        Forms\Components\Toggle::make('is_active')
                            ->label('Set as Active Rate')
                            ->helperText('Only one rate per currency pair can be active at a time.')
                            ->default(false),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('currency_from')
                    ->label('From')
                    ->badge()
                    ->color('info'),
                Tables\Columns\TextColumn::make('currency_to')
                    ->label('To')
                    ->badge()
                    ->color('success'),
                Tables\Columns\TextColumn::make('rate')
                    ->label('Mid-Market Rate')
                    ->numeric(6)
                    ->fontFamily('mono')
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('spread_percent')
                    ->label('Spread')
                    ->suffix('%')
                    ->color('warning'),
                Tables\Columns\TextColumn::make('effective_rate')
                    ->label('Effective Rate')
                    ->getStateUsing(fn ($record) => round($record->rate * (1 - $record->spread_percent / 100), 6))
                    ->fontFamily('mono')
                    ->color('success'),
                Tables\Columns\TextColumn::make('source')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'api' ? 'info' : 'gray'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean(),
                Tables\Columns\TextColumn::make('creator.name')
                    ->label('Set By')
                    ->default('System'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->since()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('source')
                    ->options(['manual' => 'Manual', 'api' => 'Auto']),
                Tables\Filters\TernaryFilter::make('is_active')->label('Active Only'),
            ])
            ->actions([
                Tables\Actions\Action::make('activate')
                    ->label('Set Active')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->action(function (FxRate $record) {
                        // Deactivate all rates for this pair
                        FxRate::where('currency_from', $record->currency_from)
                            ->where('currency_to', $record->currency_to)
                            ->update(['is_active' => false]);
                        $record->update(['is_active' => true]);
                        Notification::make()
                            ->title('Rate activated')
                            ->body("1 {$record->currency_from} = {$record->rate} {$record->currency_to} is now live.")
                            ->success()
                            ->send();
                    })
                    ->hidden(fn (FxRate $record) => $record->is_active),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
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
            'index'  => Pages\ListFxRates::route('/'),
            'create' => Pages\CreateFxRate::route('/create'),
            'edit'   => Pages\EditFxRate::route('/{record}/edit'),
        ];
    }
}

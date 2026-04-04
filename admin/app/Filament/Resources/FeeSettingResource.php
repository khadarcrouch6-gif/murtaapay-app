<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FeeSettingResource\Pages;
use App\Models\FeeSetting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class FeeSettingResource extends Resource
{
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $model = FeeSetting::class;

    protected static ?string $navigationIcon = 'heroicon-o-receipt-percent';

    protected static ?string $navigationGroup = 'FX & Fees';

    protected static ?string $navigationLabel = 'Fee Settings';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Fee Definition')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('e.g. Standard EUR→USD Fee'),
                        Forms\Components\Select::make('fee_type')
                            ->options([
                                'percent' => '% Percentage of Amount',
                                'fixed'   => '💵 Fixed Amount',
                            ])
                            ->required()
                            ->default('percent')
                            ->reactive(),
                        Forms\Components\TextInput::make('fee_value')
                            ->required()
                            ->numeric()
                            ->label(fn ($get) => $get('fee_type') === 'percent' ? 'Fee Percentage (%)' : 'Fixed Fee Amount (€)')
                            ->suffix(fn ($get) => $get('fee_type') === 'percent' ? '%' : '€')
                            ->helperText(fn ($get) => $get('fee_type') === 'percent'
                                ? 'e.g. 1.50 = 1.5% of each transaction'
                                : 'e.g. 2.00 = €2.00 flat fee per transaction'),
                        Forms\Components\Toggle::make('is_active')
                            ->label('Active')
                            ->default(true),
                    ])->columns(2),

                Forms\Components\Section::make('Currency & Limits')
                    ->schema([
                        Forms\Components\Select::make('currency_from')
                            ->options(['EUR' => '🇪🇺 EUR', 'GBP' => '🇬🇧 GBP'])
                            ->default('EUR')
                            ->required(),
                        Forms\Components\Select::make('currency_to')
                            ->options(['USD' => '🇺🇸 USD', 'SOS' => '🇸🇴 SOS'])
                            ->default('USD')
                            ->required(),
                        Forms\Components\TextInput::make('min_amount')
                            ->label('Min Transaction (cents)')
                            ->numeric()
                            ->default(0)
                            ->helperText('e.g. 1000 = €10.00 minimum'),
                        Forms\Components\TextInput::make('max_amount')
                            ->label('Max Transaction (cents)')
                            ->numeric()
                            ->nullable()
                            ->helperText('Leave blank for no upper limit'),
                    ])->columns(2),

                Forms\Components\Section::make('Notes')
                    ->schema([
                        Forms\Components\Textarea::make('description')
                            ->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('fee_type')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'percent' ? 'info' : 'warning'),
                Tables\Columns\TextColumn::make('fee_value')
                    ->label('Fee')
                    ->getStateUsing(fn ($record) => $record->fee_type === 'percent'
                        ? $record->fee_value . '%'
                        : '€' . number_format($record->fee_value, 2))
                    ->fontFamily('mono'),
                Tables\Columns\TextColumn::make('currency_from')
                    ->badge()->color('primary'),
                Tables\Columns\TextColumn::make('currency_to')
                    ->badge()->color('success'),
                Tables\Columns\TextColumn::make('min_amount')
                    ->label('Min (€)')
                    ->getStateUsing(fn ($record) => '€' . number_format($record->min_amount / 100, 2)),
                Tables\Columns\TextColumn::make('max_amount')
                    ->label('Max (€)')
                    ->getStateUsing(fn ($record) => $record->max_amount
                        ? '€' . number_format($record->max_amount / 100, 2)
                        : 'No limit'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')->label('Active Only'),
                Tables\Filters\SelectFilter::make('fee_type')
                    ->options(['percent' => 'Percentage', 'fixed' => 'Fixed']),
            ])
            ->actions([
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
            'index'  => Pages\ListFeeSettings::route('/'),
            'create' => Pages\CreateFeeSetting::route('/create'),
            'edit'   => Pages\EditFeeSetting::route('/{record}/edit'),
        ];
    }
}

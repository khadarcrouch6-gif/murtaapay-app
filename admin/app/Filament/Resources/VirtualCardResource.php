<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VirtualCardResource\Pages;
use App\Filament\Resources\VirtualCardResource\RelationManagers;
use App\Models\VirtualCard;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class VirtualCardResource extends Resource
{
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $model = VirtualCard::class;

    protected static ?string $navigationIcon = 'heroicon-o-credit-card';

    protected static ?string $navigationGroup = 'Settings Panel';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Card Holder & Identity')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->required(),
                        Forms\Components\TextInput::make('card_holder_name')
                            ->required()
                            ->maxLength(255),
                    ])->columns(2),

                Forms\Components\Section::make('Card Credentials')
                    ->schema([
                        Forms\Components\TextInput::make('card_number')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('expiry_date')
                            ->required()
                            ->placeholder('MM/YY')
                            ->maxLength(255),
                        Forms\Components\TextInput::make('cvv')
                            ->required()
                            ->maxLength(255),
                    ])->columns(3),

                Forms\Components\Section::make('Financials & Status')
                    ->schema([
                        Forms\Components\TextInput::make('balance')
                            ->required()
                            ->numeric()
                            ->prefix('$')
                            ->default(0)
                            ->helperText('Balance in cents'),
                        Forms\Components\Select::make('currency')
                            ->options([
                                'USD' => 'USD',
                                'EUR' => 'EUR',
                            ])
                            ->required()
                            ->default('USD'),
                        Forms\Components\Select::make('status')
                            ->options([
                                'active' => 'Active',
                                'inactive' => 'Inactive',
                                'frozen' => 'Frozen',
                                'blocked' => 'Blocked',
                            ])
                            ->required()
                            ->default('active'),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('User')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('card_holder_name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('card_number')
                    ->searchable()
                    ->formatStateUsing(fn ($state) => substr($state, 0, 4) . ' **** **** ' . substr($state, -4)),
                Tables\Columns\TextColumn::make('balance')
                    ->money(fn ($record) => $record->currency)
                    ->state(fn ($record) => $record->balance / 100)
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'frozen' => 'warning',
                        'blocked' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListVirtualCards::route('/'),
            'create' => Pages\CreateVirtualCard::route('/create'),
            'edit' => Pages\EditVirtualCard::route('/{record}/edit'),
        ];
    }
}

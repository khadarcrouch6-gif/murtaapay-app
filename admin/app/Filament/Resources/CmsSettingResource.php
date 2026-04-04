<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CmsSettingResource\Pages;
use App\Filament\Resources\CmsSettingResource\RelationManagers;
use App\Models\CmsSetting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class CmsSettingResource extends Resource
{
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $model = CmsSetting::class;

    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static ?string $navigationGroup = 'Settings Panel';

    protected static ?string $navigationLabel = 'Bill Setting';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Setting Identification')
                    ->schema([
                        Forms\Components\TextInput::make('key')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),
                        Forms\Components\Select::make('group')
                            ->options([
                                'general' => 'General Settings',
                                'website' => 'Landing Page Content',
                                'mobile_app' => 'Mobile App Content',
                                'finance' => 'Financial Rules',
                            ])
                            ->required()
                            ->default('general'),
                    ])->columns(2),

                Forms\Components\Section::make('Configuration Content')
                    ->schema([
                        Forms\Components\Select::make('type')
                            ->options([
                                'text' => 'Plain Text',
                                'textarea' => 'Long Text',
                                'image' => 'Image (URL)',
                                'boolean' => 'On/Off (Toggle)',
                            ])
                            ->required()
                            ->default('text')
                            ->reactive(),
                        Forms\Components\Textarea::make('value')
                            ->label('Content / Value')
                            ->required()
                            ->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('key')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('group')
                    ->badge()
                    ->searchable(),
                Tables\Columns\TextColumn::make('type')
                    ->color('gray'),
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
            'index' => Pages\ListCmsSettings::route('/'),
            'create' => Pages\CreateCmsSetting::route('/create'),
            'edit' => Pages\EditCmsSetting::route('/{record}/edit'),
        ];
    }
}

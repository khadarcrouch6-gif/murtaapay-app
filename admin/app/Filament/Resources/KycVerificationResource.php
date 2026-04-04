<?php

namespace App\Filament\Resources;

use App\Filament\Resources\KycVerificationResource\Pages;
use App\Filament\Resources\KycVerificationResource\RelationManagers;
use App\Models\KycVerification;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class KycVerificationResource extends Resource
{
    protected static ?string $model = KycVerification::class;

    protected static ?string $navigationIcon = 'heroicon-o-shield-check';

    protected static ?string $navigationGroup = 'KYC Management';

    protected static ?string $navigationLabel = 'KYC Setting';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Identity Information')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\Select::make('id_type')
                            ->options([
                                'passport' => 'Passport',
                                'national_id' => 'National ID',
                                'driving_license' => 'Driving License',
                            ])
                            ->required(),
                        Forms\Components\TextInput::make('id_number')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Select::make('status')
                            ->options([
                                'pending' => 'Pending',
                                'verified' => 'Verified',
                                'rejected' => 'Rejected',
                            ])
                            ->required()
                            ->default('pending'),
                    ])->columns(2),

                Forms\Components\Section::make('Document Uploads')
                    ->schema([
                        Forms\Components\FileUpload::make('id_front_path')
                            ->label('ID Card Front')
                            ->image()
                            ->directory('kyc/ids'),
                        Forms\Components\FileUpload::make('id_back_path')
                            ->label('ID Card Back')
                            ->image()
                            ->directory('kyc/ids'),
                        Forms\Components\FileUpload::make('selfie_path')
                            ->label('Selfie Verification')
                            ->image()
                            ->directory('kyc/selfies'),
                    ])->columns(3),

                Forms\Components\Section::make('Audit Notes')
                    ->schema([
                        Forms\Components\Textarea::make('admin_notes')
                            ->columnSpanFull(),
                    ])
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
                Tables\Columns\TextColumn::make('id_type')
                    ->badge(),
                Tables\Columns\TextColumn::make('id_number')
                    ->searchable(),
                Tables\Columns\ImageColumn::make('id_front_path')
                    ->label('ID Front'),
                Tables\Columns\ImageColumn::make('selfie_path')
                    ->label('Selfie'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'verified' => 'success',
                        'rejected' => 'danger',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\EditAction::make(),
                    Tables\Actions\Action::make('approve')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(function (KycVerification $record) {
                            $record->update(['status' => 'verified']);
                            
                            // 🚀 Upgrade User to Silver Tier
                            $user = $record->user;
                            if ($user && $user->tier === 'basic') {
                                $user->update([
                                    'tier' => 'silver',
                                    'daily_limit' => 500000,   // $5,000.00
                                    'monthly_limit' => 2500000, // $25,000.00
                                ]);
                                
                                // Notification can be added here
                            }
                        }),
                    Tables\Actions\Action::make('reject')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->form([
                            Forms\Components\Textarea::make('admin_notes')
                                ->label('Rejection Reason')
                                ->required(),
                        ])
                        ->action(fn (KycVerification $record, array $data) => $record->update([
                            'status' => 'rejected',
                            'admin_notes' => $data['admin_notes'],
                        ])),
                ])
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
            'index' => Pages\ListKycVerifications::route('/'),
            'create' => Pages\CreateKycVerification::route('/create'),
            'edit' => Pages\EditKycVerification::route('/{record}/edit'),
        ];
    }
}

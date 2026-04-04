<?php
namespace App\Filament\Resources\FeeSettingResource\Pages;
use App\Filament\Resources\FeeSettingResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
class EditFeeSetting extends EditRecord {
    protected static string $resource = FeeSettingResource::class;
    protected function getHeaderActions(): array { return [Actions\DeleteAction::make()]; }
}

<?php
namespace App\Filament\Resources\FxRateResource\Pages;
use App\Filament\Resources\FxRateResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
class EditFxRate extends EditRecord {
    protected static string $resource = FxRateResource::class;
    protected function getHeaderActions(): array { return [Actions\DeleteAction::make()]; }
}

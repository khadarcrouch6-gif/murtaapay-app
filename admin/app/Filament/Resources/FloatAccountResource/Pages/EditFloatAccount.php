<?php
namespace App\Filament\Resources\FloatAccountResource\Pages;
use App\Filament\Resources\FloatAccountResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
class EditFloatAccount extends EditRecord {
    protected static string $resource = FloatAccountResource::class;
    protected function getHeaderActions(): array { return [Actions\DeleteAction::make()]; }
}

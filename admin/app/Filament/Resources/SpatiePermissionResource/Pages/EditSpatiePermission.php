<?php

namespace App\Filament\Resources\SpatiePermissionResource\Pages;

use App\Filament\Resources\SpatiePermissionResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSpatiePermission extends EditRecord
{
    protected static string $resource = SpatiePermissionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}

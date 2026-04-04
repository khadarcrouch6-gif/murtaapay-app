<?php

namespace App\Filament\Resources\SpatieRoleResource\Pages;

use App\Filament\Resources\SpatieRoleResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListSpatieRoles extends ListRecords
{
    protected static string $resource = SpatieRoleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}

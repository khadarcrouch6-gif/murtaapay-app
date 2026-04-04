<?php

namespace App\Filament\Resources\CmsSettingResource\Pages;

use App\Filament\Resources\CmsSettingResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListCmsSettings extends ListRecords
{
    protected static string $resource = CmsSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}

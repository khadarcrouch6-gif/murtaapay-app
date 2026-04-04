<?php

namespace App\Filament\Resources\VirtualCardResource\Pages;

use App\Filament\Resources\VirtualCardResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListVirtualCards extends ListRecords
{
    protected static string $resource = VirtualCardResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}

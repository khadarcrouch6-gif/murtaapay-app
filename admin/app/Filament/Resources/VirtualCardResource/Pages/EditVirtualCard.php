<?php

namespace App\Filament\Resources\VirtualCardResource\Pages;

use App\Filament\Resources\VirtualCardResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditVirtualCard extends EditRecord
{
    protected static string $resource = VirtualCardResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}

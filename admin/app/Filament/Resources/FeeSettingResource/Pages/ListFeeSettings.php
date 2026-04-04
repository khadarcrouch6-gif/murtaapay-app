<?php
namespace App\Filament\Resources\FeeSettingResource\Pages;
use App\Filament\Resources\FeeSettingResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
class ListFeeSettings extends ListRecords {
    protected static string $resource = FeeSettingResource::class;
    protected function getHeaderActions(): array { return [Actions\CreateAction::make()]; }
}

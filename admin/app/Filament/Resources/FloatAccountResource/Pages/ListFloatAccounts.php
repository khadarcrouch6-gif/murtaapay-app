<?php
namespace App\Filament\Resources\FloatAccountResource\Pages;
use App\Filament\Resources\FloatAccountResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
class ListFloatAccounts extends ListRecords {
    protected static string $resource = FloatAccountResource::class;
    protected function getHeaderActions(): array { return [Actions\CreateAction::make()]; }
}

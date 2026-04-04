<?php

namespace App\Filament\Pages\Settings;

class WebsiteHeroSettings extends BaseSettingsPage
{
    protected static bool $shouldRegisterNavigation = false;
    protected static ?string $navigationIcon  = 'heroicon-o-sparkles';
    protected static ?string $navigationGroup = 'Settings Panel';
    protected static ?string $navigationLabel = 'Hero & Landing';
    protected static ?string $title           = 'Website Hero & Landing Page Settings';
    protected static ?int    $navigationSort  = 3;
    protected static string  $view            = 'filament.pages.settings.website-hero';

    protected function settingsGroup(): string
    {
        return 'website_hero';
    }

    protected function settingsKeys(): array
    {
        return [
            /* ENGLISH */
            'hero_title_en'    => 'Send Money Home, Instantly',
            'hero_subtitle_en' => 'The most reliable way to send and manage funds across Somalia and the globe.',
            'hero_cta_en'      => 'Get Started',

            /* SOMALI */
            'hero_title_so'    => 'Lacag Ku Dir Guriga, Si Degdeg Ah',
            'hero_subtitle_so' => 'Habka ugu kalsoonida badan ee lagu diro laguna maareeyo lacagaha guud ahaan Soomaaliya iyo caalamka.',
            'hero_cta_so'      => 'Hadda Bilow',

            /* ARABIC */
            'hero_title_ar'    => 'أرسل الأموال إلى المنزل في لحظة',
            'hero_subtitle_ar' => 'الطريقة الأكثر موثوقية لإرسال وإدارة الأموال في جميع أنحاء الصومال والعالم.',
            'hero_cta_ar'      => 'ابدأ الآن',
            
            /* GERMAN */
            'hero_title_de'    => 'Geld sofort nach Hause senden',
            'hero_subtitle_de' => 'Der zuverlässigste Weg, um Gelder in ganz Somalia und weltweit zu senden und zu verwalten.',
            'hero_cta_de'      => 'Jetzt anfangen',

            /* COMMON */
            'hero_image'       => '',
            'hero_cta_url'     => '/signup',
        ];
    }
}

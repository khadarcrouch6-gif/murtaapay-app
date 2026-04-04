<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsSetting;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    /**
     * Get global settings for the App/Web ecosystem.
     */
    public function index()
    {
        return response()->json([
            'success' => true,
            'data'    => [
                'site_name'        => CmsSetting::get('site_name', 'MurtaaxPay'),
                'maintenance_mode' => (bool) CmsSetting::get('maintenance_mode', false),
                'app_version'      => CmsSetting::get('app_version', '2.4.1'),
                'currencies'       => [
                    'default' => CmsSetting::get('default_currency', 'USD'),
                    'supported' => ['USD', 'EUR', 'SOS'],
                ],
                'contact' => [
                    'email' => CmsSetting::get('contact_email', 'support@murtaaxpay.com'),
                    'phone' => CmsSetting::get('contact_phone', '+252...'),
                ]
            ]
        ]);
    }

    /**
     * Get Website CMS content (Hero, Features, etc.)
     */
    public function cms()
    {
        $hero = CmsSetting::group('website_hero');
        
        return response()->json([
            'success' => true,
            'data'    => [
                'hero' => $hero,
                'features' => CmsSetting::group('website_features'),
            ]
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\CmsSetting;

class CmsController extends Controller
{
    public function getSettings(Request $request)
    {
        $group = $request->query('group', 'website');
        
        $settings = CmsSetting::where('group', $group)
            ->get()
            ->pluck('value', 'key');

        return response()->json($settings);
    }
}

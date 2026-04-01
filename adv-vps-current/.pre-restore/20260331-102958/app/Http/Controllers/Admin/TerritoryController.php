<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\District;
use App\Models\Province;
use App\Models\Village;

class TerritoryController extends Controller
{
    public function provinces()
    {
        return Province::orderBy('name')->get(['id', 'name']);
    }

    public function districts($id)
    {
        return District::where('province_id', $id)->orderBy('name')->get(['id', 'name']);
    }

    public function villages($id)
    {
        return Village::where('district_id', $id)->orderBy('name')->get(['id', 'name']);
    }
}

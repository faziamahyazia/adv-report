<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('provinces') || !Schema::hasTable('districts')) {
            return;
        }

        $now = now();

        $westJavaProvinceId = DB::table('provinces')
            ->whereRaw('LOWER(name) = ?', ['jawa barat'])
            ->value('id');

        if (!$westJavaProvinceId) {
            $westJavaProvinceId = DB::table('provinces')->insertGetId([
                'name' => 'Jawa Barat',
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }

        $districtNames = [
            'Kabupaten Bandung',
            'Kabupaten Bandung Barat',
            'Kabupaten Bekasi',
            'Kabupaten Bogor',
            'Kabupaten Ciamis',
            'Kabupaten Cianjur',
            'Kabupaten Cirebon',
            'Kabupaten Garut',
            'Kabupaten Indramayu',
            'Kabupaten Karawang',
            'Kabupaten Kuningan',
            'Kabupaten Majalengka',
            'Kabupaten Pangandaran',
            'Kabupaten Purwakarta',
            'Kabupaten Subang',
            'Kabupaten Sukabumi',
            'Kabupaten Sumedang',
            'Kabupaten Tasikmalaya',
            'Kota Bandung',
            'Kota Banjar',
            'Kota Bekasi',
            'Kota Bogor',
            'Kota Cimahi',
            'Kota Cirebon',
            'Kota Depok',
            'Kota Sukabumi',
            'Kota Tasikmalaya',
        ];

        foreach ($districtNames as $districtName) {
            $exists = DB::table('districts')
                ->where('province_id', $westJavaProvinceId)
                ->where('name', $districtName)
                ->exists();

            if (!$exists) {
                DB::table('districts')->insert([
                    'province_id' => $westJavaProvinceId,
                    'name' => $districtName,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }
        }
    }

    public function down(): void
    {
        // Intentionally left blank to avoid removing master regional data.
    }
};

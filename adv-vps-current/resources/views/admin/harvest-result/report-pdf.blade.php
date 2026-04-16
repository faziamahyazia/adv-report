<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Laporan Hasil Panen</title>
    <style>
        body {
            font-family: DejaVu Sans, sans-serif;
            font-size: 12px;
            color: #1f2d3d;
            margin: 20px;
        }
        .header {
            border-bottom: 2px solid #2b6cb0;
            padding-bottom: 10px;
            margin-bottom: 16px;
            display: table;
            width: 100%;
        }
        .header-left {
            display: table-cell;
            width: 64px;
            vertical-align: top;
        }
        .header-left img {
            width: 54px;
            height: auto;
        }
        .header-right {
            display: table-cell;
            vertical-align: top;
        }
        .title {
            font-size: 20px;
            font-weight: 700;
            margin: 0;
            color: #1a365d;
        }
        .company {
            margin: 0;
            font-size: 14px;
            color: #2d3748;
            font-weight: 700;
        }
        .subtitle {
            margin-top: 4px;
            color: #4a5568;
        }
        .meta {
            margin-top: 6px;
            color: #4a5568;
        }
        .section-title {
            margin: 16px 0 8px;
            font-size: 14px;
            font-weight: 700;
            color: #1a365d;
        }
        .grid {
            width: 100%;
            border-collapse: collapse;
        }
        .grid td {
            border: 1px solid #d7e3f0;
            padding: 7px 8px;
            vertical-align: top;
        }
        .key {
            width: 34%;
            background: #f5f9ff;
            font-weight: 600;
            color: #2d3748;
        }
        .value {
            width: 66%;
            color: #1f2d3d;
        }
        .photo {
            margin-top: 10px;
            border: 1px solid #d7e3f0;
            border-radius: 4px;
            overflow: hidden;
            text-align: center;
            padding: 6px;
            background: #f8fbff;
        }
        .photo img {
            max-width: 100%;
            max-height: 260px;
            width: auto;
            height: auto;
            object-fit: contain;
        }
        .photo-grid {
            width: 100%;
            border-collapse: separate;
            border-spacing: 8px;
            margin-top: 4px;
        }
        .photo-grid td {
            width: 50%;
            vertical-align: top;
        }
        .photo-label {
            margin: 0 0 4px;
            font-size: 10px;
            color: #4a5568;
        }
        .weakness-photo-title {
            margin: 8px 0 4px;
            font-size: 11px;
            color: #2d3748;
            font-weight: 700;
        }
        .weakness-photo-note {
            margin: 0 0 6px;
            font-size: 10px;
            color: #5c6b7a;
        }
        .note-box {
            border: 1px solid #d7e3f0;
            background: #f8fbff;
            border-radius: 4px;
            padding: 8px;
            min-height: 48px;
        }
        .chart-card {
            border: 1px solid #d7e3f0;
            border-radius: 4px;
            padding: 8px;
            background: #f8fbff;
            page-break-inside: avoid;
            break-inside: avoid;
        }
        .no-page-break {
            page-break-inside: avoid;
            break-inside: avoid;
        }
        .chart-table {
            width: 100%;
            border-collapse: collapse;
        }
        .chart-table td {
            padding: 6px 4px;
            vertical-align: middle;
            font-size: 11px;
        }
        .chart-label {
            width: 56px;
            font-weight: 700;
            color: #2d3748;
        }
        .chart-bar-track {
            background: #e9f2fb;
            border: 1px solid #d5e4f3;
            border-radius: 999px;
            height: 14px;
            overflow: hidden;
        }
        .chart-bar-fill {
            height: 14px;
            background: #1976d2;
        }
        .chart-bar-fill.peak {
            background: #f59e0b;
        }
        .chart-value {
            width: 130px;
            text-align: right;
            color: #2d3748;
            font-weight: 600;
            white-space: nowrap;
        }
        .chart-date {
            width: 92px;
            text-align: right;
            color: #5c6b7a;
            font-size: 10px;
            white-space: nowrap;
        }
        .peak-chip {
            display: inline-block;
            font-size: 11px;
            color: #8a5a00;
            background: #fff3cd;
            border: 1px solid #ffe29a;
            border-radius: 999px;
            padding: 3px 10px;
            margin-top: 6px;
        }
        .chart-caption {
            margin-top: 6px;
            font-size: 11px;
            color: #4a5568;
            text-align: center;
        }
        .chart-analysis {
            margin-top: 8px;
            border: 1px solid #d7e3f0;
            border-radius: 4px;
            background: #ffffff;
            padding: 8px 10px;
            font-size: 11px;
            color: #2d3748;
        }
        .chart-analysis p {
            margin: 2px 0;
        }
        .footer {
            margin-top: 16px;
            font-size: 10px;
            color: #718096;
            border-top: 1px solid #e2e8f0;
            padding-top: 8px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-left">
            @if(!empty($companyLogoDataUri))
                <img src="{{ $companyLogoDataUri }}" alt="Logo perusahaan" />
            @endif
        </div>
        <div class="header-right">
            <p class="company">{{ $companyName }}</p>
            <h1 class="title">Laporan Hasil Panen</h1>
            <div class="subtitle">Laporan per data panen untuk analisis cepat dan mudah dibaca</div>
            <div class="meta">Dicetak: {{ $generatedAt }}</div>
        </div>
    </div>

    <div class="section-title">Informasi Utama</div>
    <table class="grid">
        <tr>
            <td class="key">Varietas Produk</td>
            <td class="value">{{ $item->product?->name ?: '-' }}</td>
        </tr>
        <tr>
            <td class="key">Petani / Pemilik Lahan</td>
            <td class="value">{{ $item->farmer_name ?: ($item->demoPlot?->owner_name ?: '-') }}</td>
        </tr>
        <tr>
            <td class="key">Tanggal Panen</td>
            <td class="value">{{ optional($item->harvest_date)->format('d M Y') ?: '-' }}</td>
        </tr>
        <tr>
            <td class="key">Total Panen</td>
            <td class="value">{{ number_format((float) $item->harvest_quantity, 2, ',', '.') }} {{ $item->harvest_unit ?: 'kg' }}</td>
        </tr>
        <tr>
            <td class="key">Jumlah yang ditanam (PCS)</td>
            <td class="value">{{ $item->total_pieces !== null ? number_format((float) $item->total_pieces, 0, ',', '.') : '-' }}</td>
        </tr>
        <tr>
            <td class="key">Hasil per PCS</td>
            <td class="value">{{ $perPieceYield !== null ? number_format((float) $perPieceYield, 2, ',', '.') . ' ' . ($item->harvest_unit ?: 'kg') . '/pcs' : '-' }}</td>
        </tr>
        @if(!empty($isFreshCorn))
            <tr>
                <td class="key">Hasil Putren</td>
                <td class="value">{{ $putrenQuantity !== null ? number_format((float) $putrenQuantity, 2, ',', '.') . ' ' . ($item->harvest_unit ?: 'kg') : '-' }}</td>
            </tr>
            <tr>
                <td class="key">Putren per PCS</td>
                <td class="value">{{ $putrenPerPieceYield !== null ? number_format((float) $putrenPerPieceYield, 2, ',', '.') . ' ' . ($item->harvest_unit ?: 'kg') . '/pcs' : '-' }}</td>
            </tr>
        @endif
        <tr>
            <td class="key">DB / Germinasi</td>
            <td class="value">{{ $item->germination_percentage !== null ? number_format((float) $item->germination_percentage, 2, ',', '.') . ' %' : '-' }}</td>
        </tr>
        <tr>
            <td class="key">Estimasi Pohon Tumbuh</td>
            <td class="value">{{ $estimatedPlants !== null ? number_format((float) $estimatedPlants, 0, ',', '.') . ' pohon' : '-' }}</td>
        </tr>
        <tr>
            <td class="key">Hasil per Pohon Tumbuh</td>
            <td class="value">{{ $perTreeYield !== null ? number_format((float) $perTreeYield, 2, ',', '.') . ' ' . ($item->harvest_unit ?: 'kg') . '/pohon' : '-' }}</td>
        </tr>
        @if(!empty($isFreshCorn))
            <tr>
                <td class="key">Putren per Pohon</td>
                <td class="value">{{ $putrenPerTreeYield !== null ? number_format((float) $putrenPerTreeYield, 2, ',', '.') . ' ' . ($item->harvest_unit ?: 'kg') . '/pohon' : '-' }}</td>
            </tr>
        @endif
        <tr>
            <td class="key">Ketinggian</td>
            <td class="value">{{ $item->altitude_mdpl !== null ? number_format((int) $item->altitude_mdpl, 0, ',', '.') . ' mdpl' : '-' }} ({{ $zoneLabel }})</td>
        </tr>
        <tr>
            <td class="key">Luas Lahan</td>
            <td class="value">{{ $item->land_area !== null ? number_format((float) $item->land_area, 2, ',', '.') . ' m2' : '-' }}</td>
        </tr>
        <tr>
            <td class="key">Diinput Oleh</td>
            <td class="value">{{ $item->createdBy?->name ?: '-' }}</td>
        </tr>
    </table>

    @if(($harvestPhotoDataUris ?? collect())->count() > 0)
        <div class="section-title">Dokumentasi Foto Panen</div>
        <table class="photo-grid">
            @foreach(($harvestPhotoDataUris ?? collect())->values()->chunk(2) as $chunk)
                <tr>
                    @foreach($chunk as $photoIndex => $photoDataUri)
                        <td>
                            <p class="photo-label">Foto Panen {{ ($loop->parent->index * 2) + $photoIndex + 1 }}</p>
                            <div class="photo">
                                <img src="{{ $photoDataUri }}" alt="Foto panen {{ ($loop->parent->index * 2) + $photoIndex + 1 }}" />
                            </div>
                        </td>
                    @endforeach
                    @if($chunk->count() === 1)
                        <td></td>
                    @endif
                </tr>
            @endforeach
        </table>
    @endif

    @if($cycleChartRows->count() > 0)
        <div class="no-page-break">
        <div class="section-title">Grafik Panen Bertahap (K1/K2/dst)</div>
        <div class="chart-card">
            @php
                $maxQty = max(1, (float) $cycleChartRows->max('quantity'));
            @endphp

            <table class="chart-table">
                @foreach($cycleChartRows as $cycle)
                    @php
                        $percent = (float) $cycle['quantity'] > 0 ? max(2, (($cycle['quantity'] / $maxQty) * 100)) : 0;
                        $isPeak = ($peakCycle['label'] ?? null) === $cycle['label'];
                    @endphp
                    <tr>
                        <td class="chart-label">{{ $cycle['label'] }}</td>
                        <td>
                            <div class="chart-bar-track">
                                <div class="chart-bar-fill {{ $isPeak ? 'peak' : '' }}" style="width: {{ $percent }}%;"></div>
                            </div>
                        </td>
                        <td class="chart-value">
                            {{ number_format((float) $cycle['quantity'], 2, ',', '.') }} {{ $item->harvest_unit ?: 'kg' }}
                            @if($isPeak)
                                <span style="color:#8a5a00; font-weight:700;"> (Puncak)</span>
                            @endif
                        </td>
                        <td class="chart-date">
                            {{ !empty($cycle['date']) ? \Carbon\Carbon::parse($cycle['date'])->format('d/m/Y') : '-' }}
                        </td>
                    </tr>
                @endforeach
            </table>
            @if($peakCycle)
                <div class="peak-chip">
                    Puncak panen: {{ $peakCycle['label'] }} dengan {{ number_format((float) $peakCycle['quantity'], 2, ',', '.') }} {{ $item->harvest_unit ?: 'kg' }}
                </div>
            @endif
            <div class="chart-caption">Satuan: {{ $item->harvest_unit ?: 'kg' }} per siklus panen.</div>
            <div class="chart-analysis">
                <p><strong>Analisa Grafik:</strong></p>
                <p>Jumlah siklus tercatat: {{ $cycleChartRows->count() }} kali panen.</p>
                <p>Rata-rata hasil per siklus: {{ $cycleAverage !== null ? number_format((float) $cycleAverage, 2, ',', '.') : '-' }} {{ $item->harvest_unit ?: 'kg' }}.</p>
                <p>Tren akhir siklus: {{ $cycleTrend ?: '-' }}.</p>
                @if($peakCycle && !empty($peakCycle['date']))
                    <p>Puncak terjadi pada {{ $peakCycle['label'] }} ({{ \Carbon\Carbon::parse($peakCycle['date'])->format('d M Y') }}).</p>
                @endif
            </div>
        </div>
        </div>
    @endif

    <div class="section-title">Analisis</div>
    <table class="grid">
        <tr>
            <td class="key">Kelebihan</td>
            <td class="value"><div class="note-box">{{ $item->strengths ?: '-' }}</div></td>
        </tr>
        <tr>
            <td class="key">Kelemahan</td>
            <td class="value">
                <div class="note-box">{{ $item->weaknesses ?: '-' }}</div>
                @if(($weaknessPhotoDataUris ?? collect())->count() > 0)
                    <p class="weakness-photo-title">Foto Kelemahan</p>
                    <p class="weakness-photo-note">Dokumentasi masalah/kelemahan yang diunggah saat input data.</p>
                    <table class="photo-grid">
                        @foreach(($weaknessPhotoDataUris ?? collect())->values()->chunk(2) as $chunk)
                            <tr>
                                @foreach($chunk as $photoIndex => $photoDataUri)
                                    <td>
                                        <p class="photo-label">Foto {{ ($loop->parent->index * 2) + $photoIndex + 1 }}</p>
                                        <div class="photo">
                                            <img src="{{ $photoDataUri }}" alt="Foto kelemahan {{ ($loop->parent->index * 2) + $photoIndex + 1 }}" />
                                        </div>
                                    </td>
                                @endforeach
                                @if($chunk->count() === 1)
                                    <td></td>
                                @endif
                            </tr>
                        @endforeach
                    </table>
                @endif
            </td>
        </tr>
        <tr>
            <td class="key">Catatan Tambahan</td>
            <td class="value"><div class="note-box">{{ $item->notes ?: '-' }}</div></td>
        </tr>
    </table>

    <div class="footer">
        Dokumen ini dibuat otomatis oleh sistem Product Knowledge.
    </div>
</body>
</html>

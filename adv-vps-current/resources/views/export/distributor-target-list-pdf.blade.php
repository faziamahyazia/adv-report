@extends('export.layout', [
    'title' => $title,
])

@section('content')
  <style>
    table.distributor-target {
      width: 100%;
      table-layout: fixed;
      border-collapse: collapse;
      font-size: 8px;
    }

    table.distributor-target th,
    table.distributor-target td {
      padding: 3px 4px;
      border: 1px solid #000;
      vertical-align: top;
      word-break: break-word;
      overflow-wrap: anywhere;
    }

    table.distributor-target th {
      background: #f2f2f2;
      text-align: center;
      font-size: 8px;
      line-height: 1.2;
    }

    .col-distributor { width: 10%; }
    .col-product { width: 10%; }
    .col-month { width: 4.5%; }
    .col-total { width: 6%; }
    .col-value { width: 7%; }
    .col-achievement { width: 6%; }
    .col-notes { width: 8%; }
  </style>

  <table class="distributor-target">
    <thead>
      <tr>
        <th class="col-distributor">Distributor</th>
        <th class="col-product">Produk</th>
        @foreach ($month_labels as $label)
          <th class="col-month">Target {{ $label }}</th>
        @endforeach
        <th class="col-total">Total Target</th>
        <th class="col-total">Total Realisasi</th>
        <th class="col-value">Nilai Target (Rp)</th>
        <th class="col-value">Nilai Realisasi (Rp)</th>
        <th class="col-achievement">Pencapaian (%)</th>
        <th class="col-notes">Catatan</th>
      </tr>
    </thead>
    <tbody>
      @forelse ($items as $item)
        <tr>
          <td>{{ $item['distributor_name'] ?? '-' }}</td>
          <td>{{ $item['product_name'] ?? '-' }}</td>
          @foreach (array_keys($month_labels) as $monthKey)
            <td align="right">{{ number_format((float) ($item[$monthKey] ?? 0), 2, ',', '.') }}</td>
          @endforeach
          <td align="right">{{ number_format((float) ($item['total_target_qty'] ?? 0), 2, ',', '.') }}</td>
          <td align="right">{{ number_format((float) ($item['total_actual_qty'] ?? 0), 2, ',', '.') }}</td>
          <td align="right">{{ number_format((float) ($item['total_target_value'] ?? 0), 0, ',', '.') }}</td>
          <td align="right">{{ number_format((float) ($item['total_actual_value'] ?? 0), 0, ',', '.') }}</td>
          <td align="right">{{ number_format((float) ($item['achievement'] ?? 0), 1, ',', '.') }}</td>
          <td>{{ $item['notes'] ?? '' }}</td>
        </tr>
      @empty
        <tr>
          <td colspan="21" align="center">Tidak ada data</td>
        </tr>
      @endforelse
    </tbody>
    <tfoot>
      <tr>
        <th colspan="14" align="right">Total</th>
        <th align="right">{{ number_format((float) ($summary['total_target'] ?? 0), 2, ',', '.') }}</th>
        <th align="right">{{ number_format((float) ($summary['total_actual'] ?? 0), 2, ',', '.') }}</th>
        <th align="right">{{ number_format((float) ($summary['total_target_value'] ?? 0), 0, ',', '.') }}</th>
        <th align="right">{{ number_format((float) ($summary['total_actual_value'] ?? 0), 0, ',', '.') }}</th>
        <th align="right">
          @php
            $ach = (float) ($summary['total_target'] ?? 0) > 0
                ? ((float) ($summary['total_actual'] ?? 0) / (float) ($summary['total_target'] ?? 0)) * 100
                : 0;
          @endphp
          {{ number_format($ach, 1, ',', '.') }}
        </th>
      </tr>
    </tfoot>
  </table>
@endsection

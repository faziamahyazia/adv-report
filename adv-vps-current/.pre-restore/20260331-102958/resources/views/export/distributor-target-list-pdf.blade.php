@extends('export.layout', [
    'title' => $title,
])

@section('content')
  <table>
    <thead>
      <tr>
        <th>Distributor</th>
        <th>Produk</th>
        @foreach ($month_labels as $label)
          <th>Target {{ $label }}</th>
        @endforeach
        <th>Total Target</th>
        <th>Total Realisasi</th>
        <th>Nilai Target (Rp)</th>
        <th>Nilai Realisasi (Rp)</th>
        <th>Pencapaian (%)</th>
        <th>Catatan</th>
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

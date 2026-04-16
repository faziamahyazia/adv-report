@extends('export.layout', [
    'title' => $title,
])

@section('content')
  <table>
    <thead>
      <tr>
        <th style="width: 4%;">No</th>
        <th style="width: 10%;">Tanggal Cek</th>
        <th style="width: 12%;">Checker</th>
        <th style="width: 11%;">Area</th>
        <th style="width: 14%;">Client</th>
        <th style="width: 12%;">Crops</th>
        <th style="width: 16%;">Varietas</th>
        <th style="width: 11%;">LOT Package</th>
        <th style="width: 12%;">Quantity ({{ strtoupper($qtyUnit ?? 'kg') }})</th>
        <th style="width: 10%;">Catatan</th>
      </tr>
    </thead>
    <tbody>
      @forelse ($items as $item)
        <tr>
          <td align="right">{{ $loop->iteration }}</td>
          <td>{{ optional($item->check_date)->format('d-m-Y') }}</td>
          <td>{{ $item->user->name ?? '-' }}</td>
          <td>{{ $item->area ?? '-' }}</td>
          <td>{{ $item->customer->name ?? '-' }}</td>
          <td>{{ $item->product->category->name ?? '-' }}</td>
          <td>{{ $item->product->name ?? '-' }}</td>
          <td>{{ $item->lot_package ?? '-' }}</td>
          <td>{{ $item->export_qty_text ?? '-' }}</td>
          <td>{{ $item->notes ?? '-' }}</td>
        </tr>
      @empty
        <tr>
          <td colspan="10" align="center">Tidak ada data</td>
        </tr>
      @endforelse
    </tbody>
  </table>
@endsection

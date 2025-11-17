<div>
    <h2 class="text-3xl font-bold mb-6">COSHH Inventory</h2>
    <div class="grid gap-6">
        @foreach($chemicals as $chem)
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 {{ $chem->current_stock_level <= $chem->min_stock_level ? "border-l-8 border-red-600" : "" }}">
                <h3 class="text-xl font-bold">{{ $chem->name }}</h3>
                <p>Stock: <strong class="{{ $chem->current_stock_level <= $chem->min_stock_level ? "text-red-600" : "text-green-600" }}">{{ $chem->current_stock_level }}</strong> / {{ $chem->min_stock_level }} minimum</p>
                @if($chem->un_number)<p class="text-sm">UN: {{ $chem->un_number }}</p>@endif
            </div>
        @endforeach
    </div>
</div>

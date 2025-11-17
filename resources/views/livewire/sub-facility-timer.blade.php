<div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8 text-center">
    <h3 class="text-2xl font-bold mb-4">{{ $subFacility->name }}</h3>
    <div class="text-7xl font-mono font-bold {{ $isOverdue ? "text-red-600" : "text-green-600" }}">
        {{ str_pad(floor($minutesLeft / 60), 2, "0", STR_PAD_LEFT) }}:{{ str_pad($minutesLeft % 60, 2, "0", STR_PAD_LEFT) }}
    </div>
    <p class="text-xl mt-4 {{ $isOverdue ? "text-red-600 font-bold" : "" }}">
        {{ $isOverdue ? "OVERDUE â€“ ACTION REQUIRED" : "Until next check" }}
    </p>
    <button wire:click="markChecked" class="mt-8 bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 px-12 rounded-xl text-xl">
        âœ“ Check Complete
    </button>
</div>

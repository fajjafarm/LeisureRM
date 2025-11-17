<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 text-center">
    <h3 class="text-xl font-bold mb-4">{{ $subFacility->name }}</h3>
    <div class="text-5xl font-mono font-bold {{ $isOverdue ? 'text-red-600' : 'text-green-600' }}">
        {{ str_pad(floor($minutesRemaining / 60), 2, "0", STR_PAD_LEFT) }}:{{ str_pad($minutesRemaining % 60, 2, "0", STR_PAD_LEFT) }}
    </div>
    <p class="mt-2 text-lg">{{ $isOverdue ? 'OVERDUE â€“ Action Required' : 'Until next check' }}</p>
    <button wire:click="markChecked" class="mt-4 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded text-xl">
        Check Complete
    </button>
</div>

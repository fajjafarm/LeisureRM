<div class="max-w-2xl mx-auto">
    <h2 class="text-2xl font-bold mb-6">Pool Water Testing</h2>

    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <select wire:model="selectedSubFacility" class="w-full p-3 border rounded mb-6">
            @foreach($subFacilities as $sub)
                <option value="{{ $sub->id }}">{{ $sub->name }} ({{ ucwords(str_replace('_', ' ', $sub->type)) }})</option>
            @endforeach
        </select>

        <form wire:submit.prevent="submitTest" class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
                <x-input label="Temperature (Â°C)" wire:model="form.temperature" type="number" step="0.1" required />
                <x-input label="Free Chlorine (mg/L)" wire:model="form.free_chlorine" type="number" step="0.1" required />
                <x-input label="Total Chlorine (mg/L)" wire:model="form.total_chlorine" type="number" step="0.1" />
                <x-input label="pH" wire:model="form.ph" type="number" step="0.01" required />
                <x-input label="Alkalinity (mg/L)" wire:model="form.alkalinity" type="number" step="1" />
                <x-input label="Calcium Hardness (mg/L)" wire:model="form.calcium_hardness" type="number" step="1" />
                <x-input label="Cyanuric Acid (mg/L)" wire:model="form.cyanuric_acid" type="number" step="1" />
            </div>

            <x-textarea label="Notes" wire:model="form.notes" rows="3" />

            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded">
                Record Test
            </button>
        </form>

        @if(session()->has('message'))
            <div class="mt-4 p-4 bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 rounded">
                {{ session('message') }}
            </div>
        @endif
    </div>
</div>

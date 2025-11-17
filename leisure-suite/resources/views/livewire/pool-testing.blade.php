<div class="max-w-2xl mx-auto">
    <h2 class="text-3xl font-bold mb-8">Pool Water Testing (PWTAG)</h2>

    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8">
        <div class="mb-6">
            <select wire:model="selectedSubFacility" class="w-full px-4 py-3 rounded-lg border dark:bg-gray-700">
                @foreach($subFacilities as $sub)
                    <option value="{{ $sub->id }}">{{ $sub->name }}</option>
                @endforeach
            </select>
        </div>

        <form wire:submit.prevent="submit" class="space-y-6">
            <div class="grid grid-cols-2 gap-6">
                <x-input label="Temperature (Â°C)" wire:model="form.temperature" type="number" step="0.1" required />
                <x-input label="Free Chlorine (mg/L)" wire:model="form.free_chlorine" type="number" step="0.1" required />
                <x-input label="pH" wire:model="form.ph" type="number" step="0.01" required />
                <x-input label="Total Alkalinity" wire:model="form.alkalinity" type="number" step="1" />
                <x-input label="Calcium Hardness" wire:model="form.calcium_hardness" type="number" step="1" />
                <x-input label="Cyanuric Acid" wire:model="form.cyanuric_acid" type="number" step="1" />
            </div>

            <x-textarea label="Notes" wire:model="form.notes" rows="3" />

            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-lg text-xl">
                Record Test Result
            </button>
        </form>

        @if(session('message'))
            <div class="mt-6 p-6 {{ session('message') includes 'CRITICAL' ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800' }} rounded-lg text-center font-bold">
                {{ session('message') }}
            </div>
        @endif
    </div>
</div>

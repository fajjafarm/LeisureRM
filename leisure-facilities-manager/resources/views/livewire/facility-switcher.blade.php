<div class="md:hidden fixed bottom-0 left-0 right-0 bg-white p-4 shadow-md">
    <select wire:model="currentFacility.id" class="w-full p-2 border rounded">
        @foreach($facilities as $facility)
            <option value="{{ $facility->id }}">{{ $facility->name }}</option>
        @endforeach
    </select>
</div>

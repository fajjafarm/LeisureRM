<div class="max-w-5xl mx-auto">
    <h2 class="text-3xl font-bold mb-8">Facility Message Board & Daily Overview</h2>

    <!-- Daily Overview Card -->
    <div class="bg-blue-50 dark:bg-blue-900/30 border-2 border-blue-400 rounded-xl p-8 mb-8">
        <h3 class="text-2xl font-bold mb-4">Today â€“ {{ today()->format('l j F Y') }}</h3>
        <div class="grid md:grid-cols-2 gap-8">
            <div>
                <p class="text-lg"><strong>Expected Guests:</strong> {{ $overview->expected_guests }}</p>
                <p class="text-lg"><strong>Staff on Shift:</strong></à§p>
                <ul class="mt-2 space-y-2">
                    @foreach($staffOnShift as $s)
                        <li class="bg-white dark:bg-gray-800 px-4 py-2 rounded">{{ $s['name'] }}: {{ $s['start'] }} â€“ {{ $s['end'] }}</li>
                    @endforeach
                </ul>
            </div>
            <div>
                <form wire:submit.prevent="addShift" class="space-y-4">
                    <input wire:model="newStaffName" placeholder="Staff name" class="w-full px-4 py-2 border rounded" required />
                    <div class="grid grid-cols-2 gap-4">
                        <input type="time" wire:model="shiftStart" required />
                        <input type="time" wire:model="shiftEnd" required />
                    </div>
                    <button type="submit" class="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded">Add Shift</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Messages -->
    <div class="space-y-6">
        @foreach($posts as $post)
            <div class="bg-white dark:bg-gray-800 rounded-xl shadow p-6">
                <div class="flex justify-between">
                    <div>
                        <p class="font-bold">{{ $post->user->name }}</p>
                        <p class="text-sm text-gray-500">{{ $post->created_at->diffForHumans() }}</p>
                        <p class="mt-4 whitespace-pre-wrap">{{ $post->message }}</p>
                    </div>
                </div>
            </div>
        @endforeach

        <form wire:submit.prevent="postMessage" class="mt-8">
            <textarea wire:model="message" placeholder="Write a message..." rows="4" class="w-full px-4 py-3 border rounded-lg" required></textarea>
            <button type="submit" class="mt-4 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded-lg">Post Message</button>
        </form>
    </div>
</div>

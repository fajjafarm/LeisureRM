<div class="max-w-4xl mx-auto">
    <h2 class="text-3xl font-bold mb-6">Facility Message Board & Daily Overview</h2>

    <!-- Daily Overview Card (Always Pinned at Top) -->
    <div class="bg-blue-50 dark:bg-blue-900/30 border-2 border-blue-300 rounded-lg p-6 mb-8">
        <h3 class="text-2xl font-bold text-blue-800 dark:text-blue-200">Today â€“ {{ today()->format('l j F Y') }}</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
            <div>
                <p class="text-lg"><strong>Expected Guests:</strong> {{ $todayOverview->expected_guests }}</p>
                <p><strong>Classes/Events:</strong> {{ $todayOverview->classes_today ?? 'None' }}</p>
                <p><strong>Special Notes:</strong> {{ $todayOverview->notes ?? 'None' }}</p>
            </div>
            <div>
                <p class="font-bold mb-2">Staff on Shift Today:</p>
                @if(count($staffOnShift))
                    <ul class="space-y-1">
                        @foreach($staffOnShift as $s)
                            <li class="bg-white dark:bg-gray-800 px-3 py-1 rounded">{{ $s['name'] }}: {{ $s['start'] }} â€“ {{ $s['end'] }} (Break: {{ $s['break'] }} mins)</li>
                        @endforeach
                    </ul>
                @else
                    <p class="text-gray-500">No staff logged yet</p>
                @endif
            </div>
        </div>
    </div>

    <!-- Add Staff to Shift -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-8">
        <h4 class="font-bold mb-4">Log Staff on Shift</h4>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <select wire:model="selectedStaffId" class="p-2 border rounded">
                <option value="">Select Staff</option>
                @foreach(\App\Models\User::where('business_id', Auth::user()->profile->business_id)->get() as $u)
                    <option value="{{ $u->id }}">{{ $u->name }}</option>
                @endforeach
            </select>
            <input type="time" wire:model="shiftStart" class="p-2 border rounded">
            <input type="time" wire:model="shiftEnd" class="p-2 border rounded">
            <button wire:click="addStaffToShift" class="bg-green-600 hover:bg-green-700 text-white px-4 rounded">Add</button>
        </div>
    </div>

    <!-- Messages -->
    <div class="space-y-4">
        @foreach($posts as $post)
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 {{ $post->pinned ? 'ring-4 ring-yellow-400' : '' }}">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="font-bold">{{ $post->user->name }}</p>
                        <p class="text-sm text-gray-500">{{ $post->created_at->diffForHumans() }}</p>
                        <p class="mt-3 whitespace-pre-wrap">{{ $post->message }}</p>
                    </div>
                    @can('pin messages')
                        <button wire:click="pinPost({{ $post->id }})" class="text-yellow-600 hover:text-yellow-800">
                            {{ $post->pinned ? 'Unpin' : 'Pin' }}
                        </button>
                    @endcan
                </div>
            </div>
        @endforeach
    </div>

    <!-- New Message -->
    <div class="fixed bottom-4 right-4 left-4 md:left-auto bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
        <textarea wire:model="newMessage" placeholder="Type a message..." rows="3" class="w-full p-3 border rounded"></textarea>
        <button wire:click="postMessage" class="mt-3 bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-6 rounded">Send</button>
    </div>
</div>

<div class="py-4">
    <!-- Facility Switcher -->
    <div class="px-6 mb-6">
        <label class="block text-sm font-medium mb-2">Current Facility</label>
        <select wire:model="currentFacility" wire:change="switchFacility($event.target.value)" class="w-full px-3 py-2 border rounded-lg dark:bg-gray-700">
            @foreach($facilities as $f)
                <option value="{{ $f->id }}">{{ $f->name }}</option>
            @endforeach
        </select>
    </div>

    <nav class="space-y-1 px-4">
        <a href="/dashboard" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 {{ request()->is('dashboard') ? 'bg-blue-50 dark:bg-blue-900 text-blue-600' : '' }}">
            <span> Dashboard</span>
        </a>
        <a href="/tasks" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
            <span> Task Manager</span>
        </a>
        <a href="/pool-testing" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
            <span> Pool Testing</span>
        </a>
        <a href="/coshh" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
            <span> COSHH</span>
        </a>
        <a href="/message-board" class="flex items-center px-4 py-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
            <span> Message Board</span>
        </a>

        @if($subFacilities->count())
            <div class="mt-6 pt-4 border-t dark:border-gray-700">
                <p class="px-4 text-xs font-semibold text-gray-500 uppercase">Sub-Facilities</p>
                @foreach($subFacilities as $sub)
                    <a href="#" class="flex items-center px-4 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 rounded">
                        {{ $sub->name }} <span class="ml-auto text-xs">{{ $sub->type }}</span>
                    </a>
                @endforeach
            </div>
        @endif
    </nav>
</div>

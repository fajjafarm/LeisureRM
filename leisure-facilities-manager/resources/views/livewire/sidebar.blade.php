<nav class="p-4">
    <div class="mb-6">
        <label class="block text-sm font-medium mb-2">Current Facility</label>
        <select wire:model="selectedFacilityId" wire:change="changeFacility($event.target.value)" class="w-full p-2 border rounded">
            @foreach($facilities as $facility)
                <option value="{{ $facility->id }}">{{ $facility->name }}</option>
            @endforeach
        </select>
    </div>

    <ul class="space-y-4">
        <li><a href="{{ route('dashboard') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Dashboard</a></li>
        <li><a href="{{ route('tasks.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Task Manager</a></li>
        <li><a href="{{ route('staff.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Staff Management</a></li>
        <li><a href="{{ route('coshh.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">COSHH</a></li>
        <li><a href="{{ route('pool-tests.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Pool Testing</a></li>
        <li><a href="{{ route('water-meters.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Water Meters</a></li>
        <li><a href="{{ route('inventory.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Inventory</a></li>
        <li><a href="{{ route('club-hires.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Club Hires</a></li>
        <li><a href="{{ route('message-board') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Message Board</a></li>
        <li><a href="{{ route('safety-checklists.index') }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded">Safety Inspections</a></li>
        
        <!-- Dynamic Sub-Facilities -->
        @if(!empty($subFacilities))
            <li class="mt-4 font-bold">Facilities</li>
            @foreach($subFacilities as $group => $subs)
                <li class="ml-2">{{ $group }}</li>
                @foreach($subs as $sub)
                    <li class="ml-4"><a href="{{ route('sub-facility.show', $sub->id) }}" class="block hover:bg-gray-100 dark:hover:bg-gray-700 p-1 rounded text-sm">{{ $sub->name }}</a></li>
                @endforeach
            @endforeach
        @endif
    </ul>
</nav>

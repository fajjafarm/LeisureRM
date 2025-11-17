<div>
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
        <h2 class="text-2xl font-bold mb-4">Task Manager</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div class="bg-red-100 dark:bg-red-900 p-4 rounded">
                <p class="text-3xl font-bold text-red-600">{{ $openTasks->where('priority', 'critical')->count() }}</p>
                <p>Critical Tasks</p>
            </div>
            <div class="bg-yellow-100 dark:bg-yellow-900 p-4 rounded">
                <p class="text-3xl font-bold text-yellow-600">{{ $openTasks->whereIn('priority', ['high','medium'])->count() }}</p>
                <p>Pending Tasks</p>
            </div>
            <div class="bg-green-100 dark:bg-green-900 p-4 rounded">
                <p class="text-3xl font-bold text-green-600">{{ $completedToday }}</p>
                <p>Completed Today</p>
            </div>
        </div>

        <div class="space-y-3">
            @forelse($openTasks as $task)
                <div class="border-l-4 {{ $task->priority == 'critical' ? 'border-red-500' : ($task->priority == 'high' ? 'border-orange-500' : 'border-gray-400') }} bg-gray-50 dark:bg-gray-700 p-4 rounded-r">
                    <div class="flex justify-between items-start">
                        <div>
                            <h4 class="font-bold">{{ $task->title }}</h4>
                            @if($task->subFacility)
                                <span class="text-sm text-gray-600">{{ $task->subFacility->name }} ({{ $task->subFacility->type }})</span>
                            @endif
                            <p class="text-sm mt-1">{{ $task->description }}</p>
                            @if($task->due_at)
                                <p class="text-xs text-red-600">Due: {{ $task->due_at->format('d/m/Y H:i') }}</p>
                            @endif
                        </div>
                        <button wire:click="completeTask({{ $task->id }})"
                                class="ml-4 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded text-sm">
                            Complete
                        </button>
                    </div>
                </div>
            @empty
                <p class="text-center text-gray-500 py-8">No open tasks â€“ well done!</p>
            @endforelse
        </div>
    </div>
</div>

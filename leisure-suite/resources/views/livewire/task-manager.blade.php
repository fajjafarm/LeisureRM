<div class="space-y-6">
    <h2 class="text-3xl font-bold mb-6">Task Manager</h2>

    @if($tasks->isEmpty())
        <div class="bg-green-50 dark:bg-green-900 p-8 rounded-lg text-center">
            <p class="text-2xl">ðŸŽ‰ All tasks complete â€“ brilliant work!</p>
        </div>
    @else
        <div class="grid gap-4">
            @foreach($tasks as $task)
                <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 border-l-8 {{ 
                    $task->priority === 'critical' ? 'border-red-600' : 
                    ($task->priority === 'high' ? 'border-orange-500' : 'border-gray-300')
                }}">
                    <div class="flex justify-between items-start">
                        <div class="flex-1">
                            <h3 class="text-xl font-bold">{{ $task->title }}</h3>
                            @if($task->subFacility)
                                <p class="text-sm text-gray-600">{{ $task->subFacility->name }} ({{ ucwords(str_replace('_', ' ', $task->subFacility->type)) }})</p>
                            @endif
                            <p class="mt-2 text-gray-700 dark:text-gray-300">{!! nl2br(e($task->description)) !!}</p>
                            @if($task->due_at)
                                <p class="text-sm mt-2 {{ $task->due_at->isPast() ? 'text-red-600 font-bold' : '' }}">
                                    Due: {{ $task->due_at->format('d/m/Y H:i') }}
                                </p>
                            @endif
                        </div>
                        <button wire:click="completeTask({{ $task->id }})" 
                                class="ml-6 bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg">
                            Complete
                        </button>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
</div>

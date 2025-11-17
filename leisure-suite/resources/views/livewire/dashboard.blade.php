<div class="space-y-8">
    <h1 class="text-4xl font-bold">Welcome back, {{ auth()->user()->name }}! ðŸ‘‹</h1>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <a href="/tasks" class="bg-gradient-to-r from-red-500 to-pink-600 text-white p-8 rounded-xl shadow-lg transform hover:scale-105 transition">
            <h3 class="text-2xl font-bold">Critical Tasks</h3>
            <p class="text-5xl mt-4">3</p>
        </a>
        <a href="/pool-testing" class="bg-gradient-to-r from-blue-500 to-cyan-600 text-white p-8 rounded-xl shadow-lg transform hover:scale-105 transition">
            <h3 class="text-2xl font-bold">Pool Testing</h3>
            <p class="text-5xl mt-4">âœ“</p>
        </a>
        <a href="/coshh" class="bg-gradient-to-r from-orange-500 to-red-600 text-white p-8 rounded-xl shadow-lg transform hover:scale-105 transition">
            <h3 class="text-2xl font-bold">COSHH Alerts</h3>
            <p class="text-5xl mt-4">1</p>
        </a>
        <a href="/message-board" class="bg-gradient-to-r from-purple-500 to-indigo-600 text-white p-8 rounded-xl shadow-lg transform hover:scale-105 transition">
            <h3 class="text-2xl font-bold">Team Board</h3>
            <p class="text-5xl mt-4">ðŸ“¢</p>
        </a>
    </div>

    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-6">Your Empire is Running Perfectly</h2>
        <p class="text-lg text-gray-600 dark:text-gray-400">
            All UK H&S requirements met â€¢ PWTAG compliant â€¢ Auto-tasks active â€¢ Mobile-ready
        </p>
    </div>
</div>

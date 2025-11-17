<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ config('app.name') }} - @yield('title', 'Dashboard')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @livewireStyles
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body class="bg-gray-100 dark:bg-gray-900 text-gray-900 dark:text-gray-100 font-sans antialiased min-h-screen flex flex-col md:flex-row">
    <!-- Mobile menu button -->
    <div class="md:hidden fixed bottom-4 right-4 z-50">
        <button @click="sidebarOpen = !sidebarOpen" class="bg-blue-600 hover:bg-blue-700 text-white p-4 rounded-full shadow-lg">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
        </button>
    </div>

    <!-- Dynamic Sidebar -->
    <aside x-data="{ sidebarOpen: false }" :class="{ 'translate-x-0': sidebarOpen, '-translate-x-full': !sidebarOpen }" class="fixed md:relative inset-y-0 left-0 z-40 w-72 bg-white dark:bg-gray-800 shadow-xl transform transition-transform duration-300 ease-in-out md:translate-x-0">
        <div class="p-6 border-b dark:border-gray-700">
            <h1 class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ config('app.name') }}</h1>
            <p class="text-sm text-gray-600 dark:text-gray-400">UK H&S Compliant</p>
        </div>
        @livewire('sidebar')
    </aside>

    <!-- Overlay for mobile -->
    <div x-show="sidebarOpen" @click="sidebarOpen = false" class="fixed inset-0 bg-black bg-opacity-50 z-30 md:hidden"></div>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col">
        <header class="bg-white dark:bg-gray-800 shadow-sm px-6 py-4 flex justify-between items-center">
            <h2 class="text-2xl font-semibold">@yield('title')</h2>
            <div class="flex items-center space-x-4">
                <span class="text-sm">{{ auth()->user()->name }}</span>
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button type="submit" class="text-sm text-red-600 hover:text-red-800">Logout</button>
                </form>
            </div>
        </header>

        <main class="flex-1 p-6 overflow-y-auto">
            @if(session('message'))
                <div class="bg-green-100 dark:bg-green-900 border border-green-400 text-green-700 dark:text-green-200 px-4 py-3 rounded mb-6">
                    {{ session('message') }}
                </div>
            @endif
            @yield('content')
        </main>
    </div>

    @livewireScripts
    @stack('scripts')
</body>
</html>

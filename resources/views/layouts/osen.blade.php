<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>@yield('title') - Leisure Manager</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="{{ asset('osen/css/app.css') }}" rel="stylesheet">
    <link href="{{ asset('osen/css/icons.min.css') }}" rel="stylesheet">
    @livewireStyles
</head>
<body class="loading" data-layout-config='{"leftSideBarTheme":"dark","layoutBoxed":false}'>
    <div class="wrapper">
        @include('partials.sidebar')
        <div class="content-page">
            @include('partials.topbar')
            <div class="content">
                <div class="container-fluid">
                    @yield('content')
                </div>
            </div>
        </div>
    </div>
    @livewireScripts
    <script src="{{ asset('osen/js/app.js') }}"></script>
    @stack('scripts')
</body>
</html>

# 10-ViteFinalSetup.ps1
# # Set-Location leisure-suite  #  DISABLED  we are already in the right folder  #  DISABLED  we are already in the right folder

# vite.config.js (Laravel 12 + Livewire 3 ready)
@'
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
});
'@ | Out-File -Encoding utf8 vite.config.js

# resources/css/app.css (Tailwind + custom leisure styling)
@'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
    .btn-primary { @apply bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg; }
    .card { @apply bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8; }
    .input { @apply w-full px-4 py-3 border rounded-lg dark:bg-gray-700; }
}
'@ | Out-File -Encoding utf8 resources/css/app.css

# resources/js/app.js
@'
import './bootstrap';
import Alpine from 'alpinejs';
window.Alpine = Alpine;
Alpine.start();
'@ | Out-File -Encoding utf8 resources/js/app.js

# tailwind.config.js (full dark mode + forms plugin)
@'
/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: [
    "./resources/**/*.blade.php",
    "./resources/**/*.js",
    "./app/Http/Livewire/**/*.php",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
'@ | Out-File -Encoding utf8 tailwind.config.js

# postcss.config.js
@'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@ | Out-File -Encoding utf8 postcss.config.js

Write-Host "10 - Vite + Tailwind fully configured with dark mode and forms" -ForegroundColor Green

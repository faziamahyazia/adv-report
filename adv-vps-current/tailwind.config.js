import defaultTheme from 'tailwindcss/defaultTheme';
import forms from '@tailwindcss/forms';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './resources/js/**/*.vue',
    ],

    theme: {
        extend: {
            fontFamily: {
                sans: ['Figtree', ...defaultTheme.fontFamily.sans],
            },
            colors: {
                advanta: {
                    blue: '#0a3b82',
                    blueLight: '#1677c8',
                    green: '#00b140',
                    greenDark: '#008a3d',
                    gold: '#f9a800',
                    orange: '#ff5a00',
                    red: '#e31c4b',
                    magenta: '#a10f56',
                },
            },
        },
    },

    plugins: [forms],
};

import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";
import vue from "@vitejs/plugin-vue";
import { quasar, transformAssetUrls } from "@quasar/vite-plugin";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig({
  server: {
    port: 8002, // Or your desired port
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor1: ['vue', 'quasar', 'dayjs', 'material-design-icons-iconfont', 'vue-i18n'],
          vendor2: ['vue-echarts'],
          vendor3: ['echarts'],
        },
      },
    },
  },
  plugins: [
    vue({
      template: { transformAssetUrls },
    }),
    quasar({
      sassVariables: "/resources/css/quasar-variables.sass",
    }),
    laravel({
      input: ["resources/css/app.css", "resources/js/app.js"],
      refresh: true,
    }),
    VitePWA({
      registerType: "autoUpdate",
      injectRegister: false,
      outDir: "public",
      manifestFilename: "manifest.webmanifest",
      manifest: {
        name: "Advanta Report",
        short_name: "AdvReport",
        description: "Advanta Sales Activity & Demo Plot Report",
        theme_color: "#388E3C",
        background_color: "#ffffff",
        display: "standalone",
        orientation: "portrait-primary",
        scope: "/",
        start_url: "/admin/dashboard",
        icons: [
          {
            src: "/icons/icon-192x192.png",
            sizes: "192x192",
            type: "image/png",
          },
          {
            src: "/icons/icon-512x512.png",
            sizes: "512x512",
            type: "image/png",
          },
          {
            src: "/icons/icon-512x512.png",
            sizes: "512x512",
            type: "image/png",
            purpose: "maskable",
          },
        ],
      },
      workbox: {
        globDirectory: "public",
        globPatterns: ["build/assets/*.{js,css}"],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/(fonts\.googleapis\.com|fonts\.bunny\.net)\/.*/i,
            handler: "CacheFirst",
            options: {
              cacheName: "fonts-cache",
              expiration: {
                maxEntries: 20,
                maxAgeSeconds: 60 * 60 * 24 * 365,
              },
              cacheableResponse: { statuses: [0, 200] },
            },
          },
          {
            urlPattern: /\/uploads\/.*\.(jpg|jpeg|png|webp|gif)/i,
            handler: "StaleWhileRevalidate",
            options: {
              cacheName: "uploads-cache",
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 60 * 60 * 24 * 30,
              },
            },
          },
        ],
      },
    }),
  ],
});

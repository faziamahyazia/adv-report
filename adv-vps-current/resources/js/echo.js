import Echo from "laravel-echo";
import Pusher from "pusher-js";

window.Pusher = Pusher;

const runtimeConfig = window.CONFIG || {};
const reverbKey =
  runtimeConfig.REVERB_APP_KEY || import.meta.env.VITE_REVERB_APP_KEY;
const reverbHost =
  runtimeConfig.REVERB_HOST ||
  import.meta.env.VITE_REVERB_HOST ||
  window.location.hostname;
const reverbPort = Number(
  runtimeConfig.REVERB_PORT || import.meta.env.VITE_REVERB_PORT || 443
);
const reverbScheme =
  runtimeConfig.REVERB_SCHEME || import.meta.env.VITE_REVERB_SCHEME || "https";

if (!reverbKey) {
  console.warn("Echo tidak diinisialisasi: REVERB_APP_KEY kosong.");
} else {
  try {
    window.Echo = new Echo({
      broadcaster: "reverb",
      key: reverbKey,
      wsHost: reverbHost,
      wsPort: reverbPort,
      wssPort: reverbPort,
      forceTLS: reverbScheme === "https",
      enabledTransports: ["ws", "wss"],
    });
  } catch (error) {
    console.error("Gagal inisialisasi Echo", error);
  }
}

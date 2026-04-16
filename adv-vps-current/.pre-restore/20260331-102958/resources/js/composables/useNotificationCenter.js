import { onBeforeUnmount, onMounted, ref } from "vue";
import { usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";

const POLL_INTERVAL_MS = 30000;
const SEEN_NOTIFICATION_IDS_KEY = "advanta-report.notification.seen";
const MAX_SEEN_IDS = 100;

function routePath(name, fallback, params = {}) {
  if (typeof window.route === "function") {
    return window.route(name, params);
  }

  return fallback.replace(":id", params.id ?? "");
}

export default function useNotificationCenter() {
  const page = usePage();
  const $q = useQuasar();
  const items = ref([]);
  const unreadCount = ref(0);
  const isLoading = ref(false);
  const pushStatus = ref("unknown");
  const browserPermission = ref(
    typeof window !== "undefined" && "Notification" in window
      ? window.Notification.permission
      : "unsupported"
  );
  const pushSupported =
    typeof window !== "undefined" &&
    "serviceWorker" in navigator &&
    "PushManager" in window;

  let pollTimerId = null;
  let realtimeChannelName = null;
  let hasHydrated = false;

  function authUserId() {
    return page.props?.auth?.user?.id ?? null;
  }

  function getSeenIds() {
    try {
      const raw = sessionStorage.getItem(SEEN_NOTIFICATION_IDS_KEY);
      const parsed = raw ? JSON.parse(raw) : [];
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }

  function saveSeenIds(ids) {
    sessionStorage.setItem(
      SEEN_NOTIFICATION_IDS_KEY,
      JSON.stringify(ids.slice(-MAX_SEEN_IDS))
    );
  }

  function rememberNotifications(notificationIds) {
    const current = getSeenIds();
    const merged = [...new Set([...current, ...notificationIds])];
    saveSeenIds(merged);
  }

  async function getPushRegistration() {
    if (!pushSupported) {
      return null;
    }

    try {
      return await navigator.serviceWorker.register("/push-sw.js");
    } catch (error) {
      console.error("Gagal registrasi service worker push", error);
      return null;
    }
  }

  async function syncPushStatus() {
    if (!pushSupported) {
      pushStatus.value = "unsupported";
      return pushStatus.value;
    }

    const registration = await getPushRegistration();

    if (!registration) {
      pushStatus.value = "unsupported";
      return pushStatus.value;
    }

    const subscription = await registration.pushManager.getSubscription();
    pushStatus.value = subscription ? "subscribed" : "not-subscribed";
    return pushStatus.value;
  }

  function urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
    const base64 = (base64String + padding)
      .replace(/-/g, "+")
      .replace(/_/g, "/");
    const rawData = atob(base64);
    const outputArray = new Uint8Array(rawData.length);

    for (let index = 0; index < rawData.length; index += 1) {
      outputArray[index] = rawData.charCodeAt(index);
    }

    return outputArray;
  }

  async function registerAndSubscribePush() {
    if (!pushSupported || browserPermission.value !== "granted") {
      pushStatus.value = pushSupported ? "not-subscribed" : "unsupported";
      return;
    }

    const vapidPublicKey = window.CONFIG?.WEBPUSH_PUBLIC_KEY;

    if (!vapidPublicKey) {
      pushStatus.value = "missing-vapid-key";
      return;
    }

    const registration = await getPushRegistration();

    if (!registration) {
      pushStatus.value = "unsupported";
      return;
    }

    let subscription = await registration.pushManager.getSubscription();

    if (!subscription) {
      subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array(vapidPublicKey),
      });
    }

    const payload = subscription.toJSON();
    await axios.post(
      routePath(
        "admin.notification.push-subscribe",
        "/admin/notifications/push-subscribe"
      ),
      {
        endpoint: payload.endpoint,
        keys: payload.keys,
        content_encoding: payload.contentEncoding || "aes128gcm",
      }
    );

    pushStatus.value = "subscribed";
  }

  function maybeShowBrowserNotifications(notificationItems) {
    if (pushSupported) {
      return;
    }

    if (
      browserPermission.value !== "granted" ||
      typeof window === "undefined" ||
      !("Notification" in window)
    ) {
      return;
    }

    notificationItems.forEach((item) => {
      const notification = new window.Notification(item.title, {
        body: item.message,
        icon: "/icons/icon-192x192.png",
        tag: item.id,
      });

      notification.onclick = () => {
        window.focus();

        if (item.url) {
          window.location.assign(item.url);
        }
      };
    });
  }

  async function fetchNotifications({ silent = false } = {}) {
    if (!silent) {
      isLoading.value = true;
    }

    try {
      const response = await axios.get(
        routePath("admin.notification.inbox", "/admin/notifications/inbox")
      );

      const nextItems = response.data?.items || [];
      items.value = nextItems;
      unreadCount.value = response.data?.unread_count || 0;

      const unreadItems = nextItems.filter((item) => !item.read_at);
      const seenIds = getSeenIds();
      const unseenItems = unreadItems.filter((item) => !seenIds.includes(item.id));

      rememberNotifications(unreadItems.map((item) => item.id));

      if (hasHydrated) {
        maybeShowBrowserNotifications(unseenItems);
      }

      hasHydrated = true;
    } catch (error) {
      if (!silent) {
        console.error("Gagal memuat notification inbox", error);
      }
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  async function markAsRead(id) {
    await axios.post(
      routePath("admin.notification.read", "/admin/notifications/:id/read", {
        id,
      })
    );
    await fetchNotifications({ silent: true });
  }

  async function requestBrowserPermission() {
    if (!("Notification" in window)) {
      browserPermission.value = "unsupported";
      pushStatus.value = "unsupported";
      return browserPermission.value;
    }

    browserPermission.value = await window.Notification.requestPermission();

    if (browserPermission.value === "granted") {
      await registerAndSubscribePush();
    } else {
      await syncPushStatus();
    }

    return browserPermission.value;
  }

  async function markAllAsRead() {
    await axios.post(
      routePath("admin.notification.read-all", "/admin/notifications/read-all")
    );
    await fetchNotifications({ silent: true });
  }

  async function replyToNotification(id, message, attachmentFile = null) {
    const payload = new FormData();
    payload.append("message", message || "");

    if (attachmentFile) {
      payload.append("attachment", attachmentFile);
    }

    await axios.post(
      routePath("admin.notification.reply", "/admin/notifications/:id/reply", {
        id,
      }),
      payload,
      {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      }
    );

    await fetchNotifications({ silent: true });
  }

  async function fetchNotificationThread(id) {
    const response = await axios.get(
      routePath("admin.notification.thread", "/admin/notifications/:id/thread", {
        id,
      })
    );

    return {
      threadKey: response.data?.thread_key || null,
      items: response.data?.items || [],
    };
  }

  async function openNotification(item, { navigate = true } = {}) {
    if (!item.read_at) {
      await markAsRead(item.id);
    }

    if (navigate && item.url) {
      window.location.assign(item.url);
    }
  }

  function startPolling() {
    if (pollTimerId !== null) {
      clearInterval(pollTimerId);
    }

    pollTimerId = window.setInterval(() => {
      fetchNotifications({ silent: true });
    }, POLL_INTERVAL_MS);
  }

  function stopPolling() {
    if (pollTimerId !== null) {
      clearInterval(pollTimerId);
      pollTimerId = null;
    }
  }

  function subscribeRealtimeNotifications() {
    const userId = authUserId();

    if (!userId || typeof window === "undefined" || !window.Echo) {
      return;
    }

    realtimeChannelName = `App.Models.User.${userId}`;

    window.Echo.private(realtimeChannelName).notification((notification) => {
      if (notification?.context === "admin_info" && notification?.context_action === "read") {
        $q.notify({
          color: "positive",
          message: notification?.message || "Notifikasi sudah dibaca penerima.",
          position: "top",
        });
      }

      if (notification?.context === "admin_info" && notification?.context_action === "reply") {
        $q.notify({
          color: "primary",
          message: notification?.message || "Ada balasan notifikasi baru.",
          position: "top",
        });
      }

      fetchNotifications({ silent: true });
    });
  }

  function unsubscribeRealtimeNotifications() {
    if (typeof window === "undefined" || !window.Echo || !realtimeChannelName) {
      return;
    }

    window.Echo.leave(realtimeChannelName);
    realtimeChannelName = null;
  }

  onMounted(() => {
    syncPushStatus().catch((error) => {
      console.error("Gagal sinkron status web push", error);
    });

    if (pushSupported && browserPermission.value === "granted") {
      registerAndSubscribePush().catch((error) => {
        console.error("Gagal registrasi web push", error);
      });
    }

    fetchNotifications();
    subscribeRealtimeNotifications();
    startPolling();
  });

  onBeforeUnmount(() => {
    unsubscribeRealtimeNotifications();
    stopPolling();
  });

  return {
    items,
    unreadCount,
    isLoading,
    pushStatus,
    pushSupported,
    browserPermission,
    fetchNotifications,
    syncPushStatus,
    registerAndSubscribePush,
    requestBrowserPermission,
    markAllAsRead,
    replyToNotification,
    fetchNotificationThread,
    openNotification,
  };
}

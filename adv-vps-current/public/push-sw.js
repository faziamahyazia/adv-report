self.addEventListener("push", (event) => {
  const fallback = {
    title: "Informasi Baru",
    body: "Ada pemberitahuan baru.",
    icon: "/icons/icon-192x192.png",
    url: "/admin/dashboard",
  };

  let payload = {};

  try {
    payload = event.data ? event.data.json() : {};
  } catch (_error) {
    payload = {
      title: fallback.title,
      body: event.data ? event.data.text() : fallback.body,
    };
  }

  const notification = payload.notification || payload;
  const title = notification.title || fallback.title;
  const body = notification.body || payload.body || fallback.body;
  const icon = notification.icon || payload.icon || fallback.icon;
  const url = payload.url || (notification.data && notification.data.url) || fallback.url;

  event.waitUntil(
    self.registration.showNotification(title, {
      body,
      icon,
      badge: "/icons/icon-192x192.png",
      tag: payload.id || payload.tag || title,
      data: {
        url,
      },
    })
  );
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();

  const targetUrl = (event.notification.data && event.notification.data.url) || "/admin/dashboard";

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ("focus" in client) {
          client.navigate(targetUrl);
          return client.focus();
        }
      }

      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }

      return null;
    })
  );
});

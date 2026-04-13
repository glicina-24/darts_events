self.addEventListener("push", (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (_e) {
    data = {};
  }

  const title = data.title || "Darts Events";
  const body = data.body || "新しいお知らせがあります";
  const url = data.url || "/";
  const targetUrl = new URL(url, self.location.origin).toString();

  event.waitUntil(
    self.registration.showNotification(title, {
      body,
      tag: data.tag || "default",
      data: { url: targetUrl }
    })
  );
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const targetUrl = event.notification.data?.url || self.location.origin;

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url === targetUrl && "focus" in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow(targetUrl);
    })
  );
});

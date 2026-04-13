function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content;
}

function vapidPublicKey() {
  return document.querySelector('meta[name="vapid-public-key"]')?.content;
}

function urlBase64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
  const raw = window.atob(base64);
  return Uint8Array.from([...raw].map((char) => char.charCodeAt(0)));
}

async function saveSubscription(subscription) {
  const json = subscription.toJSON();
  const response = await fetch("/push_subscription", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken()
    },
    credentials: "same-origin",
    body: JSON.stringify({
      push_subscription: {
        endpoint: subscription.endpoint,
        p256dh: json.keys?.p256dh,
        auth: json.keys?.auth,
        expiration_time: subscription.expirationTime,
        user_agent: navigator.userAgent
      }
    })
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`push_subscription save failed: ${response.status} ${body}`);
  }
}

async function ensurePushSubscription() {
  if (document.body.dataset.signedIn !== "true") return;
  if (!("serviceWorker" in navigator)) return;
  if (!("PushManager" in window)) return;
  if (!("Notification" in window)) return;

  const vapid = vapidPublicKey();
  if (!vapid) return;

  const registration = await navigator.serviceWorker.register("/service-worker");

  const permission = await Notification.requestPermission();
  if (permission !== "granted") return;

  let subscription = await registration.pushManager.getSubscription();
  if (!subscription) {
    subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(vapid)
    });
  }

  await saveSubscription(subscription);
}

document.addEventListener("turbo:load", () => {
  ensurePushSubscription().catch((error) => {
    console.error("[push] subscription setup failed", error);
  });
});

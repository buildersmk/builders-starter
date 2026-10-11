import { Controller } from "@hotwired/stimulus"

// Opt the person into web push on a tap. Needs the server's VAPID public key:
// data-controller="push" data-push-key-value="<%= ENV["VAPID_PUBLIC_KEY"] %>"
// and a button: data-action="push#subscribe". No key → the button no-ops.
export default class extends Controller {
  static values = { key: String, url: String }

  async subscribe() {
    if (!this.hasKeyValue || !("serviceWorker" in navigator) || !("PushManager" in window)) return

    const permission = await Notification.requestPermission()
    if (permission !== "granted") return

    const registration = await navigator.serviceWorker.ready
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: this.#bytes(this.keyValue)
    })

    await fetch(this.urlValue || "/push_subscription", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.#csrf() },
      body: JSON.stringify(subscription.toJSON())
    })
  }

  #csrf() {
    return document.querySelector("meta[name=csrf-token]")?.content || ""
  }

  #bytes(base64url) {
    const padding = "=".repeat((4 - (base64url.length % 4)) % 4)
    const base64 = (base64url + padding).replace(/-/g, "+").replace(/_/g, "/")
    const raw = atob(base64)
    return Uint8Array.from([...raw].map((char) => char.charCodeAt(0)))
  }
}

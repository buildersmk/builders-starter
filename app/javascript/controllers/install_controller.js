import { Controller } from "@hotwired/stimulus"

// Registers the service worker on every page and powers the "Install app" button. The button
// (data-install-target="button") stays hidden until the browser says the app is installable.
// Put it on body: data-controller="install" data-install-worker-value="/service-worker.js".
export default class extends Controller {
  static values = { worker: String, scope: String }
  static targets = ["button"]

  connect() {
    this.#registerWorker()
    this.onPrompt = (event) => {
      event.preventDefault()
      this.deferred = event
      this.buttonTargets.forEach((button) => button.classList.remove("hidden"))
    }
    window.addEventListener("beforeinstallprompt", this.onPrompt)
  }

  disconnect() {
    window.removeEventListener("beforeinstallprompt", this.onPrompt)
  }

  async install() {
    if (!this.deferred) return
    this.deferred.prompt()
    await this.deferred.userChoice
    this.deferred = null
    this.buttonTargets.forEach((button) => button.classList.add("hidden"))
  }

  #registerWorker() {
    if (!("serviceWorker" in navigator) || !this.hasWorkerValue) return
    navigator.serviceWorker
      .register(this.workerValue, { scope: this.scopeValue || "/" })
      .catch((error) => console.warn("service worker did not register", error))
  }
}

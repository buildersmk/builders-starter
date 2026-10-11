import { Controller } from "@hotwired/stimulus"

// A dropdown menu: a button that toggles a panel, closing on an outside click or Escape.
// <div data-controller="menu"> <button data-action="menu#toggle"> … <div data-menu-target="panel" class="hidden"> … </div></div>
export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.onDocumentClick = (event) => { if (!this.element.contains(event.target)) this.close() }
    this.onKeydown = (event) => { if (event.key === "Escape") this.close() }
    document.addEventListener("click", this.onDocumentClick)
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("keydown", this.onKeydown)
  }

  toggle() {
    this.panelTarget.classList.toggle("hidden")
  }

  close() {
    this.panelTarget.classList.add("hidden")
  }
}

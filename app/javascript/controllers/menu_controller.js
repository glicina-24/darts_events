import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "iconOpen", "iconClose", "backdrop"]

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.panelTarget.classList.remove("translate-x-full")
    this.backdropTarget.classList.remove("hidden")
    this.iconOpenTarget.classList.add("hidden")
    this.iconCloseTarget.classList.remove("hidden")
  }

  close() {
    this.panelTarget.classList.add("translate-x-full")
    this.backdropTarget.classList.add("hidden")
    this.iconOpenTarget.classList.remove("hidden")
    this.iconCloseTarget.classList.add("hidden")
  }

  get isOpen() {
    return !this.panelTarget.classList.contains("translate-x-full")
  }
}
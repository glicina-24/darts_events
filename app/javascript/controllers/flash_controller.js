import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    setTimeout(() => {
      this.messageTarget.classList.add("opacity-0", "transition", "duration-700")
    }, 2500)
    setTimeout(() => {
      this.element.remove()
    }, 3300)
  }
}
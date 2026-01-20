import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "selected"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.element.dataset.connected = "1"
  }

  preventEnter(e) {
    if (e.key === "Enter") e.preventDefault()
  }

  search() {
    console.log("search fired")

    clearTimeout(this.timeout)
    const q = this.inputTarget.value.trim()
    const selectedIds = this.selectedIds().join(",")

    if (q.length === 0) {
      this.resultsTarget.innerHTML = ""
      return
    }

    this.timeout = setTimeout(async () => {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("q", q)
      url.searchParams.set("selected_ids", selectedIds)

      const res = await fetch(url.toString(), { headers: { Accept: "text/html" } })
      this.resultsTarget.innerHTML = await res.text()
    }, 250)
  }

  add(e) {
    const id = e.currentTarget.dataset.userId
    const name = e.currentTarget.dataset.userName

    if (this.selectedIds().includes(Number(id))) return

    const chip = document.createElement("span")
    chip.className = "inline-flex items-center gap-2 px-3 py-1 rounded-full border bg-white"
    chip.dataset.userId = id
    chip.innerHTML = `
      <span>${this.escape(name)}</span>
      <button type="button" class="text-slate-500 hover:text-red-600"
        data-action="click->pro-picker#remove" data-user-id="${id}">×</button>
      <input type="hidden" name="event[pro_player_ids][]" value="${id}">
    `
    this.selectedTarget.appendChild(chip)

    this.inputTarget.value = ""
    this.resultsTarget.innerHTML = ""
    this.inputTarget.focus()
  }

  remove(e) {
    const id = e.currentTarget.dataset.userId
    const chip = this.selectedTarget.querySelector(`[data-user-id="${id}"]`)
    if (chip) chip.remove()
  }

  selectedIds() {
    return Array.from(this.selectedTarget.querySelectorAll("[data-user-id]"))
      .map(el => Number(el.dataset.userId))
  }

  escape(str) {
    return str.replace(/[&<>"']/g, (m) => ({
      "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"
    }[m]))
  }
}
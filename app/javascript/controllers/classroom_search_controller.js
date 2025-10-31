import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    classroomsUrl: String,
    target: String
  }

  connect() {
    this.timeout = null
    this.targetElement = document.getElementById(this.targetValue)
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 200)
  }

  async performSearch() {
    const query = this.inputTarget.value.trim()
    
    if (query.length >= 1) {
      const response = await fetch(`${this.classroomsUrlValue}?query=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'text/vnd.turbo-stream.html'
        }
      })

      if (response.ok) {
        const stream = await response.text()
        Turbo.renderStreamMessage(stream)
      }
    } else {
      this.reset()
    }
  }

  reset() {
    this.inputTarget.value = ''
    fetch(this.classroomsUrlValue, {
      headers: { 'Accept': 'text/vnd.turbo-stream.html' }
    })
    .then(response => response.text())
    .then(stream => Turbo.renderStreamMessage(stream))
  }
}
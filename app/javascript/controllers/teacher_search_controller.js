import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    teachersUrl: String,
    target: String,
    partial: String
  }

  connect() {
    this.timeout = null
    this.targetElement = document.getElementById(this.targetValue)
    if (!this.targetElement) {
      console.error(`Element with id "${this.targetValue}" not found`)
    }
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 300)
  }

  async performSearch() {
    console.log(this.partialValue)
    const query = this.inputTarget.value.trim()
    
    if (query.length >= 1) {
      const response = await fetch(`${this.teachersUrlValue}?query=${encodeURIComponent(query)}&partial=${this.partialValue}`, {
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
    fetch(`${this.teachersUrlValue}?partial=${this.partialValue}`, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => response.text())
    .then(stream => Turbo.renderStreamMessage(stream))
  }
}
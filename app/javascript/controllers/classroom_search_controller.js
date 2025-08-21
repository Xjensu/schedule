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
      const html = await response.text()
      
      document.getElementById("schedule_classrooms").innerHTML = html
    } else {
      this.reset()
    }
  }

  reset() {
    this.inputTarget.value = ''
    // Здесь можно добавить запрос для получения исходного списка
    fetch(this.classroomsUrlValue, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => response.text())
    .then(html => {
      document.getElementById("schedule_classrooms").innerHTML = html
    })
  }
}
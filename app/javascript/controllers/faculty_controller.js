import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values={
    url: String
  }

  static targets= [ "button" ]

  connect() {
  }

  disconnect() {
  }

  handleClick(event) {
    const ignoredElement = event.target.closest("[data-faculty-ignore]")
    if (ignoredElement) return

    if (this.urlValue) {
      Turbo.visit(this.urlValue, { frame: "_top" })
    }
  }
}

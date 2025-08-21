import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["resizer", "offcanvas"]
  static values = {
    minWidth: { type: Number, default: 300 },
    maxWidth: { type: Number, default: 800 },
    direction: { type: String, default: "start" } // Добавляем направление
  }

  connect() {
    this.isResizing = false
    this.startX = 0
    this.startWidth = 0
  }

  startResize(e) {
    this.isResizing = true
    this.startX = e.clientX
    this.startWidth = parseInt(document.defaultView.getComputedStyle(this.offcanvasTarget).width, 10)
    
    document.addEventListener('mousemove', this.resize.bind(this))
    document.addEventListener('mouseup', this.stopResize.bind(this))
    
    e.preventDefault()
  }

  resize(e) {
    if (!this.isResizing) return
    
    // Модифицируем расчет ширины в зависимости от направления
    let width;
    if (this.directionValue === "end") {
      width = this.startWidth - (e.clientX - this.startX) // Инвертируем для правой панели
    } else {
      width = this.startWidth + (e.clientX - this.startX)
    }
    
    const clampedWidth = Math.min(Math.max(width, this.minWidthValue), this.maxWidthValue)
    
    this.offcanvasTarget.style.width = `${clampedWidth}px`
    this.offcanvasTarget.style.flex = '0 0 auto'
  }

  stopResize() {
    this.isResizing = false
    document.removeEventListener('mousemove', this.resize.bind(this))
    document.removeEventListener('mouseup', this.stopResize.bind(this))
  }
}
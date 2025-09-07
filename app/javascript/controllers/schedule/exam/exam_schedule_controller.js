import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect(){
    const offcanvasElement = document.getElementById("offcanvasScrolling")
    this.offcanvas = bootstrap.Offcanvas.getInstance(offcanvasElement) || 
                     new bootstrap.Offcanvas(offcanvasElement)
  }
  select(event){
    this.offcanvas.show()
  }
}
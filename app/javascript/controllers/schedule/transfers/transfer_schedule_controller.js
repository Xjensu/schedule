import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]
  static values = { groupId: String }

  connect(){
    console.log("conn")
    const offcanvasElement = document.getElementById("transfersList")
    this.listOffcanvas = bootstrap.Offcanvas.getInstance(offcanvasElement) || 
                     new bootstrap.Offcanvas(offcanvasElement)

    this.listOffcanvas.show()
  }


}
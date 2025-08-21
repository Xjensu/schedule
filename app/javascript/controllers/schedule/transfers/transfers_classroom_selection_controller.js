import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets= ["hiddenField"];
  
  connect() {
    console.log("CONENENENEN");
  }

  updateHiddenField(event) {
    console.log("selected", event.target.value);
    this.hiddenFieldTarget.value = event.target.value

    const unsavedChanges = this.application.getControllerForElementAndIdentifier(
      this.element, "unsaved-changes"
    )
    if (unsavedChanges) unsavedChanges.checkChanges()
  }

}
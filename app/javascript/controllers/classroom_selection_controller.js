import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hiddenField"]

  connect() {
    const classroom = this.hiddenFieldTarget.value || 0;

    const radioButton = document.getElementById(`schedule_classroom_id_${classroom}`);
    if (radioButton) {
      radioButton.checked = true;
    }
  }

  updateHiddenField(event) {
    if (this.hasHiddenFieldTarget) {
      this.hiddenFieldTarget.value = event.target.value;
    }
  }

}
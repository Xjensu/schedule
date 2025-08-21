import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.hiddenField = document.getElementById('schedule_teacher_id');
    const selectedTeacherId = this.hiddenField.value || 0;

    const radioButton = document.getElementById(`schedule_teacher_id_${selectedTeacherId}`);
    if (radioButton) {
      radioButton.checked = true;
    }
  }

  selectTeacher(event) {
    this.hiddenField.value = event.target.value
  }

}
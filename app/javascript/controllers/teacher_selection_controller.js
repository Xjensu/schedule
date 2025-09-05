import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets=["hiddenField"]
  connect() {
    this.hiddenField = document.getElementById('schedule_teacher_id');
    console.log(this.hiddenFieldTarget)
    const selectedTeacherId = this.hiddenFieldTarget.value || 0;
    
    const radioButton = document.getElementById(`schedule_teacher_id_${selectedTeacherId}`);
    if (radioButton) {
      radioButton.checked = true;
    }
  }

  selectTeacher(event) {
    this.hiddenFieldTarget.value = event.target.value
  }

}
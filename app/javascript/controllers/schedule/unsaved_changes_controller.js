// unsaved_changes_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton"]
  static values = {
    initialTeacher: Number,
    initialClassroom: Number
  }

  connect() {
    console.log(this.submitButtonTarget)
    this.hasUnsavedChanges = false
    this.updateSubmitButton()
  }

  checkChanges() {
    console.log("CHECH")
    const currentTeacher = parseInt(this.element.querySelector('[name="change[teacher_id]"]:checked')?.value || 0)
    const currentClassroom = parseInt(this.element.querySelector('[name="change[classroom_id]"]:checked')?.value || 0)
    
    const teacherChanged = currentTeacher !== this.initialTeacherValue
    const classroomChanged = currentClassroom !== this.initialClassroomValue
    
    this.hasUnsavedChanges = teacherChanged || classroomChanged
    console.log(this.hasUnsavedChanges)
    this.updateSubmitButton()
  }

  updateSubmitButton() {
    console.log(this.hasSubmitButtonTarget)
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.style.display = this.hasUnsavedChanges ? 'block' : 'none'
    }
  }

  beforeUnload(event) {
    if (this.hasUnsavedChanges) {
      event.preventDefault()
      event.returnValue = 'У вас есть несохраненные изменения. Вы уверены, что хотите уйти?'
    }
  }
}
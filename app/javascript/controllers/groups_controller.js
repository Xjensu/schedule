import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["groupSelect", "courseSelect", "academicPeriodSelect"]

  connect() {
  }


  deleteGroup() {
    const selectedGroupId = this.groupSelectTarget.value;
    if (!selectedGroupId) {
      alert("Пожалуйста, выберите группу для удаления");
      return;
    }

    fetch(`/admin/student_groups/${selectedGroupId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      credentials: 'same-origin'
    }).then(response => {
      return response.text();
    })
    .then(text => {
      Turbo.renderStreamMessage(text);
    })
    .catch(error => {
      console.error('Error:', error);
    });
  }

  confirm(event) {
    const scheduleType = event.currentTarget.dataset.scheduleType;
    
    const formData = {
      group_id: this.groupSelectTarget.value,
      course: this.courseSelectTarget.value,
      academic_period_id: this.academicPeriodSelectTarget.value
    }

    const url = new URL(`/admin/${scheduleType.toString()}_schedules`, window.location.origin);

    Object.entries(formData).forEach(([key, value]) => {
      if (value !== null && value !== undefined) {
        url.searchParams.append(key, value);
      }
    });

    Turbo.visit(url.toString());
  }
}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["academicPeriodSelect", "editPeriodBtn"]

  connect() {
    console.log("CONN ACADEM")
    this.updateEditButtonState();
    this.academicPeriodSelectTarget.addEventListener('change', () => {
      this.updateEditButtonState();
    });
  }

  updateEditButtonState() {
    const selectedPeriodId = this.academicPeriodSelectTarget.value;
    this.editPeriodBtnTarget.style.display = selectedPeriodId ? 'inline-block' : 'none';
    
    if (selectedPeriodId) {
      this.editPeriodBtnTarget.href = `/admin/academic_periods/${selectedPeriodId}/edit?faculty_id=${this.getFacultyId()}`;
    }
  }

  getFacultyId() {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get('faculty_id') || document.body.dataset.facultyId;
  }

  editAcademicPeriod(event) {
    const selectedPeriodId = this.academicPeriodSelectTarget.value;
    if (!selectedPeriodId) {
      event.preventDefault();
      alert("Пожалуйста, выберите академический период для редактирования");
      return;
    }
  }

  deleteAcademicPeriod(event) {
    const selectedPeriodId = this.academicPeriodSelectTarget.value;
    if (!selectedPeriodId) {
      event.preventDefault();
      alert("Пожалуйста, выберите академический период для удаления");
      return;
    }

    if (!confirm("Вы уверены, что хотите удалить этот академический период? Это действие нельзя отменить.")) {
      event.preventDefault();
      return;
    }

    // Отправляем DELETE запрос
    fetch(`/admin/academic_periods/${selectedPeriodId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin',
      body: JSON.stringify({
        faculty_id: this.getFacultyId()
      })
    })
    .then(response => {
      if (response.ok) {
        return response.text();
      }
      throw new Error('Network response was not ok.');
    })
    .then(text => {
      Turbo.renderStreamMessage(text);
    })
    .catch(error => {
      console.error('Error:', error);
      alert('Произошла ошибка при удалении периода');
    });
    
    event.preventDefault();
  }
}
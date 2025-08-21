import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  handleDragStart(event) {
    event.dataTransfer.setData('application/json', JSON.stringify({
      scheduleId: this.element.dataset.scheduleId,
      time: this.element.dataset.time,
      groupId: this.element.dataset.groupId,
      under: this.element.dataset.under,
      academicPeriodId: this.element.dataset.academicPeriodId,
      source: event.target.dataset.transferScheduleCardTarget,
      date: this.element.dataset.date,
      course: this.element.dataset.course,
      elementId: event.target.id
    }));
    
    // Добавляем визуальный эффект
    event.currentTarget.classList.add('dragging');
    event.dataTransfer.effectAllowed = 'move';

    document.getElementById('trash-bin').style.display = 'flex'

    event.dataTransfer.setData('text/plain', event.target.id)
  }

  handleDragEnd(event) {
    // Убираем визуальные эффекты
    event.currentTarget.classList.remove('dragging')
    // Скрываем мусорку
    document.getElementById('trash-bin').style.display = 'none'
  }
}
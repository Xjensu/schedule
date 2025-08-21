import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    time: String
  }


  handleDragOver(event) {
    if (event.target.offsetParent.attributes.draggable){
      event.preventDefault()
      event.dataTransfer.dropEffect = 'move'
      event.target.offsetParent.classList.add('border-warning')
    }
  }

  handleDragLeave(event) {
    if (this.isDraggableElement(event.target)) {
      event.target.offsetParent.classList.remove('border-warning')
    }
  }

  async handleDrop(event) {
    event.preventDefault();
    const dropTarget = this.findDraggableParent(event.target)
    if (!dropTarget) return

    dropTarget.classList.remove('border-warning')

    const draggedElementId = event.dataTransfer.getData('text/plain')
    const draggedElement = document.getElementById(draggedElementId)
    if (!draggedElement || draggedElement === dropTarget) return

    const current_dataset = dropTarget.dataset

    const draggedData = JSON.parse(event.dataTransfer.getData('application/json'))
    const dropTargetData = {
      scheduleId: dropTarget.dataset.scheduleId,
      time: dropTarget.dataset.time,
      groupId: dropTarget.dataset.groupId,
      under: dropTarget.dataset.under,
      academicPeriodId: dropTarget.dataset.academicPeriodId,
      date: dropTarget.dataset.date
    }
    const dataset = {
      source_schedule_id: draggedData.scheduleId,
      target_schedule_id: current_dataset.scheduleId,
      group_id: draggedData.groupId,
      source_date: draggedData.date,
      target_date: current_dataset.date,
      course: draggedData.course,
      operation: (!current_dataset.scheduleId.trim() == !draggedData.scheduleId.trim()) ? 'replace' : 'transfer',
      source: draggedData.source,
      target: current_dataset.transferScheduleCardTarget,
      source_time: draggedData.time,
      target_time: current_dataset.time,
    }
    console.log(dataset)

    await this.sendTransferData(dataset);
    // this.swapElements(draggedElement, dropTarget, draggedData, dropTargetData); 
  }

  async sendTransferData(dataset) {
    try {
      const response = await fetch('/admin/transfer_schedules/update_sidebar', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        },
        body: JSON.stringify({ dataset: dataset })
      });

      if (response.ok) {
        const html = await response.text();
        Turbo.renderStreamMessage(html);
      }
    } catch (error) {
      console.error('Error:', error);
    }
  }
  

  isDraggableElement(element) {
    return element.closest('[draggable="true"]')
  }

  findDraggableParent(element) {
    return element.closest('[draggable="true"]')
  }

}
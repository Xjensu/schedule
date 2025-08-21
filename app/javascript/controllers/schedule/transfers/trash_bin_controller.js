import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleDragOver(event) {
    event.preventDefault()
    this.element.classList.add('bg-danger', 'bg-opacity-10')
    event.dataTransfer.dropEffect = 'move'
  }

  handleDragLeave(event) {
    event.preventDefault()
    this.element.classList.remove('bg-danger', 'bg-opacity-10')
  }

  async handleDrop(event) {
    event.preventDefault();
    this.element.classList.remove('bg-danger', 'bg-opacity-10');
    
    const dataset = JSON.parse(event.dataTransfer.getData('application/json'));
    let datas =  {
      source_schedule_id: dataset.scheduleId,
      target_schedule_id: null,
      group_id: dataset.groupId,
      source_date: dataset.date,
      target_date: null,
      new_start_time: null,
      course: dataset.course,
      operation: 'delete',
      source: dataset.source,
      target: null,
      source_time: dataset.time,
      target_time: null,
    } ;

    await this.sendTransferData(datas);
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
}
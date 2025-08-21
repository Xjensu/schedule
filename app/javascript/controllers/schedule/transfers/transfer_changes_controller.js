import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect(){
    const editOffcanvasElement = document.getElementById("editPanel")
    this.editPanel = bootstrap.Offcanvas.getInstance(editOffcanvasElement) || 
                     new bootstrap.Offcanvas(editOffcanvasElement);
  }

  async openEditPanel(event){
    this.editPanel.show();
    const dataset = {
      changeId: event.currentTarget.dataset.changeId,
      teacherId: event.currentTarget.dataset.teacherId,
      classroomId: event.currentTarget.dataset.classroomId
    }
    await this.sendTransferData(dataset);
  }

   async sendTransferData(dataset) {
    try {
      const response = await fetch(`/admin/added_schedules/${dataset['changeId']}/edit?added_schedule[teacher_id]=${dataset['teacherId']}&added_schedule[classroom_id]=${dataset['classroomId']}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        }
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
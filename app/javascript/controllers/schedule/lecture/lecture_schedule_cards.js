import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect(){
    const offcanvasElement = document.getElementById("offcanvasScrolling")
    this.offcanvas = bootstrap.Offcanvas.getInstance(offcanvasElement) || 
                     new bootstrap.Offcanvas(offcanvasElement)
  }
  mouseoverElement(event){
    event.currentTarget.style.backgroundColor = 'yellow';
  }

  mouseoutElement(event){
    event.currentTarget.style.backgroundColor = '';
  }

  async showScheduleEditor(event){
    this.offcanvas.show()
    console.log("da")
    const special_period_id = event.currentTarget.dataset.specialPeriodId;
    const start_time = event.currentTarget.dataset.startTime;
    const teacher_id = event.currentTarget.dataset.teacherId;
    const subject_id = event.currentTarget.dataset.subjectId;
    const schedule_id = event.currentTarget.dataset.scheduleId;
    const classroom_id = event.currentTarget.dataset.classroomId
    const student_group_id = event.currentTarget.dataset.groupId;
    const course = event.currentTarget.dataset.course 

    let url = `/admin/lecture_schedules/editor/?start_time=${start_time}&special_period_id=${special_period_id}&course=${course}&teacher_id=${teacher_id}&subject_id=${subject_id}&classroom_id=${classroom_id}&schedule_id=${schedule_id}&student_group_id=${student_group_id}`

    try {
      const response = await fetch(url, {
        headers: {
          Accept: "text/vnd.turbo-stream.html"
        }
      })
      
      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Error fetching schedule:", error)
    }
  }
}
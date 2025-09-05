import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  connect(){
    console.log("conn")
    const offcanvasElement = document.getElementById("offcanvasScrolling")
    this.offcanvas = bootstrap.Offcanvas.getInstance(offcanvasElement) || 
                     new bootstrap.Offcanvas(offcanvasElement)
  }

  select(event) {
    this.offcanvas.show()

    const card = event.currentTarget
    const scheduleId = card.dataset.scheduleId
    const course = card.dataset.course
    const time = card.dataset.time
    const day = card.dataset.day
    const groupId = card.dataset.groupId
    const under = card.dataset.under
    const academicPeriodId = card.dataset.academicPeriodId

    let url = `/admin/default_schedules/editor?group_id=${groupId}&academic_period_id=${academicPeriodId}&day=${day}&time=${time}&course=${course}`
    if (under) {
      url += `&under=${under}`
    }

    document.querySelectorAll('.schedule-card').forEach(c => {
        c.classList.remove('selected-card')
        c.id = ''
    })
      
    // Добавляем выделение текущей карточке
    card.classList.add('selected-card')
    this.element.id = `schedule_${scheduleId ? scheduleId : '0'}`
    console.log(this.element.id)


    if (!scheduleId) {
      this.handleNewSchedule(url)
    } else {
      this.handleExistingSchedule(scheduleId, url)
    }
  }

  handleNewSchedule(url) {  
    this.handleUrl(url)
  }

  handleExistingSchedule(scheduleId, url) {
    url += `&schedule_id=${scheduleId}`
    this.handleUrl(url)
  }

  handleUrl(url){
    fetch(url, {
        headers: {
          Accept: "text/vnd.turbo-stream.html",
        }
      })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }

}
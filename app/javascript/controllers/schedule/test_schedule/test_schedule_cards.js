import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect(){
    console.log("Connected")
    const offcanvasElement = document.getElementById("offcanvasScrolling")
    this.offcanvas = bootstrap.Offcanvas.getInstance(offcanvasElement) || 
                     new bootstrap.Offcanvas(offcanvasElement)
  }
  clicked(event){
    this.offcanvas.show()
    console.log("CLICK!")
    console.log(this.elevent)
    console.log(event.target.offsetParent.dataset)

    const scheduleId = event.currentTarget.dataset.scheduleId
    const course = event.currentTarget.dataset.course
    const time = event.currentTarget.dataset.time
    const groupId = event.currentTarget.dataset.groupId
    const academicPeriodId = event.currentTarget.dataset.academicPeriodId
    const specialPeriodId = event.currentTarget.dataset.specialPeriodId

    let url = `/admin/test_schedules/editor?group_id=${groupId}&academic_period_id=${academicPeriodId}&time=${time}&course=${course}&special_period_id=${specialPeriodId}`

    document.querySelectorAll('.schedule-card').forEach(c => {
        c.classList.remove('selected-card')
        c.id = ''
    })

    event.currentTarget.classList.add('selected-card')
    this.element.id = `schedule_${scheduleId ? scheduleId : '0'}`

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
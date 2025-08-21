import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sourceDate", "targetDate"]
  static values = {
    groupId: String,
    course: String,
    academicPeriodId: String
  }


  async handleDateChange(event) {
    const date = event.target.value
    const target = event.target.dataset.dateChangeTarget
    
    const params = new URLSearchParams({
      group_id: this.groupIdValue,
      course: this.courseValue,
      academic_period_id: this.academicPeriodIdValue,
      date: date
    })

    const url = `/admin/transfer_schedules/schedule_for_date?${params.toString()}&target=${target}`
    
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
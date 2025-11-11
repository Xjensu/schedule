class StudentScheduleController < ApplicationController
  def index
    group_id = params[:group_id]
    course = params[:course]
    @schedule_type = params[:schedule_type]
    if @schedule_type.present?
      @schedules = Rails.cache.read("#{@schedule_type}_schedule:group:#{group_id}:course:#{course}")
    else
      @schedule_type= :default
      @schedules = Rails.cache.read("schedules_for_group:#{group_id}_course:#{course}")
    end
    puts "addddddddddddddddaAAAAAAAAAAAAA", @schedule_type
    @times = ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10']
    @days = ['Понедельник', 'Вторник', 'Среда', 'Четверг','Пятница','Суббота']
  end


   def download
    group_id = params[:group_id]
    course = params[:course]
    @schedule_type = params[:schedule_type]
    if @schedule_type.present?
      @schedules = Rails.cache.read("#{@schedule_type}_schedule:group:#{group_id}:course:#{course}")
    else
      @schedule_type= :default
      @schedules = Rails.cache.read("schedules_for_group:#{group_id}_course:#{course}")
    end
    @times = ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10']
    @days = ['Понедельник', 'Вторник', 'Среда', 'Четверг','Пятница','Суббота']

    respond_to do |format|
      format.html do
        html_content = render_to_string(
          template: 'student_schedule/download',
          layout: false,
          locals: { 
            schedules: @schedules, 
            days: @days, 
            times: @times,
            schedule_type: @schedule_type
          }
        )
        
        send_data(
          html_content,
          filename: "#{@schedules[0][:dates][0][:schedule].first.student_group.group_name}-#{course}.html",
          type: 'text/html',
          disposition: 'attachment'
        )
      end
    end
  end
end

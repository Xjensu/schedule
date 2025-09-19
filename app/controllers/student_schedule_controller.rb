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
    @times = ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10', '18:45']
    @days = ['Понедельник', 'Вторник', 'Среда', 'Четверг','Пятница','Суббота']
  end
end

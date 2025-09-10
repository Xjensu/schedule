class StudentScheduleController < ApplicationController
  def index
    group_id = params[:group_id]
    course = params[:course]
    @schedules = Rails.cache.read("schedules_for_group:#{group_id}_course:#{course}")
    @times = ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10', '18:45']
    @days = ['Понедельник', 'Вторник', 'Среда', 'Четверг','Пятница','Суббота']
    puts @schedules
  end
end

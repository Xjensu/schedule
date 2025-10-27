class TeacherSchedulesController < ApplicationController
  def index
    @times = ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10']
    @days = ['Понедельник', 'Вторник', 'Среда', 'Четверг','Пятница','Суббота']
    @schedules = Rails.cache.read("teacher:#{params[:id]}:schedule")
  end
end

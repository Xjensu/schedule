class HomeController < ApplicationController
  def index
    @faculties = Rails.cache.read('all_faculties')
  end

  def keys
    update_keys
  end

  private

  def update_keys
    DateProcessingJob.perform_async
    StaticDatasJob.perform_async
    Faculty.find_each do |faculty|
      FacultyJob.perform_now(faculty.id)
    end
    TeacherScheduleJob.perform_async
  end
end

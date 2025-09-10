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
    FacultyJob.perform_now(1)
    TeacherScheduleJob.perform_async
  end
end

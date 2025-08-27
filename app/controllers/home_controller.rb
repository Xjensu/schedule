class HomeController < ApplicationController
  def index
    @lessons = Rails.cache.fetch('admin/faculties/lessons', expires_in: 2.minutes) do 
      Lesson.all.to_a
    end
    DateProcessingJob.perform_async
    StaticDatasJob.perform_async
    FacultyJob.perform_now(1)
    TeacherScheduleJob.perform_async
  end
end

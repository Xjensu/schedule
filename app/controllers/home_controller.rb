class HomeController < ApplicationController
  def index
    @lessons = Rails.cache.fetch('admin/faculties/lessons', expires_in: 2.minutes) do 
      Lesson.all.to_a
    end
    puts @lessons
  end
end

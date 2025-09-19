class FacultiesController < ApplicationController
  def index
  end

  def show
    @faculty_id = params[:id]

    @groups = Rails.cache.read("faculty:#{@faculty_id}_groups")
    if @groups.present?
      if params[:group_id].present?
        @selected_group_id = params[:group_id].to_i 
        @selected_course = params[:course].to_i
      else
        @selected_group_id = @groups.first.id
        @selected_course =  1
      end
    end

    @exist_lecture = Rails.cache.exist?("lecture_schedule:group:#{@selected_group_id}:course:#{@selected_course}")
    @exist_exams = Rails.cache.exist?("exam_schedule:group:#{@selected_group_id}:course:#{@selected_course}")
    @exist_test = Rails.cache.exist?("test_schedule:group:#{@selected_group_id}:course:#{@selected_course}")
  end
end

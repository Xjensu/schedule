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
  end
end

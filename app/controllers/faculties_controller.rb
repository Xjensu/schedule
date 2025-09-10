class FacultiesController < ApplicationController
  def index
  end

  def show
    id = params[:id]

    @groups = Rails.cache.read("faculty:#{id}_groups")
  end
end

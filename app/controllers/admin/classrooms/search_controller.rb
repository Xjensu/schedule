class Admin::Classrooms::SearchController < ApplicationController
  def index
    @classrooms = ClassroomsFetcher.new(
      search_query: params[:query],
      limit: 10
    ).call
    respond_to do |format|
      format.turbo_stream
    end
  end
end
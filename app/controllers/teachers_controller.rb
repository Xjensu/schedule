class TeachersController < ApplicationController
  def index
    @teachers = TeachersFetcher.new(
      search_query: params[:search],
      limit: 10
    ).call.order(name: :asc)
  end

end



# class Admin::Teachers::SearchController < ApplicationController
#   def index
#     @teachers = TeachersFetcher.new(
#       search_query: params[:query],
#       limit: 10
#     ).call
#     respond_to do |format|
#       format.turbo_stream { render params[:partial].present? ? params[:partial].to_s : :index  }
#     end
#   end
# end

class Admin::ClassroomsController < Admin::BaseAdminController
  def index
    @classrooms = ClassroomsFetcher.new(
      search_query: params[:query],
      limit: params[:limit]
    ).call

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @classroom = Classroom.new
  end

  def create
    @classroom = Classroom.new(classroom_params)

    respond_to do |format|
      if @classroom.save
        format.html { redirect_to admin_classrooms_path || admin_default_schedules_path }
        format.turbo_stream { redirect_to admin_classrooms_path || admin_default_schedules_path }
      else
        format.turbo_stream { render :create_error }
      end
    end
  end

  def destroy
    @classroom = Classroom.find(params[:id])
    
    respond_to do |format|
      if @classroom.destroy
        format.html { redirect_to admin_classrooms_path || admin_default_schedules_path }
        format.turbo_stream { redirect_to admin_classrooms_path || admin_default_schedules_path }
      else
        format.turbo_stream { render :destroy_error }
      end
    end
  end

  private

  def classroom_params
    params.require(:classroom).permit(:name)
  end
end

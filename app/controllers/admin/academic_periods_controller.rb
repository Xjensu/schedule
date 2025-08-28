class Admin::AcademicPeriodsController < Admin::BaseAdminController
  before_action :set_group, only: [:new], if: -> { params[:group_id].present? }
  before_action :set_query_params, only: [:create, :update, :destroy]
  before_action :set_faculty_id, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_academic_period, only: [:edit, :update, :destroy]

  def new
    @academic_period = AcademicPeriod.new
    @academic_period.faculty_id = params[:faculty_id] if params[:faculty_id].present?
  end

  def create
    @academic_period = AcademicPeriod.new(academic_period_params.merge(faculty_id: @faculty_id))
    
    respond_to do |format|
      if @academic_period.save
        @academic_periods = AcademicPeriod.where(faculty_id: @faculty_id)
        format.turbo_stream
      else
        format.turbo_stream { render :create_error }
      end
    end
  end

  def edit
    # @academic_period уже установлен через before_action
  end

  def destroy
    @academic_period = AcademicPeriod.find(params[:id])
    faculty_id = @academic_period.faculty_id
    
    respond_to do |format|
      if @academic_period.destroy
        @academic_periods = AcademicPeriod.where(faculty_id: faculty_id)
        format.turbo_stream
      else
        format.turbo_stream { render :destroy_error }
      end
    end
  end

  def update
    respond_to do |format|
      if @academic_period.update(academic_period_params)
        @academic_periods = AcademicPeriod.where(faculty_id: @faculty_id)
        format.turbo_stream { render :create }
      else
        format.turbo_stream { render :create_error }
      end
    end
  end

  def destroy
    @faculty_id = @academic_period.faculty_id
    
    respond_to do |format|
      if @academic_period.destroy
        @academic_periods = AcademicPeriod.where(faculty_id: @faculty_id)
        format.turbo_stream
      else
        format.turbo_stream { render :destroy_error }
      end
    end
  end

  private 

  def set_academic_period
    @academic_period = AcademicPeriod.find(params[:id])
  end

  def set_group
    @group = StudentGroup.find(params[:group_id])
    @group_id = @group.id
    @faculty_id = @group.faculty_id
  rescue ActiveRecord::RecordNotFound
    redirect_to default_schedules_path, alert: "Группа не найдена"
  end

  def academic_period_params
    params.require(:academic_period).permit(:name, :start_date, :end_date, :faculty_id)
  end

   def set_query_params
    @query_params = {
      group_id: params[:group_id],
      course: params[:course],
      use_default_schedule: params[:use_default_schedule],
      custom_date: params[:custom_date],
      day: params[:day]
    }.compact
  end

  def set_faculty_id
    @faculty_id = params[:faculty_id] || @academic_period&.faculty_id
  end
end

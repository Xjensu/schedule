class Admin::TestSchedulesController < ApplicationController
  before_action :find_or_new_special_period, only: [:index]
  before_action :set_academic_period, only: [:index]
  def index
    puts params
  end

  def show
    @special_period = SpecialPeriod.find(params[:id])
    @schedules = SpecialSchedule.where(special_period_id: @special_period.id)

    @schedule_renderer = ScheduleRenderer.new(
          self,
          default_times: ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10', '18:45'],
          schedules: @schedules,
          param: { group_id:  @special_period.student_group_id, academic_period_id: @special_period.academic_period_id, special_period_id: @special_period.id, course: @special_period.course },
          card_stimulus: { controller: 'test-schedule-cards', action: 'click->test-schedule-cards#clicked' }, #action: 'dragstart->transfer-schedule-card#handleDragStart' },
          # card_attributes: { draggable: 'true', transfer_schedule_card_target: params[:target] },
          partial: 'shared/schedule/transfer_schedule_container'
        )
  end

  def editor
    load_data_from_params
    @lesson = Lesson.find_by(lesson_type: :test)
    @teachers = TeachersFetcher.new(
      search_query: params[:teacher_search],
      limit: params[:teacher_search].present? ? 10 : nil,
      priority_teacher_id: @selected_teacher_id,
    ).call.order(name: :asc)
    
    @schedule = if @schedule_id.present?
                  SpecialSchedule.find(@schedule_id)
                else
                  SpecialSchedule.new(
                    student_group_id: @group_id,
                    special_period_id: @special_period_id,
                    start_time: @time,
                    course: @course,
                    lesson_id: @lesson.id
                  )
                end

    @classrooms = Classroom.all
    
    respond_to do |format|
      format.turbo_stream
    end
  end

  def new
  end

  def create
    @special_schedule = SpecialSchedule.new(create_params.merge( subject_id: find_or_create_subject(create_params[:subject_id]) ))
    if @special_schedule.save
      redirect_back fallback_location: root_path, notice: "Сообщение об успехе", allow_other_host: false
    else
      redirect_back fallback_location: root_path, notice: "ошибка при создании, #{@special_schedule.errors.full_messages}", allow_other_host: false
    end
  end

  def edit
  end

  def update
    puts params
    @special_schedule = SpecialSchedule.find(params[:id])
    if @special_schedule.update( update_params.merge( subject_id: find_or_create_subject(create_params[:subject_id]) ))
      redirect_back fallback_location: root_path, notice: "Сообщение об успехе", allow_other_host: false
    else
      redirect_back fallback_location: root_path, notice: "ошибка при обновлении, #{@special_schedule.errors.full_messages}", allow_other_host: false
    end
  end

  def destroy
    @special_schedule = SpecialSchedule.find(params[:id])
    if @special_schedule.destroy
      redirect_back fallback_location: root_path, notice: "Сообщение об успехе", allow_other_host: false
    else
      redirect_back fallback_location: root_path, notice: "ошибка при удалении, #{@special_schedule.errors.full_messages}", allow_other_host: false
    end
  end

  private 

  def create_params
    params.require(:special_schedule).permit(:teacher_id, :special_period_id, :student_group_id, :start_time, :classroom_id, :lesson_id, :course, :subject_id)
  end

  def update_params
    params.require(:special_schedule).permit(:teacher_id, :special_period_id, :student_group_id, :start_time, :classroom_id, :lesson_id, :course, :subject_id)
  end

  def find_or_new_special_period
    @special_period = SpecialPeriod.where(academic_period_id: params[:academic_period_id], student_group_id: params[:group_id], course: params[:course], name: :test)
  end

  def set_academic_period
    @academic_period = AcademicPeriod.find(params[:academic_period_id])
  end

  def load_data_from_params
    @group_id = params[:group_id]
    @special_period_id = params[:special_period_id]
    @time = params[:time]
    @schedule_id = params[:schedule_id]
    @course = params[:course]
  end

  def find_or_create_subject(name)
    return nil if name.blank?
    subject = Subject.where(name: name)
    if subject.present?
      subject = subject.ids.first
    else 
      subject = Subject.new(name: name.to_s)
      subject.save!
      subject = subject.id
    end
    subject
  end

end

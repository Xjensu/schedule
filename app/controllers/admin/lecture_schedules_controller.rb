class Admin::LectureSchedulesController < ApplicationController
  before_action :set_special_periods, only: [:index]
  before_action :set_resources, only: [:index]
  before_action :get_schedules, only: [:index]


  before_action :set_params, only: [:editor]
  before_action :get_objects, only: [:editor]

  before_action :process_subject, only: [:create, :update]

  def index
    respond_to do |format|
      format.html
      format.turbo_stream do
        
        render turbo_stream: [
          turbo_stream.update('schedule-list', partial: 'daily_schedule', locals: { schedules: @daily_schedules, selected_day: @selected_day, student_group_id: @group, course: @course }),
          turbo_stream.update_all(".period-btn", partial: 'special_period_info', collection: @periods, as: :period)
        ]
      end
    end
  end

  def new
  end

  def create
    @schedule = SpecialSchedule.create(craete_params.merge(subject_id: @subject.id))
  end

  def edit
  end

  def update
    @schedule = SpecialSchedule.find(params[:id])
    @schedule.update( craete_params.merge(subject_id: @subject.id) )
  end

  def destroy
  end

  def editor
    respond_to do |format|
      format.turbo_stream
    end
  end


  private

  def set_resources
    @group = params[:group_id]
    @course = params[:course]
    @special_period_id = params[:special_period_id].present? ? params[:special_period_id].to_i : SpecialPeriod.find_by(academic_period_id: @academic_period_id).id
    puts @special_period_id
  end


  def set_special_periods
    @academic_period_id = params[:academic_period_id]
    @academic_period = AcademicPeriod.find(@academic_period_id)
    @periods = 7.times.map do |i|
       SpecialPeriodManager.find_or_create_lecture_period( @academic_period_id, @group, @course, @academic_period.start_date + i.days )
    end.compact
  end
  
  def get_schedules
    @daily_schedules = SpecialSchedule.includes(:subject).where(special_period_id: @special_period_id)
  end

  def set_params
    @start_time = params[:start_time]
    @special_period_id = params[:special_period_id]
    @teacher = params[:teacher_id]
    @classroom = params[:classroom_id]
    @subject = params[:subject_id]
    @group_id = params[:student_group_id]
    @course = params[:course]
    @lesson = Lesson.find_by(lesson_type: :lecture).id
  end

  def get_objects
    schedule_id = params[:schedule_id]
    @schedule = schedule_id.present? ? SpecialSchedule.includes(:subject).find(schedule_id) : 
      SpecialSchedule.joins(:subject).new( special_period_id: @special_period_id, teacher_id: @teacher_id, classroom_id: @classroom_id, subject_id: @subject_id, start_time: @start_time, student_group_id: @group_id, course: @course, lesson_id: @lesson )
    
    @classrooms = Classroom.all
    @teachers = TeachersFetcher.new(
      search_query: params[:teacher_search],
      limit: params[:teacher_search].present? ? 10 : nil,
      priority_teacher_id: @selected_teacher_id,
    ).call.order(name: :asc)
  end

  def process_subject
    @subject = Subject.find_or_create_by(name: params[:special_schedule][:subject_name])
  end

  def craete_params
    params.require(:special_schedule).permit(:special_period_id, :teacher_id, :classroom_id, :course, :student_group_id, :lesson_id, :start_time)
  end

  def update_params
    params.require(:special_schedule).permit(:teacher_id, :classroom_id)
  end
end

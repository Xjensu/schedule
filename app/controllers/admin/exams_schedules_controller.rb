class Admin::ExamsSchedulesController < ApplicationController
  def index
    @academic_period = AcademicPeriod.find(params[:academic_period_id])

    @special_period = SpecialPeriod.new(academic_period_id: params[:academic_period_id], student_group_id: params[:group_id], course: params[:course], name: :exam)
    @special_periods = SpecialPeriod.where(academic_period_id: params[:academic_period_id], student_group_id: params[:group_id], course: params[:course], name: :exam)
    
    @special_schedule = SpecialSchedule.new()
    @special_schedules = SpecialSchedule.where(special_period_id: @special_periods.ids)
    @times = ['8:30', '10:10', '11:45', '14:00', '15:35', '17:10']
  end

  def create
    @special_schedule = SpecialSchedule.new(create_params.merge( subject_id: find_or_create_subject(create_params[:subject_id]) ))
    if @special_schedule.save
      redirect_back fallback_location: root_path, notice: "Сообщение об успехе", allow_other_host: false
    else
      redirect_back fallback_location: root_path, notice: "ошибка при создании, #{@special_period.errors.full_messages}", allow_other_host: false
    end
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

  def editor
    puts "dadada", params
    @special_period = SpecialPeriod.find(editor_params[:special_period_id])
    @group_id = StudentGroup.find(editor_params[:student_group_id]).id
    @course = editor_params[:course]
    @time = editor_params[:start_time]
    @schedule = editor_params[:id].present? ? SpecialSchedule.find(editor_params[:id]) : SpecialSchedule.new()
    @lesson_id = Lesson.find_by(lesson_type: :exam).id

    @teachers = Teacher.all
    @classrooms = Classroom.all

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def editor_params
    params.require(:special_schedule).permit(:special_period_id, :student_group_id, :course, :start_time, :id)
  end

  def create_params
    params.require(:special_schedule).permit(:teacher_id, :special_period_id, :student_group_id, :start_time, :classroom_id, :lesson_id, :course, :subject_id)
  end

  def update_params
    params.require(:special_schedule).permit(:teacher_id, :special_period_id, :student_group_id, :start_time, :classroom_id, :lesson_id, :course, :subject_id)
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

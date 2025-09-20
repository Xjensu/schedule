class Admin::AddedSchedulesController < Admin::BaseAdminController
  before_action :get_added, only: [:destroy]
  def create
    service = AddedScheduleService.new(create_params)
    @added = service.create

    if @added
      puts "da"
    else
      puts "net"
    end
  end

  def destroy
    @target = params[:target]
    service = AddedScheduleService.new( id: @added.id )
    respond_to do |format|
      if service.destroy
        param = {
          student_group_id: @added.student_group_id,
          course: @added.course,
          academic_period_id: @added.schedule.academic_period_id
        }

        schedules = ScheduleGeter.new(param)
        schedules.set_schedule_for_date(@added.date.to_s)
        @schedules = schedules.get_schedule
        @default_times = ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10', '18:45']

        @schedule_renderer = ScheduleRenderer.new(
          self,
          default_times: @default_times,
          schedules: @schedules,
          param: { group_id: @added.student_group_id, academic_period_id: @added.schedule.academic_period_id, course: @added.course, date: @added.date },
          card_stimulus: { controller: 'transfer-schedule-card', action: 'dragstart->transfer-schedule-card#handleDragStart' },
          card_attributes: { draggable: 'true', transfer_schedule_card_target: @target },
          partial: 'shared/schedule/transfer_schedule_container'
        )

        format.turbo_stream
      else
        puts "net"
      end
    end
  end

  def edit
    puts "PARAMS", edit_params[:teacher_id].present?
    @change = AddedSchedule.includes(:schedule,:teacher,:classroom).find(params[:id])
    @teacher_id = edit_params[:teacher_id].present? ? edit_params[:teacher_id] : @change.schedule.teacher_id
    @classroom_id = edit_params[:classroom_id].present? ? edit_params[:classroom_id] : @change.schedule.classroom_id

    @classrooms = Classroom.all
    @teachers = TeachersFetcher.new(
      search_query: params[:teacher_search],
      limit: params[:teacher_search].present? ? 10 : nil,
      priority_teacher_id: @selected_teacher_id,
    ).call.order(name: :asc)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
    puts "PARAMS", params

    @change = AddedSchedule.find(params[:id])

    respond_to do |format|
      if @change.update(edit_params)
        format.turbo_stream
      end
    end
  end

  private 

  def create_params
    params.require(:deleted_schedule).permit(:schedule_id, :date, :student_group_id, :course)
  end

  def get_added
    @added = AddedSchedule.find(params[:id])
  end

  def edit_params
    params.require(:added_schedule).permit(:teacher_id, :classroom_id)
  end
end

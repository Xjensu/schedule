class Admin::DeletedSchedulesController < Admin::BaseAdminController
  before_action :get_deleted, only: [:destroy]
  def create
    service = DeletedScheduleService.new(create_params)
    @deleted = service.create

    if @deleted
      puts "da"
    else
      puts "net"
    end
  end

  def destroy
    @target = params[:target]
    service = DeletedScheduleService.new( id: @deleted.id )
    puts "DADADADAWWDDDADA", @deleted.attributes
    respond_to do |format|
      if service.destroy
        param = {
          student_group_id: @deleted.student_group_id,
          course: @deleted.course,
          academic_period_id: @deleted.schedule.academic_period_id
        }

        schedules = ScheduleGeter.new(param)
        schedules.set_schedule_for_date(@deleted.date)
        @schedules = schedules.get_schedule
        @schedules.each do |scheule|
          puts ":::::::::::::::::::::", scheule.attributes
        end
        @default_times = ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10', '18:45']

        @schedule_renderer = ScheduleRenderer.new(
          self,
          default_times: @default_times,
          schedules: @schedules,
          param: { group_id: @deleted.student_group_id, academic_period_id: @deleted.schedule.academic_period_id, course: @deleted.course, date: @deleted.date },
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

  private 

  def create_params
    params.require(:deleted_schedule).permit(:schedule_id, :date, :student_group_id, :course)
  end

  def get_deleted
    @deleted = DeletedSchedule.find(params[:id])
  end
end

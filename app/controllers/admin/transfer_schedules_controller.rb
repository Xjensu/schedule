class Admin::TransferSchedulesController < Admin::BaseAdminController
  before_action :load_academic_period, only: [:index]

  def index
    @source_date = constrain_date_to_academic_period(params[:source_date] || Date.current)
    @target_date = constrain_date_to_academic_period( params[:target_date] || Date.current ) 
  end

  def schedule_for_date

    @schedules_data = ScheduleTransferService.new(
      student_group_id: params[:group_id],
      course: params[:course],
      academic_period_id: params[:academic_period_id]
    ).for_date(params[:date])

    @changes = @schedules_data.changes
    @schedules = @schedules_data.schedule
    @target = params[:target]
    @default_times = default_schedule_times

    @schedule_renderer = build_schedule_renderer(
      schedules: @schedules,
      date: params[:date],
      target: @target
    )

    respond_to do |format|
      format.turbo_stream
    end
  end

  def update_sidebar
    permitted_params = params.require(:dataset).permit(:source_schedule_id, :target_schedule_id, :group_id, :source_date, :target_date, :course, :operation, :source, :target, :source_time, :target_time)
    @dataset = permitted_params.to_h.symbolize_keys
    @target = @dataset[:target].to_s
    @source = @dataset[:source].to_s

    @datas_source = {}
    @datas_target = {}

    process_dataset_changes

    render_schedule_renderers

    respond_to do |format|
      if valid_schedule_ids?
        format.turbo_stream
      else
        format.turbo_stream { render :schedule_id_error }
      end
    end
  end

  private

  def process_dataset_changes
    operation_handler = ScheduleOperationHandler.new(@dataset)
    
    operation_handler.on_replace do
      puts "Replace"
      source1_data = extract_schedule_data(:source)
      source2_data = extract_schedule_data(:target)

      delete_schedule(source1_data[:schedule_id], source1_data[:group_id], source1_data[:course], source1_data[:date])
      @datas_source[:delete] = @deleted

      delete_schedule(source2_data[:schedule_id], source2_data[:group_id], source2_data[:course], source2_data[:date])
      @datas_target[:delete] = @deleted

      add_schedule(source1_data[:schedule_id], source2_data[:date], source2_data[:time], source2_data[:group_id], source2_data[:course])
      @datas_target[:add] = @added

      add_schedule(source2_data[:schedule_id], source1_data[:date], source1_data[:time], source1_data[:group_id], source1_data[:course])
      @datas_source[:add] = @added
    end

    operation_handler.on_transfer do
      puts "Transfer"
      source_data = extract_schedule_data(:source)
      
      delete_schedule(source_data[:schedule_id], source_data[:group_id], source_data[:course], source_data[:date])
      @datas_source[:delete] = @deleted
      
      add_schedule(source_data[:schedule_id], @dataset[:target_date], @dataset[:target_time], source_data[:group_id], source_data[:course])
      @datas_target[:add] = @added
    end

    operation_handler.on_delete do
      puts "Delete"
      source_data = extract_schedule_data(:source)
      
      delete_schedule(source_data[:schedule_id], source_data[:group_id], source_data[:course], source_data[:date])
      @datas_source[:delete] = @deleted
    end

    operation_handler.process
  end

  def extract_schedule_data(type)
    case type
    when :source
      {
        schedule_id: @dataset[:source_schedule_id],
        group_id: @dataset[:group_id],
        course: @dataset[:course],
        date: @dataset[:source_date],
        time: @dataset[:source_time]
      }
    when :target
      {
        schedule_id: @dataset[:target_schedule_id].present? ? @dataset[:target_schedule_id] : @dataset[:source_schedule_id],
        group_id: @dataset[:target_group_id] || @dataset[:group_id],
        course: @dataset[:course],
        date: @dataset[:target_date],
        time: @dataset[:target_time]
      }
    end
  end

  def render_schedule_renderers
    @default_times = default_schedule_times

    if @target.present?
      @schedules_target_data = ScheduleTransferService.new(
        student_group_id: @dataset[:group_id],
        course: @dataset[:course],
        academic_period_id: @dataset[:academic_period_id]
      ).for_date(@dataset[:target_date])

      @changes_target = @schedules_target_data.changes
      @schedules_target = @schedules_target_data.schedule

      @schedule_renderer_target = build_schedule_renderer(
        schedules: @schedules_target,
        date: @dataset[:target_date],
        target: @dataset[:target]
      )
    end

    @schedules_source_data = ScheduleTransferService.new(
      student_group_id: @dataset[:group_id],
      course: @dataset[:course],
      academic_period_id: @dataset[:academic_period_id]
    ).for_date(@dataset[:source_date])

    @changes_source = @schedules_source_data.changes
    @schedules_source = @schedules_source_data.schedule

    @schedule_renderer_source = build_schedule_renderer(
      schedules: @schedules_source,
      date: @dataset[:source_date],
      target: @dataset[:target]
    )
  end

  def build_schedule_renderer(schedules:, date:, target:)
    ScheduleRenderer.new(
      self,
      default_times: default_schedule_times,
      schedules: schedules,
      param: { group_id: params[:group_id] || @dataset[:group_id], academic_period_id: params[:academic_period_id] || @dataset[:academic_period_id], course: params[:course] || @dataset[:course], date: date },
      card_stimulus: {
        controller: 'transfer-schedule-card',
        action: 'dragstart->transfer-schedule-card#handleDragStart'
      },
      card_attributes: {
        draggable: 'true',
        transfer_schedule_card_target: target
      },
      partial: 'shared/schedule/transfer_schedule_container'
    )
  end

  def delete_schedule(schedule_id, group_id, course, date)
    service = DeletedScheduleService.new(
      schedule_id: schedule_id,
      date: date,
      student_group_id: group_id,
      course: course
    )
    @deleted = service.create
  end

  def add_schedule(schedule_id, date, time, group_id, course)
    schedule = Schedule.find(schedule_id)
    @added = AddedSchedule.new( schedule_id: schedule_id, date: date, time: time, student_group_id: group_id, course: course, classroom_id: schedule.classroom_id, teacher_id: schedule.teacher_id )
    if @added.save
      puts "ADDED"
    else
      puts "ERROR"
    end
  end

  def load_academic_period
    @academic_period = AcademicPeriod.find(params[:academic_period_id])
  end

  def constrain_date_to_academic_period(target_date)
    date = Date.parse(target_date.to_s)
    return @academic_period.start_date if date < @academic_period.start_date
    return @academic_period.end_date if date > @academic_period.end_date
    date
  rescue ArgumentError
    Date.current
  end

  def valid_schedule_ids?
    @dataset[:source_schedule_id].present? || @dataset[:target_schedule_id].present?
  end

  def default_schedule_times
    ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10', '18:45']
  end

end

class ScheduleOperationHandler
  def initialize(dataset)
    @dataset = dataset
    @handlers = {}
  end

  def on_replace(&block)
    @handlers[:replace] = block if @dataset[:operation] == 'replace'
  end

  def on_transfer(&block)
    @handlers[:transfer] = block if @dataset[:operation] == 'transfer'
  end

  def on_delete(&block)
    @handlers[:delete] = block if @dataset[:operation] == 'delete'
  end

  def process
    handler = @handlers[@dataset[:operation].to_sym]
    handler.call if handler
  end
end

class ScheduleTransferService
  def initialize(student_group_id:, course:, academic_period_id:)
    @student_group_id = student_group_id
    @course = course
    @academic_period_id = academic_period_id
    @schedule_getter = ScheduleGeter.new(
      student_group_id: @student_group_id,
      course: @course,
      academic_period_id: @academic_period_id
    )
  end

  def for_date(date)
    @schedule_getter.set_schedule_for_date(date)
    self
  end

  def changes
    @schedule_getter.changes
  end

  def schedule
    @schedule_getter.get_schedule
  end
end
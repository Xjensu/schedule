class Admin::TransferSchedulesController < Admin::BaseAdminController
  before_action :load_academic_period, only: [:index]
  # TODO пофиксить баг с отображением расписания
  def index
    @source_date = get_current_date_else( params[:source_date] || Date.current )
    @target_date = get_current_date_else( params[:target_date] || Date.current ) 
  end

  def schedule_for_date
    param = { student_group_id: params[:group_id], course: params[:course], academic_period_id: params[:academic_period_id] }

    @schedules = ScheduleGeter.new(param)
    @schedules.set_schedule_for_date(params[:date])
    @changes = @schedules.changes
    @schedules = @schedules.get_schedule
    @target = params[:target]
    @default_times = ['8:30', '10:10', '11:45', '14:00', '15:35', '17:10', '18:45']
    
    @schedule_renderer = ScheduleRenderer.new(
          self,
          default_times: @default_times,
          schedules: @schedules,
          param: { group_id:  params[:group_id], academic_period_id: params[:academic_period_id], course: params[:course], date: params[:date] },
          card_stimulus: { controller: 'transfer-schedule-card', action: 'dragstart->transfer-schedule-card#handleDragStart' },
          card_attributes: { draggable: 'true', transfer_schedule_card_target: params[:target] },
          partial: 'shared/schedule/transfer_schedule_container'
        )

    respond_to do |format|
      format.turbo_stream 
    end
  end

  def update_sidebar
    @dataset = params[:dataset]
    @target = "transfers_#{@dataset[:target]}"
    @source = "transfers_#{@dataset[:source]}"

    @datas_source = {}
    @datas_target = {}

    process_changes_for_sidebar @dataset

    puts @source
    puts "SOURCE", @datas_source
    puts @target
    puts "TARGET", @datas_target

    respond_to do |format|
      if @dataset[:source_schedule_id].present? || @dataset[:target_schedule_id].present? || ( @dataset[:target_schedule_id].present? && @dataset[:source_schedule_id].present?)
        format.turbo_stream
      else
        format.turbo_stream { render :schedule_id_error }
      end
    end
  end

  private

  def process_changes_for_sidebar(dataset)
    puts dataset

    case dataset[:operation]
      when 'replace' 
        # Сохраняем исходные данные первого предмета
        source1 = {
          schedule_id: dataset[:source_schedule_id],
          group_id: dataset[:group_id],
          course: dataset[:course],
          date: dataset[:source_date],
          time: dataset[:source_time]
        }
        
        # Сохраняем исходные данные второго предмета
        source2 = {
          schedule_id: dataset[:target_schedule_id],
          group_id: dataset[:target_group_id] || dataset[:group_id], # если не указана, используем ту же группу
          course: dataset[:target_course] || dataset[:course], # если не указан, используем тот же курс
          date: dataset[:target_date],
          time: dataset[:target_time]
        }

        # Удаляем оба предмета из их исходных позиций
        delete_schedule(source1[:schedule_id], source1[:group_id], source1[:course], source1[:date])
        @datas_source[:delete] = @deleted
        
        delete_schedule(source2[:schedule_id], source2[:group_id], source2[:course], source2[:date])
        @datas_target[:delete] = @deleted

        # Добавляем предметы на новые места (меняем местами)
        add_schedule(source1[:schedule_id], source2[:date], source2[:time], source2[:group_id], source2[:course])
        @datas_target[:add] = @added
        
        add_schedule(source2[:schedule_id], source1[:date], source1[:time], source1[:group_id], source1[:course])
        @datas_source[:add] = @added
      when 'transfer'
        # сначала удаляем запись из source
        delete_schedule( dataset[:source_schedule_id], dataset[:group_id], dataset[:course] , dataset[:source_date]  )
        @datas_source[:delete] = @deleted
        # потом добавляем запись в target
        add_schedule( dataset[:source_schedule_id], dataset[:target_date], dataset[:target_time], dataset[:group_id], dataset[:course] )
        @datas_target[:add] = @added
      when 'delete'
        delete_schedule( dataset[:source_schedule_id], dataset[:group_id], dataset[:course] , dataset[:source_date] )
        @datas_source[:delete] = @deleted
      else
        puts "UNKNOWN"
      end
  end

  def processing_transfers

  end

  def delete_schedule( schedule_id, group_id, course, date )
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
      puts "ERROR", @added.errors.full_messages
    end
  end

  def load_academic_period
    @academic_period = AcademicPeriod.find(params[:academic_period_id])
  end

  

  def get_current_date_else(target_date)
    date = target_date
    if target_date.present?
      date = target_date > @academic_period.end_date ? @academic_period.end_date : target_date < @academic_period.start_date  ? @academic_period.start_date : date
    end
  end
end

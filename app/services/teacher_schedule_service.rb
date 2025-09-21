class TeacherScheduleService
  attr_reader :changes

  def initialize(teacher_id, date)
    @teacher_id = teacher_id
    @date = date.is_a?(String) ? Date.parse(date) : date
    @day_of_week = @date.wday
    @under = even_odd_week(@date.cweek)
    @changes = []
    @final_schedule = []
  end

  def execute
    fetch_data
    apply_changes
    sort_schedule
    self
  end

  def schedule
    @final_schedule
  end

  private

  def fetch_data
    @base_schedules = fetch_base_schedules
    @schedule_changes = fetch_schedule_changes
  end

  def fetch_base_schedules
    Schedule
      .where(teacher_id: @teacher_id, day_of_week: @day_of_week, under: @under)
      .includes(:subject, :academic_period, :student_group, :classroom, :lesson)
      .order(:start_time)
      .to_a
  end

  def fetch_schedule_changes
    changes = []
    
    deleted_records = DeletedSchedule
      .where(date: @date)
      .joins(:schedule)
      .where(schedules: { teacher_id: @teacher_id })
    
    deleted_records.each do |deleted|
      changes << ScheduleChange.new(:delete, deleted, deleted.created_at)
    end

    added_records = AddedSchedule
      .where(date: @date, teacher_id: @teacher_id)
      .includes(:schedule)
      .to_a

    added_records.each do |added|
      changes << ScheduleChange.new(:add, added, added.created_at)
    end

    changes.sort_by(&:created_at)
  end

  def apply_changes
    schedules = @base_schedules.dup

    @schedule_changes.each do |change|
      case change.action
      when :delete
        schedules.reject! { |s| s.id == change.target_id }
      when :add
        added = change.record
        original_schedule = added.schedule
        
        modified_schedule = Schedule.new(
          academic_period_id: original_schedule.academic_period_id,
          student_group_id: original_schedule.student_group_id,
          subject_id: original_schedule.subject_id,
          teacher_id: added.teacher_id || original_schedule.teacher_id,
          classroom_id: added.classroom_id || original_schedule.classroom_id,
          lesson_id: original_schedule.lesson_id,
          day_of_week: @day_of_week,
          under: @under,
          start_time: added.time || original_schedule.start_time,
          course: original_schedule.course
        )
        
        modified_schedule.define_singleton_method(:original_id) { original_schedule.id }
        
        schedules << modified_schedule
      end
    end

    @final_schedule = schedules
    @changes = @schedule_changes
  end

  def sort_schedule
    @final_schedule.sort_by!(&:start_time)
  end

  def even_odd_week(week_number)
    week_number.even?
  end
end
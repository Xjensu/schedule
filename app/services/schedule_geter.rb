
class ScheduleGeter
  def initialize(params)
    @params = params
  end

  def set_schedule_for_date(day_string)
    date = Date.parse(day_string)
    day_of_week = date.wday.to_s
    under = even_odd_week(date.cweek)
    
    base_schedules = fetch_base_schedules(day_of_week, under)
    @schedule_changes = fetch_schedule_changes(date)

    @final_schedule = apply_changes(base_schedules, @schedule_changes).sort_by(&:start_time)
  end

  def fetch_base_schedules(day_of_week, under)
    Schedule.where(@params).where(day_of_week: day_of_week, under: under).order(:start_time).includes(:subject, :teacher, :classroom, :lesson)
  end

  def fetch_schedule_changes(date)
    changes = []
    
    DeletedSchedule.where(date: date, student_group_id: @params[:student_group_id], course: @params[:course]).each { |d| changes << { action: :delete, record: d, created_at: d.created_at } }
    
    # Получаем добавления
    AddedSchedule.where(date: date, student_group_id: @params[:student_group_id], course: @params[:course]).includes(:schedule).each { |a| changes << { action: :add, record: a, created_at: a.created_at } }
    # Сортируем по времени создания
    changes.sort_by { |c| c[:created_at] }
  end

  def apply_changes(base_schedules, changes)
    schedules = base_schedules.to_a
    
    changes.each do |change|
      case change[:action]
      when :delete
        schedules.reject! { |s| s.id == change[:record].schedule_id }
      when :add
        added = change[:record]
        schedule = added.schedule.dup
        
        schedule.assign_attributes(
          id: added.schedule_id,
          classroom_id: added.classroom_id || schedule.classroom_id,
          teacher_id: added.teacher_id || schedule.teacher_id,
          start_time: added.time || schedule.start_time,
        )
        
        schedules << schedule
      end
    end
    schedules
  end

  def changes 
    @schedule_changes
  end

  def get_schedule
    return @final_schedule
  end

  private

  def even_odd_week(week_number)
    week_number.even?
  end
end
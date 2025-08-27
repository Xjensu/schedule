class TeacherScheduleFacade
  def self.get_schedule(teacher_id, date, use_cache: true)
    if use_cache
      CachedTeacherScheduleService.new(teacher_id, date).execute
    else
      TeacherScheduleService.new(teacher_id, date).execute
    end
  end

  def self.get_formatted_schedule(teacher_id, date)
    result = get_schedule(teacher_id, date)
    decorator = TeacherScheduleDecorator.new(result[:schedule])
    {
      schedule: decorator.to_hash,
      changes: result[:changes],
      date: date,
      teacher: Teacher.find(teacher_id).full_name
    }
  end
end
class AddedScheduleService
  def initialize(id: nil, schedule_id: nil, date: nil, student_group_id: nil, course: nil, classroom_id: nil, teacher_id: nil, time: nil)
    @id = id
    @schedule_id = schedule_id
    @date = date
    @student_group_id = student_group_id
    @course = course
    @classroom_id = classroom_id
    @teacher_id = teacher_id
    @time = time
  end

  def create
    @added_schedule = AddedSchedule.new( schedule_id: @schedule_id, date: @date, student_group_id: @student_group_id, course: @course, classroom_id: @classroom_id, teacher_id: @teacher_id, time: @time )

    if @added_schedule.save
      @added_schedule
    else
      nil
    end
  end

  def destroy
    @added_schedule = AddedSchedule.find(@id)

    if @added_schedule&.destroy
      puts "Deleted schedule destroyed successfully"
      @added_schedule
    else
      puts "Failed to destroy deleted schedule"
      false
    end
  end
end
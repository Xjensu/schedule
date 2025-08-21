class DeletedScheduleService
  def initialize(id: nil, schedule_id: nil, date: nil, student_group_id: nil, course: nil)
    @id = id
    @schedule_id = schedule_id
    @date = date
    @student_group_id = student_group_id
    @course = course
  end

  def create
    @deleted_schedule = DeletedSchedule.new( schedule_id: @schedule_id, date: @date, student_group_id: @student_group_id, course: @course )

    if @deleted_schedule.save
      puts "Deleted schedule created successfully"
      @deleted_schedule
    else
      puts "Failed to create deleted schedule"
      nil
    end
  end

  def destroy
    @deleted_schedule = DeletedSchedule.find(@id)

    if @deleted_schedule&.destroy
      puts "Deleted schedule destroyed successfully"
      @deleted_schedule
    else
      puts "Failed to destroy deleted schedule"
      false
    end
  end
end
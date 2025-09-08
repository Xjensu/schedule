class FacultyJob < ApplicationJob
  queue_as :default
  COURSES = (1..5)

  def perform(faculty_id)
    faculty = Faculty.find(faculty_id)
    academic_period_matcher = AcademicPeriodMatcher.new(faculty_id)
    
    @dates = Rails.cache.read('current_dates')

    StudentGroup.where(faculty_id: faculty_id).find_each do |group|
      
      COURSES.each do |course|
        cache_key = "schedules_for_group:#{group.id}_course:#{course}"
        schedules = (0..1).map do |offset|
          { 
            week: offset, dates: @dates[offset][:dates].lazy.map do |date|
              period = academic_period_matcher.find_period_id(date)
              param = { student_group_id: group.id, course: course, academic_period_id: period }
              schedule= ScheduleGeter.new(param)
              schedule.set_schedule_for_date(date.to_s)
              schedules = schedule.get_schedule
              period.present? ? { date: date, schedule: schedule } : nil
            end.to_a.compact
          }
        end.to_a
        Rails.cache.write(cache_key, schedules, expires_in: 25.hours)

        exam_schedules = SpecialSchedule.where(special_period_id: SpecialPeriod.where(student_group_id: group.id, course: course, name: :exam).ids)
        test_schedules = SpecialSchedule.where(special_period_id: SpecialPeriod.where(student_group_id: group.id, course: course, name: :test).ids)
        lecture_schedules = SpecialSchedule.where(special_period_id: SpecialPeriod.where(student_group_id: group.id, course: course, name: :lecture).ids)

        [:exam, :test, :lecture].each do |type|
          schedule = instance_eval("#{type}_schedules")
          schedule = schedule.as_json( except: [:created_at, :updated_at], 
            include: {
              teacher: { only: [:name, :surname, :patronymic] },
              subject: { only: [:name] },
              classroom: { only: [:name] },
              lesson: { only: [:lesson_type] }
            }
          )
          if schedule.exists?
            Rails.cache.write("#{type}_schedule:group:#{group.id}:course:#{course}", schedule, expires_in: 25.hours)
          end
        end

      end
    end
  end
end


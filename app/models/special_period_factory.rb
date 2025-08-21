class SpecialPeriodFactory
  def self.find_or_create(type, attributes, date)
    case type
    when :lecture then find_or_create_lecture_period(attributes, date)
    when :exam then find_or_create_exam_period(attributes, date)
    # другие типы периодов
    end
  end

  private

  def self.find_or_create_lecture_period(attributes, date)
    @period = SpecialPeriod.find_by(academic_period_id: attributes[:academic_period_id], student_group_id: attributes[:group_id], course: attributes[:course], start_date: date)
    if @period.blank? 
      self.create_period_for( attributes[:academic_period_id], attributes[:group_id], attributes[:course], date )
    end
    @period
  end


  def self.create_period_for(academic_period_id, student_group_id, course, date)
    name = "lecture_week_for_#{academic_period_id}_on_#{date}"
    @period = SpecialPeriod.create(academic_period_id: academic_period_id, student_group_id: student_group_id, course: course, start_date: date, name: name)
  end
end
class AcademicPeriodMatcher
  def initialize(faculty_id = nil)
    @implementation = FacultyPeriodMatcher.new(faculty_id) 
  end

  def find_period_id(date)
    @implementation.find_period_id(date)
  end

  # Метод для массовой проверки дат
  def find_period_ids(dates)
    @implementation.find_period_ids(dates)
  end
end
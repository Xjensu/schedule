class FacultyPeriodMatcher
  def initialize(faculty_id)
    @faculty_id = faculty_id
  end

  def find_period_id(date)
    periods.find { |period| date.between?(period[:start_date], period[:end_date]) }&.dig(:id)
  end

  def find_period_ids(dates)
    period_map = {}
    periods = periods
    
    dates.each do |date|
      period_map[date] = periods.find { |p| date.between?(p[:start_date], p[:end_date]) }&.dig(:id)
    end
    
    period_map
  end

  private

  def periods
    AcademicPeriod
      .where(faculty_id: @faculty_id)
      .select(:id, :start_date, :end_date)
      .where('start_date IS NOT NULL AND end_date IS NOT NULL')
      .to_a
      .map { |p| { id: p.id, start_date: p.start_date, end_date: p.end_date } }
  end
end
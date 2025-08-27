class DateProcessor
  class << self 
    def generate_weeks_data(start_date = Date.current)
      current_monday = start_date.beginning_of_week

      [ current_monday, current_monday + 7 ].lazy.map do |monday|
        {
          dates: generate_dates(monday),
          under: !monday.cweek.even?
        }
      end.to_a
    end

    private

    def generate_dates(monday)
      (0..5).lazy.map { |offset| monday + offset }.to_a
    end
  end
end
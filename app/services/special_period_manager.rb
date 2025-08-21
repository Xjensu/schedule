class SpecialPeriodManager
  [ :lecture, :test, :exam ].each do |type|
    self.define_singleton_method "find_or_create_#{type}_period" do |academic_period_id, group_id, course, date| 
      SpecialPeriodFactory.find_or_create type, { academic_period_id: academic_period_id, group_id: group_id, course: course }, date
    end
  end
end
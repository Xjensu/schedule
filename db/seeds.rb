
[ :lecture, :pz, :lab, :test, :exam, :under ].each do |type|
  Lesson.create!(lesson_type: type)
end

User.create(email: 'testadmin@gmail.com', password: 'password', admin: true)

[
  { full_name: "Строительный факультет", short_name: "СТР", processing_time: "14:00"  },
  { full_name: "Факультет экономики и бизнес-технологий:", short_name: "ФЭБТ", processing_time: "14:10" },
  { full_name: "Военно-транспортный факультет", short_name: "ВТФ", processing_time: "14:20" },
  { full_name: "Электротехнический факультет", short_name: "ЭТФ", processing_time: "14:30" },
  { full_name: "Факультет промышленнного и гражданского строительства", short_name: "ПГС", processing_time: "14:40" },
  { full_name: "Механический факультет", short_name: "МЕХ", processing_time: "14:50" },
  { full_name: "Факультет управления процессами пеервозок", short_name: "УПП", processing_time: "15:00" }
].each do |faculty|
  Faculty.create( full_name: faculty[:full_name], short_name: faculty[:short_name], processing_time: faculty[:processing_time] )
end
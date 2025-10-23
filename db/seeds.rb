
[ :lecture, :pz, :lab, :test, :exam, :under ].each do |type|
  Lesson.create!(lesson_type: type)
end

User.create(email: 'testadmin@gmail.com', password: 'password', admin: true)

[
  { full_name: "Строительный факультет", short_name: "СТР", processing_time: "14:00", src: "https://www.bsut.by/university/faculties/sf" },
  { full_name: "Факультет экономики и бизнес-технологий:", short_name: "ФЭБТ", processing_time: "14:10", src: "https://www.bsut.by/university/faculties/gef" },
  { full_name: "Военно-транспортный факультет", short_name: "ВТФ", processing_time: "14:20", src: "https://www.bsut.by/university/faculties/vtf" },
  { full_name: "Электротехнический факультет", short_name: "ЭТФ", processing_time: "14:30", src: "https://www.bsut.by/university/faculties/etf" },
  { full_name: "Факультет промышленнного и гражданского строительства", short_name: "ПГС", processing_time: "14:40", src: "https://www.bsut.by/university/faculties/pgs" },
  { full_name: "Механический факультет", short_name: "МЕХ", processing_time: "14:50", src: "https://www.bsut.by/university/faculties/mf" },
  { full_name: "Факультет управления процессами пеервозок", short_name: "УПП", processing_time: "15:00", src: "https://www.bsut.by/university/faculties/upp" }
].each do |faculty|
  Faculty.create( full_name: faculty[:full_name], short_name: faculty[:short_name], processing_time: faculty[:processing_time] )
end
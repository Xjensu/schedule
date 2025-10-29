class Lesson < ApplicationRecord
  enum :lesson_type, {
    lecture: 0,
    pz: 1,
    lab: 2,
    test: 3,
    exam: 4,
    under: 5,
    kp: 6
  }

  def lesson_type_name
    {
      lecture: "Лекция",
      pz: "ПЗ",
      lab: "ЛАБ",
      test: "Зачёт",
      exam: "Экзамен",
      under: "Под чертой",
      kp: "КП"
    }[lesson_type.to_sym]
  end
end
class ChangeSchedulesNullableColumns < ActiveRecord::Migration[8.0]
   def change
    change_column_null :schedules, :teacher_id, true
    change_column_null :schedules, :classroom_id, true
    change_column_null :schedules, :lesson_id, true
  end
end

class AddUniqueConstraintsToSchedules < ActiveRecord::Migration[8.0]
  def change
    add_index :schedules, [:teacher_id, :day_of_week, :under, :start_time], unique: true, name: 'index_schedules_on_teacher_and_time'

    add_index :schedules, [:classroom_id, :day_of_week, :under, :start_time], unique: true, name: 'index_schedules_on_classroom_and_time'
  end
end

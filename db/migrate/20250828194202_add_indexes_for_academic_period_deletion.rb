class AddIndexesForAcademicPeriodDeletion < ActiveRecord::Migration[8.0]
  def change
    add_index :schedules, :academic_period_id
    add_index :special_periods, :academic_period_id
    add_index :special_schedules, :special_period_id
    add_index :added_schedules, :schedule_id
    add_index :deleted_schedules, :schedule_id
  end
end

class AddProcessingTimeToFaculty < ActiveRecord::Migration[8.0]
  def change
    add_column :faculties, :processing_time, :time
  end
end

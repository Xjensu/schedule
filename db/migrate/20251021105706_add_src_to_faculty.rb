class AddSrcToFaculty < ActiveRecord::Migration[8.0]
  def change
    add_column :faculties, :src, :string
  end
end

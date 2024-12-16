class AddFamilyIdToTasks < ActiveRecord::Migration[7.2]
  def change
    add_reference :tasks, :family, null: false, foreign_key: true
  end
end

class AddFamilyIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :family, null: true, foreign_key: true
  end
end

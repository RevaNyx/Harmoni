class CreateAppointments < ActiveRecord::Migration[7.2]
  def change
    create_table :appointments do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.integer :recurrence
      t.references :family, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

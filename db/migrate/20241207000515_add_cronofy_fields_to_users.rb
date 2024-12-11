class AddCronofyFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :access_token, :string
    add_column :users, :refresh_token, :string
    add_column :users, :account_id, :string
  end
end
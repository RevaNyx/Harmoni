class AddCronofyTokenExpirationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :token_expiration, :datetime
  end
end

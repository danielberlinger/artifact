class AddAccessToken < ActiveRecord::Migration
  def change
    add_column :entries, :access_token, :string
    add_column :entries, :access_token_expires_at, :datetime
    add_index :entries, :access_token
  end
end

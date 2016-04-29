class AddLastAskedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_asked, :integer
  end
end

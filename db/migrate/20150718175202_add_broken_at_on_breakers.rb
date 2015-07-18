class AddBrokenAtOnBreakers < ActiveRecord::Migration
  def change
    add_column :breakers, :broken_at, :datetime
  end
end

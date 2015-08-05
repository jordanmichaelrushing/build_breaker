class AddFixedAtToBreakers < ActiveRecord::Migration
  def change
    add_column :breakers, :fixed_at, :datetime
  end
end

class AddFixedByToBreakers < ActiveRecord::Migration
  def change
    add_column :breakers, :fixed_by, :string
  end
end

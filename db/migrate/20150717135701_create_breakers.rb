class CreateBreakers < ActiveRecord::Migration
  def change
    create_table :breakers do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end

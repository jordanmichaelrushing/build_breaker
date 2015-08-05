class CreateSayings < ActiveRecord::Migration
  def change
    create_table :sayings do |t|
      t.string :msg

      t.timestamps null: false
    end
  end
end

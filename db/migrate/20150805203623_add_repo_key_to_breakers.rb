class AddRepoKeyToBreakers < ActiveRecord::Migration
  def change
    add_column :breakers, :repo_key, :string
  end
end

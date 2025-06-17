class AddDeveloper1Field < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :developer1_field, :string
  end
end

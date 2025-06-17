class AddDeveloper2Field < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :developer2_field, :string
  end
end

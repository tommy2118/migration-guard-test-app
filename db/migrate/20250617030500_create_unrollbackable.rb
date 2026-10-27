class CreateUnrollbackable < ActiveRecord::Migration[8.0]
  def up
    create_table :unrollbackable do |t|
      t.string :name
    end
  end
  
  def down
    raise "This migration cannot be rolled back\!"
  end
end

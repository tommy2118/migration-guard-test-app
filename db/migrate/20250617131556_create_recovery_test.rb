class CreateRecoveryTest < ActiveRecord::Migration[8.0]
  def change
    create_table :recovery_tests do |t|
      t.text :description

      t.timestamps
    end
  end
end

class CreateBatchTest1 < ActiveRecord::Migration[8.0]
  def change
    create_table :batch_test1s do |t|
      t.string :field

      t.timestamps
    end
  end
end

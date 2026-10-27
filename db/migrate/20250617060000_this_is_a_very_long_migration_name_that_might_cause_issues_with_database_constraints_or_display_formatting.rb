class ThisIsAVeryLongMigrationNameThatMightCauseIssuesWithDatabaseConstraintsOrDisplayFormatting < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :very_long_field_name_for_testing_purposes, :string
  end
end

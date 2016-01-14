class CreateUsers < ActiveRecord::Migration
  # for incremental changes to the db
  def change
    create_table :users do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end

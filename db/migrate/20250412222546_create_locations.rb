class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :zip
      t.float :lat
      t.float :long

      t.timestamps
    end
  end
end

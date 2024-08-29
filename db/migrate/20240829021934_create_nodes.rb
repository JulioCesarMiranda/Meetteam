class CreateNodes < ActiveRecord::Migration[7.0]
  def change
    create_table :nodes do |t|
      t.integer :identifier
      t.integer :current_state
      t.text :log
      t.boolean :active

      t.timestamps
    end
  end
end

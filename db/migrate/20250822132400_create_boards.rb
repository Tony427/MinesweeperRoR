class CreateBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :boards do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :mines_count, null: false
      t.text :board_data, null: false

      t.timestamps
    end

    add_index :boards, :created_at
    add_index :boards, :email
  end
end
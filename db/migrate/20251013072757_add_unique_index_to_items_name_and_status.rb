class AddUniqueIndexToItemsNameAndStatus < ActiveRecord::Migration[8.0]
  def change
    add_index :items, [ :name, :status ], unique: true
  end
end

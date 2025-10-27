class AddUniqueIndexToItemsName < ActiveRecord::Migration[8.1]
  def change
    remove_index :items, name: "index_items_on_name_and_status"
    add_index :items, :name, unique: true, name: "index_items_on_name"
  end
end

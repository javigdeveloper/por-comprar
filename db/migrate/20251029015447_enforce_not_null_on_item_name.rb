class EnforceNotNullOnItemName < ActiveRecord::Migration[8.1]
  def change
    change_column :items, :name, :string, limit: 50, null: false
  end
end

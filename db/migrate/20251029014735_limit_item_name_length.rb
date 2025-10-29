class LimitItemNameLength < ActiveRecord::Migration[8.1]
  def change
    change_column :items, :name, :string, limit: 50
  end
end

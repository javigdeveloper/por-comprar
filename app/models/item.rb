class Item < ApplicationRecord
  enum :status, [:to_buy, :bought, :archived]

  validates :name, presence: true
end

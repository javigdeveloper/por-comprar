require 'rails_helper'

RSpec.describe Item, type: :model do
  it "is valid with a name and status" do
    item = Item.new(name: "Milk", status: :to_buy)
    expect(item).to be_valid
  end

  it "is invalid without a name" do
    item = Item.new(name: nil, status: :to_buy)
    expect(item).not_to be_valid
  end

  it "defaults to 'to_buy' status" do
    item = Item.new(name: "Bread")
    expect(item.status).to eq("to_buy")
  end
end

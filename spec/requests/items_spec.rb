require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "GET /items" do
    it "shows only to_buy items" do
      to_buy = Item.create!(name: "Apples", status: :to_buy)
      bought = Item.create!(name: "Eggs", status: :bought)

      get items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Apples")
      expect(response.body).not_to include("Eggs")
    end
  end

  describe "POST /items" do
    it "creates a new item and redirects" do
      expect {
        post items_path, params: { item: { name: "Bread" } }
      }.to change(Item, :count).by(1)

      expect(response).to redirect_to(items_path)
      follow_redirect!
      expect(response.body).to include("Bread")
    end

    it "fails without name" do
      expect {
        post items_path, params: { item: { name: "" } }
      }.not_to change(Item, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /items/:id" do
    it "marks item as bought" do
      item = Item.create!(name: "Juice", status: :to_buy)

      patch item_path(item), params: { item: { status: :bought } }

      expect(response).to redirect_to(items_path)
      item.reload
      expect(item.status).to eq("bought")
    end
  end

  describe "DELETE /items/:id" do
    it "deletes the item" do
      item = Item.create!(name: "Milk")

      expect {
        delete item_path(item)
      }.to change(Item, :count).by(-1)

      expect(response).to redirect_to(items_path)
    end
  end
end

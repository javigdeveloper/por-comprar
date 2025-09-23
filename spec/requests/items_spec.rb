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

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
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

      expect(response).to redirect_to(to_buy_items_path)
    end
  end

  describe "GET /items/to_buy" do
    it "shows only to_buy items" do
      to_buy_item = Item.create!(name: "Manzanas", status: :to_buy)
      bought_item = Item.create!(name: "Huevos", status: :bought)

      get to_buy_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Manzanas")
      expect(response.body).not_to include("Huevos")
    end
  end

  describe "GET /items/bought" do
    it "shows only bought items" do
      bought_item = Item.create!(name: "Pan", status: :bought)
      to_buy_item = Item.create!(name: "Leche", status: :to_buy)

      get bought_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Pan")
      expect(response.body).not_to include("Leche")
    end
  end

  describe "GET /items/archived" do
    it "shows only archived items" do
      archived_item = Item.create!(name: "Cereal", status: :archived)
      to_buy_item = Item.create!(name: "Café", status: :to_buy)

      get archived_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cereal")
      expect(response.body).not_to include("Café")
    end
  end

  describe "GET /items/popular" do
    it "renders the popular items page" do
      get popular_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Artículos Populares") # Match your <h1> title
    end
  end
end

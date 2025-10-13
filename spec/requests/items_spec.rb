require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "GET /items/to_buy" do
    it "shows only to_buy items" do
      item_por_comprar = Item.create!(name: "Manzanas", status: :to_buy)
      item_comprado = Item.create!(name: "Huevos", status: :bought)

      get to_buy_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Manzanas")
      expect(response.body).not_to include("Huevos")
    end
  end

  describe "POST /items" do
    it "creates a new item and redirects" do
      expect {
        post items_path, params: { item: { name: "Pan" } }
      }.to change(Item, :count).by(1)

      expect(response).to redirect_to(to_buy_items_path)
      follow_redirect!
      expect(response.body).to include("Pan")
    end

    it "fails to create an item with a blank name" do
      expect {
        post items_path, params: { item: { name: "" } }
      }.not_to change(Item, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("El artículo no puede estar vacío")
    end

    it "fails to create an item with a name longer than 50 chars" do
      long_name = "a" * 51
      expect {
        post items_path, params: { item: { name: long_name } }
      }.not_to change(Item, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("El artículo es demasiado largo")
    end

    it "fails to create a duplicate item with same name and status" do
      Item.create!(name: "Pan", status: :to_buy)

      expect {
        post items_path, params: { item: { name: "Pan", status: :to_buy } }
      }.not_to change(Item, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("El artículo ya existe en esta lista")
    end
  end

  describe "PATCH /items/:id" do
    it "marks item as bought" do
      item = Item.create!(name: "Jugo", status: :to_buy)

      patch item_path(item),
            params: { item: { status: :bought } },
            headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      item.reload
      expect(item.status).to eq("bought")
    end

    it "fails to update an item to a duplicate name and status" do
      item1 = Item.create!(name: "Pan", status: :to_buy)
      item2 = Item.create!(name: "Leche", status: :to_buy)

      patch item_path(item2), params: { item: { name: "Pan", status: :to_buy } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("El artículo ya existe en esta lista")
      expect(item2.reload.name).to eq("Leche")
    end

    it "renders turbo stream update failure template on update failure" do
      item1 = Item.create!(name: "Pan", status: :to_buy)
      item2 = Item.create!(name: "Leche", status: :to_buy)

      patch item_path(item2),
            params: { item: { name: "Pan", status: :to_buy } },
            headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end
  end

  describe "DELETE /items/:id" do
    it "deletes the item" do
      item = Item.create!(name: "Leche")

      expect {
        delete item_path(item)
      }.to change(Item, :count).by(-1)

      expect(response).to redirect_to(to_buy_items_path)
    end
  end

  describe "GET /items/bought" do
    it "shows only bought items" do
      comprado = Item.create!(name: "Pan", status: :bought)
      por_comprar = Item.create!(name: "Leche", status: :to_buy)

      get bought_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Pan")
      expect(response.body).not_to include("Leche")
    end
  end

  describe "GET /items/archived" do
    it "shows only archived items" do
      archivado = Item.create!(name: "Cereal", status: :archived)
      por_comprar = Item.create!(name: "Café", status: :to_buy)

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
      expect(response.body).to include("Artículos Populares")
    end
  end

  describe "POST /items/create_from_popular" do
    it "adds a popular item to the list" do
      expect {
        post create_from_popular_items_path, params: { name: "Pan" }
      }.to change(Item, :count).by(1)

      expect(Item.last.name).to eq("Pan")
      expect(Item.last.status).to eq("to_buy")
    end

    it "does not add duplicate item names" do
      Item.create!(name: "Pan", status: :to_buy)

      expect {
        post create_from_popular_items_path, params: { name: "Pan" }
      }.not_to change(Item, :count)
    end
  end

  describe "POST /items/batch_update_status" do
    it "updates multiple item statuses" do
      item1 = Item.create!(name: "Pan", status: :bought)
      item2 = Item.create!(name: "Leche", status: :bought)

      post batch_update_status_items_path, params: {
        updates: {
          item1.id.to_s => "to_buy",
          item2.id.to_s => "archived"
        }
      }

      expect(response).to have_http_status(:ok).or have_http_status(:found) # Turbo = 200, HTML fallback = 302

      expect(item1.reload.status).to eq("to_buy")
      expect(item2.reload.status).to eq("archived")
    end
  end
end

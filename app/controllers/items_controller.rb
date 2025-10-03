class ItemsController < ApplicationController
  before_action :set_item, only: [ :update, :destroy ]

  POPULAR_ITEM_NAMES = [
    "Pan", "Leche", "Huevos", "Queso", "Café", "Mantequilla", "Arroz",
    "Pasta", "Aceite", "Azúcar", "Sal", "Pimienta", "Tomates", "Cebolla",
    "Ajo", "Papas", "Zanahorias", "Manzanas", "Bananas", "Naranjas",
    "Pollo", "Carne", "Pescado", "Jugo", "Agua", "Refresco", "Yogur",
    "Harina", "Galletas", "Cereal"
  ]

  def to_buy
    @items = Item.to_buy
    @item = Item.new
  end

  def bought
    @items = Item.bought
  end

  def archived
    @items = Item.archived
  end

  def popular
    @popular_items = POPULAR_ITEM_NAMES - Item.pluck(:name)
  end

  def create_from_popular
    item_name = params[:name]

    unless Item.exists?(name: item_name)
      Item.create!(name: item_name, status: :to_buy)
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("popular_item_#{item_name.parameterize}") }
      format.html { redirect_to to_buy_items_path }
    end
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to to_buy_items_path
    else
      @items = Item.to_buy
      render :to_buy, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to to_buy_items_path }
      end
    else
      respond_to do |format|
        format.html { redirect_to to_buy_items_path, alert: "No se pudo actualizar el artículo." }
      end
    end
  end

  def destroy
    @item.destroy
    redirect_to to_buy_items_path
  end

  def batch_update_status
    updates = params[:updates] || {}

    @processed_items = []

    updates.each do |id, status|
      item = Item.find_by(id: id)
      next unless item

      if status == "delete"
        item.destroy
      elsif Item.statuses.key?(status)
        item.update(status: status)
      end

      @processed_items << id
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to request.referer || to_buy_items_path, notice: "Productos actualizados correctamente." }
    end
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :status)
  end
end

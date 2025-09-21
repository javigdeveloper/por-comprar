class ItemsController < ApplicationController
  before_action :set_item, only: [:update, :destroy]

  def index
    @items = Item.to_buy.order(created_at: :desc)
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to items_path, notice: "Item added."
    else
      @items = Item.to_buy.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      redirect_to items_path, notice: "Item updated."
    else
      redirect_to items_path, alert: "Update failed."
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: "Item deleted."
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :status)
  end
end

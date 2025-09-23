class ItemsController < ApplicationController
  before_action :set_item, only: [ :update, :destroy ]

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
    # @popular_items = Item.popular_logic_here # To be implement this later
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

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :status)
  end
end

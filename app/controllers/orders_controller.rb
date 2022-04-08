class OrdersController < ApplicationController
  include OrdersHelper
  before_action :logged_in_user
  before_action :order_new_create, only: :create

  def index
    @pagy, @orders = pagy Order.list_orders_of_user(current_user.id)
                               .sort_by_day,
                          items: Settings.number.digits_6
  end

  def new
    @default_address = current_user.addresses.first
    @products = {}

    if cart_current.empty?
      flash[:danger] = t ".no_proc_in_cart"
      redirect_to cart_url
    else
      cart_current.each do |product_detail_id, quantity|
        product_not_found product_detail_id
        @products[@product_detail] = quantity if @product_detail
      end
    end
  end

  def create
    new_order_details
    ActiveRecord::Base.transaction do
      @new_order.save!
    end
    cart_current.clear
    flash[:success] = t ".success_order"
    redirect_to root_url
  rescue NoMethodError
    flash[:danger] = t ".has_err"
    redirect_to new_order_url
  end

  def show_by_status
    @pagy, @orders = pagy Order.list_orders_of_user(current_user.id)
                               .show_by_status(params[:id_status]).sort_by_day,
                          items: Settings.number.digits_6
    render "index"
  end

  private

  def params_new_order
    order_params_user
    order_params_address
    params.permit :user_id, :address_id
  end

  def order_new_create
    @new_order = Order.new params_new_order
  end

  def new_order_details
    cart_current.each do |product_detail_id, quantity|
      product_detail = ProductDetail.find_by id: product_detail_id
      @new_order.order_details.build(
        quantity: quantity,
        price: product_detail.price,
        product_detail_id: product_detail.id
      )
    end
  end

  def product_not_found product_detail_id
    @product_detail = ProductDetail.find_by id: product_detail_id
    return @product_detail if @product_detail

    delete_cart product_detail_id
    flash[:danger] = t("product.out_of_stock")
    redirect_to cart_path
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :no_nil_cart

  protected

  def no_nil_cart
    session[:cart] ||= []
  end

  def confirm_login
    if session[:merchant].nil?
      flash[:status] = :failure
      flash[:message] = "You must be logged in to do that."
      return redirect_back(fallback_location: products_path)
    end
  end

  def find_object_by_params(model)
    @product = model.find_by(id: params[:id])
    unless @product
      return head :not_found
    end
    return @product
  end

  def confirm_object_ownership(model, merchant_id)
    unless session[:merchant]['id'] == merchant_id
      flash[:status] = :failure
      flash[:message] = "Only a #{model}'s merchant can modify a #{model}."
      return redirect_back(fallback_location: pathfinder(model.class))
    end
  end

  def check_for_product_owner
    unless session[:merchant].nil?
      if @review.merchant_id == session[:merchant]["id"]
        flash[:status] = :failure
        flash[:result_text] = "Owner can not edit the review of the product!"
        redirect_to product_path(@review.product_id)
      end
    end
  end

  def check_for_product_owner_nested
    @product = Product.find_by(id: params[:product_id])
    unless @product
      head :not_found
    end
    if !session[:merchant].nil? && @product.merchant_id == session[:merchant]["id"]
      flash[:status] = :failure
      flash[:result_text] = "Owner can not review the product!"
      redirect_to product_path(@product)
    end
  end

  private
  def pathfinder(model)
    case model
    when Product
      return products_path
    else
      return root_path
    end
  end
end

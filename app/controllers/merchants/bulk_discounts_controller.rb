class Merchants::BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @discounts = @merchant.bulk_discounts
    @holidays = UpcomingHolidays.next_three_holidays
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.new
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    discount = merchant.bulk_discounts.new(bulk_discount_params)

    if discount.discount_valid?
      if discount.save
        redirect_to merchant_bulk_discounts_path(merchant.id)
      else
        redirect_to new_merchant_bulk_discount_path(merchant.id)
        flash[:alert] = "Error: #{error_message(discount.errors)}"
      end
    else
      redirect_to new_merchant_bulk_discount_path(merchant.id)
      flash[:alert] = "Error: Discount terms invalid - another discount will always supersede"
    end
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.find(params[:id])

    if discount.update_valid?
      if discount.update(bulk_discount_params)
        redirect_to merchant_bulk_discount_path(merchant.id, discount.id)
      else
        redirect_to edit_merchant_bulk_discount_path(merchant.id, discount.id)
        flash[:alert] = "Error: #{error_message(discount.errors)}"
      end
    else
      redirect_to edit_merchant_bulk_discount_path(merchant.id, discount.id)
      flash[:alert] = "Error: Cannot update discount while it applies to in-progress invoices"
    end
  end

  def destroy
    merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.find(params[:id])

    if discount.update_valid?
      merchant.bulk_discounts.delete(discount)
      redirect_to merchant_bulk_discounts_path(merchant.id)
    else
      redirect_to merchant_bulk_discounts_path(merchant.id)
      flash[:alert] = "Error: Cannot update discount while it applies to in-progress invoices"
    end
  end

  private
  def bulk_discount_params
    params.require(:bulk_discount).permit(:percentage, :quantity_threshold)
  end

end

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

    if discount.save
      redirect_to merchant_bulk_discounts_path(merchant.id)
    else
      redirect_to new_merchant_bulk_discount_path(merchant.id)
      flash[:alert] = "Error: #{error_message(discount.errors)}"
    end
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.find(params[:id])

    if valid_update?(discount.id)
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

    merchant.bulk_discounts.delete(discount)

    redirect_to merchant_bulk_discounts_path(merchant.id)
  end

  private
  def bulk_discount_params
    params.require(:bulk_discount).permit(:percentage, :quantity_threshold)
  end

  def valid_update?(discount_id)
    discount = BulkDiscount.find(discount_id)

    in_progress_invoices = discount
                      .merchant
                      .items
                      .joins(:invoices)
                      .where('invoice_items.quantity >= ?', discount.quantity_threshold)
                      .where('invoices.status = ?', 0)


    in_progress_invoices.length == 0
  end
end

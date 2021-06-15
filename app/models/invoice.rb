class Invoice < ApplicationRecord
  enum status: [:in_progress, :completed, :cancelled]

  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :transactions

  validates :customer_id, presence: true
  validates :status, {presence: true}
  validates_numericality_of :status

  def self.unshipped_items
    joins(:invoice_items)
    .where('invoice_items.status != 2')
    .select('invoices.*')
    .group('invoices.id')
    .order('invoices.created_at asc')
  end

  def item_sale_price
    items
    .select('items.*, invoice_items.unit_price as sale_price, invoice_items.quantity as sale_quantity')
  end

  def total_revenue
    invoice_items
    .sum('invoice_items.unit_price * invoice_items.quantity')
  end

  def discounted_revenue
    discounted_revenue = 0

    invoice_items.each do |invoice_item|
      discounts = invoice_items
                  .joins(item: {merchant: :bulk_discounts})
                  .where('items.merchant_id = ?', invoice_item.item.merchant_id)
                  .where('invoice_items.quantity >= bulk_discounts.quantity_threshold')
                  .group('invoice_items.id')
                  .maximum('bulk_discounts.percentage')
      discount = discounts[invoice_item.id]

      if discount.nil?
        discounted_revenue += invoice_item.quantity * invoice_item.unit_price
      else
        discounted_revenue += ((invoice_item.quantity * invoice_item.unit_price) * (1.0 - discount/100.0))
      end
    end

    discounted_revenue
  end

  def total_revenue_for_merchant(merchant_id)
    items
    .where(merchant_id: merchant_id)
    .sum('invoice_items.unit_price * invoice_items.quantity')
  end

  def discounted_revenue_for_merchant(merchant_id)
    item_discounts(merchant_id).sum do |item|
      item.total_revenue * (1-(item.discount_percentage / 100))
    end
  end

  def enum_integer
    enum_convert = Invoice.statuses
    enum_convert[self.status]
  end

  private
  def item_discounts(merchant_id)
    invoice_items
    .select('DISTINCT ON (invoice_items.id)
            invoice_items.id,
            CASE
              WHEN invoice_items.quantity >= bulk_discounts.quantity_threshold
              THEN bulk_discounts.percentage
              ELSE 0
              END AS discount_percentage,
            (invoice_items.unit_price * invoice_items.quantity) as total_revenue')
    .joins(item: {merchant: :bulk_discounts})
    .where('items.merchant_id = ?', merchant_id)
    .order('invoice_items.id, discount_percentage DESC')
  end

end

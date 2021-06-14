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

  def total_revenue_for_merchant(merchant_id)
    items
    .where(merchant_id: merchant_id)
    .sum('invoice_items.unit_price * invoice_items.quantity')
  end

  def enum_integer
    enum_convert = Invoice.statuses
    enum_convert[self.status]
  end

  def discounted_revenue_for_merchant(merchant_id)
    discounts = invoice_item_percent_discount(merchant_id)
    initial_revenue = invoice_item_undiscounted_revenue(merchant_id)

    initial_revenue.sum do |invoice_item_id, revenue|
      if !discounts[invoice_item_id].nil?
        revenue * (1.0 - discounts[invoice_item_id]/100.0)
      else
        revenue
      end
    end
  end

  # Helpers for #discounted_revenue_for_merchant
  def invoice_item_percent_discount(merchant_id)
    invoice_items
    .joins(item: {merchant: :bulk_discounts})
    .where('items.merchant_id = ?', merchant_id)
    .where('invoice_items.quantity >= bulk_discounts.quantity_threshold')
    .group('invoice_items.id')
    .maximum('bulk_discounts.percentage')
  end

  def invoice_item_undiscounted_revenue(merchant_id)
    items
    .where('items.merchant_id = ?', merchant_id)
    .group('invoice_items.id')
    .sum('invoice_items.unit_price * invoice_items.quantity')
  end
end

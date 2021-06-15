class InvoiceItem < ApplicationRecord
  enum status: [:pending, :packaged, :shipped]
  belongs_to :invoice
  belongs_to :item

  def self.invoice_items_show(invoice_id, merchant_id)
    joins(:item)
    .select("invoice_items.*, items.name AS item_name")
    .where("invoice_items.invoice_id = #{invoice_id} and items.merchant_id = #{merchant_id}")
  end

  def discount_applied
    item
    .merchant
    .bulk_discounts
    .where('bulk_discounts.quantity_threshold <= ?', self.quantity)
    .order('bulk_discounts.percentage DESC')
    .first
  end

  def numeric_status
    InvoiceItem.statuses[status]
  end
end

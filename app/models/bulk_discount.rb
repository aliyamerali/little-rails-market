class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  validates :percentage, presence: true
  validates :quantity_threshold, presence: true

  def update_valid?
    in_progress_invoices = merchant
                          .items
                          .joins(:invoices)
                          .where('invoice_items.quantity >= ?', quantity_threshold)
                          .where('invoices.status = ?', 0)

    in_progress_invoices.length == 0
  end

end

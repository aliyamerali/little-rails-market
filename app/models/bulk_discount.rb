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

  def discount_valid?
    superceding_invoices = BulkDiscount
                          .where('quantity_threshold <= ?', self.quantity_threshold)
                          .where('percentage >= ?', self.percentage)

    superceding_invoices.length == 0
  end

end

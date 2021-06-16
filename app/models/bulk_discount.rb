class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  validates :percentage, presence: true
  validates :quantity_threshold, presence: true


  def delete_valid?
    in_progress_invoices = merchant
                          .items
                          .joins(:invoices)
                          .where('invoice_items.quantity >= ?', quantity_threshold)
                          .where('invoices.status = ?', 0)

    in_progress_invoices.length == 0
  end

  def create_valid?
    if id.nil?
      superceding_invoices = BulkDiscount
                            .where('quantity_threshold <= ?', self.quantity_threshold)
                            .where('percentage >= ?', self.percentage)
    else
      superceding_invoices = BulkDiscount
                            .where('quantity_threshold <= ?', self.quantity_threshold)
                            .where('percentage >= ?', self.percentage)
                            .where.not('id = ?', self.id)
    end

    superceding_invoices.length == 0
  end

  def update_valid?
    delete_valid? && create_valid?
  end
end

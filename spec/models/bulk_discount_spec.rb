require 'rails_helper'

RSpec.describe BulkDiscount do
  describe 'relationships' do
    it { should belong_to(:merchant)}
    it { should validate_presence_of(:percentage)}
    it { should validate_presence_of(:quantity_threshold)}
  end

  describe 'instance methods' do

    it '#update_valid? returns true if a discount *is not* applied to any invoices with status in-progress, else false' do
      merchant = Merchant.create!(name: 'Sal\'s Signs')
      discount_1 = merchant.bulk_discounts.create!(percentage: 10.0, quantity_threshold: 10)
      discount_2 = merchant.bulk_discounts.create!(percentage: 5.0, quantity_threshold: 5)

      customer_1 = Customer.create!(first_name: 'Sally', last_name: 'Shopper')

      item_1 = merchant.items.create!(name: 'Gold Ring', description: 'Jewelery', unit_price: 10000)
      item_2 = merchant.items.create!(name: 'Silver Ring', description: 'Jewelery', unit_price: 10000)

      invoice_1 = customer_1.invoices.create!(status: 1, created_at: "2012-03-06 14:54:15 UTC")
      invoice_2 = customer_1.invoices.create!(status: 0, created_at: "2012-03-06 14:54:15 UTC")

      invoice_item_1 = InvoiceItem.create!(quantity: 10, unit_price: 10000, item_id: item_1.id, invoice_id: invoice_1.id, status: 1)
      invoice_item_2 = InvoiceItem.create!(quantity: 5, unit_price: 5000, item_id: item_2.id, invoice_id: invoice_2.id, status: 1)

      expect(discount_1.update_valid?).to eq(true)
      expect(discount_2.update_valid?).to eq(false)
    end

    it '#discount_valid? returns false if discount will always be superceded by existing discount' do
      merchant = Merchant.create!(name: 'Sal\'s Signs')
      discount_1 = merchant.bulk_discounts.create!(percentage: 10.0, quantity_threshold: 10)
      discount_2 = merchant.bulk_discounts.new(percentage: 5.0, quantity_threshold: 12)

      expect(discount_1.discount_valid?).to eq(true)
      expect(discount_2.discount_valid?).to eq(false)
    end
  end
end

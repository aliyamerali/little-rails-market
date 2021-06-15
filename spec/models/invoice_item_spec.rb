require 'rails_helper'

RSpec.describe InvoiceItem do
  describe 'relationships' do

    it { should belong_to(:invoice) }
    it { should belong_to(:item) }

  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values([:pending, :packaged, :shipped])}
  end

  describe 'class methods' do
    describe '.invoice_items_show' do
      it 'returns all items for a given merchants invoice id' do
        merchant = Merchant.create!(name: 'Schroeder-Jerde')
        merchant_2 = Merchant.create!(name: 'James Bond')
        customer_2 = Customer.create!(first_name: 'Evan', last_name: 'East')
        customer_3 = Customer.create!(first_name: 'Yasha', last_name: 'West')
        customer_1 = Customer.create!(first_name: 'Sally', last_name: 'Shopper')
        customer_4 = Customer.create!(first_name: 'Du', last_name: 'North')
        customer_5 = Customer.create!(first_name: 'Jackie', last_name: 'Chan')
        item_1 = merchant.items.create!(name: 'Gold Ring', description: 'Jewelery', unit_price: 10000)
        item_4 = merchant.items.create!(name: 'Hair Clip', description: 'Accessories', unit_price: 200)
        item_2 = merchant.items.create!(name: 'Silver Ring', description: 'Jewelery', unit_price: 5000)
        item_3 = merchant.items.create!(name: 'Hoop Earrings', description: 'Jewelery', unit_price: 1000)
        item_5 = merchant_2.items.create!(name: 'Silver Bracelet', description: 'Accessories', unit_price: 3000)
        item_6 = merchant_2.items.create!(name: 'Bronze Ring', description: 'Jewelery', unit_price: 2000)
        invoice_1 = customer_1.invoices.create!(status: 1, created_at: "2012-03-06 14:54:15 UTC")
        invoice_4 = customer_4.invoices.create!(status: 1, created_at: "2012-03-09 14:54:15 UTC")
        invoice_2 = customer_2.invoices.create!(status: 1, created_at: "2012-03-07 00:54:24 UTC")
        invoice_3 = customer_3.invoices.create!(status: 1, created_at: "2012-03-08 14:54:15 UTC")
        invoice_5 = customer_5.invoices.create!(status: 1, created_at: "2012-03-10 14:54:15 UTC")
        invoice_6 = customer_5.invoices.create!(status: 1, created_at: "2012-03-11 14:54:15 UTC")
        invoice_item_1 = InvoiceItem.create!(quantity: 2, unit_price: 10000, item_id: item_1.id, invoice_id: invoice_1.id, status: 1)
        invoice_item_2 = InvoiceItem.create!(quantity: 2, unit_price: 5000, item_id: item_2.id, invoice_id: invoice_1.id, status: 1)
        invoice_item_3 = InvoiceItem.create!(quantity: 2, unit_price: 1000,item_id: item_3.id, invoice_id: invoice_1.id, status: 1)
        invoice_item_4 = InvoiceItem.create!(quantity: 2, unit_price: 200,item_id: item_4.id, invoice_id: invoice_4.id, status: 1)
        invoice_item_5 = InvoiceItem.create!(quantity: 2, unit_price: 3000,item_id: item_5.id, invoice_id: invoice_1.id, status: 1)
        invoice_item_6 = InvoiceItem.create!(quantity: 2, unit_price: 2000,item_id: item_6.id, invoice_id: invoice_6.id, status: 2)

        expect(InvoiceItem.invoice_items_show(invoice_1.id, merchant.id).first.item_name).to eq("Gold Ring")
        expect(InvoiceItem.invoice_items_show(invoice_1.id, merchant.id).first.unit_price).to eq(10000)
        expect(InvoiceItem.invoice_items_show(invoice_1.id, merchant.id).first.status).to eq("packaged")
        expect(InvoiceItem.invoice_items_show(invoice_1.id, merchant.id).second.item_name).to eq("Silver Ring")
        expect(InvoiceItem.invoice_items_show(invoice_1.id, merchant.id).second.unit_price).to eq(5000)
        expect(InvoiceItem.invoice_items_show(invoice_1.id, merchant.id).second.status).to eq("packaged")
        expect(InvoiceItem.invoice_items_show(invoice_1.id, merchant.id)).to_not include(item_5)
      end
    end

    describe 'instance methods' do
      describe '#discount_applied' do
        it 'returns id of the discount applied to an invoice_item, if any' do
          @merchant = Merchant.create!(name: "Little Shop of Horrors")
          @merchant_2 = Merchant.create!(name: "Little Shop of Horrors")

          @customer = Customer.create!(first_name: 'Audrey', last_name: 'I')
          @invoice_1 = @customer.invoices.create!(status: 1, updated_at: '2021-03-01')

          # my items on invoice
          @item_1 = @merchant.items.create!(name: 'Audrey II', description: 'Large, man-eating plant', unit_price: '100000000', enabled: true)
          @item_2 = @merchant.items.create!(name: 'Bouquet of roses', description: '12 red roses', unit_price: '1900', enabled: true)
          @item_3 = @merchant.items.create!(name: 'Echevaria', description: 'Peacock varietal', unit_price: '3100', enabled: true)

          # other merchant items on invoice
          @item_4 = @merchant_2.items.create!(name: 'Silver Bracelet', description: 'Accessories', unit_price: 3000)

          #my discounts
          @discount_1 = @merchant.bulk_discounts.create!(percentage: 10.0, quantity_threshold: 8)
          @discount_2 = @merchant.bulk_discounts.create!(percentage: 20.0, quantity_threshold: 15)
          @discount_3 = @merchant.bulk_discounts.create!(percentage: 25.0, quantity_threshold: 19)

          # $2520 for my revenue / $1970 discounted revenue
          @invoice_item_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 10000, status: 0) # $2000 total / $1500 discounted (25%)
          @invoice_item_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 10, unit_price: 5000, status: 0) # $500 total / $450 discounted (10%)
          @invoice_item_3 = @item_3.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 2, unit_price: 1000, status: 1) # $20 total / no discount

          # Other merchant's revenue
          @invoice_item_4 = InvoiceItem.create!(quantity: 10, unit_price: 3000,item_id: @item_4.id, invoice_id: @invoice_1.id, status: 0) # 30,000 total

          expect(@invoice_item_1.discount_applied).to eq(@discount_3)
          expect(@invoice_item_2.discount_applied).to eq(@discount_1)
          expect(@invoice_item_3.discount_applied).to eq(nil)
          expect(@invoice_item_4.discount_applied).to eq(nil)
        end
      end
      describe '#numeric_status' do
        it 'returns the status of the invoice item as an integer for select menu' do
          merchant = Merchant.create!(name: 'Schroeder-Jerde')
          customer = Customer.create!(first_name: 'Sally', last_name: 'Shopper')
          invoice = customer.invoices.create!(status: 1, created_at: "2012-03-06 14:54:15 UTC")

          item_1 = merchant.items.create!(name: 'Gold Ring', description: 'Jewelery', unit_price: 10000)
          item_2 = merchant.items.create!(name: 'Silver Ring', description: 'Jewelery', unit_price: 5000)
          item_3 = merchant.items.create!(name: 'Hoop Earrings', description: 'Jewelery', unit_price: 1000)

          ii_1 = InvoiceItem.create!(quantity: 2, unit_price: 10000, item_id: item_1.id, invoice_id: invoice.id, status: 0)
          ii_2 = InvoiceItem.create!(quantity: 2, unit_price: 10000, item_id: item_2.id, invoice_id: invoice.id, status: 1)
          ii_3 = InvoiceItem.create!(quantity: 2, unit_price: 10000, item_id: item_3.id, invoice_id: invoice.id, status: 2)

          expect(ii_1.numeric_status).to eq 0
          expect(ii_2.numeric_status).to eq 1
          expect(ii_3.numeric_status).to eq 2
        end
      end
    end
  end
end

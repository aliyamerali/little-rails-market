require 'rails_helper'

RSpec.describe Invoice do
  describe 'relationships' do
    it { should have_many(:invoice_items).dependent(:destroy) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:transactions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:customer_id) }
    it { should validate_presence_of(:status) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values([:in_progress, :completed, :cancelled])}
  end

  before :each do
    @merchant = Merchant.create!(name: "Little Shop of Horrors")
    @merchant_2 = Merchant.create!(name: 'James Bond')

    @customer = Customer.create!(first_name: 'Audrey', last_name: 'I')
    @invoice_1 = @customer.invoices.create!(status: 1, updated_at: '2021-03-01')
    @invoice_2 = @customer.invoices.create!(status: 1, updated_at: '2021-03-01')
    @invoice_3 = @customer.invoices.create!(status: 1, updated_at: '2021-03-01')
    @invoice_4 = @customer.invoices.create!(status: 1, updated_at: '2021-03-01')

    # my items on invoice
    @item_1 = @merchant.items.create!(name: 'Audrey II', description: 'Large, man-eating plant', unit_price: '100000000', enabled: true)
    @item_2 = @merchant.items.create!(name: 'Bouquet of roses', description: '12 red roses', unit_price: '1900', enabled: true)
    @item_3 = @merchant.items.create!(name: 'Echevaria', description: 'Peacock varietal', unit_price: '3100', enabled: true)

    # other merchant items on invoice
    @item_4 = @merchant_2.items.create!(name: 'Silver Bracelet', description: 'Accessories', unit_price: 3000)
    @item_5 = @merchant_2.items.create!(name: 'Bronze Ring', description: 'Jewelery', unit_price: 2000)

    #my discounts
    @discount_1 = @merchant.bulk_discounts.create!(percentage: 10.0, quantity_threshold: 8)
    @discount_2 = @merchant.bulk_discounts.create!(percentage: 20.0, quantity_threshold: 15)
    @discount_3 = @merchant.bulk_discounts.create!(percentage: 25.0, quantity_threshold: 19)
    @discount_4 = @merchant.bulk_discounts.create!(percentage: 30.0, quantity_threshold: 25)
    @discount_5 = @merchant_2.bulk_discounts.create!(percentage: 30.0, quantity_threshold: 11)

    # $2520 for my revenue / $1970 discounted revenue
    @invoice_item_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 10000, status: 0) # $2000 total / $1500 discounted (25%)
    @invoice_item_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 10, unit_price: 5000, status: 0) # $500 total / $450 discounted (10%)
    @invoice_item_3 = @item_3.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 2, unit_price: 1000, status: 1) # $20 total / no discount

    # Other merchant's revenue
    @invoice_item_4 = InvoiceItem.create!(quantity: 10, unit_price: 3000,item_id: @item_4.id, invoice_id: @invoice_1.id, status: 0) # 30,000 total
    @invoice_item_7 = InvoiceItem.create!(quantity: 15, unit_price: 2000,item_id: @item_5.id, invoice_id: @invoice_1.id, status: 2) # 30,000 / 21,000 discounted
    @invoice_item_5 = InvoiceItem.create!(quantity: 10, unit_price: 5000,item_id: @item_4.id, invoice_id: @invoice_2.id, status: 2) # 50,000
    @invoice_item_8 = InvoiceItem.create!(quantity: 15, unit_price: 4000,item_id: @item_5.id, invoice_id: @invoice_3.id, status: 0) # 60,000 / 42,000 discounted
    @invoice_item_6 = InvoiceItem.create!(quantity: 10, unit_price: 9000,item_id: @item_4.id, invoice_id: @invoice_4.id, status: 2) # 90,000
    @invoice_item_9 = InvoiceItem.create!(quantity: 15, unit_price: 6000,item_id: @item_5.id, invoice_id: @invoice_4.id, status: 1) # 90,000 / 63,000 discounted
  end

  describe 'class methods' do
    describe '.unshipped_items' do
      it 'returns a collection of invoices that have unshipped items' do
        expect(Invoice.unshipped_items.first.id).to eq(@invoice_1.id)
        expect(Invoice.unshipped_items.length).to eq(3)
        expect(Invoice.unshipped_items.ids.include?(@invoice_2.id)).to eq(false)
      end
    end
  end

  describe 'instance methods' do
    it '#item_sale_price returns all items from an invoice and the amount they sold for and number sold' do
      actual = @invoice_1.item_sale_price.first

      expect(actual.sale_price).to eq(10000)
      expect(actual.sale_quantity).to eq(20)
    end

    it '#total_revenue returns sum of items unit_price * quantity for all items on an invoice' do
      expect(@invoice_1.total_revenue).to eq(312000)
    end

    it '#discounted_revenue returns total revenue less discounts for items across multiple merchants' do
      expect(@invoice_1.discounted_revenue).to eq(248000)
    end

    it '#total_revenue_for_merchant returns the total revenue expected for the invoice only for items belonging to given merchant' do
      expect(@invoice_1.total_revenue_for_merchant(@merchant.id)).to eq(252000)
    end

    it '#discounted_revenue_for_merchant calculates undiscounted revenue - discount for total discounted revenue' do
      expect(@invoice_1.discounted_revenue_for_merchant(@merchant.id)).to eq(197000)
    end

    it '#enum_integer returns the integer associated with that status' do
      expect(@invoice_1.status).to eq('completed')
      expect(@invoice_1.enum_integer).to eq(1)
    end

  end
end

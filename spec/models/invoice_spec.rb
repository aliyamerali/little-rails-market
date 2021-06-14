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

    # $2520 for my revenue / $1970 discounted revenue
    @invoice_item_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 20, unit_price: 10000, status: 0) # $2000 total / $1500 discounted (25%)
    @invoice_item_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 10, unit_price: 5000, status: 0) # $500 total / $450 discounted (10%)
    @invoice_item_3 = @item_3.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 2, unit_price: 1000, status: 1) # $20 total / no discount

    # Other merchant's revenue
    @invoice_item_4 = InvoiceItem.create!(quantity: 10, unit_price: 3000,item_id: @item_4.id, invoice_id: @invoice_1.id, status: 0) # Other merchant rev
    @invoice_item_5 = InvoiceItem.create!(quantity: 15, unit_price: 2000,item_id: @item_5.id, invoice_id: @invoice_1.id, status: 2) # Other merchant rev
    @invoice_item_6 = InvoiceItem.create!(quantity: 10, unit_price: 3000,item_id: @item_4.id, invoice_id: @invoice_2.id, status: 2) # Other merchant rev
    @invoice_item_7 = InvoiceItem.create!(quantity: 15, unit_price: 2000,item_id: @item_5.id, invoice_id: @invoice_3.id, status: 0) # Other merchant rev
    @invoice_item_8 = InvoiceItem.create!(quantity: 10, unit_price: 3000,item_id: @item_4.id, invoice_id: @invoice_4.id, status: 2) # Other merchant rev
    @invoice_item_9 = InvoiceItem.create!(quantity: 15, unit_price: 2000,item_id: @item_5.id, invoice_id: @invoice_4.id, status: 1) # Other merchant rev
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

    it '#total_revenue returns all items from an invoice and the amount they sold for and number sold' do
      actual = @invoice_1.total_revenue

      expect(actual).to eq(312000)
    end

    it '#total_revenue_for_merchant returns the total revenue expected for the invoice only for items belonging to given merchant' do
      actual = @invoice_1.total_revenue_for_merchant(@merchant.id)

      expect(actual).to eq(252000)
    end

    describe 'methods to calculate revenue after discounts' do
      it '#invoice_item_percent_discount returns the discounted revenue for the invoice only for items belonging to given merchant based on merchant\'s discounts' do
        expect(@invoice_1.invoice_item_percent_discount(@merchant.id)[@invoice_item_1.id]).to eq(25)
        expect(@invoice_1.invoice_item_percent_discount(@merchant.id)[@invoice_item_2.id]).to eq(10)
        expect(@invoice_1.invoice_item_percent_discount(@merchant.id)[@invoice_item_3.id]).to eq(nil)
        expect(@invoice_1.invoice_item_percent_discount(@merchant.id)[@invoice_item_4.id]).to eq(nil)
        expect(@invoice_1.invoice_item_percent_discount(@merchant.id)[@invoice_item_5.id]).to eq(nil)
      end

      it '#invoice_item_undiscounted_revenue returns hash of total undiscounted revenue per invoice_item' do
        expect(@invoice_1.invoice_item_undiscounted_revenue(@merchant.id)[@invoice_item_1.id]).to eq(200_000)
        expect(@invoice_1.invoice_item_undiscounted_revenue(@merchant.id)[@invoice_item_2.id]).to eq(50_000)
        expect(@invoice_1.invoice_item_undiscounted_revenue(@merchant.id)[@invoice_item_3.id]).to eq(2_000)
        expect(@invoice_1.invoice_item_undiscounted_revenue(@merchant.id)[@invoice_item_4.id]).to eq(nil)
        expect(@invoice_1.invoice_item_undiscounted_revenue(@merchant.id)[@invoice_item_5.id]).to eq(nil)
      end

      it 'discounted_revenue_for_merchant calculates undiscounted revenue - discount for total discounted revenue' do
        expect(@invoice_1.discounted_revenue_for_merchant(@merchant.id)).to eq(197000)
      end
    end

    it '#invoice_item_discount returns the discount id applied to a given item' do
      expect(@invoice_1.invoice_item_discount(@merchant.id, @invoice_item_1.id).id).to eq(@discount3.id)
      expect(@invoice_1.invoice_item_discount(@merchant.id, @invoice_item_2.id).id).to eq(@discount1.id)
      expect(@invoice_1.invoice_item_discount(@merchant.id, @invoice_item_3.id).id).to eq(nil)
      expect(@invoice_1.invoice_item_discount(@merchant.id, @invoice_item_4.id).id).to eq(nil)
    end

    it '#enum_integer returns the integer associated with that status' do
      expect(@invoice_1.status).to eq('completed')
      expect(@invoice_1.enum_integer).to eq(1)
    end

  end
end

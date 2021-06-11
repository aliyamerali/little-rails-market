require 'rails_helper'

RSpec.describe Merchant do
  describe 'relationships' do
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:bulk_discounts).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'callbacks' do
    it 'after_initialization it sets status to false if nil' do
      test = Merchant.create!(name: "test")
      expect(test.status).to eq(false)
    end
  end

  before :each do
    @merch_1 = Merchant.create!(name: "Sal's Signs", status: true)
    @merch_2 = Merchant.create!(name: "T-shirts by Terry", status: true)
    @merch_3 = Merchant.create!(name: "All About Amphibians", status: false)
    @merch_4 = Merchant.create!(name: "Will's Widdles", status: true)
    @merch_5 = Merchant.create!(name: "Rugula by Ron", status: true)
    @merch_6 = Merchant.create!(name: "Gemeni Gems", status: false)

    @item_1 = @merch_1.items.create!(name: 'thing1', description: 'thing1 is a thing', unit_price: 10)
    @item_2 = @merch_1.items.create!(name: 'thing2', description: 'thing1 is a thing', unit_price: 10)
    @item_3 = @merch_2.items.create!(name: 'thing1', description: 'thing1 is a thing', unit_price: 1)
    @item_4 = @merch_2.items.create!(name: 'thing2', description: 'thing2 is a thing', unit_price: 1)
    @item_5 = @merch_3.items.create!(name: 'thing1', description: 'thing1 is a thing', unit_price: 10)
    @item_6 = @merch_3.items.create!(name: 'thing2', description: 'thing2 is a thing', unit_price: 10)
    @item_7 = @merch_4.items.create!(name: 'thing1', description: 'thing1 is a thing', unit_price: 10)
    @item_8 = @merch_4.items.create!(name: 'thing2', description: 'thing2 is a thing', unit_price: 10)
    @item_9 = @merch_5.items.create!(name: 'thing1', description: 'thing1 is a thing', unit_price: 10)
    @item_10 = @merch_5.items.create!(name: 'thing2', description: 'thing2 is a thing', unit_price: 10)
    @item_11 = @merch_6.items.create!(name: 'thing1', description: 'thing1 is a thing', unit_price: 10)
    @item_12 = @merch_6.items.create!(name: 'thing2', description: 'thing2 is a thing', unit_price: 10)

    @customer = Customer.create!(first_name: "Sam", last_name: "Shmo")

    @invoice_1 = @customer.invoices.create!(status: 1, created_at: Time.utc(2020, 01, 01, 20, 30, 45))
    @invoice_2 = @customer.invoices.create!(status: 1, created_at: Time.utc(2018, 06, 01, 20, 30, 45))
    @invoice_3 = @customer.invoices.create!(status: 1, created_at: Time.utc(2019, 12, 15, 20, 30, 45))
    @invoice_4 = @customer.invoices.create!(status: 1, created_at: Time.utc(2020, 01, 15, 20, 30, 45))

    @transaction_1 = @invoice_1.transactions.create!(credit_card_number: "123123123", credit_card_expiration_date: "", result: 1)
    @transaction_5 = @invoice_3.transactions.create!(credit_card_number: "123123123", credit_card_expiration_date: "", result: 1)
    @transaction_6 = @invoice_4.transactions.create!(credit_card_number: "123123123", credit_card_expiration_date: "", result: 1)
    @transaction_2 = @invoice_1.transactions.create!(credit_card_number: "123123123", credit_card_expiration_date: "", result: 0)
    @transaction_3 = @invoice_2.transactions.create!(credit_card_number: "123123123", credit_card_expiration_date: "", result: 0)
    @transaction_4 = @invoice_2.transactions.create!(credit_card_number: "123123123", credit_card_expiration_date: "", result: 0)

    # @merch_1 total revenue = 3000, top selling date: @invoice_4.created_at = 1/15/20
    @invoice_item_1a = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 10, unit_price: 100, status: 2)
    @invoice_item_1c = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_3.id, quantity: 10, unit_price: 100, status: 2)
    @invoice_item_1b = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_4.id, quantity: 10, unit_price: 100, status: 2)
    @invoice_item_1d = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_2.id, quantity: 10, unit_price: 10, status: 2)
    # @merch_2 total revenue = 42, top selling date: @invoice_1.created_at = 1/1/20
    @invoice_item_2a = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 10, status: 2)
    @invoice_item_2c = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_3.id, quantity: 2, unit_price: 10, status: 2)
    @invoice_item_2d = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_4.id, quantity: 2, unit_price: 1, status: 2)
    @invoice_item_2b = InvoiceItem.create!(item_id: @item_4.id, invoice_id: @invoice_2.id, quantity: 2, unit_price: 10, status: 2)
    # @merch_3 total revenue = 4500, top selling date: @invoice_4.created_at = 1/15/20
    @invoice_item_3a = InvoiceItem.create!(item_id: @item_5.id, invoice_id: @invoice_1.id, quantity: 15, unit_price: 100, status: 2)
    @invoice_item_3c = InvoiceItem.create!(item_id: @item_5.id, invoice_id: @invoice_3.id, quantity: 15, unit_price: 100, status: 2)
    @invoice_item_3b = InvoiceItem.create!(item_id: @item_6.id, invoice_id: @invoice_4.id, quantity: 15, unit_price: 100, status: 2)
    @invoice_item_3d = InvoiceItem.create!(item_id: @item_5.id, invoice_id: @invoice_2.id, quantity: 15, unit_price: 10, status: 2)
    # @merch_4 total revenue = 240, top selling date: @invoice_3.created_at = 12/15/19
    @invoice_item_4a = InvoiceItem.create!(item_id: @item_7.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 10, status: 2)
    @invoice_item_4c = InvoiceItem.create!(item_id: @item_7.id, invoice_id: @invoice_3.id, quantity: 2, unit_price: 100, status: 2)
    @invoice_item_4d = InvoiceItem.create!(item_id: @item_7.id, invoice_id: @invoice_4.id, quantity: 2, unit_price: 10, status: 2)
    @invoice_item_4b = InvoiceItem.create!(item_id: @item_8.id, invoice_id: @invoice_2.id, quantity: 2, unit_price: 100, status: 2)
    # @merch_5 total revenue = 4200, top selling date: @invoice_1.created_at = 1/1/20
    @invoice_item_5a = InvoiceItem.create!(item_id: @item_9.id, invoice_id: @invoice_1.id, quantity: 20, unit_price: 100, status: 2)
    @invoice_item_5c = InvoiceItem.create!(item_id: @item_9.id, invoice_id: @invoice_3.id, quantity: 20, unit_price: 100, status: 2)
    @invoice_item_5d = InvoiceItem.create!(item_id: @item_9.id, invoice_id: @invoice_4.id, quantity: 20, unit_price: 10, status: 2)
    @invoice_item_5b = InvoiceItem.create!(item_id: @item_10.id, invoice_id: @invoice_2.id, quantity: 20, unit_price: 100, status: 2)
    # @merch_6 total revenue = 1050, top selling date: @invoice_1.created_at = 1/1/20
    @invoice_item_6a = InvoiceItem.create!(item_id: @item_11.id, invoice_id: @invoice_1.id, quantity: 5, unit_price: 100, status: 2)
    @invoice_item_6c = InvoiceItem.create!(item_id: @item_11.id, invoice_id: @invoice_3.id, quantity: 5, unit_price: 100, status: 2)
    @invoice_item_6d = InvoiceItem.create!(item_id: @item_11.id, invoice_id: @invoice_4.id, quantity: 5, unit_price: 10, status: 2)
    @invoice_item_6b = InvoiceItem.create!(item_id: @item_12.id, invoice_id: @invoice_2.id, quantity: 5, unit_price: 100, status: 2)
  end

  describe 'instance methods' do
    it '#render_status returns Enabled or Disabled based on boolean status' do
      expect(@merch_2.render_status[:status]).to eq("Enabled")
      expect(@merch_2.render_status[:action]).to eq("Disable")
      expect(@merch_3.render_status[:status]).to eq("Disabled")
      expect(@merch_3.render_status[:action]).to eq("Enable")
    end

    it '#toggle_status flips the status of a merchant' do
      expect(@merch_1.status).to eq(true)
      @merch_1.toggle_status
      expect(@merch_1.status).to eq(false)

      expect(@merch_3.status).to eq(false)
      @merch_3.toggle_status
      expect(@merch_3.status).to eq(true)
    end

    describe '#top_selling_date' do

      it 'returns the dates with most revenue for merchants' do
        merchants = Merchant.top_5_total_revenue

        expect(merchants.first.top_selling_date).to eq(@invoice_4.created_at)
        expect(merchants.second.top_selling_date).to eq(@invoice_1.created_at)
        expect(merchants.third.top_selling_date).to eq(@invoice_4.created_at)
        expect(merchants.fourth.top_selling_date).to eq(@invoice_1.created_at)
        expect(merchants.last.top_selling_date).to eq(@invoice_3.created_at)
      end
    end
  end

  describe 'class methods' do
    it '.enabled merchants returns merchantes with status = true' do
      expect(Merchant.enabled.count).to eq(4)
      expect(Merchant.enabled.first).to eq(@merch_1)
      expect(Merchant.enabled.last).to eq(@merch_5)
    end

    it '.disabled merchants returns merchantes with status = false' do
      expect(Merchant.disabled.count).to eq(2)
      expect(Merchant.disabled.first).to eq(@merch_3)
      expect(Merchant.disabled.last).to eq(@merch_6)
    end

    describe '.top_5_total_revenue' do
      it 'returns the top 5 merchants by total revenue generated' do
        output = Merchant.top_5_total_revenue
        expect(output.first.id).to eq(@merch_3.id)
        expect(output.second.id).to eq(@merch_5.id)
        expect(output.third.id).to eq(@merch_1.id)
        expect(output.fourth.id).to eq(@merch_6.id)
        expect(output.last.id).to eq(@merch_4.id)
      end

      it 'calculates total revenue as sum of all invoice items unit prices * quantity on invoices with at least 1 successful transaction' do
        output = Merchant.top_5_total_revenue
        expect(output.first.revenue).to eq(4500)
        expect(output.second.revenue).to eq(4200)
        expect(output.third.revenue).to eq(3000)
        expect(output.fourth.revenue).to eq(1050)
        expect(output.last.revenue).to eq(240)
      end
    end
  end

  describe 'instance methods' do
    it 'returns items & invoices for that merchant' do
      expect(@merch_1.items_of_merchant.pluck(@invoice_1.id)).to include(@invoice_1.id)
    end
  end
end

require 'rails_helper'

RSpec.describe 'admin/invoices/show.html.erb' do
  before :each do
    allow(GithubService).to receive(:contributors_info).and_return([
      {id: 26797256, name: 'Molly', contributions: 7},
      {id: 78388882, name: 'Sa', contributions: 80}
    ])
    allow(GithubService).to receive(:closed_pulls).and_return([
      {id: 0101010011, name: 'Molly', merged_at: 7},
      {id: 01011230011, name: 'Sa',merged_at: 80},
      {id: 01011230011, name: 'Sa', merged_at: nil}
    ])
    allow(GithubService).to receive(:repo_info).and_return({
        name: 'little-esty-shop'
    })
    @customer_1 = Customer.create!(first_name: 'Madi', last_name: 'Johnson')
    @invoice_1 = @customer_1.invoices.create!(status: 1, created_at: '2001-01-01')
    @merchant_1 = Merchant.create!(name: "Ralph's Monkey Hut")
    @merchant_2 = Merchant.create!(name: "Ralph's Monkey Hut 2")
    @item_1 = @merchant_1.items.create!(name: 'Pogs', description: 'Stack of pogs.', unit_price: 500)
    @item_2 = @merchant_1.items.create!(name: 'Frog statue', description: 'Statue of a frog', unit_price: 10000)
    @item_3 = @merchant_1.items.create!(name: 'Rabid Wolverine', description: 'No refunds', unit_price: 10)
    @item_4 = @merchant_2.items.create!(name: 'Rabid Wolverine2', description: 'No refunds2', unit_price: 101)
    @item_5 = @merchant_2.items.create!(name: 'Rabid Wolverine3', description: 'No refunds3', unit_price: 102)
    @discount_1 = @merchant_1.bulk_discounts.create!(percentage: 10, quantity_threshold: 2)
    @discount_2 = @merchant_1.bulk_discounts.create!(percentage: 20, quantity_threshold: 2)
    @discount_2 = @merchant_1.bulk_discounts.create!(percentage: 20, quantity_threshold: 2)
    @discount_3 = @merchant_1.bulk_discounts.create!(percentage: 25, quantity_threshold: 45)
    @discount_4 = @merchant_2.bulk_discounts.create!(percentage: 5, quantity_threshold: 5)
    @discount_5 = @merchant_2.bulk_discounts.create!(percentage: 10, quantity_threshold: 10)
    InvoiceItem.create!(quantity: 50, unit_price: 550, status: 0, item: @item_1, invoice: @invoice_1) #discount: 25% / total rev = 27,500 / disc rev = 20,625
    InvoiceItem.create!(quantity: 3, unit_price: 11500, status: 1, item: @item_2, invoice: @invoice_1) #discount: 20% / total rev = 34,500 / disc rev = 27,600
    InvoiceItem.create!(quantity: 1, unit_price: 16, status: 2, item: @item_3, invoice: @invoice_1) #discount: none / total rev = 16
    InvoiceItem.create!(quantity: 5, unit_price: 800, status: 2, item: @item_4, invoice: @invoice_1) #discount: 5% / total rev = 4,000 / disc rev = 3,800
    InvoiceItem.create!(quantity: 10, unit_price: 650, status: 2, item: @item_5, invoice: @invoice_1) #discount: 12% / total rev = 6500 / disc rev = 5,850

    visit "/admin/invoices/#{@invoice_1.id}"
  end

  describe 'visit' do
    it 'displays invoice data' do
      expect(page).to have_content(@invoice_1.id)
      expect(page).to have_content(@invoice_1.status)
      expect(page).to have_content('Monday, January 01, 2001')
    end
    it 'displays invoices customer name' do
      expect(page).to have_content(@customer_1.first_name)
      expect(page).to have_content(@customer_1.last_name)
    end
  end

  describe 'items on invoice' do
    it 'displays all of the items on the invoice' do
      expect(page).to have_content(@item_1.name)
      expect(page).to have_content(@item_2.name)
      expect(page).to have_content(@item_3.name)
      expect(page).to have_content('50')
      expect(page).to have_content('3')
      expect(page).to have_content('1')
      expect(page).to have_content('$5.50')
      expect(page).to have_content('$115.00')
      expect(page).to have_content('$0.16')
    end
  end

  describe 'total revenue' do
    it 'shows the total revenue the invoice will generate' do
      expect(page).to have_content('Total Revenue: $725.16')
    end
  end

  describe 'discounted revenue' do
    it 'shows the discounted revenue for the invoice' do
      expect(page).to have_content('Discounted Revenue: $578.91')
    end
  end
  
end

require 'rails_helper'

RSpec.describe 'Merchant Invoices Show Page' do
  describe 'show page' do
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

      @merchant = Merchant.create!(name: 'Schroeder-Jerde')
      @merchant_2 = Merchant.create!(name: 'James Bond')

      @customer_1 = Customer.create!(first_name: 'Sally', last_name: 'Shopper')
      @customer_2 = Customer.create!(first_name: 'Du', last_name: 'North')

      # my items
      @item_1 = @merchant.items.create!(name: 'Gold Ring', description: 'Jewelery', unit_price: 10000)
      @item_4 = @merchant.items.create!(name: 'Hair Clip', description: 'Accessories', unit_price: 200)
      @item_2 = @merchant.items.create!(name: 'Silver Ring', description: 'Jewelery', unit_price: 5000)
      @item_3 = @merchant.items.create!(name: 'Hoop Earrings', description: 'Jewelery', unit_price: 1000)

      # other merchant items
      @item_5 = @merchant_2.items.create!(name: 'Silver Bracelet', description: 'Accessories', unit_price: 3000)
      @item_6 = @merchant_2.items.create!(name: 'Bronze Ring', description: 'Jewelery', unit_price: 2000)

      @invoice_1 = @customer_1.invoices.create!(status: 1, created_at: "2012-03-06 14:54:15 UTC")
      @invoice_2 = @customer_2.invoices.create!(status: 1, created_at: "2012-03-09 14:54:15 UTC")

      # items for invoice 1
      @invoice_item_1 = InvoiceItem.create!(quantity: 2, unit_price: 10000, item_id: @item_1.id, invoice_id: @invoice_1.id, status: 1) # $200
      @invoice_item_2 = InvoiceItem.create!(quantity: 2, unit_price: 5000, item_id: @item_2.id, invoice_id: @invoice_1.id, status: 1) # $100
      @invoice_item_3 = InvoiceItem.create!(quantity: 2, unit_price: 1000, item_id: @item_3.id, invoice_id: @invoice_1.id, status: 1) # $20
      @invoice_item_5 = InvoiceItem.create!(quantity: 2, unit_price: 3000, item_id: @item_5.id, invoice_id: @invoice_1.id, status: 1) # Other merchant rev
      @invoice_item_6 = InvoiceItem.create!(quantity: 2, unit_price: 2000, item_id: @item_6.id, invoice_id: @invoice_1.id, status: 2) # Other merchant rev

      # item for different invoice
      @invoice_item_4 = InvoiceItem.create!(quantity: 2, unit_price: 200, item_id: @item_4.id, invoice_id: @invoice_2.id, status: 1) # should not be counted on invoice 1

      visit "/merchants/#{@merchant.id}/invoices/#{@invoice_1.id}"
    end

    it 'can see all of that merchants invoice info' do
      expect(page).to have_content(@invoice_1.id)
      expect(page).to have_select('invoice_item[status]', selected: "Packaged")
      expect(page).to have_content(@invoice_1.created_at.strftime('%A, %B %d, %Y'))
      expect(page).to have_content(@customer_1.first_name)
      expect(page).to have_content(@customer_1.last_name)
    end

    it 'can see all of that merchants invoice item info' do
      expect(page).to have_content(@item_1.name)
      expect(page).to have_content(@invoice_item_1.quantity)
      expect(page).to have_content('$100.00')
      expect(page).to have_select('invoice_item[status]', selected: "Packaged")
      expect(page).to_not have_content(@item_5.name)
    end

    it 'displays the total revenue generated from all of my items on the invoice' do
      expect(page).to have_content 'Total revenue: $320.00'
    end

    it 'can update an invoice item status' do
      within "tr#ii-#{@invoice_item_1.id}" do
        expect(page).to have_select('invoice_item[status]', selected: "Packaged")

        select 'Shipped', from: 'invoice_item[status]'
        click_button 'Update'
      end

      expect(current_path).to eq "/merchants/#{@merchant.id}/invoices/#{@invoice_1.id}"

      within "tr#ii-#{@invoice_item_1.id}" do
        expect(page).to have_select('invoice_item[status]', selected: "Shipped")
      end
    end
  end
end

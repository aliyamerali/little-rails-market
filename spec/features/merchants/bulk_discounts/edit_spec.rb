require 'rails_helper'

RSpec.describe 'Merchant\'s Bulk Discount edit', type: :feature do
  before :each do
    @merchant = Merchant.create!(name: 'Sal\'s Signs')
    @discount_1 = @merchant.bulk_discounts.create!(percentage: 10.0, quantity_threshold: 10)
    @discount_2 = @merchant.bulk_discounts.create!(percentage: 5.0, quantity_threshold: 5)

    @customer_1 = Customer.create!(first_name: 'Sally', last_name: 'Shopper')

    @item_1 = @merchant.items.create!(name: 'Gold Ring', description: 'Jewelery', unit_price: 10000)
    @item_2 = @merchant.items.create!(name: 'Silver Ring', description: 'Jewelery', unit_price: 10000)

    @invoice_1 = @customer_1.invoices.create!(status: 1, created_at: "2012-03-06 14:54:15 UTC")
    @invoice_2 = @customer_1.invoices.create!(status: 0, created_at: "2012-03-06 14:54:15 UTC")

    @invoice_item_1 = InvoiceItem.create!(quantity: 10, unit_price: 10000, item_id: @item_1.id, invoice_id: @invoice_1.id, status: 1)
    @invoice_item_2 = InvoiceItem.create!(quantity: 5, unit_price: 5000, item_id: @item_2.id, invoice_id: @invoice_2.id, status: 1)

    visit edit_merchant_bulk_discount_path(@merchant.id, @discount_1.id)
  end

  it 'has the discounts current attributes pre-populated in the fields' do
    expect(page).to have_field("Percentage", with: 10.0)
    expect(page).to have_field("Quantity Threshold", with: 10)
    expect(page).to have_button("Update Bulk discount")
  end

  it 'shows error message if required information is missing on submit' do
    fill_in "Percentage", with: ''
    click_button "Update Bulk discount"

    expect(page).to have_current_path(edit_merchant_bulk_discount_path(@merchant.id, @discount_1.id))
    expect(page).to have_content "Error: Percentage can't be blank"
  end

  it 'shows an error if the discount is applied to any pending invoice' do
    visit edit_merchant_bulk_discount_path(@merchant.id, @discount_2.id)

    fill_in "Percentage", with: 12.5
    fill_in "Quantity Threshold", with: 25
    click_button "Update Bulk discount"

    expect(page).to have_current_path(edit_merchant_bulk_discount_path(@merchant.id, @discount_2.id))
    expect(page).to have_content("Error: Cannot update discount while it applies to in-progress invoices")
  end

  it 'upon valid submit, redirects to show page, shows updated attributes' do
    fill_in "Percentage", with: 12.5
    fill_in "Quantity Threshold", with: 25
    click_button "Update Bulk discount"

    expect(page).to have_current_path( "/merchants/#{@merchant.id}/bulk_discounts/#{@discount_1.id}")
    expect(page).to have_content("Percentage: 12.5%")
    expect(page).to have_content("Quantity Threshold: 25")
    expect(page).to_not have_content("Percentage: 20.0%")
    expect(page).to_not have_content("Quantity Threshold: 20")
  end
end

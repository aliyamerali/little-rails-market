require 'rails_helper'

RSpec.describe 'Merchant\'s Bulk Discount show', type: :feature do
  before :each do
    @merchant = Merchant.create!(name: "Sassy Spoons")
    @discount = @merchant.bulk_discounts.create!(percentage: 20.0, quantity_threshold: 20)

    visit merchant_bulk_discount_path(@merchant.id, @discount.id)
  end

  it 'shows discount quantity threshold and percentage' do
    expect(page).to have_content(@discount.percentage)
    expect(page).to have_content(@discount.quantity_threshold)
  end

  it 'has a link to edit the bulk discount' do
    page.find_button("Edit Discount")[edit_merchant_bulk_discount_path(@merchant.id, @discount.id)]
    click_button("Edit Discount")
    expect(page).to have_current_path(edit_merchant_bulk_discount_path(@merchant.id, @discount.id))
  end

end

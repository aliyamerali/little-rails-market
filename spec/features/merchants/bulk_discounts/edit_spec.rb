require 'rails_helper'

RSpec.describe 'Merchant\'s Bulk Discount edit', type: :feature do
  before :each do
    @merchant = FactoryBot.create(:merchant)
    @discount = @merchant.bulk_discounts.create!(percentage: 20.0, quantity_threshold: 20)

    visit edit_merchant_bulk_discount_path(@merchant.id, @discount.id)
  end

  it 'has the discounts current attributes pre-populated in the fields' do
    expect(page).to have_field("Percentage", with: 20.0)
    expect(page).to have_field("Quantity Threshold", with: 20)
    expect(page).to have_button("Update Bulk discount")
  end

  it 'shows error message if required information is missing on submit' do
    fill_in "Percentage", with: ''
    click_button "Update Bulk discount"

    expect(page).to have_current_path(edit_merchant_bulk_discount_path(@merchant.id, @discount.id))
    expect(page).to have_content "Error: Percentage can't be blank"
  end

  it 'upon valid submit, redirects to show page, shows updated attributes' do
    fill_in "Percentage", with: 12.5
    fill_in "Quantity Threshold", with: 25
    click_button "Update Bulk discount"

    expect(page).to have_current_path( "/merchants/#{@merchant.id}/bulk_discounts/#{@discount.id}")
    expect(page).to have_content("Percentage: 12.5%")
    expect(page).to have_content("Quantity Threshold: 25")
    expect(page).to_not have_content("Percentage: 20.0%")
    expect(page).to_not have_content("Quantity Threshold: 20")
  end
end

require 'rails_helper'

RSpec.describe 'Bulk Discount create', type: :feature do
  before :each do
    @merchant1 = FactoryBot.create(:merchant)
    @merchant2 = FactoryBot.create(:merchant)

    visit new_merchant_bulk_discount_path(@merchant1.id)
  end

  it 'shows a form to create a new discount' do
    expect(page).to have_field("Percentage")
    expect(page).to have_field("Quantity Threshold")
    expect(page).to have_button("Create Bulk discount")
  end

  it 'upon submission, creates a new discount for the merchant' do
    fill_in "Percentage", with: 12.5
    fill_in "Quantity Threshold", with: 25
    click_button "Create Bulk discount"

    expect(@merchant1.bulk_discounts.last.percentage).to eq(12.5)
    expect(@merchant1.bulk_discounts.last.quantity_threshold).to eq(25)
  end

  it 'shows an error message if a field is missing' do
    fill_in "Percentage", with: 12.5
    click_button "Create Bulk discount"

    expect(page).to have_current_path(new_merchant_bulk_discount_path(@merchant1.id))
    expect(page).to have_content "Error: Quantity threshold can't be blank"
  end

  it 'redirects to the merchants discount index, showing new discount' do
    fill_in "Percentage", with: 15.5
    fill_in "Quantity Threshold", with: 15
    click_button "Create Bulk discount"

    new_discount = @merchant1.bulk_discounts.last

    expect(page).to have_current_path(merchant_bulk_discounts_path(@merchant1.id))
    within("#discount-#{new_discount.id}") do
      expect(page).to have_content(new_discount.percentage)
      expect(page).to have_content(new_discount.quantity_threshold)
      page.find_link(new_discount.id)[merchant_bulk_discount_path(@merchant1.id, new_discount.id)]
    end
  end

  it 'does not add the discount to any other merchant' do
    fill_in "Percentage", with: 15.5
    fill_in "Quantity Threshold", with: 15
    click_button "Create Bulk discount"

    new_discount = @merchant1.bulk_discounts.last

    visit new_merchant_bulk_discount_path(@merchant2.id)

    expect(page).not_to have_selector("#discount-#{new_discount.id}")
  end
end

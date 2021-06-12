require 'rails_helper'

RSpec.describe 'Merchant\'s Bulk Discount index', type: :feature do
  before :each do
    @merchant1 = FactoryBot.create(:merchant)
    @discount1 = @merchant1.bulk_discounts.create!(percentage: 20.0, quantity_threshold: 20)
    @discount2 = @merchant1.bulk_discounts.create!(percentage: 5.0, quantity_threshold: 10)
    @discount3 = @merchant1.bulk_discounts.create!(percentage: 3.5, quantity_threshold: 5)

    @merchant2 = FactoryBot.create(:merchant)
    @discount4 = @merchant2.bulk_discounts.create!(percentage: 15, quantity_threshold: 15)

    visit "/merchants/#{@merchant1.id}/bulk_discounts"
  end

  it 'shows all of my bulk discount %s and quantity thresholds' do
    within("#discount-#{@discount1.id}") do
      expect(page).to have_content(@discount1.percentage)
      expect(page).to have_content(@discount1.quantity_threshold)
    end
    within("#discount-#{@discount2.id}") do
      expect(page).to have_content(@discount2.percentage)
      expect(page).to have_content(@discount2.quantity_threshold)
    end
    within("#discount-#{@discount3.id}") do
      expect(page).to have_content(@discount3.percentage)
      expect(page).to have_content(@discount3.quantity_threshold)
    end
    expect(page).not_to have_selector("#discount-#{@discount4.id}")
  end

  it 'links to the show page of each bulk discount' do
    page.find_link(@discount1.id)[merchant_bulk_discount_path(@merchant1.id, @discount1.id)]
    page.find_link(@discount2.id)[merchant_bulk_discount_path(@merchant1.id, @discount2.id)]
    page.find_link(@discount3.id)[merchant_bulk_discount_path(@merchant1.id, @discount3.id)]
  end

  it 'shows a link to create a new discount' do
    page.find_link("New Discount")[new_merchant_bulk_discount_path(@merchant1.id)]
  end
end

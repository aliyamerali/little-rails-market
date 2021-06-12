require 'rails_helper'

RSpec.describe 'Merchant\'s Bulk Discount index', type: :feature do
  before :each do
    @merchant1 = FactoryBot.create(:merchant)
    @discount1 = @merchant1.bulkdiscounts.create!(percentage: 20.0, quantity_threshold: 20)
    @discount2 = @merchant1.bulkdiscounts.create!(percentage: 5.0, quantity_threshold: 10)
    @discount3 = @merchant1.bulkdiscounts.create!(percentage: 3.5, quantity_threshold: 5)

    @merchant2 = FactoryBot.create(:merchant)
    @discount4 = @merchant2.bulkdiscounts.create!(percentage: 15, quantity_threshold: 15)
  end

  it 'shows all of my bulk discount %s and quantity thresholds' do
    expect(page).to have_content(@discount1.percentage)
    expect(page).to have_content(@discount1.quantity_threshold)
    expect(page).to have_content(@discount2.percentage)
    expect(page).to have_content(@discount2.quantity_threshold)
    expect(page).to have_content(@discount3.percentage)
    expect(page).to have_content(@discount3.quantity_threshold)
    expect(page).to_not have_content(@discount4.percentage)
    expect(page).to_not have_content(@discount4.quantity_threshold)
  end

  it 'links to the show page of each bulk discount' do
    expect(page).to have_link(@discount1.id, :href => "merchants/#{@merchant1.id}/bulk_discounts/#{@discount1.id}")
  end
end

require 'rails_helper'

RSpec.describe 'Bulk Discount create', type: :feature do
  before :each do
    @merchant1 = FactoryBot.create(:merchant)
    @merchant2 = FactoryBot.create(:merchant)

    visit new_merchant_bulk_discount_path(@merchant.id)
  end

  it 'shows a form to create a new discount' do
    expect(page).to have_field("Percentage")
    expect(page).to have_field("Quantity Threshold")
  end

  it 'upon submission, creates a new discount for the merchant' 

  it 'redirects to the merchants discount index, showing new discount'

  it 'does not add the discount to any other merchant'

end

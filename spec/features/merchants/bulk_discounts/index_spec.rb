require 'rails_helper'

RSpec.describe 'Merchant\'s Bulk Discount index', type: :feature do
  before :each do
    allow(HolidayService).to receive(:upcoming_holiday_info).and_return(
      [{:date=>"2021-07-05", :localName=>"Independence Day", :name=>"Independence Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
        {:date=>"2021-09-06", :localName=>"Labor Day", :name=>"Labour Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
        {:date=>"2021-11-11", :localName=>"Veterans Day", :name=>"Veterans Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
        {:date=>"2021-11-25", :localName=>"Thanksgiving Day", :name=>"Thanksgiving Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>1863, :type=>"Public"},
        ])

    @merchant1 = Merchant.create!(name: "Sassy Spoons")
    @discount1 = @merchant1.bulk_discounts.create!(percentage: 20.0, quantity_threshold: 20)
    @discount2 = @merchant1.bulk_discounts.create!(percentage: 5.0, quantity_threshold: 10)
    @discount3 = @merchant1.bulk_discounts.create!(percentage: 3.5, quantity_threshold: 5)

    @customer_1 = Customer.create!(first_name: 'Sally', last_name: 'Shopper')

    @item_1 = @merchant1.items.create!(name: 'Gold Ring', description: 'Jewelery', unit_price: 10000)
    @item_2 = @merchant1.items.create!(name: 'Silver Ring', description: 'Jewelery', unit_price: 10000)

    @invoice_1 = @customer_1.invoices.create!(status: 1, created_at: "2012-03-06 14:54:15 UTC")
    @invoice_2 = @customer_1.invoices.create!(status: 0, created_at: "2012-03-06 14:54:15 UTC")

    @invoice_item_1 = InvoiceItem.create!(quantity: 10, unit_price: 10000, item_id: @item_1.id, invoice_id: @invoice_1.id, status: 1)
    @invoice_item_2 = InvoiceItem.create!(quantity: 5, unit_price: 5000, item_id: @item_2.id, invoice_id: @invoice_2.id, status: 1)

    @merchant2 = Merchant.create!(name: "Tees by Tom")
    @discount4 = @merchant2.bulk_discounts.create!(percentage: 15, quantity_threshold: 15)

    visit "/merchants/#{@merchant1.id}/bulk_discounts"
  end

  it 'shows the next three holidays upcoming' do
    within("#upcoming-holidays") do
      expect(page).to have_content("Upcoming Holidays")
      expect(page).to have_content("2021-07-05")
      expect(page).to have_content("Independence Day")
      expect(page).to have_content("2021-09-06")
      expect(page).to have_content("Labour Day")
      expect(page).to have_content("2021-11-11")
      expect(page).to have_content("Veterans Day")
    end
  end

  it 'shows a link to create a new discount' do
    page.find_link("New Discount")[new_merchant_bulk_discount_path(@merchant1.id)]
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

  it 'shows a link to delete each bulk discount' do
    page.find_link("Delete Discount ##{@discount1.id}")["/merchants/#{@merchant1.id}/bulk_discounts/#{@discount1.id}"]
  end

  it 'deletes the bulk discount when delete link is clicked' do
    click_link "Delete Discount ##{@discount1.id}"

    expect(page).not_to have_selector("#discount-#{@discount1.id}")

    within("#discount-#{@discount2.id}") do
      expect(page).to have_content(@discount2.percentage)
      expect(page).to have_content(@discount2.quantity_threshold)
    end
    within("#discount-#{@discount3.id}") do
      expect(page).to have_content(@discount3.percentage)
      expect(page).to have_content(@discount3.quantity_threshold)
    end
  end

  it 'shows an error if delete is attempted on discount applied to items on in-progress invoices' do
    click_link "Delete Discount ##{@discount3.id}"

    expect(page).to have_content("Error: Cannot update discount while it applies to in-progress invoices")

    within("#discount-#{@discount2.id}") do
      expect(page).to have_content(@discount2.percentage)
      expect(page).to have_content(@discount2.quantity_threshold)
    end
    within("#discount-#{@discount3.id}") do
      expect(page).to have_content(@discount3.percentage)
      expect(page).to have_content(@discount3.quantity_threshold)
    end
  end

end

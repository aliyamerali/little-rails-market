require 'rails_helper'

RSpec.describe GithubService do
  describe 'class methods' do
    describe '#upcoming_holiday_info' do
      it 'returns a collection of upcoming holidays' do
        holidays = HolidayService.upcoming_holiday_info
        # binding.pry

        expect(holidays[0][:countryCode]).to eq("US")
        expect(holidays[0][:type]).to eq("Public")
        expect(holidays[0]).to have_key(:date)
        expect(holidays[0]).to have_key(:localName)
        expect(holidays[0]).to have_key(:name)
        expect(holidays[0]).to have_key(:countryCode)
        expect(holidays[0]).to have_key(:fixed)
        expect(holidays[0]).to have_key(:global)
        expect(holidays[0]).to have_key(:counties)
        expect(holidays[0]).to have_key(:launchYear)
      end
    end
  end
end

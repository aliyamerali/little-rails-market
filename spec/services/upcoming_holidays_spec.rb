require 'rails_helper'

RSpec.describe UpcomingHolidays do
  describe '.next_three_holidays' do
    it 'returns the name and date of the next three holidays' do
      allow(HolidayService).to receive(:upcoming_holiday_info).and_return(
        [
         {:date=>"2021-07-05", :localName=>"Independence Day", :name=>"Independence Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
         {:date=>"2021-09-06", :localName=>"Labor Day", :name=>"Labour Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
         {:date=>"2021-11-11", :localName=>"Veterans Day", :name=>"Veterans Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
         {:date=>"2021-11-25", :localName=>"Thanksgiving Day", :name=>"Thanksgiving Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>1863, :type=>"Public"},
         {:date=>"2021-12-24", :localName=>"Christmas Day", :name=>"Christmas Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
         {:date=>"2021-12-31", :localName=>"New Year's Day", :name=>"New Year's Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
         {:date=>"2022-02-21", :localName=>"Presidents Day", :name=>"Washington's Birthday", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
         {:date=>"2022-05-30", :localName=>"Memorial Day", :name=>"Memorial Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"}
       ])

      expect(UpcomingHolidays.next_three_holidays.first[:name]).to eq("Independence Day")
      expect(UpcomingHolidays.next_three_holidays.first[:date]).to eq("2021-07-05")
      expect(UpcomingHolidays.next_three_holidays.second[:name]).to eq("Labour Day")
      expect(UpcomingHolidays.next_three_holidays.second[:date]).to eq("2021-09-06")
      expect(UpcomingHolidays.next_three_holidays.last[:name]).to eq("Veterans Day")
      expect(UpcomingHolidays.next_three_holidays.last[:date]).to eq("2021-11-11")
    end
  end
end

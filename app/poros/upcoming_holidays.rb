class UpcomingHolidays

  def self.next_three_holidays
    holidays = HolidayService.upcoming_holiday_info
    [{name: holidays.first[:name], date: holidays.first[:date]},
    {name: holidays.second[:name], date: holidays.second[:date]},
    {name: holidays.third[:name], date: holidays.third[:date]}
    ]
  end

end

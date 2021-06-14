class HolidayService

  def self.upcoming_holiday_info
    response = Faraday.get "https://date.nager.at/api/v2/NextPublicHolidays/US"

    body = response.body
    JSON.parse(body, symbolize_names: true)
  end
end

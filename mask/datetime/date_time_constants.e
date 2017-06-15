note
	description: "Summary description for {DATE_TIME_CONSTANTS}."
	date: "$Date: 2015-12-03 15:44:02 -0500 (Thu, 03 Dec 2015) $"
	revision: "$Revision: 12794 $"

class
	DATE_TIME_CONSTANTS

feature -- Access

	date_separator: CHARACTER_32 = '/'

	date_separator_string: STRING_32 = "/"

	days_in_months: ARRAY [INTEGER]
			-- Array containing number of days for each month of a leap year.
		once
			Result := <<31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31>>
		ensure
			result_exists: Result /= Void
			valid_count: Result.count = 12
		end

	format_month_day: INTEGER = 1
	format_month_day_year: INTEGER = 2
	format_year_month_day: INTEGER = 3

end

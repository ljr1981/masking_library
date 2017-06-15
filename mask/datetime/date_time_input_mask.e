note
	description: "[
			An Date Input Mask is an {ABSTRACT_DATE_TIME_INPUT_MASK} specialized to only allow date input.
			]"
	purpose: "[			
			Some fields need to permit only Year, Month and Day input.
			Defines fields: Year, Month and Day
			Handles mask apply/remove to DATE_TIME
			]"
	how: "[
			See {ABSTRACT_DATE_TIME_INPUT_MASK}.
			]"
	date: "$Date: 2015-12-19 10:26:15 -0500 (Sat, 19 Dec 2015) $"
	revision: "$Revision: 12868 $"

class
	DATE_TIME_INPUT_MASK

inherit
--	ABSTRACT_DATE_TIME_INPUT_MASK [detachable DATE_TIME, DATE_TIME_COLUMN_METADATA]
--| FIXME Test won't allow above, why?
	ABSTRACT_DATE_TIME_INPUT_MASK [DATE_TIME, DATE_TIME_COLUMN_METADATA]
		redefine
			remove_implementation
		end

create
	make_month_day_year, make_year_month_day

feature {NONE} -- Initialization

	make_month_day_year
			-- Make and initialize `Current' for date masking in format MM/DD/YYYY.
		do
			format := (create {DATE_TIME_CONSTANTS}).format_month_day_year
		ensure
			format_month_day_year_set: format = (create {DATE_TIME_CONSTANTS}).format_month_day_year
		end

	make_year_month_day
			-- Make and initialize `Current' for date masking in format YYYY/MM/DD.
		do
			format := (create {DATE_TIME_CONSTANTS}).format_year_month_day
		ensure
			format_year_month_day_set: format = (create {DATE_TIME_CONSTANTS}).format_year_month_day
		end

feature -- Access

	default_value: DATE_TIME	-- FIXME detachable
			-- <Precursor>
		do
			Result := default_date_time
		end

feature -- Basic Operations

	apply_empty: TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			-- Mask `empty_date_string' as `masked_string'.
			-- Provide `error_message' if `a_value' does not conform to mask specification or is invalid.
			-- Empty `error_message' indicates `a_value' conforms to mask specification and is fully valid
			--| DATA_CONSTRAINT is not checked. `a_value' will come from the database and will "fit" automatically.
		require
			not_is_invalid: not is_invalid
		do
			Result := apply_implementation (empty_date_string)
		end

feature {TEST_SET_BRIDGE} -- Implementation

	string_to_value (a_string: READABLE_STRING_GENERAL): like default_value
			-- <Precursor>
		local
			l_date_time: DATE_TIME
			l_date_time_string: STRING_8
		do
			create l_date_time.make_now
			l_date_time_string := a_string.as_string_8
			l_date_time_string.extend (' ')
			l_date_time_string.append (default_time_string)
			if not l_date_time.date_time_valid (l_date_time_string, date_and_time_format_string) then
					-- We are not a valid string so we set to default invalid date and time strings.
				l_date_time_string := default_invalid_date_time_string
			end

			create Result.make_from_string (l_date_time_string, date_and_time_format_string)
		end

	value_to_string (a_value: like default_value): READABLE_STRING_GENERAL
			-- String representation of `a_value
		local
			l_string_8: STRING_8
		do
			l_string_8 := a_value.formatted_out (date_format_string)
			Result := l_string_8
		end

	remove_implementation (a_string: STRING_32; a_constraint: detachable DATE_TIME_COLUMN_METADATA): TUPLE [value: DATE_TIME; error_message: STRING_32]
			-- <Precursor>
		local
			l_string, l_error_message: STRING_32
			l_value: DATE_TIME
			l_invalid_date_time, l_has_invalid_characters: BOOLEAN
		do
				-- No Precursor
			l_string := a_string
			l_value := string_to_value (l_string)

				-- FIXME Update to handle datetime values as well.
			if value_to_string (l_value).same_string (default_invalid_date_string) then
				l_invalid_date_time := True
			else
				across a_string as ic_items loop
					if not is_valid_character_for_mask (ic_items.item) then
						l_has_invalid_characters := True
					end
				end
			end

			if l_invalid_date_time then
				l_error_message := translated_string (masking_messages.invalid_date_sentence, [])
			elseif l_has_invalid_characters then
				l_error_message := translated_string (masking_messages.invalid_changes_message, [])
			else
				l_error_message := ""
			end
			Result := [l_value, l_error_message]
		end

	empty_date_string: STRING
		-- Empty date string for blank fields.
		-- TODO Update this to deal with varying date formats.
		-- For example, the format_year_month_day might use '-' instead of '/' for separation.
		do
			Result := "//"
		ensure
			valid_result: Result.same_string ("//")
		end


	default_date_time: DATE_TIME
			-- Default date helper object.
		once
			create Result.make_from_string (default_date_and_time_string, date_and_time_format_string)
		end

	default_date_string: STRING = "12/31/9999"
		-- Default date string used for creation of a default date.

	default_invalid_date_string: STRING = "1/1/0000"
		-- Invalid date string used when a masking operation involving dates has failed.

	default_time_string: STRING = "12:00:00 AM"
		-- Default time string used for creation of a default time.

	default_invalid_date_time_string: STRING = "1/1/0000 12:00:00 AM"
		-- Invalid datetime string used when a masking operation involving datetimes has failed.

	default_date_and_time_string: STRING
			-- Default date and time string used for creation of a default datetime.
		once
			create Result.make (22)
			Result.append (default_date_string)
			Result.extend (' ')
			Result.append (default_time_string)
		end

	date_format_string: STRING = "mm/dd/yyyy"
		-- Format string used for initializing date objects.

	time_format_string: STRING = "[0]hh12:[0]mi:[0]ss AM"
		-- Format string used for initialize time objects.

	date_and_time_format_string: STRING
			-- Default format string used for date and time masks.
		once
			create Result.make (40)
			Result.append (date_format_string)
			Result.extend (' ')
			Result.append (time_format_string)
		end

end

note
	description: "[
			An Month Day Input Mask is an {ABSTRACT_DATE_TIME_INPUT_MASK} specialized to only allow MM/DD input.
			]"
	purpose: "[			
			Some fields need to permit only MM/DD input.
			Defines fields: Month and Day
			Handles mask apply/remove to STRING
			]"
	how: "[
			See {ABSTRACT_DATE_TIME_INPUT_MASK}.
			]"
	date: "$Date: 2015-12-03 15:44:02 -0500 (Thu, 03 Dec 2015) $"
	revision: "$Revision: 12794 $"

class
	MONTH_DAY_INPUT_MASK

inherit
	ABSTRACT_DATE_TIME_INPUT_MASK [READABLE_STRING_GENERAL, STRING_COLUMN_METADATA]

create
	make

feature {NONE} -- Initialization

	make
			-- Make and initialize `Current' for MM/DD masking.
		do
			format := (create {DATE_TIME_CONSTANTS}).format_month_day
		ensure
			format_month_day_set: format = (create {DATE_TIME_CONSTANTS}).format_month_day
		end

feature -- Access

	default_value: READABLE_STRING_GENERAL
			-- <Precursor>
		do
			Result := separator_string
		end

feature {TEST_SET_BRIDGE} -- Implementation

	string_to_value (a_string: READABLE_STRING_GENERAL): like default_value
			-- <Precursor>
		local
			l_fields: LIST [STRING_32]
			l_string: READABLE_STRING_GENERAL
			l_item, l_result: STRING_32
		do
			l_string := a_string.twin
			create l_result.make_empty
			if not l_string.has (date_separator) then
				if l_string.is_empty then
					l_string := "/"
				else
					--| FIXME: Add case handling
				end
			end
			l_fields := l_string.as_string_32.split (date_separator)
			across l_fields as ic_field loop
				l_item := ic_field.item
				if l_item.is_empty then
					l_item.prepend ("00")
				elseif l_item.count = 1 then
					l_item.prepend ("0")
				end
				l_result.append (l_item)
			end
			Result := l_result
		end

	value_to_string (a_value: like default_value): READABLE_STRING_GENERAL
			-- String representation of `a_value
		local
			l_widget: EV_TEXT
		do
			create l_widget.make_with_text (default_value)
			insert_string (l_widget, a_value.as_string_32)
			Result := l_widget.text.twin
		end

end

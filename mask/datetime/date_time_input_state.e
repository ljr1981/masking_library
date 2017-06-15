note
	description: "Summary description for {DATE_TIME_INPUT_STATE}."
	date: "$Date: 2015-12-19 10:26:15 -0500 (Sat, 19 Dec 2015) $"
	revision: "$Revision: 12868 $"

class
	DATE_TIME_INPUT_STATE

inherit
	DATE_TIME_CONSTANTS

create
	make

feature {NONE} -- Initialization

	make (a_widget: EV_TEXT_COMPONENT; a_format: INTEGER; a_modifiers: TUPLE [is_shift_pressed, is_control_pressed, is_alt_pressed: BOOLEAN])
			-- Make and initialize with `a_widget', `a_format', and `a_modifiers'.
		require
			is_valid_format: is_valid_format (a_format)
		do
			widget := a_widget
			format := a_format
			year_field := ""
			month_field := ""
			day_field := ""
			modifiers := a_modifiers
		ensure
			widget_set: widget = a_widget
			format_set: format = a_format
			modifiers_set: modifiers = a_modifiers
		end

feature -- Access

	widget: EV_TEXT_COMPONENT

	format: INTEGER

	widget_caret_position: INTEGER

	separator_index_1,
	separator_index_2: INTEGER

	year_field_caret_position,
	month_field_caret_position,
	day_field_caret_position: INTEGER

	year_field,
	month_field,
	day_field: STRING_32

	combined_fields: STRING_32
			-- Combined fields plus separators based on `format'.
		do
			inspect
				format
			when format_month_day then
				Result := month_field.twin
				Result.append_character (date_separator.twin)
				Result.append (day_field.twin)
			when format_month_day_year then
				Result := month_field.twin
				Result.append_character (date_separator.twin)
				Result.append (day_field.twin)
				Result.append_character (date_separator.twin)
				Result.append (year_field.twin)
			when format_year_month_day then
				Result := year_field.twin
				Result.append_character (date_separator.twin)
				Result.append (month_field.twin)
				Result.append_character (date_separator.twin)
				Result.append (day_field.twin)
			else
				-- TODO handle error condition
				check combined_fields_error_condition: False end
				Result := ""
			end
		end

	modifiers: TUPLE [is_shift_pressed, is_control_pressed, is_alt_pressed: BOOLEAN]

feature -- Status report

	is_valid_format (a_format: INTEGER): BOOLEAN
			-- Is `a_format' a valid format, see {DATE_TIME_CONSTANT} for formats.
		do
			Result := a_format = format_month_day
					or a_format = format_month_day_year
					or a_format = format_year_month_day
		ensure
			valid_result: Result = (a_format = format_month_day)
								or (a_format = format_month_day_year)
								or (a_format = format_year_month_day)
		end

	is_slash_navigation_character (a_character: CHARACTER_32): BOOLEAN
			-- Is `a_character' a slash navigation character?
		do
			Result := a_character.is_equal (date_separator)
		ensure
			valid_result: Result = a_character.is_equal (date_separator)
		end

	does_string_contain_only_navigation_characters (a_string: STRING_32): BOOLEAN
			-- Does `a_string' contain one or more `date_separator' characters only?
		do
			Result := not a_string.is_empty and (a_string.occurrences (date_separator) = a_string.count)
		ensure
			valid_result: Result = not a_string.is_empty implies (a_string.occurrences (date_separator) = a_string.count)
		end

	is_valid_field (a_field: STRING_32): BOOLEAN
			-- Is `a_field' a valid virtual field for Current?
		do
			Result := (a_field = year_field) or (a_field = month_field) or (a_field = day_field)
		ensure
			valid_result: Result = (a_field = year_field) or (a_field = month_field) or (a_field = day_field)
		end

	is_valid_month (a_month: INTEGER): BOOLEAN
			-- Is `a_month' a valid month?
		do
			Result := 0 <= a_month and a_month <= 12
		ensure
			valid_result: Result = (0 <= a_month and a_month <= 12)
		end

	is_valid_day_for_month (a_day, a_month: INTEGER): BOOLEAN
			-- Is `a_day' a valid day for `a_month'?
		require
			valid_month: is_valid_month (a_month)
		local
			l_days: INTEGER
		do
			if a_month = 0 then
				l_days := days_in_months.item (1)
			else
				l_days := days_in_months.item (a_month)
			end
			Result := 1 <= a_day and a_day <= l_days
--		ensure
--			valid_result: Result = (1 <= a_day and a_day <= l_days)
		end

	is_valid_day_for_current_month (a_day: INTEGER): BOOLEAN
			-- Is `a_day' a valid day for `month_field'?
		local
			l_range_begin, l_range_end: INTEGER
		do
			if month_field.is_empty or (month_field.is_integer and then month_field.to_integer = 0) then
				l_range_begin := 0
				l_range_end := days_in_months.item (1)
			else
				l_range_begin := 1
				l_range_end := days_in_months.item (month_field.to_integer)
			end
			Result := l_range_begin <= a_day and a_day <= l_range_end
--		ensure
--			valid_result: Result = (1 <= a_day and a_day <= l_days)
		end

	is_february_29th: BOOLEAN
			-- Is month and date currently February 29th?
		do
			Result := (not month_field.is_empty and not day_field.is_empty)
						and then (month_field.to_integer = 2 and day_field.to_integer = 29)
		end

feature -- Event handling

	handle_character (a_character: CHARACTER_32)
			-- Insert `a_character' into `widget'.
		do
			if a_character.is_digit then
				inspect
					format
				when format_month_day then
					if month_field_caret_position > 0 then
						insert_into_month_field (a_character)
					else
						insert_into_day_field (a_character)
					end
				when format_month_day_year then
					if month_field_caret_position > 0 then
						insert_into_month_field (a_character)
					elseif day_field_caret_position > 0 then
						insert_into_day_field (a_character)
					else
						insert_into_year_field (a_character)
					end
				when format_year_month_day then
						-- TODO implement
					check handle_character_format_ymd_implemented: False end
				else
						-- TODO handle error condition
					check handle_character_error_condition: False end
				end
			elseif is_slash_navigation_character (a_character) then
				if widget_caret_position <= separator_index_1 and not modifiers.is_control_pressed then
						-- if caret is in the first field then move cursor to the right of the first slash
					widget_caret_position := separator_index_1 + 1
				elseif widget_caret_position <= separator_index_2 and not modifiers.is_control_pressed then
						-- if caret is in the second field then move cursor to the right of the second slash
					widget_caret_position := separator_index_2 + 1
				else
					if format = format_month_day and day_field.count = 2 then
						widget_caret_position := widget.text.count
					elseif format = format_month_day_year and year_field.count = 4 then
						widget_caret_position := widget.text.count
					else
						widget_caret_position := widget.text.count + 1
					end
				end
			else
				--| TODO exception?
			end
		end

feature {ABSTRACT_DATE_TIME_INPUT_MASK} -- Datetime Input Mask

	split_widget_into_fields
			-- Split `widget'.text into `month_field' and `day_field'.
		local
			l_widget_text: STRING_32
			l_fields: LIST [STRING_32]
			l_year_index, l_month_index, l_day_index: INTEGER
		do
			l_widget_text := widget.text.twin
			year_field := ""
			month_field := ""
			day_field := ""
			l_month_index := 0
			l_day_index := 0
			l_year_index := 0

			if l_widget_text.has (date_separator) then
				l_fields := l_widget_text.split (date_separator)
				if format = format_month_day and l_widget_text.occurrences (date_separator) = 1 then
					check two_fields: l_fields.count = 2 end
					l_month_index := 1
					l_day_index := 2
				elseif l_widget_text.occurrences (date_separator) = 2 then
					check three_fields: l_fields.count = 3 end
					if format = format_month_day_year then
						l_month_index := 1
						l_day_index := 2
						l_year_index := 3
					else
						l_year_index := 1
						l_month_index := 2
						l_day_index := 3
					end
				else
					-- TODO Add case handling
				end

				if l_year_index > 0 then
					year_field := l_fields.i_th (l_year_index).twin
				end
				if l_month_index > 0 and l_day_index > 0 then
					month_field := l_fields.i_th (l_month_index).twin
					day_field := l_fields.i_th (l_day_index).twin
				end
			else
				if not l_widget_text.is_empty then
					--| TODO Add case handling
				end
			end

			widget_caret_position := widget.caret_position
			separator_index_1 := l_widget_text.index_of (date_separator, 1)
			separator_index_2 := l_widget_text.last_index_of (date_separator, l_widget_text.count)
			calculate_field_caret_positions
		end

	split_widget_with_selection_into_fields
			-- Split `widget'.text with selected text into corresponding fields, updating caret position.
		do
			if format = format_month_day then
				split_with_selection_month_day
			elseif format = format_month_day_year then
				split_with_selection_month_day_year
			else
				-- TODO Add case handling
			end
		end

	split_with_selection_month_day
			-- Split `widget'.text with selected text into `month_field' and `day_field', updating caret position.
		local
			l_start_selection, l_end_selection, l_remove_start, l_remove_end: INTEGER
		do
			l_start_selection := widget.start_selection
			l_end_selection := widget.end_selection
			split_widget_into_fields

			if l_start_selection < separator_index_1 then
				l_remove_start := l_start_selection
					-- Update month_field
				if l_end_selection <= separator_index_1 then
					l_remove_end := l_end_selection - 1
				else
					l_remove_end := separator_index_1 - 1
				end
				month_field.remove_substring (l_remove_start, l_remove_end)
					-- Update day_field
				if l_end_selection > separator_index_1 + 1 then
					l_remove_start := 1
					l_remove_end := l_end_selection - separator_index_1 - 1
					day_field.remove_substring (l_remove_start, l_remove_end)
					widget_caret_position := month_field.count + 1
				else
					widget_caret_position := l_start_selection
				end
			else
				if l_start_selection = separator_index_1 then
					l_remove_start := 1
				else
					l_remove_start := l_start_selection - separator_index_1
				end
				l_remove_end := l_end_selection - separator_index_1 - 1
				day_field.remove_substring (l_remove_start, l_remove_end)
				widget_caret_position := l_start_selection
			end
		end

	split_with_selection_month_day_year
			-- Split `widget'.text with selected text into `month_field', `day_field', and `year_field', updating caret position.
		local
			l_start_selection, l_end_selection, l_selected_separators_count, i: INTEGER
			l_text, l_text_tail: STRING_32
		do
			l_start_selection := widget.start_selection
			l_end_selection := widget.end_selection
			separator_index_1 := widget.text.index_of (date_separator, 1)
			separator_index_2 := widget.text.last_index_of (date_separator, widget.text.count)

			if widget.selected_text.same_string (date_separator_string) then
				widget.deselect_all
			else
					-- Get updated selected separators count, if any, to add back in after deletion of selected text
				widget.set_selection (l_start_selection, l_end_selection)
				l_selected_separators_count := widget.selected_text.occurrences (date_separator)
				widget.delete_selection

				if l_selected_separators_count > 0 then
					if l_start_selection > 1 then
						l_text := widget.text.substring (1, l_start_selection - 1)
					else
						l_text := ""
					end
					l_text_tail := widget.text.substring (l_start_selection, widget.text.count)
					from
						i := 1
					until
						i > l_selected_separators_count
					loop
						l_text.append_character (date_separator)
						i := i + 1
					end
					l_text.append (l_text_tail)
					widget.set_text (l_text)
				end
			end

			widget.set_caret_position (l_start_selection)
			split_widget_into_fields
		end

	increment_widget_caret_position (a_amount: INTEGER)
			-- Increment `widget_caret_position' by `a_amount'.
		do
			widget_caret_position := widget_caret_position + a_amount
			calculate_field_caret_positions
		ensure
			incremented: widget_caret_position = old widget_caret_position + a_amount
		end

	decrement_widget_caret_position (a_amount: INTEGER)
			-- Decrement `widget_caret_position' by `a_amount'.
		do
			widget_caret_position := widget_caret_position - a_amount
			calculate_field_caret_positions
		ensure
			incremented: widget_caret_position = old widget_caret_position - a_amount
		end

feature {NONE} -- Implementation

	calculate_field_caret_positions
			-- Calculate `year_field_caret_position', `month_field_caret_position', and `day_field_caret_position'.
		do
				-- TODO refactor
			inspect
				format
			when format_month_day then
				if widget_caret_position <= separator_index_1 then
					set_month_field_caret_position (widget_caret_position)
				else
					set_day_field_caret_position (widget_caret_position - separator_index_1)
				end
			when format_month_day_year then
				if widget_caret_position <= separator_index_1 then
					set_month_field_caret_position (widget_caret_position)
				elseif widget_caret_position <= separator_index_2 then
					set_day_field_caret_position (widget_caret_position - separator_index_1)
				else
					set_year_field_caret_position (widget_caret_position - separator_index_2)
				end
			when format_year_month_day then
					-- TODO implement
				check calculate_field_caret_positions_format_ymd_implemented: False end
			else
					-- TODO handle error condition
				check calculate_field_caret_positions_error_condition: False end
			end

		ensure
			year_field_but_not_month_and_day_field: year_field_caret_position > 0 implies (month_field_caret_position = 0 and day_field_caret_position = 0)
			month_field_but_not_year_and_day_field: month_field_caret_position > 0 implies (year_field_caret_position = 0 and day_field_caret_position = 0)
			day_field_but_not_year_and_month_field: day_field_caret_position > 0 implies (year_field_caret_position = 0 and month_field_caret_position = 0)
		end

	set_year_field_caret_position (a_caret_position: INTEGER)
			-- Set `year_field_caret_position' to `a_caret_position'.
		require
			valid_caret_position: 1 <= a_caret_position and a_caret_position <= 5
		do
			year_field_caret_position := a_caret_position
			month_field_caret_position := 0
			day_field_caret_position := 0
		ensure
			year_field_caret_position_set: year_field_caret_position = a_caret_position
			month_field_caret_position_cleared: month_field_caret_position = 0
			day_field_caret_position_cleared: day_field_caret_position = 0
		end

	set_month_field_caret_position (a_caret_position: INTEGER)
			-- Set `month_field_caret_position' to `a_caret_position'.
		require
			valid_caret_position: 1 <= a_caret_position and a_caret_position <= 3
		do
			year_field_caret_position := 0
			month_field_caret_position := a_caret_position
			day_field_caret_position := 0
		ensure
			year_field_caret_position_cleared: year_field_caret_position = 0
			month_field_caret_position_set: month_field_caret_position = a_caret_position
			day_field_caret_position_cleared: day_field_caret_position = 0
		end

	set_day_field_caret_position (a_caret_position: INTEGER)
			-- Set `day_field_caret_position' to `a_caret_position'.
		require
			valid_caret_position: 1 <= a_caret_position and a_caret_position <= 3
		do
			year_field_caret_position := 0
			month_field_caret_position := 0
			day_field_caret_position := a_caret_position
		ensure
			year_field_caret_position_cleared: year_field_caret_position = 0
			month_field_caret_position_cleared: month_field_caret_position = 0
			day_field_caret_position_set: day_field_caret_position = a_caret_position
		end

	insert_into_year_field (a_character: CHARACTER_32)
			-- Insert `a_character' into `year_field'.
		require
			character_is_digit: a_character.is_digit
		local
			l_caret_delta: INTEGER
		do
			if year_field_caret_position < 4 then
				l_caret_delta := 1
			end

			if year_field.count < 4 then	--| |; N| or |N; NN|, N|N or |NN; NNN|, NN|N, N|NN, or |NNN
				if is_valid_year_for_insertion (a_character, False) then
					year_field.insert_character (a_character, year_field_caret_position)
				else
					l_caret_delta := 0
				end
			elseif year_field.count = 4 then 	--| NNN|N, NN|NN, N|NNN, or |NNNN
				if is_valid_year_for_insertion (a_character, True) then
					year_field.remove (year_field_caret_position)
					year_field.insert_character (a_character, year_field_caret_position)
				else
					l_caret_delta := 0
				end
			else
					-- TODO implement exception handling
				check insert_into_year_field_exception: False end
			end

			increment_widget_caret_position (l_caret_delta)
		end

	is_valid_year_for_insertion (a_character: CHARACTER_32; a_remove: BOOLEAN) : BOOLEAN
			-- Given day and month, is year field a valid year for insertion of `a_character'?
			-- When `a_remove' is True, remove the character at `year_field_caret_position'.
		require
			is_valid_to_check_year: format = format_month_day_year or format = format_year_month_day
		local
			l_test_string: STRING_32
		do
			if not is_february_29th then
				Result := True
			else
				l_test_string := year_field.twin
				if a_remove then
					l_test_string.remove (year_field_caret_position)
				end
				l_test_string.insert_character (a_character, year_field_caret_position)
				Result := l_test_string.to_integer < 1581 or else (create {DATE_CONSTANTS}).is_leap_year (l_test_string.to_integer)
			end
		end

	insert_into_month_field (a_character: CHARACTER_32)
			-- Insert `a_character' into `month_field'.
		require
			character_is_digit: a_character.is_digit
		local
			l_caret_delta: INTEGER
			l_test_string: STRING_32
		do
			l_caret_delta := 0
			if month_field.is_empty then	--| |
				month_field.append_character (a_character)
				if a_character.is_equal ('0') or a_character.is_equal ('1') then
					-- Move caret to end of this (month) field.
					l_caret_delta := 1
				else
					--| Move caret to beginning of next field.
					l_caret_delta := 2
				end
			elseif month_field.count = 1 then	--| N| or |N
				l_test_string := month_field.twin

				if month_field_caret_position = 1 then		-- |N
					l_test_string.prepend_character (a_character)
					l_caret_delta := 1

					if is_valid_month (l_test_string.to_integer) then
						if not (a_character.is_equal ('0') and then month_field.same_string ("0")) then
							month_field.prepend_character (a_character)
						end
					else
						month_field.remove (1)
						month_field.append_character (a_character)
						if not (a_character.is_equal ('0') or a_character.is_equal ('1')) then
							l_caret_delta := l_caret_delta + 1
						end
					end
				elseif month_field_caret_position = 2 then -- N|
					l_test_string.append_character (a_character)

					if is_valid_month (l_test_string.to_integer) then
						if not (a_character.is_equal ('0') and then month_field.same_string ("0")) then
							month_field.append_character (a_character)
							l_caret_delta := 2
						else
							increment_widget_caret_position (1)
							insert_into_day_field (a_character)
						end
					else
						if not (month_field.same_string ("0") and a_character.is_equal ('0')) then
							increment_widget_caret_position (1)
							insert_into_day_field (a_character)
						end
						l_caret_delta := 0
					end
				else
					--| TODO implement exception handling
					check month_field_count_is_1_exception: False end
				end
			elseif month_field.count = 2 then	--| NN|, N|N, or |NN
				if month_field_caret_position = 1 then		-- |NN
					if (a_character.is_equal ('0') and not month_field.item (2).is_equal ('0')) or
						(a_character.is_equal ('1') and (month_field.item (2).is_equal ('0') or month_field.item (2).is_equal ('1') or month_field.item (2).is_equal ('2'))) then

						month_field.remove (1)
						month_field.prepend_character (a_character)
						l_caret_delta := 1
					end
				elseif month_field_caret_position = 2 then		-- N|N
					if (month_field.item (1).is_equal ('0') and not a_character.is_equal ('0')) or
						(month_field.item (1).is_equal ('1') and (a_character.is_equal ('0') or a_character.is_equal ('1') or a_character.is_equal ('2'))) then

						month_field.remove (2)
						month_field.append_character (a_character)
						l_caret_delta := 2
					end
				elseif month_field_caret_position = 3 then		-- NN|
					increment_widget_caret_position (1)
					insert_into_day_field (a_character)
					l_caret_delta := 0
				else
					--| TODO implement exception handling
					check month_field_count_is_2_exception: False end
				end
			end
			increment_widget_caret_position (l_caret_delta)
		end

	insert_into_day_field (a_character: CHARACTER_32)
			-- Insert `a_character' into `day_field'
		require
			character_is_digit: a_character.is_digit
		local
			l_caret_delta, l_month: INTEGER
			l_test_string: STRING_32
		do
			l_caret_delta := 0

			if day_field.is_empty then	--| |
				day_field.append_character (a_character)
				l_caret_delta := 1

				if format /= format_month_day then
					if day_field.to_integer = 3 and not month_field.is_empty then
						l_month := month_field.to_integer
						if l_month = 2 then
							l_caret_delta := l_caret_delta + 1
						else
							l_test_string := day_field.twin
							if l_month = 4 or l_month = 6 or l_month = 9 or l_month = 11 then
								l_test_string.append_character ('0')
							else
								l_test_string.append_character ('1')
							end
							if not is_valid_day_for_current_month (l_test_string.to_integer) then
								l_caret_delta := l_caret_delta + 1
							end
						end
					else
						if day_field.to_integer > 3 then
							l_caret_delta := l_caret_delta + 1
						end
					end
				end
			elseif day_field.count = 1 then		--| N| or |N
				l_test_string := day_field.twin

				if day_field_caret_position = 1 then		-- |N
					l_test_string.prepend_character (a_character)
					if a_character.is_equal ('0') and then day_field.same_string ("0") then
						l_caret_delta := 1
					elseif is_valid_day_for_current_month (l_test_string.to_integer) then
						day_field.prepend_character (a_character)
						l_caret_delta := 1
					else
						create l_test_string.make (1)
						l_test_string.append_character (a_character)
						if is_valid_day_for_current_month (l_test_string.to_integer) then
							day_field.remove (1)
							day_field.append_character (a_character)
							l_caret_delta := 1

							if format /= format_month_day then
									-- TODO refactor this with condition above - abc.
								if day_field.to_integer = 3 and not month_field.is_empty then
									l_month := month_field.to_integer
									if l_month = 2 then
										l_caret_delta := l_caret_delta + 1
									else
										l_test_string := day_field.twin
										if l_month = 4 or l_month = 6 or l_month = 9 or l_month = 11 then
											l_test_string.append_character ('0')
										else
											l_test_string.append_character ('1')
										end
										if not is_valid_day_for_current_month (l_test_string.to_integer) then
											l_caret_delta := l_caret_delta + 1
										end
									end
								else
									if day_field.to_integer > 3 then
										l_caret_delta := l_caret_delta + 1
									end
								end
							end
						end
					end
				elseif day_field_caret_position = 2 then -- N|
					l_test_string.append_character (a_character)
					if is_valid_day_for_current_month (l_test_string.to_integer_32) then
						if not (a_character.is_equal ('0') and then day_field.same_string ("0")) then
							day_field.append_character (a_character)
							if format = format_month_day_year then
								l_caret_delta := 2
							end
						elseif format = format_month_day_year then
							increment_widget_caret_position (1)
							insert_into_year_field (a_character)
						end
					elseif format = format_month_day_year then
						increment_widget_caret_position (1)
						insert_into_year_field (a_character)
						l_caret_delta := 0
					end
				end
			elseif day_field.count = 2 then		--| N|N, or |NN
				l_test_string := day_field.twin

				if day_field_caret_position = 1 then		-- |NN
					l_test_string.remove (1)
					l_test_string.prepend_character (a_character)
					if is_valid_day_for_current_month (l_test_string.to_integer) and then
						not (a_character.is_equal ('0') and then l_test_string.same_string ("00")) then

						day_field.remove (1)
						day_field.prepend_character (a_character)
						l_caret_delta := 1
					end
				elseif day_field_caret_position = 2 then		-- N|N
					l_test_string.remove (2)
					l_test_string.append_character (a_character)
					if is_valid_day_for_current_month (l_test_string.to_integer) then
						day_field.remove (2)
						day_field.append_character (a_character)

						if format = format_month_day_year then
							l_caret_delta := 2
						end
					end
				elseif format = format_month_day_year then
					increment_widget_caret_position (1)
					insert_into_year_field (a_character)
					l_caret_delta := 0
				else
						--| TODO implement exception handling
					check day_field_count_is_2_exception: False end
				end
			end
			increment_widget_caret_position (l_caret_delta)
		end

end

note 
	description: "[
			A Numeric Input Mask is an {INPUT_MASK} specialized to only allow numeric input.
			]"
	purpose: "[			
			Some fields need to permit only numeric input.
			]"
	how: "[
			See {INPUT_MASK}.
			]"
	generic_definition: "V -> NUMERIC Value; CON -> Type of the DATA_COLUMN_METADATA to use as a constraint"
	date: "$Date: 2015-10-14 16:41:00 -0400 (Wed, 14 Oct 2015) $"
	revision: "$Revision: $"

deferred class
	NUMERIC_VALUE_INPUT_MASK [V -> NUMERIC, reference CON -> DATA_COLUMN_METADATA [ANY]]

inherit
	INPUT_MASK [V, CON]
		rename
			refresh_formatting as refresh_number_formatting
		redefine
			handle_cut,
			is_valid_character_for_mask,
			handle_key_string,
			refresh_number_formatting,
			update_text_and_caret_position,
			right_limit_offset
		end

feature -- Status Report

	is_valid_character_for_mask (a_character: CHARACTER_32): BOOLEAN
			-- <Precursor>
		do
			Result := valid_characters_for_mask.has (a_character)
		end

	is_suppressing_format: BOOLEAN
			-- Is formatting being suppressed?

feature -- Access

	capacity: NATURAL_8
			-- Maximum number of characters allowed in field.

	thousands_separator: CHARACTER_32 = ','
			-- Character used to visually separate the integer part of numbers into groups of three

	negative_sign: CHARACTER_32 = '-'
			-- Character used to indicate a negative number

	decimal_point: CHARACTER_32 = '.'
			-- Character which separates integer part of number from decimal part

feature -- Event Handling

	handle_key_string (a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_caret_position, l_caret_offset: INTEGER
			l_is_dash, l_is_plus, l_is_numpad: BOOLEAN
			l_key_string: STRING_32
			l_numpad_correction: like numpad_correction
		do
			l_numpad_correction := numpad_correction (a_key_string)
			l_key_string := l_numpad_correction.corrected
			l_is_numpad := l_numpad_correction.is_numpad
			l_is_dash := l_key_string.same_string ("-")
			l_is_plus := l_key_string.same_string ("+")
			if ev_application.ctrl_pressed then
				if not ev_application.shift_pressed and not ev_application.alt_pressed and then a_key_string.same_string ("x") and then a_widget.has_selection and then a_widget.is_editable then
					ev_application.clipboard.set_text (a_widget.selected_text)
					handle_key_delete (a_widget)
				elseif not ev_application.shift_pressed and not ev_application.alt_pressed and then a_key_string.same_string ("c") and then a_widget.has_selection then
					ev_application.clipboard.set_text (a_widget.selected_text)
				end
			elseif l_is_dash or l_is_plus then
				if a_widget.is_editable and not a_widget.has_selection then
					l_caret_position := a_widget.caret_position
					if a_widget.text.at (1).is_equal (negative_sign) then
						a_widget.set_text (a_widget.text.substring (2, a_widget.text_length))
						if l_caret_position > 1 then
							l_caret_offset := -1
						else
							l_caret_offset := 0
						end
					elseif not l_is_plus then
						a_widget.set_text ("-" + a_widget.text)
						l_caret_offset := 1
					end
					a_widget.set_caret_position (l_caret_position + l_caret_offset)
				end
			elseif not (l_is_numpad and ev_application.shift_pressed) and then not l_key_string.is_empty and then l_key_string.item (1).is_digit then
				handle_digit_string (l_key_string, a_widget)
			end
		end

	handle_digit_string (a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- User has pressed a number key
		require
			is_digit_string: (a_key_string.count = 1) and then a_key_string.item (1).is_digit
		local
			l_caret_position, l_old_comma_count, l_caret_offset, l_integer_count: INTEGER
			l_unrefreshed_text, l_new_text: STRING_32
			l_comma_left_of_caret: BOOLEAN
			l_key_string: STRING_32
		do
			if a_widget.is_editable then
				--| See https://docs.google.com/spreadsheet/ccc?key=0AlbYAXcgX6hLdDl4c3c5S2NRbjJ5QlVMWE9zN3ZnWnc#gid=0
				l_key_string := a_key_string.twin
				l_new_text := a_widget.text.twin
				l_integer_count := digit_count (l_new_text).integer
				if a_widget.has_selection and then (l_integer_count < capacity or else selection_includes_digit (a_widget)) then
					l_caret_position := a_widget.end_selection
					l_caret_offset := a_widget.text_length - l_caret_position + 1
					a_widget.delete_selection

					if a_widget.text_length = 0 then
						l_new_text := l_key_string
						l_caret_position := 2
					else
						l_new_text := a_widget.text.twin
						l_caret_position := l_new_text.count - l_caret_offset + 1
						l_new_text.insert_character (l_key_string.item (1), l_caret_position)
						l_new_text := refresh_number_formatting (l_new_text)
						l_caret_position := l_new_text.count - l_caret_offset
						if l_caret_position <= 0 then
							l_caret_position := 1
						elseif l_new_text.item (l_caret_position) /= thousands_separator then
							l_caret_position := l_caret_position + 1
						end
					end
					a_widget.set_text (l_new_text)
					a_widget.set_caret_position (l_caret_position)
				elseif not a_widget.has_selection and then l_integer_count < capacity then
					l_old_comma_count := l_new_text.occurrences (thousands_separator)
					l_caret_position := a_widget.caret_position
					l_comma_left_of_caret := (l_caret_position > 1) and then (l_new_text.item (l_caret_position - 1) = thousands_separator)
					if l_caret_position = 1 and then a_widget.text.at (1).is_equal (negative_sign) then
						l_caret_position := l_caret_position + 1
						l_new_text.insert_character (l_key_string.item (1), l_caret_position)
					else
						l_new_text.insert_character (l_key_string.item (1), l_caret_position)
					end
					l_unrefreshed_text := l_new_text.twin
					l_new_text := refresh_number_formatting (l_new_text)
					if (l_caret_position = 2) and then l_unrefreshed_text.substring (1, 3).same_string ("-00") then
						l_caret_offset := -1
					elseif
						l_new_text.is_empty or else l_comma_left_of_caret or else
						((l_caret_position = 2) and then l_unrefreshed_text.item (1) = '0' and then l_unrefreshed_text.count > 1) or else
						((l_caret_position = 1) and then l_unrefreshed_text.item (1) = '0' and then l_unrefreshed_text.count > 1) or else
						((l_caret_position = 2) and then l_unrefreshed_text.substring (1, 2).same_string ("-0"))
					then
						l_caret_offset := 0
					elseif l_old_comma_count /= l_new_text.occurrences (thousands_separator) then
						l_caret_offset := 2
						if l_new_text.item (l_caret_position + 1) = thousands_separator then
							l_caret_offset := 1
						end
					else
						l_caret_offset := 1
					end
					a_widget.set_text (l_new_text)
					a_widget.set_caret_position ((l_new_text.count + 1).min (l_caret_position + l_caret_offset))
				end
			end
		end

	handle_key_left (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_caret_position, l_new_caret_position: INTEGER
			l_anchor_position, l_new_anchor_position: INTEGER
			l_has_selection: BOOLEAN
		do
			if not a_widget.text.is_empty then
				l_caret_position := caret_position_from_widget (a_widget)
				l_anchor_position := anchor_position_from_widget (a_widget)
				l_has_selection := a_widget.has_selection
				if ev_application.ctrl_pressed then
					l_new_caret_position := 1
				else
					l_new_caret_position := (1).max (a_widget.caret_position - 1)
				end
				if ev_application.shift_pressed then
					if l_has_selection then
						if l_caret_position /= 1 then
							if ev_application.ctrl_pressed then
								l_new_anchor_position := l_anchor_position
								if l_new_anchor_position > 1 then
									if is_separator (a_widget.text.item (l_new_anchor_position - 1)) then
										l_new_anchor_position := l_new_anchor_position - 1
									end
									a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
								else
									a_widget.set_caret_position (1)
								end
							elseif
								(l_anchor_position = l_new_caret_position) or else
								((l_caret_position > l_anchor_position) and then (is_separator (a_widget.text.item (l_anchor_position)) and then (a_widget.selected_text.count = 2)))
							then
								if
									a_widget.text.valid_index (l_new_caret_position - 1) and then
									is_separator (a_widget.text.item (l_new_caret_position - 1))
								then
									l_new_caret_position := l_new_caret_position - 1
								end
								a_widget.deselect_all
								a_widget.set_caret_position (l_new_caret_position)
							elseif l_new_caret_position > l_anchor_position then
								if
									a_widget.text.valid_index (l_new_caret_position - 1) and then
									is_separator (a_widget.text.item (l_new_caret_position - 1))
								then
									l_new_caret_position := l_new_caret_position - 1
								end
								l_new_anchor_position := l_anchor_position
								if is_separator (a_widget.text.item (l_new_anchor_position)) then
									l_new_anchor_position := l_anchor_position + 1
								end
								a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
							else
								if is_separator (a_widget.text.item (l_new_caret_position)) then
									l_new_caret_position := l_new_caret_position - 1
								end
								l_new_anchor_position := l_anchor_position
								if is_separator (a_widget.text.item (l_new_anchor_position - 1)) then
									l_new_anchor_position := l_new_anchor_position - 1
								end
								a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
							end
						end
					elseif l_caret_position > 1 then --| Shift but no selection
						if ev_application.ctrl_pressed then
							l_new_anchor_position := l_caret_position
							if a_widget.text.valid_index (l_new_anchor_position - 1) and then is_separator (a_widget.text.item (l_new_anchor_position - 1)) then
								l_new_anchor_position := l_new_anchor_position - 1
							end
							a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
						else
							l_new_anchor_position := l_caret_position
							if l_new_anchor_position > 1 and then is_separator (a_widget.text.item (l_new_anchor_position - 1)) then
								l_new_caret_position := l_new_caret_position - 1
								l_new_anchor_position := l_new_anchor_position - 1
							end
							a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
						end
					end
				else
					if l_has_selection and not ev_application.ctrl_pressed then
						l_new_caret_position := a_widget.start_selection
					end
					if a_widget.text.valid_index (l_new_caret_position - 1) and then a_widget.text.item (l_new_caret_position - 1) = thousands_separator then
						l_new_caret_position := l_new_caret_position - 1
					end
					a_widget.deselect_all
					a_widget.set_caret_position (l_new_caret_position)
				end
			end
		end

	handle_key_right (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		note
			purpose: "[
				To provide handling of all these various conditions handle some sort of input in the 
				numeric spreadsheet to ensure the output matches.
				]"
			testing: "[
				When we get an exception, we step through, find the offending line, figure out why it's 
				not producing the matching spreadsheet output pattern, fix it, update the test, then 
				check it in.
				]"
		local
			l_anchor_position, l_new_anchor_position, l_caret_position, l_new_caret_position: INTEGER
			l_has_selection: BOOLEAN
		do
			l_has_selection := a_widget.has_selection
			l_caret_position := caret_position_from_widget (a_widget)
			if ev_application.shift_pressed then
				if l_has_selection then
					l_anchor_position := anchor_position_from_widget (a_widget)
					if ev_application.ctrl_pressed then
						if l_anchor_position = (a_widget.text_length + 1 + right_limit_offset) then
							a_widget.deselect_all
							a_widget.set_caret_position (a_widget.text_length + right_limit_offset)
						else
							l_new_anchor_position := l_anchor_position
							l_new_caret_position := a_widget.text_length + 1
							if a_widget.text.valid_index (l_new_anchor_position) and then is_separator (a_widget.text.item (l_new_anchor_position)) then
								l_new_anchor_position := l_new_anchor_position + 1
							end
							a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
						end
					elseif (l_caret_position + 1) = l_anchor_position then
						a_widget.deselect_all
						l_new_caret_position := l_caret_position
						if (l_new_caret_position < (a_widget.text_length + right_limit_offset)) and then (a_widget.text.item (l_new_caret_position) /= thousands_separator) then
							l_new_caret_position := l_new_caret_position + 1
						end
						a_widget.set_caret_position (l_new_caret_position)
					elseif l_caret_position < l_anchor_position then
						l_new_caret_position := l_caret_position + 1
						l_new_anchor_position := l_anchor_position
						if
							(a_widget.text.item (l_new_caret_position) = decimal_point) or else
							(a_widget.text.valid_index (l_new_caret_position) and then is_separator (a_widget.text.item (l_new_caret_position))
							and then l_new_anchor_position > (l_new_caret_position + 1))
						then
							l_new_caret_position := l_new_caret_position + 1
						end
						if l_new_caret_position = l_new_anchor_position then
							a_widget.deselect_all
							a_widget.set_caret_position (l_new_caret_position)
						else
							if is_separator (a_widget.text.item (l_new_anchor_position - 1)) then
								l_new_anchor_position := l_new_anchor_position - 1
							end
							a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
						end
					elseif l_caret_position > l_anchor_position then
						l_new_caret_position := l_caret_position + 1
						l_new_anchor_position := l_anchor_position
						if a_widget.text.valid_index (l_caret_position) and then is_separator (a_widget.text.item (l_caret_position)) then
							l_new_caret_position := l_new_caret_position + 1
						end
						if is_separator (a_widget.text.item (l_new_anchor_position)) then
							l_new_anchor_position := l_new_anchor_position + 1
						end
						a_widget.set_selection (l_new_anchor_position, (a_widget.text_length + 1).min (l_new_caret_position))
					end
				elseif l_caret_position <= a_widget.text_length then --| Shift but no selection
					l_new_anchor_position := l_caret_position
					if ev_application.ctrl_pressed then
						l_new_caret_position := a_widget.text_length + 1
					else
						l_new_caret_position := l_caret_position + 1
					end
					if (a_widget.text.item (l_new_anchor_position) = decimal_point) or else is_separator (a_widget.text.item (l_new_anchor_position)) then
						l_new_anchor_position := l_new_anchor_position + 1
						if l_new_caret_position = l_new_anchor_position then
							l_new_caret_position := l_new_caret_position + 1
						end
					end
					a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
				end
			else
				if ev_application.ctrl_pressed then
					l_caret_position := a_widget.text_length + right_limit_offset
				elseif l_has_selection then
					l_caret_position := (a_widget.text_length + right_limit_offset).min (a_widget.start_selection.max (a_widget.end_selection - 1) + 1)
				elseif a_widget.caret_position < a_widget.text_length + right_limit_offset then
					l_caret_position := a_widget.caret_position + 1
					if a_widget.text.valid_index (l_caret_position - 1) and then a_widget.text.item (l_caret_position - 1) = thousands_separator then
						l_caret_position := l_caret_position + 1
					end
				else
					l_caret_position := a_widget.caret_position
				end
				l_caret_position := (1).max (l_caret_position)
				l_caret_position := (a_widget.text_length + 1).min (l_caret_position)
				a_widget.deselect_all
				a_widget.set_caret_position (l_caret_position)
			end
		end

	handle_key_back_space (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_new_text: STRING_32
			l_caret_position, l_caret_offset, l_new_caret_position: INTEGER
			l_left_removal_index, l_right_removal_index: INTEGER
			l_has_selection: BOOLEAN
		do
			if a_widget.is_editable and then (a_widget.caret_position > 1 or a_widget.has_selection) then
				l_caret_position := a_widget.caret_position
				l_new_text := a_widget.text.twin
				l_has_selection := a_widget.has_selection
				if l_has_selection then
					l_right_removal_index := a_widget.start_selection.max (a_widget.end_selection - 1)
					l_left_removal_index := a_widget.start_selection.min (a_widget.end_selection - 1)
					l_caret_offset := l_new_text.count - l_right_removal_index - 1
				else
					l_right_removal_index := l_caret_position - 1
					l_left_removal_index := l_right_removal_index
					if l_new_text.item (l_left_removal_index) = thousands_separator then
						check
							l_left_removal_index_greater_than_one: l_left_removal_index > 1
						end
						l_left_removal_index := l_left_removal_index - 1
					end
					l_caret_offset := l_new_text.count - l_caret_position
					if l_left_removal_index /= l_right_removal_index then
						l_caret_offset := l_caret_offset + 1
					end
				end
				if ev_application.ctrl_pressed and not l_has_selection then
					l_right_removal_index := l_caret_position
					if l_right_removal_index = l_new_text.count + 1 then
						l_new_text := ""
					else
						l_new_text := l_new_text.substring (l_right_removal_index, l_new_text.count)
					end
					l_caret_offset := l_new_text.count
				else
					l_new_text.remove_substring (l_left_removal_index, l_right_removal_index)
				end
				reformat_number_and_set (l_new_text, a_widget)
				l_new_caret_position := a_widget.text_length - l_caret_offset
				l_new_caret_position := (1).max (l_new_caret_position)
				l_new_caret_position := (a_widget.text_length + 1).min (l_new_caret_position)
				if l_new_caret_position > 1 and then a_widget.text.item (l_new_caret_position - 1) = thousands_separator then
					l_new_caret_position := l_new_caret_position - 1
				end
				a_widget.set_caret_position (l_new_caret_position)
			end
		end

	handle_key_delete (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_caret_position, l_caret_offset, l_comma_count: INTEGER
			l_new_text: STRING_32
			l_comma_adjacent, l_separator_adjacent: BOOLEAN
		do
			if a_widget.is_editable then
				if a_widget.has_selection then
					l_caret_offset := a_widget.end_selection - a_widget.text_length - 1
					a_widget.delete_selection
					a_widget.set_text (refresh_number_formatting (a_widget.text))
					l_caret_position := a_widget.text_length + l_caret_offset + 1
					l_caret_position := (1).max (l_caret_position)
					l_caret_position := (a_widget.text_length + 1).min (l_caret_position)
					if a_widget.text.valid_index (l_caret_position - 1) and then (a_widget.text.item (l_caret_position - 1) = thousands_separator) then
						l_caret_position := l_caret_position - 1
					end
					a_widget.set_caret_position (l_caret_position)
				elseif a_widget.caret_position <= a_widget.text.count then
					l_caret_position := a_widget.caret_position
					l_new_text := a_widget.text.twin
					l_comma_count := l_new_text.occurrences (thousands_separator)
					l_comma_adjacent := l_new_text.item (l_caret_position) = thousands_separator
					l_separator_adjacent := is_separator (l_new_text.item (l_caret_position))
					if ev_application.ctrl_pressed then
						if l_caret_position = 1 then
							l_new_text := ""
						else
							l_new_text := l_new_text.substring (1, l_caret_position - 1)
						end
					else
						if l_comma_adjacent then
							l_new_text.remove (l_caret_position)
						end
						if l_new_text.valid_index (l_caret_position) then
							if l_separator_adjacent then
								l_new_text.remove (l_caret_position + 1)
							else
								l_new_text.remove (l_caret_position)
							end
						end
					end
					l_new_text := refresh_number_formatting (l_new_text)

					if ev_application.ctrl_pressed then
						l_caret_position := l_new_text.count + right_limit_offset
						l_caret_offset := 0
					elseif not l_comma_adjacent and then l_new_text.occurrences (thousands_separator) /= l_comma_count and then l_caret_position > 1 then
						l_caret_offset := 1
					elseif l_comma_adjacent and then l_new_text.occurrences (thousands_separator) = l_comma_count then
						l_caret_offset := -1
					elseif not l_comma_adjacent and l_separator_adjacent then
						l_caret_offset := -2
					end
					a_widget.set_text (l_new_text)
					a_widget.set_caret_position ((1).max (l_caret_position - l_caret_offset))
				end
			end
		end

	handle_key_home (a_widget: EV_TEXT_COMPONENT)
			-- Moves caret and/or extends selection to the left most position in the field.
		local
			l_start_selection: INTEGER
		do
			if a_widget.has_selection and then a_widget.caret_position = a_widget.start_selection then
				l_start_selection := a_widget.end_selection - 1
			elseif a_widget.has_selection then
				l_start_selection := a_widget.start_selection - 1
			else
				l_start_selection := a_widget.caret_position - 1
			end
			if a_widget.text.valid_index (l_start_selection) and then is_separator (a_widget.text.item (l_start_selection)) then
				l_start_selection := l_start_selection - 1
			end
			if ev_application.shift_pressed and then a_widget.text.valid_index (l_start_selection) then
				a_widget.set_selection (l_start_selection + 1, 1)
			else
				a_widget.set_caret_position (1)
			end
		end

	handle_key_end (a_widget: EV_TEXT_COMPONENT)
			-- Moves caret and/or extends selection to the left most position in the field.
		local
			l_start_selection: INTEGER
		do
			if a_widget.text_length > 0 then
				if a_widget.has_selection and then a_widget.caret_position = a_widget.start_selection then
					l_start_selection := a_widget.end_selection
				elseif a_widget.has_selection then
					l_start_selection := a_widget.start_selection
				else
					l_start_selection := a_widget.caret_position
				end
				if a_widget.text.valid_index (l_start_selection) and then is_separator (a_widget.text.item (l_start_selection)) then
					l_start_selection := l_start_selection + 1
				end
				if ev_application.shift_pressed and then a_widget.text.valid_index (l_start_selection) then
					a_widget.set_selection (l_start_selection, a_widget.text_length + 1)
				else
					a_widget.set_caret_position (a_widget.text_length + right_limit_offset)
				end
			end
		end

	handle_cut (a_widget: EV_TEXT_COMPONENT)
			-- Perform a cut operation
		do
			if a_widget.is_editable and then a_widget.has_selection then
				ev_application.clipboard.set_text (a_widget.selected_text)
				handle_key_delete (a_widget)
			end
		end

feature {TEST_SET_BRIDGE} -- Implementation

	selection_includes_digit (a_widget: EV_TEXT_COMPONENT): BOOLEAN
			-- Does selected text in `a_widget' include at least one digit?
		require
			has_selection: a_widget.has_selection
		do
			Result := across a_widget.selected_text as ic_selection some ic_selection.item.is_digit end
		end

	apply_implementation (a_value: READABLE_STRING_GENERAL): TUPLE [READABLE_STRING_GENERAL, STRING_32]
			-- <Precursor>
		do
			Result := [apply_formatting (a_value.as_string_32), create {STRING_32}.make_empty]
		end

	update_text_and_caret_position (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32; a_caret_position: INTEGER)
			-- <Precursor>
		do
			Precursor (a_widget, a_text, a_caret_position.min (a_text.count + right_limit_offset))
		end

	insert_string (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32)
			-- <Precursor>
		local
			l_caret_position, l_caret_delta, l_digits_counted: INTEGER
			l_string, l_string_2: STRING_32
			l_was_inserted: BOOLEAN
		do
			l_caret_position := a_widget.caret_position

			if l_caret_position = 1 and then a_widget.text.has (negative_sign) then
				create l_string.make_filled (negative_sign, 1)
				l_string_2 := a_widget.text.substring (2, a_widget.text.count)
			else
				l_string := a_widget.text.substring (1, l_caret_position - 1)
				l_string := remove_formatting (l_string)
				l_string_2 := a_widget.text.substring (l_caret_position, a_widget.text.count)
			end
			if l_string.same_string ("0") then
				l_string := ""
			elseif l_string.same_string ("-0") then
				l_string := "-"
			end
			l_string_2 := remove_formatting (l_string_2)
			across a_text as ic_items loop
				if
					((l_caret_position = 1 and then ic_items.cursor_index = 1 and then ic_items.item = negative_sign and then is_valid_character_for_mask (negative_sign) and then not a_widget.text.has (negative_sign)) or else
					ic_items.item.is_digit) and then
					(fits_in_mask (l_string + create {STRING_32}.make_filled (ic_items.item, 1) + l_string_2) or else l_string.has (decimal_point))
				then
					l_string.append_character (ic_items.item)
					l_was_inserted := ic_items.item.is_digit
				end
			end
			l_caret_delta := l_string.count
			l_string.append (l_string_2)
			if not is_suppressing_format then
				l_string := format_as_number (l_string)
			end
			from
				l_caret_position := 1
				l_digits_counted := 0
			until
				(l_digits_counted >= l_caret_delta) or else not l_string.valid_index (l_caret_position)
			loop
				if l_string.item (l_caret_position).is_digit or else l_string.item (l_caret_position) = negative_sign or else l_string.item (l_caret_position) = decimal_point then
					l_digits_counted := l_digits_counted + 1
				end
				l_caret_position := l_caret_position + 1
			end
			if l_was_inserted and then fits_in_mask (l_string) then
				update_text_and_caret_position (a_widget, l_string, l_caret_position)
			end
		end

	format_as_number (a_string: STRING_32): STRING_32
			-- Format `_string' for use as a number
		local
			l_formatted_integer: FORMAT_INTEGER
		do
			if a_string.count = 1 and then a_string.item (1) = negative_sign then
				create Result.make_filled (negative_sign, 1)
			elseif not a_string.is_empty then
				if a_string.item (1) = negative_sign then
					create l_formatted_integer.make (a_string.count - 1)
				else
					create l_formatted_integer.make (a_string.count)
				end
				l_formatted_integer.comma_separate
				l_formatted_integer.no_justify
				Result := l_formatted_integer.formatted (a_string.to_integer_32).to_string_32
			else
				create Result.make_empty
			end
		end

	apply_formatting (a_string: STRING_32): STRING_32
			-- <Precursor>
		do
			Result := format_as_number (a_string)
		end

	remove_formatting (a_string: STRING_32): STRING_32
			-- Remove formatting for this mask from `a_string'.
		do
			create Result.make (a_string.count)
			across a_string as ic_items loop
				if is_valid_character_for_mask (ic_items.item) then
					Result.append_character (ic_items.item)
				end
			end
		end

	refresh_number_formatting (a_string: STRING_32): STRING_32
			-- Re-applies formatting to `a_string' by removing any formatting already in place with `remove_formatting', then calling `apply_formatting'.
		do
			Result := remove_formatting (a_string)
			Result := format_as_number (Result)
		end

	valid_characters_for_mask: STRING_32
			-- Characters that are valid for Current.
		do
			create Result.make_from_string ("1234567890")
		end

	replace_selection (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32)
			-- <Precursor>
		local
			l_prepend, l_append, l_decimal_point: STRING_32
			l_start_selection, l_end_selection: INTEGER
			l_widget_text: STRING_32
			l_widget: EV_TEXT_FIELD
		do
			create l_widget
			if a_widget.selected_text.has (decimal_point) then
				create l_decimal_point.make_filled (decimal_point, 1)
			else
				create l_decimal_point.make_empty
			end
			l_start_selection := a_widget.start_selection
			l_end_selection := a_widget.end_selection - 1
			l_widget_text := a_widget.text.twin
			l_prepend :=  l_widget_text.substring (1, l_start_selection - 1)
			l_append := l_widget_text.substring (l_end_selection + 1, l_widget_text.count)
			l_widget_text := l_prepend + l_decimal_point + l_append
			l_widget.set_text (l_widget_text.twin)
			l_widget.set_caret_position (l_prepend.count + 1)
			insert_string (l_widget, a_text)
			if not l_widget.text.same_string (l_widget_text) then
				update_text_and_caret_position (a_widget, l_widget.text, l_widget.caret_position)
			end
		end

	remove_character_at_caret_position (a_widget: EV_TEXT_COMPONENT; before: BOOLEAN)
			-- <Precursor>
		local
			l_string: STRING_32
			l_caret_position: INTEGER
		do
			l_string := a_widget.text
			l_caret_position := a_widget.caret_position
			if before then
				l_caret_position := l_caret_position - 1
			end
			if l_string.valid_index (l_caret_position) then
				l_string := remove_formatting (l_string)
				l_string.remove (l_caret_position)
				l_string := format_as_number (l_string)
				update_text_and_caret_position (a_widget, l_string, l_caret_position)
			end
		end

	reformat_number_and_set (a_text: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- Reformat `a_text' and set it into `a_widget'
		do
			a_widget.set_text (format_as_number (remove_formatting (a_text)))
		end

	digit_count (a_text: STRING_32): TUPLE [integer: INTEGER; decimal: INTEGER]
			-- Count of digits in `a_text'
		local
			l_is_in_decimals, l_is_digit: BOOLEAN
			l_integer, l_decimal: INTEGER
			l_item: CHARACTER_32
		do
			across a_text as ic_text loop
				l_item := ic_text.item
				l_is_digit := l_item.is_digit
				if l_is_digit and then l_is_in_decimals then
					l_decimal := l_decimal + 1
				elseif l_is_digit then
					l_integer := l_integer + 1
				elseif l_item = decimal_point then
					l_is_in_decimals := True
				end
			end
			Result := [l_integer, l_decimal]
		end

	fits_in_mask (a_text: STRING_32): BOOLEAN
			-- Does `a_text' fit in the current mask?
		deferred
		end

	separator_characters: ARRAY [CHARACTER_32]
			-- Characters which separate portions of a number
		once
			Result := <<thousands_separator>>
		ensure
			result_has_comma: Result.has (thousands_separator)
		end

	is_separator (a_character: CHARACTER_32): BOOLEAN
			-- Is a character a separator?
		do
			Result := separator_characters.has (a_character)
		ensure
			result_correct: Result = separator_characters.has (a_character)
		end

	right_limit_offset: INTEGER
			-- Offset of the right limit for cursor movement (from widget.text_length)
		do
			Result := 1
		end

	total_column_capacity: INTEGER
			-- The total number of columns which may be displayed in the widget, not counting thousand separators
		do
			Result := capacity
		end

;note
	operations: "[
		This note entry is here to offer you instruction on how to effectively and quickly
		navigate through the documentation of this library and its clusters and classes.
		
		Virtues of Clickable-view & Notes
		=================================
		When viewing notes in the editor, embedded references which are Pick-and-Droppable in
		the Clickable-view are not when in the general editing view. Moreover, only classes
		which are "in-system" will have their features, clients, supplies, and so on viewable
		in the various tools. Therefore, based on these items, you will want to pick-and-drop
		"in-system" "classes-of-interest" (your interest) into the Class-tool and select the
		Clickable-view tool as your primary reader -OR- you will want to change the editor to
		the Clickable-view in order to explore (i.e. you are learning and not coding, so you
		want to use the Clickable-view in the editor to explore with while learning).
		
		One will find an advantage by viewing the class and its notes in the editor under the
		Clickable-view. When this is so, you may pick and drop a CLASS or Feature reference to
		the Class or Feature tool in this IDE.
		
		Known Editor Bugs
		=================
		There are presently bugs in the Eiffel Studio editor that work against good documentation
		exploration in the Clickable-view. Primarily, Tab characters and Unicode characters will
		be removed from the view in Clickable-view, but are shown in the Editable-view. Clearly,
		this behavior is against the purpose of the Clickable-view.
		]"
	glossary: "Definition of Terms"
	term: "[
		Clickable-view: Pick-and-drop a CLASS to the Class-tool and select the Clickable-view
		]"
	term: "[
		In-system: A class is termed "in-system" when it is referenced by a Client, which is
		in-turn referenced by another Client, and all the way back to the "root-class" of the
		system (see Project Settings or ECF file for root-class definition).
		]"
	copyright: "Copyright (c) 2010-2014"
	copying: "[
			All source code and binary programs included in Masking
			are distributed under the terms and conditions of the MIT
			License:

			    The MIT License

			    Copyright (c) 2014

			    Permission is hereby granted, free of charge, to any person obtaining
			    a copy of this software and associated documentation files (the
			    "Software"), to deal in the Software without restriction, including
			    without limitation the rights to use, copy, modify, merge, publish,
			    distribute, sublicense, and/or sell copies of the Software, and to
			    permit persons to whom the Software is furnished to do so, subject to
			    the following conditions:

			    The above copyright notice and this permission notice shall be included
			    in all copies or substantial portions of the Software.

			    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
			    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
			    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
			    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
			    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
			    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
			    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

			This license is an OSI Approved License:

			    http://opensource.org/licenses/mit-license.html

			and a GPL-Compatible Free Software License:

			    http://www.gnu.org/licenses/license-list.html#X11License			]"
	source: "[
			Jinny Corp.
			3587 Oakcliff Road, Doraville, GA 30340
			Telephone 770-734-9222, Fax 770-734-0556
		]"
end

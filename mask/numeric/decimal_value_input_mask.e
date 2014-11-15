note
	description: "[
			{NUMERIC_INPUT_MASK} objects that only allow numeric and `.' input.
	how: "[
			See {INPUT_MASK}.

			- Formatting -
			Formatting for the Decimal Mask comes from its `apply_formatting' feature, which uses a {FORMAT_DOUBLE}
			in order to return a formatted decimal to the user.

			See: https://docs.google.com/spreadsheet/ccc?key=0AlbYAXcgX6hLdEJvRGpRMk9kR1lBV0hoNkk4Y0FmVlE&usp=drive_web#gid=0
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

class
	DECIMAL_VALUE_INPUT_MASK

inherit
	NUMERIC_INPUT_MASK [DECIMAL, DECIMAL_COLUMN_METADATA]
		redefine
			is_valid_constraint,
			remove_implementation,
			fix_pointer_position_implementation,
			format_as_number,
			handle_key_back_space,
			handle_key_delete,
			handle_digit_string,
			handle_key_press,
			handle_key_string,
			right_limit_offset,
			separator_characters,
			total_column_capacity,
			valid_characters_for_mask
		end

create
	make

feature {NONE} -- Initialization

	make (a_scale: like scale; a_capacity: NATURAL_8)
			-- Make decimal input mask with precision `a_scale' decimal places with a full digit capacity
			-- `a_capacity' (the number of integer columns the mask will accept).
		require
			valid_scale: a_scale > 0
			valid_capacity: a_capacity > 0
		do
			scale := a_scale
			capacity := a_capacity
		end

feature -- Access

	scale: NATURAL_8
		-- Scale (or mantissa) of `precision' for current masking.

	default_value: DECIMAL
			-- <Precursor>
		do
			create Result.make_zero
		end

feature -- Status Report

	is_nan_valid: BOOLEAN
			-- Is NAN value for decimal valid?

	is_valid_constraint (a_constraint: detachable DATA_COLUMN_METADATA [ANY]): BOOLEAN
			-- Is `a_constraint' consistent with specification of Current?
		do
			Result := attached {DECIMAL_COLUMN_METADATA} a_constraint as al_real_constraint
				and then capacity <= al_real_constraint.capacity.as_natural_32
				and then scale <= al_real_constraint.scale
		end

feature -- Settings

	set_is_nan_valid (a_is_nan_valid: like is_nan_valid)
			-- Sets `set_nan_valid' with `a_set_nan_valid'.
		do
			is_nan_valid := a_is_nan_valid
		ensure
			is_nan_valid_set: is_nan_valid = a_is_nan_valid
		end

feature -- Event Handling

	handle_key_press (a_key: EV_KEY; a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		do
			inspect
				a_key.code
			when key_numpad_decimal then
				handle_key_string (".", a_widget)
			when key_period then
				if not ev_application.shift_pressed then
					handle_key_string (".", a_widget)
				end
			else
				Precursor (a_key, a_widget)
			end
		end

	handle_key_string (a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_key_string: STRING_32
			l_decimal_position, l_anchor_position, l_new_anchor_position, l_caret_position: INTEGER
		do
			l_key_string := numpad_correction (a_key_string).corrected
			l_anchor_position := anchor_position_from_widget (a_widget)
			l_new_anchor_position := l_anchor_position
			l_caret_position := caret_position_from_widget (a_widget)
			if l_key_string.same_string (">") or else (l_key_string.same_string (".") and then ev_application.shift_pressed) then
				l_decimal_position := a_widget.text.index_of (decimal_point, 1)
				if a_widget.is_editable and a_widget.text_length = 0 then
					a_widget.set_text (refresh_number_formatting ("0"))
					a_widget.set_caret_position (a_widget.text.index_of (decimal_point, 1) + 1)
				elseif a_widget.has_selection then
					if
						(l_caret_position < l_anchor_position and then (((l_anchor_position - 1) = l_decimal_position or else ((l_anchor_position) = l_decimal_position)))) or else
						a_widget.selected_text.count = 1 and then a_widget.selected_text.item (1) = decimal_point
					then
						a_widget.set_caret_position (l_decimal_position + 1)
					elseif l_caret_position < l_anchor_position and l_caret_position < l_decimal_position and then l_anchor_position <= l_decimal_position then
						if is_separator (a_widget.text.item (l_new_anchor_position)) then
							l_new_anchor_position := l_new_anchor_position + 1
						end
						a_widget.set_selection (l_new_anchor_position, l_decimal_position + 1)
					elseif l_caret_position < l_anchor_position then
						a_widget.set_selection (l_anchor_position, l_decimal_position + 1)
					elseif l_caret_position > l_anchor_position and l_anchor_position < l_decimal_position then
						if is_separator (a_widget.text.item (l_new_anchor_position)) then
							l_new_anchor_position := l_new_anchor_position + 1
						end
						a_widget.set_selection (l_new_anchor_position, l_decimal_position + 1)
					elseif l_caret_position > l_anchor_position and then a_widget.text.item (l_caret_position - 1) = decimal_point then
						do_nothing
					elseif l_caret_position > l_decimal_position and l_anchor_position > l_decimal_position then
						if l_anchor_position = (l_decimal_position + 1) and l_anchor_position < l_caret_position then
							a_widget.set_caret_position (l_decimal_position + 1)
						else
							a_widget.set_selection (l_anchor_position, l_decimal_position + 1)
						end
					elseif l_caret_position = l_decimal_position then
						a_widget.set_selection (l_anchor_position, l_decimal_position + 2)
					else
						a_widget.set_caret_position (l_decimal_position + 1)
					end
				else
					if l_caret_position < l_decimal_position then
						if is_separator (a_widget.text.item (l_caret_position)) then
							l_new_anchor_position := l_caret_position + 1
						end
						a_widget.set_selection (l_new_anchor_position, l_decimal_position + 1)
					elseif l_caret_position > (l_decimal_position + 1) then
						a_widget.set_selection (l_caret_position, l_decimal_position + 1)
					else
						a_widget.set_caret_position (l_decimal_position + 1)
					end
				end
			elseif a_widget.is_editable and l_key_string.same_string (create {STRING_32}.make_filled (decimal_point, 1)) then
				if a_widget.text_length = 0 then
					a_widget.set_text (refresh_number_formatting ("0"))
				end
				a_widget.set_caret_position (a_widget.text.index_of (decimal_point, 1) + 1)
			elseif (a_widget.is_editable and a_widget.text_length = 0) and then l_key_string.same_string (create {STRING_32}.make_filled (negative_sign, 1)) then
				a_widget.set_text (create {STRING_32}.make_filled (negative_sign, 1) + refresh_number_formatting ("0"))
				a_widget.set_caret_position (3)
			else
				Precursor (a_key_string, a_widget)
			end
		end

	handle_key_back_space (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_decimal_point_index, l_caret_position, l_caret_offset: INTEGER
			l_digit_count: like digit_count
			l_prefix, l_suffix, l_decimal_point, l_new_text: STRING_32
		do
			if a_widget.is_editable and a_widget.text_length > 0 then
				l_decimal_point_index := a_widget.text.index_of (decimal_point, 1)
				l_caret_position := a_widget.caret_position
				check
					valid_decimal_point_index: 1 < l_decimal_point_index and then l_decimal_point_index < a_widget.text_length
				end
				l_digit_count := digit_count (a_widget.text)
				if a_widget.has_selection and then is_nan_valid and then a_widget.selected_text.count = a_widget.text_length then
					a_widget.set_text ("")
					a_widget.set_caret_position (1)
				elseif
					(not a_widget.has_selection and then ev_application.ctrl_pressed and then a_widget.caret_position > 1 and then a_widget.caret_position >= (l_decimal_point_index)) or else
					((not a_widget.has_selection) and then (l_digit_count.integer = 1) and then (l_caret_position = l_decimal_point_index)) or else
					(a_widget.has_selection and then ((a_widget.start_selection = 1) or ((a_widget.start_selection = 2) and then a_widget.text.item (1) = negative_sign)) and then a_widget.end_selection >= (l_decimal_point_index))
				then
					if
						(a_widget.text.item (1) = negative_sign) and then
						((not a_widget.has_selection and then not ev_application.ctrl_pressed) or else
						(a_widget.has_selection and then a_widget.start_selection = 2))
					then
						create l_prefix.make_filled (negative_sign, 1)
					else
						create l_prefix.make_empty
						l_caret_offset := -1
					end

					if a_widget.has_selection and then a_widget.end_selection - 1 < a_widget.text_length then
						l_suffix := a_widget.text.substring (a_widget.end_selection, a_widget.text_length)
					elseif not a_widget.has_selection and then a_widget.caret_position > a_widget.text_length then
						l_suffix := "0"
					elseif not a_widget.has_selection then
						l_suffix := a_widget.text.substring (a_widget.caret_position, a_widget.text_length)
					else
						create l_suffix.make_empty
					end
					if not l_suffix.has (decimal_point) then
						create l_decimal_point.make_filled (decimal_point, 1)
					else
						create l_decimal_point.make_empty
					end
					a_widget.set_text (refresh_number_formatting (l_prefix + "0" + l_decimal_point + l_suffix))
					a_widget.set_caret_position (3 + l_caret_offset)
				elseif a_widget.has_selection then
					if a_widget.selected_text.count = 1 and then a_widget.selected_text.item (1) = decimal_point then
						a_widget.deselect_all
						a_widget.set_caret_position (l_decimal_point_index)
					elseif a_widget.end_selection - 1 >= l_decimal_point_index  then
						if a_widget.start_selection > 1 then
							l_prefix := a_widget.text.substring (1, a_widget.start_selection - 1)
						else
							create l_prefix.make_empty
						end
						if a_widget.end_selection - 1 < a_widget.text_length then
							l_suffix := a_widget.text.substring (a_widget.end_selection, a_widget.text_length)
						else
							create l_suffix.make_empty
						end
						if a_widget.selected_text.has (decimal_point) then
							create l_decimal_point.make_filled (decimal_point, 1)
						else
							create l_decimal_point.make_empty
							l_caret_offset := a_widget.start_selection - l_decimal_point_index
						end
						l_new_text := refresh_number_formatting (l_prefix + l_decimal_point + l_suffix)
						l_caret_position := l_new_text.index_of (decimal_point, 1)
						a_widget.set_text (l_new_text)
						a_widget.set_caret_position (l_caret_position + l_caret_offset)
					else
						Precursor (a_widget)
					end
				else
					if l_caret_position = (l_decimal_point_index + 1) then
						a_widget.set_caret_position (l_decimal_point_index)
						Precursor (a_widget)
					elseif l_caret_position = (l_decimal_point_index + 1) then
						a_widget.set_caret_position (l_decimal_point_index)
					elseif l_caret_position > l_decimal_point_index then
						Precursor (a_widget)
						a_widget.set_caret_position (l_caret_position - 1)
					else
						Precursor (a_widget)
					end
				end
			end
		end

	handle_key_delete (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_digit_count: like digit_count
			l_decimal_index, l_new_caret_position: INTEGER
			l_zero_text, l_text_before, l_text_after, l_new_text, l_decimal_point: STRING_32
			l_is_negative, l_stays_negative: BOOLEAN
		do
			if a_widget.is_editable and a_widget.text_length > 0 then
				l_is_negative := a_widget.text.item (1).is_equal (negative_sign)
				l_decimal_index := a_widget.text.index_of (decimal_point, 1)
				if
					is_nan_valid and then
					((not a_widget.has_selection and then ev_application.ctrl_pressed and then a_widget.caret_position = 1) or else
					(a_widget.has_selection and then (a_widget.text_length = a_widget.selected_text.count)))
				then
					a_widget.set_text ("")
					a_widget.set_caret_position (1)
				elseif not a_widget.has_selection
					and not ev_application.ctrl_pressed
					and ((not l_is_negative and a_widget.caret_position = 1) or (l_is_negative and a_widget.caret_position = 2)) then

					l_digit_count := digit_count (a_widget.text)
					if l_digit_count.integer = 1 then
						if not l_is_negative or a_widget.text.to_double = 0.0 then
							l_zero_text := "0."
						else
							l_zero_text := "-0."
						end
						a_widget.set_text (l_zero_text + a_widget.text.substring (a_widget.text.index_of (decimal_point, 1) + 1, a_widget.text_length))
						a_widget.set_caret_position (a_widget.text.index_of (decimal_point, 1))
					else
						Precursor (a_widget)
					end
				elseif a_widget.has_selection and then a_widget.selected_text.has (decimal_point) then
					if a_widget.start_selection > 1 then
						l_text_before := a_widget.text.substring (1, a_widget.start_selection - 1)
					else
						l_text_before := ""
					end
					if a_widget.end_selection - 1 < a_widget.text_length then
						l_text_after := a_widget.text.substring (a_widget.end_selection, a_widget.text_length)
					else
						l_text_after := ""
					end
					l_new_text := l_text_before + create {STRING_32}.make_filled (decimal_point, 1) + l_text_after
					l_new_text := refresh_number_formatting (l_new_text)
					a_widget.set_text (refresh_number_formatting (l_new_text))
					a_widget.set_caret_position (l_new_text.index_of (decimal_point, 1) + 1)
				else
					if a_widget.has_selection and then a_widget.caret_position > l_decimal_index then
						l_new_caret_position := (a_widget.start_selection).min (a_widget.text_length)
					elseif not ev_application.ctrl_pressed and then not a_widget.has_selection and a_widget.text.valid_index (a_widget.caret_position) and then a_widget.text.item (a_widget.caret_position) = decimal_point then
						a_widget.set_caret_position (a_widget.caret_position + 1)
					end
					l_stays_negative := (not a_widget.has_selection and then a_widget.caret_position > 1) or else (a_widget.has_selection and then not a_widget.selected_text.has (negative_sign))
					if ev_application.ctrl_pressed and then not a_widget.has_selection then
						if a_widget.caret_position <= l_decimal_index then
							create l_decimal_point.make_filled (decimal_point, 1)
						else
							create l_decimal_point.make_empty
							l_new_caret_position := a_widget.caret_position
						end
						if not a_widget.text.is_empty and then a_widget.text.item (1) = negative_sign and then a_widget.caret_position = 2 then
							l_text_before := create {STRING_32}.make_filled (negative_sign, 1) + create {STRING_32}.make_filled ('0', 1)
						elseif a_widget.caret_position > 1 then
							l_text_before := a_widget.text.substring (1, a_widget.caret_position - 1)
						else
							create l_text_before.make_filled ('0', 1)
						end
						a_widget.set_text (refresh_number_formatting (l_text_before + l_decimal_point))
						if not l_decimal_point.is_empty then
							l_new_caret_position := a_widget.text.index_of (decimal_point, 1)
						end
					else
						Precursor (a_widget)
					end
					if l_is_negative and then l_stays_negative and then a_widget.text.item (1) /= negative_sign then
						a_widget.set_text (create {STRING_32}.make_filled (negative_sign, 1) + a_widget.text)
					end
					if l_new_caret_position > 0 then
						a_widget.set_caret_position (l_new_caret_position)
					end
				end
			end
		end

	handle_digit_string (a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_decimal_point_position, l_caret_position, l_caret_offset: INTEGER
			l_text_before, l_text_after, l_new_text, l_decimal_point_before, l_decimal_point_after:  STRING_32
			l_digit_count: like digit_count
		do
			l_decimal_point_position := a_widget.text.index_of (decimal_point, 1)
			l_caret_position := a_widget.caret_position
			if a_widget.has_selection and then a_widget.end_selection <= l_decimal_point_position then
				Precursor (a_key_string, a_widget)
			elseif a_widget.is_editable and a_widget.has_selection then
				l_digit_count := digit_count (a_widget.text)
				if a_widget.selected_text.item (1) = decimal_point and then a_widget.selected_text.count > 1 then
					create l_decimal_point_before.make_filled (decimal_point, 1)
					l_decimal_point_after := ""
				elseif a_widget.selected_text.has (decimal_point) then
					l_decimal_point_before := ""
					create l_decimal_point_after.make_filled (decimal_point, 1)
				else
					l_decimal_point_before := ""
					l_decimal_point_after := ""
				end
				if l_digit_count.integer < capacity or else selection_includes_digit (a_widget) then
					if a_widget.start_selection > 1 then
						l_text_before := a_widget.text.substring (1, a_widget.start_selection - 1)
					else
						l_text_before := ""
					end
					if a_widget.end_selection - 1 < a_widget.text_length then
						l_text_after := a_widget.text.substring (a_widget.end_selection, a_widget.text_length)
					else
						l_text_after := ""
					end
					l_new_text := refresh_number_formatting (l_text_before + l_decimal_point_before + a_key_string + l_decimal_point_after + l_text_after)
					if l_decimal_point_before.is_empty and then l_decimal_point_after.is_empty and then a_widget.end_selection - 1 < l_decimal_point_position then
						l_decimal_point_position := (l_new_text.index_of(decimal_point, 1) - (l_decimal_point_position - a_widget.end_selection - 2)).max (1)
					elseif l_decimal_point_before.is_empty and then l_decimal_point_after.is_empty then
						l_decimal_point_position := (a_widget.start_selection + 1).min (a_widget.text_length)
					elseif l_decimal_point_after.is_empty and then a_widget.selected_text.item (1) = decimal_point then
						l_decimal_point_position := l_new_text.index_of (decimal_point, 1) + 2
					elseif l_decimal_point_after.is_empty then
						l_decimal_point_position := (a_widget.end_selection).min (a_widget.text_length)
					else
						l_decimal_point_position := l_new_text.index_of (decimal_point, 1)
					end
					a_widget.set_text (l_new_text)
					a_widget.set_caret_position (l_decimal_point_position)
				end
			elseif l_caret_position <= l_decimal_point_position then
				l_digit_count := digit_count (a_widget.text)
				if
					l_digit_count.integer = 1 and then
					(a_widget.caret_position = 3 and then (a_widget.text.item (1) = negative_sign) and then a_widget.text.item (2) = '0')
					-- (a_widget.caret_position = 2 and then (a_widget.text.item (1) = '0')) or else
				then
					l_caret_offset := -1
				end
				Precursor (a_key_string, a_widget)
				a_widget.set_caret_position (a_widget.caret_position + l_caret_offset)
			elseif a_widget.is_editable and l_caret_position <= a_widget.text_length then
				if l_caret_position <= a_widget.text_length - 1 then
					l_text_after := a_widget.text.substring (l_caret_position, a_widget.text_length - 1)
					l_caret_offset := 1
				else
					l_text_after := ""
				end
				a_widget.set_text (a_widget.text.substring (1, l_caret_position - 1) + a_key_string + l_text_after)
				a_widget.set_text (refresh_number_formatting (a_widget.text))
				a_widget.set_caret_position (l_caret_position + l_caret_offset)
			elseif a_widget.is_editable and a_widget.text_length = 0 then
				a_widget.set_text (refresh_number_formatting (a_key_string))
				a_widget.set_caret_position (a_widget.text.index_of (decimal_point, 1))
			end
		end

	fix_pointer_position_implementation (a_widget: EV_TEXT_COMPONENT)
			-- Ensure user has not used mouse to place caret in an illegal position for this mask
		do
			if not a_widget.has_selection and then not a_widget.text.is_empty then
				if a_widget.caret_position > a_widget.text_length then
					a_widget.set_caret_position (a_widget.text_length)
				elseif a_widget.text.valid_index (a_widget.caret_position) and then a_widget.text.item (a_widget.caret_position) = thousands_separator then
					a_widget.set_caret_position (a_widget.caret_position + 1)
				end
			end
		end

feature {TEST_SET_BRIDGE} -- Implementation

	remove_implementation (a_string: STRING_32; a_constraint: detachable DECIMAL_COLUMN_METADATA): TUPLE [value: DECIMAL; error_message: STRING_32]
			-- <Precursor>
			--| Currently does not report presence of illegal characters in `a_string'
		local
			l_string, l_error_message: STRING_32
			l_value: DECIMAL
			l_text_is_too_long, l_has_invalid_characters: BOOLEAN
			l_decimal_index: INTEGER
		do
			l_string := remove_formatting (a_string)
			l_string.left_adjust
			l_string.right_adjust
			if l_string.is_empty then
				if is_nan_valid then
					Result := [(create {DECIMAL}.make_zero).nan, ("").as_string_32]
				else
					Result := [create {DECIMAL}.make_zero, masking_messages.decimal_field_nan_invalid_sentence.to_string_32]
				end
			else
				l_value := string_to_value (l_string)

				across l_string as ic_items loop
					if not is_valid_character_for_mask (ic_items.item) then
						l_has_invalid_characters := True
					end
					if ic_items.item ~ '.' then
						l_decimal_index := ic_items.cursor_index
					end
				end

				if l_string.count > capacity or else l_string.substring (l_decimal_index + 1, l_string.count).count > scale then
					l_text_is_too_long := True
				end

				if l_text_is_too_long then
					l_error_message := data_does_not_conform_to_mask_specification_message (l_string, capacity)
				elseif l_has_invalid_characters then
					l_error_message := translated_string (masking_messages.invalid_changes_message, [])
				else
					l_error_message := ""
				end
				Result := [l_value, l_error_message]
			end
		end

	format_as_number (a_string: STRING_32): STRING_32
			-- <Precursor>
		local
			l_formatted_decimal: FORMAT_DOUBLE
		do
			create l_formatted_decimal.make (capacity, scale)
			l_formatted_decimal.comma_separate
			l_formatted_decimal.point_decimal
			l_formatted_decimal.no_separate_after_decimal
			l_formatted_decimal.no_justify
			if (a_string.is_empty and not is_nan_valid) or else a_string ~ "." or else a_string ~ "-" then
				Result := l_formatted_decimal.formatted (("0.0").to_real_64).out.to_string_32
				if a_string ~ "-" then
					Result := "-" + Result
				end
			elseif not a_string.is_empty then
				Result := l_formatted_decimal.formatted (a_string.to_real_64).out.to_string_32
				if a_string.item (1) = negative_sign and then Result.item (1) /= negative_sign then
					Result.prepend_character (negative_sign)
				end
			else
				Result := ""
			end
		end

	initial_mask: STRING
			-- Initial starting portion of mask for `Current'.
		do
			Result := ":"
		end

	string_to_value (a_string: READABLE_STRING_GENERAL): DECIMAL
			-- <Precursor>
		local
			l_string: STRING_32
		do
			l_string := remove_formatting (a_string.to_string_32)
			if l_string.is_double then
				Result := l_string.as_string_8
			else
				create Result.make_zero
			end
		end

	value_to_string (a_value: DECIMAL): READABLE_STRING_GENERAL
			-- String representation of `a_value'.
		do
			if a_value.is_special and then is_nan_valid then
				Result := ""
			elseif a_value.is_special then
				if a_value.is_negative then
					Result := a_value.negative_zero.round_to (scale).to_scientific_string
				else
					Result := a_value.zero.round_to (scale).to_scientific_string
				end
			else
				Result := a_value.round_to (scale).to_scientific_string
			end
		end

	valid_characters_for_mask: STRING_32
			-- Characters that are valid for Current.
		do
			create Result.make_from_string ("-1234567890.")
		end

	data_exceeds_column_constraint_message (a_result: DECIMAL; a_constraint: DATA_COLUMN_METADATA [ANY]): STRING_32
		do
			Result := translated_string (masking_messages.integer_entered_too_large_message, [a_result.out, (a_constraint.capacity ^ 10) - 1])
		end

	separator_characters: ARRAY [CHARACTER_32]
			-- <Precursor>
		once
			Result := <<thousands_separator, decimal_point>>
		ensure then
			result_has_period: result.has (decimal_point)
		end

	right_limit_offset: INTEGER
			-- <Precursor>
		do
			Result := 0
		end

	total_column_capacity: INTEGER
			-- <Precursor>
		do
			Result := capacity + scale + 1
		end

	fits_in_mask (a_text: STRING_32): BOOLEAN
			-- Does `a_text' fit in the current mask?
		local
			l_digit_count: like digit_count
		do
			l_digit_count := digit_count (a_text)
			Result := l_digit_count.integer <= capacity and then l_digit_count.decimal <= scale
		end

note
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

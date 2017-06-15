note
	description: "[
			An Abstract Date Time Input Mask is an {INPUT_MASK} specialized to only allow date/datetime input.
			]"
	purpose: "[			
			Some fields need to permit only date/datetime input.
			Handles intra-field processing of Day, Month, and Year fields.
			Handles inter-field cursor movements for fields in arbitrary order.
			Handles cursor position corrections.
			]"
	how: "[
			See {INPUT_MASK}.
			]"
	generic_definition: "V -> detachable ANY Value; CON -> Type of the DATA_COLUMN_METADATA to use as a constraint"
	date: "$Date: 2015-12-19 10:26:15 -0500 (Sat, 19 Dec 2015) $"
	revision: "$Revision: 12868 $"

deferred class
	ABSTRACT_DATE_TIME_INPUT_MASK [V -> detachable ANY, reference CON -> detachable DATA_COLUMN_METADATA [ANY]]

inherit
	INPUT_MASK [V, CON]
		redefine
			is_valid_character_for_mask,
			handle_key_press,
			handle_key_string,
			handle_paste
		end

	DATE_TIME_CONSTANTS

feature -- Status Report

	is_valid_character_for_mask (a_character: CHARACTER_32): BOOLEAN
			-- <Precursor>
		do
			Result := valid_characters_for_mask.has (a_character)
		end

	is_pasting: BOOLEAN
			-- Is current in a paste operation?

feature -- Event handling

	handle_key_press (a_key: EV_KEY; a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		do
			inspect
				a_key.code
			when key_numpad_divide then
				handle_key_string ("/", a_widget)
			when key_slash then
				if not ev_application.shift_pressed then
					handle_key_string ("/", a_widget)
				end
			else
				Precursor (a_key, a_widget)
			end
		end

	handle_key_string (a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- Process a key press string event from `a_widget'.
		do
			if not (a_key_string.has_substring ("NumPad") and is_shift_pressed) then
				Precursor (numpad_correction (a_key_string).corrected, a_widget)
			end
		end

	handle_paste (a_widget: EV_TEXT_COMPONENT)
			-- (from INPUT_MASK)
		do
			is_pasting := True
			Precursor (a_widget)
			is_pasting := False
		end

	handle_key_left (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_anchor_position, l_caret_position, l_new_anchor_position, l_new_caret_position: INTEGER
			l_has_selection: BOOLEAN
			l_input_state: DATE_TIME_INPUT_STATE
		do
				-- Retrieve caret positions of selection if any and store selection state.
			l_anchor_position := anchor_position_from_widget (a_widget)
			l_caret_position := caret_position_from_widget (a_widget)
			l_has_selection := a_widget.has_selection

			l_new_anchor_position := l_anchor_position
			l_new_caret_position := l_caret_position

			if not (is_alt_pressed or else (is_shift_pressed and then l_caret_position = 1)) then
					-- No caret/selection handling if alt/option key is pressed.
				create l_input_state.make (a_widget, format, [is_shift_pressed, is_control_pressed, is_alt_pressed])
				l_input_state.split_widget_into_fields

				if l_caret_position > 1 then
						-- If caret is at the first position then no manipulation of caret is necessary.
					if l_has_selection then
						if is_control_pressed then
							l_caret_position := l_anchor_position.min (l_caret_position)
							if format = format_month_day then
								if l_caret_position > l_input_state.separator_index_1 + 1 then
									l_new_caret_position := l_input_state.separator_index_1 + 1
								else
									l_new_caret_position := 1
								end
							elseif format = format_month_day_year then
								if l_caret_position > l_input_state.separator_index_2 + 1 then
									l_new_caret_position := l_input_state.separator_index_2 + 1
								elseif l_caret_position > l_input_state.separator_index_1 + 1 then
									l_new_caret_position := l_input_state.separator_index_1 + 1
								else
									l_new_caret_position := 1
								end
							end
						elseif not is_shift_pressed then
								-- Remove the existing selection by setting the caret position to the leftmost selection index.
							l_new_caret_position := l_anchor_position.min (l_caret_position)
						else
							l_new_caret_position := l_new_caret_position - 1
						end
					else
							-- no selection
						if is_control_pressed then
							if format = format_month_day then
									-- FIXME model format_month_day_year below
								if l_caret_position > l_input_state.separator_index_1 + 1 then
									l_new_caret_position := l_input_state.separator_index_1 + 1
								elseif l_caret_position = l_input_state.separator_index_1 + 1 then
									if l_input_state.month_field.count = 2 then
										l_new_caret_position := l_input_state.separator_index_1 - 1
									else
										l_new_caret_position := l_input_state.separator_index_1
									end
								else
									l_new_caret_position := 1
								end
							elseif format = format_month_day_year then
								if l_caret_position > l_input_state.separator_index_2 + 1 then
									l_new_caret_position := l_input_state.separator_index_2 + 1
								elseif l_caret_position > l_input_state.separator_index_1 + 1 then
									l_new_caret_position := l_input_state.separator_index_1 + 1
								else
									l_new_caret_position := 1
								end
							end
						else
							l_new_caret_position := l_new_caret_position - 1

								-- FIXME remove this and update month day csv file, retest
							if not is_shift_pressed and format = format_month_day and l_input_state.day_field_caret_position = 1 and l_input_state.month_field.count = 2 then
								l_new_caret_position := l_new_caret_position - 1
							end
						end
					end
				end
				if not is_shift_pressed then
						-- Retain new anchor position only if shift is pressed.
					l_new_anchor_position := l_new_caret_position
				end

					-- Handle caret and selection positioning.
				set_selection_in_widget (l_input_state.widget, l_new_anchor_position, l_new_caret_position)
			end
		end

	handle_key_right (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_anchor_position, l_caret_position, l_new_anchor_position, l_new_caret_position: INTEGER
			l_has_selection: BOOLEAN
			l_input_state: DATE_TIME_INPUT_STATE
		do
				-- Retrieve caret positions of selection if any and store selection state.
			l_anchor_position := anchor_position_from_widget (a_widget)
			l_caret_position := caret_position_from_widget (a_widget)
			l_has_selection := a_widget.has_selection

			l_new_anchor_position := l_anchor_position
			l_new_caret_position := l_caret_position

			if not is_alt_pressed then
					-- No caret/selection handling if alt/option key is pressed.
				create l_input_state.make (a_widget, format, [is_shift_pressed, is_control_pressed, is_alt_pressed])
				l_input_state.split_widget_into_fields

				if l_has_selection then
					if is_control_pressed then
						l_caret_position := l_anchor_position.max (l_caret_position)
						if format = format_month_day then
							if l_caret_position >= l_input_state.separator_index_1 then
								if is_shift_pressed then
									if l_new_anchor_position = l_input_state.widget.text_length + 1 then
										l_new_caret_position := l_input_state.widget.text_length
										l_new_anchor_position := l_new_caret_position
									else
										l_new_caret_position := l_input_state.widget.text_length + 1
									end
								else
									l_new_caret_position := l_input_state.widget.text_length
								end
							else
								l_new_caret_position := l_input_state.separator_index_1
							end
						elseif format = format_month_day_year then
							if l_caret_position >= l_input_state.separator_index_2 then
								if is_shift_pressed then
									if l_new_anchor_position = l_input_state.widget.text_length + 1 then
										l_new_caret_position := l_input_state.widget.text_length
										l_new_anchor_position := l_new_caret_position
									else
										l_new_caret_position := l_input_state.widget.text_length + 1
									end
								else
									l_new_caret_position := l_input_state.widget.text_length
								end
							elseif l_caret_position >= l_input_state.separator_index_1 then
								l_new_caret_position := l_input_state.separator_index_2
							else
								l_new_caret_position := l_input_state.separator_index_1
							end
						end
					elseif is_shift_pressed then
						if l_new_caret_position = l_input_state.widget.text_length and l_new_anchor_position = l_input_state.widget.text_length + 1 then
							l_new_caret_position := l_input_state.widget.text_length
							l_new_anchor_position := l_new_caret_position
						elseif l_new_caret_position <= l_input_state.widget.text_length then
							l_new_caret_position := l_new_caret_position + 1
						end
					else
							-- Remove the existing selection by setting the caret position to the rightmost selection index.
						l_new_caret_position := l_anchor_position.max (l_caret_position)
						l_new_caret_position := l_input_state.widget.text_length.min (l_new_caret_position)
					end
				else
						-- no selection
					if not is_control_pressed then
						if format = format_month_day then
							if l_input_state.month_field_caret_position > 0 then -- caret started in month field
								l_new_caret_position := l_new_caret_position + 1

									-- FIXME remove this if block, update month day csv file, retest
								if not is_shift_pressed and l_input_state.month_field.count = 2 and l_input_state.widget_caret_position = l_input_state.separator_index_1 - 1 then
									l_new_caret_position := l_new_caret_position + 1
								end
							else -- caret started in day field
									-- If caret is at the last position then no manipulation of caret is necessary.
									-- Last position is day_field_caret_position = 2
								if is_shift_pressed and l_input_state.widget_caret_position <= l_input_state.widget.text_length then
									l_new_caret_position := l_new_caret_position + 1
								elseif not is_shift_pressed and l_input_state.day_field_caret_position = 1 and not l_input_state.day_field.is_empty then
									l_new_caret_position := l_new_caret_position + 1
								end
							end
						elseif format = format_month_day_year then
							if is_shift_pressed and l_input_state.widget_caret_position <= l_input_state.widget.text_length then
								l_new_caret_position := l_new_caret_position + 1
							elseif not is_shift_pressed and
								((l_input_state.widget_caret_position < l_input_state.widget.text_length) or
								(l_input_state.widget_caret_position = l_input_state.widget.text_length and l_input_state.year_field.count < 4)) then

								l_new_caret_position := l_new_caret_position + 1
							end
						end
					else -- is_control_pressed
						if format = format_month_day then
							if l_input_state.month_field_caret_position > 0 then -- caret in month field
								if not is_shift_pressed or (is_shift_pressed and l_input_state.month_field_caret_position = l_input_state.separator_index_1) then
									l_new_caret_position := l_input_state.separator_index_1 + 1
								else
									l_new_caret_position := l_input_state.separator_index_1
								end
							else
								if is_shift_pressed or l_input_state.day_field.count < 2 then
									l_new_caret_position := l_input_state.widget.text_length + 1
								else
									l_new_caret_position := l_input_state.widget.text_length
								end
							end
						elseif format = format_month_day_year then
							if l_input_state.month_field_caret_position > 0 then -- caret in month field
								if l_input_state.widget_caret_position = l_input_state.separator_index_1 then
									l_new_caret_position := l_input_state.separator_index_2
								else
									l_new_caret_position := l_input_state.separator_index_1
								end
							elseif l_input_state.day_field_caret_position > 0 then -- caret in day field
								if l_input_state.widget_caret_position = l_input_state.separator_index_2 then
									if is_shift_pressed or l_input_state.year_field.count < 4 then
										l_new_caret_position := l_input_state.widget.text_length + 1
									else
										l_new_caret_position := l_input_state.widget.text_length
									end
								else
									l_new_caret_position := l_input_state.separator_index_2
								end
							else
								if is_shift_pressed or l_input_state.year_field.count < 4 then
									l_new_caret_position := l_input_state.widget.text_length + 1
								else
									l_new_caret_position := l_input_state.widget.text_length
								end
							end
						end
					end
				end
				if not is_shift_pressed then
						-- Retain initial selection only if shift is pressed.
					l_new_anchor_position := l_new_caret_position
				end

					-- Handle caret and selection positioning.
				set_selection_in_widget (l_input_state.widget, l_new_anchor_position, l_new_caret_position)
			end
		end

	handle_key_home (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_new_anchor_position, l_new_caret_position, l_left_caret_position: INTEGER
			l_input_state: DATE_TIME_INPUT_STATE
		do
			l_new_anchor_position := anchor_position_from_widget (a_widget).max (1)
			l_new_caret_position := 1
			create l_input_state.make (a_widget, format, [is_shift_pressed, is_control_pressed, is_alt_pressed])
			l_input_state.split_widget_into_fields

			if not is_control_pressed then
				if format = format_month_day then
					if l_input_state.day_field_caret_position > 0 and then l_input_state.widget_caret_position /= l_input_state.separator_index_1 + 1 then
						l_new_caret_position := l_input_state.separator_index_1 + 1
					end
				elseif format = format_month_day_year then
					l_left_caret_position := l_input_state.widget_caret_position.min (l_new_anchor_position)
					if l_left_caret_position <= l_input_state.separator_index_1 + 1 then
						-- l_new_caret_position already is 1					
					elseif l_left_caret_position <= l_input_state.separator_index_2 + 1 then
						l_new_caret_position := l_input_state.separator_index_1 + 1
					elseif l_input_state.year_field_caret_position > 0 then
						l_new_caret_position := l_input_state.separator_index_2 + 1
					end
				end
			end

			if not is_shift_pressed then
					-- Retain initial selection only if shift is pressed.
				l_new_anchor_position := l_new_caret_position
			end
				-- Handle caret and selection positioning.
			set_selection_in_widget (l_input_state.widget, l_new_anchor_position, l_new_caret_position)
		end

	handle_key_end (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_caret_position, l_new_anchor_position, l_new_caret_position, l_right_caret_position: INTEGER
			l_input_state: DATE_TIME_INPUT_STATE
		do
			l_caret_position := caret_position_from_widget (a_widget)
			l_new_anchor_position := anchor_position_from_widget (a_widget)
			create l_input_state.make (a_widget, format, [is_shift_pressed, is_control_pressed, is_alt_pressed])
			l_input_state.split_widget_into_fields

			if format = format_month_day then
				if not is_control_pressed and l_input_state.month_field_caret_position > 0 then
					if l_caret_position = l_input_state.separator_index_1 then
						if l_input_state.day_field.count = 2 and not is_shift_pressed then
							l_new_caret_position := l_input_state.widget.text_length
						else
							if l_caret_position /= l_new_anchor_position and l_new_anchor_position = l_input_state.widget.text_length + 1 then
								l_new_caret_position := l_input_state.widget.text_length
								l_new_anchor_position := l_new_caret_position
							else
								l_new_caret_position := l_input_state.widget.text_length + 1
							end
						end
					else
						l_new_caret_position := l_input_state.separator_index_1
					end
				else
					if not is_shift_pressed then
						if l_input_state.day_field.count = 2 then
							l_new_caret_position := l_input_state.widget.text_length
						else
							l_new_caret_position := l_input_state.widget.text_length + 1
						end
					else
						if l_caret_position /= l_new_anchor_position and l_new_anchor_position = l_input_state.widget.text_length + 1 then
							l_new_caret_position := l_input_state.widget.text_length
							l_new_anchor_position := l_new_caret_position
						else
							l_new_caret_position := l_input_state.widget.text_length + 1
						end
					end
				end
			elseif format = format_month_day_year then
				l_right_caret_position := l_caret_position.max (l_new_anchor_position)
				if not is_control_pressed then -- and l_input_state.day_field_caret_position > 0 then
					if l_right_caret_position >= l_input_state.separator_index_2 then
						if l_input_state.year_field.count = 4 and not is_shift_pressed then
							l_new_caret_position := l_input_state.widget.text_length
						else
							if l_caret_position /= l_new_anchor_position and l_new_anchor_position = l_input_state.widget.text_length + 1 then
								l_new_caret_position := l_input_state.widget.text_length
								l_new_anchor_position := l_new_caret_position
							else
								l_new_caret_position := l_input_state.widget.text_length + 1
							end
						end
					elseif l_right_caret_position >= l_input_state.separator_index_1 then
						l_new_caret_position := l_input_state.separator_index_2
					else
						l_new_caret_position := l_input_state.separator_index_1
					end
				else
					if not is_shift_pressed then
						if l_input_state.year_field.count = 4 then
							l_new_caret_position := l_input_state.widget.text_length
						else
							l_new_caret_position := l_input_state.widget.text_length + 1
						end
					else
						if l_caret_position /= l_new_anchor_position and l_new_anchor_position = l_input_state.widget.text_length + 1 then
							l_new_caret_position := l_input_state.widget.text_length
							l_new_anchor_position := l_new_caret_position
						else
							l_new_caret_position := l_input_state.widget.text_length + 1
						end
					end
				end
			end

			if not is_shift_pressed then
					-- Retain initial selection only if shift is pressed.
				l_new_anchor_position := l_new_caret_position
			end
				-- Handle caret and selection positioning.
			set_selection_in_widget (l_input_state.widget, l_new_anchor_position, l_new_caret_position)
		end

	handle_key_back_space (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_has_selection: BOOLEAN
			l_caret_delta: INTEGER
			l_input_state: DATE_TIME_INPUT_STATE
		do
			l_has_selection := a_widget.has_selection

			if a_widget.is_editable then
				create l_input_state.make (a_widget, format, [is_shift_pressed, is_control_pressed, is_alt_pressed])
				if l_has_selection then
					l_input_state.split_widget_with_selection_into_fields
				else
					l_input_state.split_widget_into_fields

						-- TODO Refactor
					if format = format_month_day then
							-- determine which field the cursor is in
						if l_input_state.month_field_caret_position = 1 then
							do_nothing
						else
							if l_input_state.month_field_caret_position > 1 then	-- month_field
								if is_control_pressed then
										-- delete all characters to left of cursor in month field
									l_input_state.month_field.remove_substring (1, l_input_state.month_field_caret_position - 1)
									l_caret_delta := l_input_state.month_field_caret_position - 1
								else
										-- delete 1 character to left of cursor in month field
									l_input_state.month_field.remove (l_input_state.month_field_caret_position - 1)
									l_caret_delta := 1
								end
							else	-- day_field
								if l_input_state.day_field_caret_position = 1 then
									if is_control_pressed then
										l_caret_delta := l_input_state.month_field.count + 1
											-- delete all characters in month field
										l_input_state.month_field.remove_substring (1, l_input_state.month_field.count)
									else
										if not l_input_state.month_field.is_empty then
											l_input_state.month_field.remove_tail (1)
											l_caret_delta := 1
										end
										l_caret_delta := l_caret_delta + 1
									end
								else
									-- delete character to left of cursor
									if is_control_pressed then
										l_input_state.day_field.remove_substring (1, l_input_state.day_field_caret_position - 1)
										l_caret_delta := l_input_state.day_field_caret_position - 1
									else
										l_input_state.day_field.remove (l_input_state.day_field_caret_position - 1)
										l_caret_delta := 1
									end
								end
							end
						end
					elseif format = format_month_day_year then
							-- determine which field the cursor is in
						if l_input_state.month_field_caret_position = 1 then
							do_nothing
						else
							if l_input_state.month_field_caret_position > 1 then	-- month_field
								if is_control_pressed then
										-- delete all characters to left of cursor in month field
									l_input_state.month_field.remove_substring (1, l_input_state.month_field_caret_position - 1)
									l_caret_delta := l_input_state.month_field_caret_position - 1
								else
										-- delete 1 character to left of cursor in month field
									l_input_state.month_field.remove (l_input_state.month_field_caret_position - 1)
									l_caret_delta := 1
								end
							elseif l_input_state.day_field_caret_position = 1 then	-- day_field
								if is_control_pressed then
									l_caret_delta := l_input_state.month_field.count + 1
										-- delete all characters in month field
									l_input_state.month_field.remove_substring (1, l_input_state.month_field.count)
								else
									if not l_input_state.month_field.is_empty then
										l_input_state.month_field.remove_tail (1)
										l_caret_delta := 1
									end
									l_caret_delta := l_caret_delta + 1
								end
							elseif l_input_state.day_field_caret_position > 1 then
								-- delete character to left of cursor
									if is_control_pressed then
										l_input_state.day_field.remove_substring (1, l_input_state.day_field_caret_position - 1)
										l_caret_delta := l_input_state.day_field_caret_position - 1
									else
										l_input_state.day_field.remove (l_input_state.day_field_caret_position - 1)
										l_caret_delta := 1
									end
							else	-- year_field
								if l_input_state.year_field_caret_position = 1 then
									if is_control_pressed then
										l_caret_delta := l_input_state.day_field.count + 1
											-- delete all characters in day field
										l_input_state.day_field.remove_substring (1, l_input_state.day_field.count)
									else
										if not l_input_state.day_field.is_empty then
											l_input_state.day_field.remove_tail (1)
											l_caret_delta := 1
										end
										l_caret_delta := l_caret_delta + 1
									end
								else
									-- delete character to left of cursor
									if is_control_pressed then
										l_input_state.year_field.remove_substring (1, l_input_state.year_field_caret_position - 1)
										l_caret_delta := l_input_state.year_field_caret_position - 1
									else
										l_input_state.year_field.remove (l_input_state.year_field_caret_position - 1)
										l_caret_delta := 1
									end
								end
							end
						end
					else
						-- FIXME exception handling
					end
				end

				if l_input_state.widget_caret_position > l_caret_delta then
					l_input_state.decrement_widget_caret_position (l_caret_delta)
				end
				update_text_and_caret_position (l_input_state.widget, l_input_state.combined_fields, l_input_state.widget_caret_position)
			end
		end

	handle_key_delete (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_has_selection: BOOLEAN
			l_caret_delta: INTEGER
			l_input_state: DATE_TIME_INPUT_STATE
			l_selected_text: STRING_32
		do
			l_has_selection := a_widget.has_selection

			if a_widget.is_editable then
				create l_input_state.make (a_widget, format, [is_shift_pressed, is_control_pressed, is_alt_pressed])
				if l_has_selection then
					l_selected_text := l_input_state.widget.selected_text
					l_input_state.split_widget_with_selection_into_fields
					if l_selected_text.has (date_separator) then
						l_caret_delta := l_selected_text.occurrences (date_separator)
					end
				else
					l_input_state.split_widget_into_fields

						-- TODO Refactor
					if format = format_month_day then
							-- determine which field the cursor is in
						if l_input_state.month_field_caret_position > 0 then	-- month_field
							if l_input_state.month_field_caret_position <= l_input_state.month_field.count then
								-- delete character(s) to right of cursor
								if is_control_pressed then
									l_input_state.month_field.remove_substring (l_input_state.month_field_caret_position, l_input_state.month_field.count)
								else
									l_input_state.month_field.remove (l_input_state.month_field_caret_position)
								end
							else
								l_caret_delta := 1
							end
						else	-- day_field
							if l_input_state.day_field_caret_position <= l_input_state.day_field.count then
								l_input_state.day_field.remove (l_input_state.day_field_caret_position)
								if l_input_state.day_field_caret_position = l_input_state.day_field.count then
									l_caret_delta := 1
								end
							end
						end
					elseif format = format_month_day_year then
							-- determine which field the cursor is in
						if l_input_state.month_field_caret_position > 0 then	-- month_field
							if l_input_state.month_field_caret_position <= l_input_state.month_field.count then
								-- delete character(s) to right of cursor
								if is_control_pressed then
									l_input_state.month_field.remove_substring (l_input_state.month_field_caret_position, l_input_state.month_field.count)
								else
									l_input_state.month_field.remove (l_input_state.month_field_caret_position)
								end
							else
								if not l_input_state.day_field.is_empty then
									l_input_state.day_field.remove_head (1)
								end
								l_caret_delta := 1
							end
						elseif l_input_state.day_field_caret_position > 0 then	-- day_field
							if l_input_state.day_field_caret_position <= l_input_state.day_field.count then
								-- delete character(s) to right of cursor
								if is_control_pressed then
									l_input_state.day_field.remove_substring (l_input_state.day_field_caret_position, l_input_state.day_field.count)
								else
									l_input_state.day_field.remove (l_input_state.day_field_caret_position)
								end
							else
								if not l_input_state.year_field.is_empty then
									if is_control_pressed then
										l_input_state.year_field.remove_substring (1, l_input_state.year_field.count)
									else
										l_input_state.year_field.remove_head (1)
									end
								end
								l_caret_delta := 1
							end
						else	-- year_field
							if l_input_state.year_field_caret_position <= l_input_state.year_field.count then
								if is_control_pressed then
									l_input_state.year_field.remove_substring (l_input_state.year_field_caret_position, l_input_state.year_field.count)
								else
									l_input_state.year_field.remove (l_input_state.year_field_caret_position)
								end
							end
						end
					else
						-- TODO exception handling
					end
				end

				l_input_state.increment_widget_caret_position (l_caret_delta)
				update_text_and_caret_position (l_input_state.widget, l_input_state.combined_fields, l_input_state.widget_caret_position)
			end
		end

feature {NONE} -- Internal Access

	format: INTEGER

	valid_characters_for_mask: STRING_32 = "0123456789/"
			-- Characters that are valid for Current.
			-- TODO Allow '-'?

	separator_string: STRING_32
		attribute
			create Result.make (1)
			Result.append_character (date_separator)
		end

feature {TEST_SET_BRIDGE} -- Implementation

	insert_string (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32)
			-- <Precursor>
		do
			if a_widget.is_editable then
				across a_text as ic_text loop
					handle_character (a_widget, ic_text.item)
				end
			end
		end

	handle_character (a_widget: EV_TEXT_COMPONENT; a_character: CHARACTER_32)
			-- Insert `a_character' into `a_widget'.
		local
			l_input_state: DATE_TIME_INPUT_STATE
			l_is_control_pressed: BOOLEAN
		do
			if is_pasting then
				l_is_control_pressed := False
			else
				l_is_control_pressed := is_control_pressed
			end
			create l_input_state.make (a_widget, format, [is_shift_pressed, l_is_control_pressed, is_alt_pressed])
			l_input_state.split_widget_into_fields
			l_input_state.handle_character (a_character)

			update_text_and_caret_position (l_input_state.widget, l_input_state.combined_fields, l_input_state.widget_caret_position)
		end

	replace_selection (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32)
			-- <Precursor>
		local
			l_widget: EV_TEXT_FIELD
			l_input_state: DATE_TIME_INPUT_STATE
		do
			create l_input_state.make (a_widget, format, [is_shift_pressed, is_control_pressed, is_alt_pressed])

			if l_input_state.does_string_contain_only_navigation_characters (l_input_state.widget.selected_text)
				or l_input_state.does_string_contain_only_navigation_characters (a_text) then

				l_input_state.split_widget_into_fields
				l_input_state.widget.deselect_all
			else
				l_input_state.split_widget_with_selection_into_fields
			end

			create l_widget.make_with_text (l_input_state.combined_fields.twin)
			l_widget.set_caret_position (l_input_state.widget_caret_position)
			insert_string (l_widget, a_text)
			update_text_and_caret_position (l_input_state.widget, l_widget.text, l_widget.caret_position)
		end

	remove_character_at_caret_position (a_widget: EV_TEXT_COMPONENT; before: BOOLEAN)
			-- <Precursor>
--		local
--			l_string: STRING_32
--			l_caret_position: INTEGER
		do
--			l_string := a_widget.text
--			l_caret_position := a_widget.caret_position
--			if is_repeating_specification and then before then
--				l_caret_position := l_caret_position - 1
--			elseif is_repeating_specification then
--				-- Do nothing
--			elseif before then
--				l_caret_position := mask.item (l_caret_position).left_open_index
--			else
--				if not mask.item (l_caret_position).is_open then
--					l_caret_position := mask.item (l_caret_position).right_open_index
--				end
--				if l_caret_position = 0 then
--					l_caret_position := a_widget.text_length + 1
--				end
--			end
--			if l_string.valid_index (l_caret_position) then
--				if is_repeating_specification then
--					l_string.remove (l_caret_position)
--				else
--					if l_caret_position > 0 and then l_caret_position <= mask.count then
--						l_string.put (mask [l_caret_position].character_to_display, l_caret_position)
--					else
--						l_string.remove (l_caret_position)
--					end
--				end
--			end
--			if not is_repeating_specification and then not before and then mask.valid_index (l_caret_position) and then mask [l_caret_position].right_open_index > 1 then
--				l_caret_position := mask [l_caret_position].right_open_index
--			end
--			if l_caret_position > 0 and then l_caret_position <= l_string.count + 1 then
--				update_text_and_caret_position (a_widget, l_string, l_caret_position)
--			end
		end

	apply_implementation (a_value: READABLE_STRING_GENERAL): TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			-- <Precursor>
		local
			l_result: STRING_32
			l_error_message: STRING_32
		do
			l_result := a_value.as_string_32
			create l_error_message.make_empty
				-- FIXME: errors and message
			Result := [l_result, l_error_message]
		end

	remove_implementation (a_string: STRING_32; a_constraint: detachable CON): TUPLE [value: V; error_message: STRING_32]
			-- <Precursor>
		local
			l_string, l_error_message: STRING_32
			l_value: V
			l_has_invalid_characters: BOOLEAN
		do
			l_string := a_string
			l_value := string_to_value (l_string)

			across a_string as ic_items loop
				if not is_valid_character_for_mask (ic_items.item) then
					l_has_invalid_characters := True
				end
			end

			if l_has_invalid_characters then
				l_error_message := translated_string (masking_messages.invalid_changes_message, [])
			else
				l_error_message := ""
			end
			Result := [l_value, l_error_message]
		end


end

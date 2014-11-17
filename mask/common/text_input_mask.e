note
	description: "{INPUT_MASK} objects specialize in input for text data types."
	how: "[
			- Masking -

			Input masking is done primarily through `insert_string', which uses the `mask' as a template
			for what kind of character can be allowed in what positions in the field.
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 1494 $"

deferred class
	TEXT_INPUT_MASK [V -> ANY, reference CON -> detachable DATA_COLUMN_METADATA [ANY]]

inherit
	INPUT_MASK [V, CON]
		redefine
			handle_key_string,
			handle_select_all,
			fix_pointer_position_implementation,
			set_selection_in_widget,
			update_text_and_caret_position
		end

feature -- Access

	mask_specification: STRING
			-- Specification used to construct Current.

	open_item_count: NATURAL
			-- The number of open items in Current.

	right_trim (a_string: STRING_32): STRING_32
			-- Version of `a_string' with right whitespace removed.
		local
			l_string: STRING_32
		do
			l_string := a_string.as_string_32.twin
			l_string.right_adjust
			Result := l_string
		end

feature -- Status Report

	accepts_new_line_and_tab: BOOLEAN
			-- Can user enter a new_line or tab character into this mask?

	allow_spaces: BOOLEAN
			-- Allows space as a valid character or not.

	is_masked_string_valid_for_current (a_masked_string: READABLE_STRING_GENERAL): BOOLEAN
			-- Is `a_masked_string' a valid masked string for `Current'?
		do
			Result := is_repeating_specification or else a_masked_string.count <= mask.count or else allow_spaces
		end

	is_valid_mask (a_mask: STRING): BOOLEAN
			-- <Precursor>
		do
			Result := a_mask.count > 0
		end

	is_repeating_specification: BOOLEAN
			-- Is `Current' implemented as a single repeating character specification?

feature -- Settings

	set_accepts_new_line_and_tab (a_accepts_new_line_and_tab: like accepts_new_line_and_tab)
			-- Sets `accepts_new_line_and_tab' with `a_accepts_new_line_and_tab'.
		do
			accepts_new_line_and_tab := a_accepts_new_line_and_tab
		ensure
			accepts_new_line_and_tab_set: accepts_new_line_and_tab = a_accepts_new_line_and_tab
		end

feature -- Event handling

	handle_key_string (a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- Process a key press string event from `a_widget'.
		local
			l_has_selection: BOOLEAN
			l_is_editable: BOOLEAN
			l_text_to_insert: like numpad_correction
		do
			l_is_editable := a_widget.is_editable
			l_has_selection := a_widget.has_selection

			if a_key_string.count > 0 and then (accepts_new_line_and_tab or else (not (a_key_string.has ('%N') or a_key_string.has ('%T')))) then
				l_text_to_insert := numpad_correction (a_key_string)
				if l_is_editable and then (not is_control_pressed) and then (is_shift_pressed implies (not l_text_to_insert.is_numpad or else l_text_to_insert.corrected.same_string ("-") or else l_text_to_insert.corrected.same_string ("+"))) then
						-- No selection operations are needed so we try to insert characters if valid to the mask.
					if l_has_selection then
						replace_selection (a_widget, l_text_to_insert.corrected)
					else
						insert_string (a_widget, l_text_to_insert.corrected)
					end
				end
			end
				-- Reset selection operation value
		end

	handle_key_back_space (a_widget: EV_TEXT_COMPONENT)
			-- Remove text to the left of the cursor, as appropriate.
		local
			l_caret_position: INTEGER
			l_initial_text: STRING_32
		do
			if a_widget.is_editable then
				if is_repeating_specification and then not a_widget.has_selection and then is_control_pressed and then a_widget.caret_position > 1 then
					a_widget.set_selection (1, a_widget.caret_position)
				end
				if a_widget.has_selection then
						-- Remove selected text, place caret position at leftmost selection position.
					l_initial_text := a_widget.text.twin
					l_caret_position := a_widget.start_selection
					--| For a back space, the caret ends up at the start of the selection
					replace_selection (a_widget, "")
					if not l_initial_text.same_string (a_widget.text) then
						update_text_and_caret_position (a_widget, a_widget.text, l_caret_position)
					end
				else
					l_caret_position := a_widget.caret_position
					if
						(not is_repeating_specification) and then
						mask.valid_index (l_caret_position - 1) and then
						not mask [l_caret_position - 1].is_open and then
						mask [l_caret_position - 1].left_open_index > 0
					then
						a_widget.set_caret_position (mask [l_caret_position - 1].left_open_index + 1)
					end
					if is_control_pressed then
						if not is_repeating_specification then
							if a_widget.caret_position > 1 and then not mask [a_widget.caret_position - 1].is_open and then mask [a_widget.caret_position - 1].left_open_index > 0 then
								update_text_and_caret_position (a_widget, a_widget.text, (open_items [1].index).max (mask [a_widget.caret_position - 1].left_open_index) + 1)
							elseif mask [a_widget.caret_position].left_open_index = 0 then
								update_text_and_caret_position (a_widget, a_widget.text, open_items [1].index)
							end
							from
							until
								(is_repeating_specification and then a_widget.caret_position = 1) or else
								((not is_repeating_specification) and then (mask [a_widget.caret_position].left_open_index = 0) or else ((a_widget.caret_position > 1 and then not mask [a_widget.caret_position -1].is_open)))
							loop
								remove_character_at_caret_position (a_widget, True)
							end
						end
					else
						remove_character_at_caret_position (a_widget, True)
					end
				end
			end
		end

	handle_key_delete (a_widget: EV_TEXT_COMPONENT)
			-- Processing to occur when delete key is pressed
		local
			l_has_deleted, l_has_deleted_last_character: BOOLEAN
		do
			if a_widget.is_editable then
				if is_repeating_specification and then is_control_pressed and then not a_widget.has_selection and then a_widget.caret_position < (a_widget.text_length + 1) then
					a_widget.set_selection (a_widget.caret_position, a_widget.text_length + 1)
				end
				if a_widget.has_selection then
						-- Remove selected text, place caret position at left most selection position.
					replace_selection (a_widget, "")
				elseif is_control_pressed then
					if a_widget.caret_position <= mask.count and then (not mask [a_widget.caret_position].is_open) and then (mask [a_widget.caret_position].right_open_index > 0) then
						a_widget.set_caret_position (mask [a_widget.caret_position].right_open_index)
					end

					from
					until
						(is_repeating_specification and then a_widget.caret_position > a_widget.text_length) or else
						(not is_repeating_specification and then l_has_deleted and then mask.valid_index (a_widget.caret_position - 1) and then (not mask [a_widget.caret_position - 1].is_open)) or else
						(not is_repeating_specification and then not mask.valid_index (a_widget.caret_position)) or else
						(not is_repeating_specification and then not mask [a_widget.caret_position].is_open) or else
						l_has_deleted_last_character
					loop
						if not is_repeating_specification and then a_widget.caret_position = open_items [open_items.count].index then
							l_has_deleted_last_character := True
						end
						remove_character_at_caret_position (a_widget, False)
						l_has_deleted := True
					end
				else
					remove_character_at_caret_position (a_widget, False)
				end
			end
		end

	handle_key_left (a_widget: EV_TEXT_COMPONENT)
		local
			l_anchor_position, l_caret_position, l_new_anchor_position, l_new_caret_position: INTEGER
			l_has_selection: BOOLEAN
		do
				-- Retrieve caret positions of selection if any and store selection state.
			l_anchor_position := anchor_position_from_widget (a_widget)
			l_caret_position := caret_position_from_widget (a_widget)
			l_has_selection := a_widget.has_selection

			l_new_anchor_position := l_anchor_position
			l_new_caret_position := l_caret_position
			if not (is_option_pressed or else (is_shift_pressed and then l_caret_position = 1)) then
					-- No caret/selection handling if option key is pressed.
				if l_caret_position > 1 then
						-- If caret is at the first position then no manipulation of caret is necessary.
					if is_control_pressed then
							-- Move end selection index to the next caret position.
						if is_repeating_specification then
							l_new_caret_position := 1
								--| Move end selection to the first position, however this could be updated to handle block jumps by word.
						else
							if l_caret_position > mask.count + 1 then
									-- Jump the end selection index to the end of the mask if beyond
								l_new_caret_position := mask.count + 1
							else
								if not mask [l_caret_position - 1].is_open and then mask [l_caret_position - 1].left_open_index > 0 then
									l_new_caret_position := mask [l_caret_position - 1].left_open_index
									if mask [l_new_caret_position].left_closed_index > 0 then
										l_new_caret_position := mask [mask [l_new_caret_position].left_closed_index].right_open_index
									end
								end
								if mask.valid_index (l_new_caret_position) and then mask [l_new_caret_position].left_closed_index > 0 then
									l_new_caret_position := mask [mask [l_new_caret_position].left_closed_index].right_open_index
								elseif (not mask.valid_index (l_new_caret_position)) and then (l_new_caret_position > 0) then
									l_new_caret_position := mask [mask [open_items [open_items.count].index].left_closed_index].right_open_index
								else
									l_new_caret_position := open_items [1].index
								end
							end
						end
					else
						if l_has_selection and not is_shift_pressed then
								-- Remove the existing selection by setting the caret position to the leftmost selection index.
							l_new_caret_position := l_anchor_position.min (l_caret_position)
						elseif is_repeating_specification then
							l_new_caret_position := l_caret_position - 1
						elseif l_has_selection and then l_caret_position < l_anchor_position then
							if mask [l_caret_position].is_open then
								l_new_caret_position := open_items [1].index.max (mask [l_caret_position].left_open_index)
							else
								l_new_caret_position := open_items [1].index.max (mask [l_caret_position].left_open_index)
							end
							if mask.valid_index (l_new_anchor_position - 1) and then not mask [l_new_anchor_position - 1].is_open and mask [l_new_anchor_position - 1].left_open_index > 0 then
								l_new_anchor_position := mask [l_new_anchor_position - 1].left_open_index + 1
							end
						elseif l_has_selection then
							l_new_caret_position := l_new_caret_position - 1
						elseif not mask.valid_index (l_new_caret_position) then
							l_new_caret_position := open_items [open_items.count].index
							l_new_anchor_position := l_new_caret_position + 1
						elseif mask [l_new_caret_position].left_open_index > 0 then
							l_new_caret_position := mask [l_new_caret_position].left_open_index
							l_new_anchor_position := l_new_caret_position + 1
						end
					end
				end
				if (l_new_caret_position < 1) and then is_repeating_specification then
					l_new_caret_position := 1
				elseif (l_new_caret_position < 1) or else ((not is_repeating_specification) and then (l_new_caret_position < open_items [1].index)) then
					l_new_caret_position := open_items [1].index
				end
				if not is_shift_pressed or else (l_new_anchor_position = 0) then
						-- Retain initial selection only if shift is pressed or we have an invalid start index
					l_new_anchor_position := l_new_caret_position
				elseif (not is_repeating_specification) and then l_new_anchor_position < open_items [1].index then
					l_new_anchor_position := open_items [1].index
				end
					-- Handle caret and selection positioning.
				set_selection_in_widget (a_widget, l_new_anchor_position, l_new_caret_position)
			end
		end

	handle_key_right (a_widget: EV_TEXT_COMPONENT)
		local
			l_anchor_position, l_caret_position, l_new_anchor_position, l_new_caret_position, l_text_length: INTEGER
			l_control_pressed, l_option_pressed, l_shift_pressed, l_has_selection, l_move_end_index: BOOLEAN
			l_app: EV_APPLICATION
		do
			l_app := ev_application
			l_control_pressed := l_app.ctrl_pressed
			l_option_pressed := l_app.alt_pressed
			l_shift_pressed := l_app.shift_pressed
			l_text_length := a_widget.text_length

				-- Retrieve caret positions of selection if any and store selection state.
			l_anchor_position := anchor_position_from_widget (a_widget)
			l_caret_position := caret_position_from_widget (a_widget)
			l_has_selection := a_widget.has_selection
			l_new_anchor_position := l_anchor_position
			l_new_caret_position := l_caret_position
			if not l_option_pressed then
					-- No caret/selection handling if option key is pressed.
				if l_caret_position <= l_text_length then
						-- If caret is at the last position then no manipulation of caret is necessary.
					if l_control_pressed then
							-- Move end selection index to the next caret position.
						if is_repeating_specification or else (l_caret_position > mask.count) then
								-- Move caret to end of control should it be passed an existing mask item.
							l_new_caret_position := l_text_length + 1
						else
							if l_shift_pressed and then mask [l_caret_position].is_open and then mask.valid_index (mask [l_caret_position].right_closed_index) then
								l_new_caret_position := mask [l_caret_position].right_closed_index
							elseif l_shift_pressed and then (not mask [l_caret_position].is_open) and then mask.valid_index (mask [l_caret_position].right_open_index) then
								l_new_caret_position := mask [l_caret_position].right_open_index
								if mask [l_new_caret_position].right_closed_index > 0 then
									l_new_caret_position := mask [l_new_caret_position].right_closed_index
								else
									l_new_caret_position := l_text_length + 1
								end
							elseif l_shift_pressed then
								l_new_caret_position := open_items [open_items.count].index + 1
							elseif mask [l_caret_position].is_open and then mask.valid_index (mask [l_caret_position].right_closed_index) then
								l_new_caret_position := mask [mask [l_caret_position].right_closed_index].right_open_index
							elseif (not mask [l_caret_position].is_open) and then mask.valid_index (mask [l_caret_position].right_open_index) then
								l_new_caret_position := mask [l_caret_position].right_open_index
							else
								l_new_caret_position := open_items [open_items.count].index
							end
							if (not is_repeating_specification) and then l_shift_pressed and then mask.valid_index (l_new_anchor_position) and then (not mask [l_new_anchor_position].is_open) and then mask [l_new_anchor_position].right_open_index > 0 then
								l_move_end_index := l_new_anchor_position = l_new_caret_position
								l_new_anchor_position := mask [l_new_anchor_position].right_open_index
								if l_move_end_index then
									l_new_caret_position := l_new_anchor_position
								end
							end
						end
					else
						if l_has_selection and not l_shift_pressed then
								-- Remove the existing selection by setting the caret position to the rightmost selection index.
							l_new_caret_position := l_anchor_position.max (l_caret_position)
						elseif is_repeating_specification then
							l_new_caret_position := l_caret_position + 1
						elseif l_shift_pressed then
							if (not l_has_selection) and then not mask.item (l_new_anchor_position).is_open and then mask.item (l_new_anchor_position).right_open_index > 0 then
								l_new_anchor_position := mask.item (l_new_anchor_position).right_open_index
							end
							if l_has_selection then
								if (l_caret_position > l_anchor_position) and then mask.valid_index (l_caret_position) and then not mask [l_caret_position].is_open and then (mask [l_caret_position].right_open_index > 0) then
									l_new_caret_position := mask [l_caret_position].right_open_index + 1
								elseif mask.valid_index (l_caret_position) then
									l_new_caret_position := l_caret_position + 1
								end
								if l_new_anchor_position < l_new_caret_position and then not mask [l_new_anchor_position].is_open then
									l_new_anchor_position := mask [l_new_anchor_position].right_open_index
								end
								if l_new_anchor_position = 0 then
									l_new_anchor_position := l_text_length + 1
								end
							elseif mask.valid_index (l_new_anchor_position) and then mask.item (l_new_anchor_position).is_open then
								l_new_caret_position := l_new_anchor_position + 1
							elseif mask.item (l_new_anchor_position).right_open_index > 0 then
								l_new_caret_position := mask.item (l_new_anchor_position).right_open_index
							else
								l_new_caret_position := l_new_anchor_position
							end
						elseif mask.item (l_anchor_position).right_open_index > 0 then
							l_new_caret_position := mask.item (l_anchor_position).right_open_index
						end
					end
				end
				if not l_shift_pressed then
						-- Retain initial selection only if shift is pressed.
					l_new_anchor_position := l_new_caret_position
				elseif (not is_repeating_specification) and then (not region_contains_open_item (l_new_anchor_position, l_new_caret_position)) then
					if mask.valid_index (l_new_anchor_position.max (l_new_caret_position)) and then mask [l_new_anchor_position.max (l_new_caret_position)].right_open_index > 0 then
						l_new_anchor_position := mask [l_new_anchor_position.max (l_new_caret_position)].right_open_index
					else
						l_new_anchor_position := open_items [open_items.count].index
					end
					l_new_caret_position := l_new_anchor_position
				end
					-- Handle caret and selection positioning.
				set_selection_in_widget (a_widget, l_new_anchor_position, l_new_caret_position)
			end
		end

	handle_key_home (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_new_anchor_position, l_new_caret_position: INTEGER
		do
			l_new_anchor_position := anchor_position_from_widget (a_widget)
			if is_repeating_specification then
				l_new_caret_position := 1
			else
				if mask.valid_index (l_new_anchor_position - 1) and then not mask [l_new_anchor_position - 1].is_open then
					l_new_anchor_position := mask [l_new_anchor_position - 1].left_open_index + 1
				end
				l_new_caret_position := open_items [1].index.max (1)
			end
			if not is_shift_pressed or else l_new_caret_position > l_new_anchor_position then
					-- Retain initial selection only if shift is pressed.
				l_new_anchor_position := l_new_caret_position
			end
				-- Handle caret and selection positioning.
			set_selection_in_widget (a_widget, l_new_anchor_position, l_new_caret_position)
		end

	handle_key_end (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_new_anchor_position, l_new_caret_position, l_text_length: INTEGER
		do
			l_text_length := a_widget.text_length
			l_new_anchor_position := anchor_position_from_widget (a_widget)
			if (not is_repeating_specification) and then mask.valid_index (l_new_anchor_position) and then (not mask [l_new_anchor_position].is_open) and then mask [l_new_anchor_position].right_open_index > 0 then
				l_new_anchor_position := mask [l_new_anchor_position].right_open_index
			end
			l_new_caret_position := l_text_length + 1
			if not is_shift_pressed then
					-- Retain initial selection only if shift is pressed.
				l_new_anchor_position := l_new_caret_position
			end
				-- Handle caret and selection positioning.
			set_selection_in_widget (a_widget, l_new_anchor_position, l_new_caret_position)
		end

	handle_select_all (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_start_index, l_end_index: INTEGER
		do
			if is_repeating_specification then
				Precursor (a_widget)
			else
				across mask as ic_mask loop
					if ic_mask.item.is_open then
						if l_start_index = 0 then
							l_start_index := ic_mask.cursor_index
						end
						l_end_index := ic_mask.cursor_index
					end
				end
				if l_start_index > 0 then
					a_widget.set_selection (l_start_index, l_end_index + 1)
				end
			end
		end

feature {TEST_SET_BRIDGE} -- Implementation

	mask: ARRAY [MASK_ITEM_SPECIFICATION]
			-- Implementation of the mask

feature {TEST_SET_BRIDGE} -- Implementation

	apply_implementation (a_value: READABLE_STRING_GENERAL): TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			-- <Precursor>
		local
			l_input: STRING_32
			l_result: STRING_32
			l_error_message: STRING_32
			l_mask_item: MASK_ITEM_SPECIFICATION
			l_index, l_mask_index: INTEGER
			l_character: CHARACTER_32
			l_has_reported_illegal_characters: BOOLEAN
		do
			l_input := a_value.as_string_32
			l_input := right_trim (l_input)
			create l_result.make (mask.count)
			if is_repeating_specification then
				l_mask_item := mask [1]
				l_error_message := {STRING_32} ""
				across 1 |..| l_input.count as ic_index loop
					l_character := l_input.item (ic_index.cursor_index)
					l_result.extend (l_mask_item.character_for_character (l_character))
					if not l_mask_item.is_valid_character (l_character) and then l_error_message.is_empty then
						l_error_message.append (translated_string (masking_messages.contains_illegal_characters, []).twin)
						l_error_message.extend ('.')
					end
				end
			else
				l_mask_index := initial_masking_iteration_index_from_string (l_input)
				l_error_message := ""

					-- Add all closed mask items to result until we reach the initial masking iteration index.
				from
					l_index := 1
					l_mask_item := mask [l_index]
				until
					l_index = l_mask_index or l_mask_item.is_open
				loop
					l_result.extend (l_mask_item.character_to_display)
					l_index := l_index + 1
					if l_index <= mask.count then
						l_mask_item := mask [l_index]
					end
				end

				across 1 |..| l_input.count as ic_index loop
					if l_mask_index <= mask.count then
						from
							l_mask_item := mask [l_mask_index]
						until
							l_mask_item.is_open or l_mask_index > mask.count
						loop
							l_result.extend (l_mask_item.character_to_display)
							l_mask_index := l_mask_index + 1
							if l_mask_index <= mask.count then
								l_mask_item := mask [l_mask_index]
							end
						end
						if l_mask_item.is_open then
							l_character := l_input.item (ic_index.cursor_index)
							l_result.extend (l_mask_item.character_for_character (l_character))
							if not l_mask_item.is_valid_character (l_character) and then l_error_message.is_empty then
								l_error_message.append (translated_string (masking_messages.contains_illegal_characters, []).twin)
								l_error_message.extend ('.')
							end
						end
						l_mask_index := l_mask_index + 1
					end
				end
				across l_mask_index |..| mask.count as ic_index loop
					l_mask_item := mask [ic_index.target_index]
					if not l_mask_item.is_open then
						l_result.extend (l_mask_item.character_to_display)
					elseif l_mask_item.is_required then
						l_result.extend (l_mask_item.character_to_display)
						if not l_has_reported_illegal_characters and not allow_spaces then
							l_has_reported_illegal_characters := True
							if not l_error_message.is_empty then
								l_error_message.extend (' ')
							end
							l_error_message.append (translated_string (masking_messages.missing_required_characters, []).twin)
							l_error_message.extend ('.')
						end
					end
				end
			end
			Result := [l_result, l_error_message]
		end

	replace_selection (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32)
			-- Replace selected text in `a_widget' with `a_text'
		local
			l_prepend, l_conforming_text, l_append: STRING_32
			l_new_caret_position: INTEGER
			l_mask_index, l_text_index, l_start_selection, l_end_selection: INTEGER
			l_widget_text: STRING_32
			l_character: CHARACTER_32
			l_text_updated: BOOLEAN
			l_overwrite_locations: ARRAY [BOOLEAN]
		do
			create l_overwrite_locations.make_filled (False, 1, mask.count)
			l_widget_text := a_widget.text
			create l_conforming_text.make (a_text.count)
			l_start_selection := a_widget.start_selection
			l_end_selection := a_widget.end_selection - 1

			if l_start_selection > 1 then
				l_prepend :=  l_widget_text.substring (1, l_start_selection - 1)
			else
				l_prepend := ""
			end
			if l_end_selection < l_widget_text.count then
				l_append := l_widget_text.substring (l_end_selection + 1, l_widget_text.count)
			else
				l_append := ""
			end

			if is_repeating_specification then
					-- Conform replacement string to mask.
				across a_text as lc_index loop
					l_character := mask [1].character_for_character (lc_index.item)
					if not mask [1].is_strict or else mask [1].is_valid_character (lc_index.item) then
						l_conforming_text.extend (l_character)
						l_text_updated := True
					end
				end
			else

				-- First pass replaces conforming characters
				from
					l_mask_index := l_start_selection
					l_text_index := 1
				until
					l_mask_index > l_end_selection
				loop
					if mask.valid_index (l_mask_index) then
						if a_text.valid_index (l_text_index) then
							if mask [l_mask_index].is_open then
								if mask [l_mask_index].is_valid_character (a_text [l_text_index]) then
									l_character := a_text [l_text_index]
									l_text_updated := True
								else
									l_character := l_widget_text [l_mask_index]
									l_overwrite_locations [l_mask_index] := True
								end
								l_text_index := l_text_index + 1
							else
								l_character := mask [l_mask_index].character_to_display
								if l_character = a_text.item (l_text_index) then
									l_text_index := l_text_index + 1
								end
							end
							l_new_caret_position := l_new_caret_position + 1
						elseif a_text.is_empty and then mask [l_mask_index].is_open then
							l_character := mask [l_mask_index].character_to_display
							l_text_updated := True
						elseif not mask [l_mask_index].is_open then
							l_character := mask [l_mask_index].character_to_display
						else
							l_character := a_widget.text.item (l_mask_index)
							l_overwrite_locations [l_mask_index] := True
						end
						l_conforming_text.extend (l_character)
					end
					l_mask_index := l_mask_index + 1
				end
				-- Second pass replaces non-conforming characters; only if we have actually updated a conforming character
				from
					l_mask_index := l_start_selection
					l_text_index := 1
				until
					(not l_text_updated) or else (l_mask_index > l_end_selection)
				loop
					if mask [l_mask_index].is_open and then l_overwrite_locations [l_mask_index] then
						l_conforming_text.put (mask [l_mask_index].character_to_display, l_text_index)
					end
					l_mask_index := l_mask_index + 1
					l_text_index := l_text_index + 1
				end
			end
			if (not a_text.is_empty) implies (not l_conforming_text.is_empty) then
				l_prepend.append (l_conforming_text)
				l_new_caret_position := l_prepend.count + 1
				l_prepend.append (l_append)
				if not l_widget_text.same_string (l_prepend) or else l_text_updated then
					--| Test for l_text_updated is neeeded to account for possibility
					--| inserted text exactly matches selected text
					update_text_and_caret_position (a_widget, l_prepend, l_new_caret_position)
				end
			end
		end

	insert_string (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32)
			-- Insert `a_insert' at caret_position of `a_widget'
		require else
			not_has_selection: not a_widget.has_selection
		local
			l_string, l_conforming_text: STRING_32
			l_caret_position: INTEGER
			l_character: CHARACTER_32
			l_mask_index, l_string_index: INTEGER
		do
			l_string := a_widget.text
			l_caret_position := a_widget.caret_position
			create l_conforming_text.make (a_text.count)
			if not a_text.is_empty then
				if is_repeating_specification then
						-- Conform insertion string to mask.
					across a_text as lc_index loop
						l_character := mask [1].character_for_character (lc_index.item)
						if not mask [1].is_strict or else mask [1].is_valid_character (lc_index.item) then
							l_conforming_text.extend (l_character)
						end
					end
					l_string.insert_string (l_conforming_text, l_caret_position)
					update_text_and_caret_position (a_widget, l_string, l_caret_position + l_conforming_text.count)
				else
					if a_widget.has_selection then
						replace_selection (a_widget, "")
					end
					from
						l_mask_index := a_widget.caret_position
						if mask.valid_index (l_mask_index) and then not mask [l_mask_index].is_open then
							l_mask_index := mask [l_mask_index].right_open_index
						end
						l_string_index := 1
						l_caret_position := (a_widget.caret_position).max (l_mask_index)
					until
						(not mask.valid_index (l_mask_index)) or else
						(l_string_index > a_text.count)
					loop
						if mask [l_mask_index].is_valid_character (a_text.item (l_string_index)) then
							l_string.put (a_text.item (l_string_index), l_mask_index)
							l_mask_index := mask [l_mask_index].right_open_index
							l_caret_position := l_caret_position.max (mask[l_caret_position].right_open_index)
						end
						l_string_index := l_string_index + 1
					end
					update_text_and_caret_position (a_widget, l_string, l_caret_position)
				end
			end
		end

	remove_character_at_caret_position (a_widget: EV_TEXT_COMPONENT; before: BOOLEAN)
			-- Remove character at caret position, `before' removes character before caret.
			-- Caret is set at the index of the removed character.
		local
			l_string: STRING_32
			l_caret_position: INTEGER
		do
			l_string := a_widget.text
			l_caret_position := a_widget.caret_position
			if is_repeating_specification and then before then
				l_caret_position := l_caret_position - 1
			elseif is_repeating_specification then
				-- Do nothing
			elseif before then
				l_caret_position := mask.item (l_caret_position).left_open_index
			else
				if not mask.item (l_caret_position).is_open then
					l_caret_position := mask.item (l_caret_position).right_open_index
				end
				if l_caret_position = 0 then
					l_caret_position := a_widget.text_length + 1
				end
			end
			if l_string.valid_index (l_caret_position) then
				if is_repeating_specification then
					l_string.remove (l_caret_position)
				else
					if l_caret_position > 0 and then l_caret_position <= mask.count then
						l_string.put (mask [l_caret_position].character_to_display, l_caret_position)
					else
						l_string.remove (l_caret_position)
					end
				end
			end
			if not is_repeating_specification and then not before and then mask.valid_index (l_caret_position) and then mask [l_caret_position].right_open_index > 1 then
				l_caret_position := mask [l_caret_position].right_open_index
			end
			if l_caret_position > 0 and then l_caret_position <= l_string.count + 1 then
				update_text_and_caret_position (a_widget, l_string, l_caret_position)
			end
		end

	pivotal_mask_index: INTEGER
			-- Mask index where partial masking pivots from.
		do
			Result := default_initial_masking_iteration_index
		ensure
			result_greater_than_zero: Result > 0
		end

	default_value: V
			-- Default value from `Current'.
		deferred
		end

	empty_masked_string: READABLE_STRING_GENERAL
			-- Empty masked string.
		require
			valid_mask: not is_invalid
		local
			i, nb: INTEGER
			l_string_32: STRING_32
		do
			if is_repeating_specification then
				Result := ""
			else
				create l_string_32.make (mask.count)
				from
					i := 1
					nb := mask.count
				until
					i > nb
				loop
					l_string_32.extend (mask [i].character_to_display)
					i := i + 1
				end
					-- Remove whitespace from edges.
				l_string_32.left_adjust
				l_string_32 := right_trim (l_string_32)
				Result := l_string_32
			end
		end

	open_items: like mask
			-- The items in `mask' which are open for user input

	initialize_from_mask_string
			-- <Precursor>
		require
			is_valid_mask: is_valid_mask (mask_specification)
		local
			l_mask_characters: STRING
			l_current_mask_item: detachable MASK_ITEM_SPECIFICATION
			l_mask_set_item: detachable MASK_ITEM_SET_MASK_ITEM
			l_mask, l_open_items, l_closed_items: ARRAYED_LIST [MASK_ITEM_SPECIFICATION]
			l_is_escaped, l_create_literal, l_add_forbidden: BOOLEAN
			l_mask_index, l_last_count, l_last_item_index: INTEGER
			l_character: CHARACTER
		do
			create l_mask.make (20)
			create l_open_items.make (20)
			create l_closed_items.make (20)
			l_mask_characters := mask_specification.substring (1, mask_specification.count)
			l_mask_index := 0
			across l_mask_characters as ic_index loop
				l_character := ic_index.item
				if l_mask_index = 1 and then is_repeating_specification then
					log_error ("initialize_from_mask_string", "more_than_one_specification_character_in_repeating_mask", <<["mask", mask_specification]>>)
					report_invalid_mask_specification
				end
				if l_is_escaped then
					l_create_literal := True
					l_is_escaped := False
				else
					inspect l_character.as_upper
					when '!' then
						l_current_mask_item := create {FORCE_UPPER_CASE_MASK_ITEM}.make (l_mask_index)
					when '#' then
						l_current_mask_item := create {NUMERIC_AND_SPACES_MASK_ITEM}.make_allowing_spaces (l_mask_index)
					when '_' then
						l_current_mask_item := create {NUMERIC_AND_SPACES_MASK_ITEM}.make_allowing_spaces_no_error (l_mask_index)
					when '9' then
							-- '0-9' only
						l_current_mask_item := create {NUMERIC_MASK_ITEM}.make (l_mask_index)
					when 'A' then
						l_current_mask_item := create {ALPHABETIC_MASK_ITEM}.make (l_mask_index)
					when 'K' then
						l_current_mask_item := create {UPPERCASE_ALPHA_NUMERIC_MASK_ITEM}.make (l_mask_index)
					when 'N' then
						l_current_mask_item := create {ALPHA_NUMERIC_MASK_ITEM}.make (l_mask_index)
					when 'U' then
						l_current_mask_item := create {ALPHABETIC_MASK_ITEM}.make_upper_case (l_mask_index)
					when 'W' then
						l_current_mask_item := create {ALPHABETIC_MASK_ITEM}.make_lower_case (l_mask_index)
					when 'X' then
						l_current_mask_item := create {WILDCARD_MASK_ITEM}.make (l_mask_index)
					when '-' then
						if l_mask_set_item = Void then
							-- A masking set has not been created so we treat '-' as a literal.
							l_create_literal := True
						else
							l_add_forbidden := True
						end
					when '\' then
						l_is_escaped := True
					when
							-- Reserved characters for future enhancements.
						'C', 'V', 'Y', 'Z', '[', ']', '{', '}', '<', '>', '`', '~', '?', '='
					then
						log_error ("initialize_from_mask_string", "reserved_specification_character_remove_or_escape", <<["mask", mask_specification], ["reserved_character", l_character]>>)
						report_invalid_mask_specification
					else
						l_create_literal := True
					end
				end

				if l_create_literal then
					l_current_mask_item := create {LITERAL_MASK_ITEM}.make_with_character (l_mask_index, l_character)
					l_create_literal := False
				end

				if not l_is_escaped then
					if l_mask_set_item /= Void then
						if l_current_mask_item /= Void then
							if not l_add_forbidden then
								l_mask_set_item.add_allowed_mask_item (l_current_mask_item)
							else
								l_mask_set_item.add_forbidden_mask_item (l_current_mask_item)
								l_add_forbidden := False
							end
							l_current_mask_item := Void
						end
					elseif l_current_mask_item /= Void then
						l_mask.extend (l_current_mask_item)
						l_current_mask_item := Void
						l_mask_index := l_mask_index + 1
						if l_mask.count > l_last_count then
							-- A new mask item was added
							if not is_repeating_specification then
								l_mask.last.set_index (l_mask.count)
								if not l_open_items.is_empty then
									l_mask.last.set_left_open_index (l_open_items.last.index)
								end
								if not l_closed_items.is_empty then
									l_mask.last.set_left_closed_index (l_closed_items.last.index)
								end
							end
							if attached {OPEN_MASK_ITEM} l_mask.last as l_open_mask_item then
								l_open_items.extend (l_open_mask_item)
								if not is_repeating_specification then
									l_open_mask_item.set_is_required
									if l_mask.count > 1 then
										from
											l_last_item_index := l_mask.count - 1
											l_mask.i_th (l_last_item_index).set_right_open_index (l_mask.count)
										until
											l_last_item_index = 1 or else l_mask.i_th (l_last_item_index).is_open
										loop
											l_last_item_index := l_last_item_index - 1
											l_mask.i_th (l_last_item_index).set_right_open_index (l_mask.count)
										end
									end
								end
							else
									-- CLOSED_MASK_ITEM descendent.
								l_closed_items.extend (l_mask.last)
								if not is_repeating_specification and then l_mask.count > 1 then
									from
										l_last_item_index := l_mask.count - 1
										l_mask.i_th (l_last_item_index).set_right_closed_index (l_mask.count)
									until
										l_last_item_index = 1 or else not l_mask.i_th (l_last_item_index).is_open
									loop
										l_last_item_index := l_last_item_index - 1
										l_mask.i_th (l_last_item_index).set_right_closed_index (l_mask.count)
									end
								end
							end
						end
						l_last_count := l_mask.count
					end
				end
			end
			open_item_count := l_open_items.count.as_natural_32
			mask := l_mask.to_array
			open_items := l_open_items.to_array
			if open_item_count < 1 then
				log_error ("initialize_from_mask_string", "mask_specification_must_be_open_to_input", <<["mask", mask_specification]>>)
				report_invalid_mask_specification
			end
		end

	remove_implementation (a_string: STRING_32; a_constraint: detachable CON): TUPLE [value: V; error_message: STRING_32]
			-- <Precursor>
		local
			l_masked_string_valid: BOOLEAN
			l_result: STRING_32
			l_is_incomplete: BOOLEAN
			l_character: CHARACTER_32
			l_mask_item: MASK_ITEM_SPECIFICATION
			l_error_message: STRING_32
			l_start_iteration_index, l_end_iteration_index: INTEGER
			l_text_is_too_long: BOOLEAN
			l_mask_offset: INTEGER
			l_value: V
		do
			l_result := a_string

				-- Check if the string is valid for masking
			l_masked_string_valid := is_masked_string_valid_for_current (l_result)
			if not l_masked_string_valid then
					-- Force string to conform to mask.
				l_result := a_string.substring (1, mask.count)
			end

			if l_result.count > 0 and then not is_repeating_specification then
				l_start_iteration_index := initial_masking_iteration_index_from_string (l_result)
				l_end_iteration_index := ending_masking_iteration_index_from_string (l_result)
				l_mask_offset := l_result.count - (l_end_iteration_index - l_start_iteration_index) - 1

				if l_end_iteration_index > mask.count then
						-- String is larger than mask can account for.
					l_text_is_too_long := True
				else
					create l_result.make ((l_end_iteration_index - l_start_iteration_index) + 1)
					across l_start_iteration_index |..| l_end_iteration_index as ic_index loop
						l_mask_item := mask [ic_index.item]
						l_character := a_string [ic_index.cursor_index + l_mask_offset]
						if l_mask_item.is_open then
							if l_mask_item.is_required and not allow_spaces then
								l_is_incomplete := l_is_incomplete or else (l_character = ' ' or else not l_mask_item.is_valid_character (l_character))
							end
							l_result.extend (l_character)
						end
					end
				end
			end

			l_value := string_to_value (l_result)
				-- Make sure masked result is not too big for constraint if not already too big for any preset mask.

			if l_masked_string_valid and then not l_text_is_too_long and then attached a_constraint and then not a_constraint.conforms_to_constraint (l_value) then
				l_text_is_too_long := True
			end

			if not l_masked_string_valid then
				l_error_message := data_does_not_conform_to_mask_specification_message (a_string, mask.count)
			elseif l_text_is_too_long then
				l_error_message := data_exceeds_column_constraint_message (l_value, a_constraint)
			elseif l_is_incomplete then
				l_error_message := translated_string (masking_messages.entry_incomplete, []).twin
			else
				l_error_message := ""
			end

			Result := [l_value, l_error_message]
		end

	data_exceeds_column_constraint_message (a_result: V; a_constraint: detachable DATA_COLUMN_METADATA [ANY]): STRING_32
			-- <Precursor>
		deferred
		end

	string_to_value (a_string: READABLE_STRING_GENERAL): like default_value
			-- Value from its string representation
		deferred
		end

	value_to_string (a_value: like default_value): READABLE_STRING_GENERAL
			-- String representation of `a_value'
		deferred
		end

	exception_tag: STRING = "mask_details_in_log"
			-- Tag to use in exceptions

	report_invalid_mask_specification
			-- Raise an exception related to Current
		local
			l_dev_exception: DEVELOPER_EXCEPTION
		do
			if is_test_mode then
				is_invalid := True
			else
				create l_dev_exception
				l_dev_exception.set_description (exception_tag)
				l_dev_exception.raise
			end
		end

	update_text_and_caret_position (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32; a_caret_position: INTEGER_32)
			-- <Precursor>
		local
			l_caret_position: INTEGER
		do
			l_caret_position := a_caret_position
			if (not is_repeating_specification) and then mask.valid_index (l_caret_position) and then (not mask [l_caret_position].is_open) and then mask [l_caret_position].right_open_index > 0 then
				l_caret_position := mask [l_caret_position].right_open_index
			elseif (not is_repeating_specification) and then ((not mask.valid_index (l_caret_position)) or else (mask [l_caret_position].right_open_index = 0)) then
				l_caret_position := open_items [open_items.count].index
			end
			Precursor (a_widget, a_text, l_caret_position)
		end

	set_selection_in_widget (a_widget: EV_TEXT_COMPONENT; a_anchor_position, a_caret_position: INTEGER_32)
			-- <Precursor>
		local
			l_anchor_position, l_caret_position: INTEGER_32
		do
			l_anchor_position := a_anchor_position
			l_caret_position := a_caret_position
			if not is_repeating_specification then
				if l_anchor_position < l_caret_position then
					if mask.valid_index (l_anchor_position) and then not mask [l_anchor_position].is_open and then mask [l_anchor_position].right_open_index > 0 then
						l_anchor_position := mask [l_anchor_position].right_open_index
					end
					if mask.valid_index (l_caret_position - 1) and then not mask [l_caret_position - 1].is_open and then mask [l_caret_position - 1].left_open_index > 0 then
						l_caret_position := mask [l_caret_position].left_open_index + 1
					end
				elseif l_caret_position < l_anchor_position then
					if mask.valid_index (l_caret_position) and then not mask [l_caret_position].is_open and then mask [l_caret_position].right_open_index > 0 then
						l_caret_position := mask [l_caret_position].right_open_index
					end
					if mask.valid_index (l_anchor_position - 1) and then not mask [l_anchor_position - 1].is_open and then mask [l_anchor_position - 1].left_open_index > 0 then
						l_anchor_position := mask [l_anchor_position].left_open_index + 1
					end
				end
			end
			if l_anchor_position = l_caret_position then
				update_text_and_caret_position (a_widget, a_widget.text, l_anchor_position)
			else
				Precursor (a_widget, l_anchor_position, l_caret_position)
			end
		end

	fix_pointer_position_implementation (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		do
			if (not is_repeating_specification) and then (not a_widget.has_selection) and then (not a_widget.text.is_empty)  then
				if
					(not mask.valid_index (a_widget.caret_position)) or else
					((not mask [a_widget.caret_position].is_open) and then (mask [a_widget.caret_position].right_open_index = 0))
				then
					a_widget.set_caret_position (open_items [open_items.count].index)
				elseif not mask [a_widget.caret_position].is_open then
					a_widget.set_caret_position (mask [a_widget.caret_position].right_open_index)
				end
			end
		end

	region_contains_open_item (a_start_position, a_end_position: INTEGER_32): BOOLEAN
			-- Does mask contain an open item between `a_start_position' and `a_end_position'?
		require
			not_repeating_mask: not is_repeating_specification
			non_zero_start_position: a_start_position > 0
			non_zero_end_position: a_end_position > 0
		local
			l_index: INTEGER_32
		do
			from
				l_index := a_start_position.min (a_end_position)
			until
				Result or else (not mask.valid_index (l_index)) or else (l_index > a_start_position.max (a_end_position))
			loop
				Result := mask [l_index].is_open
				l_index := l_index + 1
			end

		end

feature {NONE} -- Private Data Implementation

	enable_private_data_mode (a_allow_peeking: BOOLEAN)
		do
			if a_allow_peeking then
				private_data_mode := private_data_mode_enabled_with_peeking
			else
				private_data_mode := private_data_mode_enabled
			end
		end

	disable_private_data_mode
		do
			private_data_mode := private_data_mode_disabled
		end

	private_data_character: CHARACTER_32 = ' '
		-- Character used to mask private data.

feature {NONE} -- Privacy mode implementation

	private_data_mode: NATURAL_8
		-- Current privacy mode, disabled by default.

	private_data_mode_disabled: NATURAL_8 = 0
	private_data_mode_enabled: NATURAL_8 = 1
	private_data_mode_enabled_with_peeking: NATURAL_8 = 2
		-- Available privacy modes.

invariant

	not_repeating_implies_indexes_consistent: not is_invalid and not is_repeating_specification implies across mask as ic_item all ic_item.cursor_index = ic_item.item.index end
	mask_not_empty: not is_invalid implies not mask.is_empty
	open_items_not_empty: not is_invalid implies not open_items.is_empty
	open_items_all_open: not is_invalid implies across open_items as ic_open_item all ic_open_item.item.is_open end

;note
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

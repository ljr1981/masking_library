note
	description: "[
			DECIMAL_VALUE_INPUT_MASKS which are prefixed or suffixed with a character (e.g. 0.00% or $0.00)
			]"
	purpose: "[			
			Some decimal fields have annotations such as '$' or '%' and key handling needs to account for these.
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

deferred class
	ANNOTATED_DECIMAL_VALUE_INPUT_MASK

inherit
	DECIMAL_VALUE_INPUT_MASK
		redefine
			apply_formatting,
			handle_key_delete,
			handle_key_press,
			handle_key_string
		end

feature -- Status Report

	is_symbol_prepended: BOOLEAN
			-- Will symbol be prepended to text?
		deferred
		end

feature -- Access

	annotation_symbol: CHARACTER_32
			-- The symbol to be added to the mask
		deferred
		end

	annotation_string: STRING_32
			-- String value of `annotation_symbol'
		do
			create Result.make_filled (annotation_symbol, 1)
		end

	annotation_offset: INTEGER
			-- Offset of caret and selection positions to account for annotation symbol
		do
			Result := is_symbol_prepended.to_integer
		end

feature -- Event Handling

	handle_key_string (a_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_was_all_selected_before, l_is_all_selected_after: BOOLEAN
		do
			if ev_application.ctrl_pressed and then is_nan_valid and then a_string.same_string ("a") and then a_widget.text_length > 0 then
				a_widget.set_selection (1, a_widget.text_length + 1)
			elseif ev_application.ctrl_pressed and then a_widget.has_selection and then not ev_application.shift_pressed and then a_string.same_string ("c") then
				ev_application.clipboard.set_text (a_widget.selected_text)
			elseif ev_application.ctrl_pressed and then a_widget.has_selection and then not ev_application.shift_pressed and then a_string.same_string ("x") then
				Precursor (a_string, a_widget)
				replace_symbol (a_widget)
			elseif not (ev_application.shift_pressed and then ev_application.ctrl_pressed and then (a_string.same_string ("a"))) then
				l_was_all_selected_before := a_widget.has_selection and then a_widget.selected_text.count = a_widget.text_length
				if a_widget.text.has (annotation_symbol) then
					remove_symbol (a_widget)
				end
				Precursor (a_string, a_widget)
				l_is_all_selected_after := a_widget.has_selection and then a_widget.selected_text.count = a_widget.text_length
				if not a_widget.text.has (annotation_symbol) then
					replace_symbol (a_widget)
					if l_was_all_selected_before and then l_is_all_selected_after and then (not (not is_nan_valid and then ev_application.ctrl_pressed and then a_string.same_string ("a"))) then
						fix_select_all (a_widget, a_widget.caret_position)
					end
				end
			end
		end

	handle_key_press (a_key: EV_KEY; a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_was_empty, l_was_all_selected_before, l_is_all_selected_after, l_had_selection: BOOLEAN
			l_initial_caret_position: INTEGER
		do
			if ev_application.ctrl_pressed and then (not ev_application.shift_pressed) and then is_nan_valid and then a_key.code = key_a and then a_widget.text_length > 0 then
				a_widget.set_selection (1, a_widget.text_length + 1)
			elseif ev_application.ctrl_pressed and then a_widget.has_selection and then not ev_application.shift_pressed and then (a_key.code = key_c) then
				ev_application.clipboard.set_text (a_widget.selected_text)
			elseif ev_application.ctrl_pressed and then a_widget.has_selection and then not ev_application.shift_pressed and then (a_key.code = key_x) then
				Precursor (a_key, a_widget)
				replace_symbol (a_widget)
			elseif not (ev_application.shift_pressed and then ev_application.ctrl_pressed and then (a_key.code = key_a)) then
				l_was_all_selected_before := a_widget.has_selection and then a_widget.selected_text.count = a_widget.text_length
				l_was_empty := a_widget.text_length = 0
				l_initial_caret_position := a_widget.caret_position
				l_had_selection := a_widget.has_selection
				if a_widget.text.has (annotation_symbol) then
					remove_symbol (a_widget)
				end
				Precursor (a_key, a_widget)
				l_is_all_selected_after := a_widget.has_selection and then a_widget.selected_text.count = a_widget.text_length
				if
					a_widget.text_length = 0 and then
					not l_was_all_selected_before and then
					not l_was_empty and then
					not ((not l_had_selection) and then a_key.code = key_delete and then (l_initial_caret_position = 1) and then ev_application.ctrl_pressed)
				then
					a_widget.set_text (refresh_number_formatting ("0.0"))
					if a_key.code = key_delete and l_had_selection then
						a_widget.set_caret_position (3)
					else
						a_widget.set_caret_position (2)
					end
					replace_symbol (a_widget)
				elseif a_widget.text_length > 0 and then not a_widget.text.has (annotation_symbol) then
					replace_symbol (a_widget)
					if l_was_all_selected_before and then l_is_all_selected_after and then (not (not is_nan_valid and then ev_application.ctrl_pressed and then (a_key.code = key_a))) then
						fix_select_all (a_widget, a_widget.caret_position)
					end
				end
			end
		end

	handle_key_delete (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		do
			if a_widget.text.has (annotation_symbol) then
				remove_symbol (a_widget)
			end
			Precursor (a_widget)
		end

feature {TEST_SET_BRIDGE} -- Implementation

	fix_select_all (a_widget: EV_TEXT_COMPONENT; a_caret_position: INTEGER)
			-- Adjust selection of `a_widget' such that it selects all text
		require
			not_empty: a_widget.text_length > 0
		do
			if a_caret_position <= (1 + annotation_offset) then
				a_widget.set_selection (a_widget.text_length + 1, 1)
			else
				a_widget.set_selection (1, a_widget.text_length + 1)
			end
		ensure
			all_selected: a_widget.text.same_string (a_widget.selected_text)
		end

	remove_symbol (a_widget: EV_TEXT_COMPONENT)
			-- Remove annotation symbol from `a_widget', preserving caret and selections
		require
			one_symbol: a_widget.text_length > 0 implies a_widget.text.occurrences (annotation_symbol) = 1
			symbol_character_first: is_symbol_prepended and then a_widget.text_length > 0 implies a_widget.text.item (1) = annotation_symbol
			symbol_character_last: (not is_symbol_prepended) and then a_widget.text_length > 0 implies a_widget.text.item (a_widget.text_length) = annotation_symbol
			symbol_count: a_widget.text_length > 0 implies a_widget.text_length >= 4 -- at least 0.0% or $0.0
			not_symbol_selected: (a_widget.is_editable and a_widget.has_selection) implies not a_widget.selected_text.same_string (annotation_string)
		local
			l_caret_position, l_anchor_position: INTEGER
			l_has_selection: BOOLEAN
		do
			if a_widget.is_editable and a_widget.text_length > 0 then
				l_anchor_position := (1).max (anchor_position_from_widget (a_widget) - annotation_offset)
				l_caret_position := (1).max (caret_position_from_widget (a_widget) - annotation_offset)
				l_has_selection := a_widget.has_selection
				a_widget.set_text (a_widget.text.substring (1 + annotation_offset, a_widget.text_length - 1 + annotation_offset))
				if l_has_selection and then l_caret_position < l_anchor_position then
					a_widget.set_selection ((a_widget.text_length + 1).min (l_anchor_position), l_caret_position)
				elseif l_has_selection then
					a_widget.set_selection (l_anchor_position, (a_widget.text_length + 1).min (l_caret_position))
				else
					a_widget.set_caret_position ((a_widget.text_length + 1).min (l_caret_position))
				end
			end
		end

	replace_symbol (a_widget: EV_TEXT_COMPONENT)
			-- Replace anotation smbol from `a_widget', preserving caret and selections
		require
			no_percent_character: a_widget.text.occurrences (annotation_symbol) = 0
		local
			l_caret_position, l_anchor_position, l_new_caret_position, l_new_anchor_position: INTEGER
			l_has_selection: BOOLEAN
		do
			if a_widget.is_editable and a_widget.text_length > 0 then
				l_anchor_position := anchor_position_from_widget (a_widget)
				l_caret_position := caret_position_from_widget (a_widget)
				l_has_selection := a_widget.has_selection
				if is_symbol_prepended then
					a_widget.set_text (annotation_string + a_widget.text)
				else
					a_widget.set_text (a_widget.text + annotation_string)
				end
				l_new_caret_position := (a_widget.text_length + 1).min (l_caret_position + annotation_offset)
				l_new_anchor_position := (a_widget.text_length + 1).min (l_anchor_position + annotation_offset)
				if l_has_selection then
					a_widget.set_selection (l_new_anchor_position, l_new_caret_position)
				else
					a_widget.set_caret_position ((a_widget.text_length + 1).min (l_new_caret_position))
				end
			end
		ensure
			one_symbol: a_widget.text_length > 0 implies a_widget.text.occurrences (annotation_symbol) = 1
			replaced_first: is_symbol_prepended and then a_widget.text_length > 0 implies a_widget.text.item (1) = annotation_symbol
			replaced_last: (not is_symbol_prepended) and then a_widget.text_length > 0 implies a_widget.text.item (a_widget.text_length) = annotation_symbol
		end

	apply_formatting (a_string: STRING_32): STRING_32
			-- <Precursor>
		do
			Result := Precursor (a_string)
			if not Result.is_empty then
				if is_symbol_prepended then
					Result := annotation_string + Result
				else
					Result := Result + annotation_string
				end
			end
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

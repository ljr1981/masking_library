note
	description: "[
			Specialization of {TEXT_INPUT_MASK} which handles READABLE_STRING_GENERAL input.
			]"
	purpose: "[
			This mask is used as a variable input mask to filter and format input in the form of strings.
			]"
	how: "[
			The String Value Input Mask uses a string `mask specification' to determine what type of character can be placed in each of the
			allowed spaces in the field.
			]"
	examples: "[
			See {STRING_MASK_TEST_SET}.masking_example
			
			┌───────────────────────────────────────────────────────────┬──────────────────────────────────────────────────────────────────────────────┐
			│create string_value_input_mask.make_repeating ("!") 		│forces all alphabetic characters to uppercase.
			│create string_value_input_mask.make_repeating ("X") 		│allows unrestricted character entry.
			│create string_value_input_mask.make_repeating ("K") 		│forces alphabetic characters to uppercase and also allows numeric characters.
			│create string_value_input_mask.make_repeating ("9") 		│allows digits only
			│create string_value_input_mask.make ("(###) ###-####") 	│allows digits and displays a typical phone format, like '(212) 555-4565'
			│create string_value_input_mask.make ("###-##-####") 		│a typical SSN format, like '555-55-5555'
			│create string_value_input_mask.make ("__/__") 				│a MM/YY type format, the '_' allows digits or spaces, like ' 8/65' or '8 /65'
			└───────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────────────┘

			See also {TEXT_INPUT_MASK}.initialize_from_mask_string for more allowable specifications.
			]"
	date: "$Date: 2015-02-25 13:18:53 -0500 (Wed, 25 Feb 2015) $"
	revision: "$Revision: 1345 $"
	generic_definition: "V -> READABLE_STRING_GENERAL Value; CON -> Type of the DATA_COLUMN_METADATA to use as a constraint"

class
	STRING_VALUE_INPUT_MASK

inherit
	TEXT_INPUT_MASK [READABLE_STRING_GENERAL, STRING_COLUMN_METADATA]
		redefine
			handle_key_string,
			handle_paste,
			is_valid_constraint
		end

create
	make, make_repeating

feature {NONE} -- Initialization

	make (a_mask: STRING)
			-- Create using `a_mask'.
		require
			is_valid_mask: is_valid_mask (a_mask)
		do
			mask_specification := a_mask
			initialize_from_mask_string
		end

	make_repeating (a_mask: STRING)
			-- Create using `a_mask' as a repeating specification.
		require
			is_valid_mask: is_valid_mask (a_mask)
		do
			is_repeating_specification := True
			make (a_mask)
		ensure
			is_repeating_specification: is_repeating_specification
		end

feature -- Access

	default_value: READABLE_STRING_GENERAL
			-- <Precursor>
		do
			Result := ""
		end

feature -- Status Report

	is_valid_constraint (a_constraint: detachable DATA_COLUMN_METADATA [ANY]): BOOLEAN
			-- Is `a_constraint' consistent with specification of Current?
		do
			Result := Precursor (a_constraint) and then attached a_constraint and then open_item_count <= a_constraint.capacity.as_natural_32
		end

feature {NONE} -- Implementation

	handle_key_string (a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_caret_position, l_new_text_index, l_text_index, l_before_end_index: INTEGER
			l_before, l_new_text, l_attached_inserted_text: STRING_32
			l_inserted_text: detachable STRING_32
		do
			l_caret_position := a_widget.caret_position
				l_inserted_text := numpad_correction (a_key_string).corrected
				l_attached_inserted_text := numpad_correction (a_key_string).corrected
			if is_repeating_specification or else not is_delete_mode then
				Precursor (a_key_string, a_widget)
			elseif (a_widget.has_selection and then not region_contains_open_item (a_widget.start_selection, a_widget.end_selection - 1)) or else ((not is_currently_pasting) and then l_attached_inserted_text.is_integer and then (is_shift_pressed or is_control_pressed)) then
				-- Do Nothing
			else
				if a_widget.has_selection then
					from
						l_caret_position := a_widget.start_selection.min (a_widget.end_selection)
					until
						not mask.valid_index (l_caret_position) or else mask [l_caret_position].is_open
					loop
						l_caret_position := l_caret_position + 1
					end
				else
					l_caret_position := a_widget.caret_position
				end
				if mask.valid_index (l_caret_position) and then mask [l_caret_position].is_open and then mask [l_caret_position].is_valid_character (l_attached_inserted_text.item (1)) then
					create l_new_text.make (mask.count)
					l_before_end_index := l_caret_position - 1
					if l_before_end_index > 0 then
						l_before := a_widget.text.substring (1, l_before_end_index)
					else
						l_before := ""
					end
					l_new_text.append (l_before)
					l_new_text_index := l_caret_position
					if a_widget.has_selection then
						l_text_index := a_widget.start_selection.max (a_widget.end_selection)
					else
						l_text_index := l_new_text_index
					end

					from
					until
						not mask.valid_index (l_new_text_index)
					loop
						if mask[l_new_text_index].is_open then
							if attached l_inserted_text then
								l_new_text.append (l_inserted_text)
								l_inserted_text := Void
								if a_widget.text.valid_index (l_text_index) and then (a_widget.text.item (l_text_index) = open_data_character) then
									l_text_index := l_text_index + 1
								end
							else
								from
								until
									not mask.valid_index (l_text_index) or else mask [l_text_index].is_open
								loop
									l_text_index := l_text_index + 1
								end
								if mask.valid_index (l_text_index) then
									l_new_text.extend (a_widget.text.item (l_text_index))
									l_text_index := l_text_index + 1
								else
									l_new_text.extend (open_data_character)
								end
							end
						else
							l_new_text.extend (mask[l_new_text_index].character_to_display)
						end
						l_new_text_index := l_new_text_index + 1
					end
					if l_inserted_text = Void then
						l_caret_position := l_caret_position + 1
					end
					from
					until
						l_caret_position > l_new_text.count or else mask [l_caret_position].is_open
					loop
						l_caret_position := l_caret_position + 1
					end
					l_caret_position := l_caret_position.min (l_new_text.count)
					a_widget.set_text (l_new_text)
					a_widget.set_caret_position (l_caret_position)
				end
			end
		end

	handle_paste (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		local
			l_clipboard_text, l_filtered_text, l_widget_text: STRING_32
			l_filtered_text_index, l_selection_count, l_inserted_count: INTEGER
		do
			if is_repeating_specification or else not is_delete_mode then
				Precursor (a_widget)
			else
				is_currently_pasting := True
				l_clipboard_text := ev_application.clipboard.text.twin
				create l_filtered_text.make (l_clipboard_text.count)
				if not open_items.is_empty then
					across l_clipboard_text as ic_clipboard_text loop
						if open_items [1].is_valid_character (ic_clipboard_text.item) and then ic_clipboard_text.item /= open_data_character then
							l_filtered_text.extend (ic_clipboard_text.item)
						end
					end
				end
				if a_widget.has_selection then
					from
						l_filtered_text_index := 1
						l_selection_count := open_items_in_region (a_widget.start_selection, a_widget.end_selection - 1)
					until
						l_filtered_text_index > l_filtered_text.count or l_inserted_count >= l_selection_count
					loop
						l_widget_text := a_widget.text.twin
						handle_key_string (create {STRING_32}.make_filled (l_filtered_text.item (l_filtered_text_index), 1), a_widget)
						if not l_widget_text.same_string (a_widget.text) then
							l_filtered_text_index := l_filtered_text_index + 1
						end
						l_inserted_count := l_inserted_count + 1
					end
				else
					across l_filtered_text as ic_text loop
						handle_key_string (create {STRING_32}.make_filled (ic_text.item, 1), a_widget)
					end
				end
				is_currently_pasting := False
			end
		end

	string_to_value (a_string: READABLE_STRING_GENERAL): READABLE_STRING_GENERAL
			-- <Precursor>
		local
			l_string: STRING_32
		do
			l_string := a_string.as_string_32.twin
			l_string := right_trim (l_string)
			Result := l_string
		end

	value_to_string (a_value: READABLE_STRING_GENERAL): READABLE_STRING_GENERAL
			-- String representation of `a_value
		do
			Result := a_value
		end

	data_exceeds_column_constraint_message (a_result: READABLE_STRING_GENERAL; a_constraint: detachable DATA_COLUMN_METADATA [ANY]): STRING_32
			-- <Precursor>
		require else
			attached_constraint: attached a_constraint
		do
			check attached_constraint: attached a_constraint then
				Result := translated_string (masking_messages.text_entered_too_long_message, [a_result.count.out, a_constraint.capacity.out])
			end
		end

	is_currently_pasting: BOOLEAN
			-- Is the mask currently performing a paste operation
			-- TODO Can we eliminate this state from the mask? Should be OK within a single threaded GUI environment, but still...

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

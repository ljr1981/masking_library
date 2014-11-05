note 
	description: "[
			An Integer Value Input Mask is a {NUMERIC_INPUT_MASK} with support for negative numbers.
	purpose: "[
			Some fields need to permit and display an integer value.
			]"
	how: "[
			See also {INPUT_MASK}.
		]"
	generic_definition: "V -> INTEGER Value; CON -> Type of the DATA_COLUMN_METADATA to use as a constraint"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: $"

class
	INTEGER_VALUE_INPUT_MASK

inherit
	NUMERIC_VALUE_INPUT_MASK [INTEGER, INTEGER_COLUMN_METADATA]
		redefine
			is_valid_constraint,
			is_valid_character_for_mask
		end

create
	make

feature {NONE} -- Initialization

	make (a_capacity: NATURAL_8)
			-- Create a default integer value mask.
		do
			capacity := a_capacity
		end

feature -- Access

	default_value: INTEGER
			-- <Precursor>
		do
		end

feature -- Status Report

	is_valid_character_for_mask (a_character: CHARACTER_32): BOOLEAN
			-- <Precursor>
		do
			Result := Precursor (a_character) or else a_character ~ '-'
		end

	is_valid_constraint (a_constraint: detachable DATA_COLUMN_METADATA [ANY]): BOOLEAN
			-- Is `a_constraint' consistent with specification of Current?
		do
			Result := Precursor (a_constraint) and then attached a_constraint and then a_constraint.capacity.as_natural_32 >= capacity
		end

feature {TEST_SET_BRIDGE} -- Implementation

	remove_implementation (a_string: STRING_32; a_constraint: detachable INTEGER_COLUMN_METADATA): TUPLE [value: INTEGER_32; error_message: STRING_32]
			-- <Precursor>
			--| Currently does not report presence of illegal characters in `a_string'
		local
			l_string, l_error_message: STRING_32
			l_value: INTEGER
			l_text_is_too_long, l_has_invalid_characters: BOOLEAN
		do
			l_string := remove_formatting (a_string)
			l_value := string_to_value (l_string)
			l_text_is_too_long := False
			if capacity > 0 then
				l_text_is_too_long := l_string.count > capacity + a_string.has (negative_sign).to_integer
			end

			across l_string as ic_items loop
				if not is_valid_character_for_mask (ic_items.item) then
					l_has_invalid_characters := True
				end
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

	string_to_value (a_string: STRING_32): like default_value
			-- <Precursor>
		do
			if a_string.is_integer then
				Result := a_string.to_integer
			end
		end

	value_to_string (a_value: like default_value): READABLE_STRING_GENERAL
			-- String representation of `a_value
		do
			Result := a_value.out
		end

	data_exceeds_column_constraint_message (a_result: INTEGER; a_constraint: detachable DATA_COLUMN_METADATA [ANY]): STRING_32
			-- <Precursor>
		require else
			attached_constraint: attached a_constraint
		do
			check column_constraint_attached: attached a_constraint then
				Result := translated_string (masking_messages.integer_entered_too_large_message, [a_result.out, (a_constraint.capacity ^ 10) - 1])
			end
		end

	fits_in_mask (a_text: STRING_32): BOOLEAN
			-- Does `a_text' fit in the current mask?
		local
			l_digit_count: like digit_count
		do
			l_digit_count := digit_count (a_text)
			Result := l_digit_count.integer <= capacity and then l_digit_count.decimal <= 0
		end

note
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

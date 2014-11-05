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
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 1345 $"
	generic_definition: "V -> READABLE_STRING_GENERAL Value; CON -> Type of the DATA_COLUMN_METADATA to use as a constraint"

class
	STRING_VALUE_INPUT_MASK

inherit
	TEXT_INPUT_MASK [READABLE_STRING_GENERAL, STRING_COLUMN_METADATA]
		redefine
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

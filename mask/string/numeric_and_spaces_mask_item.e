note
	description: "[
			A {MASK_ITEM_SPECIFICATION} which only allows the user to enter digits or spaces.
			]"
	date: "$Date: 2015-01-22 14:06:06 -0500 (Thu, 22 Jan 2015) $"
	revision: "$Revision: 10647 $"

class
	NUMERIC_AND_SPACES_MASK_ITEM

inherit
	ALPHA_NUMERIC_MASK_ITEM
		redefine
			is_strict,
			is_valid_character
		end

create
	make_allowing_spaces, make_allowing_spaces_no_error

feature {NONE}

	make_allowing_spaces (a_index: INTEGER)
			-- Allow spaces, but report to user that required characters are missing.
		do
			is_required := False
			make (a_index)
		end

	make_allowing_spaces_no_error (a_index: INTEGER)
			-- Allow spaces with no error reporting for spaces.
		do
			validity_level := validity_level_digits_and_spaces
			make_allowing_spaces (a_index)
		end

feature -- Status Report

	is_strict: BOOLEAN
			-- <Precursor>
		do
			Result := validity_level /= validity_level_digits_and_spaces
		end

	is_valid_character (a_character: CHARACTER_32): BOOLEAN
			-- <Precursor>
		do
			Result := a_character.to_character_8.is_digit or a_character = ' '
		end

feature {NONE} -- Implementation

	validity_level: NATURAL_8
		-- Validity level for `Current', default is to report spaces as invalid.

	validity_level_digits_only: NATURAL_8 = 0
	validity_level_digits_and_spaces: NATURAL_8 = 1

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

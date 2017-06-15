note
	description: "[
			A Mask Item Specification is a specification of allowed input at an index in a masked text field.
			]"
	date: "$Date: 2015-01-23 13:59:10 -0500 (Fri, 23 Jan 2015) $"
	revision: "$Revision: 1379 $"

deferred class
	MASK_ITEM_SPECIFICATION

feature {NONE} -- Initialization

	make (a_index: INTEGER)
			-- Create with `a_index'
		do
			index := a_index
		ensure
			index_updated: index = a_index
		end

feature -- Access

	index: INTEGER
			-- Index of Current

	left_open_index: INTEGER
			-- Index of the first open item to the left

	right_open_index: INTEGER
			-- Index of the first open item to the right

	left_closed_index: INTEGER
			-- Index of the first closed item to the left

	right_closed_index: INTEGER
			-- Index of the first closed item to the right

	character_for_character (a_character: CHARACTER_32): CHARACTER_32
			-- Character to use at current mask location for `a_character'
		do
			if is_valid_character (a_character) then
				Result := a_character
			else
				Result := character_to_display
			end
		end

	character_to_display: CHARACTER_32
			-- Character to display at Current location in the mask
		do
			Result := ' '
		end

feature -- Status Report

	is_open: BOOLEAN
			-- Is Current open to user input?
		deferred
		end

	is_required: BOOLEAN
			-- Is a non-blank character required at this position of the mask?
		deferred
		end

	is_strict: BOOLEAN
			-- Must `is_valid_character' be strictly adhered to allow matched character?
		deferred
		end

	is_valid_character (a_character: CHARACTER_32): BOOLEAN
			-- Is `a_character' valid for display at this location in the mask?
		do
			Result := a_character.is_character_8 implies a_character.to_character_8.is_printable
		end

	is_unitary_to (a_item: MASK_ITEM_SPECIFICATION): BOOLEAN
			-- Does `a_item' exhibit the same masking behavior as Current?
		do
			Result := 	(generating_type.type_id = a_item.generating_type.type_id) and then
						(is_required = a_item.is_required) and then
						(is_strict = a_item.is_strict) and then
						(character_to_display = a_item.character_to_display)
		ensure
			same_types: Result implies generating_type.type_id = a_item.generating_type.type_id
			is_required: Result implies (is_required = a_item.is_required)
			is_strict: Result implies (is_strict = a_item.is_strict)
			character_to_display: Result implies (character_to_display = a_item.character_to_display)
		end

feature -- Basic Operations

	set_index (a_index: INTEGER)
			-- Set `index' to `a_index'
		do
			index := a_index
		ensure
			index_updated: index = a_index
		end

	set_left_open_index (a_index: INTEGER)
			-- Set `left_open_index' to `a_index'
		do
			left_open_index := a_index
		ensure
			left_open_index_updated: left_open_index = a_index
		end

	set_right_open_index (a_index: INTEGER)
			-- Set `right_open_index' to `a_index'
		do
			right_open_index := a_index
		ensure
			right_open_index_updated: right_open_index = a_index
		end

	set_left_closed_index (a_index: INTEGER)
			-- Set `left_closed_index' to `a_index'
		do
			left_closed_index := a_index
		ensure
			left_closed_index_updated: left_closed_index = a_index
		end

	set_right_closed_index (a_index: INTEGER)
			-- Set `right_closed_index' to `a_index'
		do
			right_closed_index := a_index
		ensure
			right_closed_index_updated: right_closed_index = a_index
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

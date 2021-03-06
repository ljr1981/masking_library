note
	description: "[
			Mask item that consists of a set of allowed and forbidden mask items.
			]"
	date: "$Date: 2015-01-26 12:48:48 -0500 (Mon, 26 Jan 2015) $"
	revision: "$Revision: $"

class
	MASK_ITEM_SET_MASK_ITEM

inherit
	OPEN_MASK_ITEM
		redefine
			character_for_character,
			is_unitary_to,
			is_valid_character,
			make
		end

create
	make

feature {NONE} -- Initialization

	make (a_index: INTEGER)
			-- Create and initialize mask set.
		do
			create allowed_mask_items.make (2)
			create forbidden_mask_items.make (0)
		end

feature -- Access

	character_for_character (a_character: CHARACTER_32): CHARACTER_32
			-- Character to use at current mask location for `a_character'
		local
			i: INTEGER
		do
			if is_valid_character (a_character) then
				from
					Result := a_character
					i := 1
				until
					i > allowed_mask_items.count
				loop
					if allowed_mask_items [i].is_valid_character (Result) then
						Result := allowed_mask_items [i].character_for_character (Result)
					end
					i := i + 1
				end
			else
				Result := character_to_display
			end
		end

feature -- Status Report

	is_unitary_to (a_item: MASK_ITEM_SPECIFICATION): BOOLEAN
			-- <Precursor>
		do
			Result := 	Precursor (a_item) and then
						attached {MASK_ITEM_SET_MASK_ITEM} a_item as al_item and then
						item_lists_unitary (allowed_mask_items, al_item.allowed_mask_items) and then
						item_lists_unitary (forbidden_mask_items, al_item.forbidden_mask_items)
		ensure then
			allowed_items_unitary: Result implies attached {MASK_ITEM_SET_MASK_ITEM} a_item as al_item and then item_lists_unitary (allowed_mask_items, al_item.allowed_mask_items)
			forbidden_items_unitary: Result implies attached {MASK_ITEM_SET_MASK_ITEM} a_item as al_item and then item_lists_unitary (forbidden_mask_items, al_item.forbidden_mask_items)
		end

	is_valid_character (a_character: CHARACTER_32): BOOLEAN
			-- <Precursor>
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > allowed_mask_items.count
			loop
				if allowed_mask_items [i].is_valid_character (a_character) then
					Result := True
						-- Exit loop
					i := allowed_mask_items.count
				end
				i := i + 1
			end

			if Result then
				from
					i := 1
				until
					i > forbidden_mask_items.count
				loop
					if forbidden_mask_items [i].is_valid_character (a_character) then
						Result := False
							-- Exit loop
						i := forbidden_mask_items.count
					end
					i := i + 1
				end
			end
		end

feature {TEXT_INPUT_MASK} -- Basic Operations

	add_allowed_mask_item (a_item: MASK_ITEM_SPECIFICATION)
			-- Add `a_item' to `allowed_mask_items'.
		do
			allowed_mask_items.extend (a_item)
		end

	add_forbidden_mask_item (a_item: MASK_ITEM_SPECIFICATION)
			-- Add `a_item' to `forbidden_mask_items'.
		do
			forbidden_mask_items.extend (a_item)
		end

feature {TEST_SET_BRIDGE, MASK_ITEM_SET_MASK_ITEM} -- Implementation

	item_lists_unitary (a_list1, a_list2: ARRAYED_LIST [MASK_ITEM_SPECIFICATION]): BOOLEAN
			-- Are `a_list1' and `a_list2' unitary with each other?
			--| This feature has not been tested. When testing was attempted, discovered
			--| that the class can't even be created
		local
			l_list1, l_list2: ARRAYED_LIST [MASK_ITEM_SPECIFICATION]
			l_found_match: BOOLEAN
			l_item: MASK_ITEM_SPECIFICATION
		do
			l_list1 := a_list1.twin
			l_list2 := a_list2.twin
			from
				Result := True
			until
				l_list1.is_empty or else not Result
			loop
				l_list1.start
				l_item := l_list1.item
				from
					l_list2.start
					l_found_match := False
				until
					l_found_match or else l_list2.after
				loop
					if l_item.is_unitary_to (l_list2.item) then
						l_found_match := True
						l_list2.remove
					else
						l_list2.forth
					end
				end
				if l_found_match then
					l_list1.remove
				else
					Result := False
				end
			end
			Result := Result and then l_list1.is_empty and then l_list2.is_empty
		end

	allowed_mask_items: ARRAYED_LIST [MASK_ITEM_SPECIFICATION]
		-- Mask items that make up `Current'.

	forbidden_mask_items: ARRAYED_LIST [MASK_ITEM_SPECIFICATION]
		-- Mask items that are not allowed in `Current'.

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

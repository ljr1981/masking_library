note
	description: "[
			{OPEN_MASK_ITEM} objects that consists of a list of allowed and forbidden mask items
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: $"

class
	MASK_ITEM_SET_MASK_ITEM

inherit
	OPEN_MASK_ITEM
		redefine
			make, is_valid_character, character_for_character
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

feature {NONE} -- Implementation

	allowed_mask_items: ARRAYED_LIST [MASK_ITEM_SPECIFICATION]
		-- Mask items that make up `Current'.

	forbidden_mask_items: ARRAYED_LIST [MASK_ITEM_SPECIFICATION]
		-- Mask items that are not allowed in `Current'.

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

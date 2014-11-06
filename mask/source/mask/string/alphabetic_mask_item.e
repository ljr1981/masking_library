note
	description: "[
			An Alphabeitc Mask Item is a {MASK_ITEM_SPECIFICATION} which handles alphabetic input to a specific index in a masked field.
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: $"

class
	ALPHABETIC_MASK_ITEM

inherit
	OPEN_MASK_ITEM
		redefine
			is_valid_character, character_for_character
		end

create
	make, make_lower_case, make_upper_case

feature {NONE} -- Initialization

	make_lower_case (a_index: INTEGER)
			-- Create `Current' so that it adjusts items to lower case.
		do
			case_adjustment_code := case_adjustment_lower
			make (a_index)
		end

	make_upper_case (a_index: INTEGER)
			-- Create `Current' so that it adjusts items to upper case.
		do
			case_adjustment_code := case_adjustment_upper
			make (a_index)
		end

feature -- Access

	character_for_character (a_character: CHARACTER_32): CHARACTER_32
			-- Character to use at current mask location for `a_character'
		do
			if is_valid_character (a_character) then
				Result := a_character
					-- Adjust case if necessary.
				if case_adjustment_code /= case_adjustment_normal and then a_character.is_character_8 then
					if case_adjustment_code = case_adjustment_upper then
						Result := a_character.to_character_8.as_upper
					else
						Result := a_character.to_character_8.as_lower
					end
				end
			else
				Result := character_to_display
			end
		end

feature -- Status Report

	is_valid_character (a_character: CHARACTER_32): BOOLEAN
			-- <Precursor>
		do
			Result := a_character.is_character_8 implies (a_character.to_character_8.is_lower or a_character.to_character_8.is_upper)
		end

feature {NONE} -- Implementation

	case_adjustment_code: NATURAL_8
		-- 0 for leaving characters as is, 1 for changing to lowercase, 2 for changing to upper case.

	case_adjustment_normal: NATURAL_8 = 0
	case_adjustment_lower: NATURAL_8 = 1
	case_adjustment_upper: NATURAL_8 = 2
		-- Case Adjustment codes for `Current'

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

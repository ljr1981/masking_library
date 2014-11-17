note
	description: "[
			{ALPHA_NUMERIC_MASK_ITEM} objects that allow numeric and space characters at a specific index in a masked field
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

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

	make_allowing_spaces (a_value: INTEGER)
			-- Allow spaces, but report to user that required characters are missing.
		do
			is_required := False
			make (a_value)
		end

	make_allowing_spaces_no_error (a_value: INTEGER)
			-- Allow spaces with no error reporting for spaces.
		do
			validity_level := validity_level_digits_and_spaces
			make_allowing_spaces (a_value)
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

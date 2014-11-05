note
	description: "[
					Representation of an example MASKED_STRING_FIELD field which is masked.
					]"
	date: "$Date: 2014-03-20 09:09:47 -0400 (Thu, 20 Mar 2014) $"
	revision: "$Revision: 8865 $"

class
	MASKED_STRING_FIELD

inherit
	MASKED_DATUM_FIELD [STRING, EV_TEXT_FIELD, EV_HORIZONTAL_BOX, STRING_VALUE_INPUT_MASK]

create
	make_with_caption_and_pattern,
	make_with_caption_and_repeating_pattern

feature {NONE} -- Implementation

	create_interface_objects
			-- <Precursor>
		do
			create box
			create widget
		end

	create_mask
			-- <Precursor>
		require else
			repeating_has_character: is_repeating_pattern_used implies attached repeating_pattern_character
		do
			if is_repeating_pattern_used then
				create mask.make_repeating (repeating_pattern_character.out)
			else
				create mask.make (mask_pattern_string)
			end
		end

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

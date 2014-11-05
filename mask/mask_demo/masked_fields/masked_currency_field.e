note
	description: "[
					Representation of an example MASKED_CURRENCY_FIELD field which is masked.
					]"
	date: "$Date: 2014-03-19 20:54:25 -0400 (Wed, 19 Mar 2014) $"
	revision: "$Revision: 8864 $"

class
	MASKED_CURRENCY_FIELD

inherit
	MASKED_DATUM_FIELD [DECIMAL, EV_TEXT_FIELD, EV_HORIZONTAL_BOX, CURRENCY_VALUE_INPUT_MASK]

create
	make_with_caption_and_precision

feature {NONE} -- Implementation

	make_with_caption_and_precision (a_caption: like caption; a_content: DECIMAL; a_scale, a_capacity: NATURAL_8)
			-- Initialize Current with `a_caption' with some `a_conent', and `a_scale' and `a_capacity' for precision.
		do
			scale := a_scale
			capacity := a_capacity
			make_with_caption (a_caption, a_content)
		ensure
			scale_set: scale = a_scale
			capacity_set: capacity = a_capacity
		end

feature {NONE} -- Implementation

	create_interface_objects
			-- <Precursor>
		do
			create box
			create widget
		end

	create_mask
			-- <Precursor>
		do
			create mask.make (scale, capacity)
		end

	scale,
	capacity: NATURAL_8

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

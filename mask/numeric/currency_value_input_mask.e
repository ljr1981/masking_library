note
	description: "[
			{DECIMAL_VALUE_INPUT_MASK} objects specialized to display decimal values prefixed by "$".
	purpose: "[
			Use this mask if you want a decimal field that has a '$' in front of the decimal.
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: $"

class
	CURRENCY_VALUE_INPUT_MASK

inherit
	ANNOTATED_DECIMAL_VALUE_INPUT_MASK
		redefine
			fix_pointer_position_implementation,
			initial_mask,
			remove_formatting
		end

create
	make, make_currency

feature {NONE} -- Initialization

	make_currency (a_capacity: NATURAL_8)
			-- Create Currency mask with `a_capacity';
		do
			make (currency_digits_count.as_natural_8, a_capacity)
		end

feature -- Status Report

	is_symbol_prepended: BOOLEAN
			-- <Precursor>
		do
			Result := True
		end

feature -- Access

	currency_digits_count: INTEGER = 2
			-- Number of digits in currency cents.

	annotation_symbol: CHARACTER_32
			-- <Precursor>
		do
			Result := '$'
		end

feature -- Event Handling

	fix_pointer_position_implementation (a_widget: EV_TEXT_COMPONENT)
			-- Ensure user has not used mouse to place caret in an illegal position for this mask
		do
			if not a_widget.has_selection and then not a_widget.text.is_empty and then a_widget.caret_position = 1 then
				a_widget.set_caret_position (2)
			else
				Precursor (a_widget)
			end
		end

feature {NONE} -- Implementation

	remove_formatting (a_string: STRING_32): STRING_32
			-- <Precursor>
		local
			l_string: STRING_32
		do
			l_string := Precursor (a_string)
			if not l_string.is_empty and then l_string [1] ~ '$' then
				l_string := l_string.substring (2, l_string.count)
			end
			Result := l_string
		end

	initial_mask: STRING
			-- <Precursor>
		do
			Result := ":$"
		end

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

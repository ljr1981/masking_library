note
	description: "[
			{DECIMAL_VALUE_INPUT_MASK} objects specialized to display decimal values suffixed by "%".
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

class
	PERCENT_VALUE_INPUT_MASK

inherit
	ANNOTATED_DECIMAL_VALUE_INPUT_MASK
		redefine
			fix_pointer_position_implementation,
			remove_implementation
		end

create
	make

feature -- Event Handling

	fix_pointer_position_implementation (a_widget: EV_TEXT_COMPONENT)
			-- Ensure user has not used mouse to place caret in an illegal position for this mask
		do
			if not a_widget.has_selection and then not a_widget.text.is_empty and then a_widget.caret_position > (a_widget.text_length - 1) then
				a_widget.set_caret_position (a_widget.text_length - 1)
			else
				Precursor (a_widget)
			end
		end

feature {TEST_SET_BRIDGE} -- Implementation

	remove_implementation (a_string: STRING_32; a_constraint: detachable DECIMAL_COLUMN_METADATA): TUPLE [value: DECIMAL; error_message: STRING_32]
			-- <Precursor>
		local
			l_max_value_string: STRING_32
			l_value, l_maximum_value: DECIMAL
		do
			l_max_value_string := "1"
			Result := Precursor (a_string, a_constraint)
			if Result.error_message.is_empty then
				l_value := Result.value
				if a_string.count = capacity then
					from until l_max_value_string.count >= (capacity - scale) - 1 loop
						l_max_value_string.append ("0")
					end
					if not l_max_value_string.is_empty then
						l_max_value_string.append (".00")
						create l_maximum_value.make_from_string (l_max_value_string)
						if l_value > l_maximum_value then
							Result.error_message := translated_string (masking_messages.invalid_percent_error, [])
						end
					end
				end
			end
		end

	annotation_symbol: CHARACTER_32
			-- <Precursor>
		do
			Result := '%%'
		end

	is_symbol_prepended: BOOLEAN = False
			-- <Precursor>

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

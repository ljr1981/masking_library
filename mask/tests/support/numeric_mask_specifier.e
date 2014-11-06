note
	description: "Summary description for {NUMERIC_MASK_SPECIFIER}."
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

class
	NUMERIC_MASK_SPECIFIER

feature -- Access

	valid_modifiers: ARRAY [STRING_32]
		once
				--| "s" = shift pressed
				--| "c" = ctrl pressed
				--| "cs" = ctrl+shift pressed
			Result := <<("s").as_string_32, ("c").as_string_32, ("cs").as_string_32>>
			Result.compare_objects
		end

feature -- Status Report

	is_valid_modifier (a_modifier: STRING_32): BOOLEAN
			-- Is `a_modifier' a valid modifier?
		do
			Result := valid_modifiers.has (a_modifier)
		end

	is_valid_widget_text_specification (a_specification: STRING_32): BOOLEAN
			-- Is `a_specification' a valid widget text specification?
		do
			Result := 	(a_specification.occurrences ('|') = 1) and then
						(a_specification.occurrences ('!') <= 1) and then
						not a_specification.has_substring ("|!") and then
						not a_specification.has_substring ("!|")
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

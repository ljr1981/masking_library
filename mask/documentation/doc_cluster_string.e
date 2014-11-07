note
	description: "[
			Documentation of String cluster in Mask cluster.
			]"
	purpose: "[
			To provide masking facilities for various {STRING} inputs like Social Security
			Numbers or Phone Numbers, and so on.
			]"
	basics: "[
			Use {STRING_VALUE_INPUT_MASK}.make or {STRING_VALUE_INPUT_MASK}.make_repeating
			to apply {STRING} masking to string input on {EV_TEXTABLE} controls.
			]"
	tutorial: "[
		Text Patterns & Masking
		=======================
		User editable input text can be everthing from totally ad-hoc to highly controlled
		by some rigid pattern or "mask". The String Cluster classes facilitate these
		user-input and editing-control masking needs.
		
		Some text is completely free-form and arbitrary. User-input in such fields may not
		be maskable. Masking does not apply to these use-cases.
		
		Some text is free-form, but controlled by a use-case rule like: "Must be all-caps"
		or "Must be all-caps and alphabetic characters only".
		
		Other text is not free-form, but follows a defined pattern (e.g. a U.S. Phone Number
		might follow a patter like: "(999) 999-9999").
		
		Still other logic in a mask will handle filtering (blocking) or replacement of
		user-input. For example, the rule might be: "The mask accepts alphabetic characters
		only; non-alpha characters are replaced with spaces".
		]"
	examples: "[
			See {STRING_VALUE_INPUT_MASK} for examples of creation with different formats.
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

deferred class
	DOC_CLUSTER_STRING

feature {NONE} -- Documentation

	string_value_input_mask: detachable STRING_VALUE_INPUT_MASK
			-- Mask that handles {STRING} user-input.

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

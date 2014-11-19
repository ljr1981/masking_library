note
	description: "[
			Masks for various types of numeric input, such as USA social-security
			numbers, phone numbers, etc.
			]"
	purpose: "[
		To provide masking facilities to {STRING} interactive user input.
		]"
	how: "[
		When the mask object is initialized, a 'map' of MASK_ITEM_SPECIFICATIONs
		(objects whose class names ends with ...MASK_ITEM) is built based on the
		mask string, which is later used polymorphicaly to help manage keystrokes
		in the widget.
		]"
	examples: "[
			See {STRING_VALUE_INPUT_MASK} for examples of creation with different
			formats.
			]"
	hierarchy: "[
			        {TEXT_INPUT_MASK} ==================> {MASK_ITEM_SPECIFICATION} <-----------------------------------------------------------+
			                |                                         |                                                                         |
			     {STRING_VALUE_INPUT_MASK}                            |                                                                 {PRESET_MASK_ITEM}
			                                                          |                                                                         |
			            +------------------------+---------->  {OPEN_MASK_ITEM} <----------------+------------------------+             {CLOSED_MASK_ITEM}
			            |                        |                    ^                          |                        |                     |
			            |                        |                    |                          |                        |                     |
			{MASK_ITEM_SET_MASK_ITEM}   {NUMERIC_MASK_ITEM} {ALPHABETIC_MASK_ITEM}  {FORCE_UPPER_CASE_MASK_ITEM}  {WILDCARD_MASK_ITEM}  {LITERAL_MASK_ITEM}
			                                         \         /                                 |
			                                  {ALPHA_NUMERIC_MASK_ITEM}          {UPPERCASE_ALPHA_NUMERIC_MASK_ITEM}
			                                             |
			                               {NUMERIC_AND_SPACES_MASK_ITEM}
		]"
	classes: "[
		{STRING_VALUE_INPUT_MASK}
			Specialization of {TEXT_INPUT_MASK} which handles {READABLE_STRING_GENERAL}
			input

		{MASK_ITEM_SPECIFICATION}
			Specifications of allowed input at a particular character index in a masked
			text field

		{PRESET_MASK_ITEM}
			{MASK_ITEM_SPECIFICATION} objects that lock a character to a specific index
			in a masked field

		{CLOSED_MASK_ITEM}
			{MASK_ITEM_SPECIFICATION} objects for a character that may not be changed
			by user input

		{LITERAL_MASK_ITEM}
			{MASK_ITEM_SPECIFICATION} objects for a literal character in a mask

		{OPEN_MASK_ITEM}
			{MASK_ITEM_SPECIFICATION} objects that represent input-field characters that
			may be changed by user input

		{MASK_ITEM_SET_MASK_ITEM}
			{OPEN_MASK_ITEM} objects that consists of a list of allowed and forbidden
			mask items

		{WILDCARD_MASK_ITEM}
			{OPEN_MASK_ITEM} objects that allow user to input any printable character
			without change or restriction

		{FORCE_UPPER_CASE_MASK_ITEM}
			{OPEN_MASK_ITEM} objects that force user input to upper case

		{UPPERCASE_ALPHA_NUMERIC_MASK_ITEM}
			{FORCE_UPPER_CASE_MASK_ITEM} objects that also allow numeric input in addition
			to alphabetic, at a specific index in a masked field while forcing alphabetic
			input to upper case

		{NUMERIC_MASK_ITEM}
			{OPEN_MASK_ITEM} objects that only allow numeric input

		{ALPHABETIC_MASK_ITEM}
			{OPEN_MASK_ITEM} objects that accept alphabetic input to a specific index in a
			masked field

		{ALPHA_NUMERIC_MASK_ITEM}
			{OPEN_MASK_ITEM} objects that accept both alphabetic and numeric input to a
			specific index in a masked field

		{NUMERIC_AND_SPACES_MASK_ITEM}
			{ALPHA_NUMERIC_MASK_ITEM} objects that allow numeric and space characters at a
			specific index in a masked field

		]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

deferred class
	DOC_CLUSTER_STRING

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

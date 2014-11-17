note
	description: "[
			Masks for various types of numeric input.
			]"
	basics: "[
			Types of numeric input currently covered are:  integers, decimals, currency values, and percents.
			]"
	usage: "[
			See examples in
				{NUMERIC_MASK_TEST_SET}.masking_example_integer, and
				{NUMERIC_MASK_TEST_SET}.masking_example_decimal.

			NOTE: EiffelStudio's Clickable-view from MASK.ECF's "test" target provides click-and-drop access
			to these examples in the above text.
			]"
	hierarchy: "[
			                                    {NUMERIC_INPUT_MASK}
			                                     /                 \
			             {DECIMAL_VALUE_INPUT_MASK}               {INTEGER_VALUE_INPUT_MASK}
			                         |
			         {ANNOTATED_DECIMAL_VALUE_INPUT_MASK}
			                 /                 \
			{PERCENT_VALUE_INPUT_MASK}    {CURRENCY_VALUE_INPUT_MASK}
		]"
	classes: "[
		{INTEGER_VALUE_INPUT_MASK}
			{NUMERIC_INPUT_MASK} objects restricted to positive and negative integers.

		{DECIMAL_VALUE_INPUT_MASK}
			{NUMERIC_INPUT_MASK} objects that only allow numeric and `.' input.

		{ANNOTATED_DECIMAL_VALUE_INPUT_MASK}
			{DECIMAL_VALUE_INPUT_MASK} objects that permit input prefixed or suffixed with a character (e.g. 0.00% or $0.00)

		{CURRENCY_VALUE_INPUT_MASK}
			{DECIMAL_VALUE_INPUT_MASK} objects specialized to display decimal values prefixed by "$".

		{PERCENT_VALUE_INPUT_MASK}
			{DECIMAL_VALUE_INPUT_MASK} objects specialized to display decimal values suffixed by "%".
		]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

deferred class
	DOC_CLUSTER_NUMERIC

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

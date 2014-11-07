note
	description: "[
			Numeric Text Mask Cluster Documentation.
			]"
	purpose: "[
			To provide masks that enforce numeric input only.
			]"
	basics: "[
			Use masks in this cluster to control input formatting of integers, decimals, 
			currencies, and percents.
			]"
	usage: "[
			See {NUMERIC_MASK_TEST_SET}.masking_example_integer
			See {NUMERIC_MASK_TEST_SET}.masking_example_decimal
			
			NOTE: You can only access these in Clickable-view from the mask:test target.
			]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

deferred class
	DOC_CLUSTER_NUMERIC

feature {NONE} -- Documentation

	integer_value_input_mask: detachable INTEGER_VALUE_INPUT_MASK
			-- Masking for {INTEGER} data.
		note
			example: "[
					See {INPUT_MASK_TEST_SET}.masking_example_integer
					]"
		attribute
			Result := Void
		end

	decimal_value_input_mask: detachable DECIMAL_VALUE_INPUT_MASK
			-- Masking for {DECIMAL} data.
		attribute
			Result := Void
		end

	currency_value_input_mask: detachable CURRENCY_VALUE_INPUT_MASK
			-- Masking for {NUMERIC} data operating as Currency.
		attribute
			Result := Void
		end

	percent_value_input_mask: detachable PERCENT_VALUE_INPUT_MASK
			-- Masking for {NUMERIC} data operating as Percentages.
		attribute
			Result := Void
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

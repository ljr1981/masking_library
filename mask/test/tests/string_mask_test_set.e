note
	description: "Tests of STRING_VALUE_INPUT_MASK"
	date: "$Date: 2014-11-03 15:29:49 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10181 $"

class
	STRING_MASK_TEST_SET

inherit
	INPUT_MASK_TEST_SET

feature -- Tests

	masking_example
			-- Demonstrates basic usage of a string mask; numeric masks are very similar
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_field: EV_TEXT_FIELD
		do
			create l_mask.make ("(###) ###-####")
			create l_field
			--| Set up the mask to properly process keystrokes in the field
			l_mask.initialize_masking_widget_events (l_field)
			--| Set a masked value into the field
			--| Note: In general, masked text should be placed in the field before accepting user keystrokes
			--| as some masks cannot process keystrokes on an empty field
			l_field.set_text (l_mask.apply ("8888888888").masked_string)
			assert_strings_equal ("field_has_masked_text", "(888) 888-8888", l_field.text)
			--| Unmask the value
			assert_strings_equal ("unmasked_value", "8888888888", l_mask.remove (l_field.text, Void).value)
		end

	test_allow_all_mask
			-- Test behavior of Allow All Repeating Mask
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make_repeating ("X")
			--| Obtain csv file from:
			--| ".\test\specification\*.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\test\specification\string_allow_all.csv")
			test_mask (l_file, l_mask, keys_used_in_repeating_mask_tests)
		end

	test_force_upper_mask
			-- Test behavior of Force Upper Repeating Mask
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make_repeating ("!")
			--| Obtain csv file from:
			--| ".\test\specification\*.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\test\specification\string_force_upper.csv")
			test_mask (l_file, l_mask, keys_used_in_repeating_mask_tests)
		end

	test_digits_only_mask
			-- Test behavior of Digits Only Repeating Mask
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make_repeating ("9")
			--| Obtain csv file from:
			--| ".\test\specification\*.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\test\specification\string_digits_only.csv")
			test_mask (l_file, l_mask, keys_used_in_repeating_mask_tests)
		end

	test_k_mask
			-- Test behavior of 'K' item Repeating Mask
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make_repeating ("K")
			--| Obtain csv file from:
			--| ".\test\specification\*.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\test\specification\string_k_dash.csv")
			test_mask (l_file, l_mask, keys_used_in_repeating_mask_tests)
		end

	test_phone_number_mask
			-- Test behavior of a phone number mask
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make ("(###) ###-####")
			--| Obtain csv file from:
			--| ".\test\specification\*.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\test\specification\string_phone_number.csv")
			test_mask (l_file, l_mask, keys_used_in_repeating_mask_tests)
		end

	test_social_security_number_mask
			-- Test behavior of a social security number mask
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make ("###-##-####")
			--| Obtain csv file from:
			--| ".\test\specification\*.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\test\specification\string_social_security_number.csv")
			test_mask (l_file, l_mask, keys_used_in_repeating_mask_tests)
		end

	test_birthdate_mask
			-- Test behavior of a DD/MM birthdate mask
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make ("__/__")
			--| Obtain csv file from:
			--| ".\test\specification\*.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\test\specification\string_birthdate.csv")
			test_mask (l_file, l_mask, keys_used_in_repeating_mask_tests)
		end

	test_region_contains_open_item
			-- Test behavior of TEXT_INPUT_MASK.region_contains_open_item
		note
			testing:  "execution/isolated"
		local
			l_mask: STRING_VALUE_INPUT_MASK
		do
			create l_mask.make ("999---999")
			assert ("selection_1", l_mask.region_contains_open_item (1, 9))
			assert ("selection_2", l_mask.region_contains_open_item (1, 3))
			assert ("selection_3", l_mask.region_contains_open_item (6, 9))
			assert ("selection_4", l_mask.region_contains_open_item (3, 7))
			assert ("selection_5", not l_mask.region_contains_open_item (4, 6))
			assert ("selection_6", not l_mask.region_contains_open_item (4, 4))
			assert ("selection_7", not l_mask.region_contains_open_item (5, 5))
			assert ("selection_8", not l_mask.region_contains_open_item (6, 6))
			assert ("selection_9", not l_mask.region_contains_open_item (4, 5))
			assert ("selection_10", not l_mask.region_contains_open_item (5, 6))
			assert ("selection_11", l_mask.region_contains_open_item (3, 10))
			assert ("selection_12", l_mask.region_contains_open_item (7, 10))
			assert ("selection_13", l_mask.region_contains_open_item (9, 10))
			assert ("selection_14", not l_mask.region_contains_open_item (10, 10))
		end

feature {NONE} -- Implementation

		keys_used_in_repeating_mask_tests: ARRAYED_LIST [EV_KEY]
				-- Keys used to test repeating masks
		local
			l_key: EV_KEY
		do
			create Result.make (100)
			create l_key.make_with_code (key_tab)
			Result.extend (l_key)
			create l_key.make_with_code (key_4)
			Result.extend (l_key)
			create l_key.make_with_code (key_numpad_4)
			Result.extend (l_key)
			create l_key.make_with_code (key_numpad_add)
			Result.extend (l_key)
			create l_key.make_with_code (key_numpad_subtract)
			Result.extend (l_key)
			create l_key.make_with_code (key_dash)
			Result.extend (l_key)
			create l_key.make_with_code (key_period)
			Result.extend (l_key)
			create l_key.make_with_code (key_numpad_decimal)
			Result.extend (l_key)
			create l_key.make_with_code (key_a)
			Result.extend (l_key)
			create l_key.make_with_code (key_c)
			Result.extend (l_key)
			create l_key.make_with_code (key_x)
			Result.extend (l_key)
			create l_key.make_with_code (key_v)
			Result.extend (l_key)
			create l_key.make_with_code (key_back_space)
			Result.extend (l_key)
			create l_key.make_with_code (key_delete)
			Result.extend (l_key)
			Result.append (function_keys)
			Result.append (navigation_keys)
		end

note
	operations: "[
		This note entry is here to offer you instruction on how to effectively and quickly
		navigate through the documentation of this library and its clusters and classes.
		
		Virtues of Clickable-view & Notes
		=================================
		When viewing notes in the editor, embedded references which are Pick-and-Droppable in
		the Clickable-view are not when in the general editing view. Moreover, only classes
		which are "in-system" will have their features, clients, supplies, and so on viewable
		in the various tools. Therefore, based on these items, you will want to pick-and-drop
		"in-system" "classes-of-interest" (your interest) into the Class-tool and select the
		Clickable-view tool as your primary reader -OR- you will want to change the editor to
		the Clickable-view in order to explore (i.e. you are learning and not coding, so you
		want to use the Clickable-view in the editor to explore with while learning).
		
		One will find an advantage by viewing the class and its notes in the editor under the
		Clickable-view. When this is so, you may pick and drop a CLASS or Feature reference to
		the Class or Feature tool in this IDE.
		
		Known Editor Bugs
		=================
		There are presently bugs in the Eiffel Studio editor that work against good documentation
		exploration in the Clickable-view. Primarily, Tab characters and Unicode characters will
		be removed from the view in Clickable-view, but are shown in the Editable-view. Clearly,
		this behavior is against the purpose of the Clickable-view.
		]"
	glossary: "Definition of Terms"
	term: "[
		Clickable-view: Pick-and-drop a CLASS to the Class-tool and select the Clickable-view
		]"
	term: "[
		In-system: A class is termed "in-system" when it is referenced by a Client, which is
		in-turn referenced by another Client, and all the way back to the "root-class" of the
		system (see Project Settings or ECF file for root-class definition).
		]"
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

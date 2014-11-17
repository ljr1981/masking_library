note
	description: "[
					Example representation of a Main Window using masked fields.
					]"
	date: "$Date: 2014-03-21 09:13:09 -0400 (Fri, 21 Mar 2014) $"
	revision: "$Revision: 8882 $"

class
	MAIN_WINDOW

inherit
	EV_TITLED_WINDOW
		redefine
			create_interface_objects,
			initialize
		end

create
	make_with_title

feature {NONE} -- Initialization

	create_interface_objects
			-- <Precursor>
		local
			l_mask: INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]
		do
			create main_box

				-- Digit-only-masked phone number
				-- Simplistic example: A mask and a string text field.
				-- See: `{STRING_MASK_TEST_SET}.masking_example' for another version of this code.
			create {STRING_VALUE_INPUT_MASK} l_mask.make ("(999) 999-9999")					-- Create mask with a pattern.
			create masked_phone_digits_only													-- Create the empty control (an EV_TEXT_FIELD).
			l_mask.add_text_widget (masked_phone_digits_only)								-- Give control to the mask to set up events.
			masked_phone_digits_only.set_text (l_mask.apply ("          ").masked_string)	-- Set some masked empty text into control.
				-- NOTE: Try commenting out the line immediately above and see what happens.
				--			(hint: it generates an error!)
			masked_phone_digits_only.set_tooltip (phone_digits_only_tooltip_text)

				-- Pound-masked phone number
			create {STRING_VALUE_INPUT_MASK} l_mask.make ("(###) ###-####")					-- Create mask with a pattern.
			create masked_phone_pound_sign													-- Create the empty control (an EV_TEXT_FIELD).
			l_mask.add_text_widget (masked_phone_pound_sign)								-- Give control to the mask to set up events.
			masked_phone_pound_sign.set_text (l_mask.apply ("          ").masked_string)	-- Set some masked empty text into control.
			masked_phone_pound_sign.set_tooltip (pound_sign_tooltip_text)

				-- Data field
			create date.make_now
			create masked_date.make_with_caption ("Date: ", date)

				-- Integer field
			some_integer := 365
			create masked_integer.make_with_caption ("Some integer: ", some_integer)

				-- Decimal field
			create some_decimal.make_from_string ("3.14")
			create masked_decimal.make_with_caption_and_precision ("Some decimal: ", some_decimal, 2, 8)

				-- Money or currency field
			create some_money.make_from_string ("19.99")
			create masked_money.make_with_caption_and_precision ("Some money: ", some_money, 2, 13)

				-- Percent field
			create some_percent.make_from_string ("99.999")
			create masked_percent.make_with_caption_and_precision ("Some percent: ", some_percent, 3, 6)

				-- SSAN field
			create some_ssan.make_empty
			create masked_ssan.make_with_caption_and_pattern ("Some SSAN: ", "999-99-9999", some_ssan)

				-- digits_only_with_spaces
			create digits_only_with_spaces.make_from_string ("only THE digits and spaces will appear 0123456789")
			create masked_digits_only_with_spaces.make_with_caption_and_repeating_pattern ("Digits only with spaces: ", '#', digits_only_with_spaces)

				-- digits only
			create digits_only.make_from_string ("111 ONLY the digits 0123456789 will appear! 777 All else is converted to zero 999")
			create masked_digits_only.make_with_caption_and_repeating_pattern ("Digits only: ", '9', digits_only)

				-- alpha only
			create alpha_only.make_from_string ("alpha only and UPPER TOO but not 0123456789")
			create masked_alpha_only.make_with_caption_and_repeating_pattern ("Alpha only (others converted to spaces): ", 'A', alpha_only)

				-- upper alpha only
			create upper_alpha_only.make_from_string ("upper alpha only but 0123456789 are digits and have no upper version")
			create masked_upper_alpha_only.make_with_caption_and_repeating_pattern ("Upper Alpha only: ", 'K', upper_alpha_only)

				-- letters and digits only
			create letters_and_digits_only.make_from_string ("letters and digits only but not !@#$%%^&*() as they are converted to spaces in the GUI")
			create masked_letters_and_digits_only.make_with_caption_and_repeating_pattern ("Letters and digits only: ", 'N', letters_and_digits_only)

				-- forced upper alpha only
			create forced_upper_alpha_only.make_from_string ("forced upper alpha only") -- Notice how this gets forced to UPPER case on the text field in the GUI.
			create masked_forced_upper_alpha_only.make_with_caption_and_repeating_pattern ("Forced upper Alpha only: ", 'U', forced_upper_alpha_only)

				-- forced lower alpha only
			create forced_lower_alpha_only.make_from_string ("FORCED LOWER ALPHA ONLY") -- Notice how this gets forced to lower case on the text field in the GUI.
			create masked_forced_lower_alpha_only.make_with_caption_and_repeating_pattern ("Forced lower Alpha only: ", 'W', forced_lower_alpha_only)

			Precursor
		end

	initialize
			-- <Precursor>
		do
			extend (main_box)

				-- Extends
			main_box.extend (masked_phone_pound_sign)
			main_box.extend (masked_phone_digits_only)
			main_box.extend (masked_date.box)
			main_box.extend (masked_integer.box)
			main_box.extend (masked_decimal.box)
			main_box.extend (masked_money.box)
			main_box.extend (masked_percent.box)
			main_box.extend (masked_ssan.box)
			main_box.extend (masked_digits_only_with_spaces.box)
			main_box.extend (masked_digits_only.box)
			main_box.extend (masked_alpha_only.box)
			main_box.extend (masked_upper_alpha_only.box)
			main_box.extend (masked_letters_and_digits_only.box)
			main_box.extend (masked_forced_upper_alpha_only.box)
			main_box.extend (masked_forced_lower_alpha_only.box)

				-- Expansions
			main_box.disable_item_expand (masked_phone_pound_sign)
			main_box.disable_item_expand (masked_phone_digits_only)
			main_box.disable_item_expand (masked_date.box)
			main_box.disable_item_expand (masked_integer.box)
			main_box.disable_item_expand (masked_decimal.box)
			main_box.disable_item_expand (masked_money.box)
			main_box.disable_item_expand (masked_percent.box)
			main_box.disable_item_expand (masked_ssan.box)
			main_box.disable_item_expand (masked_digits_only_with_spaces.box)
			main_box.disable_item_expand (masked_digits_only.box)
			main_box.disable_item_expand (masked_alpha_only.box)
			main_box.disable_item_expand (masked_upper_alpha_only.box)
			main_box.disable_item_expand (masked_letters_and_digits_only.box)
			main_box.disable_item_expand (masked_forced_upper_alpha_only.box)
			main_box.disable_item_expand (masked_forced_lower_alpha_only.box)

				-- Focus handling
			masked_date.set_insertion_point_left
			masked_integer.set_select_on_focus_in
			masked_decimal.set_select_on_focus_in
			masked_money.set_select_on_focus_in
			masked_percent.set_select_on_focus_in
			masked_ssan.set_insertion_point_left
			masked_digits_only_with_spaces.set_select_on_focus_in
			masked_digits_only.set_select_on_focus_in
			masked_alpha_only.set_select_on_focus_in
			masked_upper_alpha_only.set_select_on_focus_in
			masked_letters_and_digits_only.set_select_on_focus_in
			masked_forced_upper_alpha_only.set_select_on_focus_in
			masked_forced_lower_alpha_only.set_select_on_focus_in

				-- Miscellaneous
			masked_digits_only_with_spaces.set_tooltip ("Only digits and spaces are allowed, an error message of missing required characters is reported to the user.")
			masked_digits_only.set_tooltip ("Only digits are allowed. No spaces and nothing coverted to spaces.")
			masked_alpha_only.set_tooltip ("Only alphabetic characters are allowed. Numbers converted to spaces.")
			masked_upper_alpha_only.set_tooltip ("Only uppercase alphabetic, numeric, and dash characters are allowed.")
			masked_letters_and_digits_only.set_tooltip ("Only letters and digits are allowed. (e.g. no special characters).")
			masked_forced_upper_alpha_only.set_tooltip ("Only alphabetic characters are allowed (forced to upper case and others converted to spaces).")
			masked_forced_lower_alpha_only.set_tooltip ("Only alphabetic characters are allowed (forced to lower case).")

			Precursor
		end

feature {NONE} -- Implementation: Access

	date: DATE_TIME

	some_integer: INTEGER

	some_decimal: DECIMAL

	some_money: DECIMAL

	some_percent: DECIMAL

	some_ssan: STRING

	digits_only_with_spaces: STRING

	digits_only: STRING

	alpha_only: STRING

	upper_alpha_only: STRING

	letters_and_digits_only: STRING

	forced_upper_alpha_only: STRING

	forced_lower_alpha_only: STRING

feature {NONE} -- Implementation: GUI Elements

	masked_phone_pound_sign: EV_TEXT_FIELD

	masked_phone_digits_only: EV_TEXT_FIELD

	masked_date: MASKED_DATE_TIME_FIELD

	masked_integer: MASKED_INTEGER_FIELD

	masked_decimal: MASKED_DECIMAL_FIELD

	masked_money: MASKED_CURRENCY_FIELD

	masked_percent: MASKED_PERCENT_FIELD

	masked_ssan: MASKED_STRING_FIELD

	masked_digits_only_with_spaces: MASKED_STRING_FIELD -- '#' repeating mask

	masked_digits_only: MASKED_STRING_FIELD -- '9' repeating mask

	masked_alpha_only: MASKED_STRING_FIELD -- 'A' repeating mask

	masked_upper_alpha_only: MASKED_STRING_FIELD -- 'K' repeating mask

	masked_letters_and_digits_only: MASKED_STRING_FIELD -- 'N' repeating mask

	masked_forced_upper_alpha_only: MASKED_STRING_FIELD -- 'U' repeating mask

	masked_forced_lower_alpha_only: MASKED_STRING_FIELD -- 'W' repeating mask

	main_box: EV_VERTICAL_BOX

feature {NONE} -- Implementation: Constants

	phone_digits_only_tooltip_text: STRING = "[
Masking set with (999) 999-9999

Note how seeding it with an empty string forces it to a string of 0's.

Compare with a mask of (###) ###-####, which (when seeded the same way)
results in empty content and not a string of 0's.
		]"

	pound_sign_tooltip_text: STRING = "[
Masking set with (###) ###-####

Note how seeding control with empty string does not result in 0's, but
with an %"empty phone number%".
		]"

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

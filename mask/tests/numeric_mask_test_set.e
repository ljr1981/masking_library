note
	description: "Tests of masks descending from NUMERIC_VALUE_INPUT_MASK"
	date: "$Date: 2014-11-03 15:29:49 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10181 $"

class
	NUMERIC_MASK_TEST_SET

inherit
	INPUT_MASK_TEST_SET

feature -- Tests

	masking_example_integer
			-- Demonstrates basic usage of an {INTEGER} mask.
		local
			l_mask: INTEGER_VALUE_INPUT_MASK
			l_field: EV_TEXT_FIELD
		do
				-- Create mask and field.
			create l_mask.make (4)
			create l_field
				-- Apply mask to field (e.g. mask is a factory that know how to set itself up on the widget).
			l_mask.initialize_masking_widget_events (l_field)
			assert_strings_equal ("empty_at_creation", "", l_field.text)
		end

	masking_example_decimal
			-- Demonstrates basic usage of an {DECIMAL} mask.
		local
			l_mask: DECIMAL_VALUE_INPUT_MASK
			l_field: EV_TEXT_FIELD
		do
				-- Create mask and field.
			create l_mask.make (2, 5) -- like $999.99 is our goal (5 total digits, 2 decimal places)
			create l_field
				-- Apply mask to field (e.g. mask is a factory that know how to set itself up on the widget).
			l_mask.initialize_masking_widget_events (l_field)
			assert_strings_equal ("empty_at_creation", "", l_field.text)
		end

	test_integer_mask
			-- Test behavior of INTEGER_VALUE_INPUT_MASK
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: INTEGER_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make (9)
			--| Obtain csv file from:
			--| ".\tests\specification\integer.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\tests\specification\integer.csv")
			test_mask (l_file, l_mask, keys_tested_in_integer_tests)
		end

	test_decimal_mask
			-- Test behavior of DECIMAL_VALUE_INPUT_MASK
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: DECIMAL_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make (4, 9)
			--| Obtain csv file from:
			--| ".\tests\specification\decimal_mask_not_is_nan_valid.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\tests\specification\decimal_mask_not_is_nan_valid.csv")
			test_mask (l_file, l_mask, keys_tested_in_numeric_tests)
			--|
			--| Obtain csv file from:
			--| ".\tests\specification\decimal_mask_is_nan_valid.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\tests\specification\decimal_mask_is_nan_valid.csv")
			l_mask.set_is_nan_valid (True)
			test_mask (l_file, l_mask, keys_tested_in_numeric_tests)
		end

	test_percent_mask
			-- Test behavior of PERCENT_VALUE_INPUT_MASK
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: PERCENT_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make (4, 9)
			--| Obtain csv file from:
			--| ".\tests\specification\decimal_percent_mask_not_is_nan_valid.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\tests\specification\decimal_percent_mask_not_is_nan_valid.csv")
			test_mask (l_file, l_mask, keys_tested_in_numeric_tests)
			--|
			--| Obtain csv file from:
			--| ".\tests\specification\decimal_percent_mask_is_nan_valid.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\tests\specification\decimal_percent_mask_is_nan_valid.csv")
			l_mask.set_is_nan_valid (True)
			test_mask (l_file, l_mask, keys_tested_in_numeric_tests)
		end

	test_currency_mask
			-- Test behavior of CURRENCY_VALUE_INPUT_MASK
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_mask: CURRENCY_VALUE_INPUT_MASK
			l_file: PLAIN_TEXT_FILE
		do
			create l_mask.make_currency (9)
			--| Obtain csv file from:
			--| ".\tests\specification\decimal_currency_mask_not_is_nan_valid.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\tests\specification\decimal_currency_mask_not_is_nan_valid.csv")
			test_mask (l_file, l_mask, keys_tested_in_numeric_tests)
			--|
			--| Obtain csv file from:
			--| ".\tests\specification\decimal_currency_mask_is_nan_valid.csv"
			--| Import it into a Google Spreadsheet to modify, then export back to csv.
			create l_file.make_open_read (".\tests\specification\decimal_currency_mask_is_nan_valid.csv")
			l_mask.set_is_nan_valid (True)
			test_mask (l_file, l_mask, keys_tested_in_numeric_tests)
		end

	test_percent_remove_replace_symbol
			-- Test features PERCENT_VALUE_INPUT_MASK.remove_symbol and PERCENT_VALUE_INPUT_MASK.replace_symbol
		note
			testing:  "execution/isolated"
		local
			l_mask: PERCENT_VALUE_INPUT_MASK
			l_widget: EV_TEXT_FIELD
			l_start_text, l_end_text: STRING_32
			l_window: EV_TITLED_WINDOW
		do
			create l_mask.make (4, 9)
			create l_widget
			create l_window
			l_window.set_height (300)
			l_window.set_width (300)
			l_window.extend (l_widget)
			l_window.show
			l_window.raise
			l_widget.show
			l_widget.set_focus
			l_start_text := "12.34%%"
			l_end_text := "12.34"
			l_widget.set_text ("")
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_1", "", l_widget.text)
			assert_equals ("caret_1", 1, l_widget.caret_position)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_1", "", l_widget.text)
			assert_equals ("replace_caret_1", 1, l_widget.caret_position)
			l_widget.set_text (l_start_text)
			l_widget.set_caret_position (2)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_2", l_end_text, l_widget.text)
			assert_equals ("caret_2", 2, l_widget.caret_position)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_2", l_start_text, l_widget.text)
			assert_equals ("replace_caret_2", 2, l_widget.caret_position)
			l_widget.set_text (l_start_text)
			l_widget.set_caret_position (4)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_3", l_end_text, l_widget.text)
			assert_equals ("caret_3", 4, l_widget.caret_position)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_3", l_start_text, l_widget.text)
			assert_equals ("replace_caret_3", 4, l_widget.caret_position)
			l_widget.set_text (l_start_text)
			l_widget.set_caret_position (l_start_text.count + 1)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_4", l_end_text, l_widget.text)
			assert_equals ("caret_4", l_widget.text_length + 1, l_widget.caret_position)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_4", l_start_text, l_widget.text)
			assert_equals ("replace_caret_4", l_end_text.count + 1, l_widget.caret_position)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (4, 1)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_5", l_end_text, l_widget.text)
			assert ("has_selection_5", l_widget.has_selection)
			assert_equals ("caret_5", 1, l_widget.caret_position)
			assert_equals ("start_selection_5", 1, l_widget.start_selection)
			assert_equals ("end_selection_5", 4, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_5", l_start_text, l_widget.text)
			assert ("replace_has_selection_5", l_widget.has_selection)
			assert_equals ("replace_caret_5", 1, l_widget.caret_position)
			assert_equals ("replace_start_selection_5", 1, l_widget.start_selection)
			assert_equals ("replace_end_selection_5", 4, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (1, 4)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_6", l_end_text, l_widget.text)
			assert ("has_selection_6", l_widget.has_selection)
			assert_equals ("caret_6", 4, l_widget.caret_position)
			assert_equals ("start_selection_6", 1, l_widget.start_selection)
			assert_equals ("end_selection_6", 4, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_6", l_start_text, l_widget.text)
			assert ("replace_has_selection_6", l_widget.has_selection)
			assert_equals ("replace_caret_6", 4, l_widget.caret_position)
			assert_equals ("replace_start_selection_6", 1, l_widget.start_selection)
			assert_equals ("replace_end_selection_6", 4, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (6, 2)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_7", l_end_text, l_widget.text)
			assert ("has_selection_7", l_widget.has_selection)
			assert_equals ("caret_7", 2, l_widget.caret_position)
			assert_equals ("start_selection_7", 2, l_widget.start_selection)
			assert_equals ("end_selection_7", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_7", l_start_text, l_widget.text)
			assert ("replace_has_selection_7", l_widget.has_selection)
			assert_equals ("replace_caret_7", 2, l_widget.caret_position)
			assert_equals ("replace_start_selection_7", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_7", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (2, 6)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_8", l_end_text, l_widget.text)
			assert ("has_selection_8", l_widget.has_selection)
			assert_equals ("caret_8", 6, l_widget.caret_position)
			assert_equals ("start_selection_8", 2, l_widget.start_selection)
			assert_equals ("end_selection_8", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_8", l_start_text, l_widget.text)
			assert ("replace_has_selection_8", l_widget.has_selection)
			assert_equals ("replace_caret_8", 6, l_widget.caret_position)
			assert_equals ("replace_start_selection_8", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_8", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (6, 1)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_9", l_end_text, l_widget.text)
			assert ("has_selection_9", l_widget.has_selection)
			assert_equals ("caret_9", 1, l_widget.caret_position)
			assert_equals ("start_selection_9", 1, l_widget.start_selection)
			assert_equals ("end_selection_9", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_9", l_start_text, l_widget.text)
			assert ("replace_has_selection_9", l_widget.has_selection)
			assert_equals ("replace_caret_9", 1, l_widget.caret_position)
			assert_equals ("replace_start_selection_9", 1, l_widget.start_selection)
			assert_equals ("replace_end_selection_9", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (1, 6)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_10", l_end_text, l_widget.text)
			assert ("has_selection_10", l_widget.has_selection)
			assert_equals ("caret_10", 6, l_widget.caret_position)
			assert_equals ("start_selection_10", 1, l_widget.start_selection)
			assert_equals ("end_selection_10", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_10", l_start_text, l_widget.text)
			assert ("replace_has_selection_10", l_widget.has_selection)
			assert_equals ("replace_caret_10", 6, l_widget.caret_position)
			assert_equals ("replace_start_selection_10", 1, l_widget.start_selection)
			assert_equals ("replace_end_selection_10", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (7, 1)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_11", l_end_text, l_widget.text)
			assert ("has_selection_11", l_widget.has_selection)
			assert_equals ("caret_11", 1, l_widget.caret_position)
			assert_equals ("start_selection_11", 1, l_widget.start_selection)
			assert_equals ("end_selection_11", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_11", l_start_text, l_widget.text)
			assert ("replace_has_selection_11", l_widget.has_selection)
			assert_equals ("replace_caret_11", 1, l_widget.caret_position)
			assert_equals ("replace_start_selection_11", 1, l_widget.start_selection)
			assert_equals ("replace_end_selection_11", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (1, 7)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_12", l_end_text, l_widget.text)
			assert ("has_selection_12", l_widget.has_selection)
			assert_equals ("caret_12", 6, l_widget.caret_position)
			assert_equals ("start_selection_12", 1, l_widget.start_selection)
			assert_equals ("end_selection_12", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_12", l_start_text, l_widget.text)
			assert ("replace_has_selection_12", l_widget.has_selection)
			assert_equals ("replace_caret_12", 6, l_widget.caret_position)
			assert_equals ("replace_start_selection_12", 1, l_widget.start_selection)
			assert_equals ("replace_end_selection_12", 6, l_widget.end_selection)
		end

	test_currency_remove_replace_symbol
			-- Test features CURRENCY_VALUE_INPUT_MASK.remove_symbol and CURRENCY_VALUE_INPUT_MASK.replace_symbol
		note
			testing:  "execution/isolated"
		local
			l_mask: CURRENCY_VALUE_INPUT_MASK
			l_widget: EV_TEXT_FIELD
			l_start_text, l_end_text: STRING_32
			l_window: EV_TITLED_WINDOW
		do
			create l_mask.make (4, 9)
			create l_widget
			create l_window
			l_window.set_height (300)
			l_window.set_width (300)
			l_window.extend (l_widget)
			l_window.show
			l_window.raise
			l_widget.show
			l_widget.set_focus
			l_start_text := "$12.34"
			l_end_text := "12.34"
			l_widget.set_text ("")
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_1", "", l_widget.text)
			assert_equals ("caret_1", 1, l_widget.caret_position)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_1", "", l_widget.text)
			assert_equals ("replace_caret_1", 1, l_widget.caret_position)
			l_widget.set_text (l_start_text)
			l_widget.set_caret_position (2)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_2", l_end_text, l_widget.text)
			assert_equals ("caret_2", 1, l_widget.caret_position)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_2", l_start_text, l_widget.text)
			assert_equals ("replace_caret_2", 2, l_widget.caret_position)
			l_widget.set_text (l_start_text)
			l_widget.set_caret_position (4)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_3", l_end_text, l_widget.text)
			assert_equals ("caret_3", 3, l_widget.caret_position)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_3", l_start_text, l_widget.text)
			assert_equals ("replace_caret_3", 4, l_widget.caret_position)
			l_widget.set_text (l_start_text)
			l_widget.set_caret_position (l_start_text.count + 1)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_4", l_end_text, l_widget.text)
			assert_equals ("caret_4", l_widget.text_length + 1, l_widget.caret_position)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_4", l_start_text, l_widget.text)
			assert_equals ("replace_caret_4", l_start_text.count + 1, l_widget.caret_position)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (4, 1)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_5", l_end_text, l_widget.text)
			assert ("has_selection_5", l_widget.has_selection)
			assert_equals ("caret_5", 1, l_widget.caret_position)
			assert_equals ("start_selection_5", 1, l_widget.start_selection)
			assert_equals ("end_selection_5", 3, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_5", l_start_text, l_widget.text)
			assert ("replace_has_selection_5", l_widget.has_selection)
			assert_equals ("replace_caret_5", 2, l_widget.caret_position)
			assert_equals ("replace_start_selection_5", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_5", 4, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (1, 4)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_6", l_end_text, l_widget.text)
			assert ("has_selection_6", l_widget.has_selection)
			assert_equals ("caret_6", 3, l_widget.caret_position)
			assert_equals ("start_selection_6", 1, l_widget.start_selection)
			assert_equals ("end_selection_6", 3, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_6", l_start_text, l_widget.text)
			assert ("replace_has_selection_6", l_widget.has_selection)
			assert_equals ("replace_caret_6", 4, l_widget.caret_position)
			assert_equals ("replace_start_selection_6", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_6", 4, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (6, 2)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_7", l_end_text, l_widget.text)
			assert ("has_selection_7", l_widget.has_selection)
			assert_equals ("caret_7", 1, l_widget.caret_position)
			assert_equals ("start_selection_7", 1, l_widget.start_selection)
			assert_equals ("end_selection_7", 5, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_7", l_start_text, l_widget.text)
			assert ("replace_has_selection_7", l_widget.has_selection)
			assert_equals ("replace_caret_7", 2, l_widget.caret_position)
			assert_equals ("replace_start_selection_7", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_7", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (2, 6)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_8", l_end_text, l_widget.text)
			assert ("has_selection_8", l_widget.has_selection)
			assert_equals ("caret_8", 5, l_widget.caret_position)
			assert_equals ("start_selection_8", 1, l_widget.start_selection)
			assert_equals ("end_selection_8", 5, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_8", l_start_text, l_widget.text)
			assert ("replace_has_selection_8", l_widget.has_selection)
			assert_equals ("replace_caret_8", 6, l_widget.caret_position)
			assert_equals ("replace_start_selection_8", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_8", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (6, 1)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_9", l_end_text, l_widget.text)
			assert ("has_selection_9", l_widget.has_selection)
			assert_equals ("caret_9", 1, l_widget.caret_position)
			assert_equals ("start_selection_9", 1, l_widget.start_selection)
			assert_equals ("end_selection_9", 5, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_9", l_start_text, l_widget.text)
			assert ("replace_has_selection_9", l_widget.has_selection)
			assert_equals ("replace_caret_9", 2, l_widget.caret_position)
			assert_equals ("replace_start_selection_9", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_9", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (1, 6)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_10", l_end_text, l_widget.text)
			assert ("has_selection_10", l_widget.has_selection)
			assert_equals ("caret_10", 5, l_widget.caret_position)
			assert_equals ("start_selection_10", 1, l_widget.start_selection)
			assert_equals ("end_selection_10", 5, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_10", l_start_text, l_widget.text)
			assert ("replace_has_selection_10", l_widget.has_selection)
			assert_equals ("replace_caret_10", 6, l_widget.caret_position)
			assert_equals ("replace_start_selection_10", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_10", 6, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (7, 1)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_11", l_end_text, l_widget.text)
			assert ("has_selection_11", l_widget.has_selection)
			assert_equals ("caret_11", 1, l_widget.caret_position)
			assert_equals ("start_selection_11", 1, l_widget.start_selection)
			assert_equals ("end_selection_11", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_11", l_start_text, l_widget.text)
			assert ("replace_has_selection_11", l_widget.has_selection)
			assert_equals ("replace_caret_11", 2, l_widget.caret_position)
			assert_equals ("replace_start_selection_11", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_11", 7, l_widget.end_selection)
			l_widget.set_text (l_start_text)
			l_widget.set_selection (1, 7)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_12", l_end_text, l_widget.text)
			assert ("has_selection_12", l_widget.has_selection)
			assert_equals ("caret_12", 6, l_widget.caret_position)
			assert_equals ("start_selection_12", 1, l_widget.start_selection)
			assert_equals ("end_selection_12", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_12", l_start_text, l_widget.text)
			assert ("replace_has_selection_12", l_widget.has_selection)
			assert_equals ("replace_caret_12", 7, l_widget.caret_position)
			assert_equals ("replace_start_selection_12", 2, l_widget.start_selection)
			assert_equals ("replace_end_selection_12", 7, l_widget.end_selection)

			l_widget.set_text (l_start_text)
			l_widget.set_selection (6, 7)
			l_mask.remove_symbol (l_widget)
			assert_strings_equal ("text_13", l_end_text, l_widget.text)
			assert ("has_selection_13", l_widget.has_selection)
			assert_equals ("caret_13", 6, l_widget.caret_position)
			assert_equals ("start_selection_13", 5, l_widget.start_selection)
			assert_equals ("end_selection_13", 6, l_widget.end_selection)
			l_mask.replace_symbol (l_widget)
			assert_strings_equal ("replace_text_13", l_start_text, l_widget.text)
			assert ("replace_has_selection_13", l_widget.has_selection)
			assert_equals ("replace_caret_13", 7, l_widget.caret_position)
			assert_equals ("replace_start_selection_13", 6, l_widget.start_selection)
			assert_equals ("replace_end_selection_13", 7, l_widget.end_selection)
		end

feature {NONE} -- Implementation

	keys_tested_in_integer_tests: ARRAYED_LIST [EV_KEY]
			-- Keys to be tested for integer masks
		local
			l_key: EV_KEY
		do
			create Result.make (100)
			create l_key.make_with_code (key_0)
			Result.extend (l_key)
			create l_key.make_with_code (key_numpad_0)
			Result.extend (l_key)
			Result.append (keys_tested_in_numeric_tests)
		end

	keys_tested_in_numeric_tests: ARRAYED_LIST [EV_KEY]
			-- Keys to be tested in `test_numeric_mask'
		local
			l_key: EV_KEY
		once
			create Result.make (100)
			create l_key.make_with_code (Key_tab)
			Result.extend (l_key)
			create l_key.make_with_code (Key_4)
			Result.extend (l_key)
			create l_key.make_with_code (Key_numpad_4)
			Result.extend (l_key)
			create l_key.make_with_code (Key_numpad_add)
			Result.extend (l_key)
			create l_key.make_with_code (Key_numpad_divide)
			Result.extend (l_key)
			create l_key.make_with_code (Key_numpad_multiply)
			Result.extend (l_key)
			create l_key.make_with_code (key_num_lock)
			Result.extend (l_key)
			create l_key.make_with_code (Key_numpad_subtract)
			Result.extend (l_key)
			create l_key.make_with_code (Key_numpad_decimal)
			Result.extend (l_key)
			create l_key.make_with_code (Key_space)
			Result.extend (l_key)
			create l_key.make_with_code (Key_back_space)
			Result.extend (l_key)
			create l_key.make_with_code (Key_enter)
			Result.extend (l_key)
			create l_key.make_with_code (Key_escape)
			Result.extend (l_key)
			create l_key.make_with_code (Key_pause)
			Result.extend (l_key)
			create l_key.make_with_code (Key_caps_lock)
			Result.extend (l_key)
			create l_key.make_with_code (Key_scroll_lock)
			Result.extend (l_key)
			create l_key.make_with_code (Key_comma)
			Result.extend (l_key)
			create l_key.make_with_code (Key_equal)
			Result.extend (l_key)
			create l_key.make_with_code (Key_period)
			Result.extend (l_key)
			create l_key.make_with_code (key_numpad_decimal)
			Result.extend (l_key)
			create l_key.make_with_code (Key_semicolon)
			Result.extend (l_key)
			create l_key.make_with_code (Key_open_bracket)
			Result.extend (l_key)
			create l_key.make_with_code (Key_close_bracket)
			Result.extend (l_key)
			create l_key.make_with_code (Key_slash)
			Result.extend (l_key)
			create l_key.make_with_code (Key_backslash)
			Result.extend (l_key)
			create l_key.make_with_code (Key_quote)
			Result.extend (l_key)
			create l_key.make_with_code (Key_backquote)
			Result.extend (l_key)
			create l_key.make_with_code (Key_dash)
			Result.extend (l_key)
			create l_key.make_with_code (Key_insert)
			Result.extend (l_key)
			create l_key.make_with_code (Key_delete)
			Result.extend (l_key)
			create l_key.make_with_code (Key_a)
			Result.extend (l_key)
			create l_key.make_with_code (Key_b)
			Result.extend (l_key)
			create l_key.make_with_code (Key_c)
			Result.extend (l_key)
			create l_key.make_with_code (Key_d)
			Result.extend (l_key)
			create l_key.make_with_code (Key_e)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f)
			Result.extend (l_key)
			create l_key.make_with_code (Key_g)
			Result.extend (l_key)
			create l_key.make_with_code (Key_h)
			Result.extend (l_key)
			create l_key.make_with_code (Key_i)
			Result.extend (l_key)
			create l_key.make_with_code (Key_j)
			Result.extend (l_key)
			create l_key.make_with_code (Key_k)
			Result.extend (l_key)
			create l_key.make_with_code (Key_l)
			Result.extend (l_key)
			create l_key.make_with_code (Key_m)
			Result.extend (l_key)
			create l_key.make_with_code (Key_n)
			Result.extend (l_key)
			create l_key.make_with_code (Key_o)
			Result.extend (l_key)
			create l_key.make_with_code (Key_p)
			Result.extend (l_key)
			create l_key.make_with_code (Key_q)
			Result.extend (l_key)
			create l_key.make_with_code (Key_r)
			Result.extend (l_key)
			create l_key.make_with_code (Key_s)
			Result.extend (l_key)
			create l_key.make_with_code (Key_t)
			Result.extend (l_key)
			create l_key.make_with_code (Key_u)
			Result.extend (l_key)
			create l_key.make_with_code (Key_v)
			Result.extend (l_key)
			create l_key.make_with_code (Key_w)
			Result.extend (l_key)
			create l_key.make_with_code (Key_x)
			Result.extend (l_key)
			create l_key.make_with_code (Key_y)
			Result.extend (l_key)
			create l_key.make_with_code (Key_z)
			Result.extend (l_key)
			create l_key.make_with_code (Key_shift)
			Result.extend (l_key)
			create l_key.make_with_code (Key_ctrl)
			Result.extend (l_key)
			create l_key.make_with_code (Key_alt)
			Result.extend (l_key)
			create l_key.make_with_code (Key_left_meta)
			Result.extend (l_key)
			create l_key.make_with_code (Key_right_meta)
			Result.extend (l_key)
			create l_key.make_with_code (Key_menu)
			Result.extend (l_key)
			Result.append (function_keys)
			Result.append (navigation_keys)
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

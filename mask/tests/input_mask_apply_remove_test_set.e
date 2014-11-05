note 
	description: "[
		Tests of INPUT_MASK `apply' and `remove'
	]"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"
	testing: "type/manual"

class
	INPUT_MASK_APPLY_REMOVE_TEST_SET

inherit
	EXTENDED_TEST_SET
		redefine
			on_prepare
		end

feature -- Test routines

	test_date_time_mask_date_apply
			-- Test the DATE_TIME_VALUE_INPUT_MASK.
		local
			l_mask: DATE_TIME_VALUE_INPUT_MASK
			l_apply_data: like {TEXT_INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]}.apply
		do
			create l_mask.make_with_date
			l_apply_data := l_mask.apply (create {DATE_TIME}.make (2011, 11, 30, 12, 0, 0))
			assert_strings_equal ("mask applied to 11/30/2011", "11/30/2011", l_apply_data.masked_string)
		end

	test_date_time_mask_date_remove
			-- Test the DATE_TIME_VALUE_INPUT_MASK.
		local
			l_mask: DATE_TIME_VALUE_INPUT_MASK
			l_date_time: DATE_TIME
			l_constraint: DATE_TIME_COLUMN_METADATA
			l_result: TUPLE [value: DATE_TIME; error_message: STRING_32]
		do
			create l_mask.make_with_date
			create l_date_time.make (2011, 11, 30, 0, 0, 0)
			create l_constraint.make_with_scale ("batch", "bat_creation_date", 23, 3)
			l_result := l_mask.remove ("11/30/2011", l_constraint)
			assert_equals ("mask removed from 11/30/2011", l_date_time, l_result.value)
			l_result := l_mask.remove ("11/32/2011", l_constraint)
			assert ("mask removed from 11/32/2011", not l_result.error_message.is_empty)
		end

	test_date_time_mask_time_apply
			-- Test the DATE_TIME_VALUE_INPUT_MASK.
		local
			l_mask: DATE_TIME_VALUE_INPUT_MASK
			l_apply_data: like {TEXT_INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]}.apply
		do
			create l_mask.make_with_time
			l_apply_data := l_mask.apply (create {DATE_TIME}.make (0, 1, 1, 12, 34, 56))
			assert_strings_equal ("mask applied to 12:34:56 PM", "12:34:56 PM", l_apply_data.masked_string)
		end

	test_date_time_mask_time_remove
			-- Test the DATE_TIME_VALUE_INPUT_MASK.
		local
			l_mask: DATE_TIME_VALUE_INPUT_MASK
			l_date_time: DATE_TIME
			l_constraint: DATE_TIME_COLUMN_METADATA
			l_result: TUPLE [value: DATE_TIME; error_message: STRING_32]
		do
			create l_mask.make_with_time
			create l_date_time.make (9999, 12, 31, 12, 34, 56)
			create l_constraint.make_with_scale ("batch", "bat_creation_date", 23, 3)
			l_result := l_mask.remove ("12:34:56 PM", l_constraint)
			assert_equals ("mask removed from 12:34:56 PM", l_date_time, l_result.value)
			l_result := l_mask.remove ("12:61:56 PM", l_constraint)
			assert ("mask removed from 12:61:56 PM", not l_result.error_message.is_empty)
		end

	test_date_time_mask_date_and_time_apply
			-- Test the DATE_TIME_VALUE_INPUT_MASK.
		local
			l_mask: DATE_TIME_VALUE_INPUT_MASK
			l_date_time: DATE_TIME
			l_apply_data: like {TEXT_INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]}.apply
		do
			create l_mask.make_with_date_and_time
			create l_date_time.make (1, 2, 3, 12, 34, 56)
			l_apply_data := l_mask.apply (l_date_time)
			assert_strings_equal ("mask applied to 02/03/0001 12:34:56 PM", "02/03/0001 12:34:56 PM", l_apply_data.masked_string)

			create l_mask.make_with_date_and_time
			create l_date_time.make (1, 2, 3, 0, 12, 34)
			l_apply_data := l_mask.apply (l_date_time)
			assert_strings_equal ("mask applied to 02/03/0001 00:12:34 AM", "02/03/0001 12:12:34 AM", l_apply_data.masked_string)

			create l_mask.make_with_date_and_time
			create l_date_time.make (1, 2, 3, 13, 23, 45)
			l_apply_data := l_mask.apply (l_date_time)
			assert_strings_equal ("mask applied to 02/03/0001 01:23:45 PM", "02/03/0001 01:23:45 PM", l_apply_data.masked_string)
		end

	test_date_time_mask_date_and_time_remove
			-- Test the DATE_TIME_VALUE_INPUT_MASK.
		local
			l_mask: DATE_TIME_VALUE_INPUT_MASK
			l_date_time: DATE_TIME
			l_constraint: DATE_TIME_COLUMN_METADATA
			l_result: TUPLE [value: DATE_TIME; error_message: STRING_32]
		do
			create l_mask.make_with_date_and_time
			create l_date_time.make (1, 2, 3, 12, 34, 56)
			create l_constraint.make_with_scale ("batch", "bat_creation_date", 23, 3)

			l_result := l_mask.remove ("02/03/0001 12:34:56 PM", l_constraint)
			assert_equals ("mask removed from 02/03/0001 12:34:56 PM", l_date_time, l_result.value)
		end

	test_integer_value_input_mask_parsing
			-- Test INTEGER_VALUE_INPUT_MASK parsing
		local
			l_mask: INTEGER_VALUE_INPUT_MASK
		do
			create l_mask.make (5)
			assert ("is_valid_integer_mask", not l_mask.is_invalid)
			assert_equals ("mask_count_five integer mask", 5, l_mask.capacity.as_integer_32)
		end

	test_integer_value_input_mask_remove
			-- Test INTEGER_VALUE_INPUT_MASK remove
		local
			l_mask: INTEGER_VALUE_INPUT_MASK
			l_constraint: INTEGER_COLUMN_METADATA
			l_result: TUPLE [value: INTEGER; error_message: STRING_32]
			l_test_data: READABLE_STRING_GENERAL
		do
			create l_constraint.make ("account_type", "acctyp_id", 6)
			create l_mask.make (6)
			l_test_data := "12,345"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 12345", 12345, l_result.value)
			assert ("test 12345 error empty", l_result.error_message.is_empty)
			l_test_data := "-12,345"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -12345", -12345, l_result.value)
			assert ("test -12345 error empty", l_result.error_message.is_empty)
			l_test_data := "0"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 0", 0, l_result.value)
			assert ("test 0 error empty", l_result.error_message.is_empty)
			l_test_data := "-0"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -0", 0, l_result.value)
			assert ("test -0 error empty", l_result.error_message.is_empty)
			l_test_data := ""
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test empty", 0, l_result.value)
			assert ("test error empty", l_result.error_message.is_empty)
			l_test_data := "1111111"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1111111", 1111111, l_result.value)
			assert_strings_equal ("test 1111111 error message", "The text entered is too long. Characters Entered: 7; Maximum Allowed: 6.", l_result.error_message)
			create l_constraint.make ("account_type", "acctyp_id", {INTEGER}.max_value.out.count)
			create l_mask.make ({INTEGER}.max_value.out.count.as_natural_8)
			l_test_data := {INTEGER}.max_value.out
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test {INTEGER}.max_value.out", {INTEGER}.max_value, l_result.value)
			assert ("test {INTEGER}.max_value.out error empty", l_result.error_message.is_empty)
			l_test_data := {INTEGER}.min_value.out
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test {INTEGER}.min_value.out", {INTEGER}.min_value, l_result.value)
			assert ("test {INTEGER}.min_value.out error empty", l_result.error_message.is_empty)
		end

	test_integer_value_input_mask_apply
			-- Test INTEGER_VALUE_INPUT_MASK apply
		local
			l_mask: INTEGER_VALUE_INPUT_MASK
			l_result: TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_test_data: INTEGER_32
		do
			create l_mask.make (5)
			l_test_data := 12345
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test 12345", "12,345", l_result.masked_string.as_string_8)
			assert ("Test 12345 valid", l_result.error_message.is_empty)
			l_test_data := 2
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test 2", "2", l_result.masked_string.as_string_8)
			assert ("Test valid 2", l_result.error_message.is_empty)
			l_test_data := 0
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test 0", "0", l_result.masked_string.as_string_8)
			assert ("Test valid 0", l_result.error_message.is_empty)
			l_test_data := -12345
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test -12345", "-12,345", l_result.masked_string.as_string_8)
			assert ("Test -12345 valid", l_result.error_message.is_empty)
			l_test_data := -2
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test -2", "-2", l_result.masked_string.as_string_8)
			assert ("Test valid -2", l_result.error_message.is_empty)
			l_test_data := -0
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test -0", "0", l_result.masked_string.as_string_8)
			assert ("Test valid -0", l_result.error_message.is_empty)
			l_test_data := 8888888
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test 8888888", "8,888,888", l_result.masked_string.as_string_8)
--			assert_strings_equal ("Test error message 8888888", "Some Error Message", l_result.error_message)
			--| See ticket 6356
			l_test_data := -8888888
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test -8888888", "-8,888,888", l_result.masked_string.as_string_8)
			create l_mask.make ({INTEGER}.max_value.out.count.as_natural_8)
			l_test_data := {INTEGER}.max_value
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test {INTEGER}.max_value", "2,147,483,647", l_result.masked_string.as_string_8)
			assert ("Test valid {INTEGER}.max_value", l_result.error_message.is_empty)
--			l_test_data := {INTEGER}.min_value
--			l_result := l_mask.apply (l_test_data)
--			assert_equals ("test {INTEGER}.min_value", "-2,147,483,648", l_result.masked_string.as_string_8)
--			assert ("Test valid {INTEGER}.min_value", l_result.error_message.is_empty)
			--| See Eiffel Software Ticket 18841
		end

	test_decimal_value_input_mask_apply
			-- Test DECIMAL_VALUE_INPUT_MASK apply
		local
			l_mask: DECIMAL_VALUE_INPUT_MASK
			l_result: TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_test_data: DECIMAL
		do
			create l_mask.make (3, 10)
			--| not is_nan_valid
			l_test_data := "12.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.345", "12.345", l_result.masked_string)
			assert ("Test 1 valid", l_result.error_message.is_empty)
			l_test_data := "12.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.34", "12.340", l_result.masked_string)
			assert ("Test 2 valid", l_result.error_message.is_empty)
			l_test_data := 2000
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 2000", "2,000.000", l_result.masked_string)
			assert ("Test 3 valid", l_result.error_message.is_empty)
			l_test_data := "12.3453"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3453", "12.345", l_result.masked_string)
			assert ("Test 4 valid", l_result.error_message.is_empty)
			l_test_data := "12.3456"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3456", "12.346", l_result.masked_string)
			assert ("Test 5 valid", l_result.error_message.is_empty)
			l_test_data := "12.3455"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3455", "12.346", l_result.masked_string)
			assert ("Test 6 valid", l_result.error_message.is_empty)
			l_test_data := "12.3445"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3445", "12.345", l_result.masked_string)
			assert ("Test 7 valid", l_result.error_message.is_empty)
			l_test_data := "4312.3445"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3445", "4,312.345", l_result.masked_string)
			assert ("Test 7 valid", l_result.error_message.is_empty)
			l_test_data := "-12.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.345", "-12.345", l_result.masked_string)
			assert ("Test 8 valid", l_result.error_message.is_empty)
			l_test_data := "-12.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.34", "-12.340", l_result.masked_string)
			assert ("Test 9 valid", l_result.error_message.is_empty)
			l_test_data := "0.000"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 0.000", "0.000", l_result.masked_string)
			assert ("Test 0.000", l_result.error_message.is_empty)
			l_test_data := -2000
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -2000", "-2,000.000", l_result.masked_string)
			assert ("Test 10 valid", l_result.error_message.is_empty)
			l_test_data := "-12.3453"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3453", "-12.345", l_result.masked_string)
			assert ("Test 11 valid", l_result.error_message.is_empty)
			l_test_data := "-12.3456"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3456", "-12.346", l_result.masked_string)
			assert ("Test 12 valid", l_result.error_message.is_empty)
			l_test_data := "-12.3455"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3455", "-12.346", l_result.masked_string)
			assert ("Test 13 valid", l_result.error_message.is_empty)
			l_test_data := "-12.3445"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3445", "-12.345", l_result.masked_string)
			assert ("Test 14 valid", l_result.error_message.is_empty)
			l_test_data := "-4312.3445"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3445", "-4,312.345", l_result.masked_string)
			assert ("Test 15 valid", l_result.error_message.is_empty)
			l_test_data := "-0.000"
			assert ("l_test_data_negative", l_test_data.is_negative)
			assert_strings_equal ("round", "-0.000", l_test_data.to_scientific_string)
			assert ("Test 15 -0.000 valid", l_result.error_message.is_empty)
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test -0.000", "-0.000", l_result.masked_string)
			assert ("Test -0.000", l_result.error_message.is_empty)
			l_test_data := l_test_data.nan
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test nan", "0.000", l_result.masked_string)
			assert ("Test nan valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test infinity", "0.000", l_result.masked_string)
			assert ("Test infinity valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.negative_infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test negative_infinity", "-0.000", l_result.masked_string)
			assert ("Test negative_infinity valid", l_result.error_message.is_empty)
			--| is_nan_valid
			l_mask.set_is_nan_valid (True)
			l_test_data := "12.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.345 is_nan_valid", "12.345", l_result.masked_string)
			assert ("Test 1 validis_nan_valid", l_result.error_message.is_empty)
			l_test_data := "12.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.34 is_nan_valid", "12.340", l_result.masked_string)
			assert ("Test 2 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := 2000
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 2000 is_nan_valid", "2,000.000", l_result.masked_string)
			assert ("Test 3 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "12.3453"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3453 is_nan_valid", "12.345", l_result.masked_string)
			assert ("Test 4 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "12.3456"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3456 is_nan_valid", "12.346", l_result.masked_string)
			assert ("Test 5 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "12.3455"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3455 is_nan_valid", "12.346", l_result.masked_string)
			assert ("Test 6 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "12.3445"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3445 is_nan_valid", "12.345", l_result.masked_string)
			assert ("Test 7 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "4312.3445"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.3445 is_nan_valid", "4,312.345", l_result.masked_string)
			assert ("Test 7 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.345 is_nan_valid", "-12.345", l_result.masked_string)
			assert ("Test 8 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.34 is_nan_valid", "-12.340", l_result.masked_string)
			assert ("Test 9 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "0.000"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 0.000 is_nan_valid", "0.000", l_result.masked_string)
			assert ("Test 0.000 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := -2000
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -2000 is_nan_valid", "-2,000.000", l_result.masked_string)
			assert ("Test 10 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.3453"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3453 is_nan_valid", "-12.345", l_result.masked_string)
			assert ("Test 11 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.3456"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3456 is_nan_valid", "-12.346", l_result.masked_string)
			assert ("Test 12 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.3455"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3455 is_nan_valid", "-12.346", l_result.masked_string)
			assert ("Test 13 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.3445"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3445 is_nan_valid", "-12.345", l_result.masked_string)
			assert ("Test 14 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-4312.3445"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.3445 is_nan_valid", "-4,312.345", l_result.masked_string)
			assert ("Test 15 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-0.000"
			assert ("l_test_data_negative is_nan_valid", l_test_data.is_negative)
			assert ("Test 15 -0.000 valid is_nan_valid", l_result.error_message.is_empty)
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test -0.000 is_nan_valid", "-0.000", l_result.masked_string)
			assert ("Test -0.000 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.nan
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test nan is_nan_valid", "", l_result.masked_string)
			assert ("Test nan valid  is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test infinity is_nan_valid", "", l_result.masked_string)
			assert ("Test infinity valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.negative_infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test negative_infinity is_nan_valid", "", l_result.masked_string)
			assert ("Test negative_infinity valid is_nan_valid", l_result.error_message.is_empty)
		end

	test_decimal_value_input_mask_remove
			-- Test DECIMAL_VALUE_INPUT_MASK.remove
		local
			l_mask: DECIMAL_VALUE_INPUT_MASK
			l_constraint: DECIMAL_COLUMN_METADATA
			l_result: TUPLE [value: DECIMAL; error_message: STRING_32]
			l_test_data: READABLE_STRING_GENERAL
		do
			create l_constraint.make_with_scale ("companies", "cmp_min_delivery_amt", 19, 4)
			create l_mask.make (3, 7)
			--| not is_nan_valid
			l_test_data := "12.345"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 12.345", create {DECIMAL}.make_from_string ("12.345"), l_result.value)
			assert ("test 1 12.345 error empty", l_result.error_message.is_empty)
			l_test_data := "12.3456"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 12.3456", create {DECIMAL}.make_from_string ("12.3456"), l_result.value)
			assert ("test 1 12.3456 error included", not l_result.error_message.is_empty)
			l_test_data := "4,312.3456"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 12.3456", create {DECIMAL}.make_from_string ("4312.3456"), l_result.value)
			assert ("test 1 12.3456 error included", not l_result.error_message.is_empty)
			l_test_data := "0.000"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 0.000", create {DECIMAL}.make_from_string ("0.000"), l_result.value)
			assert ("test 1 0.000", l_result.error_message.is_empty)
			l_test_data := "-12.345"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -12.345", create {DECIMAL}.make_from_string ("-12.345"), l_result.value)
			assert ("test -12.345 error empty", l_result.error_message.is_empty)
			l_test_data := "-12.3456"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -12.3456", create {DECIMAL}.make_from_string ("-12.3456"), l_result.value)
			assert ("test -12.3456 error included", not l_result.error_message.is_empty)
			l_test_data := "-4,312.3456"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -4,312.3456", create {DECIMAL}.make_from_string ("-4312.3456"), l_result.value)
			l_test_data := "-0.000"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -0.000", create {DECIMAL}.make_from_string ("-0.000"), l_result.value)
			assert ("test 1 -0.000", l_result.error_message.is_empty)
			l_test_data := ""
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert ("empty_string_unmasks_as_zero", l_result.value.is_zero)
			assert_equals ("empty_string_unmaks_invalid", {MASKING_MESSAGES}.decimal_field_nan_invalid_sentence.to_string_32, l_result.error_message)
			--| is_nan_valid
			l_mask.set_is_nan_valid (True)
			l_test_data := "12.345"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 12.345 is_nan_valid", create {DECIMAL}.make_from_string ("12.345"), l_result.value)
			assert ("test 1 12.345 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "12.3456"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 12.3456 is_nan_valid", create {DECIMAL}.make_from_string ("12.3456"), l_result.value)
			assert ("test 1 12.3456 error included is_nan_valid", not l_result.error_message.is_empty)
			l_test_data := "4,312.3456"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 12.3456 is_nan_valid", create {DECIMAL}.make_from_string ("4312.3456"), l_result.value)
			assert ("test 1 12.3456 error included is_nan_valid", not l_result.error_message.is_empty)
			l_test_data := "0.000"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 0.000 is_nan_valid", create {DECIMAL}.make_from_string ("0.000"), l_result.value)
			assert ("test 1 0.000 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.345"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -12.345 is_nan_valid", create {DECIMAL}.make_from_string ("-12.345"), l_result.value)
			assert ("test -12.345 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.3456"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -12.3456 is_nan_valid", create {DECIMAL}.make_from_string ("-12.3456"), l_result.value)
			assert ("test -12.3456 error included is_nan_valid", not l_result.error_message.is_empty)
			l_test_data := "-4,312.3456"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -4,312.3456 is_nan_valid", create {DECIMAL}.make_from_string ("-4312.3456"), l_result.value)
			l_test_data := "-0.000"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -0.000 is_nan_valid", create {DECIMAL}.make_from_string ("-0.000"), l_result.value)
			assert ("test 1 -0.000", l_result.error_message.is_empty)
			l_test_data := ""
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert ("empty_string_unmasks_as_nan", l_result.value.is_nan)
			assert ("empty_string_unmaks_valid", l_result.error_message.is_empty)
		end

	test_currency_value_input_mask_parsing
			-- Test CURRENCY_VALUE_INPUT_MASK
		do
			assert ("is_valid_currency_mask", not (create {CURRENCY_VALUE_INPUT_MASK}.make_currency (5)).is_invalid)
		end

	test_currency_value_input_mask_remove
			-- Test CURRENCY_VALUE_INPUT_MASK remove
		local
			l_mask: CURRENCY_VALUE_INPUT_MASK
			l_constraint: DECIMAL_COLUMN_METADATA
			l_result: TUPLE [value: DECIMAL; error_message: STRING_32]
			l_test_data: READABLE_STRING_GENERAL
		do
			create l_constraint.make_with_scale ("companies", "cmp_min_delivery_amt", 19, 4)

			create l_mask.make_currency (9)
			--| not is_nan_valid
			l_test_data := "$0.00"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 0.00", create {DECIMAL}.make_from_string ("0.00"), l_result.value)
			assert ("test 1 0.00 error empty", l_result.error_message.is_empty)
			l_test_data := "$12.34"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 12.34", create {DECIMAL}.make_from_string ("12.34"), l_result.value)
			assert ("test 1 12.345 error empty", l_result.error_message.is_empty)
			l_test_data := "$4,312.34"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 4,312.34", create {DECIMAL}.make_from_string ("4312.34"), l_result.value)
			assert ("test 1 12.345 error empty", l_result.error_message.is_empty)
			l_test_data := "$-0.00"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 -0.00", create {DECIMAL}.make_from_string ("-0.00"), l_result.value)
			assert ("test 1 -0.00 error empty", l_result.error_message.is_empty)
			l_test_data := "$-12.34"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 -12.34", create {DECIMAL}.make_from_string ("-12.34"), l_result.value)
			assert ("test 1 -12.345 error empty", l_result.error_message.is_empty)
			l_test_data := "$-4,312.34"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 4,312.34", create {DECIMAL}.make_from_string ("-4312.34"), l_result.value)
			assert ("test $-4,312.34 error empty", l_result.error_message.is_empty)
			l_test_data := ""
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert ("empty_string_unmasks_as_zero", l_result.value.is_zero)
			assert_equals ("empty_string_unmaks_invalid", {MASKING_MESSAGES}.decimal_field_nan_invalid_sentence.to_string_32, l_result.error_message)
			--| is_nan_valid
			l_mask.set_is_nan_valid (True)
			l_test_data := "$0.00"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 0.00 is_nan_valid", create {DECIMAL}.make_from_string ("0.00"), l_result.value)
			assert ("test 1 0.00 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "$12.34"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 12.34 is_nan_valid", create {DECIMAL}.make_from_string ("12.34"), l_result.value)
			assert ("test 1 12.345 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "$4,312.34"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 4,312.34 is_nan_valid", create {DECIMAL}.make_from_string ("4312.34"), l_result.value)
			assert ("test 1 12.345 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "$-0.00"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 -0.00 is_nan_valid", create {DECIMAL}.make_from_string ("-0.00"), l_result.value)
			assert ("test 1 -0.00 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "$-12.34"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 -12.34 is_nan_valid", create {DECIMAL}.make_from_string ("-12.34"), l_result.value)
			assert ("test 1 -12.345 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "$-4,312.34"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 4,312.34 is_nan_valid", create {DECIMAL}.make_from_string ("-4312.34"), l_result.value)
			assert ("test $-4,312.34 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := ""
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert ("empty_string_unmasks_as_nan", l_result.value.is_nan)
			assert_strings_equal ("empty_string_unmaks_invalid", "", l_result.error_message)
		end

	test_currency_value_input_mask_apply
			-- Test CURRENCY_VALUE_INPUT_MASK apply
		local
			l_mask: CURRENCY_VALUE_INPUT_MASK
			l_result: TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_test_data: DECIMAL
		do
			--| not is_nan_valid
			create l_mask.make_currency (10)
			l_test_data := "12.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.345", "$12.35", l_result.masked_string)
			assert ("Test 1 valid", l_result.error_message.is_empty)
			l_test_data := "4312.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 4,312.345", "$4,312.35", l_result.masked_string)
			assert ("Test 1 valid", l_result.error_message.is_empty)
			create l_mask.make_currency (10)
			l_test_data := "-12.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.345", "$-12.35", l_result.masked_string)
			assert ("Test 1 valid", l_result.error_message.is_empty)
			l_test_data := "-4312.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 4,312.345", "$-4,312.35", l_result.masked_string)
			assert ("Test 1 valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.nan
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test nan", "$0.00", l_result.masked_string)
			-- assert ("Test valid nan", not l_result.error_message.is_empty)
			l_test_data := l_test_data.infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test infinity", "$0.00", l_result.masked_string)
			-- assert ("Test 1 valid infinity", not l_result.error_message.is_empty)
			l_test_data := l_test_data.negative_infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test negative_infinity", "$-0.00", l_result.masked_string)
			-- assert ("Test 1 valid negative_infinity", not l_result.error_message.is_empty)
			--| is_nan_valid
			create l_mask.make_currency (10)
			l_mask.set_is_nan_valid (True)
			l_test_data := "12.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 12.345 is_nan_valid", "$12.35", l_result.masked_string)
			assert ("Test 1 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "4312.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 4,312.345 is_nan_valid", "$4,312.35", l_result.masked_string)
			assert ("Test 1 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 -12.345 is_nan_valid", "$-12.35", l_result.masked_string)
			assert ("Test 1 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-4312.345"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 1 4,312.345 is_nan_valid", "$-4,312.35", l_result.masked_string)
			assert ("Test 1 valid is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.nan
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test nan is_nan_valid", "", l_result.masked_string)
			assert ("Test valid nan is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test infinity is_nan_valid", "", l_result.masked_string)
			assert ("Test 1 valid infinity is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.negative_infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test negative_infinity is_nan_valid", "", l_result.masked_string)
			assert ("Test 1 valid negative_infinity is_nan_valid", l_result.error_message.is_empty)
		end

	test_percent_value_input_mask_apply
			-- Test PERCENT_VALUE_INPUT_MASK apply
		local
			l_mask: PERCENT_VALUE_INPUT_MASK
			l_result: TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_test_data: DECIMAL
		do
			--| not is_nan_valid
			create l_mask.make (2, 6)
			l_test_data := "12.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 12.34", "12.34%%", l_result.masked_string)
			assert ("valid_1", l_result.error_message.is_empty)
			l_test_data := "8812.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 8812.34", "8,812.34%%", l_result.masked_string)
			assert ("valid_2", l_result.error_message.is_empty)
			l_test_data := "-12.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test -12.34", "-12.34%%", l_result.masked_string)
			assert ("valid_3", l_result.error_message.is_empty)
			l_test_data := "-8812.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test -8812.34", "-8,812.34%%", l_result.masked_string)
			assert ("valid_4", l_result.error_message.is_empty)
			l_test_data := "0.00"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 0.00", "0.00%%", l_result.masked_string)
			assert ("valid_5", l_result.error_message.is_empty)
			l_test_data := "-0.00"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test -0.00", "-0.00%%", l_result.masked_string)
			assert ("valid_6", l_result.error_message.is_empty)
			l_test_data := l_test_data.nan
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test nan", "0.00%%", l_result.masked_string)
			-- assert ("valid_7", not l_result.error_message.is_empty)
			l_test_data := l_test_data.infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test infinity", "0.00%%", l_result.masked_string)
			-- assert ("valid_8", not l_result.error_message.is_empty)
			l_test_data := l_test_data.negative_infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test negative_infinity", "-0.00%%", l_result.masked_string)
			-- assert ("valid_9", not l_result.error_message.is_empty)
			--| is_nan_valid
			create l_mask.make (2, 6)
			l_mask.set_is_nan_valid (True)
			l_test_data := "12.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 12.34 is_nan_valid", "12.34%%", l_result.masked_string)
			assert ("valid_1 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "8812.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 8812.34 is_nan_valid", "8,812.34%%", l_result.masked_string)
			assert ("valid_2 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test -12.34 is_nan_valid", "-12.34%%", l_result.masked_string)
			assert ("valid_3 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-8812.34"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test -8812.34 is_nan_valid", "-8,812.34%%", l_result.masked_string)
			assert ("valid_4 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "0.00"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test 0.00 is_nan_valid", "0.00%%", l_result.masked_string)
			assert ("valid_5 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-0.00"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test -0.00 is_nan_valid", "-0.00%%", l_result.masked_string)
			assert ("valid_6 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.nan
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test nan is_nan_valid", "", l_result.masked_string)
			assert ("valid_7 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test infinity is_nan_valid", "", l_result.masked_string)
			assert ("valid_8 is_nan_valid", l_result.error_message.is_empty)
			l_test_data := l_test_data.negative_infinity
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("test negative_infinity is_nan_valid", "", l_result.masked_string)
			assert ("valid_9 is_nan_valid", l_result.error_message.is_empty)


		end

	test_percent_value_input_mask_remove
			-- Test DECIMAL_VALUE_INPUT_MASK.remove
		local
			l_mask: PERCENT_VALUE_INPUT_MASK
			l_constraint: DECIMAL_COLUMN_METADATA
			l_result: TUPLE [value: DECIMAL; error_message: STRING_32]
			l_test_data: READABLE_STRING_GENERAL
		do
			create l_constraint.make_with_scale ("companies", "cmp_min_delivery_amt", 19, 4)
			create l_mask.make (3, 10)
			--| not is_nan_valid
			l_test_data := "12.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 12.345", create {DECIMAL}.make_from_string ("12.345"), l_result.value)
			assert ("test 1 12.345 error empty", l_result.error_message.is_empty)
			l_test_data := "122.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 122.345", create {DECIMAL}.make_from_string ("122.345"), l_result.value)
			assert ("test 1 122.345 error included", l_result.error_message.is_empty)
			l_test_data := "4,122.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 4,122.345", create {DECIMAL}.make_from_string ("4122.345"), l_result.value)
			assert ("test 1 4,122.345 error included", l_result.error_message.is_empty)
			l_test_data := "-12.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -12.345", create {DECIMAL}.make_from_string ("-12.345"), l_result.value)
			assert ("test -12.345 error empty", l_result.error_message.is_empty)
			l_test_data := "-122.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -122.345", create {DECIMAL}.make_from_string ("-122.345"), l_result.value)
			assert ("test 1 122.345 error included", l_result.error_message.is_empty)
			l_test_data := "-4,122.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -4,122.345", create {DECIMAL}.make_from_string ("-4122.345"), l_result.value)
			assert ("test 1 4,122.345 error included", l_result.error_message.is_empty)
			l_test_data := ""
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert ("empty_string_unmasks_as_zero", l_result.value.is_zero)
			assert_equals ("empty_string_unmaks_invalid", {MASKING_MESSAGES}.decimal_field_nan_invalid_sentence.to_string_32, l_result.error_message)
			--| not is_nan_valid
			l_mask.set_is_nan_valid (True)
			l_test_data := "12.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 12.345 is_nan_valid", create {DECIMAL}.make_from_string ("12.345"), l_result.value)
			assert ("test 1 12.345 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "122.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 122.345 is_nan_valid", create {DECIMAL}.make_from_string ("122.345"), l_result.value)
			assert ("test 1 122.345 error included is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "4,122.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 4,122.345", create {DECIMAL}.make_from_string ("4122.345"), l_result.value)
			assert ("test 1 4,122.345 error included is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-12.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -12.345", create {DECIMAL}.make_from_string ("-12.345"), l_result.value)
			assert ("test -12.345 error empty is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-122.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -122.345", create {DECIMAL}.make_from_string ("-122.345"), l_result.value)
			assert ("test 1 122.345 error included is_nan_valid", l_result.error_message.is_empty)
			l_test_data := "-4,122.345%%"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test -4,122.345", create {DECIMAL}.make_from_string ("-4122.345"), l_result.value)
			assert ("test 1 4,122.345 error included is_nan_valid", l_result.error_message.is_empty)
			l_test_data := ""
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert ("empty_string_unmasks_as_nan is_nan_valid", l_result.value.is_nan)
			assert ("empty_string_unmaks_valid is_nan_valid", l_result.error_message.is_empty)
		end

	test_date_time_value_input_mask_parsing
			-- Test DATE_TIME_VALUE_INPUT_MASK
		local
			l_mask: DATE_TIME_VALUE_INPUT_MASK
		do
			create l_mask.make_with_date
			assert ("is_valid_date_mask", not l_mask.is_invalid)
			assert ("not is_repeating_specification date time mask", not l_mask.is_repeating_specification)
			assert_equals ("mask_count_nineteen date time mask", 10, l_mask.mask.count)
			assert_equals ("mask_open_count fourteen date time mask", {NATURAL} 8, l_mask.open_item_count)
			create l_mask.make_with_time
			assert ("is_valid_time_mask", not l_mask.is_invalid)
			assert ("not is_repeating_specification date time mask", not l_mask.is_repeating_specification)
			assert_equals ("mask_count_nineteen date time mask", 11, l_mask.mask.count)
			assert_equals ("mask_open_count fourteen date time mask", {NATURAL} 8, l_mask.open_item_count)
			create l_mask.make_with_date_and_time
			assert ("is_valid_date_and_time_mask", not l_mask.is_invalid)
			assert ("not is_repeating_specification date time mask", not l_mask.is_repeating_specification)
			assert_equals ("mask_count_nineteen date time mask", 22, l_mask.mask.count)
			assert_equals ("mask_open_count fourteen date time mask", {NATURAL} 16, l_mask.open_item_count)
		end

	test_string_value_input_mask_parsing
			-- Test STRING_VALUE_INPUT_MASK
		local
			l_mask: STRING_VALUE_INPUT_MASK
		do
			--| Test Invalid Scope Character
			create l_mask.make ("$-")
			assert ("is_invalid_scope_character $-", l_mask.is_invalid)
			--| Test one of the reserved characters
			create l_mask.make_repeating ("Z")
			assert ("is_reserved_character Z", l_mask.is_invalid)
			create l_mask.make ("!!z")
			assert ("is_reserved_character z", l_mask.is_invalid)
			--|
			--| Repeating Masks
			--|
			--| Mask "-"
			create l_mask.make_repeating ("-")
			assert ("is_invalid_mask -", l_mask.is_invalid)
			assert ("is_repeating_specification -", l_mask.is_repeating_specification)
			assert_equals ("mask_count_one -", 1, l_mask.mask.count)
			check
				attached_literal_item_1: attached {LITERAL_MASK_ITEM} l_mask.mask [1] as al_literal
			then
				assert_equals ("literal_1 -", '-', al_literal.item)
			end
			--| Mask "--"
			create l_mask.make_repeating ("--")
			assert ("is_invalid_mask --", l_mask.is_invalid)
			--| Mask "\!"
			create l_mask.make_repeating ("\!")
			assert ("is_valid_mask \!", l_mask.is_invalid)
			assert_equals ("mask_count_one \!", 1, l_mask.mask.count)
			assert ("is_repeating_specification \!", l_mask.is_repeating_specification)
			check
				attached_literal_item_2: attached {LITERAL_MASK_ITEM} l_mask.mask [1] as al_literal
			then
				assert_equals ("literal_1 |\!", '!', al_literal.item)
			end
			--| Mask "\-\-"
			create l_mask.make_repeating ("\-\-")
			assert ("is_invalid_mask \-\-", l_mask.is_invalid)
			--| Mask "!!"
			create l_mask.make_repeating ("!!")
			assert ("is_invalid_mask !!", l_mask.is_invalid)
			--| Mask "!"
			create l_mask.make_repeating ("!")
			assert ("is_valid_mask !", not l_mask.is_invalid)
			assert_equals ("mask_count_one !", 1, l_mask.mask.count)
			assert ("is_repeating_specification !", l_mask.is_repeating_specification)
			assert_equals ("index @ 0 !", 0, l_mask.mask [1].index)
			assert_equals ("left_open_index @ 0 !", 0, l_mask.mask [1].left_open_index)
			assert_equals ("right_open_index @ 0 !", 0, l_mask.mask [1].right_open_index)
			assert ("attached_force_upper_item_2 !", attached {FORCE_UPPER_CASE_MASK_ITEM} l_mask.mask [1])
			assert ("new_line_is_valid_character_1", l_mask.mask [1].is_valid_character ('%N'))
			--| Mask "9"
			create l_mask.make_repeating ("9")
			assert ("is_valid_mask 9", not l_mask.is_invalid)
			assert_equals ("mask_count_one 9", 1, l_mask.mask.count)
			assert ("is_repeating_specification 9", l_mask.is_repeating_specification)
			assert_equals ("index @ 0 9", 0, l_mask.mask [1].index)
			assert_equals ("left_open_index @ 0 9", 0, l_mask.mask [1].left_open_index)
			assert_equals ("right_open_index @ 0 9", 0, l_mask.mask [1].right_open_index)
			assert ("attached_digits_only_item_1", attached {NUMERIC_MASK_ITEM} l_mask.mask [1])
			--| Mask "X"
			create l_mask.make_repeating ("X")
			assert ("is_valid_mask X", not l_mask.is_invalid)
			assert_equals ("mask_count_one X", 1, l_mask.mask.count)
			assert ("is_repeating_specification X", l_mask.is_repeating_specification)
			assert_equals ("index @ 0 X", 0, l_mask.mask [1].index)
			assert_equals ("left_open_index @ 0 X", 0, l_mask.mask [1].left_open_index)
			assert_equals ("right_open_index @ 0 X", 0, l_mask.mask [1].right_open_index)
			assert ("attached_digits_only_item_1", attached {WILDCARD_MASK_ITEM} l_mask.mask [1])
			assert ("new_line_is_valid_character_2", l_mask.mask [1].is_valid_character ('%N'))
			--|
			--| Character Mask
			--|
			--| Mask "-"
			create l_mask.make ("-")
			assert ("is_valid_mask -", l_mask.is_invalid)
			assert ("not_repeating_specification -", not l_mask.is_repeating_specification)
			assert_equals ("mask_count_one -", 1, l_mask.mask.count)
			check
				attached_literal_item_3: attached {LITERAL_MASK_ITEM} l_mask.mask [1] as al_literal
			then
				assert_equals ("literal_1 -", '-', al_literal.item)
			end
			--| Mask "--"
			create l_mask.make ("--")
			assert ("is_valid_mask --", l_mask.is_invalid)
			assert ("not_repeating_specification --", not l_mask.is_repeating_specification)
			assert_equals ("mask_count_two --", 2, l_mask.mask.count)
			check
				attached_literal_item_4: attached {LITERAL_MASK_ITEM} l_mask.mask [1] as al_literal
			then
				assert_equals ("literal_1 --", '-', al_literal.item)
			end
			check
				attached_literal_item_5: attached {LITERAL_MASK_ITEM} l_mask.mask [2] as al_literal
			then
				assert_equals ("literal_2 --", '-', al_literal.item)
			end
			--| Mask "\!"
			create l_mask.make ("\!")
			assert ("is_valid_mask \!", l_mask.is_invalid)
			assert ("not_repeating_specification \!", not l_mask.is_repeating_specification)
			assert_equals ("mask_count_one \!", 1, l_mask.mask.count)
			check
				attached_literal_item_3: attached {LITERAL_MASK_ITEM} l_mask.mask [1] as al_literal
			then
				assert_equals ("literal_1 \!", '!', al_literal.item)
			end
			--| Mask "\!\!"
			create l_mask.make ("\!\!")
			assert ("is_valid_mask \!\!", l_mask.is_invalid)
			assert ("not_repeating_specification \!\!", not l_mask.is_repeating_specification)
			assert_equals ("mask_count_two \!\!", 2, l_mask.mask.count)
			check
				attached_literal_item_4: attached {LITERAL_MASK_ITEM} l_mask.mask [1] as al_literal
			then
				assert_equals ("literal_1 \!\!", '!', al_literal.item)
			end
			check
				attached_literal_item_5: attached {LITERAL_MASK_ITEM} l_mask.mask [2] as al_literal
			then
				assert_equals ("literal_2 \!\!", '!', al_literal.item)
			end
			--| Mask "!-!-"
			create l_mask.make ("!-!-")
			assert ("is_valid_mask !-!-", not l_mask.is_invalid)
			assert ("not_repeating_specification !-!-", not l_mask.is_repeating_specification)
			assert_equals ("mask_count !-!-", 4, l_mask.mask.count)
			assert_equals ("mask_open_item_count !-!-", {NATURAL_32} 2, l_mask.open_item_count)
			--| No assertions for the literals; tested previously
			assert ("item_1_is_force_upper", attached {FORCE_UPPER_CASE_MASK_ITEM} l_mask.mask [1])
			assert ("item_3_is_force_upper", attached {FORCE_UPPER_CASE_MASK_ITEM} l_mask.mask [3])
			assert ("item_1_is_open !-!-", l_mask.mask [1].is_open)
			assert ("item_2_is_not_open !-!-", not l_mask.mask [2].is_open)
			assert ("item_3_is_open !-!-", l_mask.mask [3].is_open)
			assert ("item_4_is_not_open !-!-", not l_mask.mask [4].is_open)
			assert_equals ("index @ 1 !-!-", 1, l_mask.mask [1].index)
			assert_equals ("left_open_index @ 1 !-!-", 0, l_mask.mask [1].left_open_index)
			assert_equals ("right_open_index @ 1 !-!-", 3, l_mask.mask [1].right_open_index)
			assert_equals ("index @ 2 !-!-", 2, l_mask.mask [2].index)
			assert_equals ("left_open_index @ 2 !-!-", 1, l_mask.mask [2].left_open_index)
			assert_equals ("right_open_index @ 2 !-!-", 3, l_mask.mask [2].right_open_index)
			assert_equals ("index @ 3 !-!-", 3, l_mask.mask [3].index)
			assert_equals ("left_open_index @ 3 !-!-", 1, l_mask.mask [3].left_open_index)
			assert_equals ("right_open_index @ 3 !-!-", 0, l_mask.mask [3].right_open_index)
			assert_equals ("index @ 4 !-!-", 4, l_mask.mask [4].index)
			assert_equals ("left_open_index @ 4 !-!-", 3, l_mask.mask [4].left_open_index)
			assert_equals ("right_open_index @ 4 !-!-", 0, l_mask.mask [4].right_open_index)
			assert_equals ("left_closed_index @ 1 !-!-", 0, l_mask.mask [1].left_closed_index)
			assert_equals ("right_closed_index @ 1 !-!-", 2, l_mask.mask [1].right_closed_index)
			assert_equals ("left_closed_index @ 2 !-!-", 0, l_mask.mask [2].left_closed_index)
			assert_equals ("right_closed_index @ 2 !-!-", 4, l_mask.mask [2].right_closed_index)
			assert_equals ("left_closed_index @ 3 !-!-", 2, l_mask.mask [3].left_closed_index)
			assert_equals ("right_closed_index @ 3 !-!-", 4, l_mask.mask [3].right_closed_index)
			assert_equals ("left_closed_index @ 4 !-!-", 2, l_mask.mask [4].left_closed_index)
			assert_equals ("right_closed_index @ 4 !-!-", 0, l_mask.mask [4].right_closed_index)
			--| Mask "9-9-"
			create l_mask.make ("9-9-")
			assert ("is_valid_mask 9-9-", not l_mask.is_invalid)
			assert ("not_repeating_specification 9-9-", not l_mask.is_repeating_specification)
			assert_equals ("mask_count 9-9-", 4, l_mask.mask.count)
			assert_equals ("mask_open_item_count 9-9-", {NATURAL_32} 2, l_mask.open_item_count)
			--| No assertions for the literals; tested previously
			assert ("item_1_is_force_upper", attached {NUMERIC_MASK_ITEM} l_mask.mask [1])
			assert ("item_3_is_force_upper", attached {NUMERIC_MASK_ITEM} l_mask.mask [3])
			assert ("item_1_is_open 9-9-", l_mask.mask [1].is_open)
			assert ("item_2_is_not_open 9-9-", not l_mask.mask [2].is_open)
			assert ("item_3_is_open 9-9-", l_mask.mask [3].is_open)
			assert ("item_4_is_not_open 9-9-", not l_mask.mask [4].is_open)
			assert_equals ("index @ 1 9-9-", 1, l_mask.mask [1].index)
			assert_equals ("left_open_index @ 1 9-9-", 0, l_mask.mask [1].left_open_index)
			assert_equals ("right_open_index @ 1 9-9-", 3, l_mask.mask [1].right_open_index)
			assert_equals ("index @ 2 9-9-", 2, l_mask.mask [2].index)
			assert_equals ("left_open_index @ 2 9-9-", 1, l_mask.mask [2].left_open_index)
			assert_equals ("right_open_index @ 2 9-9-", 3, l_mask.mask [2].right_open_index)
			assert_equals ("index @ 3 9-9-", 3, l_mask.mask [3].index)
			assert_equals ("left_open_index @ 3 9-9-", 1, l_mask.mask [3].left_open_index)
			assert_equals ("right_open_index @ 3 9-9-", 0, l_mask.mask [3].right_open_index)
			assert_equals ("index @ 4 9-9-", 4, l_mask.mask [4].index)
			assert_equals ("left_open_index @ 4 9-9-", 3, l_mask.mask [4].left_open_index)
			assert_equals ("right_open_index @ 4 9-9-", 0, l_mask.mask [4].right_open_index)
			--| Mask "-X-X"
			create l_mask.make ("-X-X")
			assert ("is_valid_mask -X-X", not l_mask.is_invalid)
			assert ("not_repeating_specification -X-X", not l_mask.is_repeating_specification)
			assert_equals ("mask_count -X-X", 4, l_mask.mask.count)
			assert_equals ("mask_open_item_count -X-X", {NATURAL_32} 2, l_mask.open_item_count)
			--| No assertions for the literals; tested previously
			assert ("item_1_is_force_upper", attached {WILDCARD_MASK_ITEM} l_mask.mask [2])
			assert ("item_3_is_force_upper", attached {WILDCARD_MASK_ITEM} l_mask.mask [4])
			assert ("item_1_is_not_open -X-X", not l_mask.mask [1].is_open)
			assert ("item_2_is_open -X-X", l_mask.mask [2].is_open)
			assert ("item_3_is_not_open -X-X", not l_mask.mask [3].is_open)
			assert ("item_4_is_open -X-X", l_mask.mask [4].is_open)
			assert_equals ("index @ 1 -X-X", 1, l_mask.mask [1].index)
			assert_equals ("left_open_index @ 1 -X-X", 0, l_mask.mask [1].left_open_index)
			assert_equals ("right_open_index @ 1 -X-X", 2, l_mask.mask [1].right_open_index)
			assert_equals ("index @ 2 -X-X", 2, l_mask.mask [2].index)
			assert_equals ("left_open_index @ 2 -X-X", 0, l_mask.mask [2].left_open_index)
			assert_equals ("right_open_index @ 2 -X-X", 4, l_mask.mask [2].right_open_index)
			assert_equals ("index @ 3 -X-X", 3, l_mask.mask [3].index)
			assert_equals ("left_open_index @ 3 -X-X", 2, l_mask.mask [3].left_open_index)
			assert_equals ("right_open_index @ 3 -X-X", 4, l_mask.mask [3].right_open_index)
			assert_equals ("index @ 4 -X-X", 4, l_mask.mask [4].index)
			assert_equals ("left_open_index @ 4 -X-X", 2, l_mask.mask [4].left_open_index)
			assert_equals ("right_open_index @ 4 -X-X", 0, l_mask.mask [4].right_open_index)
			assert_equals ("left_closed_index @ 1 -X-X", 0, l_mask.mask [1].left_closed_index)
			assert_equals ("right_closed_index @ 1 -X-X", 3, l_mask.mask [1].right_closed_index)
			assert_equals ("left_closed_index @ 2 -X-X", 1, l_mask.mask [2].left_closed_index)
			assert_equals ("right_closed_index @ 2 -X-X", 3, l_mask.mask [2].right_closed_index)
			assert_equals ("left_closed_index @ 3 -X-X", 1, l_mask.mask [3].left_closed_index)
			assert_equals ("right_closed_index @ 3 -X-X", 0, l_mask.mask [3].right_closed_index)
			assert_equals ("left_closed_index @ 4 -X-X", 3, l_mask.mask [4].left_closed_index)
			assert_equals ("right_closed_index @ 4 -X-X", 0, l_mask.mask [4].right_closed_index)
		end

	test_string_value_input_mask_remove
			-- Test STRING_VALUE_INPUT_MASK.remove
		local
			l_constraint: STRING_COLUMN_METADATA
			l_mask: STRING_VALUE_INPUT_MASK
			l_result: TUPLE [value: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_test_data: READABLE_STRING_GENERAL
		do
			create l_constraint.make ("address", "adr_division", 50)
			--| capacity = 50
			--|
			--| Repeating Specifications
			--|
			create l_mask.make_repeating ("X")
			l_test_data := "THIS IS A TEST"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_strings_equal ("test 1 X", l_test_data, l_result.value)
			assert ("test 1 X error empty", l_result.error_message.is_empty)
			create {STRING_32} l_test_data.make_filled ('m', 62)
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_strings_equal ("test 2 |X", l_test_data, l_result.value)
			assert_strings_equal ("test 2 X error message", "The text entered is too long. Characters Entered: 62; Maximum Allowed: 50.", l_result.error_message)
			--|
			--| Mask Specifications
			--|
			create l_mask.make ("X-X-X-X-X-X-X")
			l_result := l_mask.remove ("I-N-V-A-L-I-D", l_constraint)
			assert_strings_equal ("test 5", "INVALID", l_result.value)
			assert ("test 5 no error message", l_result.error_message.is_empty)
			l_result := l_mask.remove ("I-N-V-A-L-I-F", l_constraint)
			assert_strings_equal ("test 6", "INVALIF", l_result.value)
			assert ("test 7 no error message", l_result.error_message.is_empty)
			create l_mask.make ("999-99-9999")
			l_result := l_mask.remove ("123-  -6789", l_constraint)
			assert_strings_equal ("test 8", "123  6789", l_result.value)
			assert_strings_equal ("test 8 invalid", "Entry is incomplete", l_result.error_message)
		end

	test_string_value_input_mask_apply
			-- Test STRING_VALUE_INPUT_MASK.apply
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_result: TUPLE [value: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_test_data: STRING_32
		do
			--|
			--| Repeating Mask Specifications
			--|
			--| Mask X
			--|
			create l_mask.make_repeating ("X")
			l_test_data := "My Test Data."
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("Test 1 value", l_test_data, l_result.value)
			assert ("Test 1 valid", l_result.error_message.is_empty)
			--|
			--| Mask !
			--|
			create l_mask.make_repeating ("!")
			l_test_data := "My Test Data."
			l_result := l_mask.apply (l_test_data)
			assert_case_insensitive_strings_equal ("Test 3 value", l_test_data, l_result.value)
			assert ("Test 3 valid", l_result.error_message.is_empty)
			--|
			--| Specified Masks
			--|
			--| Mask "999-99-9999"
			--|
			create l_mask.make ("999-99-9999")
			l_test_data := "123456789"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("Test 5 value", "123-45-6789", l_result.value)
			assert ("Test 5 is_valid", l_result.error_message.is_empty)
			l_test_data := "123**6789"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("Test 6 value", "123-00-6789", l_result.value)
			assert_strings_equal ("Test 6 invalid", "Contains illegal characters.", l_result.error_message)
			l_test_data := "123456789123"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("Test 7 value", "123-45-6789", l_result.value)
			assert ("Test 7 is_valid", l_result.error_message.is_empty)
			l_test_data := "1234567"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("Test 8 value", "123-45-6700", l_result.value)
			assert_strings_equal ("Test 8 invalid", "Missing required characters.", l_result.error_message)
			--|
			--| Mask !!!
			--|
			create l_mask.make ("!!!")
			l_test_data := "aaa"
			l_result := l_mask.apply (l_test_data)
			assert_case_insensitive_strings_equal ("Test 9 value", l_test_data, l_result.value)
			assert ("Test 9 is valid", l_result.error_message.is_empty)
			l_test_data := "aa"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("Test 10 value", "AA ", l_result.value)
			assert_strings_equal ("Test 10 invalid", "Missing required characters.", l_result.error_message)
			l_test_data := "aaaa"
			l_result := l_mask.apply (l_test_data)
			assert_strings_equal ("Test 11 value", "AAA", l_result.value)
			assert ("Test 11 is valid", l_result.error_message.is_empty)
		end

	test_ssn_mask_apply_remove
			-- Test of social security mask
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_apply_result: TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_remove_result: TUPLE [value: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_constraint: STRING_COLUMN_METADATA
		do
			create l_constraint.make ("contact", "con_ssan", 11)
			create l_mask.make ("###-##-####")
			l_apply_result := l_mask.apply ("XXX-XX-3333")
			assert_strings_equal ("ssn mask apply error 1", {MASKING_MESSAGES}.contains_illegal_characters + ".", l_apply_result.error_message)
			l_apply_result := l_mask.apply ("  3333  ")
			assert_strings_equal ("ssn mask apply 2", "  3-33-3   ", l_apply_result.masked_string)
			assert_strings_equal ("ssn mask apply error 2", {MASKING_MESSAGES}.missing_required_characters + ".", l_apply_result.error_message)
			l_apply_result := l_mask.apply ("3333")
			assert_strings_equal ("ssn mask apply 3", "333-3 -    ", l_apply_result.masked_string)
			assert_strings_equal ("ssn mask apply error 3", {MASKING_MESSAGES}.missing_required_characters + ".", l_apply_result.error_message)
			l_remove_result := l_mask.remove ("  3-33-3   " , l_constraint)
			assert_strings_equal ("ssn mask remove 1", "  3333", l_remove_result.value)
			assert_strings_equal ("ssn mask remove error 1", {MASKING_MESSAGES}.entry_incomplete, l_remove_result.error_message)
			l_remove_result := l_mask.remove ("   -  -    " , l_constraint)
			assert_strings_equal ("ssn mask remove 2", "", l_remove_result.value)
			assert_strings_equal ("ssn mask remove error 2", {MASKING_MESSAGES}.entry_incomplete, l_remove_result.error_message)
		end

	test_birthdate_mask_apply_remove
			-- Test of a DD/MM or MM/DD birthdate mask
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_apply_result: TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_remove_result: TUPLE [value: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_constraint: STRING_COLUMN_METADATA
		do
			create l_constraint.make ("contact", "con_birth_mmdd", 4)
			create l_mask.make ("__/__")
			l_apply_result := l_mask.apply ("X333")
			assert_strings_equal ("birthdate mask apply 1", " 3/33", l_apply_result.masked_string)
			assert_strings_equal ("birthdate mask apply error 1", {MASKING_MESSAGES}.contains_illegal_characters + ".", l_apply_result.error_message)
			l_apply_result := l_mask.apply ("  33  ")
			assert_strings_equal ("birthdate mask apply 2", "  /33", l_apply_result.masked_string)
			assert_strings_equal ("birthdate mask apply error 2", "", l_apply_result.error_message)
			l_apply_result := l_mask.apply (" 3 3 ")
			assert_strings_equal ("birthdate mask apply 3", " 3/ 3", l_apply_result.masked_string)
			assert_strings_equal ("birthdate mask apply error 3", "", l_apply_result.error_message)
			l_apply_result := l_mask.apply (" 3  3 ")
			assert_strings_equal ("birthdate mask apply 4", " 3/  ", l_apply_result.masked_string)
			assert_strings_equal ("birthdate mask apply error 4", "", l_apply_result.error_message)
			l_remove_result := l_mask.remove ("33/  " , l_constraint)
			assert_strings_equal ("birthdate mask remove 1", "33", l_remove_result.value)
			assert_strings_equal ("birthdate mask remove error 1", {MASKING_MESSAGES}.entry_incomplete, l_remove_result.error_message)
			l_remove_result := l_mask.remove ("  /  " , l_constraint)
			assert_strings_equal ("birthdate mask remove 2", "", l_remove_result.value)
			assert_strings_equal ("birthdate mask remove error 2", {MASKING_MESSAGES}.entry_incomplete, l_remove_result.error_message)
		end

	test_phone_number_mask_apply
			-- Test {INPUT_MASKS} phone_number_mask apply
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_result: TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_test_data: STRING
		do
			create l_mask.make ("(###) ###-####")
			l_test_data := "5123456789"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_1_5123456789", "(512) 345-6789", l_result.masked_string.as_string_8)
			assert ("Test_1_valid", l_result.error_message.is_empty)
			l_test_data := "5"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_2_5", "(5  )    -    ", l_result.masked_string.as_string_8)
			assert ("Test_2_invalid", not l_result.error_message.is_empty)
			l_test_data := "51"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_3_51", "(51 )    -    ", l_result.masked_string.as_string_8)
			assert ("Test_3_invalid", not l_result.error_message.is_empty)
			l_test_data := "512"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_4_512", "(512)    -    ", l_result.masked_string.as_string_8)
			assert ("Test_4_invalid", not l_result.error_message.is_empty)
			l_test_data := "5123"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_5_5123", "(512) 3  -    ", l_result.masked_string.as_string_8)
			assert ("Test_5_invalid", not l_result.error_message.is_empty)
			l_test_data := "51234"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_6_51234", "(512) 34 -    ", l_result.masked_string.as_string_8)
			assert ("Test_6_invalid", not l_result.error_message.is_empty)
			l_test_data := "512345"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_7_512345", "(512) 345-    ", l_result.masked_string.as_string_8)
			assert ("Test_7_invalid", not l_result.error_message.is_empty)
			l_test_data := "5123456"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_8_5123456", "(512) 345-6   ", l_result.masked_string.as_string_8)
			assert ("Test_8_invalid", not l_result.error_message.is_empty)
			l_test_data := "51234567"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_9_51234567", "(512) 345-67  ", l_result.masked_string.as_string_8)
			assert ("Test_9_invalid", not l_result.error_message.is_empty)
			l_test_data := "512345678"
			l_result := l_mask.apply (l_test_data)
			assert_equals ("test_10_512345678", "(512) 345-678 ", l_result.masked_string.as_string_8)
			assert ("Test_10_invalid", not l_result.error_message.is_empty)
		end

	test_phone_number_mask_remove
			-- Test REAL_VALUE_INPUT_MASK remove
		local
			l_mask: STRING_VALUE_INPUT_MASK
			l_constraint: STRING_COLUMN_METADATA
			l_result: TUPLE [value: READABLE_STRING_GENERAL; error_message: STRING_32]
			l_test_data: READABLE_STRING_GENERAL
		do
			create l_constraint.make ("phone", "phn_num", 10)
			create l_mask.make ("(###) ###-####")

			l_test_data := "(512) 345-6789"
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 (512) 345-6789", "5123456789", l_result.value.as_string_8)
			assert ("test 1 (512) 345-6789 error empty", l_result.error_message.is_empty)

			l_test_data := "(5  )    -    "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 5", "5", l_result.value.as_string_8)
			assert ("test 1 5 invalid", not l_result.error_message.is_empty)

			l_test_data := "(51 )    -    "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 51", "51", l_result.value.as_string_8)
			assert ("test 1 51 invalid", not l_result.error_message.is_empty)

			l_test_data := "(512)    -    "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 512", "512", l_result.value.as_string_8)
			assert ("test 1 512 invalid", not l_result.error_message.is_empty)

			l_test_data := "(512) 3  -    "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 5123", "5123", l_result.value.as_string_8)
			assert ("test 1 5123 invalid", not l_result.error_message.is_empty)

			l_test_data := "(512) 34 -    "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 51234", "51234", l_result.value.as_string_8)
			assert ("test 1 51234 invalid", not l_result.error_message.is_empty)

			l_test_data := "(512) 345-    "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 512345", "512345", l_result.value.as_string_8)
			assert ("test 1 512345 invalid", not l_result.error_message.is_empty)

			l_test_data := "(512) 345-6   "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 5123456", "5123456", l_result.value.as_string_8)
			assert ("test 1 5123456 invalid", not l_result.error_message.is_empty)

			l_test_data := "(512) 345-67  "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 51234567", "51234567", l_result.value.as_string_8)
			assert ("test 1 51234567 invalid", not l_result.error_message.is_empty)

			l_test_data := "(512) 345-678 "
			l_result := l_mask.remove (l_test_data, l_constraint)
			assert_equals ("test 1 512345678", "512345678", l_result.value.as_string_8)
			assert ("test 1 512345678 invalid", not l_result.error_message.is_empty)
		end

feature {NONE} -- Implementation

	on_prepare
			-- <Precursor>
		do
			Precursor;
			(create {STRING_VALUE_INPUT_MASK}.make (":X")).set_test_mode
		end

	mask_anchor: detachable MASKABLE [ANY]
			-- Ensure MASKABLE is compiled in to this project

;note
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

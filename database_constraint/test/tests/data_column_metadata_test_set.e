note
	description: "Tests for {DATA_COLUMN_METADATA_TEST_SET}."
	date: "$Date: 2013-12-23 18:28:27 -0500 (Mon, 23 Dec 2013) $"
	revision: "$Revision: 8326 $"

class
	DATA_COLUMN_METADATA_TEST_SET

inherit
	EQA_TEST_SET

feature -- Tests

	string_column_metadata_tests
			-- Tests STRING_COLUMN_METADATA.
		note
			testing:  "run/checkin/regular", "execution/isolated"
		local
			l_metadata: STRING_COLUMN_METADATA
			l_string: STRING
		do
			create l_metadata.make ("kungfoo", "fightin'", 11)
			create l_string.make_filled ('a', 10)
			assert ("string_conforms_1", l_metadata.conforms_to_constraint (l_string))
			create l_string.make_filled ('a', 11)
			assert ("string_conforms_2", l_metadata.conforms_to_constraint (l_string))
			create l_string.make_filled ('a', 12)
			assert ("string_not_conforms_1", not l_metadata.conforms_to_constraint (l_string))

			create l_metadata.make ("kungfoo", "fightin'", -1)
			create l_string.make_filled ('a', 1)
			assert ("string_conforms_3", l_metadata.conforms_to_constraint (l_string))
			create l_string.make_filled ('a', 11)
			assert ("string_conforms_4", l_metadata.conforms_to_constraint (l_string))
			create l_string.make_filled ('a', 120)
			assert ("string_conforms_5", l_metadata.conforms_to_constraint (l_string))
			create l_string.make_filled ('a', 120000)
			assert ("string_conforms_6", l_metadata.conforms_to_constraint (l_string))
		end

	integer_column_metadata_tests
			-- Tests INTEGER_COLUMN_METADATA.
		note
			testing:  "run/checkin/regular", "execution/isolated"
		local
			l_metadata: INTEGER_COLUMN_METADATA
			l_int: INTEGER
		do
			create l_metadata.make ("counting", "counter", 0)
			assert ("integer_conforms_1", l_metadata.conforms_to_constraint (l_int))
			l_int := 1
			assert ("integer_not_conforms_1", not l_metadata.conforms_to_constraint (l_int))

			create l_metadata.make ("counting", "counter", 1)
			assert ("integer_conforms_2", l_metadata.conforms_to_constraint (l_int))
			l_int := 9
			assert ("integer_conforms_3", l_metadata.conforms_to_constraint (l_int))
			l_int := 10
			assert ("integer_not_conforms_2", not l_metadata.conforms_to_constraint (l_int))

			create l_metadata.make ("counting", "counter", 2)
			assert ("integer_conforms_4", l_metadata.conforms_to_constraint (l_int))
			l_int := 99
			assert ("integer_conforms_5", l_metadata.conforms_to_constraint (l_int))
			l_int := 100
			assert ("integer_not_conforms_3", not l_metadata.conforms_to_constraint (l_int))
		end

	decimal_column_metadata_tests
			-- Tests DECIMAL_COLUMN_METADATA.
		note
			testing:  "run/checkin/regular", "execution/isolated"
		local
			l_metadata: DECIMAL_COLUMN_METADATA
			l_decimal: DECIMAL
		do
			create l_decimal.make_zero
			create l_metadata.make_with_scale ("counting", "counter", 0, 0)
			assert ("decimal_conforms_1", l_metadata.conforms_to_constraint (l_decimal))
			l_decimal := 1
			assert ("decimal_not_conforms_1", not l_metadata.conforms_to_constraint (l_decimal))

			create l_metadata.make_with_scale ("counting", "counter", 1, 1)
			assert ("decimal_conforms_2", l_metadata.conforms_to_constraint (l_decimal))
			l_decimal := 9
			assert ("decimal_conforms_3", l_metadata.conforms_to_constraint (l_decimal))
			l_decimal := 10
			assert ("decimal_not_conforms_2", not l_metadata.conforms_to_constraint (l_decimal))

			create l_metadata.make_with_scale ("counting", "counter", 2, 2)
			assert ("decimal_conforms_4", l_metadata.conforms_to_constraint (l_decimal))
			l_decimal := 99
			assert ("decimal_conforms_5", l_metadata.conforms_to_constraint (l_decimal))
			l_decimal := 100
			assert ("decimal_not_conforms_3", not l_metadata.conforms_to_constraint (l_decimal))
		end

	real_column_metadata_tests
			-- Tests REAL_COLUMN_METADATA.
		note
			testing:  "run/checkin/regular", "execution/isolated"
		local
			l_metadata: REAL_COLUMN_METADATA
			l_real: REAL_64
		do
			create l_metadata.make_with_scale ("counting", "counter", 0, 0)
			assert ("real_conforms_1", l_metadata.conforms_to_constraint (l_real))
			l_real := 1
			assert ("real_not_conforms_1", not l_metadata.conforms_to_constraint (l_real))

			create l_metadata.make_with_scale ("counting", "counter", 1, 1)
			assert ("real_conforms_2", l_metadata.conforms_to_constraint (l_real))
			l_real := 9
			assert ("real_conforms_3", l_metadata.conforms_to_constraint (l_real))
			l_real := 10
			assert ("real_not_conforms_2", not l_metadata.conforms_to_constraint (l_real))

			create l_metadata.make_with_scale ("counting", "counter", 2, 2)
			assert ("real_conforms_4", l_metadata.conforms_to_constraint (l_real))
			l_real := 99
			assert ("real_conforms_5", l_metadata.conforms_to_constraint (l_real))
			l_real := 100
			assert ("real_not_conforms_3", not l_metadata.conforms_to_constraint (l_real))
		end

	date_time_metadata_tests
			-- Tests REAL_COLUMN_METADATA.
		note
			testing:  "run/checkin/regular", "execution/isolated"
		local
			l_metadata: DATE_TIME_COLUMN_METADATA
			l_datetime: DATE_TIME
		do
			create l_metadata.make_with_scale ("date", "time", 23, 3)
			create l_datetime.make (1735, 1, 1, 0, 0, 0)
			assert ("date_conforms_1", l_metadata.conforms_to_constraint (l_datetime))
			l_datetime.make (1734, 12, 31, 23, 59, 59)
			assert ("date_not_conforms_1", not l_metadata.conforms_to_constraint (l_datetime))
			l_datetime.make (9999, 12, 31, 23, 59, 59)
			assert ("date_conforms_2", l_metadata.conforms_to_constraint (l_datetime))
			l_datetime.make (10000, 1, 1, 0, 0, 0)
			assert ("date_not_conforms_2", not l_metadata.conforms_to_constraint (l_datetime))
		end

	boolean_metadata_tests
			-- Tests BOOLEAN_COLUMN_METADATA
		note
			testing:  "run/checkin/regular", "execution/isolated"
		local
			l_metadata: BOOLEAN_COLUMN_METADATA
			l_bool: BOOLEAN
		do
			create l_metadata.make ("seriously", "cant_fail", 0)
			assert ("boolean_conforms_1", l_metadata.conforms_to_constraint (l_bool))
		end

	character_metadata_tests
			-- Tests CHARACTER_COLUMN_METADATA
		note
			testing:  "run/checkin/regular", "execution/isolated"
		local
			l_metadata: CHARACTER_COLUMN_METADATA
			l_char: CHARACTER
		do
			create l_metadata.make ("seriously", "cant_fail", 0)
			assert ("character_conforms_1", l_metadata.conforms_to_constraint (l_char))
		end

note
	copyright: "Copyright (c) 2010-2011, Jinny Corp."
	copying: "[
			Duplication and distribution prohibited. May be used only with
			Jinny Corp. software products, under terms of user license.
			Contact Jinny Corp. for any other use.
			]"
	source: "[
			Jinny Corp.
			3587 Oakcliff Road, Doraville, GA 30340
			Telephone 770-734-9222, Fax 770-734-0556
			Website http://www.jinny.com
			Customer support http://support.jinny.com
		]"
end

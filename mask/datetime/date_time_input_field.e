note
	description: "A sub field within a Date Time Mask"
	date: "$Date: "
	revision: "$Revision: 12316 $"

deferred class
	DATE_TIME_INPUT_FIELD

feature -- Status Report

	has_leading_field: BOOLEAN
			-- Is there a field to the left of this field?
		do
			Result := index > 1
		end

	has_trailing_field: BOOLEAN
			-- Is there a field to the right of this field?

feature -- Access

	minimum_value: NATURAL_32
			-- The minimum legal value within the field
		do
			Result := 1
		end

	maximum_value: NATURAL_32
			-- The maximum legal value within the field
			--| e.g. 12 for a month field
		deferred
		end

	width: NATURAL_32
			-- The maximum number of characters within the field
		deferred
		end

	index: NATURAL_32
			-- The position of this field relative to others within the EV_TEXT_COMPONENT

feature -- Basic Operations

	handle_digit (a_existing_text: STRING_32; a_digit, a_caret_position, a_end_selection: NATURAL_32; a_is_shift_pressed, a_is_control_pressed: BOOLEAN): TUPLE [new_text: STRING_32; new_caret_position: NATURAL_32; new_end_selection: NATURAL_32]
			-- User has pressed a digit
			--| a_caret_position, a_end_selection of zero indicates that selection extends into the leading field
			--| a_caret_position, a_end_selection > width + 1 indicates that the selection extends into the trailing field
			--| a_caret_position = a_end_selection indicates there is no selection
			--| Returns:
			--|  The new text to be displayed within the subfield
			--|  The new caret and end selection positions. Values of 0 and > width + 1 indicate a selection which extends into the leading or trailing fields respectively
		require
			valid_a_existing_text_length: a_existing_text.count <= width.as_integer_32
			valid_a_digit: a_digit <= 9
			valid_a_caret_position: a_caret_position <= width + 2
			valid_a_end_selection: a_end_selection <= width + 2
			position_with_no_selection: (a_caret_position = a_end_selection) implies (a_caret_position > 0) and (a_caret_position <= (width + 1))
			caret_position_leading_field: (a_caret_position = 0) implies has_leading_field
			end_selection_leading_field: (a_end_selection = 0) implies has_leading_field
			a_caret_position_trailing_field: (a_caret_position = (width + 2)) implies has_trailing_field
			a_end_selection_trailing_field: (a_end_selection = (width + 2)) implies has_trailing_field
		do
			Result := [("").as_string_32, (0).as_natural_32, (0).as_natural_32]
		ensure
			valid_new_text_length: Result.new_text.count <= width.as_integer_32
			valid_new_caret_position: Result.new_caret_position <= width + 2
			valid_new_end_selection: Result.new_end_selection <= width + 2
			new_position_with_no_selection: (Result.new_caret_position = Result.new_end_selection) implies (Result.new_caret_position > 0) and (Result.new_caret_position <= (width + 1))
			new_caret_position_leading_field: (Result.new_caret_position = 0) implies has_leading_field
			new_end_selection_leading_field: (Result.new_end_selection = 0) implies has_leading_field
			new_caret_position_trailing_field: (Result.new_caret_position = (width + 2)) implies has_trailing_field
			new_end_selection_trailing_field: (Result.new_end_selection = (width + 2)) implies has_trailing_field
		end

end

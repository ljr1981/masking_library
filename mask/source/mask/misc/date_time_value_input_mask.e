note
	warning: "DO NOT USE! (yet). See %"cautions%" below and %"refactors%" in {DOC_LIBRARY_MASK}.doc_cluster_misc notes."
	description: "[
			Date Time Value Input Masks are sepcializations of {TEXT_INPUT_MASK} to only allow date/time input.
			]"
	cautions: "[
		20141031: This class is not fully ready for use. See {DOC_LIBRARY_MASK}.doc_cluster_misc notes.
		]"
	generic_definition: "V -> DATE_TIME Value; CON -> Type of the DATA_COLUMN_METADATA to use as a constraint"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: $"

class
	DATE_TIME_VALUE_INPUT_MASK

inherit
	TEXT_INPUT_MASK [DATE_TIME, DATE_TIME_COLUMN_METADATA]
		redefine
			is_valid_constraint, is_masked_string_valid_for_current
		end

create
	make_with_date, make_with_time, make_with_date_and_time

feature {NONE} -- Initialization

	make_with_date
			-- Make and initialize `Current' for date masking.
		do
			date_time_mode := date_time_mode_date
			mask_specification := date_mask_string
			initialize_from_mask_string
		end

	make_with_time
			-- Make and initialize `Current' for date masking.
		do
			date_time_mode := date_time_mode_time
			mask_specification := time_mask_string
			initialize_from_mask_string
		end

	make_with_date_and_time
			-- Make and initialize `Current' for timestamp masking.
		do
			date_time_mode := date_time_mode_date_and_time
			mask_specification := date_mask_string + space_literal_string + time_mask_string
			initialize_from_mask_string
		end

feature -- Access

	default_value: DATE_TIME
			-- <Precursor>
		do
			create Result.make_from_epoch (0)
		end

feature -- Status Report

	is_valid_constraint (a_constraint: detachable DATA_COLUMN_METADATA [ANY]): BOOLEAN
			-- Is `a_constraint' consistent with specification of Current?
		do
			Result := attached {DATE_TIME_COLUMN_METADATA} a_constraint as l_date_time_col_metadata and then l_date_time_col_metadata.capacity >= mask.count
		end

	is_masked_string_valid_for_current (a_masked_string: READABLE_STRING_GENERAL): BOOLEAN
			-- Is `a_masked_string' a valid masked string for `Current'?
		do
			if Precursor (a_masked_string) then
				inspect
					date_time_mode
				when date_time_mode_date then
					Result := default_date.date_valid (a_masked_string.as_string_8, date_format_string)
				when date_time_mode_time then
					Result := default_time.time_valid (a_masked_string.as_string_8, time_format_string)
				when date_time_mode_date_and_time then
					if a_masked_string.count >= (default_date_string.count + 1 + default_time_string.count) then
						Result := default_date.date_valid (a_masked_string.substring (1, default_date_string.count).as_string_8, date_format_string) and then
							default_time.time_valid (a_masked_string.substring (default_date_string.count + 2, default_date_string.count + 1 + default_time_string.count).as_string_8, time_format_string)
					end
				end
			end
		end

feature {NONE} -- Implementation

	date_time_mode: NATURAL_8
		-- Current mode of date time.

	date_time_mode_date: NATURAL_8 = 0
	date_time_mode_time: NATURAL_8 = 1
	date_time_mode_date_and_time: NATURAL_8 = 2
		-- Different time date modes supported by `Current'.

	string_to_value (a_string: READABLE_STRING_GENERAL): like default_value
			-- <Precursor>
		local
			l_time_string, l_date_string: STRING_8
		do
			if a_string.count.as_natural_32 >= open_item_count then
				l_time_string := default_time_string
				l_date_string := default_date_string
				inspect
					date_time_mode
				when date_time_mode_date then
					create l_date_string.make (10)
					l_date_string.append_string_general (a_string)
					l_date_string.insert_character ('/', 3)
					l_date_string.insert_character ('/', 6)
				when date_time_mode_time then
					create l_time_string.make (12)
					l_time_string.append_string_general (a_string)
					l_time_string.insert_character (':', 3)
					l_time_string.insert_character (':', 6)
					l_time_string.insert_character (' ', 9)
				when date_time_mode_date_and_time then
					l_date_string := a_string.as_string_8.substring (1, 8)
					l_date_string.insert_character ('/', 3)
					l_date_string.insert_character ('/', 6)

					l_time_string := a_string.as_string_8.substring (9, 16)
					l_time_string.insert_character (':', 3)
					l_time_string.insert_character (':', 6)
					l_time_string.insert_character (' ', 9)
				end
			else
					-- We are not a valid string so we set to default invalid date and time strings.
				l_time_string := default_time_string
				l_date_string := default_invalid_date_string
			end

				-- Make sure that the date and time strings are valid.
			if not default_date.date_valid (l_date_string, date_format_string) then
					-- If the date is not valid then we must set with an invalid perfectly formed date.
				l_date_string := default_invalid_date_string
			end
			if not default_time.time_valid (l_time_string, time_format_string) then
					-- All times are valid so default to 12AM.
				l_time_string := default_time_string
			end

			create Result.make_by_date_time (
				create {DATE}.make_from_string (l_date_string, date_format_string),
				create {TIME}.make_from_string (l_time_string, time_format_string)
			)
		end

	value_to_string (a_value: like default_value): READABLE_STRING_GENERAL
			-- String representation of `a_value
		local
			l_string_8: STRING_8
		do
			inspect
				date_time_mode
			when date_time_mode_date then
				l_string_8 := a_value.formatted_out (date_format_string)
			when date_time_mode_time then
				l_string_8 := a_value.formatted_out (time_format_string)
			when date_time_mode_date_and_time then
				l_string_8 := a_value.formatted_out (date_and_time_format_string)
			end
				-- Remove any separator characters.
			l_string_8.prune_all (':')
			l_string_8.prune_all (' ')
			l_string_8.prune_all ('/')
			Result := l_string_8
		end

	default_date: DATE
			-- Default date helper object.
		once
			create Result.make_from_string (default_date_string, date_format_string)
		end

	default_time: TIME
			-- Default time helper object.
		once
			create Result.make_from_string (default_time_string, time_format_string)
		end

	default_date_string: STRING = "12/31/9999"
		-- Default date string used for creation of a default date.

	default_invalid_date_string: STRING = "01/01/0000"
		-- Invalid date string used when a masking operation involving dates has failed.

	default_time_string: STRING = "12:00:00 AM"
		-- Default time string used for creation of a default time.

	date_format_string: STRING = "[0]mm/[0]dd/yyyy"
		-- Format string used for initializing date objects.

	time_format_string: STRING = "[0]hh12:[0]mi:[0]ss AM"
		-- Format string used for initialize time objects.

	date_mask_string: STRING = "99\/99\/9999"
		-- mm/dd/yyyy

	time_mask_string: STRING = "99\:99\:99 UU"
		-- hh:mm:ddAM

	date_and_time_format_string: STRING
			-- Default format string used for date and time masks.
		do
			create Result.make (40)
			Result.append (date_format_string)
			Result.extend (' ')
			Result.append (time_format_string)
		end

	space_literal_string: STRING = "\ "
		-- Space literal mask representation.

	data_exceeds_column_constraint_message (a_result: DATE_TIME; a_constraint: detachable DATA_COLUMN_METADATA [ANY]): STRING_32
			-- <Precursor>
		do
			Result := translated_string (masking_messages.invalid_date_sentence, [])
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

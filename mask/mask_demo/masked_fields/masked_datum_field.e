note
	description: "[
					Abstract notion of a Datum Field with applied masking.
					
					What:
					----------------------------------------------------------------------
					A "Datum" consisting of an EV_LABEL with an EV_TEXT_COMPONENT
					inside of an EV_BOX. The `content' of the `widget' having
					a `mask' applied to it interactively with the user. Additionally,
					having a `caption' text applied to a `label' in either a side-by-side
					or over-under arrangement between the `label' and the `widget'.
					
					Why:
					----------------------------------------------------------------------
					Descendents of this class through a few deferred features and generics
					need to supply masking to various forms of EV_TEXT_COMPONENT, combining
					that `widget' together with a descriptive label.
					
					How:
					----------------------------------------------------------------------
					Supplying "C" for `content' type, "T" for `widget' type, "M" for `mask' type,
					and "B" for `box' type, such that the mask is applied to the widget for
					run-time interactive masking with user input. Additional agents are provided
					to control `select_all' or moving the insertion point to the start of the text
					for fields like date-time and others.
					]"
	date: "$Date: 2014-03-20 09:09:47 -0400 (Thu, 20 Mar 2014) $"
	revision: "$Revision: 8865 $"

deferred class
	MASKED_DATUM_FIELD [C -> ANY, T -> EV_TEXT_COMPONENT, B -> EV_BOX, M -> INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]]

feature {NONE} -- Initialization

	make_with_caption (a_caption: like caption; a_content: C)
			-- Initialize Current with `a_caption' and `a_content'.
		do
			caption := a_caption
			create label.make_with_text (caption)
			create_mask
			create_interface_objects
			set_masking (a_content)
			box.extend (label)
			box.extend (widget)
			box.disable_item_expand (label)
			box.disable_item_expand (widget)
			widget.set_minimum_width (Widget_minimum_width)
			box.set_border_width (3)
			box.set_padding (3)
		ensure
			caption_set: caption.same_string (a_caption)
			box_has_label: box.has (label)
			box_has_widget: box.has (widget)
		end

	make_with_caption_and_pattern (a_caption: like caption; a_mask_pattern: like mask_pattern_string; a_content: C)
			-- Initialize Current with `a_caption' using `a_mask_pattern' with `a_content'.
		do
			mask_pattern_string := a_mask_pattern
			make_with_caption (a_caption, a_content)
		ensure
			mask_pattern_set: mask_pattern_string.same_string (a_mask_pattern)
		end

	make_with_caption_and_repeating_pattern (a_caption: like caption; a_repeating_pattern: like repeating_pattern_character; a_content: C)
			-- Initialize Current with `a_caption' using `a_repeating_pattern' with `a_content'.
		do
			repeating_pattern_character := a_repeating_pattern
			make_with_caption (a_caption, a_content)
		ensure
			repeating_pattern_set: attached repeating_pattern_character as al_repeating_character and then al_repeating_character = a_repeating_pattern
			is_repeating: is_repeating_pattern_used
		end

feature -- Access

	box: B

feature -- Status Report

	is_repeating_pattern_used: BOOLEAN
			-- Is Current using repeating mask? (or mask_pattern_string? e.g. False)
		do
			Result := attached repeating_pattern_character and not (repeating_pattern_character.code = 0)
		end

feature -- Settings

	set_insertion_point_left
			-- Sets the insertion point of `widget' to first available place.
		do
			widget.focus_in_actions.extend (selection_at_first_agent)
		ensure
			has_agent: widget.focus_in_actions.has (selection_at_first_agent)
		end

	set_select_on_focus_in
			-- Set select_all when focus_in_actions.
		do
			widget.focus_in_actions.extend (select_all_agent)
		ensure
			has_agent: widget.focus_in_actions.has (select_all_agent)
		end

	set_tooltip (a_text: like widget.tooltip)
			-- Set `widget' tooltip to `a_text'.
		do
			widget.set_tooltip (a_text)
		end

	set_masking (a_content: C)
			-- Set `mask' on to `widget' in `box' with `label'.
		do
				-- creation
			create_mask
				-- Initialization
			mask.initialize_masking_widget_events (widget)
			check attached_string: attached {READABLE_STRING_GENERAL} mask.apply (a_content) [1] as al_text then
				widget.set_text (al_text)
			end
		end

	on_enter
		do
			
		end

feature -- Basic Operations

	remove_insertion_point_left_agent
			-- Remove `selection_at_first_agent'
		do
			widget.focus_in_actions.prune (selection_at_first_agent)
		ensure
			agent_removed: not widget.focus_in_actions.has (selection_at_first_agent)
		end

	remove_select_all_agent
			-- Remove `select_all_agent'
		do
			widget.focus_in_actions.prune (select_all_agent)
		ensure
			agent_removed: not widget.focus_in_actions.has (select_all_agent)
		end

feature {NONE} -- Implementation: Access

	selection_at_first_agent: PROCEDURE [ANY, TUPLE]
			-- Agent to set selection insertion point at some position.
		note
			option: "stable"
		attribute
			check attached {EV_TEXT_COMPONENT} widget as al_widget then
				Result := agent al_widget.set_selection (1, 1)
			end
		end

	select_all_agent: PROCEDURE [ANY, TUPLE]
			-- Select all agent.
		note
			option: "stable"
		attribute
			check attached {EV_TEXT_COMPONENT} widget as al_widget then
				Result := agent al_widget.select_all
			end
		end

	mask_pattern_string: STRING
			-- When Current is pattern-masked, then this string represents that pattern of characters.
		attribute
			Result := "X"
		end

	repeating_pattern_character: detachable CHARACTER
			-- When Current is repeating-masked, this character represents the nature of that mask.
			--'!' - Force input to upper case
			--'#' - Only digits and spaces are allowed, an error message of missing required characters is reported to the user
			--'_' - only digits and spaces are allowed, no error message reported for having spaces
			--'9' - Only digits are allowed
			--'A' - Only alphabetic characters are allowed. Numbers converted to spaces.
			--'K' - Only uppercase alphabetic, numeric, and dash characters are allowed.
			--'N' - Only letters and digits are allowed. (e.g. no special characters).
			--'U' - Only alphabetic characters are allowed (forced to upper case and others converted to spaces).
			--'W' - Only alphabetic characters are allowed (forced to lower case).
			--'X' - Permit any character

	caption: STRING
			-- `caption' for `label' of Current.

feature {NONE} -- Implementation: Basic Operations

	create_interface_objects
			-- Creation of interface GUI objects.
		deferred
		end

	create_mask
			-- Creation of `mask' object.
		deferred
		end

	mask: M
			-- `mask' applied to `widget' of Current.

	label: EV_LABEL
			-- Label for `caption' of Current.
		attribute
			create Result.make_with_text (caption)
		ensure
			Result.text.same_string (caption)
		end

	widget: T
			-- Data display `widget' for Current.

feature {NONE} -- Implementation: Constants

	Widget_minimum_width: INTEGER = 150
			-- Minimum size for widget.

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

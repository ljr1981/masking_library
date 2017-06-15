note
	description: "[
		An Input Mask handles conversion to/from the underlying data type to the {STRING_32} 
		object used in the widget and filters user input.
		]"
	purpose: "[
		Some text fields (where user input is represented as a {STRING_32}) are represented 
		in the object model as another type. Therefore, some conversion is needed to get 
		the data to/from the widget (e.g. {EV_TEXT_FIELD}).  For example, {INTEGER_32} values 
		in the model are entered by the user in a text field (represented in the gui 
		as a {STRING_32}).
		
		For some fields it is advantageous to filter user input, for example there is no 
		reason to allow the user to type an 'a' in a field which is to be used only for 
		a social security number.
		]"
	how: "[			
		All {INPUT_MASK}s are stateless so that they may be hooked up to multiple widgets.
		
		- Masked Field Hookup -
		The mask is hooked up to a field by use of `initialize_masking_widget_events'
		
		- Conversion -
		The {STRING_32} representation of data from the model is placed in the widget using `apply'
		
		The current (converted) value be obtained from the widget using `remove'. An optional constraint
		may be used to verify that the user input is not too long/large.  If conversion is not possible
		or the input does not fit within the given constraint, an error message will also be returned.
		]"
	nomenclature: "[
		The suffix *_index is used for variables which indicate character position.
		The suffix *_position is used for variables which indicate anchor/caret position.
		]"
	caution: "[
		The naming convention (e.g. *_index, *_position) was adopted late in the development and may not 
		have been universally applied.  Deviations from it should be corrected.
		]"
	glossary: "Definitions of Terms"
	term: "[
		anchor: point(s) located between the characters in a text field (see caret_position).
		]"
	term: "[
		caret position: point(s) located between the characters in a text field (see anchor).
		]"
	term: "[
		character position: position of actual character in string, as opposed to position of cursor
		]"
	refactors: "[
		20141031: Scan for, locate, and update features not meeting the *_index/*_position naming convention
					and refactor appropriately.
		]"
	generic_definition: "V -> {ANY} Value; CON -> Type of the {DATA_COLUMN_METADATA} to use as a constraint"
	date: "$Date: 2015-12-03 15:44:02 -0500 (Thu, 03 Dec 2015) $"
	revision: "$Revision: 12794 $"

deferred class
	INPUT_MASK [V -> detachable ANY, reference CON -> detachable DATA_COLUMN_METADATA [ANY]]

inherit
	EV_KEY_CONSTANTS

feature -- Access

	text_for_current_state (a_text: STRING_32): STRING_32
			-- Return text based on `Current' state of mask.
		do
			Result := a_text
		end

	filtered_clipboard_text: STRING_32
			-- Contents of application clipboard, filtered
		do
			Result := filter_text (ev_application.clipboard.text)
		end

	allow_standard_key_processing_agent: attached like {EV_WIDGET}.default_key_processing_handler
			-- Agent for use in {EV_TEXT_FIELD}.set_default_key_processing_handler
		do
			Result := agent allow_standard_key_processing
		end

	right_limit_offset: INTEGER
			-- Offset of the right limit for cursor movement (from widget.text_length)
		do
			Result := 1
		end

feature -- Status Report

	is_valid_character_for_mask (a_character: CHARACTER_32): BOOLEAN
			-- Is `a_character' valid input for Current?
		do
			Result := True
		end

	is_valid_constraint (a_constraint: detachable DATA_COLUMN_METADATA [ANY]): BOOLEAN
			-- Is `a_constraint' consistent with specification of Current?
		do
			Result := attached constraint_from_data_column_constraint (a_constraint)
		end

	is_control_pressed: BOOLEAN
			-- Is the control key currently being pressed?
		do
			Result := ev_application.ctrl_pressed
		end

	is_option_pressed, is_alt_pressed: BOOLEAN
			-- Is the option key currently being pressed?
		do
			Result := ev_application.alt_pressed
		end

	is_shift_pressed: BOOLEAN
			-- Is the shift key currently being pressed?
		do
			Result := ev_application.shift_pressed
		end

	is_dynamic: BOOLEAN
			-- Does `Current' handle dynamic, on-the-fly masking in the control?
		do
			Result := True
		end

	is_invalid: BOOLEAN
			-- Was `Current' created using an invalid mask?

	allow_standard_key_processing (a_key: EV_KEY): BOOLEAN
				-- Should we allow the standard key processing to continue
			do
				inspect
					a_key.code
				when
					key_enter, key_page_up, key_page_down, key_escape, key_up, key_down,
					key_f1, key_f2, key_f3, key_f4, key_f5, key_f6, key_f7, key_f8, key_f9,
					key_f10, key_f11, key_f12, key_num_lock, key_tab
				then
					Result :=  True
				else
					-- do nothing
				end
			end

	has_mask_target (a_list: LIST [ROUTINE [ANY, detachable TUPLE]]): BOOLEAN
			-- Does a_list contain any agents targeted at an INPUT_MASK
		do
			Result := across a_list as ic_list some is_targeted_at_mask (ic_list.item) end
		end

	is_targeted_at_mask (a_routine: ROUTINE [ANY, detachable TUPLE]): BOOLEAN
			-- Is `a_routine' targeted at a mask?
		local
			l_internal: INTERNAL
			l_input_mask_type_id: INTEGER
		do
			if attached a_routine.target as al_target then
				create l_internal
				l_input_mask_type_id := l_internal.dynamic_type_from_string ("INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]")
				check
					non_zero_type_id: l_input_mask_type_id > 0
				end
				Result := l_internal.is_instance_of (al_target, l_input_mask_type_id)
			end
		end

	widget_has_masking_event_handlers (a_widget: EV_TEXT_COMPONENT): BOOLEAN
			-- Are any msking event handlers set up on `a_widget'
		do
			Result := 	has_mask_target (a_widget.key_press_actions) or else
						has_mask_target (a_widget.key_press_string_actions) or else
						attached a_widget.configurable_target_menu_handler as al_target_menu_handler and then is_targeted_at_mask (al_target_menu_handler) or else
						has_mask_target (a_widget.pointer_enter_actions) or else
						has_mask_target (a_widget.pointer_leave_actions)
			--| Ignore status of a_widget.pebble
			--| Ignore a_widget.target_data_function since it isn't used and can't be reset anyway (set_target_data_function requires an attached argument)						
		ensure
			has_key_press_actions_implies_result: has_mask_target (a_widget.key_press_actions) implies Result
			has_key_press_string_ations_implies_result: has_mask_target (a_widget.key_press_string_actions) implies Result
			has_target_menu_handler_implies_result: attached a_widget.configurable_target_menu_handler as al_target_menu_handler and then is_targeted_at_mask (al_target_menu_handler) implies Result
			has_pointer_enter_actions_implies_result: has_mask_target (a_widget.pointer_enter_actions) implies Result
			has_pointer_leave_actions_implies_result: has_mask_target (a_widget.pointer_leave_actions) implies Result
		end

	is_cursor_at_start_of_field (a_widget: EV_TEXT_COMPONENT): BOOLEAN
			-- Is the caret position of `a_widget' at its start?
		do
			Result := a_widget.caret_position = 1
		end

	is_cursor_at_end_of_field (a_widget: EV_TEXT_COMPONENT): BOOLEAN
			-- Is the caret position of `a_widget' at its end?
		do
			Result := a_widget.caret_position = a_widget.text_length + right_limit_offset
		end

feature -- Basic Operations

	apply (a_value: V): TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			-- Mask `a_value' as `masked_string'.
			-- Provide `error_message' if `a_value' does not conform to mask specification or is invalid.
			-- Empty `error_message' indicates `a_value' conforms to mask specification and is fully valid
			--| DATA_CONSTRAINT is not checked. `a_value' will come from the database and will "fit" automatically.
		require
			not_is_invalid: not is_invalid
		do
			Result := apply_implementation (value_to_string (a_value))
		end

	remove (a_masked_string: READABLE_STRING_GENERAL; a_constraint: detachable CON): TUPLE [value: V; error_message: STRING_32]
			-- Remove mask from `a_masked_string' and return `value'.
			-- Provide `error_message' if `a_string' does not conform to mask specification, will not fit in database column, or is invalid
			-- Empty `error_message' indicates `a_value' conforms to mask specification, will fit in database column, and is fully valid.
		require
			not_is_invalid: not is_invalid
			is_valid_constraint: attached a_constraint implies is_valid_constraint (a_constraint)
		do
			Result := remove_implementation (a_masked_string.as_string_32, a_constraint)
		end

	frozen fix_pointer_position (a_widget: EV_TEXT_COMPONENT)
			-- Verifies implementation preconditions and then calls `fix_pointer_position_implementation
		local
			l_exception_occurred, l_attempted_logging: BOOLEAN
			l_start_selection, l_end_selection: INTEGER
		do
			if not a_widget.is_destroyed and not l_attempted_logging then
				if l_exception_occurred then
					if a_widget.has_selection then
						l_start_selection := a_widget.start_selection
						l_end_selection := a_widget.end_selection
					end
					log_error ("on_key_string_wrapper", "masking_exception", <<["widget_text", a_widget.text], ["caret_position", a_widget.caret_position], ["has_selection", a_widget.has_selection], ["start_selection", l_start_selection], ["end_selection", l_end_selection]>>)
				else
					ev_application.process_graphical_events
					if a_widget.has_focus and then a_widget.is_editable then
						fix_pointer_position_implementation (a_widget)
					end
				end
			end
		rescue
			if l_exception_occurred then
				l_attempted_logging := True
			end
			l_exception_occurred := True
			Retry
		end

feature -- Mask Hookup

	initialize_masking_widget_events (a_masking_widget: EV_TEXT_COMPONENT)
			-- Initialize masking widget `a_masking_widget' with masking event agents.
		do
			if widget_has_masking_event_handlers (a_masking_widget) then
				remove_masking_event_handlers (a_masking_widget)
			end
			a_masking_widget.set_default_key_processing_handler (allow_standard_key_processing_agent)
			a_masking_widget.key_press_actions.extend (agent handle_key_press_wrapper (agent handle_key_press (?, a_masking_widget), ?, a_masking_widget))
			a_masking_widget.key_press_string_actions.extend (agent handle_key_string_wrapper (agent handle_key_string (?, a_masking_widget), ?, a_masking_widget))
			setup_context_menu (a_masking_widget)
			if not attached fix_pointer_position_after_button_release_agent then
				fix_pointer_position_after_button_release_agent := agent fix_pointer_position_after_button_release
			end
			a_masking_widget.pointer_enter_actions.extend (agent handle_pointer_enter (a_masking_widget))
			a_masking_widget.pointer_leave_actions.extend (agent handle_pointer_leave (a_masking_widget))
		end

	remove_masking_event_handlers (a_widget: EV_TEXT_COMPONENT)
			-- Remove all masking related agents from `a_widget'
		do
			if attached a_widget.default_key_processing_handler as al_default_key_processing_handler and then is_targeted_at_mask (al_default_key_processing_handler) then
				a_widget.set_default_key_processing_handler (Void)
			end
			remove_masking_event_handlers_from_list (a_widget.key_press_actions)
			remove_masking_event_handlers_from_list (a_widget.key_press_string_actions)
			remove_masking_event_handlers_from_list (a_widget.pointer_enter_actions)
			remove_masking_event_handlers_from_list (a_widget.pointer_leave_actions)
			if attached a_widget.configurable_target_menu_handler as al_configurable_target_menu_handler and then is_targeted_at_mask (al_configurable_target_menu_handler) then
				a_widget.set_configurable_target_menu_handler (Void)
			end
			--| Ignore status of a_widget.pebble
			--| Ignore a_widget.target_data_function since it isn't used and can't be reset anyway (set_target_data_function requires an attached argument)						
		ensure
			not_has_masking_event_handlers: not widget_has_masking_event_handlers (a_widget)
		end

	remove_masking_event_handlers_from_list (a_list: LIST [ROUTINE [ANY, detachable TUPLE]])
			-- Remove all masking related agents from `a_list'
		local
			l_masking_related_agents: ARRAYED_LIST [ROUTINE [ANY, detachable TUPLE]]
		do
			create l_masking_related_agents.make (10)
			across a_list as ic_list loop
				if is_targeted_at_mask (ic_list.item) then
					l_masking_related_agents.extend (ic_list.item)
				end
			end
			across l_masking_related_agents as ic_masking_related_agents loop
				a_list.prune (ic_masking_related_agents.item)
			end
		ensure
			not_has_mask_target: not has_mask_target (a_list)
		end

feature -- Event handling

	handle_key_press (a_key: EV_KEY; a_widget: EV_TEXT_COMPONENT)
			-- Process a key press event from `a_widget'.
		require
			not_is_invalid: not is_invalid
		do
			if not allow_standard_key_processing (a_key) and then not a_widget.is_destroyed then
				inspect
					a_key.code
				when key_left then
					handle_key_left (a_widget)
				when key_right then
					handle_key_right (a_widget)
				when key_home then
					handle_key_home (a_widget)
				when key_end then
					handle_key_end (a_widget)
				when key_delete then
					if a_widget.is_editable then
						handle_key_delete (a_widget)
					end
				when key_back_space then
					if a_widget.is_editable then
						handle_key_back_space (a_widget)
					end
				when key_a then
						-- Select All operation.
					if is_control_pressed and then not is_option_pressed and then not is_shift_pressed then
						handle_select_all (a_widget)
					end
				when key_c then
						-- Copy operation						
					if is_control_pressed and then not is_option_pressed and then not is_shift_pressed then
						handle_copy (a_widget)
					end
				when key_x then
						-- Cut Operation
					if is_control_pressed and then not is_option_pressed and then not is_shift_pressed and then a_widget.is_editable then
						handle_cut (a_widget)
					end
				when key_v then
						-- Paste Operation
					if is_control_pressed and then not is_option_pressed and then not is_shift_pressed then
						handle_paste (a_widget)
					end
				when key_z then
						-- Undo Operation
					if is_control_pressed and then not is_option_pressed and then not is_shift_pressed then
						-- TODO Implement
					end
				else
					-- No custom handling needed.
				end
			end
		end

	handle_key_string (a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- Process a key press string event from `a_widget'.
		local
			l_has_selection: BOOLEAN
			l_text_to_insert: STRING_32
			l_is_editable: BOOLEAN
		do
			l_is_editable := a_widget.is_editable
			l_has_selection := a_widget.has_selection
			if a_key_string.count > 0 and then not (a_key_string.has ('%N') or a_key_string.has ('%T')) and then
				(l_is_editable and then across a_key_string as ic_items some is_valid_character_for_mask (ic_items.item) end) then

					-- No selection operations are needed so we try to insert characters if valid to the mask.
				l_text_to_insert := a_key_string
				if l_has_selection then
					replace_selection (a_widget, l_text_to_insert)
				else
					insert_string (a_widget, l_text_to_insert)
				end
			end
		end

	handle_select_all (a_widget: EV_TEXT_COMPONENT)
			-- Perform a select all operation on `a_widget'
		do
			if a_widget.text_length > 0 then
				a_widget.select_all
			end
		end

	handle_copy (a_widget: EV_TEXT_COMPONENT)
			-- Perform a copy operation on `a_widget'
		do
			if a_widget.has_selection then
				ev_application.clipboard.set_text (text_for_current_state (a_widget.selected_text))
			end
		end

	handle_cut (a_widget: EV_TEXT_COMPONENT)
			-- Perform a cut operation
		do
			if a_widget.is_editable and then a_widget.has_selection then
				ev_application.clipboard.set_text (a_widget.selected_text)
				replace_selection (a_widget, "")
			end
		end

	handle_paste (a_widget: EV_TEXT_COMPONENT)
		local
			l_text_to_insert: STRING_32
		do
			if a_widget.is_editable and then not ev_application.clipboard.text.is_empty then
				l_text_to_insert := filtered_clipboard_text
				if not l_text_to_insert.is_empty then
					if a_widget.has_selection then
						replace_selection (a_widget, l_text_to_insert)
					else
						insert_string (a_widget, l_text_to_insert)
					end
				end
			end
		end

	handle_pointer_enter (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		do
			if attached fix_pointer_position_after_button_release_agent as al_agent then
				ev_application.pointer_button_release_actions.extend (al_agent)
			end
		end

	handle_pointer_leave (a_widget: EV_TEXT_COMPONENT)
			-- <Precursor>
		do
			fix_pointer_position (a_widget)
			if attached fix_pointer_position_after_button_release_agent as al_agent then
				ev_application.pointer_button_release_actions.prune_all (al_agent)
			end
		end

	handle_key_left (a_widget: EV_TEXT_COMPONENT)
		deferred
		end

	handle_key_right (a_widget: EV_TEXT_COMPONENT)
			-- Moves caret one to the right or extends selection one to the right.
		deferred
		end

	handle_key_home (a_widget: EV_TEXT_COMPONENT)
			-- Moves caret and/or extends selection to the left most position in the field.
		deferred
		end

	handle_key_end (a_widget: EV_TEXT_COMPONENT)
			-- Moves caret and/or extends selection to the right most position in the field.
		deferred
		end

	handle_key_back_space (a_widget: EV_TEXT_COMPONENT)
			-- Remove text to the left of the cursor, as appropriate.
		deferred
		end

	handle_key_delete (a_widget: EV_TEXT_COMPONENT)
			-- Processing to occur when delete key is pressed
		deferred
		end

feature {NONE} -- Agents

	frozen mask_key_press_agent: PROCEDURE [ANY, TUPLE [EV_KEY]]
			-- Type anchor for masking key press agents (do not call directly).
		do
			check do_not_call: False then end
		end

	frozen mask_key_string_agent: PROCEDURE [ANY, TUPLE [STRING_32]]
			-- Type anchor for masking key string agents (do not call directly).
		do
			check do_not_call: False then end
		end

feature {TEST_SET_BRIDGE} -- Implementation: Environment/Application

	ev_environment: EV_ENVIRONMENT
		once
			create Result
		end

	ev_application: EV_APPLICATION
			-- Application Access.
		local
			l_application: detachable EV_APPLICATION
		do
			l_application := ev_environment.application
			check l_application_available: l_application /= Void end
			Result := l_application
		end

	application_clipboard: EV_CLIPBOARD
			-- Application Clipboard Access.
		local
			l_application: detachable EV_APPLICATION
		do
			l_application := ev_environment.application
			check l_application_available: l_application /= Void end
			Result := l_application.clipboard
		end

feature {TEST_SET_BRIDGE} -- Implementation: Context Menu

	setup_context_menu (a_widget: EV_TEXT_COMPONENT)
			-- Configure `a_widget' for context menu
		do
			a_widget.set_pebble ("STRING pebble")
			a_widget.set_configurable_target_menu_mode
			a_widget.set_configurable_target_menu_handler (agent target_menu_handler (a_widget, ?, ?, ?, ?))
			a_widget.set_target_data_function (agent target_data_function)
		end

	target_menu_handler (a_widget: EV_TEXT_COMPONENT; a_menu: EV_MENU; a_target_list: ARRAYED_LIST [EV_PND_TARGET_DATA]; a_source: EV_PICK_AND_DROPABLE; a_pebble: detachable ANY)
			-- Handles setup of context menu
		local
			l_menu_item: EV_MENU_ITEM
		do
			create l_menu_item.make_with_text_and_action (translated_string (masking_messages.cut_message, []), agent handle_cut (a_widget))
			if a_widget.is_editable and then a_widget.has_selection then
				l_menu_item.enable_sensitive
			else
				l_menu_item.disable_sensitive
			end
			a_menu.extend (l_menu_item)
			create l_menu_item.make_with_text_and_action (translated_string (masking_messages.copy_message, []), agent handle_copy (a_widget))
			if a_widget.has_selection then
				l_menu_item.enable_sensitive
			else
				l_menu_item.disable_sensitive
			end
			a_menu.extend (l_menu_item)
			create l_menu_item.make_with_text_and_action (translated_string (masking_messages.paste_message, []), agent handle_paste (a_widget))
			if a_widget.is_editable and then (not ev_application.clipboard.text.is_empty) then
				l_menu_item.enable_sensitive
			else
				l_menu_item.disable_sensitive
			end
			a_menu.extend (l_menu_item)
			create l_menu_item.make_with_text_and_action (translated_string (masking_messages.delete_message, []), agent handle_key_delete (a_widget))
			if a_widget.is_editable and then a_widget.has_selection then
				l_menu_item.enable_sensitive
			else
				l_menu_item.disable_sensitive
			end
			a_menu.extend (l_menu_item)
			create l_menu_item.make_with_text_and_action (translated_string (masking_messages.select_all_message, []), agent handle_select_all (a_widget))
			if not a_widget.text.is_empty then
				l_menu_item.enable_sensitive
			else
				l_menu_item.disable_sensitive
			end
			a_menu.extend (l_menu_item)
		end

	 target_data_function (a_pebble: STRING): EV_PND_TARGET_DATA
		do
			create Result
		end

feature {NONE} -- Implementation: Localization

	translated_string (a_string: READABLE_STRING_GENERAL; a_token_values: TUPLE): STRING_32
			-- Formatted translation of `a_string'.
		do
			locale.string_formatter.set_escape_character ('^')
			Result := locale.formatted_string (a_string, a_token_values)
		end


	locale: I18N_LOCALE
			-- Provides access to translations and formatting objects for a given locale.
		do
			if attached internal_locale as al_result then
				Result := al_result
			else
				create Result.make (create {I18N_DUMMY_DICTIONARY}.make (0), create {I18N_LOCALE_INFO}.make)
				internal_locale := Result
			end
		end

	internal_locale: detachable like locale
			-- Cached access to `locale' for once per object.

feature {TEST_SET_BRIDGE} -- Implementation

	handle_key_press_wrapper (a_agent: like mask_key_press_agent; a_key: EV_KEY; a_widget: EV_TEXT_COMPONENT)
			-- Provides exception handling for `mask_keypress_agent)
		local
			l_exception_occurred, l_attempted_logging: BOOLEAN
			l_start_selection, l_end_selection: INTEGER
		do
			fix_pointer_position (a_widget)
			if not a_widget.is_destroyed and then not l_attempted_logging then
				if l_exception_occurred then
					if a_widget.has_selection then
						l_start_selection := a_widget.start_selection
						l_end_selection := a_widget.end_selection
					end
					log_error ("on_key_string_wrapper", "masking_exception", <<["key_code", a_key.code], ["widget_text", a_widget.text], ["caret_position", a_widget.caret_position], ["has_selection", a_widget.has_selection], ["start_selection", l_start_selection], ["end_selection", l_end_selection]>>)
				elseif not a_widget.is_destroyed then
					a_agent.call ([a_key])
				end
			end
		rescue
			if l_exception_occurred then
				l_attempted_logging := True
			end
			l_exception_occurred := True
			Retry
		end

	handle_key_string_wrapper (a_agent: like mask_key_string_agent; a_key_string: STRING_32; a_widget: EV_TEXT_COMPONENT)
			-- Provides exception handling for `mask_keystring_agent)
		local
			l_exception_occurred, l_attempted_logging: BOOLEAN
			l_start_selection, l_end_selection: INTEGER
		do
			fix_pointer_position (a_widget)
			if not a_widget.is_destroyed and then not l_attempted_logging then
				if l_exception_occurred then
					if a_widget.has_selection then
						l_start_selection := a_widget.start_selection
						l_end_selection := a_widget.end_selection
					end
					log_error ("on_key_string_wrapper", "masking_exception", <<["key_string", a_key_string], ["widget_text", a_widget.text], ["caret_position", a_widget.caret_position], ["has_selection", a_widget.has_selection], ["start_selection", l_start_selection], ["end_selection", l_end_selection]>>)
				else
					a_agent.call ([a_key_string])
				end
			end
		rescue
			if l_exception_occurred then
				l_attempted_logging := True
			end
			l_exception_occurred := True
			Retry
		end

	fix_pointer_position_after_button_release (a_widget: EV_WIDGET; a_button: INTEGER; a_screen_x: INTEGER; a_screen_y: INTEGER)
			-- Fix pointer position after button release
		do
			if attached {EV_TEXT_COMPONENT} a_widget as al_widget then
				fix_pointer_position (al_widget)
			end
		end

	fix_pointer_position_after_button_release_agent: detachable PROCEDURE [ANY, TUPLE [widget: EV_WIDGET; button: INTEGER; screen_x: INTEGER; screen_y: INTEGER]]
			-- Agent of `fix_pointer_position_after_button_release'

	fix_pointer_position_implementation (a_widget: EV_TEXT_COMPONENT)
		require
			not_destroyed: not a_widget.is_destroyed
			has_focus: a_widget.has_focus
			is_editable: a_widget.is_editable
		do
			do_nothing
			--| Descendents may redefine
		end

	set_selection_in_widget (a_widget: EV_TEXT_COMPONENT; a_anchor_position, a_caret_position: INTEGER)
			-- Set the selection in `a_widget' using `a_anchor_position' and `a_caret_position'
		require
			start_within_range: a_anchor_position >= 1 and a_anchor_position <= a_widget.text_length + 1
			end_within_range: a_caret_position >= 1 and a_caret_position <= a_widget.text_length + 1
		do
			a_widget.set_selection (a_anchor_position, a_caret_position)
		end

	anchor_position_from_widget (a_widget: EV_TEXT_COMPONENT): INTEGER
			-- Retrieve the anchor position from the widget; this is the caret position when there is no selection
			--| The anchor of the selection is the selection point away from the caret
			--| When making a selection from with a mouse, the anchor is where the selection is started, and the caret
			--| is placed where the selection ends (which is the active end of the selection)
		local
			l_caret_pos, l_sel_start, l_sel_end: INTEGER
		do
			l_caret_pos := a_widget.caret_position
			if a_widget.has_selection then
				l_sel_start := a_widget.start_selection
				l_sel_end := a_widget.end_selection
				if l_caret_pos >= l_sel_end then
					Result := l_sel_start
				else
					Result := l_sel_end
				end
			else
				Result := l_caret_pos
			end
		end

	caret_position_from_widget (a_widget: EV_TEXT_COMPONENT): INTEGER
			-- Retrieve end selection valid caret position if available, otherwise return caret position.
		do
				-- End selection is always caret position.
			Result := a_widget.caret_position
		end

	filter_text (a_text: STRING_32): STRING_32
			-- Filter out characters in a_text which are not `is_valid_character_for_mask'
		do
			create Result.make (a_text.count)
			across a_text as ic_text loop
				if is_valid_character_for_mask (ic_text.item) then
					Result.extend (ic_text.item)
				end
			end
		end

	refresh_formatting (a_text: STRING_32): STRING_32
			-- Refresh the formatting on `a_text'
		do
			Result := a_text.twin
		end

	insert_string (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32)
			-- Insert `a_text' at caret_position of `a_widget'
		require
			widget_has_no_selection: not a_widget.has_selection
			widget_is_editable: a_widget.is_editable
		deferred
		end

	apply_implementation (a_value: READABLE_STRING_GENERAL): TUPLE [masked_string: READABLE_STRING_GENERAL; error_message: STRING_32]
			-- Implemetation of `apply'.
		deferred
		end

	replace_selection (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32)
			-- Replace selected text in `a_widget' with `a_text'
		require
			widget_has_selection: a_widget.has_selection
			widget_is_editable: a_widget.is_editable
		deferred
		end

	remove_character_at_caret_position (a_widget: EV_TEXT_COMPONENT; before: BOOLEAN)
			-- Remove character at caret position, `before' removes character before caret.
			-- Caret is set at the index of the removed character.
		deferred
		end

	remove_implementation (a_string: STRING_32; a_constraint: detachable CON): TUPLE [value: V; error_message: STRING_32]
			-- Implemetation for `remove'.
		deferred
		end

	string_to_value (a_string: READABLE_STRING_GENERAL): like default_value
			-- Value from its string representation
		deferred
		end

	value_to_string (a_value: like default_value): READABLE_STRING_GENERAL
			-- String representation of `a_value'
		deferred
		end

	update_text_and_caret_position (a_widget: EV_TEXT_COMPONENT; a_text: STRING_32; a_caret_position: INTEGER)
			-- Update text of `a_widget' with appropriate representation of `a_text' leaving caret position at `a_caret_position'.
		require
			non_negative_caret: a_caret_position > 0
			valid_caret_position: a_caret_position <= a_text.count + 1
		do
			a_widget.set_text (a_text)
			a_widget.set_caret_position (a_caret_position)
		ensure
			text_set: a_widget.text.same_string (a_text)
		end

	default_initial_masking_iteration_index: INTEGER
			-- Character index where masking usually applies?
		do
			Result := 1
		end

	initial_string_iteration_index (a_string: STRING_32): INTEGER
			-- Character index in `a_string' where masking should begin from.
		do
			Result := 1
				-- Redefined in descendents.
		ensure
			result_greater_than_zero: Result > 0
		end

	initial_masking_iteration_index_from_string (a_string: STRING_32): INTEGER
			-- Character index where string to mask mapping should begin.
		do
			Result := default_initial_masking_iteration_index
		ensure
			result_greater_than_zero: Result > 0
		end

	ending_masking_iteration_index_from_string (a_string: STRING_32): INTEGER
			-- Character index where string to mask mapping should end.
		do
			Result := initial_masking_iteration_index_from_string (a_string) + a_string.count - initial_string_iteration_index (a_string)
		ensure
			result_greater_than_zero: Result > 0
		end

	default_value: V
			-- Default value from `Current'.
		deferred
		end

	constraint_from_data_column_constraint (a_constraint: detachable DATA_COLUMN_METADATA [ANY]): detachable CON
			-- Return an attached constraint from `a_constraint' that matches `Current' if type is compatible.
		do
			if attached {CON} a_constraint as l_result then
				Result := l_result
			end
		end

	data_does_not_conform_to_mask_specification_message (a_result: READABLE_STRING_GENERAL; a_max_characters_allowed: INTEGER): STRING_32
			-- <Precursor>
		do
			Result := translated_string (masking_messages.text_entered_too_long_message, [a_result.count.out, a_max_characters_allowed.out])
		end

	log_error (a_feature_name: STRING; a_message: STRING; a_data: ARRAY [TUPLE [name: STRING; value: detachable ANY]])
			-- Log error.
		do
			do_nothing
		end

	masking_messages: ABSTRACT_MASKING_MESSAGES
			-- Masking messages
		once
			create {MASKING_MESSAGES} Result
		end

	numpad_correction (a_key_string: STRING_32): TUPLE [is_numpad: BOOLEAN; corrected: STRING_32]
			-- `a_key_string', corrected for NumPad keys
		local
			l_key_string, l_numpad_string: STRING_32
			l_is_numpad: BOOLEAN
		do
			l_key_string := a_key_string.twin
			l_numpad_string := "NumPad "
			if l_key_string.has_substring (l_numpad_string) and then l_key_string.count > l_numpad_string.count then
				l_is_numpad := True
				l_key_string.remove_substring (1, l_numpad_string.count)
			end
			Result := [l_is_numpad, l_key_string]
		end

feature {TEST_SET_BRIDGE} -- Test Mode

	is_test_mode: BOOLEAN
			-- Are we in test mode?
		do
			Result := is_test_mode_cache.item
		end

	is_test_mode_cache: CELL [BOOLEAN]
			-- Cell used to store system wide access to is_test_mode
		once
			create Result.put (False)
		end

	set_test_mode
			-- Report errors instead of raising an exception
		do
			is_test_mode_cache.put (True)
		end

	unset_test_mode
			-- Unset test mode, used for manual GUI testing which relies on querying actual values.
		do
			is_test_mode_cache.put (False)
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

note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"
	testing: "type/manual"

class
	INPUT_MASK_TEST_SET

inherit
	EXTENDED_TEST_SET
		redefine
			on_prepare
		end

	EV_KEY_CONSTANTS
		undefine
			default_create
		end

	NUMERIC_MASK_SPECIFIER
		undefine
			default_create
		end

feature -- Tests

	test_parse_modifier_line
			-- Test feature `parse_modifier_line' below
		note
			testing:  "execution/isolated"
		local
			l_result: ARRAY [STRING_32]
		do
			l_result := parse_modifier_line ("State,,,,,,,,,,,,s,s,s,s,s,s,s,s,s,s,s,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,cs,cs,cs,cs,cs,cs,cs")
			assert_strings_equal ("column 3", "", l_result [3])
			assert_strings_equal ("column 13", "s", l_result [13])
			assert_strings_equal ("column 25", "c", l_result [25])
			assert_strings_equal ("column 42", "cs", l_result [42])
		end

	test_parse_key_line
			-- Test feature `parse_key_line' below
		note
			testing:  "execution/isolated"
		local
			l_result: like parse_key_line
		do
			l_result := parse_key_line ("Before Keystroke,4,Numpad +,Numpad -,-,[<-],[->],[home],[end],[back],[delete],4,Numpad 4,= (+), Numpad +,Numpad -,[<-],[->],[home],[end],[back],[delete],4,c,x,v {},v {'4},v {4d},v {d},v {-4},v {4-4},v {4 4},v {4\r4},v {4\t4},[<-],[->],[home],[end],[back],[delete],4,[<-],[->],[home],[end],[back],[delete]")
			assert_equals ("key_column_2", key_4, l_result.keys [2].code)
			assert_strings_equal ("clipboard_column_2", "", l_result.clipboard_contents [2])
			assert_equals ("key_column_5", key_dash, l_result.keys [5].code)
			assert_strings_equal ("clipboard_column_5", "", l_result.clipboard_contents [5])
			assert_equals ("key_column_16", key_numpad_subtract, l_result.keys [16].code)
			assert_strings_equal ("clipboard_column_16", "", l_result.clipboard_contents [16])
			assert_equals ("key_column_28", key_v, l_result.keys [28].code)
			assert_strings_equal ("clipboard_column_28", "4d", l_result.clipboard_contents [28])
			assert_equals ("key_column_37", key_home, l_result.keys [37].code)
			assert_strings_equal ("clipboard_column_37", "", l_result.clipboard_contents [37])
		end

	test_parse_results_line
			-- Test feature `parse_results_line'
		note
			testing:  "execution/isolated"
		local
			l_result: like parse_results_line
		do
			l_result := parse_results_line ("33|3,%"3,34|3%",,-33|3,-33|3,3|33,333|,|333,333|,3|3,33|,,,,,-33|3,3|3!3,33!3|,|33!3,33!3|,3|3,33|,,,,,%"3,34|3%",%"3,34|3%",,%"3,34|3%",%"34,4|3%",%"34,4|3%",%"34,4|3%",%"34,4|3%",|333,333|,|333,333|,|3,33|,,|33!3,33!3|,|33!3,33!3|,|3,33|")
			assert_strings_equal ("column_1", "33|3", l_result [1])
			assert_strings_equal ("column_2", "3,34|3", l_result [2])
			assert ("column_3", not attached l_result [3])
			assert_strings_equal ("column_47", "33|", l_result [47])
			l_result := parse_results_line ("|-,-4|,|,|,|,,-|,,-|,,|,,,|,|,|,,!-|,,!-|,,|,,,,,-4|,-4|,,-4|,-44|,-44|,-44|,-44|,,-|,,-|,,|,,,!-|,,!-|,,|")
			assert_strings_equal ("column_15", "|", l_result [15])
		end

	test_adjusted_caret_and_start_selection
			-- Test `adjusted_caret_and_start_selection'
		note
			testing:  "execution/isolated"
		do
			assert_equals ("1_3_anchor", 1, adjusted_anchor_and_caret_positions (1, 3).anchor_position)
			assert_equals ("1_3_caret", 2, adjusted_anchor_and_caret_positions (1, 3).caret_position)
			assert_equals ("3_1_anchor", 2, adjusted_anchor_and_caret_positions (3, 1).anchor_position)
			assert_equals ("3_1_caret", 1, adjusted_anchor_and_caret_positions (3, 1).caret_position)
			assert_equals ("4_6_anchor", 4, adjusted_anchor_and_caret_positions (4, 6).anchor_position)
			assert_equals ("4_6_caret", 5, adjusted_anchor_and_caret_positions (4, 6).caret_position)
			assert_equals ("6_4_anchor", 5, adjusted_anchor_and_caret_positions (6, 4).anchor_position)
			assert_equals ("6_4_caret", 4, adjusted_anchor_and_caret_positions (6, 4).caret_position)
			assert_equals ("4_7_anchor", 4, adjusted_anchor_and_caret_positions (4, 7).anchor_position)
			assert_equals ("4_7_caret", 6, adjusted_anchor_and_caret_positions (4, 7).caret_position)
			assert_equals ("7_4_anchor", 6, adjusted_anchor_and_caret_positions (7, 4).anchor_position)
			assert_equals ("7_4_caret", 4, adjusted_anchor_and_caret_positions (7, 4).caret_position)
		end

	test_digit_count
			-- Test NUMERIC_VALUE_INPUT_MASK.digit_count
		note
			testing:  "execution/isolated"
		local
			l_mask: INTEGER_VALUE_INPUT_MASK
			l_result: like {INTEGER_VALUE_INPUT_MASK}.digit_count
		do
			create l_mask.make (10)
			l_result := l_mask.digit_count ("3")
			assert_equals ("integer_1", 1, l_result.integer)
			assert_equals ("decimal_1", 0, l_result.decimal)
			l_result := l_mask.digit_count ("33.333")
			assert_equals ("integer_2", 2, l_result.integer)
			assert_equals ("decimal_2", 3, l_result.decimal)
			l_result := l_mask.digit_count ("333.")
			assert_equals ("integer_3", 3, l_result.integer)
			assert_equals ("decimal_3", 0, l_result.decimal)
		end

	test_numpad_correction
			-- Test NUMERIC_VALUE_INPUT_MASK.numpad_correction
		note
			testing:  "execution/isolated"
		local
			l_mask: INTEGER_VALUE_INPUT_MASK
			l_result: like {INTEGER_VALUE_INPUT_MASK}.numpad_correction
		do
			create l_mask.make (10)
			l_result := l_mask.numpad_correction (key_strings.item (key_3))
			assert ("is_numpad_1", not l_result.is_numpad)
			assert_strings_equal ("correction_1", "3", l_result.corrected)
			l_result := l_mask.numpad_correction (key_strings.item (key_numpad_3))
			assert ("is_numpad_2", l_result.is_numpad)
			assert_strings_equal ("correction_2", "3", l_result.corrected)
			l_result := l_mask.numpad_correction (key_strings.item (key_period))
			assert ("is_numpad_3", not l_result.is_numpad)
			assert_strings_equal ("correction_3", ".", l_result.corrected)
			l_result := l_mask.numpad_correction (key_strings.item (key_numpad_decimal))
			assert ("is_numpad_4", l_result.is_numpad)
			assert_strings_equal ("correction_4", ".", l_result.corrected)
		end

	test_context_menu_setup
			-- Test INPUT_MASK.setup_context_menu
		note
			testing:  "execution/isolated"
		local
			l_widget: EV_TEXT
			l_mask: STRING_VALUE_INPUT_MASK
		do
			create l_widget
			create l_mask.make ("!")
			assert ("no_configurable_target_menu_handler", l_widget.configurable_target_menu_handler = Void)
			l_mask.add_text_widget (l_widget)
			assert ("is_menu_mode", l_widget.mode_is_configurable_target_menu)
			assert ("has_configurable_target_menu_handler", l_widget.configurable_target_menu_handler /= Void)
		end

	test_context_menu
			-- Test INPUT_MASK.target_menu_handler
		note
			testing:  "execution/isolated", "execution/serial/masking"
		local
			l_widget: EV_TEXT
			l_mask: STRING_VALUE_INPUT_MASK
			l_menu, l_source: EV_MENU
			l_list: ARRAYED_LIST [EV_PND_TARGET_DATA]
		do
			create l_widget
			create l_mask.make_repeating ("!")
			create l_list.make (0)
			create l_menu
			create l_source
			--| is_empty: False
			--| has_selection: True
			--| is_editable: True
			--| Clipboard: Empty
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.enable_edit
			test_application.clipboard.set_text ("")
			assert_equals ("menu_empty", 0, l_menu.count)
			assert ("clipboard_empty_1", test_application.clipboard.text.is_empty)
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("1a", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_1", l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_1", l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_1", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_1", l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_1", l_menu.i_th (5).is_sensitive)
			l_menu.i_th (1).select_actions.call (Void)
			assert_strings_equal ("after_cut_1", "AA", l_widget.text)
			assert_strings_equal ("clipboard_after_cut_1", "AA", test_application.clipboard.text)
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.enable_edit
			test_application.clipboard.set_text ("")
			l_menu.i_th (2).select_actions.call (Void)
			assert_strings_equal ("after_copy_1", "AAAA", l_widget.text)
			assert_strings_equal ("clipboard_after_copy_1", "AA", test_application.clipboard.text)
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.enable_edit
			test_application.clipboard.set_text ("")
			l_menu.i_th (4).select_actions.call (Void)
			assert_strings_equal ("after_delete_1", "AA", l_widget.text)
			assert_strings_equal ("clipboard_after_delete_1", "", test_application.clipboard.text)
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.enable_edit
			test_application.clipboard.set_text ("")
			l_menu.i_th (5).select_actions.call (Void)
			assert_strings_equal ("after_select_all_1", "AAAA", l_widget.text)
			assert_strings_equal ("selection_after_select_all_1", "AAAA", l_widget.selected_text)
			assert_strings_equal ("clipboard_after_select_all_1", "", test_application.clipboard.text)
			--| Clipboard: With Text
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.enable_edit
			test_application.clipboard.set_text ("BB")
			assert ("not_clipboard_empty_1", not test_application.clipboard.text.is_empty)
			create l_menu
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("2b", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_2", l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_2", l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_2", l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_2", l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_2", l_menu.i_th (5).is_sensitive)
			l_menu.i_th (3).select_actions.call (Void)
			assert_strings_equal ("after_paste_with_clipboard_1", "ABBA", l_widget.text)
			assert_strings_equal ("clipboard_after_paste_all_with_clipboard_1", "BB", test_application.clipboard.text)
			--| is_empty: False
			--| has_selection: False
			--| is_editable: True
			--| Clipboard: Empty
			create l_menu
			l_widget.set_text ("AAAA")
			l_widget.set_caret_position (2)
			l_widget.enable_edit
			test_application.clipboard.set_text ("")
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("2a", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_2", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_2", not l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_2", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_2", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_2", l_menu.i_th (5).is_sensitive)
			l_menu.i_th (5).select_actions.call (Void)
			assert_strings_equal ("after_select_all_2", "AAAA", l_widget.text)
			assert_strings_equal ("selection_after_select_all_2", "AAAA", l_widget.selected_text)
			assert_strings_equal ("clipboard_after_select_all_2", "", test_application.clipboard.text)
			--| Clipboard: With Text
			l_widget.set_text ("AAAA")
			l_widget.set_caret_position (2)
			l_widget.enable_edit
			test_application.clipboard.set_text ("BB")
			assert ("not_clipboard_empty_2", not test_application.clipboard.text.is_empty)
			create l_menu
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("2b", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_2", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_2", not l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_2", l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_2", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_2", l_menu.i_th (5).is_sensitive)
			l_menu.i_th (3).select_actions.call (Void)
			assert_strings_equal ("after_paste_with_clipboard_2", "ABBAAA", l_widget.text)
			assert_strings_equal ("clipboard_after_paste_all_with_clipboard_2", "BB", test_application.clipboard.text)
			--| is_empty: False
			--| has_selection: False
			--| is_editable: False
			--| Clipboard: Empty
			create l_menu
			l_widget.set_text ("AAAA")
			l_widget.set_caret_position (2)
			l_widget.disable_edit
			test_application.clipboard.set_text ("")
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("3a", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_3", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_3", not l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_3", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_3", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_3", l_menu.i_th (5).is_sensitive)
			l_menu.i_th (5).select_actions.call (Void)
			assert_strings_equal ("after_select_all_3", "AAAA", l_widget.text)
			assert_strings_equal ("selection_after_select_all_3", "AAAA", l_widget.selected_text)
			assert_strings_equal ("clipboard_after_select_all_3", "", test_application.clipboard.text)
			--| Clipboard: With Text
			l_widget.set_text ("AAAA")
			l_widget.set_caret_position (2)
			l_widget.disable_edit
			test_application.clipboard.set_text ("BB")
			assert ("not_clipboard_empty_3", not test_application.clipboard.text.is_empty)
			create l_menu
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("3b", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_3", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_3", not l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_3", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_3", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_3", l_menu.i_th (5).is_sensitive)
			--| is_empty: True
			--| has_selection: False
			--| is_editable: False
			--| Clipboard: Empty
			create l_menu
			l_widget.set_text ("")
			l_widget.disable_edit
			test_application.clipboard.set_text ("")
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("4a", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_4", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_4", not l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_4", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_4", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_4", not l_menu.i_th (5).is_sensitive)
			--| Clipboard: With Text
			l_widget.set_text ("")
			l_widget.disable_edit
			test_application.clipboard.set_text ("BB")
			assert ("not_clipboard_empty_4", not test_application.clipboard.text.is_empty)
			create l_menu
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("4b", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_4", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_4", not l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_4", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_4", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_4", not l_menu.i_th (5).is_sensitive)
			--| is_empty: False
			--| has_selection: True
			--| is_editable: False
			--| Clipboard: Empty
			create l_menu
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.disable_edit
			test_application.clipboard.set_text ("")
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("5a", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_5", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_5", l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_5", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_5", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_5", l_menu.i_th (5).is_sensitive)
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.enable_edit
			test_application.clipboard.set_text ("")
			l_menu.i_th (2).select_actions.call (Void)
			assert_strings_equal ("after_copy_5", "AAAA", l_widget.text)
			assert_strings_equal ("clipboard_after_copy_5", "AA", test_application.clipboard.text)
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.enable_edit
			test_application.clipboard.set_text ("")
			l_menu.i_th (5).select_actions.call (Void)
			assert_strings_equal ("after_select_all_5", "AAAA", l_widget.text)
			assert_strings_equal ("selection_after_select_all_5", "AAAA", l_widget.selected_text)
			assert_strings_equal ("clipboard_after_select_all_5", "", test_application.clipboard.text)
			--| Clipboard: With Text
			l_widget.set_text ("AAAA")
			l_widget.set_selection (2, 4)
			l_widget.disable_edit
			test_application.clipboard.set_text ("BB")
			assert ("not_clipboard_empty_5", not test_application.clipboard.text.is_empty)
			create l_menu
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("5b", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_5", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_5", l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_5", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_5", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_5", l_menu.i_th (5).is_sensitive)
			--| is_empty: True
			--| has_selection: False
			--| is_editable: True
			--| Clipboard: Empty
			create l_menu
			l_widget.set_text ("")
			l_widget.enable_edit
			test_application.clipboard.set_text ("")
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("6a", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_6", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_6", not l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_6", not l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_6", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_6", not l_menu.i_th (5).is_sensitive)
			--| Clipboard: With Text
			l_widget.set_text ("")
			l_widget.enable_edit
			test_application.clipboard.set_text ("BB")
			assert ("not_clipboard_empty_6", not test_application.clipboard.text.is_empty)
			create l_menu
			l_mask.target_menu_handler (l_widget, l_menu, l_list, l_source, Void)
			context_menu_assertions ("6b", l_menu, l_mask.masking_messages)
			assert ("item_1_sensitivity_6", not l_menu.i_th (1).is_sensitive)
			assert ("item_2_sensitivity_6", not l_menu.i_th (2).is_sensitive)
			assert ("item_3_sensitivity_6", l_menu.i_th (3).is_sensitive)
			assert ("item_4_sensitivity_6", not l_menu.i_th (4).is_sensitive)
			assert ("item_5_sensitivity_6", not l_menu.i_th (5).is_sensitive)
			l_menu.i_th (3).select_actions.call (Void)
			assert_strings_equal ("after_paste_with_clipboard_6", "BB", l_widget.text)
			assert_strings_equal ("clipboard_after_paste_all_with_clipboard_6", "BB", test_application.clipboard.text)
		end

	test_mask_target_related_features
			-- Test INPUT_MASK.has_mask_target, INPUT_MASK.is_targeted_at_mask, INPUT_MASK.remove_masking_event_handlers_from_list
		note
			testing:  "execution/isolated"
		local
			l_list: ARRAYED_LIST [ROUTINE [ANY, detachable TUPLE]]
			l_mask: DECIMAL_VALUE_INPUT_MASK
		do
			create l_list.make (3)
			create l_mask.make (5, 10)
			assert ("not_targeted_at_mask", not l_mask.is_targeted_at_mask (agent l_list.do_nothing))
			assert ("targeted_at_mask", l_mask.is_targeted_at_mask (agent l_mask.do_nothing))
			l_list.extend (agent do_nothing)
			assert ("not_has_mask_target", not l_mask.has_mask_target (l_list))
			l_list.extend (agent l_mask.do_nothing)
			assert ("has_mask_target", l_mask.has_mask_target (l_list))
			l_mask.remove_masking_event_handlers_from_list (l_list)
			assert_equals ("one_agent_left", 1, l_list.count)
		end

	test_fits_in_mask
			-- Test NUMERIC_VALUE_INPUT_MASK.fits_in_mask
		note
			testing:  "execution/isolated"
		local
			l_integer_mask: INTEGER_VALUE_INPUT_MASK
			l_decimal_mask: DECIMAL_VALUE_INPUT_MASK
		do
			create l_integer_mask.make (6)
			assert ("integer_mask_fits_1", l_integer_mask.fits_in_mask ("4"))
			assert ("integer_mask_fits_2", l_integer_mask.fits_in_mask ("444"))
			assert ("integer_mask_fits_3", l_integer_mask.fits_in_mask ("4,444"))
			assert ("integer_mask_fits_4", l_integer_mask.fits_in_mask ("444,444"))
			assert ("integer_mask_fits_5", not l_integer_mask.fits_in_mask ("4,444,444"))
			assert ("integer_mask_fits_6", not l_integer_mask.fits_in_mask ("444,444,444"))
			create l_decimal_mask.make (4, 6)
			assert ("decimal_mask_fits_1", l_decimal_mask.fits_in_mask ("4.0000"))
			assert ("decimal_mask_fits_2", not l_decimal_mask.fits_in_mask ("4.00000"))
			assert ("decimal_mask_fits_3", l_decimal_mask.fits_in_mask ("444.0000"))
			assert ("decimal_mask_fits_4", not l_decimal_mask.fits_in_mask ("444.00000"))
			assert ("decimal_mask_fits_5", l_decimal_mask.fits_in_mask ("4,444.0000"))
			assert ("decimal_mask_fits_6", not l_decimal_mask.fits_in_mask ("4,444.00000"))
			assert ("decimal_mask_fits_7", l_decimal_mask.fits_in_mask ("444,444.0000"))
			assert ("decimal_mask_fits_8", not l_decimal_mask.fits_in_mask ("444,444.00000"))
			assert ("decimal_mask_fits_9", not l_decimal_mask.fits_in_mask ("4,444,444.0000"))
			assert ("decimal_mask_fits_10", not l_decimal_mask.fits_in_mask ("4,444,444.00000"))
			assert ("decimal_mask_fits_11", not l_decimal_mask.fits_in_mask ("444,444,444.0000"))
			assert ("decimal_mask_fits_12", not l_decimal_mask.fits_in_mask ("444,444,444.00000"))
		end

feature {NONE} -- Widget test with application loop (manual, export to ANY to run in autotest)

	context_menu_assertions (a_suffix: STRING_32; a_menu: EV_MENU; a_messages: ABSTRACT_MASKING_MESSAGES)
			-- Verify basic setup of `a_menu'
		do
			assert_equals ("item_count_" + a_suffix, 5, a_menu.count)
			assert_strings_equal ("item_1_text_" + a_suffix, a_messages.cut_message, a_menu.i_th (1).text)
			assert_strings_equal ("item_2_text_" + a_suffix, a_messages.copy_message, a_menu.i_th (2).text)
			assert_strings_equal ("item_3_text_" + a_suffix, a_messages.paste_message, a_menu.i_th (3).text)
			assert_strings_equal ("item_4_text_" + a_suffix, a_messages.delete_message, a_menu.i_th (4).text)
			assert_strings_equal ("item_5_text_" + a_suffix, a_messages.select_all_message, a_menu.i_th (5).text)
		end


	numeric_mask_keystroke_test_lookup_key (a_modifiers: STRING_32; a_key: EV_KEY; a_widget_text_before, a_clipboard_contents_before: STRING_32): STRING_32
			-- Create key used to lookup test results
		do
			Result := a_key.text + ":" + a_modifiers + ":" + a_widget_text_before + ":" + a_clipboard_contents_before
		end

feature {NONE} -- Implementation

	test_application: TEST_APPLICATION
			-- A test application
		do
			if attached internal_test_application as al_application then
				Result := al_application
			else
				create Result
				internal_test_application := Result
			end
		end

	internal_test_application: detachable like test_application
			-- Internal `test_application' for once-per-object pattern.

	on_prepare
			-- <Precursor>
		do
			Precursor;
			(create {STRING_VALUE_INPUT_MASK}.make_repeating ("X")).set_test_mode
				--| Touch this once before tests need it.
			test_application.sleep (1)
		end

	test_mask (a_file: PLAIN_TEXT_FILE; a_mask: INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]; a_keys: ARRAYED_LIST [EV_KEY])
			-- Test `a_mask' using specification in `a_file' against `a_keys'
		local
			l_mask: INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]
			l_results: HASH_TABLE [detachable STRING_32, STRING_32]
			l_tests, l_clipboard_contents: ARRAYED_LIST [STRING_32]
			l_widget: EV_TEXT_COMPONENT
			l_file_contents: like parse_specification_file
			l_file: PLAIN_TEXT_FILE
			l_all_modifiers: like valid_modifiers
			l_window: EV_TITLED_WINDOW
			l_assertion_prefix: STRING_32
		do
			if attached a_file.path as al_path and then attached al_path.entry as al_entry then
				l_assertion_prefix := al_entry.name.twin
			else
				l_assertion_prefix := "no_file_"
			end
			create l_window
			l_window.set_height (300)
			l_window.set_width (300)
			l_file := a_file
			l_mask := a_mask
			l_file_contents := parse_specification_file (l_file)
			l_results := l_file_contents.results
			across l_results.linear_representation as ic_results loop
				if attached ic_results.item as al_item and then not is_valid_widget_text_specification (al_item) then
					print (l_assertion_prefix + " Invalid mask specification: " + al_item + "%N")
					assert (l_assertion_prefix + "_mask_specification", False)
				end
			end
			l_tests := l_file_contents.tests
			create {EV_TEXT} l_widget
			l_window.extend (l_widget)
			create l_all_modifiers.make_filled ("", 1, valid_modifiers.count + 1)
			across valid_modifiers as ic_modifiers loop
				l_all_modifiers [ic_modifiers.cursor_index + 1] := ic_modifiers.item
			end
			across a_keys as ic_keys loop
				across l_all_modifiers as ic_modifiers loop
					across l_tests as ic_tests loop
						l_window.show
						l_window.raise
						l_widget.show
						l_widget.set_focus
						if ic_keys.item.code = key_v and then ic_modifiers.item.same_string ("c") then
							create l_clipboard_contents.make (10)
							across l_file_contents.clipboard_contents as ic_clipboard_contents_specification loop
								if not ic_clipboard_contents_specification.item.is_empty then
									l_clipboard_contents.extend (ic_clipboard_contents_specification.item)
								end
							end
						else
							create l_clipboard_contents.make (0)
							l_clipboard_contents.extend ("")
						end
						across l_clipboard_contents as ic_clipboard_contents loop
							test_key_press (l_assertion_prefix, l_mask, l_widget, ic_modifiers.item, ic_keys.item, ic_tests.item, ic_clipboard_contents.item, l_results)
						end
					end
				end
			end
		end

	is_valid_numeric_start_state (a_start_state: STRING): BOOLEAN
			-- Is `a_start_state' valid for use in `test_numeric_mask'?
		do
			Result := a_start_state.occurrences ('|') = 1
			Result := Result and 	across a_start_state as ic_start_state all
										(not ic_start_state.item.is_digit implies true) and (ic_start_state.item.is_digit implies ic_start_state.item = '3')
									end
		ensure
			result_implies_one_pipe_symbol: Result implies a_start_state.occurrences ('|') = 1
		end

	test_key_press (a_prefix: STRING_32; a_mask: INPUT_MASK [ANY, DATA_COLUMN_METADATA [ANY]]; a_widget: EV_TEXT_COMPONENT; a_modifiers: STRING_32; a_key: EV_KEY; a_widget_text_before, a_clipboard_text_before: STRING_32; a_results: HASH_TABLE [detachable STRING_32, STRING_32])
		require
			valid_a_widget_text_before: is_valid_widget_text_specification (a_widget_text_before)
			results_object_comparison: a_results.object_comparison
			a_widget.has_focus
			-- `a_widget' must be displayed on the screen
		local
			l_start_caret_position, l_expected_caret_position: INTEGER
			l_start_anchor_position, l_expected_anchor_position, l_actual_anchor_position: INTEGER
			l_expected_value, l_start_value, l_modifier_key_tag, l_selected_text, l_clipboard_label: STRING_32
			l_test_app: EV_APPLICATION
			l_expected_selection: detachable STRING_32
			l_adjusted_values, l_adjusted_expected_values: like adjusted_anchor_and_caret_positions
		do
			l_test_app := a_mask.ev_application
			-- Get Starting Value
			l_start_value := a_widget_text_before.twin
			l_start_caret_position := l_start_value.index_of (caret_character, 1)
			l_start_anchor_position := l_start_value.index_of (anchor_character, 1)
			if l_start_anchor_position > 0 then
				l_selected_text := l_start_value.substring (l_start_caret_position.min (l_start_anchor_position) + 1, l_start_caret_position.max (l_start_anchor_position) - 1)
			else
				l_selected_text := ""
			end
			-- Adjust Anchor and Caret Positions
			l_adjusted_values := adjusted_anchor_and_caret_positions (l_start_anchor_position, l_start_caret_position)
			l_start_caret_position := l_adjusted_values.caret_position
			l_start_anchor_position := l_adjusted_values.anchor_position
			-- Define expected value
			if attached a_results.item (numeric_mask_keystroke_test_lookup_key (a_modifiers, a_key, a_widget_text_before, a_clipboard_text_before)) as al_result then
				l_expected_value := al_result.twin
			else
				l_expected_value := l_start_value.twin
			end
			-- Prepare the start value for use (remove the specification characters)
			l_start_value.prune_all (caret_character)
			l_start_value.prune_all (anchor_character)
			-- Define expected value, caret and anchor positions
			l_expected_caret_position := l_expected_value.index_of (caret_character, 1)
			l_expected_anchor_position := l_expected_value.index_of (anchor_character, 1)
			if l_expected_anchor_position > 0 then
				l_expected_selection := l_expected_value.substring (l_expected_caret_position.min (l_expected_anchor_position) + 1, l_expected_caret_position.max (l_expected_anchor_position) - 1)
			else
				l_expected_selection := Void
			end
			l_adjusted_expected_values := adjusted_anchor_and_caret_positions (l_expected_anchor_position, l_expected_caret_position)
			l_expected_caret_position := l_adjusted_expected_values.caret_position
			l_expected_anchor_position := l_adjusted_expected_values.anchor_position
			l_expected_value.prune_all (caret_character)
			l_expected_value.prune_all (anchor_character)
			a_widget.set_text (l_start_value)
			a_widget.set_caret_position (l_start_caret_position)

			if l_start_anchor_position > 0 then
				a_widget.set_selection (l_start_anchor_position, l_start_caret_position)
			end
			check
				caret_position: a_widget.caret_position = l_start_caret_position
			end
			check
				selection_correct: a_widget.has_selection implies l_selected_text.same_string (a_widget.selected_text)
			end

			if attached {TEST_APPLICATION} a_mask.ev_application as al_application then
				al_application.set_is_shift_key_pressed (False)
				al_application.set_is_control_key_pressed (False)
				al_application.set_is_alt_key_pressed (False)
				if a_modifiers.has ('s') then
					al_application.set_is_shift_key_pressed (True)
				end
				if a_modifiers.has ('c') then
					al_application.set_is_control_key_pressed (True)
				end
				al_application.clipboard.set_text (a_clipboard_text_before)
			else
				check false end
			end
			a_mask.ev_application.clipboard.set_text (a_clipboard_text_before)
			-- Execute code under test
			if a_key.code = key_backquote and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("~", a_widget)
			elseif a_key.code = Key_1 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("!", a_widget)
			elseif a_key.code = Key_2 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("@", a_widget)
			elseif a_key.code = Key_3 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("#", a_widget)
			elseif a_key.code = Key_3 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("#", a_widget)
			elseif a_key.code = Key_4 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("$", a_widget)
			elseif a_key.code = Key_5 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("%%", a_widget)
			elseif a_key.code = Key_6 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("^", a_widget)
			elseif a_key.code = Key_7 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("&", a_widget)
			elseif a_key.code = Key_8 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("*", a_widget)
			elseif a_key.code = Key_9 and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("(", a_widget)
			elseif a_key.code = Key_0 and then l_test_app.shift_pressed then
				a_mask.handle_key_string (")", a_widget)
			elseif a_key.code = key_dash and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("_", a_widget)
			elseif a_key.code = key_equal and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("+", a_widget)
			elseif a_key.code = key_open_bracket and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("{", a_widget)
			elseif a_key.code = key_close_bracket and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("}", a_widget)
			elseif a_key.code = key_backslash and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("|", a_widget)
			elseif a_key.code = key_semicolon and then l_test_app.shift_pressed then
				a_mask.handle_key_string (":", a_widget)
			elseif a_key.code = key_quote and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("%"", a_widget)
			elseif a_key.code = key_comma and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("<", a_widget)
			elseif a_key.code = key_period and then l_test_app.shift_pressed then
				a_mask.handle_key_string (">", a_widget)
			elseif a_key.code = key_slash and then l_test_app.shift_pressed then
				a_mask.handle_key_string ("?", a_widget)
			elseif a_key.code = key_tab then
				a_mask.handle_key_string ("%T", a_widget)
			elseif a_key.is_alpha and then l_test_app.shift_pressed then
				a_mask.handle_key_string (key_strings.item (a_key.code).twin.as_upper, a_widget)
			elseif a_key.is_printable and not l_test_app.ctrl_pressed then
				a_mask.handle_key_string (key_strings.item (a_key.code), a_widget)
			else
				a_mask.handle_key_press (a_key, a_widget)
			end
			-- Obtain actual values and perform assertions
			if a_widget.has_selection then
				if a_widget.start_selection = a_widget.caret_position then
					l_actual_anchor_position := a_widget.end_selection
				else
					l_actual_anchor_position := a_widget.start_selection
				end
			end
			l_modifier_key_tag := ""
			if l_test_app.shift_pressed then
				l_modifier_key_tag.append ("_shift")
			end
			if l_test_app.ctrl_pressed then
				l_modifier_key_tag.append ("_control")
			end
			l_clipboard_label := a_clipboard_text_before.twin
			if not l_clipboard_label.is_empty then
				l_clipboard_label.prepend ("_clipboard_")
			end
			assert_strings_equal (a_prefix + "_start_state_" + a_widget_text_before + "_value_for" + l_modifier_key_tag + "_key_" + key_strings.item (a_key.code) + l_clipboard_label, l_expected_value, a_widget.text)
			if attached l_expected_selection then
				assert (a_prefix + "_start_state_" + a_widget_text_before + "_has_selection_text_for" + l_modifier_key_tag + "_key_" + key_strings.item (a_key.code) + l_clipboard_label, a_widget.has_selection)
				assert_strings_equal (a_prefix + "_start_state_" + a_widget_text_before + "_selected_text_for" + l_modifier_key_tag + "_key_" + key_strings.item (a_key.code) + l_clipboard_label, l_expected_selection, a_widget.selected_text)
				assert_equals (a_prefix + "_start_state_" + a_widget_text_before + "_anchor_position_for" + l_modifier_key_tag + "_key_" + key_strings.item (a_key.code) + l_clipboard_label, l_expected_anchor_position, l_actual_anchor_position)
				assert_equals (a_prefix + "_start_state_" + a_widget_text_before + "_end_selection_for" + l_modifier_key_tag + "_key_" + key_strings.item (a_key.code) + l_clipboard_label, l_expected_caret_position, a_widget.caret_position)
			else
				assert (a_prefix + "_start_state_" + a_widget_text_before + "_no_selected_text_for" + l_modifier_key_tag + "_key_" + key_strings.item (a_key.code) + l_clipboard_label, not a_widget.has_selection)
			end
			assert_equals (a_prefix + "_start_state_" + a_widget_text_before + "_caret_position_for" + l_modifier_key_tag + "_key_" + key_strings.item (a_key.code) + l_clipboard_label, l_expected_caret_position, a_widget.caret_position)
			if ((a_key.code = key_c) or (a_key.code = key_x)) and then (l_test_app.ctrl_pressed and then not l_test_app.shift_pressed and then not l_test_app.alt_pressed) and then not l_selected_text.is_empty then
				assert_strings_equal (a_prefix + "_start_state_" + a_widget_text_before + "_clipboard_contents_for_" + l_modifier_key_tag + "_key_" + key_strings.item (a_key.code) + l_clipboard_label, l_selected_text, l_test_app.clipboard.text)
			end
		end

	adjusted_anchor_and_caret_positions (a_anchor_position, a_caret_position: INTEGER): TUPLE [anchor_position: INTEGER; caret_position: INTEGER]
			-- Adjust `a_anchor_position' and `a_caret_position' as defined in a specification string to their corresponding positions within a widget
			--| i.e. The positions within a specification (e.g. the bang and pipe chars in 3!3|3) must be translated from their character indexes
			--| into the corresponding anchor and caret positions within a text widget which does not include the bang and bar characters
			--| The bang is the anchor and the pipe is the caret.
		require
			valid_anchor_position: a_anchor_position /= a_caret_position
			valid_caret_position: a_caret_position > 0
		local
			l_anchor_position, l_caret_position: INTEGER
		do
			l_anchor_position := a_anchor_position
			l_caret_position := a_caret_position
			if l_caret_position < l_anchor_position then
				l_anchor_position := l_anchor_position - 1
			elseif l_anchor_position > 0 then
				l_caret_position := l_caret_position - 1
			end
			Result := [l_anchor_position, l_caret_position]
		end

	parse_specification_file (a_file: PLAIN_TEXT_FILE): TUPLE [results: HASH_TABLE [detachable STRING_32, STRING_32]; tests: ARRAYED_LIST [STRING_32]; clipboard_contents: ARRAYED_LIST [STRING_32]]
		require
			open_read: a_file.is_open_read
		local
			l_results: HASH_TABLE [detachable STRING_32, STRING_32]
			l_tests, l_clipboard_contents: ARRAYED_LIST [STRING_32]
			l_key_line: like parse_key_line
			l_results_line: like parse_results_line
			l_modifiers: ARRAY [STRING_32]
			l_before_text: detachable STRING_32
		do
--| Contents of `a_file' Must Conform To Following Format
--| Line 1: Ignored (contains headers used only by spread editors)
--| Line 2: Must conform to format as described in feature `parse_modifier_line'
--| Line 3: Must conform to format as described in feature `parse_key_line'
--| Line 4+: Must conform to format as described in feature `parse_specification_line'
			a_file.start
			a_file.readline
			-- Throw away line 1
			a_file.readline
			l_modifiers := parse_modifier_line (a_file.last_string)
			a_file.readline
			l_key_line := parse_key_line (a_file.last_string)
			check
				l_key_line_consistent: l_key_line.keys.count = l_key_line.clipboard_contents.count
			end
			check
				--| The current design of `test_mask' only supports specifying clipboard contents for tests of ctrl-v
				clipboard_specified_only_for_ctrl_v: across l_key_line.keys as ic_keys all (not l_key_line.clipboard_contents.item (ic_keys.cursor_index + l_key_line.clipboard_contents.lower - 1).is_empty) implies ((ic_keys.item.code = key_v) and then l_modifiers.item (ic_keys.cursor_index + l_key_line.clipboard_contents.lower - 1).same_string ("c")) end
			end
			create l_results.make (4000)
			l_results.compare_objects
			create l_tests.make (200)
			l_tests.compare_objects
			create l_clipboard_contents.make_from_array (l_key_line.clipboard_contents)
			l_clipboard_contents.compare_objects
			from
			until
				a_file.end_of_file
			loop
				a_file.read_line
				l_results_line := parse_results_line (a_file.last_string)
				if l_results_line.count = l_clipboard_contents.count + 1 then
					l_before_text := Void
					across l_results_line as ic_results loop
						if ic_results.cursor_index = 1 then
							l_before_text := ic_results.item
							if attached l_before_text and then (l_before_text.count > 1 implies not l_before_text.substring (1, 2).same_string ("\\")) then
								l_tests.extend (l_before_text)
							end
						elseif attached l_before_text then
							l_results.put (ic_results.item, numeric_mask_keystroke_test_lookup_key (l_modifiers [ic_results.cursor_index], l_key_line.keys [ic_results.cursor_index], l_before_text, l_clipboard_contents [ic_results.cursor_index - 1]))
						end
					end
				end
			end
			Result := [l_results, l_tests, l_clipboard_contents]
		end

	parse_modifier_line (a_line: STRING_32): ARRAY [STRING_32]
			-- Parse the modifier line from a numeric mask specification file
			-- Index in array corresponds to column number in spreadsheet (starts at column 2; as colum one is a label column)
			--| This line must contain one column for each column defined in the specification lines (lines 4+ in the spreadsheet)
			--| This line must contain only empty values or valid modifier strings as defined in `is_valid_modifier'
			--| This feature will not work if modifiers contain embedded " characters
		local
			l_modifiers: LIST [STRING_32]
			l_modifier: STRING_32
		do
			create result.make_filled ("", 2, 201)
			l_modifiers := a_line.split (',')
			across l_modifiers as ic_modifiers loop
				if ic_modifiers.cursor_index > 1 then
					l_modifier := ic_modifiers.item.twin
					check
						valid_modifier: not l_modifier.is_empty implies is_valid_modifier (l_modifier)
					end
					Result [ic_modifiers.cursor_index] := l_modifier
				end
			end
		end

	parse_key_line (a_line: STRING_32): TUPLE [keys: ARRAY [EV_KEY]; clipboard_contents: ARRAY [STRING_32]]
			-- Parse the key line from a numeric mask specification file
			-- Index in array corresponds to column number in spreadsheet (starts at column 2; as colum one is a label column)
			--| This line must contain one column for each column defined in the specification lines (lines 4+ in the spreadsheet)
			--| Entries in this line must be contained in `keys_by_specification_string'
			--| All text after a `(' character (and any preceeding whitespace) is ignored as a comment
			--| Clipboard contents is specified by enclosing the contents with {}
			--| This feature does not support specificying behavior for the `,' character or the `"' character
		local
			l_keys: ARRAY [EV_KEY]
			l_clipboard_contents: ARRAY [STRING_32]
			l_entries: LIST [STRING_32]
			l_entry, l_clipboard_contents_entry: STRING_32
			l_open_paren_index: INTEGER
			l_open_bracket_index, l_close_bracket_index: INTEGER
		do
			l_entries := a_line.split (',')
			create l_keys.make_filled (create {EV_KEY}, 2, l_entries.count)
			create l_clipboard_contents.make_filled ("", 2, l_entries.count)
			across l_entries as ic_entries loop
				if ic_entries.cursor_index > 1 then
					l_entry := ic_entries.item.twin
					l_entry.left_adjust
					l_open_paren_index := l_entry.index_of ('(', 1)
					if l_open_paren_index > 0 then
						l_entry.keep_head (l_open_paren_index - 1)
						l_entry.right_adjust
					end
					l_open_bracket_index := l_entry.index_of ('{', 1)
					if l_open_bracket_index > 0 then
						l_close_bracket_index := l_entry.index_of ('}', l_open_bracket_index)
						check
							has_closing_bracket: l_close_bracket_index > 0
						end
						l_clipboard_contents_entry := l_entry.substring (l_open_bracket_index + 1, l_close_bracket_index - 1)
						l_entry.keep_head (l_open_bracket_index - 1)
						l_entry.right_adjust
					else
						l_clipboard_contents_entry := ""
					end
					check
						keys_by_specification_string_has_entry: attached keys_by_specification_string.item (l_entry) as al_key
					then
						l_keys.put (al_key, ic_entries.cursor_index)
					end
					l_clipboard_contents.put (l_clipboard_contents_entry, ic_entries.cursor_index)
				end
			end
			Result := [l_keys, l_clipboard_contents]
		end

	parse_results_line (a_line: STRING): ARRAY [detachable STRING_32]
			-- Parse lines 4+ of a numeric mask specification file
			--| Entries may not contain embedded " characters
			--| Merge results columns of label rows to indicate they should be ignored
		local
			l_is_in_quote: BOOLEAN
			l_character: CHARACTER_32
			l_result: ARRAYED_LIST [detachable STRING_32]
			l_entry: STRING_32
		do
			a_line.replace_substring_all (create {STRING_32}.make_filled ('%%', 2), create {STRING_32}.make_filled ('%%', 1))
			create l_result.make (10)
			l_entry := ""
			across a_line as ic_line loop
				l_character := ic_line.item
				inspect
					l_character
				when '"' then
					l_is_in_quote := not l_is_in_quote
				when ',' then
					if l_is_in_quote then
						l_entry.extend (l_character)
					elseif l_entry.is_empty then
						l_result.extend (Void)
					else
						l_result.extend (l_entry)
						l_entry := ""
					end
				else
					l_entry.extend (l_character)
				end
			end
			if l_entry.is_empty then
				l_result.extend (Void)
			else
				l_result.extend (l_entry)
			end
			Result := l_result.to_array
		end

	keys_by_specification_string: HASH_TABLE [EV_KEY, STRING_32]
			-- EV_KEY objects indexed by the string used to identify them in the specification spreadsheet
		once
			create Result.make (20)
			result.compare_objects
			result.force (create {EV_KEY}.make_with_code (key_1), "1")
			result.force (create {EV_KEY}.make_with_code (key_2), "2")
			result.force (create {EV_KEY}.make_with_code (key_3), "3")
			result.force (create {EV_KEY}.make_with_code (key_4), "4")
			result.force (create {EV_KEY}.make_with_code (key_5), "5")
			result.force (create {EV_KEY}.make_with_code (key_6), "6")
			result.force (create {EV_KEY}.make_with_code (key_7), "7")
			result.force (create {EV_KEY}.make_with_code (key_8), "8")
			result.force (create {EV_KEY}.make_with_code (key_9), "9")
			result.force (create {EV_KEY}.make_with_code (key_0), "0")
			result.force (create {EV_KEY}.make_with_code (key_numpad_add), "Numpad +")
			result.force (create {EV_KEY}.make_with_code (key_numpad_subtract), "Numpad -")
			result.force (create {EV_KEY}.make_with_code (key_dash), "-")
			result.force (create {EV_KEY}.make_with_code (key_left), "[<-]")
			result.force (create {EV_KEY}.make_with_code (key_right), "[->]")
			result.force (create {EV_KEY}.make_with_code (key_home), "[home]")
			result.force (create {EV_KEY}.make_with_code (key_end), "[end]")
			result.force (create {EV_KEY}.make_with_code (key_back_space), "[back]")
			result.force (create {EV_KEY}.make_with_code (key_delete), "[delete]")
			result.force (create {EV_KEY}.make_with_code (key_equal), "=")
			result.force (create {EV_KEY}.make_with_code (key_period), ".")
			result.force (create {EV_KEY}.make_with_code (key_comma), "[comma]")
			result.force (create {EV_KEY}.make_with_code (key_open_bracket), "[")
			result.force (create {EV_KEY}.make_with_code (key_close_bracket), "[")
			result.force (create {EV_KEY}.make_with_code (key_backslash), "[\]")
			result.force (create {EV_KEY}.make_with_code (key_semicolon), ";")
			result.force (create {EV_KEY}.make_with_code (key_quote), "[']")
			result.force (create {EV_KEY}.make_with_code (key_backquote), "`")
			result.force (create {EV_KEY}.make_with_code (key_numpad_decimal), "Numpad .")
			result.force (create {EV_KEY}.make_with_code (key_numpad_1), "Numpad 1")
			result.force (create {EV_KEY}.make_with_code (key_numpad_2), "Numpad 2")
			result.force (create {EV_KEY}.make_with_code (key_numpad_3), "Numpad 3")
			result.force (create {EV_KEY}.make_with_code (key_numpad_4), "Numpad 4")
			result.force (create {EV_KEY}.make_with_code (key_numpad_5), "Numpad 5")
			result.force (create {EV_KEY}.make_with_code (key_numpad_6), "Numpad 6")
			result.force (create {EV_KEY}.make_with_code (key_numpad_7), "Numpad 7")
			result.force (create {EV_KEY}.make_with_code (key_numpad_8), "Numpad 8")
			result.force (create {EV_KEY}.make_with_code (key_numpad_9), "Numpad 9")
			result.force (create {EV_KEY}.make_with_code (key_numpad_0), "Numpad 0")
			result.force (create {EV_KEY}.make_with_code (key_a), "a")
			result.force (create {EV_KEY}.make_with_code (key_b), "b")
			result.force (create {EV_KEY}.make_with_code (key_c), "c")
			result.force (create {EV_KEY}.make_with_code (key_d), "d")
			result.force (create {EV_KEY}.make_with_code (key_e), "e")
			result.force (create {EV_KEY}.make_with_code (key_f), "f")
			result.force (create {EV_KEY}.make_with_code (key_g), "g")
			result.force (create {EV_KEY}.make_with_code (key_h), "h")
			result.force (create {EV_KEY}.make_with_code (key_i), "i")
			result.force (create {EV_KEY}.make_with_code (key_j), "j")
			result.force (create {EV_KEY}.make_with_code (key_k), "k")
			result.force (create {EV_KEY}.make_with_code (key_l), "l")
			result.force (create {EV_KEY}.make_with_code (key_m), "m")
			result.force (create {EV_KEY}.make_with_code (key_n), "n")
			result.force (create {EV_KEY}.make_with_code (key_o), "o")
			result.force (create {EV_KEY}.make_with_code (key_p), "p")
			result.force (create {EV_KEY}.make_with_code (key_q), "q")
			result.force (create {EV_KEY}.make_with_code (key_r), "r")
			result.force (create {EV_KEY}.make_with_code (key_x), "x")
			result.force (create {EV_KEY}.make_with_code (key_t), "t")
			result.force (create {EV_KEY}.make_with_code (key_u), "u")
			result.force (create {EV_KEY}.make_with_code (key_v), "v")
			result.force (create {EV_KEY}.make_with_code (key_w), "w")
			result.force (create {EV_KEY}.make_with_code (key_x), "x")
			result.force (create {EV_KEY}.make_with_code (key_y), "y")
			result.force (create {EV_KEY}.make_with_code (key_z), "z")
		end

	function_keys: ARRAYED_LIST [EV_KEY]
			-- EV_KEY objects corresponding to the function keys on the keyboard
		local
			l_key: EV_KEY
		once
			create Result.make (12)
			create l_key.make_with_code (Key_f1)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f2)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f3)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f4)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f5)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f6)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f7)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f8)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f9)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f10)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f11)
			Result.extend (l_key)
			create l_key.make_with_code (Key_f12)
			Result.extend (l_key)
		end

	navigation_keys: ARRAYED_LIST [EV_KEY]
			-- EV_KEY objects corresponding to the navigation keys on the keyboard
		local
			l_key: EV_KEY
		once
			create Result.make (12)
			create l_key.make_with_code (Key_up)
			Result.extend (l_key)
			create l_key.make_with_code (Key_down)
			Result.extend (l_key)
			create l_key.make_with_code (Key_left)
			Result.extend (l_key)
			create l_key.make_with_code (Key_right)
			Result.extend (l_key)
			create l_key.make_with_code (Key_page_up)
			Result.extend (l_key)
			create l_key.make_with_code (Key_page_down)
			Result.extend (l_key)
			create l_key.make_with_code (Key_home)
			Result.extend (l_key)
			create l_key.make_with_code (Key_end)
			Result.extend (l_key)
		end

feature {NONE} -- Constants

	caret_character: CHARACTER_32 = '|'
	anchor_character: CHARACTER_32 = '!'

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

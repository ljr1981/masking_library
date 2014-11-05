note 
	description: "Specification for numeric mask keystroke testing."
	date: "$Date: 2014-11-03 14:18:26 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10178 $"

class
	NUMERIC_MASK_KEYSTROKE_TEST_SPECIFICATION

inherit
	NUMERIC_MASK_SPECIFIER

create
	make

feature {NONE} -- Initialization

	make (a_mask: INPUT_MASK [NUMERIC, DATA_COLUMN_METADATA [NUMERIC]]; a_key: EV_KEY; a_widget_text_before, a_modifiers, a_clipboard_contents_before: STRING_32)
			-- Initialize with 'a_widget_text_before', `a_modifiers', `a_clipboard_contents_before'.
		require
			is_valid_modifier: is_valid_modifier (a_modifiers)
			is_valid_text_spec_before: is_valid_widget_text_specification (a_widget_text_before)
		do
			mask := a_mask
			widget_text_before := a_widget_text_before
			modifiers := a_modifiers
			clipboard_contents_before := a_clipboard_contents_before
			create test_results.make (20)
		end

feature -- Access

	mask: INPUT_MASK [NUMERIC, DATA_COLUMN_METADATA [NUMERIC]]

	clipboard_contents_before: STRING_32

	modifiers: STRING_32
		attribute
		ensure
			is_valid_modifier: is_valid_modifier (Result)
		end

	widget_text_before: STRING_32
		attribute
		ensure
			is_valid_text_specification: is_valid_widget_text_specification (Result)
		end

	test_results: HASH_TABLE [TUPLE [key: EV_KEY; widget_text_after: STRING_32; clipboard_contents_after: STRING_32], INTEGER]

feature -- Basic Operations

	add_test (a_key: EV_KEY; a_widget_text_after, a_clipboard_contents_after: STRING_32)
		require
			not_added: not test_results.has (a_key.code)
			valid_text_specification: is_valid_widget_text_specification (a_widget_text_after)
		do
			test_results.put ([a_key, a_widget_text_after, a_clipboard_contents_after], a_key.code)
		ensure
			added: attached test_results.item (a_key.code) as al_item and then al_item.key = a_key
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

note 
	description: "Masking message constants."
	date: "$Date: 2015-05-21 11:43:01 -0400 (Thu, 21 May 2015) $"
	revision: "$Revision: 11365 $"

class
	MASKING_MESSAGES

inherit
	ABSTRACT_MASKING_MESSAGES

feature -- Constants

	contains_illegal_characters: STRING = "Contains illegal characters"

	decimal_field_nan_invalid_sentence: STRING = " This field can not be blank."

	entry_incomplete: STRING = "Entry is incomplete"

	integer_entered_too_large_message: STRING = "The number entered is too large. Number Entered: ^1; Highest Number Allowed: ^2."

	integer_entered_too_small_message: STRING = "The number entered is too small. Number Entered: ^1; Lowest Number Allowed: ^2."

	invalid_changes_message: STRING = "Some of the information you edited is not valid."

	invalid_date_sentence: STRING = "Invalid date."

	invalid_mm_dd_sentence: STRING = "Invalid MM/DD."

	invalid_percent_error: STRING = "The amount you have entered is too large. Please reduce it to an appropriate amount."

	missing_required_characters: STRING = "Missing required characters"

	text_entered_too_long_message: STRING = "The text entered is too long. Characters Entered: ^1; Maximum Allowed: ^2."

	cut_message: STRING =        "Cut           Ctrl+x"

	copy_message: STRING =       "Copy          Ctrl+c"

	paste_message: STRING =      "Paste         Ctrl+v"

	delete_message: STRING =     "Delete"

	select_all_message: STRING = "Select All    Ctrl+a"

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

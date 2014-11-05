note
	title: "Masking Library Documentation"
	warning: "[
		Please read the `readme.txt' file included with this library before attempting to learn this library.
		
		This library is by no means complete.  The features that are currently working
		were implemented based only on the needs of one specific application.  There is
		more work to be done. 
		
		The documentation is also incomplete in the sense of having two audiences. You
		will fit into one of the two categories: A) Re-use Consumer or B) Maintenance.
		As a re-use consumer of this library, you ought to find sufficient documentation
		that is learnable with examples to provide rapid learning and successful use.
		As a maintenance programmer, you will find less than sufficient documentation.
		This is because this library was largely developed to its current level before
		we became aware of faults in our documentation process and style. We are now working
		to correct these faults internally in our own systems. What you now see and read
		here is the sum of our current progress as applied to this library, but ought to
		be sufficient to your needs as a re-use-consumer user of this library.
		]"
	description: "[
		Library documentation for the masking library.
		]"
	purpose: "[
		Exposes a set of masks for use in masking text fields.
		]"
	how: "[
		By allowing programmers to enforce input rules and a structure on text fields.
		]"
	tutorial: "[
			Text Field Masking

			A text field mask is a string which specifies how the characters within a text field are to be
			displayed. The text field will allow the user to input only those characters allowed by the mask.
			The mask is also used to transform the data obtained from the database to the string which will
			be set into the text field and to transform the actual string in the text field to the data
			expected by the validator and model object.

			STRING_VALUE_INPUT_MASK

			The behavior and mask syntax depend on the type of the field being masked as described below:

			Creation of a TEXT_INPUT_MASK can be done with `make' or `make_repeating'.  See examples in class 
			header of STRING_VALUE_INPUT_MASK.

			Feature `make' indicates that a format specification will be provided for each character position
			in the text field string. User input will only be allowed at mask positions which are "open" to
			user input. An exception will be raised if the number of "open" characters exceeds the width of
			the database column.

			Feature `make_repeating' indicates that a single format specification will be provided which will
			be repeated for all positions in the text field string. User input will not be restricted to the
			width of the database column, but the input will be marked as invalid if it is too long.

			The '\' character may be used to escape any format specification
			characters with special meaning (including '\').

			String Mask Specification Characters

			'!' - Force input to upper case

			'#' - Only digits and spaces are allowed, an error message of missing required characters is
					reported to the user

			'_' - only digits and spaces are allowed, no error message reported for having spaces

			'9' - Only digits are allowed

			'A' - Only alphabetic characters are allowed. Numbers converted to spaces.

			'K' - Only uppercase alphabetic, numeric, and dash characters are allowed.

			'N' - Only letters and digits are allowed. (e.g. no special characters).

			'U' - Only alphabetic characters are allowed (forced to upper case and others converted
					to spaces).

			'W' - Only alphabetic characters are allowed (forced to lower case).

			'X' - Permit any character

			TBD:

			'C', 'V', 'Y', 'Z', '[', ']', '{', '}', '<', '>', '`', '~', '?', '='

			All other characters will be considered literal input for the mask.
			Literal input will display verbatim in the text field and the cursor
			will automatically skip over them when the user is typing.  The user
			will not be allowed to edit the character.

			Example String Masks:

			Unrestricted mask: "X"

			Social Security Number: "###-##-####"

			US Phone Number: "(###) ###-####"

			Force all characters to upper case: "!"

			NUMERIC_VALUE_INPUT_MASK (descendants: INTEGER, DECIMAL, CURRENCY, PERCENT)
		]"
	demo: "[
		There is a mask demo project located in the mask_demo folder under the root mask directory.
		]"
	operation: "See Documentation Navigation Operational Notes at the end of this class."
	date: "$Date: 2014-11-03 16:42:20 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10183 $"

deferred class
	DOC_LIBRARY_MASK

feature {NONE} -- Documentation

	doc_cluster_common: detachable DOC_CLUSTER_COMMON
		note
			purpose: "[
				To provide an abstract basis for all other masks. Please explore these classes
				first to gain an overarching understanding and orientation to masking in general.
				]"
			basics: "[
				Classes in this cluster provide common features for other classes.
				{INPUT_MASK} provides features common to {TEXT_INPUT_MASK} and {NUMERIC_VALUE_INPUT_MASK}.
				{TEXT_INPUT_MASK} provides features common to all test masks.
				{NUMERIC_VALUE_INPUT_MASK}, which is not in this cluster, provides features common to all numeric masks.
				]"
		attribute
			Result := Void
		end

	doc_cluster_numeric: detachable DOC_CLUSTER_NUMERIC
		note
			description: "[
				Numeric text masks.
				]"
			purpose: "[
				Numeric text masks are used to enforce numeric input only.
				]"
			basics: "[
				{NUMERIC_VALUE_INPUT_MASK} provides features common to all numeric masks.
				
				Programmers will use:
				{INTEGER_VALUE_INPUT_MASK} - to mask fields for integer input and display
				{DECIMAL_VALUE_INPUT_MASK} - to mask fields for generic decimal input and display
				{CURRENCY_VALUE_INPUT_MASK} - to mask fields for decimal input with a currency symbol preceding it
				{PERCENT_VALUE_INPUT_MASK} - to mask fields for decimal input with a percent symbol following it
				]"
		attribute
			Result := Void
		end

	doc_cluster_misc: detachable DOC_CLUSTER_MISC
		note
			purpose: "[
				20141031: The current purpose of this cluster is a catch-all for non-string and non-numeric masks.
				]"
			refactors: "[
				20141031: At this point, this cluster contains only the DATE_TIME_VALUE_INPUT_MASK which needs overhauling.
					Currently, programmers should {STRING_VALUE_INPUT_MASK} for date/time needs.
				
					Once overhauled, programmers will use:
					{DATE_TIME_VALUE_INPUT_MASK} - to mask fields for date and/or time input and display
				]"
		attribute
			Result := Void
		end

	doc_cluster_string: detachable DOC_CLUSTER_STRING
		note
			description: "[
				String text masks.
				"]
			purpose: "[
				Text masks are used to filter and format variable input in the form of strings.
				]"
			basics: "[
				Programmers will use:
				{STRING_VALUE_INPUT_MASK} - to mask string text fields in a variety of ways.
				See {STRING_VALUE_INPUT_MASK} for more details.
				]"
		attribute
			Result := Void
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

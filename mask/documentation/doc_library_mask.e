note
	EIS: "name=readme", "src=../readme.pdf", "protocol=PDF", "tag=external"
	title: "Masking Library Documentation"
	warning: "[
		This library meets the needs of its original author, but may not meet the needs of everyone.
		]"
	description: "[
		Library documentation for the masking library.
		]"
	purpose: "[
		To provide text masking facilities to classes derived from {EV_TEXT_COMPONENT} (those having
		 text).
		]"
	how: "[
		By a factory, which takes some {EV_TEXT_COMPONENT} (e.g. {EV_TEXT_FIELD}) and hooking up a 
		"mask" and then watching user-interaction and responding to it.
		
		A "mask-string" tells the factory what form of "mask" to apply. For example, a "(999) 999-9999"
		might represent a common U.S. telephone number. A "999-99-9999" might represent a common U.S.
		Social Security Number. Thus, the user can type numeric characters (e.g. "9" mask code), but
		cannot type characters into other locations "masked-off" by "-", "(", and ")". Neither can the
		user type anything other than numbers in each position where a "9" appears (in the masks above).
		
		After the user has typed whatever they like, your program can examine the EV_TEXT_COMPONENT GUI
		control. It can use either the masked value (e.g. "(999) 999-9999") or the "unmasked" value
		(e.g. "(511) 455-5241" --> "5114555241").
		]"
	tutorial: "[
			{EV_TEXT_COMPONENT} Masking
			===================

			An {EV_TEXT_COMPONENT} "mask" is a string which specifies how the characters within
			a text field are to be displayed. The text field will allow the user to input
			only those characters allowed by the mask. The mask is also used to transform
			the data obtained from a data source to the string which will be set into the
			text field and to transform the actual string in the text field to the data
			expected by the validator and model object (see glossary for definitions).

			Example: {STRING_VALUE_INPUT_MASK}
			==================================
			
			The mask behavior and mask syntax depend on the type of the field being masked.

			Creation of a {TEXT_INPUT_MASK} can be done with `make' or `make_repeating'.
			
			Full Mask:
			==========

			Feature {STRING_VALUE_INPUT_MASK}.make indicates that a format specification will
			be provided for each character position in the text field string. User input will
			only be allowed at mask positions which are "open" to user input. An exception will
			be raised if the number of "open" characters exceeds the width of a data source 
			(e.g. possibly the width of a column in a relational database).
			
			Examples:
			* U.S. Phone Number:	"(999) 999-9999"
			* U.S. Soc Sec Number:	"999-99-9999"
			* Visa Credit Card#:	"9999-9999-9999-9999"
			
			Repeating Mask:
			===============

			Feature {STRING_VALUE_INPUT_MASK}.make_repeating indicates that a single format
			Specification Character will be provided which will be repeated for all positions
			in the text field string. User input will not be restricted to the width of the
			data source constraint, but the input will be marked as invalid if it is too long.

			The '\' character may be used to escape any format specification
			characters with special meaning (including '\').
			
			Examples:
			* U.S. Postal Address:	(several fields with their own mask)
									"9" 	<-- Street number: Nothing but numbers allowed as input
									"K"		<-- Street name: Alphabetic, numbers, dashes as input
									"!A"	<-- City: Uppercase Alphabetic characters as input
									"!A"	<-- State: Uppercase Alphabetic characters as input
									"9"		<-- ZIP Code: Numbers only

			String Mask Specification Characters:
			=====================================
			
			'!' - Force input to upper case (insert once at the start of your mask, applies to all)

			'#' - Only digits and spaces are allowed, an error message of missing required characters is
					reported to the user.

			'_' - only digits and spaces are allowed, no error message reported for having spaces.

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
			=====================

			Unrestricted mask: "X"

			Social Security Number: "999-99-9999" (full mask)

			US Phone Number: "(999) 999-9999" (full mask)

			Force all characters to upper case: "!" (repeating mask)
		]"
	demo: "[
		There is a demonstration project you can access through the "mask_demo" target of this ECF.
		]"
	operation: "See Documentation Navigation Operational Notes at the end of this class."
	glossary: "[
		Glossary of Terms
		]"
	term: "[
		Model Object: A model object is a type of object that contains the data of an application, 
			provides access to that data, and implements logic to manipulate the data. Model objects 
			play one of the three roles defined by the Model-View-Controller design pattern.
		]"
	term: "[
		Validator: Any object routine(s) responsible for data validation of user editable input. The
			validation of data may happen on either the masked or unmasked data.
		]"
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
				{INPUT_MASK} provides features common to {TEXT_INPUT_MASK} and 
					{NUMERIC_VALUE_INPUT_MASK}.
				{TEXT_INPUT_MASK} provides features common to all test masks.
				{NUMERIC_VALUE_INPUT_MASK}, which is not in this cluster, provides features 
					common to all numeric masks.
				]"
			EIS: "name=common_cluster_documentation", "src=https://github.com/ljr1981/masking_library/blob/master/mask/documentation/doc_cluster_common.e", "protocol=URI", "tag=external"
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
				{INTEGER_VALUE_INPUT_MASK}	- to mask fields for integer input and display
				{DECIMAL_VALUE_INPUT_MASK} 	- to mask fields for generic decimal input and display
				{CURRENCY_VALUE_INPUT_MASK} - to mask fields for decimal input with a currency 
												symbol preceding it
				{PERCENT_VALUE_INPUT_MASK} 	- to mask fields for decimal input with a percent 
												symbol following it
				]"
		attribute
			Result := Void
		end

	doc_cluster_misc: detachable DOC_CLUSTER_MISC
		note
			purpose: "[
				20141031: The current purpose of this cluster is a catch-all for non-string and 
					non-numeric masks.
				]"
			refactors: "[
				20141031: At this point, this cluster contains only the DATE_TIME_VALUE_INPUT_MASK 
				which needs overhauling. Currently, programmers should {STRING_VALUE_INPUT_MASK} 
				for date/time needs.
				
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

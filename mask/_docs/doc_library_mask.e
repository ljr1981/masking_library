note
	EIS: "name:Read_me", "src=./ReadMe.PDF", "protocol=PDF", "tag=external"
	description: "Mask Library Documentation"
	introduction: "[
		Masking, in this context, is an application behavior when the user is displaying, entering or
		editing text.  It permits the programmer to specify a mask, such as "(999) 999-9999", and attach
		the "mask" object with all the text fields that need it.  Then, without any further actions on the
		part of the programmer, the text field behaves as you would expect in a phone number entry field:
		namely, keystrokes are limited to numbers only, and the numbers fall into the positions indicated
		by the '9' characters.  The edited text is then available in either the masked or unmasked form.
		]"
	purpose: "[
		When writing interactive applications, it is often the case that data that gets STORED looks
		different when it is DISPLAYED.  In such cases, usually it is the DISPLAYED value that is edited
		by the user and then converted back into STORED form again before being stored.  Examples of this
		abound in database-centric applications.

		Example:  a USA telephone number is often displayed and edited in a format like "(123) 456-7890",
		but stored like this "1234567890".  Dates, tax ID numbers, currency values, account numbers, etc.
		are common examples of such data.

		The Mask library interfaces with the EiffelVision2 library text widgets (text controls) to provide
		such behavior with very little effort on the part of the programmer.
		]"
	example: "[
		set_up_phone_number_mask
				-- Basic usage of a string mask; numeric masks are similar.
				-- This example assumes the two text widgets have already been created.
			do
				create phone_mask.make ("(999) 999-9999")
				--| Connect `phone_field's and `fax_field's events for user editing.
				phone_mask.add_text_widget (phone_field)
				phone_mask.add_text_widget (fax_field)
				--| Supply initial text.  `phone_number' and `fax_number' look like this:  "2135551212".
				phone_field.set_text (phone_mask.apply (customer_record.phone_number).masked_string)
				fax_field.set_text (phone_mask.apply (customer_record.fax_number).masked_string)
			end

		unmask_edited_fields
				-- Demonstration of translating edited masked data back to unmasked form.
				-- The masked form ("(213) 555-1212") is in `phone_field.text'.
			do
				--| Other fields omitted for brevity.
				customer_record.set_unmasked_phone_number (phone_mask.remove (phone_field.text, Void).value)
				customer_record.set_unmasked_fax_number (phone_mask.remove (fax_field.text, Void).value)
				--| The new record values look like this:  "2135551212".
			end
		]"
	basics: "[
		Full Mask:
		==========
		A Full Mask is a mask string that specifies the position of every character in the text field.
		No characters are permitted beyond the length specified by the mask.

		Any mask string passed to the mask's `make' feature is considered a Full Mask.

		Examples:
		* U.S. Phone Number:	"(999) 999-9999"
		* U.S. Soc Sec Number:	"999-99-9999"
		* Credit Card#:			"9999-9999-9999-9999"


		Repeating Mask:
		===============
		A Repeating Mask is a mask string consisting of only one character, which specifies the keystrokes
		permitted in the field and DOES NOT limit the length of the text entered by the user, save only that
		when keyboard focus leaves the text field, the text is "marked" as invalid if the length is longer
		than an optionally-specified limit.

		Any mask string passed to the mask's `make_repeating' feature is considered a Repeating Mask.

		Examples:
		* U.S. Postal Address:	(several fields with their own mask)
								"9" 	<-- Street number: Nothing but numbers allowed as input
								"K"		<-- Street name: Alphabetic, numbers, dashes as input
								"!A"	<-- City: Uppercase Alphabetic characters as input
								"!A"	<-- State: Uppercase Alphabetic characters as input
								"9"		<-- ZIP Code: Numbers only


		Mask Code Character:
		====================
		Certain characters have special meaning within a mask string.  (See below.)  These characters limit
		the keystrokes that will be accepted into the field, and in the case of Full Masks, also specify
		the position that keyed characters can appear.  All other characters are "Literal Characters" and
		will be displayed in their given position without alteration.  The user will not be able to move or
		edit them.  In order to cause one of the Mask Code Characters to behave as a Literal Character,
		escape it by preceiding it with the '\' character.  (Note:  Literal Characters and '\'-escaped Mask
		Code Characters are only valid in Full Masks.)


		Literal Characters:
		===================
		See Mask Code Character above.


		String Mask Specification Characters:
		=====================================
		Mask Specification Characters limit keystrokes that are accepted into the text field as follows:

		'!' - Forces keystrokes to upper case (insert once at beginning of mask; applies to all)
		'#' - Only digits and spaces are allowed; if part of mask is left empty, an error message issued.
		'_' - Only digits and spaces are allowed; no error message.
		'9' - Only digits are allowed
		'A' - Only alphabetic characters are allowed; numbers are converted to spaces.
		'K' - Only uppercase alphabetic, numeric, and hyphen characters are allowed.
		'N' - Only letters and digits are allowed; no special characters.
		'U' - Alphabetic keystrokes are converted to upper case, others converted to spaces.
		'W' - Only alphabetic characters are allowed (forced to lower case).
		'X' - All characters accepted.

		Reserved for future enhancements:  'C', 'V', 'Y', 'Z', '[', ']', '{', '}', '<', '>', '`', '~', '?', '='.

		All other characters will be considered Literal Characters for the mask.  As previously covered,
		Literal Characters are not movable nor editable; the cursor will skip over them when the user is typing.


		Example String Masks:
		=====================

		Unrestricted mask: "X"

		Social Security Number: "999-99-9999" (Full Mask)

		US Phone Number: "(999) 999-9999" (Full Mask)

		Force all characters to upper case: "!" (Repeating Mask)
		]"
	demo: "[
		Run "mask_demo" target of MASK.ECF to interact with a demonstration program.
		]"
	clusters: "[
		common:  {DOC_CLUSTER_COMMON}
			Ancestors common to all masks.

		numeric:  {DOC_CLUSTER_NUMERIC}
			Masks for various types of numeric input, such as integers, decimals, currency values, and percents.

		string:  {DOC_CLUSTER_STRING}
			Masks for various types of string input, such as USA social-security numbers, phone numbers, etc.

		misc:  {DOC_CLUSTER_MISC}
			Masks for types of input that are not covered by numeric or string masks.

		messages:  {DOC_CLUSTER_MESSAGES}
			User message constants used while user is editing.  Hierarchy accommodates non-English translations.

		api:
			Obsolete.  Do not use.
		]"
	warning: "[
		This library meets the needs of its original author, but may not meet the needs of everyone.
		]"
	date: "$Date: 2014-11-03 16:42:20 -0500 (Mon, 03 Nov 2014) $"
	revision: "$Revision: 10183 $"

deferred class
	DOC_LIBRARY_MASK

feature {NONE} -- Cluster Documentation

	documentation
			-- Documentation references
		note
			Purpose: "[
				To provide click-and-drop access these classes, which permits every class surrounded by curly
				braces in the documentation to be click-and-droppable in Clicable View.
				]"
			synopsis: "[
				Included merely to get the DOC_* classes compiled into the universe via local variables.
				]"
		require
			do_not_call: False
		local
			a: DOC_CLUSTER_API
			b: DOC_CLUSTER_COMMON
			c: DOC_CLUSTER_MESSAGES
			d: DOC_CLUSTER_MISC
			e: DOC_CLUSTER_NUMERIC
			f: DOC_CLUSTER_STRING
		do
			do_nothing
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

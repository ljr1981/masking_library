note
	description: "Summary description for {CHARACTER_COLUMN_METADATA}."
	author: ""
	date: "$Date: 2013-12-23 18:28:27 -0500 (Mon, 23 Dec 2013) $"
	revision: "$Revision: 8326 $"

class
	CHARACTER_COLUMN_METADATA

inherit
	DATA_COLUMN_METADATA [CHARACTER_32]

create
	make

feature -- Status Report

	conforms_to_constraint (a_value: CHARACTER_32): BOOLEAN
			-- <Precursor>
			--| Should always be true.
		do
			Result := True
		ensure then
			always_true: Result
		end

note
	copyright: "Copyright (c) 2010-2011, Jinny Corp."
	copying: "[
			Duplication and distribution prohibited. May be used only with
			Jinny Corp. software products, under terms of user license.
			Contact Jinny Corp. for any other use.
			]"
	source: "[
			Jinny Corp.
			3587 Oakcliff Road, Doraville, GA 30340
			Telephone 770-734-9222, Fax 770-734-0556
			Website http://www.jinny.com
			Customer support http://support.jinny.com
		]"
end

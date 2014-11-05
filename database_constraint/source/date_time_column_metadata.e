note
	description: "Summary description for {DATA_TIME_COLUMN_METADATA}."
	author: ""
	date: "$Date: 2013-12-23 18:28:27 -0500 (Mon, 23 Dec 2013) $"
	revision: "$Revision: 8326 $"

class
	DATE_TIME_COLUMN_METADATA

inherit
	DATA_COLUMN_METADATA [DATE_TIME]

create
	make_with_scale

feature -- Initialization

	make_with_scale (a_table_name: like table_name; a_column_name: like column_name; a_capacity: like capacity; a_scale: like scale)
		do
			make (a_table_name, a_column_name, a_capacity)
			scale := a_scale
		ensure
			table_name_set: table_name = a_table_name
			column_name_set: column_name = a_column_name
			capacity_set: capacity = a_capacity
			scale_set: scale = a_scale
		end

feature -- Access

	scale: INTEGER
		-- Scale (or mantissa) of `precision' for current.

feature -- Status Report

	conforms_to_constraint (a_value: DATE_TIME): BOOLEAN
			-- <Precursor>
		do
			Result :=  a_value.year >= 1735 and then a_value.year <= 9999
		end

;note
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

note
	description: "Summary description for {DATA_COLUMN_CONSTRAINT}."
	author: ""
	date: "$Date: 2013-12-23 18:28:27 -0500 (Mon, 23 Dec 2013) $"
	revision: "$Revision: 8326 $"

deferred class
	DATA_COLUMN_METADATA [G -> ANY]

feature {NONE} -- Initialization

	make (a_table_name: like table_name; a_column_name: like column_name; a_capacity: like capacity)
			-- Initializes current `table_name' with `a_table_name', `column_name' with `a_column_name', `capacity' with `a_capacity'.
		do
			table_name := a_table_name
			column_name := a_column_name
			capacity := a_capacity
		ensure
			table_name_set: table_name = a_table_name
			column_name_set: column_name = a_column_name
			capacity_set: capacity = a_capacity
		end

feature -- Access

	table_name: STRING
		-- Table name for current.

	column_name: STRING
		-- Column name for current

	capacity: INTEGER
		-- Capacity (or precision) of current.

feature -- Status Report

	conforms_to_constraint (a_value: G): BOOLEAN
			-- Does `a_value' conform to the constraints of Current?
		deferred
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

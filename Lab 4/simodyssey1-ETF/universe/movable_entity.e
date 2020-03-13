note
	description: "Summary description for {MOVABLE_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MOVABLE_ENTITY

inherit
	ENTITY

create
	make_movable_entity

feature --constructor
	make_movable_entity (seticon : CHARACTER)
		do
			create sector.default_create
			create icon.make(seticon)
		end

feature -- attributes of a movable entity

	sector: TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER] assign set_sector

feature --commands

	set_sector(sec :TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER])
			do
				sector := sec
			end

end

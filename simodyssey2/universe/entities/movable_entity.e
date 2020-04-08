note
	description: "Summary description for {MOVABLE_ENTITY}."
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
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
	turns_left: INTEGER assign set_turns_left
	is_alive : BOOLEAN assign set_is_alive

feature --commands

	set_sector(sec :TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER])
		do
			sector := sec
		end

	set_turns_left(turns: INTEGER)
		do
			turns_left := turns
		end

	set_is_alive(alive : BOOLEAN)
		do
			is_alive := alive
		end

end

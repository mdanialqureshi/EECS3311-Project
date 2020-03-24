note
	description: "Summary description for {ASTROID}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ASTEROID

inherit
	MOVABLE_ENTITY

create
	make

feature -- constructor

	make(id_num:INTEGER;turns: INTEGER;location: TUPLE[INTEGER,INTEGER,INTEGER])
		do
			make_movable_entity ('A')
			is_asteroid := true
			id := id_num
			turns_left := turns
			sector := location
			create death_msg.make_empty
			is_alive := false
		end

feature -- variables

	death_msg : STRING

feature -- commands

	check_asteroid(cur_sector : SECTOR;moved : BOOLEAN)
		local
			contents : ARRAYED_LIST [ENTITY_ALPHABET]
		do
			contents := cur_sector.contents


			if contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_alive := TRUE
				death_msg.append ("Asteroid got devoured by blackhole (id: -1) at Sector:3:3")
			end
			-- add janitaur condition

		end

	behave(cur_sector : SECTOR)
		do
			--Seeks any other movable entities in its sector
			-- except planets and other asteroids and destroys
			-- all of them in ascending id order. (Note that explorer
			-- cannot be hit if it is landed).
			turns_left := gen.rchoose(0,2)
		end
end

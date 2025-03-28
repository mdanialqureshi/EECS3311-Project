note
	description: "This class represents the Planet movable entity in our universe, and correctly implements this entitys respective behaviours and features."
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
	revision: "$Revision$"

class
	PLANET

inherit
	MOVABLE_ENTITY

create
	make

feature -- Constructor

	make(id_num:INTEGER;turns: INTEGER;location: TUPLE[INTEGER,INTEGER,INTEGER])
		do
			make_movable_entity ('P')
--			create icon.make('P')
			is_moveable_entity := true
			is_planet := true
			id := id_num
			sector := location
			turns_left := turns
			is_alive := true
			create death_msg.make_empty
			support_life := false
			visited := false
			first_check := true
			in_orbit_icon := 'F'
		end

feature -- Variables

	in_orbit: BOOLEAN assign set_in_orbit
	in_orbit_icon : CHARACTER
	support_life: BOOLEAN assign set_support_life
	death_msg : STRING
	visited : BOOLEAN assign set_visited
	first_check: BOOLEAN assign set_first_check

feature --commands

	check_planet(cur_sector : SECTOR)
		local
			contents : ARRAYED_LIST [ENTITY_ALPHABET]
		do
			contents := cur_sector.contents

			if contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_alive := false -- planet is killed by blackhole (Remove from planets array in galaxy and dont place
								  -- the planet in the new sector after movement from old sector
				death_msg.append("Planet got devoured by blackhole (id: -1) at Sector:3:3")
			end

			if not (is_alive) then -- remove from board if its no longer alive
				cur_sector.remove_entity(Current, true) -- removes from all sector lists and
			end

		end

	behave(cur_sector : SECTOR)
		local
			contents : ARRAYED_LIST[ENTITY_ALPHABET]
		do
			contents := cur_sector.contents

			if contents.has (create {ENTITY_ALPHABET}.make ('Y')) or contents.has (create {ENTITY_ALPHABET}.make ('*')) then
				in_orbit := true
				if contents.has (create {ENTITY_ALPHABET}.make ('Y')) then
					if gen.rchoose (1, 2) = 2 then
						support_life := true
					end
				end
			else
				turns_left := gen.rchoose (0, 2)
			end
		end


feature -- commands
	set_in_orbit(orbit: BOOLEAN)
		do
			in_orbit := orbit
			if in_orbit then
				in_orbit_icon := 'T'
			end
		end

	set_first_check(first: BOOLEAN)
		do
			first_check := first
		end

	set_visited(is_visited: BOOLEAN)
		do
			visited := is_visited
		end

	set_support_life(sup_life: BOOLEAN)
		do
			support_life := sup_life
		end


end

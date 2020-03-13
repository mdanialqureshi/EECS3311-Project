note
	description: "Summary description for {PLANET}."
	author: ""
	date: "$Date$"
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
			create icon.make('P')
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

	turns_left: INTEGER assign set_turns_left
	in_orbit: BOOLEAN assign set_in_orbit
	in_orbit_icon : CHARACTER
	support_life: BOOLEAN
	is_alive : BOOLEAN
	death_msg : STRING
	gen : RANDOM_GENERATOR_ACCESS
	visited : BOOLEAN assign set_visited
	first_check: BOOLEAN assign set_first_check

feature --queries

	behave(contents : ARRAYED_LIST [ENTITY_ALPHABET])

		do
			if contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_alive := false -- planet is killed by blackhole (Remove from planets array in galaxy and dont place
								  -- the planet in the new sector after movement from old sector
				death_msg.append("Planet got devoured by blackhole (id: -1) at Sector:3:3")
			end

			if contents.has (create {ENTITY_ALPHABET}.make ('Y')) or contents.has (create {ENTITY_ALPHABET}.make ('*')) then
				in_orbit := true
				if contents.has (create {ENTITY_ALPHABET}.make ('Y')) then
					if gen.rchoose (1, 2) = 2 then
						support_life := true
					end
				end
			elseif is_alive then

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

	set_turns_left(turns: INTEGER)
		do
			turns_left := turns
		end

	set_first_check(first: BOOLEAN)
		do
			first_check := first
		end

	set_visited(is_visited: BOOLEAN)
		do
			visited := is_visited
		end



end

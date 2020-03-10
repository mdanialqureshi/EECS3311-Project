note
	description: "Summary description for {PLANET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PLANET

create
	make

feature -- Constructor

	make(id_num:INTEGER;turns: INTEGER;location: TUPLE[INTEGER,INTEGER,INTEGER])
		do
			create icon.make('P')
			id := id_num
			sector := location
			turns_left := turns
			is_alive := true
			create death_msg.make_empty
			support_life := false
			visited := false
		end

feature -- Variables

	icon: ENTITY_ALPHABET
	id: INTEGER
	turns_left: INTEGER
	in_orbit: BOOLEAN
	support_life: BOOLEAN
	sector: TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER]
	is_alive : BOOLEAN
	death_msg : STRING
	gen : RANDOM_GENERATOR_ACCESS
	visited : BOOLEAN

feature --queries

	behave(contents : ARRAYED_LIST [ENTITY_ALPHABET]; used_wormhole : BOOLEAN) : BOOLEAN

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
			else
				turns_left := gen.rchoose (0, 2)
			end

		end



end

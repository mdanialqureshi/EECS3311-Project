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

		end

feature -- Variables

	icon: ENTITY_ALPHABET
	id: INTEGER
	turns_left: INTEGER
	in_orbit: BOOLEAN
	support_life: BOOLEAN
	sector: TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER]


end

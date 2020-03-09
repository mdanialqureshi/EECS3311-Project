note
	description: "Summary description for {EXPLORER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EXPLORER

create
	make

feature -- Constructor

	make
		do
			create icon.make('E')
			id := 0
			sector := [1,1,1]
			fuel := 3
			life := 3
			is_landed := false
		end



feature -- variables
	id: INTEGER
	icon: ENTITY_ALPHABET
	fuel: INTEGER
	life: INTEGER
	sector: TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER]
	is_landed: BOOLEAN

end

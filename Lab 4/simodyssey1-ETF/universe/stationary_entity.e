note
	description: "Summary description for {STATIONARY_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STATIONARY_ENTITY

create
	make


feature -- constructor
	make(id_num: INTEGER;char: CHARACTER)
		do
			id := id_num
			create icon.make(char)
		end


feature -- variables
	id: INTEGER
	icon: ENTITY_ALPHABET
	is_star: BOOLEAN assign set_is_star
	luminosity: INTEGER assign set_luminosity



set_is_star (star: BOOLEAN)
	do
		is_star := star
	end

set_luminosity(luminosity_val: INTEGER)
	do
		luminosity := luminosity_val
	end

end

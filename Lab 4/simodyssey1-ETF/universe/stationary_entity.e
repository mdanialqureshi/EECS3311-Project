note
	description: "Summary description for {STATIONARY_ENTITY}."
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
	revision: "$Revision$"

class
	STATIONARY_ENTITY

inherit
    ENTITY

create
	make


feature -- constructor
	make(id_num: INTEGER;char: CHARACTER)
		do
			id := id_num
			create icon.make(char)
			is_stationary_entity := true
		end


feature -- variables
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

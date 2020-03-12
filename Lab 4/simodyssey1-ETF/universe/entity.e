note
	description: "Summary description for {ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENTITY

create
	makedummy, make_entity

feature -- contructor

	make_entity (in_icon : ENTITY_ALPHABET; in_id : INTEGER)
		do
			icon := in_icon
			id := in_id
			if in_id ~ -1 then
				is_blackhole := true
			elseif in_id < -1 then
				is_stationary_entity := true
			elseif in_id ~ 0 then
				is_explorer := true
			elseif in_id > 0 then
				is_planet := true
			end
		end
	makedummy
		do
			create icon.make('d')
			is_planet := false
			is_explorer := false
			is_blackhole := false
			is_stationary_entity := false
		end

feature -- attributes of an entity
	icon: ENTITY_ALPHABET
	id: INTEGER
	is_planet : BOOLEAN
	is_explorer : BOOLEAN
	is_blackhole : BOOLEAN
	is_stationary_entity : BOOLEAN

end

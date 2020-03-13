note
	description: "Summary description for {ENTITY}."
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
	revision: "$Revision$"

class
	ENTITY

create
	makedummy, make_entity

feature -- contructors

	make_entity (in_icon : ENTITY_ALPHABET; in_id : INTEGER)
		do
			icon := in_icon
			id := in_id
			if in_icon.item ~ ('-') then
				is_blank := true
			else
				is_blank := false
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
	is_blank : BOOLEAN

feature -- queries

	boolean_icon (b : BOOLEAN) : STRING
		do
			create Result.make_empty
			if b then
				Result.append("T")
			else
				Result.append("F")
			end
		end

end

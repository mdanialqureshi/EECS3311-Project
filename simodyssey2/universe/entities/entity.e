note
	description: "Representation of an entity in our Simodyssey game universe. This class represents all entity types in our universe."
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
					is_moveable_entity := true
				end
			end
			-- all are false and set to true in their
			-- own constructors
			is_planet := false
			is_benign := false
			is_asteroid := false
			is_janitaur := false
			is_malevolent := false
		end

	makedummy
		do
			create icon.make('d')
			is_moveable_entity := false
			is_explorer := false
			is_blackhole := false
			is_stationary_entity := false
			-- all are false and set to true in their
			-- own constructors
			is_planet := false
			is_benign := false
			is_asteroid := false
			is_janitaur := false
			is_malevolent := false
		end

feature -- attributes of an entity
	icon: ENTITY_ALPHABET
	id: INTEGER
	is_moveable_entity : BOOLEAN
	is_explorer : BOOLEAN
	is_blackhole : BOOLEAN
	is_stationary_entity : BOOLEAN
	is_blank : BOOLEAN
	gen: RANDOM_GENERATOR_ACCESS -- random generator to be used
	-- by child classes
	is_planet : BOOLEAN
	is_benign : BOOLEAN
	is_asteroid : BOOLEAN
	is_janitaur : BOOLEAN
	is_malevolent : BOOLEAN

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

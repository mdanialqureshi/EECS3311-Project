note
	description: "Summary description for {EXPLORER}."
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
	revision: "$Revision$"

class
	EXPLORER

inherit
    MOVABLE_ENTITY

create
	make

feature -- Constructor

	make
		do
			make_movable_entity ('E')
			create icon.make('E')
			is_explorer := true
			id := 0
			sector := [1,1,1]
			fuel := 3
			life := 3
			is_landed := false
			create death_msg.make_empty
		end



feature -- variables
	fuel: INTEGER
	life: INTEGER
	is_landed: BOOLEAN assign set_landed
	death_msg : STRING

feature --commands

	set_landed(land:BOOLEAN)
		do
			is_landed := land
		end

feature --queries

	update_explorer(contents : ARRAYED_LIST [ENTITY_ALPHABET]; used_wormhole : BOOLEAN)
		do

		if not(used_wormhole) then
			fuel := fuel - 1
		end

		if contents.has (create {ENTITY_ALPHABET}.make ('Y')) then
			fuel := fuel + 2
		elseif contents.has (create {ENTITY_ALPHABET}.make ('*')) then
			fuel := fuel + 5
		end

		if fuel > 3 then --check if too much fuel
			fuel := 3
		end

		if fuel = 0 then
			life := 0
			death_msg.append ("Explorer got lost in space - out of fuel at Sector:" + sector.row.out + ":" + sector.col.out)
		elseif contents.has (create {ENTITY_ALPHABET}.make ('O')) then
			life := 0
			death_msg.append ("Explorer got devoured by blackhole (id: -1) at Sector:3:3")
		end

		end

end

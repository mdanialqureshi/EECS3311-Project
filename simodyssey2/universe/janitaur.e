note
	description: "Summary description for {JANITAUR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JANITAUR

inherit
	MOVABLE_ENTITY

create
	make

feature -- constructor

	make(id_num:INTEGER;turns: INTEGER;location: TUPLE[INTEGER,INTEGER,INTEGER])
		do
			make_movable_entity ('J')
			is_janitaur := true
			id := id_num
			turns_left := turns
			sector := location
			fuel := 5
			actions_left_until_reproduction := 2
			create death_msg.make_empty
			is_alive := false
			load := 0
			max_load := 2
		end

feature -- variables

	fuel: INTEGER
	death_msg : STRING
	actions_left_until_reproduction : INTEGER
	load : INTEGER
	max_load : INTEGER

feature -- commands

	update_janitaur(cur_sector : SECTOR; moved : BOOLEAN; next_movable_id: INTEGER)
		local
			contents : ARRAYED_LIST [ENTITY_ALPHABET]
		do
			contents := cur_sector.contents
			if moved then
				fuel := fuel - 1
			end

			if contents.has (create {ENTITY_ALPHABET}.make ('Y')) then
				fuel := fuel + 2
			elseif contents.has (create {ENTITY_ALPHABET}.make ('*')) then
				fuel := fuel + 5
			end

			if fuel > 5 then --check if too much fuel
				fuel := 5
			end

			if fuel = 0 then
				is_alive := TRUE
				death_msg.append ("Janitaur got lost in space - out of fuel at Sector:" + sector.row.out + ":" + sector.col.out)
			elseif contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_alive := TRUE
				death_msg.append ("Janitaur got devoured by blackhole (id: -1) at Sector:3:3")
			end
			-- add astroid condition

			if not (actions_left_until_reproduction = 0) then
				actions_left_until_reproduction := actions_left_until_reproduction - 1
			else
				reproduce(cur_sector,next_movable_id)
			end

		end


	reproduce(cur_sector : SECTOR; next_movable_id: INTEGER) --reproduces every 3 turns
		do
			if not (cur_sector.is_full) then
				-- impelement
			end


			actions_left_until_reproduction := 1 --set it back for next reproduction
		end

	behave(cur_sector : SECTOR)
		do
--		    Unless its maximum_load_level has been reached,
--			looks for asteroids to implode and haul away
--			(where it destroys all the asteroids in that sector
--			and incrementing the load level by the number of asteroids destroyed).
--			If there are multiple asteroids and not enough room in the janitaur,
--			lower id asteroids are targeted first. If a wormhole is in the current
--			sector, it will then throw all the asteroids into it,
--			clearing the load level. Note the asteroids thrown into
--			the wormhole do not appear anywhere.

			turns_left := gen.rchoose(0,2)
		end
end

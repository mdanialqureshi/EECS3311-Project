note
	description: "This class represents the Janitaur movable entity in our universe, and correctly implements this entitys respective behaviours and features."
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
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
			create reproduce_msg.make_empty
			create destroy_msg.make
			create deaths_by_janitaur.make
			is_alive := true
			load := 0
			max_load := 2
		end

feature -- variables

	fuel: INTEGER
	death_msg : STRING
	reproduce_msg : STRING
	destroy_msg : LINKED_LIST[STRING]
	deaths_by_janitaur: LINKED_LIST[STRING]
	actions_left_until_reproduction : INTEGER
	load : INTEGER
	max_load : INTEGER

feature -- commands

	check_janitaur(cur_sector : SECTOR; moved : BOOLEAN)
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
				is_alive := false
				death_msg.append ("Janitaur got lost in space - out of fuel at Sector:" + sector.row.out + ":" + sector.col.out)
			elseif contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_alive := false
				death_msg.append ("Janitaur got devoured by blackhole (id: -1) at Sector:3:3")
			end
			-- asteroid death handled in asteroid class

			if not (is_alive) then -- remove from board if its no longer alive
				cur_sector.remove_entity(Current, true) -- removes from all sector lists and
			end

		end


	reproduce(cur_sector : SECTOR; next_movable_id: INTEGER) : BOOLEAN --reproduces every 3 turns
		local
			new_janitaur : JANITAUR
			location : TUPLE [INTEGER_32, INTEGER_32, INTEGER_32]
			quad : INTEGER
		do
			Result := false
			reproduce_msg.make_empty
			if not (cur_sector.is_full) and actions_left_until_reproduction = 0 then
				-- impelement
				create location.default_create
				-- create the reproduced one
				create new_janitaur.make (next_movable_id, gen.rchoose (0, 2),location)
				cur_sector.put (new_janitaur.icon, false) --add entity to sectors available contents quadrant position
				quad := cur_sector.recently_added
				location := [sector.row,sector.col,quad]
				new_janitaur.sector := location
				reproduce_msg.append ("  reproduced [" + new_janitaur.id.out + ",J] at [" + new_janitaur.sector.row.out + "," + new_janitaur.sector.col.out +
				"," + new_janitaur.sector.quadrant.out + "]")
				-- add it to all the sectors lists
				if attached{ENTITY}new_janitaur as add then
					cur_sector.add_entity_to_all_lists (add)
				end
				Result := true -- successfully reproduced
				actions_left_until_reproduction := 2 --reset for next reproduction
			else -- end if
				if not (actions_left_until_reproduction = 0) then
					actions_left_until_reproduction := actions_left_until_reproduction - 1
				elseif cur_sector.is_full then
					-- unable to reproduce. reproduce next time entity acts
				end
			end
		end

	behave(cur_sector : SECTOR)
		local
			sorted_movable_sector_ents : ARRAYED_LIST[MOVABLE_ENTITY]
		do
--		    Unless its maximum_load_level has been reached,
--			looks for asteroids to implode and haul away
--			(where it destroys all the asteroids in that sector
--			and incrementing the load level by the number of asteroids destroyed).
--			If there are multiple asteroids and not enough room in the janitaur,
--			lower id asteroids are targeted first.
			create destroy_msg.make
			create deaths_by_janitaur.make
			sorted_movable_sector_ents := cur_sector.sector_sorted -- deep_twin so cant modify this
			if turns_left = 0 then
				if load < max_load then
					from
						sorted_movable_sector_ents.start
					until
						sorted_movable_sector_ents.exhausted
					loop
						if  sorted_movable_sector_ents.item.is_asteroid and load < max_load then
							destroy_msg.extend("  destroyed [" + sorted_movable_sector_ents.item.id.out + ",A] at [" +
							sorted_movable_sector_ents.item.sector.row.out + "," + sorted_movable_sector_ents.item.sector.col.out + "," +
							sorted_movable_sector_ents.item.sector.quadrant.out + "]")

							if attached {ASTEROID}sorted_movable_sector_ents.item as a then
								deaths_by_janitaur.extend ("[" + a.id.out + ",A]->turns_left:N/A,")
								a.death_msg.append ("Asteroid got imploded by janitaur (id: " + Current.id.out + ") at Sector:" + Current.sector.row.out +
								":" + Current.sector.col.out)
								deaths_by_janitaur.extend ("  " + a.death_msg.out)
							end

							cur_sector.remove_entity(sorted_movable_sector_ents.item,true) -- removes from all sector lists and
							-- sets is alive to false if the entity being passed in is movable
							load := load + 1 -- killed an asteroid so load increases
						end
						sorted_movable_sector_ents.forth
					end
				end -- end load condition

			end -- end if turnleft = 0

--			If a wormhole is in the current
--			sector, it will then throw all the asteroids into it,
--			clearing the load level. Note the asteroids thrown into
--			the wormhole do not appear anywhere.

			if cur_sector.contents.has (create {ENTITY_ALPHABET}.make ('W'))  then -- this sector has a wormhole
				load := 0 -- clear the load if there is a wormhole in this sector
			end

			turns_left := gen.rchoose(0,2)
		end
end

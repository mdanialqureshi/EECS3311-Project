note
	description: "Summary description for {BENIGN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BENIGN

inherit
	MOVABLE_ENTITY

create
	make

feature -- constructor

	make(id_num:INTEGER;turns: INTEGER;location: TUPLE[INTEGER,INTEGER,INTEGER])
		do
			make_movable_entity ('B')
			is_benign := true
			id := id_num
			turns_left := turns
			sector := location
			fuel := 3
			actions_left_until_reproduction := 1
			create death_msg.make_empty
			create reproduce_msg.make_empty
			create destroy_msg.make
			is_alive := true
		end

feature -- variables

	fuel: INTEGER
	death_msg : STRING
	reproduce_msg : STRING
	destroy_msg : LINKED_LIST[STRING]
	actions_left_until_reproduction : INTEGER

feature -- commands

	check_benign(cur_sector : SECTOR; used_wormhole : BOOLEAN; moved : BOOLEAN)
		local
			contents : ARRAYED_LIST [ENTITY_ALPHABET]
		do
			contents := cur_sector.contents
			if not(used_wormhole) and moved then
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
				is_alive := false
				death_msg.append ("Benign got lost in space - out of fuel at Sector:" + sector.row.out + ":" + sector.col.out)
			elseif contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_alive := false
				death_msg.append ("Benign got devoured by blackhole (id: -1) at Sector:3:3")
			end
			-- asteroid death handled in asteroid class

			if not (is_alive) then -- remove from board if its no longer alive
				cur_sector.remove_entity(Current, true) -- removes from all sector lists and
			end
		end


	reproduce(cur_sector : SECTOR; next_movable_id: INTEGER) : BOOLEAN --reproduces every 2 turns
		local
			new_benign : BENIGN
			location : TUPLE [INTEGER_32, INTEGER_32, INTEGER_32]
			quad : INTEGER
			counter : INTEGER
			added : BOOLEAN
		do
			Result := false
			reproduce_msg.make_empty
			if not (cur_sector.is_full) and actions_left_until_reproduction = 0 then
				-- impelement
				create location.default_create
				-- create the reproduced one
				create new_benign.make (next_movable_id, gen.rchoose (0, 2),location)
				cur_sector.put (new_benign.icon, false) --add entity to sectors available contents quadrant position
				quad := cur_sector.recently_added
				location := [sector.row,sector.col,quad]
				new_benign.sector := location
				reproduce_msg.append ("  reproduced [" + new_benign.id.out + ",B] at [" + new_benign.sector.row.out + "," + new_benign.sector.col.out + "," +
				new_benign.sector.quadrant.out + "]")
				-- add it to all the sectors lists
				if attached{ENTITY}new_benign as add then
					cur_sector.add_entity_to_all_lists (add)
				end
				Result := true -- successfully reproduced
				actions_left_until_reproduction := 1 --reset for next reproduction
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
			-- iterate thru sectors contents list and
			-- kill all the malevolents in order of
			-- lowest to highest id
			sorted_movable_sector_ents := cur_sector.sector_sorted -- deep_twin so cant modify this
			create destroy_msg.make
			if turns_left = 0 then
				from
					sorted_movable_sector_ents.start
				until
					sorted_movable_sector_ents.exhausted
				loop
					if  sorted_movable_sector_ents.item.is_malevolent then
						destroy_msg.extend("  destroyed [" + sorted_movable_sector_ents.item.id.out + ",M] at [" + sorted_movable_sector_ents.item.sector.row.out +
						"," + sorted_movable_sector_ents.item.sector.col.out + "," + sorted_movable_sector_ents.item.sector.quadrant.out + "]")
						cur_sector.remove_entity(sorted_movable_sector_ents.item, true) -- removes from all sector lists and
						-- sets is alive to false if the entity being passed in is movable
					end
					sorted_movable_sector_ents.forth
				end

			end -- end if turnleft = 0
			turns_left := gen.rchoose(0,2)
		end


end

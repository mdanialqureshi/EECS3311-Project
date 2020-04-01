note
	description: "Summary description for {MALEVOLENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MALEVOLENT

inherit
	MOVABLE_ENTITY

create
	make

feature -- constructor

	make(id_num:INTEGER;turns: INTEGER;location: TUPLE[INTEGER,INTEGER,INTEGER])
		do
			make_movable_entity ('M')
			is_malevolent := true
			id := id_num
			turns_left := turns
			sector := location
			fuel := 3
			actions_left_until_reproduction := 1
			create death_msg.make_empty
			create reproduce_msg.make_empty
			create attack_msg.make_empty
			is_alive := true
		end

feature -- variables

	fuel: INTEGER
	death_msg : STRING
	reproduce_msg : STRING
	attack_msg : STRING
	actions_left_until_reproduction : INTEGER

feature -- commands

	check_malevolent(cur_sector : SECTOR; used_wormhole : BOOLEAN; moved : BOOLEAN)
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
				death_msg.append ("Malevolent got lost in space - out of fuel at Sector:" + sector.row.out + ":" + sector.col.out)
			elseif contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_alive := false
				death_msg.append ("Malevolent got devoured by blackhole (id: -1) at Sector:3:3")
			end
			-- asteroid death handled in asteroid class
			-- benign also kills it, handled in benign class
			if not (is_alive) then -- remove from board if its no longer alive
				cur_sector.remove_entity(Current, true) -- removes from all sector lists and
			end

		end


	reproduce(cur_sector : SECTOR; next_movable_id: INTEGER) : BOOLEAN --reproduces every 2 turns
		local
			new_malevolent : MALEVOLENT
			location : TUPLE [INTEGER_32, INTEGER_32, INTEGER_32]
			quad : INTEGER
		do
			Result := false
			reproduce_msg.make_empty
			if not (cur_sector.is_full) and actions_left_until_reproduction = 0 then
				-- impelement
				create location.default_create
				-- create the reproduced one
				create new_malevolent.make (next_movable_id, gen.rchoose (0, 2),location)
				cur_sector.put (new_malevolent.icon, false) --add entity to sectors available contents quadrant position
				quad := cur_sector.recently_added
				location := [sector.row,sector.col,quad]
				new_malevolent.sector := location
				reproduce_msg.append ("  reproduced [" + new_malevolent.id.out + ",M] at [" + new_malevolent.sector.row.out + ","
				+ new_malevolent.sector.col.out + "," + new_malevolent.sector.quadrant.out + "]")
				-- add it to all the sectors lists
				if attached{ENTITY}new_malevolent as add then
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


	behave(cur_sector : SECTOR; exp : EXPLORER)
		local
			explorer : EXPLORER
		do
			-- looks for non-landed explorer to attack
			-- reduce life of explorer by 1 each time
			-- malevolent attacks
			attack_msg.make_empty
			if turns_left = 0 then
				create explorer.make
				if cur_sector.contents.has (create {ENTITY_ALPHABET}.make ('E'))
				and not (cur_sector.contents.has (create {ENTITY_ALPHABET}.make ('B'))) then
					explorer := exp

					if not (explorer.is_landed) then
						attack_msg.append ("  attacked [0,E] at [" + exp.sector.row.out + "," + exp.sector.col.out + "," + exp.sector.quadrant.out + "]")
						explorer.life := explorer.life - 1
						if explorer.life = 0 then -- explorer is dead
							cur_sector.remove_entity (explorer, true) -- remove explorer from sector lists
							-- @@@@ need to add the death message for out of life for explorer @@ --
						end
					end
				end
			end

			turns_left := gen.rchoose(0,2)
		end
end

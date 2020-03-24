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
			is_alive := true
		end

feature -- variables

	fuel: INTEGER
	death_msg : STRING
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

		end


	reproduce(cur_sector : SECTOR; next_movable_id: INTEGER) --reproduces every 2 turns
		local
			new_malevolent : MALEVOLENT
			location : TUPLE [INTEGER_32, INTEGER_32, INTEGER_32]
			quad : INTEGER
			counter : INTEGER
			added : BOOLEAN
		do
			if not (cur_sector.is_full) and actions_left_until_reproduction = 0 then
				-- impelement
				create location.default_create
				added := false
				counter := sector.quadrant + 1 -- the next quadrant beside this benign
				from -- find free quadrent after parent benign
					cur_sector.contents.start
				until
					added -- loop must terminate b/c sector isnt full
				loop
					if cur_sector.contents[counter].item ~ '-' and counter <= 4 then
						quad := counter
						added := true
					end
					counter := counter + 1
					if counter > 4 then
						counter := 1
					end
				end
				location := [sector.row,sector.col,quad]
				-- create the reproduced one
				create new_malevolent.make (next_movable_id, gen.rchoose (0, 2),location)

				-- add it to all the sectors lists
				if attached{ENTITY}new_malevolent as add then
					cur_sector.add_entity_to_all_lists (add)
				end

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
			explorer : EXPLORER
		do
			-- looks for non-landed explorer to attack
			-- reduce life of explorer by 1 each time
			-- malevolent attacks
			if turns_left = 0 then
				create explorer.make
				if cur_sector.contents.has (create {ENTITY_ALPHABET}.make ('E'))
				and not (cur_sector.contents.has (create {ENTITY_ALPHABET}.make ('B'))) then
					across cur_sector.entities as ent loop
						if ent.item.is_explorer then
							if attached{EXPLORER}ent as ex then
								explorer := ex -- obtain the explorer instance
							end
						end
					end -- end across

					if not (explorer.is_landed) then
						explorer.life := explorer.life - 1
						if explorer.life = 0 then -- explorer is dead
							cur_sector.remove_entity (explorer) -- remove explorer from sector lists
							-- @@@@ need to add the death message for out of life for explorer @@ --
						end
					end


				end
			end

			turns_left := gen.rchoose(0,2)
		end
end

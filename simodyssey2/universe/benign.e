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
			id := id_num
			turns_left := turns
			sector := location
			fuel := 3
			actions_left_until_reproduction := 1
			create death_msg.make_empty
			is_destroyed := false
		end

feature -- variables

	turns_left: INTEGER assign set_turns_left
	fuel: INTEGER
	death_msg : STRING
	actions_left_until_reproduction : INTEGER
	is_destroyed : BOOLEAN

feature -- commands

	set_turns_left(turns: INTEGER)
		do
			turns_left := turns
		end

	update_benign(cur_sector : SECTOR; used_wormhole : BOOLEAN; moved : BOOLEAN; next_movable_id: INTEGER)
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
				is_destroyed := TRUE
				death_msg.append ("Benign got lost in space - out of fuel at Sector:" + sector.row.out + ":" + sector.col.out)
			elseif contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_destroyed := TRUE
				death_msg.append ("Benign got devoured by blackhole (id: -1) at Sector:3:3")
			end
			-- add astroid condition

			if not (actions_left_until_reproduction = 0) then
				actions_left_until_reproduction := actions_left_until_reproduction - 1
			else
				reproduce(cur_sector,next_movable_id)
			end

		end


	reproduce(cur_sector : SECTOR; next_movable_id: INTEGER) --reproduces every 2 turns
		do
			if not (cur_sector.is_full) then
				-- impelement
			end


			actions_left_until_reproduction := 1 --set it back for next reproduction
		end

	behave(cur_sector : SECTOR)
		do
			-- iterate thru sectors contents list and
			-- kill all the malevolents in order of
			-- lowest to highest id
			turns_left := gen.rchoose(0,2)
		end
end

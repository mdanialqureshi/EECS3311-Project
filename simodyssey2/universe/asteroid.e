note
	description: "Summary description for {ASTROID}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ASTEROID

inherit
	MOVABLE_ENTITY

create
	make

feature -- constructor

	make(id_num:INTEGER;turns: INTEGER;location: TUPLE[INTEGER,INTEGER,INTEGER])
		do
			make_movable_entity ('A')
			is_asteroid := true
			id := id_num
			turns_left := turns
			sector := location
			create death_msg.make_empty
			is_alive := true
		end

feature -- variables

	death_msg : STRING

feature -- commands

	check_asteroid(cur_sector : SECTOR;moved : BOOLEAN)
		local
			contents : ARRAYED_LIST [ENTITY_ALPHABET]
		do
			contents := cur_sector.contents


			if contents.has (create {ENTITY_ALPHABET}.make ('O')) then
				is_alive := false
				death_msg.append ("Asteroid got devoured by blackhole (id: -1) at Sector:3:3")
			end
			-- janitaur condition is handled in janitaur class. 

		end

	behave(cur_sector : SECTOR)
		local
			sorted_movable_sector_ents : ARRAYED_LIST[MOVABLE_ENTITY]
		do
			-- Seeks any other movable entities in its sector
			-- except planets and other asteroids and destroys
			-- all of them in ascending id order. (Note that explorer
			-- cannot be hit if it is landed).

			sorted_movable_sector_ents := cur_sector.sector_sorted -- deep_twin so cant modify this
			if turns_left = 0 then
				from
					sorted_movable_sector_ents.start
				until
					sorted_movable_sector_ents.exhausted
				loop
					if  not (sorted_movable_sector_ents.item.is_asteroid) and -- if its not an asteroid of a planet kill it
						not (sorted_movable_sector_ents.item.is_planet) then
							if attached{EXPLORER}sorted_movable_sector_ents.item as ex then -- is it an explorer, if so check if its landed
								if not (ex.is_landed) then
									cur_sector.remove_entity(sorted_movable_sector_ents.item) -- kill explorer if its not landed, ignore it if it is landed
								end
							else
								cur_sector.remove_entity(sorted_movable_sector_ents.item) -- removes from all sector lists and
								-- sets is alive to false if the entity being passed in is movable
							end
					end
					sorted_movable_sector_ents.forth
				end
			end -- end if turnleft = 0

			turns_left := gen.rchoose(0,2)
		end
end

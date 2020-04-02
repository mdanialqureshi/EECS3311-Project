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
			create destroy_msg.make
			create deaths_by_asteroid.make
			is_alive := true
		end

feature -- variables

	death_msg : STRING
	destroy_msg : LINKED_LIST[STRING]
	deaths_by_asteroid: LINKED_LIST[STRING]
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

			if not (is_alive) then -- remove from board if its no longer alive
				cur_sector.remove_entity(Current, true) -- removes from all sector lists and
			end


		end

	behave(cur_sector : SECTOR; exp: EXPLORER)
		local
			sorted_movable_sector_ents : ARRAYED_LIST[MOVABLE_ENTITY]
			quadrant : INTEGER
		do
			-- Seeks any other movable entities in its sector
			-- except planets and other asteroids and destroys
			-- all of them in ascending id order. (Note that explorer
			-- cannot be hit if it is landed).
			create destroy_msg.make
			create deaths_by_asteroid.make
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
								if not (exp.is_landed) then
									destroy_msg.extend ("  destroyed [0,E] at [" + exp.sector.row.out + "," + exp.sector.col.out + "," + exp.sector.quadrant.out + "]")
									exp.death_msg.append ("Explorer got destroyed by asteroid (id: " + Current.id.out + ") at Sector:"+ Current.sector.row.out +
									":" + Current.sector.col.out)
									exp.life := 0
									exp.is_alive := false
									cur_sector.remove_entity(sorted_movable_sector_ents.item,true) -- kill explorer if its not landed, ignore it if it is landed
								end
							else
								destroy_msg.extend ("  destroyed [" + sorted_movable_sector_ents.item.id.out + "," + sorted_movable_sector_ents.item.icon.out +
								"] at [" + sorted_movable_sector_ents.item.sector.row.out + "," + sorted_movable_sector_ents.item.sector.col.out + "," +
								sorted_movable_sector_ents.item.sector.quadrant.out + "]")
								if attached {BENIGN}sorted_movable_sector_ents.item as b then

									deaths_by_asteroid.extend ("["+ b.id.out + ",B]->fuel:" + b.fuel.out + "/3, actions_left_until_reproduction:" +
									b.actions_left_until_reproduction.out + "/1, turns_left:N/A,")
									b.death_msg.append ("Benign got destroyed by asteroid (id: " + Current.id.out + ") at Sector:" + Current.sector.row.out + ":" +
									Current.sector.col.out)
									deaths_by_asteroid.extend ("  " + b.death_msg)
								end
								if attached {JANITAUR}sorted_movable_sector_ents.item as j then

									deaths_by_asteroid.extend ("["+ j.id.out + ",J]->fuel:" + j.fuel.out + "/5, load:" + j.load.out +
									"/2, actions_left_until_reproduction:" + j.actions_left_until_reproduction.out + "/2, turns_left:N/A,")
									j.death_msg.append ("Janitaur got destroyed by asteroid (id: " + Current.id.out + ") at Sector:" + Current.sector.row.out +
									":" + Current.sector.col.out)
									deaths_by_asteroid.extend ("  " + j.death_msg)
								end
								if attached {MALEVOLENT}sorted_movable_sector_ents.item as m then

									deaths_by_asteroid.extend ("["+ m.id.out + ",M]->fuel:" + m.fuel.out + "/3, actions_left_until_reproduction:" +
									m.actions_left_until_reproduction.out + "/1, turns_left:N/A,")
									m.death_msg.append ("Malevolent got destroyed by asteroid (id: " + Current.id.out + ") at Sector:" + Current.sector.row.out +
									":" + Current.sector.col.out)
									deaths_by_asteroid.extend ("  " + m.death_msg)
								end
								cur_sector.remove_entity(sorted_movable_sector_ents.item,true) -- removes from all sector lists and
								-- sets is alive to false if the entity being passed in is movable
							end
					end
					sorted_movable_sector_ents.forth
				end
			end -- end if turnleft = 0

			turns_left := gen.rchoose(0,2)
		end
end

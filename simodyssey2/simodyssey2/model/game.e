note
	description: "A game that simulates if corona virus gets out of hand, and we need to explore the universe to find a new habitable planet"
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
	revision: "$Revision$"

class
	GAME

inherit
	ANY
		redefine
			out
		end

create {GAME_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		local
			access : SHARED_INFORMATION_ACCESS
		do
			info := access.shared_info
			create g.make_dummy
			state1 := 0
			state2 := 0
			in_game := false
			create movements.make
			create land_err.make_empty
			create land_msg.make_empty
			create liftoff_err.make_empty
			create liftoff_msg.make_empty
			create wormhole_err.make_empty
			create wormhole_msg.make_empty
			create move_msg.make_empty
			create move_err.make_empty
			create play_err.make_empty
			create status_msg.make_empty
			create status_err.make_empty
			create pass_err.make_empty
			create test_err.make_empty
			create test_msg.make_empty
			create abort_err.make_empty
			create abort_msg.make_empty
			create mode.make_empty
			test_mode := false
			used_wormhole := false
			moved := false
		end

feature -- model attributes
	state1 : INTEGER
	state2 : INTEGER
	g : GALAXY
	info : SHARED_INFORMATION
	in_game : BOOLEAN
	movements: LINKED_LIST[STRING]
	test_mode : BOOLEAN
	land_err :STRING
	land_msg : STRING
	liftoff_err : STRING
	liftoff_msg : STRING
	wormhole_err : STRING
	wormhole_msg : STRING
	move_msg: STRING
	move_err : STRING
	play_err : STRING
	status_msg : STRING
	status_err : STRING
	pass_err : STRING
	test_err : STRING
	test_msg : STRING
	abort_err : STRING
	abort_msg : STRING
	mode : STRING
	used_wormhole : BOOLEAN
	moved : BOOLEAN



feature -- model operations

	reset
			-- Reset model state.
		do
			make
		end

	play
		do
			clear_messages
			if not (in_game) then
				in_game := true
				test_mode := false
				-- set threshold for play mode
				info.set_asteroid_threshold (3)
				info.set_janitaur_threshold (5)
				info.set_malevolent_threshold (7)
				info.set_benign_threshold (15)
	        	info.set_planet_threshold(30)
	         	create g.make(false)
	         	next_state (true)
	         	create mode.make_from_string ("play")
	        else
				next_state (false)
				play_err.append("To start a new mission, please abort the current one first.")
	        end

		end

	test(a_threshold: INTEGER_32 ; j_threshold: INTEGER_32 ; m_threshold: INTEGER_32 ; b_threshold: INTEGER_32 ; p_threshold: INTEGER_32)
		do
			clear_messages
			if in_game then -- in play mode
				next_state (false)
				test_err.append ("To start a new mission, please abort the current one first.")
			else
				test_mode := true
				in_game := true
				info.set_planet_threshold (p_threshold)
				create g.make(true)
				next_state (true)
				create mode.make_from_string ("test")
			end

		end

	turn(action : STRING;dir : INTEGER)
			do
				act(action,dir)
				-- if an error does not occur (turn does not occur)
				if no_error then
					g.explorer.update_explorer(g.grid[g.explorer.sector.row,g.explorer.sector.col].contents, used_wormhole,moved) -- update explorer (fuel life etc)
					if not g.explorer.is_alive then --dead explorer
						g.grid[g.explorer.sector.row,g.explorer.sector.col].remove_entity (g.explorer,true) -- if explorer died, remove
					end

					if not(land_msg.is_equal ("Tranquility base here - we've got a life!")) then
						across g.movable_entities as m_entity loop --across all movable entites (except explorer)
							moved := false -- reset for every entity
							used_wormhole := false
							-- When an entity dies, remove it from board
							-- If it is not an explorer, also remove entity from the movable
							-- entities being iterated over
							-- this is handled by the alive check below
							if m_entity.item.turns_left = 0 and m_entity.item.is_alive then
								-- special case for planet
								if m_entity.item.is_planet and (g.grid[m_entity.item.sector.row,m_entity.item.sector.col].contents.has (create {ENTITY_ALPHABET}.make ('Y'))
									or g.grid[m_entity.item.sector.row,m_entity.item.sector.col].contents.has (create {ENTITY_ALPHABET}.make ('*'))) then
										if attached {PLANET}m_entity as planet then
											planet.in_orbit := true
											if g.grid[planet.sector.row,planet.sector.col].contents.has (create {ENTITY_ALPHABET}.make ('Y')) then
												if g.gen.rchoose (1, 2) = 2 then
													planet.support_life := true
												end
											end
										end
								else--end planet conditional

									if g.grid[m_entity.item.sector.row,m_entity.item.sector.col].contents.has (
										create {ENTITY_ALPHABET}.make ('W')) and (m_entity.item.is_malevolent
										or m_entity.item.is_benign) then -- if there is a wormhole in this sector
										-- if this entity is a malevolent or benign it prefers wormhole
										if attached {MALEVOLENT}m_entity.item as m then
											wormhole(m) -- fix this wormhole issue
										end
										if attached {BENIGN}m_entity.item as b then
											wormhole(b) -- fix this wormhole issue
										end

									else -- end wormhole conditional
										movement(m_entity.item) -- implement
									end
									-- preform checks
									if attached {MALEVOLENT}m_entity.item as m then
										m.check_malevolent (g.grid[m.sector.row,m.sector.col], used_wormhole, moved)
									end

									if attached {BENIGN}m_entity.item as b then
										b.check_benign (g.grid[b.sector.row,b.sector.col], used_wormhole, moved)
									end
									if attached {JANITAUR}m_entity.item as j then
										j.check_janitaur (g.grid[j.sector.row,j.sector.col], moved)
									end
									if attached {ASTEROID}m_entity.item as a then
										a.check_asteroid (g.grid[a.sector.row,a.sector.col], moved)
									end
									if attached {PLANET}m_entity.item as p then
										p.check_planet (g.grid[p.sector.row,p.sector.col])
									end

									if m_entity.item.is_alive then -- if it is alive
										-- reproduce, need to add reproduced entities to galazy movable entities list
										if attached {MALEVOLENT}m_entity.item as m then
											if m.reproduce (g.grid[m.sector.row,m.sector.col], g.next_movable_id) then
												g.next_movable_id := g.next_movable_id + 1 --handle case where it does not reproduce
											end
										end
										if attached {BENIGN}m_entity.item as b then
											if b.reproduce (g.grid[b.sector.row,b.sector.col], g.next_movable_id) then
												g.next_movable_id := g.next_movable_id + 1 --handle case where it does not reproduce
											end
										end
										if attached {JANITAUR}m_entity.item as j then
											if j.reproduce (g.grid[j.sector.row,j.sector.col], g.next_movable_id) then
												g.next_movable_id := g.next_movable_id + 1 --handle case where it does not reproduce
											end
										end

										-- behave
										if attached {MALEVOLENT}m_entity.item as m then
											m.behave (g.grid[m.sector.row,m.sector.col],g.explorer)
										end
										if attached {BENIGN}m_entity.item as b then
											b.behave (g.grid[b.sector.row,b.sector.col])
										end
										if attached {JANITAUR}m_entity.item as j then
											j.behave (g.grid[j.sector.row,j.sector.col])
										end
										if attached {PLANET}m_entity.item as p then
											p.new_behave (g.grid[p.sector.row,p.sector.col])
										end

									end
								end
							else -- end turnsleft = 0 conditional
								m_entity.item.turns_left := m_entity.item.turns_left - 1
							end
						end -- end across movable entities
					end -- end land msg conditional
				end -- end no error conditional
				moved := false -- reset for every entity
				used_wormhole := false
				update_movable_entities
			end

	update_movable_entities -- update the galaxy movable_entities list incase there was reproduction of entities
		do
			across 1|..| info.number_rows as i loop
				across 1|..| info.number_columns as j loop
					across 1|..| g.grid[i.item,j.item].movable_entities.count as k loop
						if not (g.movable_entities.has (g.grid[i.item,j.item].movable_entities[k.item])) then
							g.movable_entities.extend (g.grid[i.item,j.item].movable_entities[k.item]) -- add the new entity
						end
					end

				end
			end
		end

	act(action : STRING;dir : INTEGER)
		do
			if action.is_equal ("pass") then
				pass
			elseif action.is_equal ("move") then
				move(dir)
			elseif action.is_equal ("wormhole") then
				wormhole(g.explorer)
			elseif action.is_equal("land") then
				land
			elseif action.is_equal ("liftoff") then
				liftoff
			end

		end

	movement(m_ent : MOVABLE_ENTITY)
		local
			vector: TUPLE[row:INTEGER;col:INTEGER] -- vector of the direction we want to move ex. North is [-1,0]
			dest : TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER] --entities sector field to be updated
			added: BOOLEAN
			dir : INTEGER
		do
			added := false
			dir := g.gen.rchoose (1, 8)
			vector := g.directions[dir]
			dest := [m_ent.sector.row + vector.row, m_ent.sector.col + vector.col, 0]

			if dest.row = 0 then
				dest.row := 5

			elseif dest.row = 6 then
				dest.row := 1
			end

			if dest.col = 0 then
				dest.col := 5

			elseif dest.col = 6 then
				dest.col := 1
			end

			if not g.grid[dest.row,dest.col].is_full then
				moved := true
				if attached{ENTITY}m_ent as ent then -- remove from all sector lists
					g.grid[m_ent.sector.row,m_ent.sector.col].remove_entity (ent,false)
				end

				g.grid[dest.row,dest.col].put (m_ent.icon, false) --add entity to sectors available contents quadrant position

				dest.quadrant := g.grid[dest.row,dest.col].recently_added
				m_ent.sector := dest

				g.grid[dest.row,dest.col].add_entity_to_all_lists (m_ent) -- add to all sector lists

			end

		end

	move(dir: INTEGER)

		local
			vector: TUPLE[row:INTEGER;col:INTEGER] -- vector of the direction we want to move ex. North is [-1,0]
			explorer_dest : TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER] --explorers sector field to be updated
			temp_index : INTEGER -- index of where explorer is placed in quarant of a sector
			is_valid : BOOLEAN
			added: BOOLEAN
		do
			clear_messages
			added := false
			is_valid := true
			vector := g.directions[dir]
			explorer_dest := [g.explorer.sector.row + vector.row, g.explorer.sector.col + vector.col, 0]

			if not (in_game) then -- is it in a game
				move_err.append ("Negative on that request:no mission in progress.")
				is_valid := false

			elseif g.explorer.is_landed then
				move_err.append ("Negative on that request:you are currently landed at Sector:" + g.explorer.sector.row.out + ":" + g.explorer.sector.col.out)
				is_valid := false
			end

			if not (is_valid) then
				next_state(false)
			end

			if is_valid then
				if explorer_dest.row = 0 then
					explorer_dest.row := 5

				elseif explorer_dest.row = 6 then
					explorer_dest.row := 1
				end

				if explorer_dest.col = 0 then
					explorer_dest.col := 5

				elseif explorer_dest.col = 6 then
					explorer_dest.col := 1
				end
				if not g.grid[explorer_dest.row,explorer_dest.col].is_full then
					moved := true
					next_state (true)
				-- start moving explorer
					g.grid[g.explorer.sector.row,g.explorer.sector.col].remove_entity (g.explorer, false)

					g.grid[explorer_dest.row,explorer_dest.col].put(g.explorer.icon,false) --add explorer to sectors available quadrant position

					g.grid[explorer_dest.row,explorer_dest.col].add_entity_to_all_lists (g.explorer) --add explorer tosectors  lists

					temp_index := g.grid[explorer_dest.row,explorer_dest.col].contents.index_of (g.explorer.icon,1) -- index of first occurance of E in quadrants
					explorer_dest.quadrant := temp_index
					move_msg.append ("[" + "0,E]:[" + g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]->[")
					g.explorer.sector := explorer_dest
					move_msg.append (g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]")
					movements.extend(move_msg)


--					-- move planets
--					across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
--						movements.extend (curr.item)
--					end -- finish moving planets
--					g.explorer.update_explorer(g.grid[g.explorer.sector.row,g.explorer.sector.col].contents, false) -- update explorer (fuel life etc)

				else
					move_err.append("Cannot transfer to new location as it is full." )
					next_state (false)
				end 	-- end moving explorer
			end
			-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			-- *NOTE* after we move the explorer do the explorer check to see if still alive and if not handle it accordingly
			-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		--	g.explorer.update_explorer(g.grid[g.explorer.sector.row,g.explorer.sector.col].contents, false) -- update explorer (fuel life etc)
--			if not g.explorer.death_msg.is_empty then
--				g.grid[g.explorer.sector.row,g.explorer.sector.col].contents[g.grid[g.explorer.sector.row,g.explorer.sector.col].contents.index_of (g.explorer.icon, 1)] := create {ENTITY_ALPHABET}.make ('-')
--				g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.prune (g.explorer)
--			end

		end

	land
		local
			row : INTEGER
			col : INTEGER
			is_valid : BOOLEAN
			all_visited : BOOLEAN -- have all the planets in this sector already been visited?
			not_found : BOOLEAN
		do
			clear_messages
			row := g.explorer.sector.row
			col := g.explorer.sector.col
			all_visited := true
			is_valid := true
			not_found := true
			if not (in_game) then -- is it in a game
				land_err.append ("Negative on that request:no mission in progress.")
				is_valid := false
			elseif g.explorer.is_landed then --is the explorer landed already
				land_err.append ("Negative on that request:already landed on a planet at Sector:" + row.out + ":" + col.out)
				is_valid := false
			elseif not (g.grid[row,col].contents.has (create {ENTITY_ALPHABET}.make ('Y'))) then -- is there a yellow star
				land_err.append ("Negative on that request:no yellow dwarf at Sector:" + row.out + ":" + col.out)
				is_valid := false
			elseif not (g.grid[row,col].contents.has (create {ENTITY_ALPHABET}.make ('P')))  then
				land_err.append ("Negative on that request:no planets at Sector:" + row.out + ":" + col.out)
				is_valid := false
			end

			if not (is_valid) then
				next_state(false)
			end

			if is_valid then
				across g.grid[row,col].planets_sorted as i loop
					if not (i.item.visited) and i.item.in_orbit and not_found then
						all_visited := false
						g.explorer.is_landed := true
						if i.item.support_life then
							land_msg.append ("Tranquility base here - we've got a life!")
							in_game := false
							if test_mode then
								test_mode := false
							end
						else
							land_msg.append ("Explorer found no life as we know it at Sector:" + row.out + ":" + col.out)
						end
						not_found := false
						across g.grid[row,col].movable_entities as m_entity
						loop
							if attached{PLANET}m_entity.item as curr then
								if curr.id ~ i.item.id then
									curr.visited := true
								end
							end
						end
					end
				end
				if all_visited then
					land_err.append ("Negative on that request:no unvisited attached planet at Sector:" + row.out + ":" + col.out)
					next_state(false)
				else
					next_state(true)
					if in_game then
--						across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
--								movements.extend (curr.item)
--						end
					end
				end

			end

		end


	liftoff
		local
			row : INTEGER
			col : INTEGER
			is_valid : BOOLEAN
		do
			clear_messages
			is_valid := true
			row := g.explorer.sector.row
			col := g.explorer.sector.col
			if not (in_game) then -- is not in a game
				liftoff_err.append ("Negative on that request:no mission in progress.")
				is_valid := false
			elseif not (g.explorer.is_landed) then --is the explorer landed already
				liftoff_err.append ("Negative on that request:you are not on a planet at Sector:" + row.out + ":" + col.out)
				is_valid := false
			end


			if not (is_valid) then
				next_state(false)
			end

			if is_valid then
				next_state (true)
				liftoff_msg.append ("Explorer has lifted off from planet at Sector:" + row.out + ":" + col.out)
				g.explorer.is_landed := false
--				across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
--					movements.extend (curr.item)
--				end
			end

		end

	wormhole (m_ent : MOVABLE_ENTITY)
		local
			row : INTEGER
			col : INTEGER
			is_valid : BOOLEAN
			added : BOOLEAN -- has the explorer been wormholed successfully
			temp_row : INTEGER
			temp_col : INTEGER
			dest : TUPLE[INTEGER,INTEGER,INTEGER] --ent sector field to be updated
			temp_index : INTEGER -- index of where entity is placed in quarant of a sector
			added_ent: BOOLEAN
		do
			clear_messages
			added := false
			added_ent := false
			is_valid := true
			row := m_ent.sector.row
			col := m_ent.sector.col
			if not (in_game) then -- is it in a game
				wormhole_err.append ("Negative on that request:no mission in progress.")
				is_valid := false
			elseif  g.explorer.is_landed and m_ent.is_explorer then --is the explorer landed already
				wormhole_err.append ("Negative on that request:you are currently landed at Sector:" + row.out + ":" + col.out)
				is_valid := false
			elseif not (g.grid[row,col].contents.has (create {ENTITY_ALPHABET}.make ('W'))) and m_ent.is_explorer then
				wormhole_err.append ("Explorer couldn't find wormhole at Sector:"+ row.out + ":" + col.out)
				is_valid := false
			end

			if not (is_valid) then
				next_state(false)
			end

			if is_valid then

				if m_ent.is_explorer then
					next_state (true)
					wormhole_msg.append ("[" + "0,E]:[" + m_ent.sector.row.out + "," + m_ent.sector.col.out + "," + m_ent.sector.quadrant.out + "]")
				end
				from
					added := false
				until
					added
				loop
					temp_row := g.gen.rchoose (1,5)
					temp_col := g.gen.rchoose (1,5)
					if not (g.grid[temp_row,temp_col].is_full) or ((m_ent.sector.row ~ temp_row) and (m_ent.sector.col ~ temp_col)) then
						used_wormhole := true
						if attached{ENTITY}m_ent as ent then
							g.grid[row,col].remove_entity (ent,false) -- remove from all sectors lists
						end

						g.grid[temp_row,temp_col].put (m_ent.icon,false) --add entity to sectors available quadrant position
						g.grid[temp_row,temp_col].add_entity_to_all_lists (m_ent) -- add to all sector lists

						create dest.default_create
						temp_index := g.grid[temp_row,temp_col].recently_added -- index of recently added ent in quadrants
						dest := [temp_row,temp_col,temp_index] -- assign to movable entities sector the row col and quadrant index

						if not (dest ~ m_ent.sector) then
							m_ent.sector := dest
							wormhole_msg.append ("->[" + m_ent.sector.row.out + "," + m_ent.sector.col.out + "," + m_ent.sector.quadrant.out + "]")
						end
						movements.extend (wormhole_msg)
						added := true
					end

				end -- end from loop
			end -- end is valid
		end

	status
		local
			row : INTEGER
			col : INTEGER
			quad : INTEGER
		do
			clear_messages
			if in_game then -- if its in game
				row := g.explorer.sector.row
				col := g.explorer.sector.col
				quad := g.explorer.sector.quadrant
				if g.explorer.is_landed then
					status_msg.append ("Explorer status report:Stationary on planet surface at [" + row.out + "," + col.out + "," + quad.out + "]%N")
				else
					status_msg.append ("Explorer status report:Travelling at cruise speed at [" + row.out + "," + col.out + "," + quad.out + "]%N")
  				end
  				status_msg.append ("  Life units left:" + g.explorer.life.out + ", Fuel units left:" + g.explorer.fuel.out)
  			else -- not in a game
  				status_err.append ("Negative on that request:no mission in progress.")
  			end

  			next_state (false) -- status always only increments state by 0.1

		end

	pass

		do
			clear_messages
			if not in_game then
				pass_err.append("Negative on that request:no mission in progress.")
				next_state(false)

			else
--				across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
--					movements.extend (curr.item)
--				end
				next_state(true)
			end

		end

	abort
		do
			clear_messages
			if in_game then
				abort_msg.append ("Mission aborted. Try test(3,5,7,15,30)")
			else
				abort_err.append ("Negative on that request:no mission in progress.")
			end
			-- in_game := false --set this value after we are done using it for the output so in abort_string
			next_state (false) -- abort always increases the state by 0.1
		end

	next_state(ceil : BOOLEAN) -- increment the state accordingly. if it is not and error (not + 0.1) then ceil is true
		do
			if ceil then
				state1 := state1 + 1
				state2 := 0
			else
				state2 := state2 + 1
			end

		end

	clear_messages --clear all error and success messages
		do
			create land_err.make_empty
			create land_msg.make_empty
			create liftoff_err.make_empty
			create liftoff_msg.make_empty
			create wormhole_err.make_empty
			create wormhole_msg.make_empty
			create status_err.make_empty
			create status_msg.make_empty
			create abort_err.make_empty
			create abort_msg.make_empty
			create move_err.make_empty
			create land_err.make_empty
			create pass_err.make_empty
			create move_msg.make_empty
			create movements.make
			create play_err.make_empty
			create test_err.make_empty
			g.explorer.death_msg.make_empty
		end

feature -- queries

	no_error : BOOLEAN
		do
			Result := (land_err.is_empty and liftoff_err.is_empty and wormhole_err.is_empty and status_err.is_empty
					 and abort_err.is_empty and move_err.is_empty and land_err.is_empty and pass_err.is_empty
					 and play_err.is_empty and test_err.is_empty)
		end

feature -- queries

	out : STRING
		do
			create Result.make_from_string ("  ")
			-- empty both strings since this land situation has been dealt with in output
			if in_game then
				if not (test_mode) then
					Result.append (play_mode_in_game_output)
				else
					Result.append (test_mode_in_game_output)
				end

			else -- not in a game
				if not(move_err.is_empty) or not (land_err.is_empty) or not (liftoff_err.is_empty) or
				not (wormhole_err.is_empty) or not (status_err.is_empty) or not (pass_err.is_empty) or
				not (abort_err.is_empty) or not (move_err.is_empty) then -- add the rest of the commands after implementation e.g pass
					Result.append ("state:" + state1.out + "." + state2.out + ", error%N")
					Result.append ("  Negative on that request:no mission in progress.")
				elseif land_msg.out.is_equal ("Tranquility base here - we've got a life!") then
					Result.append ("state:" + state1.out + "." + state2.out + ", mode:" + mode + ", ok%N")
					Result.append("  " + land_msg)
				elseif not (g.explorer.death_msg.is_empty) then
					Result.append (explorer_death_string)
				elseif not(abort_msg.is_empty) then
					Result.append ("state:" + state1.out + "." + state2.out + ", ok%N")
					Result.append("  " + abort_msg)
				else -- not in a game and no errors such as invalid commands outside game like move
					Result.append ("state:" + state1.out + "." + state2.out +", ok%N")
					Result.append ("  ")
					if state1 = 0 and state2 = 0 then
						Result.append ("Welcome! Try test(3,5,7,15,30)")
					end
				end
			end
		end

	play_mode_in_game_output : STRING
		do
			create Result.make_empty
			if not (land_err.is_empty) or not (land_msg.is_empty) then -- land messages
				Result.append(land_string)
			elseif not (play_err.is_empty) then -- user requested play while in a game
				Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, error%N")
				Result.append ("  " + play_err)
			elseif not(test_err.is_empty) then -- user requested test while in a game
				Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, error%N")
				Result.append ("  " + test_err)
			elseif not (liftoff_err.is_empty) or not (liftoff_msg.is_empty) then -- handle liftoff outputs (errors and success messages)
				Result.append (lift_off_string)
			elseif not (wormhole_err.is_empty) or not (wormhole_msg.is_empty) then -- handle wormhole outputs (errors and success messages)
				Result.append (wormhole_string)
			elseif not (status_err.is_empty) or not (status_msg.is_empty) then -- handle status outputs (errors and success messages)
				Result.append (status_string)
			elseif not (abort_err.is_empty) or not (abort_msg.is_empty) then -- handle abort outputs (errors and success messages)
				Result.append (abort_string)
			elseif not (move_err.is_empty) then -- handle move outputs (errors and success messages)
				Result.append (move_string)
			elseif not(g.explorer.death_msg.is_empty) then -- handle explorer death outputs (erros and success messages)
				Result.append (explorer_death_string)
			else
				Result.append (play_string)
				Result.append(g.out) -- print the board out
			end
		end

	test_mode_in_game_output : STRING
		do
			create Result.make_empty
			if not (land_err.is_empty) or not (land_msg.is_empty) then -- land messages
				Result.append(land_string)
			elseif not (play_err.is_empty) then -- user requested play while in a game
				Result.append ("state:" + state1.out + "." + state2.out + ", mode:test, error%N")
				Result.append ("  " + play_err)
			elseif not(test_err.is_empty) then -- user requested test while in a game
				Result.append ("state:" + state1.out + "." + state2.out + ", mode:test, error%N")
				Result.append ("  " + test_err)
			elseif not (liftoff_err.is_empty) or not (liftoff_msg.is_empty) then -- handle liftoff outputs (errors and success messages)
				Result.append (lift_off_string)
			elseif not (wormhole_err.is_empty) or not (wormhole_msg.is_empty) then -- handle wormhole outputs (errors and success messages)
				Result.append (wormhole_string)
			elseif not (status_err.is_empty) or not (status_msg.is_empty) then -- handle status outputs (errors and success messages)
				Result.append (status_string)
			elseif not (abort_err.is_empty) or not (abort_msg.is_empty) then -- handle abort outputs (errors and success messages)
				Result.append (abort_string)
			elseif not (move_err.is_empty) then -- handle move outputs (errors and success messages)
				Result.append (move_string)
			elseif not(g.explorer.death_msg.is_empty) then -- handle explorer death outputs (erros and success messages)
				Result.append (explorer_death_string)
			else
				Result.append (test_string)
				Result.append(g.out) -- print the board out
			end
		end

	test_string : STRING
		do
			create Result.make_empty
			Result.append(test_mode_sectors)
			Result.append (test_mode_descriptions)
			Result.append (test_mode_deaths)
		end

	test_mode_sectors : STRING
		local
			temp_entities : ARRAYED_LIST[ENTITY]
			curr_sector : SECTOR
			counter : INTEGER
		do
			create Result.make_empty
			create temp_entities.make(4)
			counter := 1
			Result.append ("state:" + state1.out + "." + state2.out + ", mode:test, ok%N")
			if not(g.explorer.death_msg.is_empty) then
				Result.append ("  " + g.explorer.death_msg + "%N")
				Result.append ("  The game has ended. You can start a new game.%N")
			end
			Result.append(play_string)
			Result.append("%N  Sectors:%N")
			across 1 |..| info.number_rows as i loop  --rows
				across 1 |..| info.number_columns as j loop   --coloumns
					curr_sector := g.grid[i.item,j.item]
					Result.append("    [" + curr_sector.row.out + "," + curr_sector.column.out
					 + "]->")
					 temp_entities := curr_sector.entities
					 across 1 |..| 4 as k loop

						if  curr_sector.entities[k.item].icon.item ~ ('-') then
							Result.append ("-")
						else
							if not g.explorer.death_msg.is_empty and curr_sector.entities[k.item].icon.item ~ 'E' then
								Result.append("-")
							else
								Result.append("[" + curr_sector.entities[k.item].id.out +
								"," + curr_sector.entities[k.item].icon.item.out + "]")
							end

						end

						if not (k.item ~ 4) then
							Result.append (",")
						end
					 -- add a newline at the end of each sectors outputs
				end
				 Result.append ("%N")
			end --end across 2
		end -- end across 1
	end

	test_mode_descriptions : STRING
		local
			counter : INTEGER
		do
			create Result.make_empty
			Result.append ("  Descriptions:%N")
			from
				counter := g.stationary_items.count
			until
				counter = 0
			loop
				Result.append("    [" + g.stationary_items[counter].id.out + "," + g.stationary_items[counter].icon.item.out + "]->")
				if g.stationary_items[counter].is_star then
					Result.append("Luminosity:" + g.stationary_items[counter].luminosity.out)
				end
				Result.append ("%N")
				counter := counter - 1
			end -- end from loop
				if g.explorer.death_msg.is_empty then
					Result.append ("    [" + g.explorer.id.out + "," + g.explorer.icon.item.out + "]->fuel:" + g.explorer.fuel.out +
					"/3, life:" + g.explorer.life.out + "/3, landed?:" + g.explorer.boolean_icon (g.explorer.is_landed) + "%N")
				end
				across g.movable_entities as m_entity loop
					if attached{PLANET}m_entity.item as p then
						if p.is_alive then

						Result.append ("    [" + p.id.out + "," + p.icon.item.out + "]->attached?:" +
							p.boolean_icon (p.in_orbit) + ", support_life?:" + p.boolean_icon (p.support_life)
							+ ", visited?:" + p.boolean_icon (p.visited) + ", turns_left:")
							if not (p.in_orbit) then
								Result.append (p.turns_left.out)
							else
								Result.append ("N/A")
							end
							Result.append ("%N")
						end
					end -- end attached if
				end -- end across
		end

	test_mode_deaths : STRING
		do
			create Result.make_empty
			Result.append ("  Deaths This Turn:")
			if g.dead_planets.is_empty and g.explorer.death_msg.is_empty then
				Result.append ("none")
			else
				if not(g.explorer.death_msg.is_empty) then
					Result.append ("%N" + explorer_death_string_helper)
				end
				if not (g.dead_planets.is_empty) then
					Result.append("%N" + planet_death_string)
				end
			end
		end

	play_string : STRING
		local
			count : INTEGER
		do
			create Result.make_empty
			count := 1
			if g.explorer.death_msg.is_empty and not (test_mode) then
				Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, ok%N")
			end
			if not (land_msg.is_empty) then -- landed but no life found on planet
				Result.append ("  " + land_msg + "%N")
			elseif not (liftoff_msg.is_empty) then
				Result.append ("  " + liftoff_msg + "%N") -- successfully liftoff of a planet
			end

				if movements.is_empty then
					Result.append ("  Movement:none" )
				else
					Result.append ("  Movement:" )
					across movements as curr loop
						if count ~ 1 then
							Result.append("%N")
						end
						Result.append ("    " + curr.item.out)
						if not (count ~ movements.count) then
							Result.append("%N")
						end
						count := count + 1

					end
				end
		end


	land_string : STRING
		do
			create Result.make_empty
			if land_msg.out.is_equal ("Tranquility base here - we've got a life!") then
				if test_mode then
					Result.append ("state:" + state1.out + "." + state2.out + ", mode:test, ok%N")
					Result.append("  " + land_msg)
				else
					Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, ok%N")
					Result.append("  " + land_msg)
				end
			elseif not (land_msg.is_empty) then -- no life found after landing
				if test_mode then
					Result.append (test_string)
					Result.append(g.out) -- print the board out
				else
					Result.append (play_string)
					Result.append(g.out) -- print the board out
				end
			elseif not (land_err.is_empty) then
				if test_mode then
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:test, error%N")
					Result.append ("  " + land_err)
				else
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, error%N")
					Result.append ("  " + land_err)
				end
			end

		end


	lift_off_string : STRING
		do
			create Result.make_empty
			if not (liftoff_err.is_empty) then
				if test_mode then
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:test, error%N")
					Result.append ("  " + liftoff_err)
				else
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, error%N")
					Result.append ("  " + liftoff_err)
				end
			elseif not (liftoff_msg.is_empty) then
				if test_mode then
					Result.append (test_string)
				else
					Result.append(play_string)
				end
				Result.append(g.out) -- print the board out
			end
		end

	wormhole_string : STRING
		do
			create Result.make_empty
			if not (wormhole_err.is_empty) then
				if test_mode then
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:test, error%N")
					Result.append ("  " + wormhole_err)
				else
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, error%N")
					Result.append ("  " + wormhole_err)
				end
			elseif not (wormhole_msg.is_empty) then
				if test_mode then
					Result.append (test_string)
					Result.append (g.out)

				else
					Result.append (play_string)
					Result.append (g.out)
				end
			end

		end

	status_string : STRING
		do
			create Result.make_empty
			if in_game then
				if test_mode then
					Result.append ("state:" + state1.out + "." + state2.out + ", mode:test, ok%N")
					Result.append ("  " + status_msg)
				else
					Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, ok%N")
					Result.append ("  " + status_msg)
				end
			end

		end

	abort_string : STRING
		do
			create Result.make_empty
			if in_game then
					Result.append ("state:" + state1.out + "." + state2.out + ", ok%N")
					Result.append("  " + abort_msg)
				in_game := false -- done using this value so set it to false
				if test_mode then -- if in test mode exit it
					test_mode := false
				end
			else
				Result.append ("state:" + state1.out + "." + state2.out + ", error%N")
				Result.append ("  " + abort_err)
			end
		end

	move_string : STRING
		do
			create Result.make_empty
			if g.explorer.is_landed then
				if test_mode then
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:test, error%N")
					Result.append("  " + move_err)
				else
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, error%N")
					Result.append("  " + move_err)
				end
			else
				if test_mode then
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:test, error%N")
					Result.append ("  " + move_err)
				else
					Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, error%N")
					Result.append ("  " + move_err)
				end
			end
		end

	explorer_death_string : STRING
		do
			create Result.make_empty
			if test_mode then
				Result.append (test_string)
				Result.append (g.out + "%N")
				Result.append ("  " + g.explorer.death_msg + "%N")
				Result.append ("  The game has ended. You can start a new game.")
			else
				Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, ok%N")
				Result.append ("  " + g.explorer.death_msg + "%N")
				Result.append ("  The game has ended. You can start a new game.%N")
				Result.append (play_string)
				Result.append (g.out)
			end
			in_game := false -- end the game since the explorer is dead
		end

	planet_death_string : STRING
		local
			num_dead_planets : INTEGER
		do
			num_dead_planets := g.dead_planets.count
			create Result.make_empty
			if not(g.dead_planets.is_empty) then
				across 1 |..| num_dead_planets as p loop
					Result.append ("    [" + g.dead_planets[p.item].id.out + "," + g.dead_planets[p.item].icon.item.out + "]->attached?:" +
					g.dead_planets[p.item].boolean_icon (g.dead_planets[p.item].in_orbit) + ", support_life?:" + g.dead_planets[p.item].boolean_icon (g.dead_planets[p.item].support_life)
					+ ", visited?:" + g.dead_planets[p.item].boolean_icon (g.dead_planets[p.item].visited) + ", turns_left:N/A,%N      " + g.dead_planets[p.item].death_msg)
					if not (p.item ~ num_dead_planets) then
						Result.append ("%N")
					end
				end
				g.clear_dead_planets
			end
		end

	explorer_death_string_helper : STRING
		do
			create Result.make_empty
			Result.append ("    [" + g.explorer.id.out + "," + g.explorer.icon.item.out + "]->fuel:" + g.explorer.fuel.out +
				"/3, life:" + g.explorer.life.out + "/3, landed?:" + g.explorer.boolean_icon (g.explorer.is_landed) + ",%N")
			Result.append("      " + g.explorer.death_msg)
		end
end

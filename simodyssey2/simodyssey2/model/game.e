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
					next_state (true)
					g.grid[g.explorer.sector.row,g.explorer.sector.col].contents[g.grid[g.explorer.sector.row,g.explorer.sector.col].contents.index_of(g.explorer.icon,1)] := create {ENTITY_ALPHABET}.make ('-') -- remove explorer from previous sector
				--	g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.prune (g.explorer) -- remove the explorer from old sectors entities list
					from
						g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.start
					until
						g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.exhausted
					loop
						if g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.item ~ g.explorer then
							g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.replace (create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('-'), 150))
						end
						g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.forth
					end
					g.grid[g.explorer.sector.row,g.explorer.sector.col].contents_count := g.grid[g.explorer.sector.row,g.explorer.sector.col].contents_count - 1
					g.grid[explorer_dest.row,explorer_dest.col].put(g.explorer.icon,false) --add explorer to sectors available quadrant position
					--g.grid[explorer_dest.row,explorer_dest.col].entities.extend (g.explorer) --add explorer tosectors entities list
					from
						g.grid[explorer_dest.row,explorer_dest.col].entities.start
					until
						added
					loop
						if g.grid[explorer_dest.row,explorer_dest.col].entities.item.icon.item ~ '-' then
							g.grid[explorer_dest.row,explorer_dest.col].entities.replace (g.explorer)
							added := true
						end
						g.grid[explorer_dest.row,explorer_dest.col].entities.forth
					end
					temp_index := g.grid[explorer_dest.row,explorer_dest.col].contents.index_of (g.explorer.icon,1) -- index of first occurance of E in quadrants
					explorer_dest.quadrant := temp_index
					move_msg.append ("[" + "0,E]:[" + g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]->[")
					g.explorer.sector := explorer_dest
					move_msg.append (g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]")
					movements.extend(move_msg)

					across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
						movements.extend (curr.item)
					end
					g.explorer.update_explorer(g.grid[g.explorer.sector.row,g.explorer.sector.col].contents, false) -- update explorer (fuel life etc)

				else
					move_err.append("Cannot transfer to new location as it is full." )
					next_state (false)
				end
			end


			-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			-- *NOTE* after we move the explorer do the explorer check to see if still alive and if not handle it accordingly
			-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		--	g.explorer.update_explorer(g.grid[g.explorer.sector.row,g.explorer.sector.col].contents, false) -- update explorer (fuel life etc)
			if not g.explorer.death_msg.is_empty then
				g.grid[g.explorer.sector.row,g.explorer.sector.col].contents[g.grid[g.explorer.sector.row,g.explorer.sector.col].contents.index_of (g.explorer.icon, 1)] := create {ENTITY_ALPHABET}.make ('-')
				g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.prune (g.explorer)
			end

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
						across g.grid[row,col].planets as curr
						loop
							if curr.item.id ~ i.item.id then
								curr.item.visited := true
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
						across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
								movements.extend (curr.item)
						end
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
				across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
					movements.extend (curr.item)
				end
			end

		end

	wormhole
		local
			row : INTEGER
			col : INTEGER
			is_valid : BOOLEAN
			added : BOOLEAN -- has the explorer been wormholed successfully
			temp_row : INTEGER
			temp_col : INTEGER
			explorer_dest : TUPLE[INTEGER,INTEGER,INTEGER] --explorers sector field to be updated
			temp_index : INTEGER -- index of where explorer is placed in quarant of a sector
			added_ent: BOOLEAN
		do
			clear_messages
			added := false
			added_ent := false
			is_valid := true
			row := g.explorer.sector.row
			col := g.explorer.sector.col
			if not (in_game) then -- is it in a game
				wormhole_err.append ("Negative on that request:no mission in progress.")
				is_valid := false
			elseif  g.explorer.is_landed then --is the explorer landed already
				wormhole_err.append ("Negative on that request:you are currently landed at Sector:" + row.out + ":" + col.out)
				is_valid := false
			elseif not (g.grid[row,col].contents.has (create {ENTITY_ALPHABET}.make ('W'))) then
				wormhole_err.append ("Explorer couldn't find wormhole at Sector:"+ row.out + ":" + col.out)
				is_valid := false
			end


			if not (is_valid) then
				next_state(false)
			end

			if is_valid then
				next_state (true)
				wormhole_msg.append ("[" + "0,E]:[" + g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]")
				from
					added := false
				until
					added
				loop

					temp_row := g.gen.rchoose (1,5)
					temp_col := g.gen.rchoose (1,5)
					if not (g.grid[temp_row,temp_col].is_full) or ((g.explorer.sector.row ~ temp_row) and (g.explorer.sector.col ~ temp_col)) then
						g.grid[row,col].contents[g.grid[row,col].contents.index_of(g.explorer.icon,1)] := create {ENTITY_ALPHABET}.make ('-') -- remove explorer from previous sector
						--g.grid[row,col].entities.prune (g.explorer) -- remove the explorer from old sectors entities list
						from
							g.grid[row,col].entities.start
						until
							g.grid[row,col].entities.exhausted
						loop
							if g.grid[row,col].entities.item ~ g.explorer then
								g.grid[row,col].entities.replace (create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('-'), 150))
							end
							g.grid[row,col].entities.forth
						end
						g.grid[row,col].contents_count := g.grid[row,col].contents_count - 1
						g.grid[temp_row,temp_col].put (g.explorer.icon,false) --add explorer to sectors available quadrant position
					--	g.grid[temp_row,temp_col].entities.extend (g.explorer) --add explorer to sectors entities list
						from
							g.grid[temp_row,temp_col].entities.start
						until
							added_ent
						loop
							if g.grid[temp_row,temp_col].entities.item.icon.item ~ '-' then
								g.grid[temp_row,temp_col].entities.replace (g.explorer)
								added_ent := true
							end
							g.grid[temp_row,temp_col].entities.forth
						end
						create explorer_dest.default_create
						temp_index := g.grid[temp_row,temp_col].contents.index_of (g.explorer.icon,1) -- index of first occurance of E in quadrants
						explorer_dest := [temp_row,temp_col,temp_index] -- assign to explorer sector the row col and quadrant index
						if not (explorer_dest ~ g.explorer.sector) then
						g.explorer.sector := explorer_dest
						g.explorer.update_explorer(g.grid[g.explorer.sector.row,g.explorer.sector.col].contents, true) -- update explorer (fuel life etc)
						wormhole_msg.append ("->[" + g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]")
						end
						movements.extend (wormhole_msg)
						added := true

					end

				end
				across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
					movements.extend (curr.item)
				end
				if not g.explorer.death_msg.is_empty then
					g.grid[g.explorer.sector.row,g.explorer.sector.col].contents[g.grid[g.explorer.sector.row,g.explorer.sector.col].contents.index_of (g.explorer.icon, 1)] := create {ENTITY_ALPHABET}.make ('-')
					from
						g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.start
					until
						g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.exhausted
					loop
						if g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.item ~ g.explorer then
							g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.replace (create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('-'), 150))
						end
						g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.forth
					end
				--	g.grid[g.explorer.sector.row,g.explorer.sector.col].entities.prune (g.explorer)
				end

			end
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
				across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
					movements.extend (curr.item)
				end
				next_state(true)
			end

		end

	abort
		do
			clear_messages
			if in_game then
				abort_msg.append ("Mission aborted. Try test(30)")
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
			create move_err.make_empty
			create move_msg.make_empty
			create movements.make
			create play_err.make_empty
			create test_err.make_empty
			g.explorer.death_msg.make_empty
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
						Result.append ("Welcome! Try test(30)")
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
				across g.planets as p loop
					if p.item.is_alive then

					Result.append ("    [" + p.item.id.out + "," + p.item.icon.item.out + "]->attached?:" +
						p.item.boolean_icon (p.item.in_orbit) + ", support_life?:" + p.item.boolean_icon (p.item.support_life)
						+ ", visited?:" + p.item.boolean_icon (p.item.visited) + ", turns_left:")
						if not (p.item.in_orbit) then
							Result.append (p.item.turns_left.out)
						else
							Result.append ("N/A")
						end
						Result.append ("%N")
					end
				end
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

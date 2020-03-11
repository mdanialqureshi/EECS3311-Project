note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
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

		end

feature -- model attributes
	state1 : INTEGER
	state2 : INTEGER
	old_state1 : INTEGER
	old_state2 : INTEGER
	g : GALAXY
	info : SHARED_INFORMATION
	in_game : BOOLEAN
	movements: LINKED_LIST[STRING]
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


feature -- model operations
	default_update
			-- Perform update to the model state.
		do

		end

	reset
			-- Reset model state.
		do
			make
		end

	play
		do
			if not (in_game) then
				in_game := true
				-- set threshold to be 30 for play
	        	info.set_planet_threshold(30)
	         	create g.make
	         	next_state (true)
	        else
				next_state (false)
				play_err.append("To start a new mission, please abort the current one first.")
	        end

		end

	move(dir: INTEGER)

		local
			vector: TUPLE[row:INTEGER;col:INTEGER] -- vector of the direction we want to move ex. North is [-1,0]
			explorer_dest : TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER] --explorers sector field to be updated
			temp_index : INTEGER -- index of where explorer is placed in quarant of a sector
			is_valid : BOOLEAN
		do
			create move_err.make_empty
			create move_msg.make_empty
			create movements.make
			is_valid := true
			vector := g.directions[dir]
			explorer_dest := [g.explorer.sector.row + vector.row, g.explorer.sector.col + vector.col, 0]

			if not (in_game) then -- is it in a game
				move_err.append ("Negative on that request:no mission in progress.")
				is_valid := false

			elseif g.explorer.is_landed then
				move_err.append ("Negative on that request:already landed on a planet at Sector:" + g.explorer.sector.row.out + ":" + g.explorer.sector.col.out)
				is_valid := false
			end

			if not (is_valid) then
				next_state (false)
			end

			if is_valid then
				next_state (true)
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

					g.grid[g.explorer.sector.row,g.explorer.sector.col].contents[g.grid[g.explorer.sector.row,g.explorer.sector.col].contents.index_of(g.explorer.icon,1)] := create {ENTITY_ALPHABET}.make ('-') -- remove explorer from previous sector
					g.grid[g.explorer.sector.row,g.explorer.sector.col].contents_count := g.grid[g.explorer.sector.row,g.explorer.sector.col].contents_count - 1
					g.grid[explorer_dest.row,explorer_dest.col].put(g.explorer.icon,false) --add explorer to sectors available quadrant position
					temp_index := g.grid[explorer_dest.row,explorer_dest.col].contents.index_of (g.explorer.icon,1) -- index of first occurance of E in quadrants
					explorer_dest.quadrant := temp_index
					move_msg.append ("[" + "0,E]:[" + g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]->[")
					g.explorer.sector := explorer_dest
					move_msg.append (g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]")
					movements.extend(move_msg)

					across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
						movements.extend (curr.item)
					end

				else
					move_err.append("Cannot transfer to new location as it is full." )
				end
			end


			-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			-- *NOTE* after we move the explorer do the explorer check to see if still alive and if not handle it accordingly
			-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		end

	land
		local
			row : INTEGER
			col : INTEGER
			is_valid : BOOLEAN
			all_visited : BOOLEAN -- have all the planets in this sector already been visited?
			not_found : BOOLEAN
		do
			create land_err.make_empty
			create land_msg.make_empty
			create movements.make
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
				next_state(true)
				across g.grid[row,col].planets_sorted as i loop
					if not (i.item.visited) and i.item.in_orbit and not_found then
						all_visited := false
						g.explorer.is_landed := true
						if i.item.support_life then
							land_msg.append ("Tranquility base here - we've got a life!")
							in_game := false
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
				else
					across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
						movements.extend (curr.item)
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
			create liftoff_err.make_empty
			create liftoff_msg.make_empty
			create movements.make
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
		do
			create wormhole_err.make_empty
			create wormhole_msg.make_empty
			create movements.make
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
				wormhole_msg.append ("[" + "0,E]:[" + g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]->[")
				from
					added := false
				until
					added
				loop
					temp_row := g.gen.rchoose (1,5)
					temp_col := g.gen.rchoose (1,5)
					if not (g.grid[temp_row,temp_col].is_full) then
						g.grid[row,col].contents[g.grid[row,col].contents.index_of(g.explorer.icon,1)] := create {ENTITY_ALPHABET}.make ('-') -- remove explorer from previous sector
						g.grid[row,col].contents_count := g.grid[row,col].contents_count - 1
						g.grid[temp_row,temp_col].put (g.explorer.icon,false) --add explorer to sectors available quadrant position
						create explorer_dest.default_create
						temp_index := g.grid[temp_row,temp_col].contents.index_of (g.explorer.icon,1) -- index of first occurance of E in quadrants
						explorer_dest := [temp_row,temp_col,temp_index] -- assign to explorer sector the row col and quadrant index
						g.explorer.sector := explorer_dest
						wormhole_msg.append (g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]")
						movements.extend (wormhole_msg)
						added := true

					end
				end
				across g.check_planets as curr loop  -- check all the planets to see which ones need to be moved and iterate through the returned List of strings to append them to our movements List
					movements.extend (curr.item)
				end
			end
		end

	status
		local
			row : INTEGER
			col : INTEGER
			quad : INTEGER
		do
			create status_msg.make_empty
			create status_err.make_empty
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

	abort
		do
			create abort_err.make_empty
			create abort_msg.make_empty
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
			old_state1 := state1
			old_state2 := state2
			if ceil then
				state1 := state1 + 1
				state2 := 0
			else
				state2 := state2 + 1
				if state2 = 10 then
					state1 := state1 + 1
					state2 := 0
				end
			end

		end

	clear_messages --clear all error and success messages
		do
			create land_err.make_empty
			create land_msg.make_empty
			-- empty both strings since this liftoff situation has been dealt with in output
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
		end


feature -- queries

	out : STRING
		do
			create Result.make_from_string ("  ")
			-- empty both strings since this land situation has been dealt with in output
			if not (old_state1 ~ state1) and not (old_state2 ~ state2) then
				clear_messages
			end

			if in_game then
				if not (land_err.is_empty) or not (land_msg.is_empty) then -- land messages
					Result.append(land_string)
				elseif not (play_err.is_empty) then -- user requested play while in a game
					Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, error%N")
					Result.append ("  " + play_err)
					create play_err.make_empty -- make it empty after we finish
				elseif not (liftoff_err.is_empty) or not (liftoff_msg.is_empty) then -- handle liftoff outputs (errors and success messages)
					Result.append (lift_off_string)
				elseif not (wormhole_err.is_empty) or not (liftoff_msg.is_empty) then -- handle wormhole outputs (erros and success messages)
					Result.append (wormhole_string)
				elseif not (status_err.is_empty) or not (status_msg.is_empty) then -- handle status outputs (erros and success messages)
					Result.append (status_string)
				elseif not (abort_err.is_empty) or not (abort_msg.is_empty) then -- handle abort outputs (erros and success messages)
					Result.append (abort_string)
				else
					Result.append (play_string)
					Result.append(g.out) -- print the board out
				end

			else -- not in a game
				if not(move_err.is_empty) or not (land_err.is_empty) or not (liftoff_err.is_empty) or
				not (wormhole_err.is_empty) or not (status_err.is_empty) or not (pass_err.is_empty) or
				not (abort_err.is_empty) then -- add the rest of the commands after implementation e.g pass
					Result.append ("state:" + state1.out + "." + state2.out + ", error%N")
					Result.append ("  Negative on that request:no mission in progress.")
				elseif land_msg.out.is_equal ("Tranquility base here - we've got a life!") then
					Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, ok%N")
					Result.append("  " + land_msg)
				else -- not in a game and no errors such as invalid commands outside game like move
					Result.append ("state:" + state1.out + "." + state2.out +", ok%N")
					Result.append ("  ")
					if state1 = 0 and state2 = 0 then
						Result.append ("Welcome! Try test(30)")
					end
				end
			end
		end



	play_string : STRING
		local
			count : INTEGER
		do
			create Result.make_empty
			count := 1
			Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, ok%N")
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
				Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, ok%N")
				Result.append("  " + land_msg)
			elseif not (land_msg.is_empty) then -- no life found after landing
				Result.append (play_string)
				Result.append(g.out) -- print the board out
			elseif not (land_err.is_empty) then
				Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, error%N")
				Result.append ("  " + land_err)
			end

		end


	lift_off_string : STRING
		do
			create Result.make_empty
			if not (liftoff_err.is_empty) then
				Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, error%N")
				Result.append ("  " + liftoff_err)
			elseif not (liftoff_msg.is_empty) then
				Result.append (play_string)
				Result.append(g.out) -- print the board out
			end
		end

	wormhole_string : STRING
		do
			create Result.make_empty
			if not (wormhole_err.is_empty) then
				Result.append ("state:" + state1.out + "." +  state2.out + ", mode:play, error%N")
				Result.append ("  " + wormhole_err)
			elseif not (wormhole_msg.is_empty) then
				Result.append (play_string)
				Result.append (g.out)
			end

		end

	status_string : STRING
		do
			create Result.make_empty
			if in_game then
				Result.append ("state:" + state1.out + "." + state2.out + ", mode:play, ok%N")
				Result.append ("  " + status_msg)
			end

		end

	abort_string : STRING
		do
			create Result.make_empty
			if in_game then
				Result.append ("state:" + state1.out + "." + state2.out + ", ok%N")
				Result.append("  " + abort_msg)
				in_game := false -- done using this value so set it to false
			else
				Result.append ("state:" + state1.out + "." + state2.out + ", error%N")
				Result.append ("  " + abort_err)
			end
		end


	pass_string: STRING
		do
			create Result.make_empty
		end

	test_string : STRING
		do
			create Result.make_empty
		end


end





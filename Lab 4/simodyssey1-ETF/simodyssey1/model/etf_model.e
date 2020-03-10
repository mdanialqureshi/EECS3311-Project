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
			state := 0.0
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

		end

feature -- model attributes
	state : DOUBLE
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
			in_game := true
			-- set threshold to be 30 for play
        	info.set_planet_threshold(30)
         	create g.make

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

					g.grid[g.explorer.sector.row,g.explorer.sector.col].contents.prune (g.explorer.icon) -- remove explorer from previous sector
					g.grid[explorer_dest.row,explorer_dest.col].contents.extend (g.explorer.icon) --add explorer to sectors available quadrant position
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
		do
			create land_err.make_empty
			create land_msg.make_empty
			create movements.make
			row := g.explorer.sector.row
			col := g.explorer.sector.col
			all_visited := true
			is_valid := true
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

			if is_valid then
				across g.grid[row,col].planets as i loop
					if not (i.item.visited) then
						all_visited := false
						g.explorer.is_landed := true
						if i.item.support_life then
							land_msg.append ("Tranquility base here - we've got a life!")
							in_game := false
						else
							land_msg.append ("Explorer found no life as we know it at Sector:" + row.out + ":" + col.out)
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
			if not (in_game) then -- is it in a game
				liftoff_err.append ("Negative on that request:no mission in progress.")
				is_valid := false
			elseif not (g.explorer.is_landed) then --is the explorer landed already
				liftoff_err.append ("Negative on that request:you are not on a planet at Sector:" + row.out + ":" + col.out)
				is_valid := false
			end

			if is_valid then
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

			if is_valid then
				wormhole_msg.append ("[" + "0,E]:[" + g.explorer.sector.row.out + "," + g.explorer.sector.col.out + "," + g.explorer.sector.quadrant.out + "]->[")
				from
					added := false
				until
					added
				loop
					temp_row := g.gen.rchoose (1,5)
					temp_col := g.gen.rchoose (1,5)
					if not (g.grid[temp_row,temp_col].is_full) then
						g.grid[row,col].contents.prune (g.explorer.icon) -- remove explorer from previous sector
						g.grid[temp_row,temp_col].contents.extend (g.explorer.icon) --add explorer to sectors available quadrant position
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

feature -- queries
	out : STRING
		local
			count: INTEGER
		do
			create Result.make_from_string ("  ")
			count := 1
			if in_game then
				Result.append ("state:" + state.out + ", mode:play, ok%N")

				if movements.is_empty then
					Result.append ("  Movement:none%N" )

				else
					Result.append ("  Movement:%N" )
					across movements as curr loop
						Result.append ("    " + curr.item.out)
						if not (count ~ movements.count) then
							Result.append("%N")
						end
						count := count + 1

					end
				end

				Result.append(g.out)
				Result.append ("%N")
			else
				Result.append ("state:" + state.out +", ok%N")
				Result.append ("  ")
				if state = 0.0 then
					Result.append ("Welcome! Try test(30)")
				end
			end
			print(Result)
		end

end





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
			create land_err.make_empty
			create land_msg.make_empty
			create liftoff_err.make_empty
			create liftoff_msg.make_empty
		end

feature -- model attributes
	state : DOUBLE
	g : GALAXY
	info : SHARED_INFORMATION
	in_game : BOOLEAN
	land_err :STRING
	land_msg : STRING
	liftoff_err : STRING
	liftoff_msg : STRING


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

         	-- checker to see if planet are in orbit

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
						g.explorer.set_landed(true)
						if i.item.support_life then
							land_msg.append ("Tranquility base here - we've got a life!")
							in_game := false
						else
							land_msg.append ("Explorer found no life as we know it at Sector:" + row.out + ":" + col.out)
						end
					end
				end
			end

			if all_visited and is_valid then
				land_err.append ("Negative on that request:no unvisited attached planet at Sector:" + row.out + ":" + col.out)
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
				g.explorer.set_landed (false)
			end

		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  ")

			if in_game then
				Result.append ("state:" + state.out + ", mode:play, ok%N")
				Result.append ("  Movement:%N" )
				Result.append ("    []:[]->[]" )
				Result.append(g.out)
				Result.append ("%N")
			else
				Result.append ("state:" + state.out +", ok%N")
				Result.append ("  ")
				if state = 0.0 then
					Result.append ("Welcome! Try test(30)")
				end
			end
		end

end





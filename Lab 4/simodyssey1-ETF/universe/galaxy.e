note
	description: "Galaxy represents a game board in simodyssey."
	author: "Kevin B"
	date: "$Date$"
	revision: "$Revision$"

class
	GALAXY

inherit ANY
	redefine
		out
	end

create
	make, make_dummy

feature -- attributes

	grid: ARRAY2 [SECTOR]
			-- the board

	gen: RANDOM_GENERATOR_ACCESS

	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

	planets: LINKED_LIST[PLANET]
	planet_count: INTEGER
	explorer: EXPLORER

	directions: ARRAY[TUPLE[row:INTEGER;col:INTEGER]]
		do
			Result := <<[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1]>>
		end

feature --constructor

	make_dummy
		do
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			create planets.make
			create explorer.make
		end



	make
		-- creates a dummy of galaxy grid
		local
			row : INTEGER
			column : INTEGER
		do
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			create planets.make
			create explorer.make

			from
				row := 1
			until
				row > shared_info.number_rows
			loop

				from
					column := 1
				until
					column > shared_info.number_columns
				loop
					grid[row,column] := create {SECTOR}.make(row,column,explorer.icon,(planets.count + 1))

					across grid[row,column].planets as curr
					loop
						planets.extend (curr.item)
					end
					column:= column + 1;

				end
				row := row + 1
			end
			set_stationary_items
			inital_planet_check
	end


feature -- query

	check_planets:LINKED_LIST[STRING]  -- Returns a List of the movements from planets i.e [8,P]:[4,1,2]->[5,5,1]
		local
			move_msg : STRING
		do
			create Result.make
			create move_msg.make_empty
			across planets as curr
			loop
				if (curr.item.turns_left = 0) and (not curr.item.in_orbit) then
					move_msg.append ("[" + curr.item.id.out + ",P]:[" + curr.item.sector.row.out + "," + curr.item.sector.col.out + "," + curr.item.sector.quadrant.out + "]->[")
					if move_planet(curr.item) then
						move_msg.append (curr.item.sector.row.out + "," + curr.item.sector.col.out + "," + curr.item.sector.quadrant.out + "]")
						Result.extend (move_msg)
					end
					create move_msg.make_empty
				else
					curr.item.turns_left := curr.item.turns_left - 1
				end
			end
		end


feature --commands

	set_stationary_items
			-- distribute stationary items amongst the sectors in the grid.
			-- There can be only one stationary item in a sector
		local
			loop_counter: INTEGER
			check_sector: SECTOR
			temp_row: INTEGER
			temp_column: INTEGER
		do
			from
				loop_counter := 1
			until
				loop_counter > shared_info.number_of_stationary_items
			loop

				temp_row :=  gen.rchoose (1, shared_info.number_rows)
				temp_column := gen.rchoose (1, shared_info.number_columns)
				check_sector := grid[temp_row,temp_column]
				if (not check_sector.has_stationary) and (not check_sector.is_full) then
					grid[temp_row,temp_column].put (create_stationary_item)
					loop_counter := loop_counter + 1
				end -- if
			end -- loop
		end -- feature set_stationary_items

	create_stationary_item: ENTITY_ALPHABET
			-- this feature randomly creates one of the possible types of stationary actors
		local
			chance: INTEGER
		do
			chance := gen.rchoose (1, 3)
			inspect chance
			when 1 then
				create Result.make('Y')
			when 2 then
				create Result.make('*')
			when 3 then
				create Result.make('W')
			else
				create Result.make('Y') -- create more yellow dwarfs this will never happen, but create by default
			end -- inspect
		end

feature {NONE} -- command

	inital_planet_check  -- when we first initialize the galaxy if a planet is in the same sector as a star we set in_orbit to true

		do
			across planets as curr
			loop
				if grid[curr.item.sector.row,curr.item.sector.col].contents.has(create {ENTITY_ALPHABET}.make ('Y')) then
					curr.item.in_orbit := true
				elseif grid[curr.item.sector.row,curr.item.sector.col].contents.has(create {ENTITY_ALPHABET}.make ('*')) then
					curr.item.in_orbit := true
				end
			end
		end


	move_planet(p: PLANET): BOOLEAN -- moves a planet to a random neighbor (returns true if the planet was moved successfully)

		local
			vector: TUPLE[row:INTEGER;col:INTEGER]
			rand_dir: RANDOM_GENERATOR_ACCESS
			planet_dest : TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER] --planet's sector field to be updated
			prev_index : INTEGER -- previous index of our planet in the SECTOR planets list(we need this to remove 'P' from previous sector contents i.e PP_ _  ->  _ P _ _ )
			prev_index_found: BOOLEAN -- boolean flag used when searching for the prev_index
			old_contents_index: INTEGER -- previous index of our planet in the SECTOR contents list
			counter: INTEGER
		do

			counter := 1
			prev_index := 1
			prev_index_found := false
			vector := directions[(rand_dir.rchoose (1, 8))]
			planet_dest := [p.sector.row + vector.row, p.sector.col + vector.col,0]

			if planet_dest.row = 0 then
				planet_dest.row := 5

			elseif planet_dest.row = 6 then
				planet_dest.row := 1
			end

			if planet_dest.col = 0 then
				planet_dest.col := 5

			elseif planet_dest.col = 6 then
				planet_dest.col := 1
			end

			if not grid[planet_dest.row,planet_dest.col].is_full then


				across grid[p.sector.row,p.sector.col].planets as curr	-- this loop finds the index of our planet in the planets list defined in SECTOR
				loop
					if curr.item.id ~ p.id then
						prev_index_found := true
					end

					if not prev_index_found then
						prev_index := prev_index + 1
					end
				end

				old_contents_index := grid[p.sector.row,p.sector.col].contents.index_of (p.icon,prev_index) -- index of our planet in its old contents list

				from
					grid[p.sector.row,p.sector.col].contents.start
				until
					grid[p.sector.row,p.sector.col].contents.exhausted
				loop

					if counter ~ old_contents_index then
						grid[p.sector.row,p.sector.col].contents.remove
					else
						grid[p.sector.row,p.sector.col].contents.forth
					end

					counter := counter + 1

				end


				grid[planet_dest.row,planet_dest.col].contents.extend (p.icon) --add planet to sectors available quadrant position
				planet_dest.quadrant := grid[planet_dest.row,planet_dest.col].contents.count
				p.sector := planet_dest
				p.behave (grid[p.sector.row,p.sector.col].contents)
				Result := true

			else
				Result := false
			end





			-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			-- *NOTE* after we move the planet do the planet behave call to see if still alive and if not handle it accordingly
			-- if it died we need to remove from sector and from planets list in galaxy
			-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		end


feature -- query
	out: STRING
	--Returns grid in string form
	local
		string1: STRING
		string2: STRING
		row_counter: INTEGER
		column_counter: INTEGER
		contents_counter: INTEGER
		temp_sector: SECTOR
		temp_component: ENTITY_ALPHABET
		printed_symbols_counter: INTEGER
	do
		create Result.make_empty
		create string1.make(7*shared_info.number_rows)
		create string2.make(7*shared_info.number_columns)
		string1.append("%N")

		from
			row_counter := 1
		until
			row_counter > shared_info.number_rows
		loop
			string1.append("    ")
			string2.append("    ")

			from
				column_counter := 1
			until
				column_counter > shared_info.number_columns
			loop
				temp_sector:= grid[row_counter, column_counter]
			    string1.append("(")
            	string1.append(temp_sector.print_sector)
                string1.append(")")
			    string1.append("  ")
				from
					contents_counter := 1
					printed_symbols_counter:=0
				until
					contents_counter > temp_sector.contents.count
				loop
					temp_component := temp_sector.contents[contents_counter]
					if attached temp_component as character then
						string2.append_character(character.item)
					else
						string2.append("-")
					end -- if
					printed_symbols_counter:=printed_symbols_counter+1
					contents_counter := contents_counter + 1
				end -- loop

				from
				until (shared_info.max_capacity - printed_symbols_counter)=0
				loop
						string2.append("-")
						printed_symbols_counter:=printed_symbols_counter+1

				end
				string2.append("   ")
				column_counter := column_counter + 1
			end -- loop
			string1.append("%N")
			if not (row_counter = shared_info.number_rows) then
				string2.append("%N")
			end
			Result.append (string1.twin)
			Result.append (string2.twin)

			row_counter := row_counter + 1
			string1.wipe_out
			string2.wipe_out
		end
	end


end

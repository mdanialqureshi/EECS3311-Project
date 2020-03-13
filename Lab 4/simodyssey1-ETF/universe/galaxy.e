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

	stationary_items: LINKED_LIST[STATIONARY_ENTITY]
	stationary_count: INTEGER
	planets: LINKED_LIST[PLANET]
	planet_count: INTEGER
	dead_planets: LINKED_LIST[PLANET]
	explorer: EXPLORER
	test_mode : BOOLEAN
	directions: ARRAY[TUPLE[row:INTEGER;col:INTEGER]]
		do
			Result := <<[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1]>>
		end

feature --constructor

	make_dummy
		do
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			create planets.make
			create stationary_items.make
			create explorer.make
			create dead_planets.make
		end



	make (is_test_mode : BOOLEAN)
		-- creates a dummy of galaxy grid
		local
			row : INTEGER
			column : INTEGER
		do
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			create planets.make
			create explorer.make
			create dead_planets.make
			create stationary_items.make
			test_mode := is_test_mode
			stationary_count := -2

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
					grid[row,column] := create {SECTOR}.make(row,column,explorer,(planets.count + 1))

					across grid[row,column].planets as curr
					loop
						planets.extend (curr.item)
					end
					column:= column + 1;

				end
				row := row + 1
			end
			set_stationary_items
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

				if (curr.item.turns_left = 0) and curr.item.first_check  then

					if grid[curr.item.sector.row,curr.item.sector.col].contents.has(create {ENTITY_ALPHABET}.make ('Y')) then
						curr.item.behave (grid[curr.item.sector.row,curr.item.sector.col].contents)
					elseif grid[curr.item.sector.row,curr.item.sector.col].contents.has(create {ENTITY_ALPHABET}.make ('*')) then
						curr.item.behave (grid[curr.item.sector.row,curr.item.sector.col].contents)
					end
					curr.item.first_check := false
				end


				if (curr.item.turns_left = 0) and not curr.item.in_orbit and curr.item.is_alive then
					move_msg.append ("[" + curr.item.id.out + ",P]:[" + curr.item.sector.row.out + "," + curr.item.sector.col.out + "," + curr.item.sector.quadrant.out + "]")
					if move_planet(curr.item) then
						move_msg.append ("->[" + curr.item.sector.row.out + "," + curr.item.sector.col.out + "," + curr.item.sector.quadrant.out + "]")
					end
					Result.extend (move_msg)
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
			icon: ENTITY_ALPHABET
			item: STATIONARY_ENTITY
		do
			stationary_items.extend (create {STATIONARY_ENTITY}.make (-1, 'O'))
			from
				loop_counter := 1
			until
				loop_counter > shared_info.number_of_stationary_items
			loop

				temp_row :=  gen.rchoose (1, shared_info.number_rows)
				temp_column := gen.rchoose (1, shared_info.number_columns)
				check_sector := grid[temp_row,temp_column]
				if (not check_sector.has_stationary) and (not check_sector.is_full) then
					icon := create_stationary_item
					create item.make (stationary_count, icon.item)
					if icon ~ (create {ENTITY_ALPHABET}.make('Y')) then
						item.is_star := true
						item.luminosity := 2
					elseif icon ~ (create {ENTITY_ALPHABET}.make('*')) then
						item.is_star := true
						item.luminosity := 5
					end
					stationary_items.extend (item)
					check_sector.entities.extend (item)
					stationary_count := stationary_count - 1
					grid[temp_row,temp_column].put (icon,true)
					grid[temp_row,temp_column].contents_count := grid[temp_row,temp_column].contents.count
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

	clear_dead_planets
		do
			create dead_planets.make
		end

feature {NONE} -- command


	move_planet(p: PLANET): BOOLEAN -- moves a planet to a random neighbor (returns true if the planet was moved successfully)

		local
			vector: TUPLE[row:INTEGER;col:INTEGER]
			rand_dir: RANDOM_GENERATOR_ACCESS
			planet_dest : TUPLE[row:INTEGER;col:INTEGER;quadrant:INTEGER] --planet's sector field to be updated

		do

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


			if not grid[planet_dest.row,planet_dest.col].is_full and (not p.in_orbit)then


				from															-- this loop is to remove the planet from it's previous planets list in SECTOR
					grid[p.sector.row,p.sector.col].planets.start
				until
					grid[p.sector.row,p.sector.col].planets.exhausted
				loop
					if grid[p.sector.row,p.sector.col].planets.item.id ~ p.id then
						grid[p.sector.row,p.sector.col].planets.remove
					else
						grid[p.sector.row,p.sector.col].planets.forth
					end
				end
				grid[p.sector.row,p.sector.col].contents[p.sector.quadrant] := create {ENTITY_ALPHABET}.make ('-') -- remove planet from previous sector
				grid[p.sector.row,p.sector.col].entities.prune (p) -- remove from entities list
				grid[p.sector.row,p.sector.col].contents_count := grid[p.sector.row,p.sector.col].contents_count - 1

				grid[planet_dest.row,planet_dest.col].put(p.icon,false) --add planet to sectors available quadrant position

				planet_dest.quadrant := grid[planet_dest.row,planet_dest.col].recently_added
				--grid[planet_dest.row,planet_dest.col].planets.extend (p) -- add planet to the planets list in SECTOR
				p.sector := planet_dest
			--	print(planet_dest)
			--	print("%N")
--				grid[planet_dest.row,planet_dest.col].planets.extend (p) -- add planet to the planets list in SECTOR
--				grid[planet_dest.row,planet_dest.col].entities.extend (p) --add the planet to entities list
				p.behave (grid[p.sector.row,p.sector.col].contents)
				if not p.is_alive then
					dead_planets.extend (p)
					grid[3,3].contents.prune_all (p.icon)
					grid[3,3].contents_count := grid[3,3].contents_count - 1
				else
					grid[planet_dest.row,planet_dest.col].planets.extend (p) -- add planet to the planets list in SECTOR
					grid[planet_dest.row,planet_dest.col].entities.extend (p) --add the planet to entities list
				end
				Result := true
			elseif not p.in_orbit then

				p.behave (grid[p.sector.row,p.sector.col].contents)
			else
				Result := false
			end
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

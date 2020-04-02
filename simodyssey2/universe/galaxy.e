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
	movable_entities : LINKED_LIST[MOVABLE_ENTITY]
	dead_planets: LINKED_LIST[PLANET]
	explorer: EXPLORER
	test_mode : BOOLEAN
	directions: ARRAY[TUPLE[row:INTEGER;col:INTEGER]]
		do
			Result := <<[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1]>>
		end
	max_movable_entity_id : INTEGER -- the current largest movable entity id
	next_movable_id : INTEGER assign set_next_movable_id

feature --constructor

	make_dummy
		do
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			create movable_entities.make
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
			create movable_entities.make
			create explorer.make
			create dead_planets.make
			create stationary_items.make
			test_mode := is_test_mode
			stationary_count := -2
			next_movable_id := 1

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
					max_movable_entity_id := movable_entities.count
					grid[row,column] := create {SECTOR}.make(row,column,explorer,(next_movable_id))

					across grid[row,column].movable_entities as curr
					loop
						if not curr.item.is_explorer then
							movable_entities.extend (curr.item)
						end
					end
						if grid[row,column].contents.has (explorer.icon)  then
							next_movable_id := next_movable_id + grid[row,column].movable_entities.count - 1
						else
							next_movable_id := next_movable_id + grid[row,column].movable_entities.count
						end
					--	next_movable_id := movable_entities.count + 1

					column:= column + 1;

				end
				row := row + 1
			end
			set_stationary_items
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
			added: BOOLEAN
		do
			added := false
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
					grid[temp_row,temp_column].add_to_entities_list (item)
				--	check_sector.entities.extend (item)
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

	set_next_movable_id(next : INTEGER)
		do
			next_movable_id := next
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

note
	description: "Represents a sector in the galaxy."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SECTOR

create
	make, make_dummy

feature -- attributes
	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

	gen: RANDOM_GENERATOR_ACCESS

	contents: ARRAYED_LIST [ENTITY_ALPHABET] --holds 4 quadrants

	contents_count: INTEGER assign set_contents_count

	row: INTEGER

	column: INTEGER

	planet_id: INTEGER

	planets: ARRAYED_LIST[PLANET]

	recently_added: INTEGER -- index of most recently added entity

	entities : ARRAYED_LIST[ENTITY]





feature -- constructor
	make(row_input: INTEGER; column_input: INTEGER; a_explorer:EXPLORER;planet_id_num:INTEGER)
		--initialization
		require
			valid_row: (row_input >= 1) and (row_input <= shared_info.number_rows)
			valid_column: (column_input >= 1) and (column_input <= shared_info.number_columns)
		do
			create planets.make(4)
			create entities.make (4)
			across 1|..| 4 as curr
			loop
				entities.extend (create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('-'), 150))
			end

			entities.compare_objects
			planet_id := planet_id_num
			row := row_input
			column := column_input
			create contents.make (shared_info.max_capacity) -- Each sector should have 4 quadrants
			contents.compare_objects
			if (row = 3) and (column = 3) then
				put (create {ENTITY_ALPHABET}.make ('O'),true) -- If this is the sector in the middle of the board, place a black hole
				entities[1] := create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('O'),-1)
			else
--				entities.extend (create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('O')
--				, -1))

				if (row = 1) and (column = 1) then
					put (a_explorer.icon,true) -- If this is the top left corner sector, place the explorer there
					entities[1] := (a_explorer)

				--	entities.extend (a_explorer)
				end
				populate -- Run the populate command to complete setup
			end -- if
		end

feature -- commands
	make_dummy
		--initialization without creating entities in quadrants
		do
			create contents.make (shared_info.max_capacity)
			create planets.make (4)
			contents.compare_objects
			create entities.make(4)
			entities.compare_objects
		end

	populate
			-- this feature creates 1 to max_capacity-1 components to be intially stored in the
			-- sector. The component may be a planet or nothing at all.
		local
			threshold: INTEGER
			number_items: INTEGER
			loop_counter: INTEGER
			component: ENTITY_ALPHABET
			planet: PLANET
			added: BOOLEAN
		do
			added := false
			number_items := gen.rchoose (1, shared_info.max_capacity-1)  -- MUST decrease max_capacity by 1 to leave space for Explorer (so a max of 3)
			from
				loop_counter := 1
			until
				loop_counter > number_items
			loop
				threshold := gen.rchoose (1, 100) -- each iteration, generate a new value to compare against the threshold values provided by `test` or `play`

				if threshold < shared_info.planet_threshold then

					create planet.make (planet_id,gen.rchoose (0, 2),[row,column,0])
					planet_id := planet_id + 1
					component := planet.icon
				end


				if attached component as entity then

					if attached planet as p then
						planets.extend (p)
					end
					put (entity,true) -- add new entity to the contents list
					if attached {ENTITY} planet as add then
						from
							entities.start
						until
							added
						loop
							if entities.item.icon.item ~ '-'  then
								entities.replace (add)
								added := true
							end
							entities.forth
						end
						added := false
						--entities.extend (add)
					end


					--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
				--	turn:=gen.rchoose (0, 2) -- Hint: Use this number for assigning turn values to the planet created
					-- The turn value of the planet created (except explorer) suggests the number of turns left before it can move.
					--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

				--	planet.turns_left := turn
					component := void -- reset component object
				end

				loop_counter := loop_counter + 1
			end
		end

feature --command

	put (new_component: ENTITY_ALPHABET;first_time:BOOLEAN)
			-- put `new_component' in contents array
		local
			loop_counter: INTEGER
			found: BOOLEAN
			blank_char: ENTITY_ALPHABET
			check_first: BOOLEAN
		do
			create blank_char.make ('-')
			check_first := first_time
			from
				loop_counter := 1
			until
				loop_counter > contents_count or found
			loop
				if contents [loop_counter] = new_component then
					found := TRUE
				end --if
				loop_counter := loop_counter + 1
			end -- loop

			if not found and not is_full then
				if contents.has (blank_char) then
					recently_added := contents.index_of (blank_char, 1)
					contents[contents.index_of (blank_char, 1)] := new_component

				else
					contents.extend (new_component)
					recently_added := contents_count + 1

				end
				contents_count := contents_count + 1
				if new_component ~ (create {ENTITY_ALPHABET}.make ('P')) and check_first then
					planets[planets.count].sector.quadrant := contents_count
				end

			end

		ensure
			component_put: not is_full implies contents.has (new_component)
		end

	set_contents_count(new_count: INTEGER)
		do
			contents_count := new_count
		end

feature -- Queries

	print_sector: STRING
			-- Printable version of location's coordinates with different formatting
		do
			Result := ""
			Result.append (row.out)
			Result.append (":")
			Result.append (column.out)
		end

	is_full: BOOLEAN
			-- Is the location currently full?
		local
			loop_counter: INTEGER
			occupant: ENTITY_ALPHABET
			empty_space_found: BOOLEAN
			blank_char: ENTITY_ALPHABET
		do
			create blank_char.make ('-')
			if contents_count < shared_info.max_capacity then
				empty_space_found := TRUE
			end
			from
				loop_counter := 1
			until
				loop_counter > contents_count or empty_space_found
			loop
				occupant := contents [loop_counter]
				if not attached occupant or (occupant = blank_char)  then
					empty_space_found := TRUE
				end
				loop_counter := loop_counter + 1
			end

			if contents_count = shared_info.max_capacity and then not empty_space_found then
				Result := TRUE
			else
				Result := FALSE
			end
		end

	has_stationary: BOOLEAN
			-- returns whether the location contains any stationary item
		local
			loop_counter: INTEGER
		do
			from
				loop_counter := 1
			until
				loop_counter > contents_count or Result
			loop
				if attached contents [loop_counter] as temp_item  then
					Result := temp_item.is_stationary
				end -- if
				loop_counter := loop_counter + 1
			end
		end

	planets_sorted:ARRAYED_LIST[PLANET] -- Returns a sorted list of the planets in this sector by lowest id to highest (used for land command)

		local
			i: INTEGER
			j: INTEGER
			temp: PLANET

		do
			create Result.make(4)
			across planets as curr
			loop
				Result.extend (curr.item.deep_twin)
			end

			from
				i := 1
			until
				i = Result.count
			loop

				from
					j := i
				until
					j = Result.count + 1
				loop
					if Result[j].id < Result[i].id then
						temp := Result[j].deep_twin
						Result[j] := Result[i].deep_twin
						Result[i] := temp
					end

					j := j + 1

				end
				i := i + 1
			end
		end
end

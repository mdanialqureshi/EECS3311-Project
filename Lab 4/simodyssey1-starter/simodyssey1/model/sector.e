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

	row: INTEGER

	column: INTEGER

	planet_id: INTEGER

	planets: ARRAYED_LIST[PLANET]



feature -- constructor
	make(row_input: INTEGER; column_input: INTEGER; a_explorer:ENTITY_ALPHABET;planet_id_num:INTEGER)
		--initialization
		require
			valid_row: (row_input >= 1) and (row_input <= shared_info.number_rows)
			valid_column: (column_input >= 1) and (column_input <= shared_info.number_columns)
		do
			create planets.make(4)
			planet_id := planet_id_num
			row := row_input
			column := column_input
			create contents.make (shared_info.max_capacity) -- Each sector should have 4 quadrants
			contents.compare_objects
			if (row = 3) and (column = 3) then
				put (create {ENTITY_ALPHABET}.make ('O')) -- If this is the sector in the middle of the board, place a black hole
			else
				if (row = 1) and (column = 1) then
					put (a_explorer) -- If this is the top left corner sector, place the explorer there
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
		end

	populate
			-- this feature creates 1 to max_capacity-1 components to be intially stored in the
			-- sector. The component may be a planet or nothing at all.
		local
			threshold: INTEGER
			number_items: INTEGER
			loop_counter: INTEGER
			component: ENTITY_ALPHABET
			turn :INTEGER
			planet: PLANET

		do

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
					put (entity) -- add new entity to the contents list

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

feature {GALAXY} --command

	put (new_component: ENTITY_ALPHABET)
			-- put `new_component' in contents array
		local
			loop_counter: INTEGER
			found: BOOLEAN
		do
			from
				loop_counter := 1
			until
				loop_counter > contents.count or found
			loop
				if contents [loop_counter] = new_component then
					found := TRUE
				end --if
				loop_counter := loop_counter + 1
			end -- loop

			if not found and not is_full then
				contents.extend (new_component)
				if new_component ~ (create {ENTITY_ALPHABET}.make ('P')) then
					planets[planets.count].sector.quadrant := contents.count
				end

			end

		ensure
			component_put: not is_full implies contents.has (new_component)
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
		do
			if contents.count < shared_info.max_capacity then
				empty_space_found := TRUE
			end
			from
				loop_counter := 1
			until
				loop_counter > contents.count or empty_space_found
			loop
				occupant := contents [loop_counter]
				if not attached occupant  then
					empty_space_found := TRUE
				end
				loop_counter := loop_counter + 1
			end

			if contents.count = shared_info.max_capacity and then not empty_space_found then
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
				loop_counter > contents.count or Result
			loop
				if attached contents [loop_counter] as temp_item  then
					Result := temp_item.is_stationary
				end -- if
				loop_counter := loop_counter + 1
			end
		end

end

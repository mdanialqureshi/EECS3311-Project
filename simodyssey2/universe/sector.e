note
	description: "Represents a sector in the galaxy."
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
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

	movable_entity_id: INTEGER

	movable_entities : ARRAYED_LIST[MOVABLE_ENTITY]

	recently_added: INTEGER -- index of most recently added entity

	entities : ARRAYED_LIST[ENTITY]





feature -- constructor
	make(row_input: INTEGER; column_input: INTEGER; a_explorer:EXPLORER;movable_entity_num:INTEGER)
		--initialization
		require
			valid_row: (row_input >= 1) and (row_input <= shared_info.number_rows)
			valid_column: (column_input >= 1) and (column_input <= shared_info.number_columns)
		do
			create movable_entities.make (4)
			create entities.make (4)

			across 1|..| 4  as i
			loop
				entities.extend (create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('-'), 150))
			end

			entities.compare_objects
			movable_entity_id := movable_entity_num
			row := row_input
			column := column_input
			create contents.make (shared_info.max_capacity) -- Each sector should have 4 quadrants
			contents.compare_objects
			if (row = 3) and (column = 3) then
				put (create {ENTITY_ALPHABET}.make ('O'),true) -- If this is the sector in the middle of the board, place a black hole
				entities[1] := create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('O'),-1)
			else

				if (row = 1) and (column = 1) then
					put (a_explorer.icon,true) -- If this is the top left corner sector, place the explorer there
					entities[1] := (a_explorer)
				--	entities.extend (a_explorer)
				end
				populate -- Run the populate command to complete setup
			end -- if
			movable_entities.compare_objects
		end

feature -- commands
	make_dummy
		--initialization without creating entities in quadrants
		do
			create contents.make (shared_info.max_capacity)
			create movable_entities.make(4)
			contents.compare_objects
			create entities.make(4)
			entities.compare_objects
			movable_entities.compare_objects
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
			benign : BENIGN
			janitaur : JANITAUR
			asteroid : ASTEROID
			malevolent : MALEVOLENT
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


				if threshold < shared_info.asteroid_threshold then
					create asteroid.make (movable_entity_id, gen.rchoose (0, 2), [row,column,0])
					movable_entity_id := movable_entity_id + 1
					component := asteroid.icon
				else
					if threshold < shared_info.janitaur_threshold then
						create janitaur.make (movable_entity_id, gen.rchoose (0, 2), [row,column,0])
						movable_entity_id := movable_entity_id + 1
						component := janitaur.icon
					else
						if (threshold < shared_info.malevolent_threshold) then
								create malevolent.make (movable_entity_id, gen.rchoose (0, 2), [row,column,0])
								movable_entity_id := movable_entity_id + 1
								component := malevolent.icon
						else
							if (threshold < shared_info.benign_threshold) then
								create benign.make (movable_entity_id, gen.rchoose (0, 2), [row,column,0])
								movable_entity_id := movable_entity_id + 1
								component := benign.icon
							else
								if threshold < shared_info.planet_threshold then
									create planet.make (movable_entity_id,gen.rchoose (0, 2),[row,column,0])
									movable_entity_id := movable_entity_id + 1
									component := planet.icon
								end
							end
						end
					end
				end


				if attached component as entity then


					if attached asteroid as a then
						movable_entities.extend (a)
					end

					if attached janitaur as j then
						movable_entities.extend (j)
					end

					if attached malevolent as m then
						movable_entities.extend (m)
					end

					if attached benign as b then
						movable_entities.extend (b)
					end

					if attached planet as p then
						movable_entities.extend (p)
					end

					put (entity,true) -- add new entity to the contents list
					-- add new entity to entites array
					if attached {ENTITY} asteroid as add then
						add_to_entities_list (add)
					end

					if attached {ENTITY} janitaur as add then
						add_to_entities_list (add)
					end

					if attached {ENTITY} malevolent as add then
						add_to_entities_list (add)
					end

					if attached {ENTITY} benign as add then
						add_to_entities_list (add)
					end

					if attached {ENTITY} planet as add then
						add_to_entities_list (add)
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

	add_to_entities_list(ent : ENTITY)
		local
			added : BOOLEAN
		do
			added := false
			from
				entities.start
			until
				added
			loop
				if entities.item.icon.item ~ '-'  then
					entities.replace (ent)
					added := true
				end
				entities.forth
			end
			added := false
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
					movable_entities[movable_entities.count].sector.quadrant := contents_count
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
			across movable_entities as m_entity
			loop
				if attached {PLANET}m_entity.item as curr then
					Result.extend (curr.deep_twin)
				end
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


	sector_sorted:ARRAYED_LIST[MOVABLE_ENTITY] -- Returns a sorted list of the movable entities in this sector by lowest id to highest

		local
			i: INTEGER
			j: INTEGER
			temp: MOVABLE_ENTITY

		do
			create Result.make(4)
			across movable_entities as m_entity
			loop
				if attached {MOVABLE_ENTITY}m_entity.item as curr then
					Result.extend (curr.deep_twin)
				end
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

	remove_entity(ent : ENTITY)
		do
			-- remove from entities
			from
				entities.start
			until
				entities.exhausted
			loop
				if  entities.item.id ~ ent.id then
					entities.replace (create {ENTITY}.make_entity (create {ENTITY_ALPHABET}.make ('-'), 150))
				end
				entities.forth
			end

			-- also remove from movable entities of this sector
			from	 -- this loop is to remove the planet from it's previous planets list in SECTOR
				movable_entities.start
			until
				movable_entities.exhausted
			loop
				if attached{MOVABLE_ENTITY}ent as curr_m_ent  then
					if curr_m_ent.id ~ movable_entities.item.id then
						movable_entities.item.is_alive := false -- item is dead
						movable_entities.remove
					else
						movable_entities.forth
					end
				end
			end

			--update the contents list by removal as well
			if attached{MOVABLE_ENTITY}ent as curr_m_ent then
				contents[curr_m_ent.sector.quadrant] := create {ENTITY_ALPHABET}.make ('-') --remove from contents of this sector
				contents_count := contents_count - 1 -- decrement contents count
			end

		end

	add_entity_to_all_lists(ent : ENTITY)
		do
			add_to_entities_list (ent) -- add to entities list
			if attached{MOVABLE_ENTITY}ent as curr_m_ent then --add to movable entities list
				movable_entities.extend (curr_m_ent)
			end

			--update the contents list by addition as well
			if attached{MOVABLE_ENTITY}ent as curr_m_ent then
				contents[curr_m_ent.sector.quadrant] := curr_m_ent.icon
				contents_count := contents_count + 1 -- decrement contents count
			end

		end

end

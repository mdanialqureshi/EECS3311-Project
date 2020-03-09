note
	description: "[
		Starter code to help students generate the initial placement
		of movable and stationary entities in the sectors of a galaxy
		Note: This code is not well-designed, but can be refactored
		in your design.
	]"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	ROOT

inherit

	ARGUMENTS_32

	ES_SUITE -- testing via ESpec

create
	make

feature {NONE} -- Initialization

    g: GALAXY -- has access to shared information
    info: SHARED_INFORMATION
    e: EXPLORER
    gen: RANDOM_GENERATOR_ACCESS

    make
            -- Run application.
        local
        	sa: SHARED_INFORMATION_ACCESS -- singleton
        do

        	info := sa.shared_info
        	print("This code is creating two boards with different thresholds.%N")
			create e.make
        	--set first threshold
        	info.set_planet_threshold(30)
         	create g.make
         	--g.grid[1,1].contents.prune (e.icon)


         	--e.sector.quadrant := g.grid[1,2].contents.count + 1
         	--print(e.sector.quadrant)
			--g.grid[1,2].contents.extend (e.icon)
		--	g.grid[1,2].contents.prune (explorer)
		--	if not g.grid[1,3].is_full then
		--		g.grid[1,3].contents.extend (explorer)
		--	end


          -- 	print(g.out)
			print("%N")
			across g.planets as curr
			loop
				print(curr.item.sector)
				print("%N")
				print(curr.item.id)
				print("%N")
				print(curr.item.turns_left)
				print("%N")

			end
			print("%N")
			print("%N")

			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")
			print(g.gen.rchoose (0, 2))
			print("%N")


--			print(g.gen.rchoose (1, 8))
--			print("%N")
--			print(g.gen.rchoose (1, 8))
--			print("%N")
--			print(g.gen.rchoose (1, 8))
--			print("%N")











		--	create g.make
		--	print(g.out)
		--	print("%N")
           	--set second threshold
        	info.set_planet_threshold(100)
         	create g.make
          -- 	print(g.out)
           	io.new_line
        end


end

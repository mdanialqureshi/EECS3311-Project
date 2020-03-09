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
		do
			i := 0
			state := 0.0
		end

feature -- model attributes
	state : DOUBLE
	i : INTEGER


feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			i := i + 1
		end

	reset
			-- Reset model state.
		do
			make
		end

	play
		local
			g : GALAXY
			info : SHARED_INFORMATION
			access : SHARED_INFORMATION_ACCESS
		do
			info := access.shared_info
        	print("This code is creating two boards with different thresholds.%N")

        	--set first threshold
        	print("This board has threshold 30.%N")
        	info.set_planet_threshold(30)
         	create g.make
           	print(g.out)
			print("%N")

           	--set second threshold
           	print("This board has threshold 100.%N")
        	info.set_planet_threshold(100)
         	create g.make
           	print(g.out)
           	io.new_line
           	state := state + 1

		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  ")
			Result.append ("state:" + state.out +", ok%N")
			Result.append ("  ")
			if state = 0.0 then
				Result.append ("Welcome! Try test(30)")
			end

		end

end





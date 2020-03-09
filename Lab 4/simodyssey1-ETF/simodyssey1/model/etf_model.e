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
			create s.make_empty
			i := 0
		end

feature -- model attributes
	s : STRING
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

		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  ")
			Result.append ("System State: default model state ")
			Result.append ("(")
			Result.append (i.out)
			Result.append (")")
		end

end





note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LAND
inherit
	ETF_LAND_INTERFACE
create
	make
feature -- command
	land
    	do
			-- perform some update on the model state
			model.turn ("land", 0)
			etf_cmd_container.on_change.notify ([Current])
    	end

end

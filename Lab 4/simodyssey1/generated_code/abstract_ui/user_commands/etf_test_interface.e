note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ETF_TEST_INTERFACE
inherit
	ETF_COMMAND
		redefine 
			make 
		end

feature {NONE} -- Initialization

	make(an_etf_cmd_name: STRING; etf_cmd_args: TUPLE; an_etf_cmd_container: ETF_ABSTRACT_UI_INTERFACE)
		do
			Precursor(an_etf_cmd_name,etf_cmd_args,an_etf_cmd_container)
			etf_cmd_routine := agent test(?)
			etf_cmd_routine.set_operands (etf_cmd_args)
			if
				attached {INTEGER_32} etf_cmd_args[1] as p_threshold
			then
				out := "test(" + etf_event_argument_out("test", "p_threshold", p_threshold) + ")"
			else
				etf_cmd_error := True
			end
		end

feature -- command precondition 
	test_precond(p_threshold: INTEGER_32): BOOLEAN
		do  
			Result := 
				         is_threshold(p_threshold)
					-- (1 <= p_threshold) and then (p_threshold <= 101)
		ensure then  
			Result = 
				         is_threshold(p_threshold)
					-- (1 <= p_threshold) and then (p_threshold <= 101)
		end 
feature -- command 
	test(p_threshold: INTEGER_32)
		require 
			test_precond(p_threshold)
    	deferred
    	end
end

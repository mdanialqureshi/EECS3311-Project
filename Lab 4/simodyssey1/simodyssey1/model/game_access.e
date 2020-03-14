note
	description: "Singleton access to the default business model."
	author: "Ameer Bacchus and Muhammad Danial Qureshi"
	date: "2020-03-13"
	revision: "$Revision$"

expanded class
	GAME_ACCESS

feature
	m: GAME
		once
			create Result.make
		end

invariant
	m = m
end





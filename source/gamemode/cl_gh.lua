--[[
-----	Ghetto Hidden: Client	-----
This is code that will be run clientside, and only clientside.

Shared code is in gh.lua.
Server code is in sv_gh.lua.
--]]

function GHClientBegin()

	for _, ply in ipairs( player.GetAll() ) do
	
		
	
	end

end
hook.Add( "TTTBeginRound", "GHClientBegin", GHClientBegin )
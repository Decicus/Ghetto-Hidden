--[[
-----	Ghetto Hidden: Client	-----
This is code that will be run clientside, and only clientside.

Server/shared code is in gh.lua.
--]]

--Namecolors on scoreboard.
function NameColors(ply)
	if ply:SteamID() == "STEAM_0:1:18726919" then
		Color(255, 0, 234)
	elseif ply:SteamID() == "STEAM_0:1:38997936" then
		Color(255, 0, 234)
	else
		nil
	end
end
hook.Add("TTTScoreboardColorForPlayer", "NameColors", NameColors)
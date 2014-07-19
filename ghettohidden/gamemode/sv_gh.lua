--[[

	Ghetto Hidden - Serverside Code.

--]]

function GHNotifyDeaths( ply, inf, att )

	if att ~= ply then
	
		for _, plys in ipairs( player.GetAll() ) do
		
			plys:ChatPrint( ply:Nick() .. " got killed by " .. att:Nick() )
		
		end
		
	else
	
		for _, plys in ipairs( player.GetAll() ) do
		
			ply:ChatPrint( ply:Nick() .. " killed themself." )
		
		end
	
	end

end
hook.Add( "PlayerDeath", "GHNotifyDeaths", GHNotifyDeaths )
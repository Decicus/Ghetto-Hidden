--[[
	-----	Ghetto Hidden: Functions	-----
	This whole Lua file contains all the custom functions I've added into Ghetto Hidden.
	AT LEAST one of them uses a ULib function (invisible/cloak) so you will need that for it to work. (ULib.tsayColor is also used)
	
	This file contains shared functions.
--]]

resource.AddFile( "gamemodes/ghettohidden/icon24.png" )
resource.AddFile( "gamemodes/ghettohidden/logo.png" )

function GHMainStart()

	for _, ply in ipairs( player.GetAll() ) do
	
		if ply:IsRole( ROLE_TRAITOR ) then
		
			ply:ConCommand( "ttt_set_disguise 1" )
			ply:SetHealth( 150 )
			ULib.tsayColor( nil, Color( 255, 0, 0 ), ply:Nick(), Color( 255, 255, 255 ), " has been selected as a Hidden!" )
			ULib.invisible( ply, true )
			ply:AllowFlashlight( false ) -- Remove the ability to reveal yourself because of Flashlight.
			ply:StripWeapons()
			
		else
		
			ply:SetRole( ROLE_DETECTIVE )
			ply:SetCredits( 2 )
			
			ULib.invisible( ply, false )
			ply:AllowFlashlight( true )
			ULib.tsayColor( nil, Color( 25, 25, 200 ), "Hunters ", Color( 255, 255, 255 ), " are frozen and invincible for 10 seconds." )
			ply:Freeze( true )
			ply:GodEnable()
			ply:ChatPrint( "You're frozen and invincible for 10 seconds, be patient." )
			timer.Simple( 10, function()

				ply:Freeze( false )
				ply:GodDisable()
				ply:ChatPrint( "You are unfrozen and able to take damage. Go out and hunt some Hidden. Be careful." )
				ULib.tsayColor( nil, Color( 25, 25, 200 ), "Hunters ", Color( 255, 255, 255 ), "are now unfrozen and can take damage." )
			
			end )
		
		end
		
		timer.Simple( 0.5, function()
			
			GiveLoadoutItems( ply )
			GiveLoadoutWeapons( ply )
			SendFullStateUpdate()
			
		end )
		
	end
	
end
hook.Add( "TTTBeginRound", "GHMainStart", GHMainStart )

function GHMainEnd( r )

	for _, ply in ipairs( player.GetAll() ) do
	
		ULib.invisible( ply, false )
		ply:AllowFlashlight( true )
	
	end

end
hook.Add( "TTTEndRound", "GHMainEnd", GHMainEnd )

function GHRamboMode( ply, cmd, args )

	if ply:IsRole( ROLE_TRAITOR ) then
	
		if ply:GetCredits() < 1 then
		
			ply:ChatPrint( "You need at least 1 credit to activate Rambo Mode." )
			
		else
		
			ply.GHRamboMode = true
			ply:StripAll()
			ply:GodEnable()
			ply:ChatPrint( "Rambo Mode is enabled. You will be invincible for 5 seconds." )
			ULib.tsay( nil, ply:Nick() .. " has activated Rambo Mode!" )
			
			if ply:Health() <= 25 then
			
				ply:ChatPrint( "Your health is below or at 25. Your health will stay the same." )
				
			else
			
				ply:ChatPrint( "Your health has been set to 25." )
				ply:SetHealth( 25 )
			
			end
			
			timer.Simple( 0.1, function()
			
				ply:Give( "weapon_gh_rambo" )
			
			end )
			
			timer.Simple( 5, function()
			
				ply:GodDisable()
				ply:ChatPrint( "Your God mode has been disabled. You will be able to take damage, so be careful." )
			
			end )
		
		end
		
	elseif not ply:IsRole( ROLE_TRAITOR ) then
		
		ply:ChatPrint( "You're not a Hidden." )
	
	elseif not ply:Alive() then
	
		ply:ChatPrint( "You're not alive." )
		
	else
	
		ply:ChatPrint( "You cannot be in Rambo Mode." )
	
	end

end
concommand.Add( "gh_rambo", GHRamboMode, "Activates Rambo Mode for Hidden." )

function GHPlayerSpeed( ply, slowed )

	if ply.GHRamboMode then
	
		return 1.5
		
	else
	
		return 1
		
	end

end
hook.Add( "TTTPlayerSpeed", "GHPlayerSpeed", GHPlayerSpeed )


function GHCheckCredit( ply )

	if ply.GHRamboMode then
		
		ply:SubtractCredits( 1 )
		ply:ChatPrint( "The credit you just received has been removed due to Rambo Mode." )
	
	end

end
hook.Add( "GHCreditAward", "GHCheckCredit", GHCheckCredit ) -- Line 549, player.lua. Custom hook called when Hidden receive credit.
--[[

	"GHCreditAward" documentation. Parameters - Player ply.
	Hook will always be called when a TRAITOR/HIDDEN gets credited. No need to check if ply == ROLE_TRAITOR.

--]]

--Functions below are taken from Bender and Skillz' TTT module for ULX.
--If you guys actually end up seeing this, you can find me on the ULX forums under the name "Decicus".
--Contact me if you wish to remove this from the gamemode.
--[Helper Functions]---------------------------------------------------------------------------
--[[GetLoadoutWeapons][Returns the loadout weapons ]
@param  {[Number]} r [The role of the loadout weapons to be returned]
@return {[table]}    [A table of loadout weapons for the given role.]
--]]
function GetLoadoutWeapons(r)
	local tbl = {
		[ROLE_INNOCENT] = {},
		[ROLE_TRAITOR]  = {},
		[ROLE_DETECTIVE]= {}
	};
	for k, w in pairs(weapons.GetList()) do
		if w and type(w.InLoadoutFor) == "table" then
			for _, wrole in pairs(w.InLoadoutFor) do
				table.insert(tbl[wrole], WEPS.GetClass(w))
			end
		end
	end
	return tbl[r]
end

--[[RemoveBoughtWeapons][Removes previously bought weapons from the shop.]
@param  {[PlayerObject]} ply [The player who will have their bought weapons removed.]
--]]
function RemoveBoughtWeapons(ply)
	for _, wep in pairs(weapons.GetList()) do
		local wep_class = WEPS.GetClass(wep)
		if wep and type(wep.CanBuy) == "table" then
			for _, weprole in pairs(wep.CanBuy) do
				if weprole == ply:GetRole() and ply:HasWeapon(wep_class) then
					ply:StripWeapon(wep_class)
				end
			end
		end
	end
end

--[[RemoveLoadoutWeapons][Removes all loadout weapons for the given player.]
@param  {[PlayerObject]} ply [The player who will have their loadout weapons removed.]
--]]
function RemoveLoadoutWeapons(ply)
	local weps = GetLoadoutWeapons( GetRoundState() == ROUND_PREP and ROLE_INNOCENT or ply:GetRole() )
	for _, cls in pairs(weps) do
		if ply:HasWeapon(cls) then
			ply:StripWeapon(cls)
		end
	end
end

--[[GiveLoadoutWeapons][Gives the loadout weapons for that player.]
@param  {[PlayerObject]} ply [The player who will have their loadout weapons given.]
--]]
function GiveLoadoutWeapons(ply)
	local r = GetRoundState() == ROUND_PREP and ROLE_INNOCENT or ply:GetRole()
	local weps = GetLoadoutWeapons(r)
	if not weps then return end

	for _, cls in pairs(weps) do
		if not ply:HasWeapon(cls) then
			ply:Give(cls)
		end
	end
end

--[[GiveLoadoutItems][Gives the default loadout items for that role.]
@param  {[PlayerObject]} ply [The player who the equipment will be given to.]
--]]
function GiveLoadoutItems(ply)
	local items = EquipmentItems[ply:GetRole()]
	if items then
		for _, item in pairs(items) do
			if item.loadout and item.id then
				ply:GiveEquipmentItem(item.id)
			end
		end
	end
end
--[End]----------------------------------------------------------------------------------------
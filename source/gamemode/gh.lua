--[[
-----	Ghetto Hidden: Functions	-----
This whole Lua file contains all the custom functions I've added into Ghetto Hidden.
AT LEAST one of them uses a ULib function (invisible/cloak) so you will need that for it to work. (ULib.tsayColor is also used)
I'm just letting you know that there are edits in the other files too, but this contains the functions I have ADDED (not modified).
The reasons I have so many functions is for easier troubleshooting in the beginning, I'll narrow it down when I've tested all of them.
--]]

--Forces downloads of the icon and such. Pretty sure this is needed.
resource.AddFile("gamemodes/ghettohidden/icon24.png")
resource.AddFile("gamemodes/ghettohidden/logo.png")

--Main functions that trigger when round starts.
function HiddenMain()
	for k, v in ipairs (player.GetAll()) do --Gets all the players
		if v:IsRole (ROLE_TRAITOR) then --Checks if Traitor/Hidden
			v:ConCommand("ttt_set_disguise 1") --Activates disguise
			v:SetHealth(150) --Sets health to 150.
			ULib.tsayColor(nil, Color(255, 0, 0), v:Nick(), Color(255, 255, 255), " has become one of the Hidden!") --Says who is a Hidden.
			ULib.invisible(v, true)
		else
			ULib.invisible(v, false)
		end
	end
end
hook.Add("TTTBeginRound", "HiddenMain", HiddenMain)

--Freezes Hunters.
function FreezeHunters()
	ULib.tsayColor(nil, true, Color(25, 25, 200), "Hunters ", Color(255, 255, 255), "are frozen and immune to damage for 10 seconds.")
	timer.Simple(10, function()
				ULib.tsayColor(nil, wait, Color(25, 25, 200), "Hunters ", Color(255, 255, 255), "are now unfrozen and can take damage.")
				end)
	for k, v in ipairs (player.GetAll()) do
		if not v:IsRole(ROLE_TRAITOR) then
			v:Freeze(true)
			v:GodEnable()
			v:ChatPrint("You're frozen and cannot move for 10 seconds, be patient.")
			timer.Simple(10, function()
						v:Freeze(false)
						v:GodDisable()
						v:ChatPrint("You can now move. Go out and hunt some Hidden.")
						end)
		end
	end
end
hook.Add("TTTBeginRound", "FreezeHunters", FreezeHunters)

--Forces innocents to become Hunters.
function InnocentsHunter()
	for k, v in ipairs (player.GetAll()) do
		if v:IsRole(ROLE_INNOCENT) then
			v:SetRole(ROLE_DETECTIVE)
			v:SetCredits(2)
			timer.Simple(1, function()
						GiveLoadoutItems(v)
						GiveLoadoutWeapons(v)
						end)
		elseif v:IsRole(ROLE_TRAITOR) then
			v:StripWeapons()
			--Timer to give weapons
			timer.Simple(1, function()
					GiveLoadoutItems(v)
					GiveLoadoutWeapons(v)
					end)
		end
		timer.Simple(1.5, function()
					SendFullStateUpdate()
					end)
	end
end
hook.Add("TTTBeginRound", "InnocentsHunter", InnocentsHunter)

--Just makes everyone visible.
function NoInvisEnd(r)
	if WIN_TRAITOR or WIN_TIMELIMIT or WIN_INNOCENT then
		for k, v in ipairs (player.GetAll()) do
			ULib.invisible(v, false)
		end
	end
end
hook.Add("TTTEndRound", "NoInvisEnd", NoInvisEnd)

--The most advanced function I'm probably ever going to create.
--#RamboMode
function RamboMode(ply, cmd, args)
	if ply:IsRole(ROLE_TRAITOR) then
		if ply:GetCredits() < 1 then
			ply:ChatPrint("You don't have enough credits to activate Rambo Mode.")
		else
			ply:SetPData("gh_ramboenabled", true) --Bad way of saving it, but I'm not too sure of any other way to do it.
			ply:StripAll()
			ply:GodEnable()
			ply:ChatPrint("Rambo Mode is enabled, you have God mode for 5 seconds")
			timer.Simple(0.05, function()
						ply:Give("weapon_gh_rambo")
						end)
			timer.Simple(5, function()
						ply:GodDisable()
						ply:ChatPrint("God mode is now disabled")
						end)
			--What to add here: Something that makes Rambo-Hidden faster.
			--I need to override some default TTT functions.
			ULib.tsay( nil, ply:Nick() .. " has activated Rambo Mode!", true )
			if ply:Health() < 25 then
				ply:ChatPrint("Your health is too low to be set to 25. Your health will be the same.")
			else
				ply:SetHealth(25)
				ply:ChatPrint("Your health has been set to 25.")
			end
		end
	elseif not ply:IsRole(ROLE_TRAITOR) then
		ply:ChatPrint("You're not even a Hidden...")
	elseif not ply:Alive() then
		ply:ChatPrint("You're sort of dead.")
	end
end
concommand.Add("gh_rambo", RamboMode, "Activates Rambo Mode (Hidden-only).")

--[Helper Functions for Rambo Mode]------------------------------------------------------------

-- Most functions inside this little block are functions to DISABLE Rambo Mode.
-- All of them should be commented for a developer to understand.
function RamboInitialSpawnDisable( ply )
	if ply:GetPData( "gh_ramboenabled" ) == true then
		ply:SetPData( "gh_ramboenabled", false )
	end
end
hook.Add( "PlayerInitialSpawn", RamboInitialSpawnDisable ) -- Triggers when player loads with "Sending client info..." in case they timed out or something like that.

function CheckRamboCredit()
	for _, v in ipairs ( player.GetAll() ) do
		if v:IsRole( ROLE_TRAITOR ) then
			if v:GetPData( "gh_ramboenabled" ) == true then --Check if Rambo Mode is enabled.
				v:SubtractCredits(1) -- Removes the credit.
				v:ChatPrint("The credit you just received has been removed.") -- Prints to the Rambo-Hidden.
			end
		end
	end
end
hook.Add( "GHCreditAward", CheckRamboCredit ) -- Line 549, player.lua. Custom hook called when Hidden receive credit.

function RamboModeDisableDC( ply )
	if ply:IsRole( ROLE_TRAITOR ) then
		if ply:GetPData( "gh_ramboenabled" ) == true then -- Checks if Rambo Mode is enabled.
			ply:SetPData( "gh_ramboenabled", false ) -- Disables it.
		end
	end
end
hook.Add( "PlayerDisconnected", RamboModeDisableDC ) -- Triggers when player disconnects.

function RamboModeDisableDeath( ply, wep, att )
	if ply:IsRole( ROLE_TRAITOR ) then
		if ply:GetPData( "gh_ramboenabled" ) == true then
			ply:SetPData( "gh_ramboenabled", false )
		end
	end
end
hook.Add( "PlayerDeath", RamboModeDisableDeath ) -- Triggers when player dies.

function RamboModeDisableRound()
	for _, v in ipairs ( player.GetAll() ) do
		if v:IsRole( ROLE_TRAITOR ) then
			if v:GetPData( "gh_ramboenabled" ) == true then
				v:SetPData( "gh_ramboenabled", false )
			end
		end
	end
end
hook.Add( "TTTBeginRound", RamboModeDisableRound )
hook.Add( "TTTEndRound", RamboModeDisableRound ) -- Disables Rambo Mode for everyone on round start and end.

--[End]----------------------------------------------------------------------------------------

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
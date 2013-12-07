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
			v:SetHealth(200) --Sets health to 200.
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
	for k, v in ipairs (player.GetAll()) do
		if not v:IsRole(ROLE_TRAITOR) then
			v:Freeze(true)
			v:GodEnable()
			ULib.tsayColor(nil, true, Color(25, 25, 200), "Hunters ", Color(255, 255, 255), "are frozen and immune to damage for 10 seconds.")
			v:ChatPrint("You're frozen and cannot move for 10 seconds, be patient.")
			timer.Simple(10, function()
						v:Freeze(false)
						v:GodDisable()
						ULib.tsayColor(nil, wait, Color(25, 25, 200), "Hunters ", Color(255, 255, 255), "are now unfrozen and can take damage.")
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
function RamboMode()
	for k, v in ipairs (player.GetAll()) do
		if v:IsRole(ROLE_TRAITOR) then
			if v:GetCredits() < 1 then
				v:ChatPrint("You don't have enough credits to activate Rambo Mode.")
			else
				v:SetPData("gh_ramboenabled", true) --Bad way of saving it, but I'm not too sure of any other way to do it.
				v:StripAll()
				v:GodEnable()
				v:ChatPrint("Rambo Mode is enabled, you have God mode for 5 seconds")
				timer.Simple(0.05, function()
							v:Give("weapon_gh_rambo")
							end)
				timer.Simple(5, function()
							v:GodDisable()
							v:ChatPrint("God mode is now disabled")
							end)
				--What to add here: Something that makes Rambo-Hidden faster.
				--I need to override some default TTT functions.
				ULib.csay(nil, v:Nick() .. " has activated Rambo Mode!", 100)
				if v:Health() < 25 then
					v:ChatPrint("Your health is too low to be set to 25. Your health will be the same.")
				else
					v:SetHealth(25)
					v:ChatPrint("Your health has been set to 25.")
				end
			end
		elseif not v:IsRole(ROLE_TRAITOR) then
			v:ChatPrint("You're not even a Hidden...")
		elseif not v:Alive() then
			v:ChatPrint("You're sort of dead.")
		end
	end
end
--concommand.Add("RamboMode", RamboMode)

--[Helper Functions for Rambo Mode]------------------------------------------------------------

function CheckRamboCredit()
	for _, v in ipairs ( player.GetAll() ) do
		if v:IsRole( ROLE_TRAITOR ) then
			if v:GetPData( "gh_ramboenabled" ) == true then
				v:SubtractCredits(1)
			end
		end
	end
end
hook.Add( "GHCreditAward", CheckRamboCredit )

function RamboModeDisableDC( ply )
	if ply:IsRole( ROLE_TRAITOR ) then
		if ply:GetPData( "gh_ramboenabled" ) == true then
			ply:SetPData( "gh_ramboenabled", false )
		end
	end
end
hook.Add( "PlayerDisconnected", RamboModeDisableDC )

function RamboModeDisableDeath( ply, wep, att )
	if ply:IsRole( ROLE_TRAITOR ) then
		if ply:GetPData( "gh_ramboenabled" ) == true then
			ply:SetPData( "gh_ramboenabled", false )
		end
	end
end
hook.Add( "PlayerDeath", RamboModeDisableDeath )

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
hook.Add( "TTTEndRound", RamboModeDisableRound )

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
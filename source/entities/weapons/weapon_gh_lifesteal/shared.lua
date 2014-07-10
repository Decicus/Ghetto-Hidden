-- Lifesteal weapon
if SERVER then
	AddCSLuaFile()
end

SWEP.HoldType = "pistol"

if CLIENT then

	SWEP.PrintName = "Lifestealer"
	SWEP.Slot = 6
	
	SWEP.Icon = "VGUI/ttt/icon_flare" -- Need icon for it.
	SWEP.EquipmentData = {
		type = "Weapon",
		desc = "Lifesteal weapon. Takes 20 health from the target on hit and gives it to you unless the target has less than 20 health."
	}

end

SWEP.Base = "weapon_tttbase"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.WeaponID = 
SWEP.Kind = WEAPON_EQUIP1
SWEP.Primary.Ammo = "AirboatGun"
SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 0.6
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = 5
SWEP.Primary.ClipMax = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.AutoSpawnable = false

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel	= Model( "models/weapons/c_357.mdl" )
SWEP.WorldModel	= Model( "models/weapons/w_357.mdl" )

SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true -- Only bought once.

SWEP.AllowDrop = false
SWEP.IsSilent = true
SWEP.NoSights = true

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if not IsValid( self.Owner ) then return end
	
	local tr = self.Owner:GetEyeTrace().Entity
	local ply = self.Owner
	
	if IsValid( tr ) and tr:IsPlayer() or tr:IsBot() then
	
		if tr:Health() >= 20 then
		
			ply:SetHealth( ply:Health() + 20 )
			
		else
		
			ply:SetHealth( ply:Health() + tr:Health() )
		
		end
	
	end

end

function SWEP:ShouldDropOnDie()

	return false

end

function SWEP:OnDrop()

	self:Remove()
	
end
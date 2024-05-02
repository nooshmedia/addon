AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Inventory Pickup"
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
end

-- Variables that are used on both client and server

SWEP.Author = "Brickwall"
SWEP.Instructions = "Left click to pickup, right click to open inventory."
SWEP.Contact = ""
SWEP.Purpose = "Use inventory"

SWEP.WorldModel = ""
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Bricks Server"

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

function SWEP:Deploy()
    if( CLIENT or not IsValid( self:GetOwner() ) ) then return true end
    self:GetOwner():DrawWorldModel( false )
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PreDrawViewModel()
    return true
end

function SWEP:PrimaryAttack()
	if( SERVER ) then
		local ply = self.Owner
		
		if( not IsValid( ply ) or not ply:GetEyeTrace() ) then return end

		local traceEntity = ply:GetEyeTrace().Entity

		if( not IsValid( traceEntity ) ) then return end

		ply:BRS():AddInventoryEnt( traceEntity )
	end
end

function SWEP:Think()

end

function SWEP:SecondaryAttack()
	if( CLIENT ) then
		BRICKS_SERVER.Func.OpenInventory()
	end
end


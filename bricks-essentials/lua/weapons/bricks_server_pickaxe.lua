if CLIENT then
	SWEP.PrintName = "Pickaxe"
	SWEP.Slot = 1
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

-- Variables that are used on both client and server

SWEP.Author = "Brickwall"
SWEP.Instructions = "Left click to hit rocks."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/sterling/c_crafting_pickaxe.mdl")
SWEP.WorldModel = Model("models/sterling/w_crafting_pickaxe.mdl")
SWEP.HoldType = "melee";

SWEP.UseHands = true

SWEP.Spawnable = true	
SWEP.Category = "Bricks Server"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 1;
SWEP.Primary.Delay = 1;
SWEP.Primary.Ammo = "";

--[[-------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
function SWEP:Initialize()
	self:SendWeaponAnim(ACT_VM_HOLSTER);
end

function SWEP:DoHitEffects()
	local trace = self.Owner:GetEyeTraceNoCursor();
	
	if (((trace.Hit or trace.HitWorld) and self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) and IsValid(trace.Entity) and trace.Entity:GetClass() == "bricks_server_rock" ) then
		self:SendWeaponAnim(ACT_VM_HITCENTER);
		self:EmitSound("physics/concrete/rock_impact_hard5.wav");

		local bullet = {}
		bullet.Num    = 1
		bullet.Src    = self.Owner:GetShootPos()
		bullet.Dir    = self.Owner:GetAimVector()
		bullet.Spread = Vector(0, 0, 0)
		bullet.Tracer = 0
		bullet.Force  = 3
		bullet.Damage = 0
		self.Owner:DoAttackEvent()
		self.Owner:FireBullets(bullet) 
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
		self:EmitSound("npc/vort/claw_swing2.wav");
	end;
end;

function SWEP:DoAnimations(idle)
	if (!idle) then
		self.Owner:SetAnimation(PLAYER_ATTACK1);
	end;
end;

--[[-------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self:DoAnimations();
	self:DoHitEffects();
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )
	
	if (SERVER) then
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(true);
		end;
		
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
			if (IsValid(trace.Entity)) then
				if( trace.Entity:GetClass() == "bricks_server_rock" ) then
					if( BRICKS_SERVER.CONFIG.CRAFTING.RockTypes[trace.Entity:GetRockType() or ""] ) then
						trace.Entity:HitRock( 34, self.Owner )
					end
				end
			end;
		end;
		
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false);
		end;
	end;
end

function SWEP:SecondaryAttack()
end

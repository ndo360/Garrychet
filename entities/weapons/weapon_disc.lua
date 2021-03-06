if CLIENT then
	SWEP.PrintName = "Ricochet Disk"
	SWEP.ViewModelFOV = 70

	SWEP.Slot = 0
	SWEP.SlotPos = 1
end

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "slam"
SWEP.ViewModel = ""

SWEP.WorldModel = "models/disc.mdl"

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Delay = 0.6

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 0.6

SWEP.NextThink = 0

SWEP.Offset = {
	Pos = {
		Up = 1,
		Right = -3,
		Forward = 0,
	},
	Ang = {
		Up = 0,
		Right = 0,
		Forward = 180,
	},
	Scale = 1
}

function SWEP:Initialize() 
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Precache()
	util.PrecacheSound("weapons/knife/knife_slash1.wav")
end

function SWEP:Deploy()
	local owner = self.Owner

	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetModelScale( 0.5, 0)

	return true
end

function SWEP:CanAttack()
	return self:GetNextPrimaryFire() < CurTime()
end

function SWEP:CreateDisk(ammo, power)
	local owner = self.Owner
	local angles = owner:GetAngles()
	local col = team.GetColor(owner:Team())

	if SERVER then
		--[[if owner:GetPowerup() == POWERUP_FAST then
			self:SetFireSpeed(0.3)
		end]]
	end

	--self.LastFire = CurTime()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:TakePrimaryAmmo(ammo)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	owner:SetAnimation(PLAYER_ATTACK1)

	if SERVER then
		local disc = ents.Create("projectile_disc")
		disc:SetPos(owner:GetPos() + owner:GetForward() * 16 + Vector(0, 0, 36))
		disc:SetOwner(owner)
		disc:SetColor(Color(col.r, col.g, col.b, 255))
		disc:SetAngles(Angle(0, angles.yaw, 0))
		disc:Spawn()
		disc:SetAmmoBack(ammo)
		disc:Launch(1000)
		disc:SetPowerShot(power)
	end
end

function SWEP:DrawWorldModel()
	local owner = self.Owner
	local hand, offset, rotate

	if not IsValid(owner) then
		self:DrawModel()
		return
	end

	if not self.Hand then
		self.Hand = owner:LookupAttachment("anim_attachment_rh")
	end

	hand = owner:GetAttachment(self.Hand)

	if not hand then
		self:DrawModel()
		return
	end

	offset = hand.Ang:Right() * self.Offset.Pos.Right + hand.Ang:Forward() * self.Offset.Pos.Forward + hand.Ang:Up() * self.Offset.Pos.Up

	hand.Ang:RotateAroundAxis(hand.Ang:Right(), self.Offset.Ang.Right)
	hand.Ang:RotateAroundAxis(hand.Ang:Forward(), self.Offset.Ang.Forward)
	hand.Ang:RotateAroundAxis(hand.Ang:Up(), self.Offset.Ang.Up)

	self:DrawModel()
	self:SetColor(team.GetColor(owner:Team()))
	self:SetMaterial("models/debug/shiny")
	self:SetRenderOrigin(hand.Pos + offset)
	self:SetRenderAngles(hand.Ang)
end

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	if not self:CanAttack() then return end

	self:CreateDisk(1, false)
end

function SWEP:SecondaryAttack()
	if self:Clip1() < 3 then return end
	if not self:CanAttack() then return end

	self:CreateDisk(3, true)
end

function SWEP:Reload()
	return false
end

if CLIENT then
	function SWEP:DrawHUD()
		local x = ScrW() * 0.5
		local y = ScrH() * 0.5
		local size = 12

		surface.SetDrawColor(COLOR_GREEN)
		surface.DrawLine(x, y, x + size, y)
		surface.DrawLine(x, y, x - size, y)
		surface.DrawLine(x, y, x, y + size)
		surface.DrawLine(x, y, x, y - size)
	end
end

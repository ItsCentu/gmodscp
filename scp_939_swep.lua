-- weapon_scp_939.lua
if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "SCP-939"
SWEP.Author = "Centu"
SWEP.Instructions = "Left-click to bite, right-click to mimic sounds."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Base = "weapon_base"

-- Weapon properties
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- Model & sounds
SWEP.ViewModel = "models/weapons/v_hands.mdl"  -- Placeholder
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"  -- Placeholder

-- Attack range and damage
SWEP.BiteDamage = 50
SWEP.BiteRange = 75

-- Sound Table
SWEP.Sounds = {
    Bite = {
        "npc/zombie/claw_strike1.wav",
        "npc/zombie/claw_strike2.wav",
        "npc/zombie/claw_strike3.wav"
    },
    Mimic = {
        "npc/zombie/zombie_alert1.wav",
        "npc/zombie/zombie_alert2.wav"
    },
    Ambient = {
        "ambient/creatures/town_zombie_call1.wav",
        "ambient/creatures/town_zombie_call2.wav"
    }
}

function SWEP:Initialize()
    self:SetHoldType("melee")
end

-- Function to play a random sound from a specific category
function SWEP:PlayRandomSound(category)
    local soundList = self.Sounds[category]
    if not soundList then return end
    local randomSound = soundList[math.random(#soundList)]
    self:GetOwner():EmitSound(randomSound)
end

-- Primary attack: Bite
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1.5)  -- 1.5 seconds cooldown

    if CLIENT then return end

    -- Play bite sound
    self:PlayRandomSound("Bite")

    local ply = self:GetOwner()
    local tr = ply:GetEyeTrace()  -- Trace a line to see if we're close to hitting something
    if tr.Hit and tr.HitPos:Distance(ply:GetPos()) <= self.BiteRange then
        local target = tr.Entity
        if IsValid(target) and target:IsPlayer() or target:IsNPC() then
            local dmg = DamageInfo()
            dmg:SetDamage(self.BiteDamage)
            dmg:SetAttacker(ply)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_SLASH)
            target:TakeDamageInfo(dmg)
        end
    end
end

-- Secondary attack: Mimic Sound
function SWEP:SecondaryAttack()
    if CLIENT then return end

    self:SetNextSecondaryFire(CurTime() + 5)  -- Mimic cooldown
    -- Play mimic sound
    self:PlayRandomSound("Mimic")
end

-- Function to update player visibility based on movement and voice activity
function SWEP:UpdatePlayerVisibility()
    local owner = self:GetOwner()  -- SCP-939 player
    if not IsValid(owner) then return end

    for _, ply in ipairs(player.GetAll()) do
        if ply == owner then continue end  -- Skip SCP-939 player itself

        -- Check if player is running, talking, or crouch-walking
        if ply:IsOnGround() then
            if ply:GetVelocity():Length() > 200 and not ply:Crouching() then
                ply:SetNoDraw(false)  -- Running or walking normally (make visible)
            elseif ply:IsSpeaking() then
                ply:SetNoDraw(false)  -- Talking (make visible)
            elseif ply:Crouching() and ply:GetVelocity():Length() > 0 then
                ply:SetNoDraw(true)  -- Crouch-walking (make invisible)
            else
                ply:SetNoDraw(true)  -- Standing still or just crouching (make invisible)
            end
        end
    end
end

-- Deploy function to start the visibility timer
function SWEP:Deploy()
    if not self.BaseClass.Deploy(self) then return end

    -- Start checking visibility conditions
    timer.Create("SCP939_Visibility_Check" .. self:EntIndex(), 0.1, 0, function()
        if not IsValid(self) or not IsValid(self:GetOwner()) then return end
        self:UpdatePlayerVisibility()
    end)

    return true
end

-- Clean up the timer when the weapon is holstered or removed
function SWEP:Holster()
    timer.Remove("SCP939_Visibility_Check" .. self:EntIndex())
    return true
end

function SWEP:OnRemove()
    timer.Remove("SCP939_Visibility_Check" .. self:EntIndex())
end

SWEP.PrintName = "SCP 035"
SWEP.Author = "Centu"
SWEP.Instruction = "M1: Take control of user, LMB: Deal damage"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "None"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.UseHands = true

SWEP.ShootSound = Sound("weapons/pistol/pistol_fire2.wav")
SWEP.FrozenModel = "models/props/scp/scp035/035_mask.mdl"
SWEP.ControlledModel = "models/vinrax/player/035_player.mdl"  -- The controlled model

-- Offset vector to lift the frozen model above ground
local modelOffset = Vector(0, 0, 20)  -- Adjust the Z component as needed

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then
        -- Make the player semi-transparent and unable to move
        owner:SetRenderMode(RENDERMODE_TRANSALPHA)
        owner:SetColor(Color(255, 255, 255, 150))  -- 150 is the alpha value
        owner:SetModel(self.FrozenModel)  -- Set the frozen model
        owner:SetNWBool("IsFrozen", true)  -- Prevent the player from moving
        owner:SetNWBool("IsControlled", false)  -- Indicate that the player is not yet in control

        -- Enable god mode if the method exists
        if owner.GodEnable then
            owner:GodEnable()
        end

        -- Adjust position of the frozen model
        owner:SetPos(owner:GetPos() + modelOffset)
    end
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then
        -- Disable god mode if the method exists
        if owner.GodDisable then
            owner:GodDisable()
        end

        -- Restore the player's ability to move and reset their transparency
        owner:SetNWBool("IsFrozen", false)
        owner:SetNWBool("IsControlled", false)
        owner:SetRenderMode(RENDERMODE_NORMAL)
        owner:SetColor(Color(255, 255, 255, 255))  -- Fully opaque
        owner:SetModel(player_manager.TranslateToPlayerModelName(owner:GetModel()))  -- Reset to their original model
    end
    return true
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    local tr = owner:GetEyeTrace()
    local target = tr.Entity

    if IsValid(target) and target:IsPlayer() and target:GetPos():Distance(owner:GetPos()) <= 100 then
        -- Play shoot sound
        self:EmitSound(self.ShootSound)

        -- Kill the target player
        target:Kill()

        -- Restore owner's ability to move and reset their transparency
        owner:SetNWBool("IsFrozen", false)
        owner:SetRenderMode(RENDERMODE_NORMAL)
        owner:SetColor(Color(255, 255, 255, 255))  -- Fully opaque
        owner:SetModel(self.ControlledModel)  -- Set the new model when the user takes control
        owner:SetNWBool("IsControlled", true)  -- Indicate that the player is now in control

        -- Disable god mode if the method exists
        if owner.GodDisable then
            owner:GodDisable()
        end

        -- Set cooldown for next attack
        self:SetNextPrimaryFire(CurTime() + 1)
    else
        owner:ChatPrint("No player in range or in sight to take control of!")
    end
end

function SWEP:SecondaryAttack()
    if not SERVER then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    -- Only allow secondary attack if the player is in the controlled state
    if not owner:GetNWBool("IsControlled", false) then return end

    local tr = owner:GetEyeTrace()
    local target = tr.Entity

    if IsValid(target) and target:IsPlayer() and target:GetPos():Distance(owner:GetPos()) <= 100 then
        -- Deal 50 damage to the target
        local dmg = DamageInfo()
        dmg:SetDamage(100)
        dmg:SetAttacker(owner)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_GENERIC)
        target:TakeDamageInfo(dmg)

        -- Set cooldown for next attack
        self:SetNextSecondaryFire(CurTime() + 1)
    else
        owner:ChatPrint("No player in range or in sight to attack!")
    end
end

function SWEP:DrawWorldModel()
    -- Do nothing, effectively making the world model invisible
end

hook.Add("StartCommand", "SCP035FreezeMovement", function(ply, cmd)
    if ply:GetNWBool("IsFrozen", false) then
        cmd:ClearMovement()  -- Prevents movement while still allowing the player to turn
    end
end)

-- Table to define which teams should have instant respawn behavior
local teamsWithRespawn = {
    [TEAM_SCP035] = true,  -- Replace TEAM_DClass with your actual team ID
}

-- PlayerDeath hook to handle instant respawn
hook.Add("PlayerDeath", "SCP035InstantRespawn", function(victim, inflictor, attacker)
    if IsValid(victim) and victim:IsPlayer() then
        local victimTeam = victim:Team()

        -- Check if the victim's team is in the teamsWithRespawn table and if they have the SCP 035 SWEP
        if teamsWithRespawn[victimTeam] and victim:HasWeapon("scp_035_swep") then
            -- Store death position
            local deathPos = victim:GetPos()

            -- Delay respawn to the next frame to ensure all death processes are completed
            timer.Simple(0, function()
                if IsValid(victim) then
                    -- Preserve god mode if it was active before respawn
                    if victim.GodEnable then
                        local wasGod = victim:HasGodMode()

                        -- Respawn at death position
                        victim:Spawn()
                        victim:SetPos(deathPos)

                        -- Restore god mode
                        if wasGod then
                            victim:GodEnable()
                        end

                        -- Give SCP 035 SWEP
                        victim:StripWeapons()
                        victim:Give("scp_035_swep")

                        -- Optionally, you can set other attributes like model, render mode, etc.
                        -- Example:
                        -- victim:SetModel("models/vinrax/player/035_player.mdl")
                        -- victim:SetRenderMode(RENDERMODE_TRANSALPHA)
                        -- victim:SetColor(Color(255, 255, 255, 150))
                    end
                end
            end)
        end
    end
end)

-- PlayerSpawn hook to handle post-respawn settings
hook.Add("PlayerSpawn", "SCP035PostRespawn", function(player)
    -- Check if the player has the SCP 035 SWEP
    if player:HasWeapon("scp_035_swep") then
        -- Set full health upon respawn if necessary
        player:SetHealth(player:GetMaxHealth())

        -- Enable god mode after 3 seconds if the method exists
        if player.GodEnable then
            timer.Simple(6, function()
                if IsValid(player) and player:HasWeapon("scp_035_swep") then
                    player:GodEnable()
                end
            end)
        end
    end
end)
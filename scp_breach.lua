-- Example breach positions and timers
local breachPositions = {
    [TEAM_173] = Vector(-5, 334, -83), -- Replace with actual positions, ensure no trailing comma
    -- Add other SCP teams and their positions here
}

-- Breach timers (in seconds)
local breachTimers = {
    [TEAM_173] = 10, -- 10 seconds for SCP-173
    -- Add other SCP teams and their timers here
}

-- Cooldown times (in seconds)
local breachCooldowns = {
    [TEAM_173] = 60, -- 60 seconds cooldown for SCP-173
    -- Add other SCP teams and their cooldowns here
}

-- Table to store active timers
local activeTimers = {}

-- Table to store cooldown end times
local cooldownEndTimes = {}

if SERVER then
    print("Running scp_breach.lua")
    
    util.AddNetworkString("NotifyBreach")
    util.AddNetworkString("NotifyStopBreach")

    -- Handle chat commands
    hook.Add("PlayerSay", "HandleBreachCommands", function(ply, text)
        local args = string.Explode(" ", text)
        local command = args[1]
        
        if command == "/breach" then
            local scpTeam = ply:Team()
            local breachPos = breachPositions[scpTeam]
            local breachTime = breachTimers[scpTeam]
            local cooldownTime = breachCooldowns[scpTeam]
            local currentTime = CurTime()

            if not cooldownTime then
                ply:ChatPrint("Your team does not have a defined cooldown time.")
                return ""
            end

            if breachPos and breachTime then
                if cooldownEndTimes[ply:SteamID()] and cooldownEndTimes[ply:SteamID()] > currentTime then
                    local remainingCooldown = math.ceil(cooldownEndTimes[ply:SteamID()] - currentTime)
                    ply:ChatPrint("You must wait " .. remainingCooldown .. " seconds before breaching again.")
                    return ""
                end

                ply:ChatPrint("Breach initiated. You will be moved in " .. breachTime .. " seconds.")
                
                -- Notify all players of the breach
                net.Start("NotifyBreach")
                net.WriteString(team.GetName(scpTeam) .. " is breaching in " .. breachTime .. " seconds!")
                net.Broadcast()

                -- Create a unique timer identifier
                local timerID = "BreachTimer_" .. ply:SteamID()
                activeTimers[ply:SteamID()] = timerID
                cooldownEndTimes[ply:SteamID()] = currentTime + cooldownTime

                -- Delay the teleportation by the specified time
                timer.Create(timerID, breachTime, 1, function()
                    if IsValid(ply) and ply:Team() == scpTeam then
                        ply:SetPos(breachPos)
                        ply:ChatPrint("You have been breached out of your cell.")
                    end
                    activeTimers[ply:SteamID()] = nil
                end)
            else
                ply:ChatPrint("Your team does not have a defined breach position or timer.")
            end
            
            return ""
        elseif command == "/stopbreach" then
            local timerID = activeTimers[ply:SteamID()]

            if timerID and timer.Exists(timerID) then
                timer.Remove(timerID)
                activeTimers[ply:SteamID()] = nil
                ply:ChatPrint("Breach stopped.")

                -- Notify all players that the breach was stopped
                net.Start("NotifyStopBreach")
                net.WriteString(team.GetName(ply:Team()) .. " breach has been stopped.")
                net.Broadcast()
            else
                ply:ChatPrint("No active breach to stop.")
            end

            return ""
        end
    end)
end

if CLIENT then
    -- Handle receiving the breach notification
    net.Receive("NotifyBreach", function()
        local message = net.ReadString()
        chat.AddText(Color(255, 0, 0), message)
    end)

    -- Handle receiving the stop breach notification
    net.Receive("NotifyStopBreach", function()
        local message = net.ReadString()
        chat.AddText(Color(0, 255, 0), message)
    end)
end

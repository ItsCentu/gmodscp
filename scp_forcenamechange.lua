if SERVER then
    print("Running sv_namechange.lua")

    hook.Add("InitPostEntity", "InitializeNameChangeScript", function()
        print("Initializing name change script after all entities have loaded")

        -- Ensure team constants are defined
        TEAM_173 = TEAM_173 or 1  -- Replace with actual team IDs

        -- Table storing the new names for each team
        local teamNameChanges = {
            [TEAM_173] = "SCP-173",
            -- Add more teams and their corresponding new names here
        }

        -- Table to store original names
        local originalNames = {}

        -- Function to save the original name
        local function saveOriginalName(ply)
            if not originalNames[ply:SteamID()] then
                originalNames[ply:SteamID()] = ply:Nick()
            end
        end

        hook.Add("PlayerChangedTeam", "ForceNameChangeOnTeamSwitch", function(ply, oldTeam, newTeam)
            print("PlayerChangedTeam hook triggered")
            print("Player: " .. ply:Nick() .. ", New Team: " .. tostring(newTeam))

            -- Check if the player is switching to an SCP team
            if teamNameChanges[newTeam] then
                saveOriginalName(ply)
                local newName = teamNameChanges[newTeam]
                print("Changing name to: " .. newName)

                -- Check if DarkRP functions exist
                if ply.setRPName then
                    ply:setRPName(newName)
                    ply:ChatPrint("Your roleplay name has been changed to " .. newName)
                    print("Roleplay name changed to " .. newName)
                else
                    print("DarkRP function setRPName not found")
                end
            -- Check if the player is switching from an SCP team to another team
            elseif originalNames[ply:SteamID()] then
                local originalName = originalNames[ply:SteamID()]
                print("Restoring original name: " .. originalName)

                -- Check if DarkRP functions exist
                if ply.setRPName then
                    ply:setRPName(originalName)
                    ply:ChatPrint("Your roleplay name has been restored to " .. originalName)
                    print("Roleplay name restored to " .. originalName)

                    -- Remove the saved original name after restoring
                    originalNames[ply:SteamID()] = nil
                else
                    print("DarkRP function setRPName not found")
                end
            else
                print("No name change required for team " .. tostring(newTeam))
            end
        end)
    end)
end

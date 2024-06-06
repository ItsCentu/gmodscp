hook.Add("InitPostEntity", "InitPostEntity_SCP_Codes", function()
    -- Example Sounds
    -- ambient/water/drip1.wav: Water Dripping
    -- ambient/atmosphere/cave_hit5.wav: Cave Ambiance
    -- buttons/button14.wav: Button Click
    -- buttons/button9.wav: Positive Confirmation
    -- buttons/button10.wav: Negative Confirmation
    -- buttons/lightswitch2.wav: Toggle Switch
    -- ambient/machines/thumper_startup1.wav: Machinery Startup

    local soundOfUi = "ambient/water/drip1.wav" -- The sound of when the code changes

    if SERVER then
        print("Running scp_codes.lua")
        
        util.AddNetworkString("UpdateHUDText")
        util.AddNetworkString("PlaySound")

        -- Table to hold allowed teams and their corresponding commands
        local allowedTeams = {
            [TEAM_SD] = true, -- Add other teams here
        }

        -- Table to hold commands and their corresponding text and color
        local commandTable = {
            ["/cdyellow"] = {text = "Code: Yellow", color = Color(255, 255, 0)},
            ["/cdgreen"] = {text = "Code: Green", color = Color(0, 255, 0)},
            ["/cdorange"] = {text = "Code: Orange", color = Color(225, 102, 0)},
            ["/cdred"] = {text = "Code: Red", color = Color(225, 0, 0)},
            ["/cdblack"] = {text = "Code: Black", color = Color(0, 0, 0)},
        }

        -- Handle chat commands
        hook.Add("PlayerSay", "HandleChatCommands", function(ply, text)
            local args = string.Explode(" ", text)
            local command = args[1]

            -- Check if the command exists and the player is in an allowed team
            if commandTable[command] and allowedTeams[ply:Team()] then
                local cmdData = commandTable[command]
                net.Start("UpdateHUDText")
                net.WriteString(cmdData.text)
                net.WriteColor(cmdData.color)
                net.Broadcast()
                
                -- Play sound for everyone
                net.Start("PlaySound")
                net.Broadcast()
                
                return ""
            end
        end)
    end

    if CLIENT then
        local hudText = "Code: Green"
        local hudColor = Color(0, 255, 42)

        -- Create a custom font
        surface.CreateFont("CustomLargeFont", {
            font = "Arial",  -- Font face
            size = 40,       -- Font size
            weight = 700,    -- Font weight
            antialias = true -- Enable antialiasing
        })

        -- Update text and color from server
        net.Receive("UpdateHUDText", function()
            hudText = net.ReadString()
            hudColor = net.ReadColor()
        end)
        
        -- Play sound from server
        net.Receive("PlaySound", function()
            print("Running Sounds!")
            -- Test with a known sound
            surface.PlaySound(soundOfUi) -- Replace with your desired sound
            -- Alternative method to play sound
            LocalPlayer():EmitSound(soundOfUi) -- Replace with your desired sound
        end)

        hook.Add("HUDPaint", "HUDPaint_DrawABox", function()
            local scrw, scrh = ScrW(), ScrH()
            local boxWidth, boxHeight = 300, 50
            local boxX, boxY = 1600, 50

            -- Draw the box
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(boxX, boxY, boxWidth, boxHeight)

            -- Calculate the position for the text to be centered
            surface.SetFont("CustomLargeFont")
            local textWidth, textHeight = surface.GetTextSize(hudText)
            local textX = boxX + (boxWidth - textWidth) / 2
            local textY = boxY + (boxHeight - textHeight) / 2

            -- Draw the text
            draw.DrawText(hudText, "CustomLargeFont", textX, textY, hudColor, TEXT_ALIGN_LEFT)
        end)
    end
end)

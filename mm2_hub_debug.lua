-- MM2 HUB - DEBUG VERSION
print("[MM2 HUB] Starting load...")

pcall(function()
    print("[MM2 HUB] Inside pcall")
    
    local LocalPlayer = game.Players.LocalPlayer
    print("[MM2 HUB] LocalPlayer:", LocalPlayer.Name)
    print("[MM2 HUB] Character:", LocalPlayer.Character)
    
    local function SimpleESP()
        print("[MM2 HUB] Starting ESP setup")
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer then
                print("[MM2 HUB] Processing player:", player.Name)
                
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    
                    -- Create simple billboard
                    local bbGui = Instance.new("BillboardGui")
                    bbGui.Size = UDim2.new(0, 150, 0, 50)
                    bbGui.Adornee = hrp
                    bbGui.AlwaysOnTop = true
                    bbGui.MaxDistance = 500
                    
                    local textLabel = Instance.new("TextLabel", bbGui)
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextSize = 12
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.Text = player.Name
                    
                    bbGui.Parent = hrp
                    print("[MM2 HUB] ESP added to:", player.Name)
                end
            end
        end
        
        -- Connect to new players
        game.Players.PlayerAdded:Connect(function(newPlayer)
            print("[MM2 HUB] New player joined:", newPlayer.Name)
            newPlayer.CharacterAdded:Connect(function(character)
                print("[MM2 HUB] Character loaded for:", newPlayer.Name)
                task.wait(1)
                if character:FindFirstChild("HumanoidRootPart") then
                    local bbGui = Instance.new("BillboardGui")
                    bbGui.Size = UDim2.new(0, 150, 0, 50)
                    bbGui.Adornee = character.HumanoidRootPart
                    bbGui.AlwaysOnTop = true
                    bbGui.MaxDistance = 500
                    
                    local textLabel = Instance.new("TextLabel", bbGui)
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextSize = 12
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.Text = newPlayer.Name
                    
                    bbGui.Parent = character.HumanoidRootPart
                end
            end)
        end)
    end
    
    SimpleESP()
    print("[MM2 HUB] Setup complete!")
    
end)

print("[MM2 HUB] Script finished loading")

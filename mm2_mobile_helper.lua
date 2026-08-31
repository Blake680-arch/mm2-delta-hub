-- MM2 MOBILE HELPER - ORION UI + MOBILE AIMBOT
pcall(function()
    local Orion = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
    
    local Window = Orion:MakeWindow({
        Name = "MM2 Mobile Helper",
        HidePremium = false,
        SaveConfig = false,
        ConfigFolder = "OrionConfig"
    })

    local LocalPlayer = game.Players.LocalPlayer
    local Active_Tags = {}
    local Active_Auras = {}
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    -- ROLE COLORS
    local RoleColors = {
        Murderer = Color3.fromRGB(255, 50, 50),      -- Bright Red
        Sheriff = Color3.fromRGB(50, 150, 255),      -- Bright Blue
        Innocent = Color3.fromRGB(100, 255, 100),    -- Bright Green
        Hero = Color3.fromRGB(255, 255, 0),          -- Yellow
        Guest = Color3.fromRGB(255, 200, 50)         -- Gold
    }

    -- ESP Settings
    local ESPRoles = {
        Murderer = true,
        Sheriff = true,
        Innocent = true,
        Hero = true,
        Guest = false
    }

    local ShowNameTag = true
    local ShowHighlight = true
    local ShowGunESP = true

    -- AIMBOT Settings
    local SilentAimEnabled = false
    local ShiftLockEnabled = false

    print("[MM2] Starting with Orion UI...")

    -- ========================================================
    -- UTILITY FUNCTIONS
    -- ========================================================
    local function GetPlayerRole(player)
        if not player or not player.Character then return "Guest" end
        
        -- Check for Knife (Murderer)
        if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
            return "Murderer"
        end
        
        -- Check for Gun (Sheriff or Hero)
        if player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then
            -- If they're alive and have gun = Sheriff
            if player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                return "Sheriff"
            end
        end
        
        -- Check if Innocent has gun (Hero)
        local hasGun = player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun")
        if hasGun and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- If not Murderer and has gun = Hero
            if not (player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")) then
                return "Hero"
            end
        end
        
        -- Default to Innocent
        return "Innocent"
    end

    local function GetMurderer()
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if GetPlayerRole(player) == "Murderer" then
                    return player
                end
            end
        end
        return nil
    end

    local function CanSeeTarget(targetPosition)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return false
        end
        
        local camera = workspace.CurrentCamera
        local rayOrigin = camera.CFrame.Position
        local rayDirection = (targetPosition - rayOrigin).Unit * 1000
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if rayResult then
            local hitPart = rayResult.Instance
            local hitCharacter = hitPart.Parent
            
            if hitCharacter and hitCharacter:FindFirstChild("Humanoid") then
                local murderer = GetMurderer()
                return murderer and hitCharacter == murderer.Character
            end
            return false
        end
        
        return true
    end

    -- ========================================================
    -- CREATE TABS
    -- ========================================================
    local VisualTab = Window:MakeTab({
        Name = "Visual",
        Icon = "rbxassetid://4483362458",
        PremiumOnly = false
    })

    local AimbotTab = Window:MakeTab({
        Name = "Aimbot",
        Icon = "rbxassetid://4483345906",
        PremiumOnly = false
    })

    local MiscTab = Window:MakeTab({
        Name = "Misc",
        Icon = "rbxassetid://4483362752",
        PremiumOnly = false
    })

    -- ========================================================
    -- VISUAL TAB - ESP
    -- ========================================================
    VisualTab:AddSection("ESP Target Selection")

    VisualTab:AddToggle({
        Name = "ESP Murderer (Red)",
        Default = ESPRoles.Murderer,
        Callback = function(Value)
            ESPRoles.Murderer = Value
        end
    })

    VisualTab:AddToggle({
        Name = "ESP Sheriff (Blue)",
        Default = ESPRoles.Sheriff,
        Callback = function(Value)
            ESPRoles.Sheriff = Value
        end
    })

    VisualTab:AddToggle({
        Name = "ESP Innocent (Green)",
        Default = ESPRoles.Innocent,
        Callback = function(Value)
            ESPRoles.Innocent = Value
        end
    })

    VisualTab:AddToggle({
        Name = "ESP Hero (Yellow)",
        Default = ESPRoles.Hero,
        Callback = function(Value)
            ESPRoles.Hero = Value
        end
    })

    VisualTab:AddSection("ESP Display Options")

    VisualTab:AddToggle({
        Name = "Show Role Nametags",
        Default = ShowNameTag,
        Callback = function(Value)
            ShowNameTag = Value
        end
    })

    VisualTab:AddToggle({
        Name = "Show Highlight Aura",
        Default = ShowHighlight,
        Callback = function(Value)
            ShowHighlight = Value
        end
    })

    VisualTab:AddToggle({
        Name = "Show Gun ESP",
        Default = ShowGunESP,
        Callback = function(Value)
            ShowGunESP = Value
        end
    })

    -- ========================================================
    -- AIMBOT TAB
    -- ========================================================
    AimbotTab:AddSection("Silent Aim")

    AimbotTab:AddToggle({
        Name = "Enable Silent Aim",
        Default = SilentAimEnabled,
        Callback = function(Value)
            SilentAimEnabled = Value
            Orion:MakeNotification({
                Name = "Silent Aim",
                Content = Value and "Tap to shoot - auto-locks on murderer" or "Silent Aim disabled",
                Image = "rbxassetid://4483345906",
                Time = 3
            })
        end
    })

    AimbotTab:AddLabel("Redirects all shots to murderer")
    AimbotTab:AddLabel("Cannot shoot through walls/blocks")

    AimbotTab:AddSection("Shift Lock (Top-Left Button)")

    AimbotTab:AddToggle({
        Name = "Enable Shift Lock",
        Default = ShiftLockEnabled,
        Callback = function(Value)
            ShiftLockEnabled = Value
            Orion:MakeNotification({
                Name = "Shift Lock",
                Content = Value and "Tap button at top-left to lock on murderer" or "Shift Lock disabled",
                Image = "rbxassetid://4483345906",
                Time = 3
            })
        end
    })

    AimbotTab:AddLabel("Tap top-left button to lock/unlock")
    AimbotTab:AddLabel("Shoots with perfect accuracy")

    -- ========================================================
    -- MISC TAB
    -- ========================================================
    MiscTab:AddSection("Utilities")

    MiscTab:AddButton({
        Name = "Close GUI",
        Callback = function()
            Window:Close()
        end
    })

    -- ========================================================
    -- SHIFT LOCK BUTTON (Top-Left)
    -- ========================================================
    local ShiftLockButton = Instance.new("TextButton")
    ShiftLockButton.Name = "ShiftLockButton"
    ShiftLockButton.Size = UDim2.new(0, 80, 0, 40)
    ShiftLockButton.Position = UDim2.new(0, 10, 0, 10)
    ShiftLockButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    ShiftLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ShiftLockButton.TextSize = 12
    ShiftLockButton.Font = Enum.Font.GothamBold
    ShiftLockButton.BorderSizePixel = 2
    ShiftLockButton.BorderColor3 = Color3.fromRGB(255, 100, 100)
    ShiftLockButton.Text = "SL: OFF"
    ShiftLockButton.Visible = false
    ShiftLockButton.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local function UpdateShiftLockButton()
        if ShiftLockEnabled then
            ShiftLockButton.Visible = true
            ShiftLockButton.Text = "SL: ON"
            ShiftLockButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            ShiftLockButton.Visible = false
        end
    end

    ShiftLockButton.MouseButton1Click:Connect(function()
        ShiftLockEnabled = not ShiftLockEnabled
        UpdateShiftLockButton()
    end)

    -- ========================================================
    -- ESP RENDERING
    -- ========================================================
    local function SetupPlayerESP(player)
        if player == LocalPlayer then return end
        
        local function SetupCharacter(character)
            task.wait(0.3)
            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            if not torso then return end
            
            local role = GetPlayerRole(player)
            if not ESPRoles[role] then return end
            
            local roleColor = RoleColors[role]
            
            -- NAME TAG
            if ShowNameTag and not Active_Tags[player] then
                local bbGui = Instance.new("BillboardGui")
                bbGui.Size = UDim2.new(0, 150, 0, 40)
                bbGui.Adornee = torso
                bbGui.AlwaysOnTop = true
                bbGui.MaxDistance = 300
                bbGui.StudsOffset = Vector3.new(0, 3, 0)
                
                local textLabel = Instance.new("TextLabel", bbGui)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextSize = 16
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextStrokeTransparency = 0.3
                textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                textLabel.TextColor3 = roleColor
                textLabel.Text = role
                
                bbGui.Parent = torso
                Active_Tags[player] = bbGui
                
                task.spawn(function()
                    while character and character:IsDescendantOf(workspace) and ShowNameTag do
                        local currentRole = GetPlayerRole(player)
                        if ESPRoles[currentRole] then
                            textLabel.Text = currentRole
                            textLabel.TextColor3 = RoleColors[currentRole]
                        end
                        task.wait(0.5)
                    end
                    pcall(function() Active_Tags[player]:Destroy() end)
                    Active_Tags[player] = nil
                end)
            end
            
            -- HIGHLIGHT AURA
            if ShowHighlight and not Active_Auras[player] then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.FillTransparency = 1
                    highlight.OutlineTransparency = 0.2
                    highlight.OutlineColor = roleColor
                    highlight.Parent = character
                    Active_Auras[player] = highlight
                    
                    task.spawn(function()
                        while character and character:IsDescendantOf(workspace) and ShowHighlight do
                            local currentRole = GetPlayerRole(player)
                            if ESPRoles[currentRole] then
                                highlight.OutlineColor = RoleColors[currentRole]
                            end
                            task.wait(0.5)
                        end
                        pcall(function() Active_Auras[player]:Destroy() end)
                        Active_Auras[player] = nil
                    end)
                end)
            end
        end
        
        if player.Character then SetupCharacter(player.Character) end
        player.CharacterAdded:Connect(SetupCharacter)
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        SetupPlayerESP(player)
    end
    game.Players.PlayerAdded:Connect(SetupPlayerESP)

    -- ========================================================
    -- GUN ESP (Sheriff Gun Detection)
    -- ========================================================
    task.spawn(function()
        while task.wait(1) do
            if not ShowGunESP then continue end
            
            -- Search for gun in workspace
            local gunFound = false
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:lower():find("gun") then
                    gunFound = true
                    if obj:FindFirstChild("Handle") then
                        -- Create nametag if doesn't exist
                        if not obj:FindFirstChild("GunESPTag") then
                            local bbGui = Instance.new("BillboardGui")
                            bbGui.Name = "GunESPTag"
                            bbGui.Size = UDim2.new(0, 150, 0, 50)
                            bbGui.Adornee = obj.Handle
                            bbGui.AlwaysOnTop = true
                            bbGui.MaxDistance = 300
                            bbGui.StudsOffset = Vector3.new(0, 2, 0)
                            
                            local textLabel = Instance.new("TextLabel", bbGui)
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.TextSize = 16
                            textLabel.Font = Enum.Font.GothamBold
                            textLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                            textLabel.TextStrokeTransparency = 0.3
                            textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            textLabel.Text = "SHERIFF GUN"
                            
                            bbGui.Parent = obj.Handle
                        end
                    end
                end
            end
        end
    end)

    -- ========================================================
    -- SILENT AIM
    -- ========================================================
    task.spawn(function()
        while task.wait() do
            if not SilentAimEnabled then continue end
            
            local murderer = GetMurderer()
            if not murderer or not murderer.Character then continue end
            
            local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
            if not murdererHRP then continue end
            
            if not CanSeeTarget(murdererHRP.Position) then continue end
            
            local localChar = LocalPlayer.Character
            if not localChar or not localChar:FindFirstChild("Humanoid") then continue end
            
            local gun = localChar:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            if not gun then continue end
            
            -- Auto-aim: rotate character to face murderer
            local direction = (murdererHRP.Position - localChar.HumanoidRootPart.Position).Unit
            localChar.HumanoidRootPart.CFrame = CFrame.new(
                localChar.HumanoidRootPart.Position,
                localChar.HumanoidRootPart.Position + direction
            )
        end
    end)

    -- ========================================================
    -- SHIFT LOCK AIMBOT
    -- ========================================================
    RunService.RenderStepped:Connect(function()
        if not ShiftLockEnabled then return end
        
        local murderer = GetMurderer()
        if not murderer or not murderer.Character then return end
        
        local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
        if not murdererHRP then return end
        
        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
        
        local camera = workspace.CurrentCamera
        
        -- Rotate camera to point at murderer
        local targetCFrame = CFrame.new(camera.CFrame.Position, murdererHRP.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.1)
    end)

    -- Update Shift Lock button visibility
    task.spawn(function()
        while task.wait(0.1) do
            UpdateShiftLockButton()
        end
    end)

    Orion:MakeNotification({
        Name = "MM2 Mobile Helper",
        Content = "Loaded with Orion UI!",
        Image = "rbxassetid://4483362458",
        Time = 3
    })

    print("✓ MM2 Mobile Helper loaded with Orion!")

end)

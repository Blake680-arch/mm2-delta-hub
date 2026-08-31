-- MM2 MOBILE HELPER - FULL ESP SYSTEM
pcall(function()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()
    
    local Window = Rayfield:CreateWindow({
        Name = "MM2 Mobile Helper",
        LoadingTitle = "Loading...",
        LoadingSubtitle = "Mobile Friendly",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    -- TABS
    local VisualTab = Window:CreateTab("Visual", 4483362458)
    local AimbotTab = Window:CreateTab("Aimbot", 4483345906)
    local FarmTab = Window:CreateTab("Auto Farm", 4483362624)
    local MiscTab = Window:CreateTab("Misc", 4483362752)

    -- ========================================================
    -- VARIABLES & CONFIG
    -- ========================================================
    local LocalPlayer = game.Players.LocalPlayer
    local Active_Tags = {}
    local Active_Auras = {}

    -- ROLE COLORS
    local RoleColors = {
        Murderer = Color3.fromRGB(255, 50, 50),      -- Bright Red
        Sheriff = Color3.fromRGB(50, 150, 255),      -- Bright Blue
        Innocent = Color3.fromRGB(100, 255, 100),    -- Bright Green
        Guest = Color3.fromRGB(255, 200, 50)         -- Gold/Yellow
    }

    -- ESP Settings
    local ESPRoles = {
        Murderer = true,
        Sheriff = true,
        Innocent = false,
        Guest = false
    }

    local ShowNameTag = true
    local ShowHighlight = true
    local ShowUsernames = false

    -- ========================================================
    -- UTILITY FUNCTIONS
    -- ========================================================
    local function GetPlayerRole(player)
        if player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
            return "Murderer"
        elseif player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun")) then
            return "Sheriff"
        else
            -- Check if player is a guest (optional - you can customize this logic)
            return "Innocent"
        end
    end

    -- ========================================================
    -- ESP RENDERING
    -- ========================================================
    local function SetupPlayerESP(player)
        if player == LocalPlayer then return end
        print("[ESP] Setting up ESP for:", player.Name)
        
        local function SetupCharacter(character)
            task.wait(0.3)
            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            if not torso then return end
            
            local role = GetPlayerRole(player)
            
            -- CHECK IF ROLE SHOULD BE DISPLAYED
            if not ESPRoles[role] then return end
            
            local roleColor = RoleColors[role]
            
            -- ===== NAME TAG (Above Torso) =====
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
                
                bbGui.Parent = torso
                Active_Tags[player] = bbGui
                
                task.spawn(function()
                    while character and character:IsDescendantOf(workspace) and ShowNameTag do
                        local currentRole = GetPlayerRole(player)
                        if ESPRoles[currentRole] then
                            if ShowUsernames then
                                textLabel.Text = player.Name
                            else
                                textLabel.Text = currentRole
                            end
                            textLabel.TextColor3 = RoleColors[currentRole]
                        end
                        task.wait(0.5)
                    end
                    if Active_Tags[player] then
                        Active_Tags[player]:Destroy()
                        Active_Tags[player] = nil
                    end
                end)
            end
            
            -- ===== HIGHLIGHT AURA (No Fill, Just Outline) =====
            if ShowHighlight and not Active_Auras[player] then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.FillTransparency = 1  -- NO FILL
                    highlight.OutlineTransparency = 0.2  -- AURA ONLY
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
                        if Active_Auras[player] then
                            Active_Auras[player]:Destroy()
                            Active_Auras[player] = nil
                        end
                    end)
                end)
            end
        end
        
        if player.Character then SetupCharacter(player.Character) end
        player.CharacterAdded:Connect(SetupCharacter)
    end

    -- Initialize ESP for existing players
    for _, player in pairs(game.Players:GetPlayers()) do
        SetupPlayerESP(player)
    end

    -- Connect new players
    game.Players.PlayerAdded:Connect(SetupPlayerESP)

    -- ========================================================
    -- UI LAYOUT
    -- ========================================================
    
    VisualTab:CreateSection("ESP Target Selection")
    
    VisualTab:CreateToggle({
        Name = "ESP Murderer (Red)",
        CurrentValue = ESPRoles.Murderer,
        Callback = function(Value)
            ESPRoles.Murderer = Value
        end
    })

    VisualTab:CreateToggle({
        Name = "ESP Sheriff (Blue)",
        CurrentValue = ESPRoles.Sheriff,
        Callback = function(Value)
            ESPRoles.Sheriff = Value
        end
    })

    VisualTab:CreateToggle({
        Name = "ESP Innocent (Green)",
        CurrentValue = ESPRoles.Innocent,
        Callback = function(Value)
            ESPRoles.Innocent = Value
        end
    })

    VisualTab:CreateToggle({
        Name = "ESP Guest (Gold)",
        CurrentValue = ESPRoles.Guest,
        Callback = function(Value)
            ESPRoles.Guest = Value
        end
    })

    VisualTab:CreateSection("ESP Display Options")

    VisualTab:CreateToggle({
        Name = "Show Role Nametag",
        CurrentValue = ShowNameTag,
        Callback = function(Value)
            ShowNameTag = Value
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Highlight Aura",
        CurrentValue = ShowHighlight,
        Callback = function(Value)
            ShowHighlight = Value
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Usernames Only",
        CurrentValue = ShowUsernames,
        Callback = function(Value)
            ShowUsernames = Value
        end
    })

    -- AIMBOT TAB
    AimbotTab:CreateSection("Aimbot Settings")

    local AimbotEnabled = false
    AimbotTab:CreateToggle({
        Name = "Enable Aimbot",
        CurrentValue = AimbotEnabled,
        Callback = function(Value)
            AimbotEnabled = Value
        end
    })

    -- AUTO FARM TAB
    FarmTab:CreateSection("Farm Settings")

    local AutoFarmEnabled = false
    FarmTab:CreateToggle({
        Name = "Enable Auto Farm",
        CurrentValue = AutoFarmEnabled,
        Callback = function(Value)
            AutoFarmEnabled = Value
        end
    })

    -- MISC TAB
    MiscTab:CreateSection("Utilities")

    MiscTab:CreateButton({
        Name = "Close GUI",
        Callback = function()
            Window:Close()
        end
    })

    -- NOTIFICATION
    Rayfield:Notify({
        Title = "MM2 Mobile Helper",
        Content = "ESP Ready! Murderer & Sheriff enabled",
        Duration = 3,
    })

    print("✓ MM2 Mobile Helper fully loaded with ESP!")

end)

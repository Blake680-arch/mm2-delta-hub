-- MM2 UNIVERSAL PROTECTOR HUB - COMPLETE LOADSTRING
-- Paste this entire code into Delta Executor

pcall(function()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

    local Window = Rayfield:CreateWindow({
       Name = "MM2 Universal Protector Hub",
       LoadingTitle = "Loading Secure Hub...",
       LoadingSubtitle = "By A Helpful Dev",
       ConfigurationSaving = { Enabled = false },
       KeySystem = false
    })

    -- ========================================================
    -- CREATE TABS
    -- ========================================================
    local ESPTab = Window:CreateTab("Visual ESPs", 4483362458)
    local CombatTab = Window:CreateTab("Combat / Aim", 4483345906)
    local MiscTab = Window:CreateTab("Misc Utilities", 4483362752)

    -- ========================================================
    -- SYSTEM VARIABLES
    -- ========================================================
    local LocalPlayer = game.Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local ESP_Tags_Enabled = true   
    local ESP_Aura_Enabled = true   
    local Gun_ESP_Enabled = true    
    local Active_Tags = {}
    local Active_Auras = {}
    local Gun_Tag = nil

    local Sheriff_SilentAim = false
    local Sheriff_ShiftLock = false
    local Sheriff_AutoPickUpGun = false

    local Murd_ShiftLock = false
    local Safe_Return_CFrame = nil

    -- ========================================================
    -- UTILITY FUNCTIONS
    -- ========================================================
    local function GetPlayerRole(player)
        if player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
            return "Murderer", Color3.fromRGB(255, 0, 0)
        elseif player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun")) then
            return "Sheriff", Color3.fromRGB(0, 150, 255)
        else
            return "Innocent", Color3.fromRGB(0, 255, 100)
        end
    end

    local function GetMurdererRoot()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                    return p.Character.HumanoidRootPart
                end
            end
        end
        return nil
    end

    local function GetClosestVictimRoot()
        local closestPart = nil
        local shortestDistance = math.huge
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Backpack:FindFirstChild("Knife") and not p.Character:FindFirstChild("Knife") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPart = p.Character.HumanoidRootPart
                        end
                    end
                end
            end
        end
        return closestPart
    end

    local function GetAllLivingTargets()
        local targets = {}
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    table.insert(targets, p.Character.HumanoidRootPart)
                end
            end
        end
        return targets
    end

    -- ========================================================
    -- ESP ENGINE
    -- ========================================================
    local function ManagePlayerESP(player)
        if player == LocalPlayer then return end
        
        local function SetupCharacter(character)
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if not hrp then return end
            
            -- Text Tags
            if ESP_Tags_Enabled and not Active_Tags[player] then
                local bbGui = Instance.new("BillboardGui")
                bbGui.Size = UDim2.new(0, 200, 0, 50)
                bbGui.Adornee = hrp
                bbGui.AlwaysOnTop = true
                bbGui.StudsOffset = Vector3.new(0, 3, 0)
                
                local textLabel = Instance.new("TextLabel", bbGui)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextSize = 14
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextStrokeTransparency = 0
                
                bbGui.Parent = hrp
                Active_Tags[player] = bbGui
                
                task.spawn(function()
                    while character:IsDescendantOf(workspace) and ESP_Tags_Enabled do
                        local roleName, roleColor = GetPlayerRole(player)
                        textLabel.Text = player.Name .. " [" .. roleName .. "]"
                        textLabel.TextColor3 = roleColor
                        task.wait(1)
                    end
                end)
            end
            
            -- Aura Highlights
            if ESP_Aura_Enabled and not Active_Auras[player] then
                local highlight = Instance.new("Highlight")
                highlight.FillTransparency = 0.6
                highlight.OutlineTransparency = 0.2
                highlight.Parent = character
                Active_Auras[player] = highlight
                
                task.spawn(function()
                    while character:IsDescendantOf(workspace) and ESP_Aura_Enabled do
                        local _, roleColor = GetPlayerRole(player)
                        highlight.FillColor = roleColor
                        highlight.OutlineColor = roleColor
                        task.wait(1.5)
                    end
                end)
            end
        end
        
        if player.Character then SetupCharacter(player.Character) end
        player.CharacterAdded:Connect(SetupCharacter)
    end

    -- Gun Tracker
    local function TrackDroppedGun()
        task.spawn(function()
            while task.wait(2) do
                if not Gun_ESP_Enabled then 
                    if Gun_Tag then Gun_Tag:Destroy() Gun_Tag = nil end
                    continue 
                end
                local gunDrop = workspace:FindFirstChild("GunDrop")
                if gunDrop and not Gun_Tag then
                    local bbGui = Instance.new("BillboardGui")
                    bbGui.Size = UDim2.new(0, 150, 0, 50)
                    bbGui.Adornee = gunDrop
                    bbGui.AlwaysOnTop = true
                    bbGui.StudsOffset = Vector3.new(0, 2, 0)
                    
                    local textLabel = Instance.new("TextLabel", bbGui)
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextSize = 16
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.Text = "⭐ SHERIFF GUN ⭐"
                    
                    bbGui.Parent = gunDrop
                    Gun_Tag = bbGui
                elseif not gunDrop and Gun_Tag then
                    Gun_Tag:Destroy()
                    Gun_Tag = nil
                end
            end
        end)
    end

    -- Initialize ESP
    for _, player in pairs(game.Players:GetPlayers()) do ManagePlayerESP(player) end
    game.Players.PlayerAdded:Connect(ManagePlayerESP)
    TrackDroppedGun()

    -- ========================================================
    -- COMBAT ENGINE
    -- ========================================================
    game:GetService("RunService").RenderStepped:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local myHrp = LocalPlayer.Character.HumanoidRootPart
        local isShiftPressed = game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift)
        
        -- Sheriff Lock
        local murderer = GetMurdererRoot()
        if murderer and Sheriff_ShiftLock and isShiftPressed then
            myHrp.CFrame = CFrame.new(myHrp.Position, Vector3.new(murderer.Position.X, myHrp.Position.Y, murderer.Position.Z))
        end
        
        -- Murderer Lock
        local victim = GetClosestVictimRoot()
        if victim and Murd_ShiftLock and isShiftPressed then
            myHrp.CFrame = CFrame.new(myHrp.Position, Vector3.new(victim.Position.X, myHrp.Position.Y, victim.Position.Z))
        end
    end)

    -- Auto Gun Pickup
    task.spawn(function()
        while task.wait(0.2) do
            if Sheriff_AutoPickUpGun and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local gunDrop = workspace:FindFirstChild("GunDrop")
                if gunDrop and gunDrop:FindFirstChild("Handle") then
                    local oldCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                    LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.Handle.CFrame
                    task.wait(0.1)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = oldCFrame
                end
            end
        end
    end)

    -- ========================================================
    -- ESP TAB UI
    -- ========================================================
    ESPTab:CreateToggle({
        Name = "Enable Name Tags",
        CurrentValue = ESP_Tags_Enabled,
        Callback = function(Value)
            ESP_Tags_Enabled = Value
        end
    })

    ESPTab:CreateToggle({
        Name = "Enable Aura Glow",
        CurrentValue = ESP_Aura_Enabled,
        Callback = function(Value)
            ESP_Aura_Enabled = Value
        end
    })

    ESPTab:CreateToggle({
        Name = "Enable Gun Tracker",
        CurrentValue = Gun_ESP_Enabled,
        Callback = function(Value)
            Gun_ESP_Enabled = Value
        end
    })

    -- ========================================================
    -- COMBAT TAB UI
    -- ========================================================
    CombatTab:CreateSection("Sheriff Features")

    CombatTab:CreateToggle({
        Name = "Shift Lock on Murderer",
        CurrentValue = Sheriff_ShiftLock,
        Callback = function(Value)
            Sheriff_ShiftLock = Value
        end
    })

    CombatTab:CreateToggle({
        Name = "Auto Pick Up Gun",
        CurrentValue = Sheriff_AutoPickUpGun,
        Callback = function(Value)
            Sheriff_AutoPickUpGun = Value
        end
    })

    CombatTab:CreateSection("Murderer Features")

    CombatTab:CreateToggle({
        Name = "Shift Lock on Victim",
        CurrentValue = Murd_ShiftLock,
        Callback = function(Value)
            Murd_ShiftLock = Value
        end
    })

    -- ========================================================
    -- MISC TAB UI
    -- ========================================================
    MiscTab:CreateSection("Information")

    MiscTab:CreateLabel("MM2 Universal Hub v1.0")
    MiscTab:CreateLabel("Designed for MM2 & Delta")

    MiscTab:CreateButton({
        Name = "Close GUI",
        Callback = function()
            Window:Close()
        end
    })

    -- ========================================================
    -- NOTIFICATION
    -- ========================================================
    Rayfield:Notify({
        Title = "MM2 Hub Loaded",
        Content = "Universal Protector Hub is ready!",
        Duration = 3,
        Image = 4483362458,
    })

    print("✓ MM2 Universal Hub loaded successfully!")
end)

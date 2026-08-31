-- MM2 MOBILE HELPER - PURE ROBLOX UI (MOVABLE + COLLAPSIBLE)
pcall(function()
    local LocalPlayer = game.Players.LocalPlayer
    local Active_Tags = {}
    local Active_Auras = {}
    local Gun_Tag = nil
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    -- ROLE COLORS
    local RoleColors = {
        Murderer = Color3.fromRGB(255, 50, 50),
        Sheriff = Color3.fromRGB(50, 150, 255),
        Innocent = Color3.fromRGB(100, 255, 100),
        Hero = Color3.fromRGB(255, 255, 0),
        Guest = Color3.fromRGB(255, 200, 50)
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

    print("[MM2] Starting with movable UI...")

    -- ========================================================
    -- UTILITY FUNCTIONS
    -- ========================================================
    local function GetPlayerRole(player)
        if not player or not player.Character then return "Guest" end
        
        if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
            return "Murderer"
        end
        
        if player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then
            if player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if not (player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")) then
                    return "Hero"
                end
                return "Sheriff"
            end
        end
        
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
    -- CREATE GUI
    -- ========================================================
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2Hub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame (Movable)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 20, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Parent = screenGui

    -- Dragging Setup
    local dragging = false
    local dragStart = nil
    local dragPos = nil

    mainFrame.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            dragPos = mainFrame.Position
        end
    end)

    mainFrame.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
            dragPos = mainFrame.Position
        end
    end)

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -35, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "MM2 Mobile Helper"
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Collapse/Expand Button
    local collapseBtn = Instance.new("TextButton")
    collapseBtn.Name = "CollapseBtn"
    collapseBtn.Size = UDim2.new(0, 35, 1, 0)
    collapseBtn.Position = UDim2.new(1, -35, 0, 0)
    collapseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    collapseBtn.BorderSizePixel = 0
    collapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    collapseBtn.TextSize = 14
    collapseBtn.Font = Enum.Font.GothamBold
    collapseBtn.Text = "-"
    collapseBtn.Parent = titleBar

    local isCollapsed = false

    collapseBtn.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        if isCollapsed then
            mainFrame.Size = UDim2.new(0, 300, 0, 35)
            collapseBtn.Text = "+"
        else
            mainFrame.Size = UDim2.new(0, 300, 0, 400)
            collapseBtn.Text = "-"
        end
    end)

    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, -35)
    scrollFrame.Position = UDim2.new(0, 0, 0, 35)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 700)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    scrollFrame.Parent = mainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = scrollFrame

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingRight = UDim.new(0, 5)
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.Parent = scrollFrame

    -- ========================================================
    -- TAB SYSTEM
    -- ========================================================
    local currentTab = "Visual"
    local tabContainers = {}

    local function CreateTab(tabName)
        local tabContainer = Instance.new("Frame")
        tabContainer.Name = tabName .. "Tab"
        tabContainer.Size = UDim2.new(1, -10, 0, 0)
        tabContainer.BackgroundTransparency = 1
        tabContainer.BorderSizePixel = 0
        tabContainer.Visible = (tabName == "Visual")
        tabContainer.Parent = scrollFrame

        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Padding = UDim.new(0, 5)
        tabLayout.Parent = tabContainer

        tabContainers[tabName] = tabContainer
        return tabContainer
    end

    -- Tab Buttons
    local tabButtonsFrame = Instance.new("Frame")
    tabButtonsFrame.Size = UDim2.new(1, -10, 0, 30)
    tabButtonsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    tabButtonsFrame.BorderSizePixel = 1
    tabButtonsFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    tabButtonsFrame.Parent = scrollFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = tabButtonsFrame

    local function CreateTabButton(tabName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 95, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = tabName
        btn.Parent = tabButtonsFrame

        btn.MouseButton1Click:Connect(function()
            for _, tab in pairs(tabContainers) do
                tab.Visible = false
            end
            tabContainers[tabName].Visible = true
            currentTab = tabName
        end)

        if tabName == "Visual" then
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)

        btn.MouseLeave:Connect(function()
            if currentTab == tabName then
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            else
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end)
    end

    CreateTabButton("Visual")
    CreateTabButton("Aimbot")
    CreateTabButton("Misc")

    local VisualTab = CreateTab("Visual")
    local AimbotTab = CreateTab("Aimbot")
    local MiscTab = CreateTab("Misc")

    -- ========================================================
    -- TOGGLE BUTTON CREATOR
    -- ========================================================
    local function CreateToggle(parent, name, defaultValue, callback)
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = name
        toggleBtn.Size = UDim2.new(1, 0, 0, 30)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.TextSize = 12
        toggleBtn.Font = Enum.Font.Gotham
        toggleBtn.BorderSizePixel = 1
        toggleBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
        toggleBtn.Parent = parent

        local isEnabled = defaultValue
        
        local function UpdateButton()
            toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
            toggleBtn.Text = (isEnabled and "✓ " or "✗ ") .. name
            callback(isEnabled)
        end

        toggleBtn.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            UpdateButton()
        end)

        toggleBtn.MouseEnter:Connect(function()
            toggleBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
        end)

        toggleBtn.MouseLeave:Connect(function()
            toggleBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
        end)

        UpdateButton()
    end

    -- ========================================================
    -- SECTION HEADERS
    -- ========================================================
    local function CreateHeader(parent, text)
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 25)
        header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        header.TextColor3 = Color3.fromRGB(255, 255, 255)
        header.TextSize = 13
        header.Font = Enum.Font.GothamBold
        header.Text = "[ " .. text .. " ]"
        header.BorderSizePixel = 1
        header.BorderColor3 = Color3.fromRGB(255, 255, 255)
        header.Parent = parent
    end

    -- ========================================================
    -- POPULATE TABS
    -- ========================================================

    -- VISUAL TAB
    CreateHeader(VisualTab, "ESP Target Selection")
    CreateToggle(VisualTab, "ESP Murderer", ESPRoles.Murderer, function(val) ESPRoles.Murderer = val end)
    CreateToggle(VisualTab, "ESP Sheriff", ESPRoles.Sheriff, function(val) ESPRoles.Sheriff = val end)
    CreateToggle(VisualTab, "ESP Innocent", ESPRoles.Innocent, function(val) ESPRoles.Innocent = val end)
    CreateToggle(VisualTab, "ESP Hero", ESPRoles.Hero, function(val) ESPRoles.Hero = val end)

    CreateHeader(VisualTab, "Display Options")
    CreateToggle(VisualTab, "Show Nametags", ShowNameTag, function(val) ShowNameTag = val end)
    CreateToggle(VisualTab, "Show Highlights", ShowHighlight, function(val) ShowHighlight = val end)
    CreateToggle(VisualTab, "Show Gun ESP", ShowGunESP, function(val) ShowGunESP = val end)

    -- AIMBOT TAB
    CreateHeader(AimbotTab, "Silent Aim")
    CreateToggle(AimbotTab, "Silent Aim", SilentAimEnabled, function(val) SilentAimEnabled = val end)

    CreateHeader(AimbotTab, "Shift Lock")
    CreateToggle(AimbotTab, "Shift Lock", ShiftLockEnabled, function(val) ShiftLockEnabled = val end)

    -- MISC TAB
    CreateHeader(MiscTab, "Utilities")
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(1, 0, 0, 30)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Text = "Close GUI"
    closeBtn.Parent = MiscTab

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    closeBtn.MouseEnter:Connect(function()
        closeBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    end)

    closeBtn.MouseLeave:Connect(function()
        closeBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
    end)

    print("[MM2] GUI Created successfully!")

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
    -- GUN ESP
    -- ========================================================
    task.spawn(function()
        while task.wait(1) do
            if not ShowGunESP then continue end
            
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:lower():find("gun") then
                    if obj:FindFirstChild("Handle") and not obj:FindFirstChild("GunESPTag") then
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
        local targetCFrame = CFrame.new(camera.CFrame.Position, murdererHRP.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.1)
    end)

    print("✓ MM2 Mobile Helper loaded successfully!")

end)

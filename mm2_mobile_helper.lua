-- MM2 MOBILE HELPER - PURE ROBLOX UI (NO RAYFIELD)
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
        Guest = Color3.fromRGB(255, 200, 50)
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
    local ShowGunESP = true

    -- AIMBOT Settings
    local SilentAimEnabled = false
    local ShiftLockEnabled = false

    print("[MM2] Starting setup...")

    -- ========================================================
    -- UTILITY FUNCTIONS
    -- ========================================================
    local function GetPlayerRole(player)
        if player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
            return "Murderer"
        elseif player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun")) then
            return "Sheriff"
        else
            return "Innocent"
        end
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
                return hitCharacter == GetMurderer().Character
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

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 20, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainFrame.Parent = screenGui

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "MM2 Mobile Helper"
    titleLabel.BorderSizePixel = 0
    titleLabel.Parent = mainFrame

    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -30)
    scrollFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = mainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = scrollFrame

    -- ========================================================
    -- TOGGLE BUTTON CREATOR
    -- ========================================================
    local function CreateToggle(parent, name, defaultValue, callback)
        local toggleFrame = Instance.new("TextButton")
        toggleFrame.Name = name
        toggleFrame.Size = UDim2.new(1, -10, 0, 30)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleFrame.TextSize = 12
        toggleFrame.Font = Enum.Font.Gotham
        toggleFrame.BorderSizePixel = 1
        toggleFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
        toggleFrame.Parent = parent

        local isEnabled = defaultValue
        
        local function UpdateButton()
            toggleFrame.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(150, 0, 0)
            toggleFrame.Text = (isEnabled and "✓ " or "✗ ") .. name
            callback(isEnabled)
        end

        toggleFrame.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            UpdateButton()
        end)

        UpdateButton()
    end

    -- ========================================================
    -- CREATE UI SECTIONS
    -- ========================================================

    -- ESP Section Header
    local espHeader = Instance.new("TextLabel")
    espHeader.Name = "ESPHeader"
    espHeader.Size = UDim2.new(1, -10, 0, 25)
    espHeader.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    espHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    espHeader.TextSize = 14
    espHeader.Font = Enum.Font.GothamBold
    espHeader.Text = "[ ESP Settings ]"
    espHeader.BorderSizePixel = 0
    espHeader.Parent = scrollFrame

    -- ESP Toggles
    CreateToggle(scrollFrame, "ESP Murderer", ESPRoles.Murderer, function(val)
        ESPRoles.Murderer = val
    end)

    CreateToggle(scrollFrame, "ESP Sheriff", ESPRoles.Sheriff, function(val)
        ESPRoles.Sheriff = val
    end)

    CreateToggle(scrollFrame, "ESP Innocent", ESPRoles.Innocent, function(val)
        ESPRoles.Innocent = val
    end)

    CreateToggle(scrollFrame, "Show Nametags", ShowNameTag, function(val)
        ShowNameTag = val
    end)

    CreateToggle(scrollFrame, "Show Highlights", ShowHighlight, function(val)
        ShowHighlight = val
    end)

    CreateToggle(scrollFrame, "Show Gun ESP", ShowGunESP, function(val)
        ShowGunESP = val
    end)

    -- Aimbot Section Header
    local aimbotHeader = Instance.new("TextLabel")
    aimbotHeader.Name = "AimbotHeader"
    aimbotHeader.Size = UDim2.new(1, -10, 0, 25)
    aimbotHeader.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    aimbotHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotHeader.TextSize = 14
    aimbotHeader.Font = Enum.Font.GothamBold
    aimbotHeader.Text = "[ Aimbot Settings ]"
    aimbotHeader.BorderSizePixel = 0
    aimbotHeader.Parent = scrollFrame

    -- Aimbot Toggles
    CreateToggle(scrollFrame, "Silent Aim", SilentAimEnabled, function(val)
        SilentAimEnabled = val
    end)

    CreateToggle(scrollFrame, "Shift Lock", ShiftLockEnabled, function(val)
        ShiftLockEnabled = val
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
            if not ShowGunESP then 
                if Gun_Tag then Gun_Tag:Destroy() Gun_Tag = nil end
                continue 
            end
            
            local gunDrop = workspace:FindFirstChild("GunDrop")
            if gunDrop and gunDrop:FindFirstChild("Handle") and not Gun_Tag then
                local bbGui = Instance.new("BillboardGui")
                bbGui.Size = UDim2.new(0, 150, 0, 50)
                bbGui.Adornee = gunDrop
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
                
                bbGui.Parent = gunDrop
                Gun_Tag = bbGui
                
            elseif not gunDrop and Gun_Tag then
                pcall(function() Gun_Tag:Destroy() end)
                Gun_Tag = nil
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
        
        local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        if not isShiftPressed then return end
        
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
    print("✓ UI Created - Check top left corner")

end)

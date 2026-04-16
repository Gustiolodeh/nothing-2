--[[
    Nama Skrip: Script Universal Tools By Olodeh 2026 (Updated with Floatwalk)
    Kredit: Created By Gusti with Love (@gustiolodeh)
    Deskripsi: Skrip alat universal untuk Roblox Mobile dengan fitur GUI Efisien.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- == VARIBEL DASAR ==
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- == VARIBEL KONFIGURASI UI ==
local UI_SIZE = UDim2.new(0, 250, 0, 350)
local UI_TITLE = "Script Universal Tools By Olodeh 2026"
local FOLLOW_PLAYER_DISTANCE = 5

-- == FUNGSI BANTUAN ==
local function createButton(name, text, layoutOrder, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(45, 120, 180)
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.SourceSansBold
    button.LayoutOrder = layoutOrder
    button.Parent = parent

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(30, 80, 120)
    uiStroke.Parent = button

    return button
end

local function isPlayerPart(part)
    if not part then return false end
    if part:IsDescendantOf(Character) then return true end
    if part:IsDescendantOf(Player:FindFirstChildOfClass("Backpack")) then return true end
    return false
end

local function findPlayerFromPart(part)
    local currentPart = part
    while currentPart do
        local player = Players:GetPlayerFromCharacter(currentPart)
        if player then
            return player, currentPart
        end
        currentPart = currentPart.Parent
    end
    return nil, nil
end

local function splitString(inputString, separator)
    local result = {}
    for part in string.gmatch(inputString, "[^"..separator.."]+") do
        table.insert(result, part)
    end
    return result
end

-- == UI UTAMA ==
local MainGui = Instance.new("ScreenGui")
MainGui.Name = UI_TITLE
MainGui.ResetOnSpawn = false
MainGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UI_SIZE
MainFrame.Position = UDim2.new(0.5, -UI_SIZE.X.Offset / 2, 0.5, -UI_SIZE.Y.Offset / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MainFrame or MainGui

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.Text = "Olodeh 2026 | @gustiolodeh"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local ButtonsLayout = Instance.new("UIListLayout")
ButtonsLayout.Padding = UDim.new(0, 5)
ButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonsLayout.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.LayoutOrder = 1
CloseButton.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.LayoutOrder = 2
MinimizeButton.Parent = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 30)
StatusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.Parent = MainFrame

local FeaturesScrollingFrame = Instance.new("ScrollingFrame")
FeaturesScrollingFrame.Name = "FeaturesScrollingFrame"
FeaturesScrollingFrame.Size = UDim2.new(1, 0, 1, -60)
FeaturesScrollingFrame.Position = UDim2.new(0, 0, 0, 60)
FeaturesScrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FeaturesScrollingFrame.BackgroundTransparency = 1
FeaturesScrollingFrame.BorderSizePixel = 0
FeaturesScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
FeaturesScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = FeaturesScrollingFrame

-- FUNGSI UNTUK STATUS SEMENTARA
local function showTempStatus(message)
    local originalText = StatusLabel.Text
    StatusLabel.Text = message
    task.delay(2, function()
        StatusLabel.Text = originalText
    end)
end

-- == FITUR BARU: DESTROY TOOL ITEM ==
local function giveDestroyTool()
    local backpack = Player:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    
    if backpack:FindFirstChild("Destroy Tool") or (Character and Character:FindFirstChild("Destroy Tool")) then
        showTempStatus("Destroy Tool already in inventory!")
        return
    end

    local tool = Instance.new("Tool")
    tool.Name = "Destroy Tool"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    
    tool.Activated:Connect(function()
        local target = Mouse.Target
        if target then
            if not isPlayerPart(target) and not target:IsDescendantOf(MainGui) and target ~= Workspace.Terrain then
                local success, _ = pcall(function() target:Destroy() end)
                if success then
                    showTempStatus("Destroyed: " .. target.Name)
                else
                    showTempStatus("Cannot destroy this!")
                end
            else
                showTempStatus("Invalid Target!")
            end
        end
    end)
    
    tool.Parent = backpack
    showTempStatus("Destroy Tool Added!")
end

-- == BUTTONS ==
local TeleportButton = createButton("TeleportButton", "Teleport: OFF", 1, FeaturesScrollingFrame)
local TapTPToolButton = createButton("TapTPToolButton", "Get Tap TP Tool", 2, FeaturesScrollingFrame)
local DestroyToolButton = createButton("DestroyToolButton", "Get Destroy Tool", 3, FeaturesScrollingFrame)
local FloatwalkButton = createButton("FloatwalkButton", "Floatwalk: OFF", 4, FeaturesScrollingFrame) -- FITUR BARU
local DestroyButton = createButton("DestroyButton", "Destroy: OFF", 5, FeaturesScrollingFrame)
local ShowNameButton = createButton("ShowNameButton", "Show Name: OFF", 6, FeaturesScrollingFrame)
local PartRemoverButton = createButton("PartRemoverButton", "Part Remover: OFF", 7, FeaturesScrollingFrame)
local TagPlayerButton = createButton("TagPlayerButton", "Tag Player: OFF", 8, FeaturesScrollingFrame)
local LightToggleButton = createButton("LightToggleButton", "Light Toggle: OFF", 9, FeaturesScrollingFrame)
local PlayerInfoButton = createButton("PlayerInfoButton", "Player Info: OFF", 10, FeaturesScrollingFrame)
local BulkRemoveButton = createButton("BulkRemoveButton", "Remove Object: OFF", 11, FeaturesScrollingFrame)
local EditObjectButton = createButton("EditObjectButton", "Edit Object: OFF", 12, FeaturesScrollingFrame)
local SizeEditAdvanceButton = createButton("SizeEditAdvanceButton", "Size Edit Advance: OFF", 13, FeaturesScrollingFrame)
local ShowNameAdvanceButton = createButton("ShowNameAdvanceButton", "Show Name Advance: OFF", 14, FeaturesScrollingFrame)
local PlayerListButton = createButton("PlayerListButton", "Player List", 15, FeaturesScrollingFrame)
local PlayerConfigButton = createButton("PlayerConfigButton", "Player Config", 16, FeaturesScrollingFrame)
local VisualConfigButton = createButton("VisualConfigButton", "Visual Config", 17, FeaturesScrollingFrame)
local TeleportPointsButton = createButton("TeleportPointsButton", "Teleport Points", 18, FeaturesScrollingFrame)
local ObjectSearchButton = createButton("ObjectSearchButton", "Object Search", 19, FeaturesScrollingFrame)
local TeleportCoordsButton = createButton("TeleportCoordsButton", "Teleport to Coords", 20, FeaturesScrollingFrame)
local TriggerFinderButton = createButton("TriggerFinderButton", "Auto Trigger Finder", 21, FeaturesScrollingFrame)
local ProximityManagerButton = createButton("ProximityManagerButton", "Proximity Tools", 22, FeaturesScrollingFrame)

local exclusiveButtons = {
    Teleport = TeleportButton,
    Destroy = DestroyButton,
    ShowName = ShowNameButton,
    PartRemover = PartRemoverButton,
    TagPlayer = TagPlayerButton,
    LightToggle = LightToggleButton,
    PlayerInfo = PlayerInfoButton,
    BulkRemove = BulkRemoveButton,
    EditObject = EditObjectButton,
    SizeEditAdvance = SizeEditAdvanceButton,
    ShowNameAdvance = ShowNameAdvanceButton,
}

-- == LOGIKA SKRIP ==
local exclusiveFeatureOn = nil
local simultaneousFeatures = {
    InfiniteJump = false,
    Godmode = false,
    NoClip = false,
    Sleeping = false,
    FastProximity = false,
    Floatwalk = false, -- Fitur Baru
}

local visualStates = {
    Fullbright = false,
    ESP = false,
    NoFog = false,
    DangerESP = false,
    ReduceTexture = false
}

local ToggleTpwalk = false
local TpwalkValue = 1
local TpwalkConnection = nil

local removedParts = {}
local taggedPlayers = {}
local followingPlayer = nil
local walkToConnection = nil
local teleportModeOn = false
local originalJumpPower = Humanoid.JumpPower

-- == LOGIKA FLOATWALK ==
local floatPart = nil
local floatConnection = nil

local function toggleFloatwalk()
    simultaneousFeatures.Floatwalk = not simultaneousFeatures.Floatwalk
    FloatwalkButton.Text = "Floatwalk: " .. (simultaneousFeatures.Floatwalk and "ON" or "OFF")
    FloatwalkButton.BackgroundColor3 = simultaneousFeatures.Floatwalk and Color3.fromRGB(70, 180, 70) or Color3.fromRGB(45, 120, 180)
    
    if simultaneousFeatures.Floatwalk then
        if not floatPart then
            floatPart = Instance.new("Part")
            floatPart.Name = "OlodehFloatPart"
            floatPart.Transparency = 1
            floatPart.Size = Vector3.new(5, 0.5, 5)
            floatPart.Anchored = true
            floatPart.CanCollide = true
            floatPart.Parent = Workspace
        end
        
        floatConnection = RunService.RenderStepped:Connect(function()
            if Character and RootPart and floatPart then
                floatPart.CFrame = CFrame.new(RootPart.Position.X, floatPart.Position.Y, RootPart.Position.Z)
                -- Jika melompat, naikkan platform
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    floatPart.CFrame = CFrame.new(RootPart.Position.X, RootPart.Position.Y - 3.5, RootPart.Position.Z)
                end
            end
        end)
        
        -- Inisialisasi posisi awal di bawah kaki
        if RootPart then
            floatPart.Position = RootPart.Position - Vector3.new(0, 3.5, 0)
        end
        showTempStatus("Floatwalk Activated")
    else
        if floatConnection then floatConnection:Disconnect() end
        if floatPart then floatPart:Destroy(); floatPart = nil end
        showTempStatus("Floatwalk Deactivated")
    end
    updateStatusLabel()
end

FloatwalkButton.MouseButton1Click:Connect(toggleFloatwalk)

-- == LOGIKA TAP TP TOOL ==
local function giveTapTPTool()
    local backpack = Player:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    
    if backpack:FindFirstChild("Tap TP Tool") or (Character and Character:FindFirstChild("Tap TP Tool")) then
        showTempStatus("Tool already in inventory!")
        return
    end

    local tool = Instance.new("Tool")
    tool.Name = "Tap TP Tool"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    
    tool.Activated:Connect(function()
        if Mouse.Target and RootPart then
            local targetPos = Mouse.Hit.p
            RootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
            showTempStatus("Tool TP Success!")
        end
    end)
    
    tool.Parent = backpack
    showTempStatus("Tap TP Tool Added!")
end

TapTPToolButton.MouseButton1Click:Connect(giveTapTPTool)
DestroyToolButton.MouseButton1Click:Connect(giveDestroyTool)

-- PERBAIKAN STOP FOLLOW
local function stopFollowing()
    followingPlayer = nil
    if walkToConnection then
        walkToConnection:Disconnect()
        walkToConnection = nil
    end
    if Humanoid then 
        Humanoid:MoveTo(RootPart.Position) 
    end
    -- Update UI
    local plStopFollowButton = MainGui:FindFirstChild("StopFollowButton", true)
    if plStopFollowButton then plStopFollowButton.Visible = false end
    
    showTempStatus("Following Stopped.")
end

local function stopWalkTo()
    if walkToConnection then
        walkToConnection:Disconnect()
        walkToConnection = nil
    end
    if Humanoid then Humanoid:MoveTo(RootPart.Position) end
end

local function updateStatusLabel()
    local activeModes = {}
    if teleportModeOn then table.insert(activeModes, "Tap to Teleport") end
    
    if exclusiveFeatureOn and exclusiveFeatureOn ~= "Teleport" then
        local displayName = exclusiveFeatureOn
        if displayName == "EditObject" then displayName = "Edit Object (Proportional)" end
        if displayName == "SizeEditAdvance" then displayName = "Size Edit Advance (Per Part)" end
        if displayName == "ShowNameAdvance" then displayName = "Show Name Advance" end
        table.insert(activeModes, displayName)
    end
    if followingPlayer then table.insert(activeModes, "Following " .. followingPlayer.Name) end
    if walkToConnection then table.insert(activeModes, "Walking to Player") end
    if ToggleTpwalk then table.insert(activeModes, "TP Walk") end

    for name, state in pairs(simultaneousFeatures) do
        if state then
            local displayName = name
            if displayName == "InfiniteJump" then displayName = "Infinite Jump" end
            if displayName == "Godmode" then displayName = "God Mode" end
            if displayName == "NoClip" then displayName = "NoClip" end
            if displayName == "Sleeping" then displayName = "Turu" end
            if displayName == "FastProximity" then displayName = "Fast Proximity" end
            if displayName == "Floatwalk" then displayName = "Floatwalk" end
            table.insert(activeModes, displayName)
        end
    end

    if #activeModes > 0 then
        StatusLabel.Text = "Mode: " .. table.concat(activeModes, ", ") .. " ON"
    else
        StatusLabel.Text = "Status: Idle"
    end
end

local function setExclusiveFeature(featureName)
    if teleportModeOn and featureName ~= "Teleport" then
        TeleportButton.Text = "Teleport: OFF"
        teleportModeOn = false
    end
    if exclusiveFeatureOn == featureName then
        exclusiveFeatureOn = nil
        if exclusiveButtons[featureName] then exclusiveButtons[featureName].Text = featureName .. ": OFF" end
    else
        if exclusiveFeatureOn then
            if exclusiveButtons[exclusiveFeatureOn] then exclusiveButtons[exclusiveFeatureOn].Text = exclusiveFeatureOn .. ": OFF" end
        end
        exclusiveFeatureOn = featureName
        if exclusiveButtons[featureName] then exclusiveButtons[featureName].Text = featureName .. ": ON" end
    end
    stopFollowing()
    stopWalkTo()
    updateStatusLabel()
end

local function updateCanvasSize()
    local buttonCount = #FeaturesScrollingFrame:GetChildren()
    local contentHeight = (40 + UIListLayout.Padding.Offset) * buttonCount
    FeaturesScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end

-- GUI EDIT OBJEK (Dinamic)
local editGui = Instance.new("Frame")
editGui.Name = "EditGui"
editGui.Size = UDim2.new(0, 200, 0, 150)
editGui.Position = UDim2.new(0.5, -100, 0.5, -75)
editGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
editGui.Active = true
editGui.Draggable = true
editGui.Visible = false
editGui.Parent = MainGui

local editTitleLabel = Instance.new("TextLabel")
editTitleLabel.Size = UDim2.new(1, 0, 0, 30)
editTitleLabel.Text = "Edit Object"
editTitleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
editTitleLabel.TextColor3 = Color3.new(1, 1, 1)
editTitleLabel.Font = Enum.Font.SourceSansBold
editTitleLabel.Parent = editGui

local scaleLabel = Instance.new("TextLabel")
scaleLabel.Name = "ScaleLabel"
scaleLabel.Size = UDim2.new(1, -20, 0, 20)
scaleLabel.Position = UDim2.new(0, 10, 0, 40)
scaleLabel.Text = "Scale Factor:"
scaleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scaleLabel.TextColor3 = Color3.new(1, 1, 1)
scaleLabel.TextXAlignment = Enum.TextXAlignment.Left
scaleLabel.Parent = editGui
scaleLabel.Visible = false

local scaleTextBox = Instance.new("TextBox")
scaleTextBox.Name = "ScaleTextBox"
scaleTextBox.Size = UDim2.new(1, -20, 0, 30)
scaleTextBox.Position = UDim2.new(0, 10, 0, 60)
scaleTextBox.PlaceholderText = "Contoh: 2 (untuk 2x lebih besar)"
scaleTextBox.Text = ""
scaleTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scaleTextBox.TextColor3 = Color3.new(1, 1, 1)
scaleTextBox.Parent = editGui
scaleTextBox.Visible = false

local xLabel = Instance.new("TextLabel")
xLabel.Name = "XLabel"
xLabel.Size = UDim2.new(0.3, -5, 0, 20)
xLabel.Position = UDim2.new(0, 10, 0, 40)
xLabel.Text = "X:"
xLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
xLabel.TextColor3 = Color3.new(1, 1, 1)
xLabel.TextXAlignment = Enum.TextXAlignment.Left
xLabel.Parent = editGui
xLabel.Visible = false

local xTextBox = Instance.new("TextBox")
xTextBox.Name = "XTextBox"
xTextBox.Size = UDim2.new(0.3, -5, 0, 30)
xTextBox.Position = UDim2.new(0, 10, 0, 60)
xTextBox.PlaceholderText = "X"
xTextBox.Text = ""
xTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
xTextBox.TextColor3 = Color3.new(1, 1, 1)
xTextBox.Parent = editGui
xTextBox.Visible = false

local yLabel = Instance.new("TextLabel")
yLabel.Name = "YLabel"
yLabel.Size = UDim2.new(0.3, -5, 0, 20)
yLabel.Position = UDim2.new(0.35, 0, 0, 40)
yLabel.Text = "Y:"
yLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
yLabel.TextColor3 = Color3.new(1, 1, 1)
yLabel.TextXAlignment = Enum.TextXAlignment.Left
yLabel.Parent = editGui
yLabel.Visible = false

local yTextBox = Instance.new("TextBox")
yTextBox.Name = "YTextBox"
yTextBox.Size = UDim2.new(0.3, -5, 0, 30)
yTextBox.Position = UDim2.new(0.35, 0, 0, 60)
yTextBox.PlaceholderText = "Y"
yTextBox.Text = ""
yTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
yTextBox.TextColor3 = Color3.new(1, 1, 1)
yTextBox.Parent = editGui
yTextBox.Visible = false

local zLabel = Instance.new("TextLabel")
zLabel.Name = "ZLabel"
zLabel.Size = UDim2.new(0.3, -5, 0, 20)
zLabel.Position = UDim2.new(0.7, 0, 0, 40)
zLabel.Text = "Z:"
zLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
zLabel.TextColor3 = Color3.new(1, 1, 1)
zLabel.TextXAlignment = Enum.TextXAlignment.Left
zLabel.Parent = editGui
zLabel.Visible = false

local zTextBox = Instance.new("TextBox")
zTextBox.Name = "ZTextBox"
zTextBox.Size = UDim2.new(0.3, -5, 0, 30)
zTextBox.Position = UDim2.new(0.7, 0, 0, 60)
zTextBox.PlaceholderText = "Z"
zTextBox.Text = ""
zTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
zTextBox.TextColor3 = Color3.new(1, 1, 1)
zTextBox.Parent = editGui
zTextBox.Visible = false

local applyButton = Instance.new("TextButton")
applyButton.Name = "ApplyButton"
applyButton.Size = UDim2.new(0.45, 0, 0, 30)
applyButton.Position = UDim2.new(0.05, 0, 0, 100)
applyButton.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
applyButton.Text = "Apply"
applyButton.Font = Enum.Font.SourceSansBold
applyButton.Parent = editGui

local closeEditButton = Instance.new("TextButton")
closeEditButton.Name = "CloseButton"
closeEditButton.Size = UDim2.new(0.45, 0, 0, 30)
closeEditButton.Position = UDim2.new(0.5, 5, 0, 100)
closeEditButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
closeEditButton.Text = "Close"
closeEditButton.Font = Enum.Font.SourceSansBold
closeEditButton.Parent = editGui

-- GUI SHOW NAME ADVANCE
local showGui = Instance.new("Frame")
showGui.Name = "ShowNameAdvanceGui"
showGui.Size = UDim2.new(0, 250, 0, 200)
showGui.Position = UDim2.new(0.5, -125, 0.5, -100)
showGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
showGui.Active = true
showGui.Draggable = true
showGui.Visible = false
showGui.Parent = MainGui

local showTitleLabel = Instance.new("TextLabel")
showTitleLabel.Size = UDim2.new(1, 0, 0, 30)
showTitleLabel.Text = "Object Details"
showTitleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
showTitleLabel.TextColor3 = Color3.new(1, 1, 1)
showTitleLabel.Font = Enum.Font.SourceSansBold
showTitleLabel.Parent = showGui

local showDetailsScrollingFrame = Instance.new("ScrollingFrame")
showDetailsScrollingFrame.Name = "DetailsScrollingFrame"
showDetailsScrollingFrame.Size = UDim2.new(1, -20, 1, -80)
showDetailsScrollingFrame.Position = UDim2.new(0, 10, 0, 40)
showDetailsScrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
showDetailsScrollingFrame.BackgroundTransparency = 1
showDetailsScrollingFrame.BorderSizePixel = 0
showDetailsScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
showDetailsScrollingFrame.Parent = showGui

local showDetailsLabel = Instance.new("TextLabel")
showDetailsLabel.Name = "DetailsLabel"
showDetailsLabel.Size = UDim2.new(1, 0, 1, 0)
showDetailsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
showDetailsLabel.BackgroundTransparency = 1
showDetailsLabel.TextColor3 = Color3.new(1, 1, 1)
showDetailsLabel.Text = "Click an object..."
showDetailsLabel.TextXAlignment = Enum.TextXAlignment.Left
showDetailsLabel.TextYAlignment = Enum.TextYAlignment.Top
showDetailsLabel.TextWrapped = true
showDetailsLabel.Font = Enum.Font.SourceSans
showDetailsLabel.TextSize = 14
showDetailsLabel.Parent = showDetailsScrollingFrame

local closeShowButton = Instance.new("TextButton")
closeShowButton.Name = "CloseButton"
closeShowButton.Size = UDim2.new(1, -20, 0, 30)
closeShowButton.Position = UDim2.new(0, 10, 1, -40)
closeShowButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
closeShowButton.Text = "Close"
closeShowButton.Font = Enum.Font.SourceSansBold
closeShowButton.Parent = showGui

closeShowButton.MouseButton1Click:Connect(function()
    showGui.Visible = false
    setExclusiveFeature("")
end)

-- GUI PLAYER LIST
local playerListGui = Instance.new("Frame")
playerListGui.Name = "PlayerListGui"
playerListGui.Size = UDim2.new(0, 250, 0, 300)
playerListGui.Position = UDim2.new(0.5, -125, 0.5, -150)
playerListGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerListGui.Active = true
playerListGui.Draggable = true
playerListGui.Visible = false
playerListGui.Parent = MainGui

local plTitleBar = Instance.new("Frame")
plTitleBar.Size = UDim2.new(1, 0, 0, 30)
plTitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
plTitleBar.Parent = playerListGui

local plTitleLabel = Instance.new("TextLabel")
plTitleLabel.Size = UDim2.new(1, -60, 1, 0)
plTitleLabel.Position = UDim2.new(0, 5, 0, 0)
plTitleLabel.Text = "Player List"
plTitleLabel.TextColor3 = Color3.new(1, 1, 1)
plTitleLabel.TextScaled = true
plTitleLabel.Font = Enum.Font.SourceSansBold
plTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
plTitleLabel.Parent = plTitleBar

local plButtonsLayout = Instance.new("UIListLayout")
plButtonsLayout.Padding = UDim.new(0, 5)
plButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
plButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
plButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
plButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
plButtonsLayout.Parent = plTitleBar

local plCloseButton = Instance.new("TextButton")
plCloseButton.Size = UDim2.new(0, 25, 0, 25)
plCloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
plCloseButton.Text = "X"
plCloseButton.Font = Enum.Font.SourceSansBold
plCloseButton.LayoutOrder = 1
plCloseButton.Parent = plTitleBar

local plMinimizeButton = Instance.new("TextButton")
plMinimizeButton.Size = UDim2.new(0, 25, 0, 25)
plMinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
plMinimizeButton.Text = "-"
plMinimizeButton.Font = Enum.Font.SourceSansBold
plMinimizeButton.LayoutOrder = 2
plMinimizeButton.Parent = plTitleBar

local plScrollingFrame = Instance.new("ScrollingFrame")
plScrollingFrame.Name = "PlayerListScrollingFrame"
plScrollingFrame.Size = UDim2.new(1, 0, 1, -100) -- Disesuaikan untuk tombol stop
plScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
plScrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
plScrollingFrame.BackgroundTransparency = 1
plScrollingFrame.BorderSizePixel = 0
plScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
plScrollingFrame.Parent = playerListGui

local plListLayout = Instance.new("UIListLayout")
plListLayout.Padding = UDim.new(0, 5)
plListLayout.SortOrder = Enum.SortOrder.LayoutOrder
plListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
plListLayout.Parent = plScrollingFrame

local plStopFollowButton = createButton("StopFollowButton", "STOP FOLLOWING", 99, playerListGui)
plStopFollowButton.Size = UDim2.new(1, -20, 0, 40)
plStopFollowButton.Position = UDim2.new(0, 10, 1, -50)
plStopFollowButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
plStopFollowButton.Visible = false
plStopFollowButton.MouseButton1Click:Connect(stopFollowing)

plCloseButton.MouseButton1Click:Connect(function() playerListGui.Visible = false end)

plMinimizeButton.MouseButton1Click:Connect(function()
    local isMinimized = playerListGui.Size.Y.Offset < 300
    if not isMinimized then
        playerListGui.Size = UDim2.new(0, 250, 0, 30)
        plMinimizeButton.Text = "+"
        plScrollingFrame.Visible = false
        plStopFollowButton.Visible = false
    else
        playerListGui.Size = UDim2.new(0, 250, 0, 300)
        plMinimizeButton.Text = "-"
        plScrollingFrame.Visible = true
        if followingPlayer then plStopFollowButton.Visible = true end
    end
end)

local function populatePlayerList()
    for _, child in pairs(plScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local playersInGame = Players:GetPlayers()
    for _, player in ipairs(playersInGame) do
        if player ~= Player then
            local playerButton = createButton("PlayerButton", player.Name, 1, plScrollingFrame)
            playerButton.Size = UDim2.new(1, -10, 0, 40)
            playerButton.Position = UDim2.new(0, 5, 0, 0)
            playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            playerButton.TextScaled = true
            
            local optionsFrame = Instance.new("Frame")
            optionsFrame.Size = UDim2.new(1, 0, 0, 30)
            optionsFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            optionsFrame.Visible = false
            optionsFrame.Parent = playerButton

            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Padding = UDim.new(0, 2)
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.FillDirection = Enum.FillDirection.Horizontal
            optionsLayout.Parent = optionsFrame

            local teleportOption = createButton("TeleportOption", "Teleport", 1, optionsFrame)
            teleportOption.Size = UDim2.new(0.25, -2, 1, 0)
            teleportOption.TextSize = 12
            teleportOption.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    stopFollowing()
                    stopWalkTo()
                    RootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    showTempStatus("Teleported to " .. player.Name)
                end
            end)
            
            local walkToOption = createButton("WalkToOption", "Walk To", 2, optionsFrame)
            walkToOption.Size = UDim2.new(0.25, -2, 1, 0)
            walkToOption.TextSize = 12
            walkToOption.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    stopFollowing()
                    stopWalkTo()
                    Humanoid:MoveTo(player.Character.HumanoidRootPart.Position)
                    walkToConnection = Humanoid.MoveToFinished:Connect(function()
                        showTempStatus("Arrived at " .. player.Name)
                        stopWalkTo()
                    end)
                    showTempStatus("Walking to " .. player.Name)
                end
            end)

            local followOption = createButton("FollowOption", "Follow", 3, optionsFrame)
            followOption.Size = UDim2.new(0.25, -2, 1, 0)
            followOption.TextSize = 12
            followOption.MouseButton1Click:Connect(function()
                stopWalkTo()
                followingPlayer = player
                plStopFollowButton.Visible = true
                showTempStatus("Now following " .. player.Name)
            end)

            local copyPosOption = createButton("CopyPosOption", "Copy Pos", 4, optionsFrame)
            copyPosOption.Size = UDim2.new(0.25, -2, 1, 0)
            copyPosOption.TextSize = 12
            copyPosOption.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            copyPosOption.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local p = player.Character.HumanoidRootPart.Position
                    setclipboard(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z))
                    showTempStatus("Copied " .. player.Name .. " location!")
                end
            end)

            playerButton.MouseButton1Click:Connect(function()
                local newHeight = optionsFrame.Visible and 40 or 70
                playerButton.Size = UDim2.new(1, -10, 0, newHeight)
                optionsFrame.Visible = not optionsFrame.Visible
                plScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, plListLayout.AbsoluteContentSize.Y)
            end)
        end
    end
    plScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, plListLayout.AbsoluteContentSize.Y)
end

-- GUI PLAYER CONFIG
local playerConfigGui = Instance.new("Frame")
playerConfigGui.Name = "PlayerConfigGui"
playerConfigGui.Size = UDim2.new(0, 250, 0, 200)
playerConfigGui.Position = UDim2.new(0.5, -125, 0.5, -100)
playerConfigGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerConfigGui.Active = true
playerConfigGui.Draggable = true
playerConfigGui.Visible = false
playerConfigGui.Parent = MainGui

local pcTitleBar = Instance.new("Frame")
pcTitleBar.Size = UDim2.new(1, 0, 0, 30)
pcTitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
pcTitleBar.Parent = playerConfigGui

local pcTitleLabel = Instance.new("TextLabel")
pcTitleLabel.Size = UDim2.new(1, -60, 1, 0)
pcTitleLabel.Position = UDim2.new(0, 5, 0, 0)
pcTitleLabel.Text = "Player Config"
pcTitleLabel.TextColor3 = Color3.new(1, 1, 1)
pcTitleLabel.TextScaled = true
pcTitleLabel.Font = Enum.Font.SourceSansBold
pcTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
pcTitleLabel.Parent = pcTitleBar

local pcButtonsLayout = Instance.new("UIListLayout")
pcButtonsLayout.Padding = UDim.new(0, 5)
pcButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
pcButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
pcButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
pcButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
pcButtonsLayout.Parent = pcTitleBar

local pcCloseButton = Instance.new("TextButton")
pcCloseButton.Size = UDim2.new(0, 25, 0, 25)
pcCloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
pcCloseButton.Text = "X"
pcCloseButton.Font = Enum.Font.SourceSansBold
pcCloseButton.LayoutOrder = 1
pcCloseButton.Parent = pcTitleBar

local pcMinimizeButton = Instance.new("TextButton")
pcMinimizeButton.Size = UDim2.new(0, 25, 0, 25)
pcMinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
pcMinimizeButton.Text = "-"
pcMinimizeButton.Font = Enum.Font.SourceSansBold
pcMinimizeButton.LayoutOrder = 2
pcMinimizeButton.Parent = pcTitleBar

local pcFeaturesScrollingFrame = Instance.new("ScrollingFrame")
pcFeaturesScrollingFrame.Name = "FeaturesScrollingFrame"
pcFeaturesScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
pcFeaturesScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
pcFeaturesScrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
pcFeaturesScrollingFrame.BackgroundTransparency = 1
pcFeaturesScrollingFrame.BorderSizePixel = 0
pcFeaturesScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
pcFeaturesScrollingFrame.Parent = playerConfigGui

local pcUIListLayout = Instance.new("UIListLayout")
pcUIListLayout.Padding = UDim.new(0, 5)
pcUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
pcUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
pcUIListLayout.Parent = pcFeaturesScrollingFrame

local infiniteJumpButton = createButton("InfiniteJumpButton", "Infinite Jump: OFF", 1, pcFeaturesScrollingFrame)
local godmodeButton = createButton("GodmodeButton", "God Mode: OFF", 2, pcFeaturesScrollingFrame)
local noClipButton = createButton("NoClipButton", "NoClip: OFF", 3, pcFeaturesScrollingFrame)
local jumpButton = createButton("JumpButton", "Jump", 4, pcFeaturesScrollingFrame)
local resetCharButton = createButton("ResetCharButton", "Reset Character", 5, pcFeaturesScrollingFrame)
local sleepButton = createButton("SleepButton", "Turu: OFF", 6, pcFeaturesScrollingFrame)

local jumpPowerLabel = Instance.new("TextLabel")
jumpPowerLabel.Size = UDim2.new(1, -20, 0, 20)
jumpPowerLabel.Text = "Jump Power:"
jumpPowerLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jumpPowerLabel.TextColor3 = Color3.new(1, 1, 1)
jumpPowerLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpPowerLabel.LayoutOrder = 7
jumpPowerLabel.Parent = pcFeaturesScrollingFrame
local jumpPowerTextBox = Instance.new("TextBox")
jumpPowerTextBox.Size = UDim2.new(1, -20, 0, 30)
jumpPowerTextBox.PlaceholderText = "Default: 50"
jumpPowerTextBox.Text = ""
jumpPowerTextBox.LayoutOrder = 8
jumpPowerTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
jumpPowerTextBox.TextColor3 = Color3.new(1, 1, 1)
jumpPowerTextBox.Parent = pcFeaturesScrollingFrame
local applyJumpPowerButton = createButton("ApplyJumpPowerButton", "Apply Jump Power", 9, pcFeaturesScrollingFrame)
applyJumpPowerButton.Size = UDim2.new(1, -20, 0, 30)

local tpwalkLabel = Instance.new("TextLabel")
tpwalkLabel.Size = UDim2.new(1, -20, 0, 20)
tpwalkLabel.Text = "TP Walk:"
tpwalkLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpwalkLabel.TextColor3 = Color3.new(1, 1, 1)
tpwalkLabel.TextXAlignment = Enum.TextXAlignment.Left
tpwalkLabel.LayoutOrder = 10
tpwalkLabel.Parent = pcFeaturesScrollingFrame

local tpwalkButton = createButton("TpwalkButton", "Enable Tpwalk", 11, pcFeaturesScrollingFrame)
tpwalkButton.BackgroundColor3 = Color3.fromRGB(75, 175, 255)
local tpwalkValueTextBox = Instance.new("TextBox")
tpwalkValueTextBox.Size = UDim2.new(1, -20, 0, 30)
tpwalkValueTextBox.PlaceholderText = "Tpwalk Value: " .. TpwalkValue
tpwalkValueTextBox.Text = ""
tpwalkValueTextBox.LayoutOrder = 12
tpwalkValueTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tpwalkValueTextBox.TextColor3 = Color3.new(1, 1, 1)
tpwalkValueTextBox.Parent = pcFeaturesScrollingFrame

local sleepAnimation = Instance.new("Animation")
sleepAnimation.AnimationId = "rbxassetid://176236333"
local loadedAnimation = nil

pcCloseButton.MouseButton1Click:Connect(function() playerConfigGui.Visible = false end)

pcMinimizeButton.MouseButton1Click:Connect(function()
    local isMinimized = playerConfigGui.Size.Y.Offset < 200
    if not isMinimized then
        playerConfigGui.Size = UDim2.new(0, 250, 0, 30)
        pcMinimizeButton.Text = "+"
        pcFeaturesScrollingFrame.Visible = false
    else
        playerConfigGui.Size = UDim2.new(0, 250, 0, 200)
        pcMinimizeButton.Text = "-"
        pcFeaturesScrollingFrame.Visible = true
    end
end)

tpwalkButton.MouseButton1Click:Connect(function()
    ToggleTpwalk = not ToggleTpwalk
    if ToggleTpwalk then
        tpwalkButton.Text = "Disable Tpwalk"
        tpwalkButton.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
        if not TpwalkConnection then
            TpwalkConnection = RunService.Heartbeat:Connect(function()
                if Character and Humanoid and RootPart and Humanoid.MoveDirection.Magnitude > 0 then
                    local moveDirection = Humanoid.MoveDirection
                    local currentTpwalkValue = TpwalkValue
                    RootPart.CFrame += (moveDirection * currentTpwalkValue)
                    RootPart.CanCollide = true
                end
            end)
        end
    else
        tpwalkButton.Text = "Enable Tpwalk"
        tpwalkButton.BackgroundColor3 = Color3.fromRGB(75, 175, 255)
        if TpwalkConnection then
            TpwalkConnection:Disconnect()
            TpwalkConnection = nil
        end
    end
    updateStatusLabel()
end)

tpwalkValueTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local inputValue = tonumber(tpwalkValueTextBox.Text)
        if inputValue and inputValue > 0 then
            TpwalkValue = inputValue
            tpwalkValueTextBox.PlaceholderText = "Tpwalk Value: " .. tostring(TpwalkValue)
            tpwalkValueTextBox.Text = ""
        else
            tpwalkValueTextBox.PlaceholderText = "Invalid input! (Must be > 0)"
            tpwalkValueTextBox.Text = ""
        end
    end
end)

infiniteJumpButton.MouseButton1Click:Connect(function()
    simultaneousFeatures.InfiniteJump = not simultaneousFeatures.InfiniteJump
    infiniteJumpButton.Text = "Infinite Jump: " .. (simultaneousFeatures.InfiniteJump and "ON" or "OFF")
    updateStatusLabel()
end)

UserInputService.JumpRequest:Connect(function()
    if simultaneousFeatures.InfiniteJump then
        Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local godmodeHealthConnection = nil
local function enableGodmode()
    local currentHumanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if currentHumanoid then
        currentHumanoid.MaxHealth = math.huge
        currentHumanoid.Health = math.huge
        godmodeHealthConnection = currentHumanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if currentHumanoid.Health < currentHumanoid.MaxHealth then
                currentHumanoid.Health = currentHumanoid.MaxHealth
            end
        end)
    end
end

local function disableGodmode()
    if godmodeHealthConnection then
        godmodeHealthConnection:Disconnect()
        godmodeHealthConnection = nil
    end
    local currentHumanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if currentHumanoid then
        currentHumanoid.MaxHealth = 100
        currentHumanoid.Health = 100
    end
end

godmodeButton.MouseButton1Click:Connect(function()
    simultaneousFeatures.Godmode = not simultaneousFeatures.Godmode
    godmodeButton.Text = "God Mode: " .. (simultaneousFeatures.Godmode and "ON" or "OFF")
    if simultaneousFeatures.Godmode then
        enableGodmode()
    else
        disableGodmode()
    end
    updateStatusLabel()
end)

local function applyNoClip(character)
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

local function removeNoClip(character)
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

noClipButton.MouseButton1Click:Connect(function()
    simultaneousFeatures.NoClip = not simultaneousFeatures.NoClip
    noClipButton.Text = "NoClip: " .. (simultaneousFeatures.NoClip and "ON" or "OFF")
    if simultaneousFeatures.NoClip then
        applyNoClip(Player.Character)
    else
        removeNoClip(Player.Character)
    end
    updateStatusLabel()
end)

resetCharButton.MouseButton1Click:Connect(function()
    if Player.Character then Player.Character:BreakJoints() end
end)

sleepButton.MouseButton1Click:Connect(function()
    if not Humanoid then return end
    simultaneousFeatures.Sleeping = not simultaneousFeatures.Sleeping
    sleepButton.Text = "Turu: " .. (simultaneousFeatures.Sleeping and "ON" or "OFF")
    updateStatusLabel()
    if simultaneousFeatures.Sleeping then
        if not loadedAnimation then loadedAnimation = Humanoid:LoadAnimation(sleepAnimation) end
        loadedAnimation:Play()
        loadedAnimation:AdjustSpeed(0)
        loadedAnimation.TimePosition = 0.1
    else
        if loadedAnimation then loadedAnimation:Stop() end
    end
end)

jumpButton.MouseButton1Click:Connect(function()
    if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local function applyJumpPower(newPower)
    if Humanoid then Humanoid.JumpPower = newPower end
end

applyJumpPowerButton.MouseButton1Click:Connect(function()
    local power = tonumber(jumpPowerTextBox.Text)
    if power then
        applyJumpPower(power)
        jumpPowerTextBox.PlaceholderText = "Applied: " .. power
        jumpPowerTextBox.Text = ""
    else
        jumpPowerTextBox.PlaceholderText = "Invalid input!"
        jumpPowerTextBox.Text = ""
    end
end)

-- == GUI VISUAL CONFIG ==
local visualConfigGui = Instance.new("Frame")
visualConfigGui.Name = "VisualConfigGui"
visualConfigGui.Size = UDim2.new(0, 250, 0, 300)
visualConfigGui.Position = UDim2.new(0.5, 130, 0.5, -150)
visualConfigGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
visualConfigGui.Active = true
visualConfigGui.Draggable = true
visualConfigGui.Visible = false
visualConfigGui.Parent = MainGui

local vcTitleBar = Instance.new("Frame")
vcTitleBar.Size = UDim2.new(1, 0, 0, 30)
vcTitleBar.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
vcTitleBar.Parent = visualConfigGui

local vcTitleLabel = Instance.new("TextLabel")
vcTitleLabel.Size = UDim2.new(1, -35, 1, 0)
vcTitleLabel.Position = UDim2.new(0, 5, 0, 0)
vcTitleLabel.Text = "Visual Config"
vcTitleLabel.TextColor3 = Color3.new(1, 1, 1)
vcTitleLabel.TextScaled = true
vcTitleLabel.Font = Enum.Font.SourceSansBold
vcTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
vcTitleLabel.Parent = vcTitleBar

local vcCloseButton = Instance.new("TextButton")
vcCloseButton.Size = UDim2.new(0, 25, 0, 25)
vcCloseButton.Position = UDim2.new(1, -28, 0, 2.5)
vcCloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
vcCloseButton.Text = "X"
vcCloseButton.Font = Enum.Font.SourceSansBold
vcCloseButton.Parent = vcTitleBar
vcCloseButton.MouseButton1Click:Connect(function() visualConfigGui.Visible = false end)

local vcFeaturesScrollingFrame = Instance.new("ScrollingFrame")
vcFeaturesScrollingFrame.Size = UDim2.new(1, 0, 1, -35)
vcFeaturesScrollingFrame.Position = UDim2.new(0, 0, 0, 35)
vcFeaturesScrollingFrame.BackgroundTransparency = 1
vcFeaturesScrollingFrame.BorderSizePixel = 0
vcFeaturesScrollingFrame.Parent = visualConfigGui

local vcUIListLayout = Instance.new("UIListLayout")
vcUIListLayout.Padding = UDim.new(0, 5)
vcUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
vcUIListLayout.Parent = vcFeaturesScrollingFrame

-- LOGIKA VISUAL
local function toggleBrightness()
    if visualStates.Fullbright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
    end
end

local function createESP(plr)
    if plr == Player then return end
    local function applyESP(char)
        if not visualStates.ESP then return end
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end

        local box = Instance.new("Highlight")
        box.Name = "ESPHighlight"
        box.FillTransparency = 0.5
        box.OutlineColor = Color3.new(1, 1, 1)
        box.Parent = char

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_UI"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = root

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        
        local role = "Basic Player"
        if plr.UserId == game.CreatorId then role = "Game Creator"
        elseif plr:GetRankInGroup(0) > 100 then role = "Admin/Staff" end
        
        label.Text = plr.Name .. "\n[" .. role .. "]"
        label.Parent = billboard
    end
    plr.CharacterAdded:Connect(applyESP)
    if plr.Character then applyESP(plr.Character) end
end

local function updateDangerESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then
            local part = obj.Parent
            local n = part.Name:lower()
            if n:find("lava") or n:find("kill") or n:find("trap") or n:find("damage") or n:find("danger") then
                if visualStates.DangerESP and not part:FindFirstChild("DangerTag") then
                    local highlight = Instance.new("BoxHandleAdornment")
                    highlight.Name = "DangerTag"
                    highlight.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
                    highlight.AlwaysOnTop = true
                    highlight.Color3 = Color3.new(1, 0, 0)
                    highlight.Adornee = part
                    highlight.Transparency = 0.5
                    highlight.Parent = part
                elseif not visualStates.DangerESP and part:FindFirstChild("DangerTag") then
                    if part:FindFirstChild("DangerTag") then part.DangerTag:Destroy() end
                end
            end
        end
    end
end

local btnFullbright = createButton("BtnFull", "Fullbright: OFF", 1, vcFeaturesScrollingFrame)
btnFullbright.MouseButton1Click:Connect(function()
    visualStates.Fullbright = not visualStates.Fullbright
    btnFullbright.Text = "Fullbright: " .. (visualStates.Fullbright and "ON" or "OFF")
    toggleBrightness()
end)

local btnESP = createButton("BtnESP", "Player ESP: OFF", 2, vcFeaturesScrollingFrame)
btnESP.MouseButton1Click:Connect(function()
    visualStates.ESP = not visualStates.ESP
    btnESP.Text = "Player ESP: " .. (visualStates.ESP and "ON" or "OFF")
    if visualStates.ESP then
        for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then 
                if p.Character:FindFirstChild("ESPHighlight") then p.Character.ESPHighlight:Destroy() end
                if p.Character.HumanoidRootPart:FindFirstChild("ESP_UI") then p.Character.HumanoidRootPart.ESP_UI:Destroy() end
            end
        end
    end
end)

local btnNoFog = createButton("BtnFog", "No Fog: OFF", 3, vcFeaturesScrollingFrame)
btnNoFog.MouseButton1Click:Connect(function()
    visualStates.NoFog = not visualStates.NoFog
    btnNoFog.Text = "No Fog: " .. (visualStates.NoFog and "ON" or "OFF")
    if visualStates.NoFog then
        Lighting.FogEnd = 1000000 
    else
        Lighting.FogEnd = 1000 
    end
end)

local btnReduceTexture = createButton("BtnReduce", "Reduce Texture: OFF", 4, vcFeaturesScrollingFrame)
btnReduceTexture.MouseButton1Click:Connect(function()
    visualStates.ReduceTexture = not visualStates.ReduceTexture
    btnReduceTexture.Text = "Reduce Texture: " .. (visualStates.ReduceTexture and "ON" or "OFF")
    if visualStates.ReduceTexture then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    else
        showTempStatus("Textures reduced! (Reset character to restore some)")
    end
end)

local btnDanger = createButton("BtnDanger", "Danger ESP: OFF", 5, vcFeaturesScrollingFrame)
btnDanger.MouseButton1Click:Connect(function()
    visualStates.DangerESP = not visualStates.DangerESP
    btnDanger.Text = "Danger ESP: " .. (visualStates.DangerESP and "ON" or "OFF")
    updateDangerESP()
end)

VisualConfigButton.MouseButton1Click:Connect(function()
    visualConfigGui.Visible = not visualConfigGui.Visible
    if visualConfigGui.Visible then
        vcFeaturesScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, vcUIListLayout.AbsoluteContentSize.Y)
    end
end)

-- RESET LOGIC ON CHARACTER ADDED
Player.CharacterAdded:Connect(function(character)
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")
    
    if simultaneousFeatures.Godmode then enableGodmode() end
    if simultaneousFeatures.NoClip then applyNoClip(character) end
    if loadedAnimation and loadedAnimation.IsPlaying then loadedAnimation:Stop() end
    simultaneousFeatures.Sleeping = false
    sleepButton.Text = "Turu: OFF"

    local power = tonumber(jumpPowerTextBox.Text)
    if power then applyJumpPower(power) else applyJumpPower(originalJumpPower) end
    
    -- Restart Floatwalk if active
    if simultaneousFeatures.Floatwalk then
        simultaneousFeatures.Floatwalk = false
        toggleFloatwalk()
    end
    
    updateStatusLabel()
end)

local currentEditedObject = nil

local function setEditGuiMode(mode)
    if mode == "proportional" then
        editTitleLabel.Text = "Edit Object (Proportional)"
        scaleLabel.Visible = true; scaleTextBox.Visible = true
        xLabel.Visible = false; xTextBox.Visible = false
        yLabel.Visible = false; yTextBox.Visible = false
        zLabel.Visible = false; zTextBox.Visible = false
    elseif mode == "advanced" then
        editTitleLabel.Text = "Size Edit Advance (Per Part)"
        scaleLabel.Visible = false; scaleTextBox.Visible = false
        xLabel.Visible = true; xTextBox.Visible = true
        yLabel.Visible = true; yTextBox.Visible = true
        zLabel.Visible = true; zTextBox.Visible = true
    end
end

applyButton.MouseButton1Click:Connect(function()
    if not currentEditedObject then return end
    if exclusiveFeatureOn == "EditObject" then
        local scaleFactor = tonumber(scaleTextBox.Text)
        if scaleFactor and scaleFactor > 0 then
            if currentEditedObject:IsA("Model") then currentEditedObject:ScaleTo(scaleFactor)
            elseif currentEditedObject:IsA("BasePart") then currentEditedObject.Size = currentEditedObject.Size * scaleFactor end
        end
    elseif exclusiveFeatureOn == "SizeEditAdvance" then
        local x = tonumber(xTextBox.Text)
        local y = tonumber(yTextBox.Text)
        local z = tonumber(zTextBox.Text)
        if x and y and z then pcall(function() currentEditedObject.Size = Vector3.new(x, y, z) end) end
    end
end)

closeEditButton.MouseButton1Click:Connect(function()
    editGui.Visible = false
    currentEditedObject = nil
end)


local function handleTap()
    if teleportModeOn and Mouse.Target and RootPart then
        local targetPosition = Mouse.Hit.p
        RootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
        showTempStatus("Teleported to a new location.")
        return
    end
    if not exclusiveFeatureOn then return end

    local target = Mouse.Target
    if not target then return end
    local targetPlayer, characterPart = findPlayerFromPart(target)

    if exclusiveFeatureOn == "ShowName" then
        local name = target.Parent and target.Parent:IsA("Model") and target.Parent.Name .. " - " .. target.Name or target.Name
        showTempStatus("Object: " .. name)
        return
    end

    if exclusiveFeatureOn == "ShowNameAdvance" then
        local details = "--- Object Details ---\n"
        details = details .. "Nama: " .. tostring(target.Name) .. "\n"
        details = details .. "Parent: " .. tostring(target.Parent and target.Parent.Name or "Tidak ada") .. "\n"
        details = details .. "Class: " .. tostring(target.ClassName) .. "\n"
        if target:IsA("BasePart") then
            details = details .. "\n--- Part Properties ---\n"
            details = details .. "Posisi: " .. string.format("%.1f, %.1f, %.1f", target.Position.X, target.Position.Y, target.Position.Z) .. "\n"
            details = details .. "Ukuran: " .. string.format("%.1f, %.1f, %.1f", target.Size.X, target.Size.Y, target.Size.Z) .. "\n"
            details = details .. "Warna: " .. tostring(target.Color) .. "\n"
            details = details .. "Transparansi: " .. tostring(target.Transparency) .. "\n"
            details = details .. "CanCollide: " .. tostring(target.CanCollide) .. "\n"
        end
        showDetailsLabel.Text = details
        local textSize = TextService:GetTextSize(details, showDetailsLabel.TextSize, showDetailsLabel.Font, Vector2.new(showDetailsScrollingFrame.AbsoluteSize.X, 99999))
        showDetailsLabel.Size = UDim2.new(1, 0, 0, textSize.Y + 20)
        showDetailsScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)
        showGui.Visible = true
        return
    end
    
    if exclusiveFeatureOn == "Destroy" then
        if not isPlayerPart(target) and not target:IsDescendantOf(MainGui) and target ~= game.Workspace.Terrain then
            local success, err = pcall(function() target:Destroy() end)
            if success and not target.Parent then showTempStatus("Destroyed: " .. tostring(target.Name)) else showTempStatus("Cannot destroy this object.") end
        else showTempStatus("Cannot destroy player's parts, GUI, or terrain.") end
        return
    end

    if exclusiveFeatureOn == "BulkRemove" then
        if not isPlayerPart(target) and not target:IsDescendantOf(MainGui) then
            local targetToRemove = target
            local parent = target.Parent
            if parent and (parent:IsA("Model") or parent:IsA("Folder")) then targetToRemove = parent end
            local success, err = pcall(function() targetToRemove:Destroy() end)
            if success and not targetToRemove.Parent then showTempStatus("Destroyed: " .. tostring(targetToRemove.Name)) else showTempStatus("Cannot destroy this object.") end
        else showTempStatus("Cannot destroy player's parts or GUI.") end
        return
    end

    if exclusiveFeatureOn == "EditObject" and target:IsA("BasePart") then
        if not isPlayerPart(target) and not target:IsDescendantOf(MainGui) then
            local parent = target.Parent
            if parent and (parent:IsA("Model") or parent:IsA("Folder")) then currentEditedObject = parent
            else currentEditedObject = target end
            setEditGuiMode("proportional")
            scaleTextBox.Text = "1"
            editGui.Visible = true
        else showTempStatus("Please select a valid part or model.") end
        return
    end
    
    if exclusiveFeatureOn == "SizeEditAdvance" and target:IsA("BasePart") then
        if not isPlayerPart(target) and not target:IsDescendantOf(MainGui) then
            currentEditedObject = target
            setEditGuiMode("advanced")
            xTextBox.Text = string.format("%.2f", target.Size.X)
            yTextBox.Text = string.format("%.2f", target.Size.Y)
            zTextBox.Text = string.format("%.2f", target.Size.Z)
            editGui.Visible = true
        else showTempStatus("Please select a valid part.") end
        return
    end

    if exclusiveFeatureOn == "PartRemover" then
        if not isPlayerPart(target) and target:IsA("BasePart") then
            if not removedParts[target] then
                removedParts[target] = {Transparency = target.Transparency, CanCollide = target.CanCollide}
                target.Transparency = 1
                target.CanCollide = false
                showTempStatus("Removed collision for: " .. tostring(target.Name))
            else
                target.Transparency = removedParts[target].Transparency
                target.CanCollide = removedParts[target].CanCollide
                removedParts[target] = nil
                showTempStatus("Restored collision for: " .. tostring(target.Name))
            end
        else showTempStatus("Please select a valid part.") end
        return
    end

    if exclusiveFeatureOn == "TagPlayer" and targetPlayer then
        if targetPlayer ~= Player then
            if not taggedPlayers[targetPlayer] then
                local head = target.Parent:FindFirstChild("Head") or target.Parent:FindFirstChild("HumanoidRootPart")
                if head then
                    local tag = Instance.new("BillboardGui")
                    tag.Name = "PlayerTag"
                    tag.Size = UDim2.new(0, 150, 0, 50)
                    tag.AlwaysOnTop = true
                    tag.StudsOffset = Vector3.new(0, 2, 0)
                    tag.Parent = head
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = targetPlayer.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.Font = Enum.Font.SourceSansSemibold
                    nameLabel.TextSize = 20
                    nameLabel.Parent = tag
                    taggedPlayers[targetPlayer] = tag
                    showTempStatus("Tagged: " .. targetPlayer.Name)
                end
            elseif taggedPlayers[targetPlayer] then
                taggedPlayers[targetPlayer]:Destroy()
                taggedPlayers[targetPlayer] = nil
                showTempStatus("Untagged: " .. targetPlayer.Name)
            end
        else showTempStatus("Please select another player.") end
        return
    end
    
    if exclusiveFeatureOn == "LightToggle" then
        if target:IsA("BasePart") then
            local light = target:FindFirstChild("ToggledLight")
            if light then light:Destroy()
            showTempStatus("Light turned OFF.")
            else
                local newLight = Instance.new("PointLight")
                newLight.Name = "ToggledLight"
                newLight.Range = 20
                newLight.Brightness = 2
                newLight.Parent = target
                showTempStatus("Light turned ON.")
            end
        else showTempStatus("Please select a valid part to place a light.") end
        return
    end

    if exclusiveFeatureOn == "PlayerInfo" then
        if targetPlayer then
            local accessories = {}
            for _, child in ipairs(targetPlayer.Character:GetChildren()) do
                if child:IsA("Accessory") then table.insert(accessories, child.Name) end
            end
            local infoText = "Pemain: " .. targetPlayer.Name .. "\nUserID: " .. targetPlayer.UserId .. "\nKesehatan: " .. math.floor(targetPlayer.Character.Humanoid.Health) .. "\nAksesoris: " .. (#accessories > 0 and table.concat(accessories, ", ") or "Tidak ada")
            StatusLabel.Text = infoText
        else showTempStatus("Please select a player part to get info.") end
        return
    end
end

TeleportButton.MouseButton1Click:Connect(function() 
    teleportModeOn = not teleportModeOn
    if teleportModeOn then setExclusiveFeature("Teleport") else setExclusiveFeature(nil) end
    TeleportButton.Text = "Teleport: " .. (teleportModeOn and "ON" or "OFF")
    updateStatusLabel()
end)

DestroyButton.MouseButton1Click:Connect(function() setExclusiveFeature("Destroy") end)
BulkRemoveButton.MouseButton1Click:Connect(function() setExclusiveFeature("BulkRemove") end)
ShowNameButton.MouseButton1Click:Connect(function() setExclusiveFeature("ShowName") end)
ShowNameAdvanceButton.MouseButton1Click:Connect(function() setExclusiveFeature("ShowNameAdvance") end)
PartRemoverButton.MouseButton1Click:Connect(function() setExclusiveFeature("PartRemover") end)
TagPlayerButton.MouseButton1Click:Connect(function() setExclusiveFeature("TagPlayer") end)
LightToggleButton.MouseButton1Click:Connect(function() setExclusiveFeature("LightToggle") end)
PlayerInfoButton.MouseButton1Click:Connect(function() setExclusiveFeature("PlayerInfo") end)
EditObjectButton.MouseButton1Click:Connect(function()
    setExclusiveFeature("EditObject")
    editGui.Visible = exclusiveFeatureOn == "EditObject" or exclusiveFeatureOn == "SizeEditAdvance"
    if exclusiveFeatureOn == "EditObject" then setEditGuiMode("proportional") end
end)
SizeEditAdvanceButton.MouseButton1Click:Connect(function()
    setExclusiveFeature("SizeEditAdvance")
    editGui.Visible = exclusiveFeatureOn == "EditObject" or exclusiveFeatureOn == "SizeEditAdvance"
    if exclusiveFeatureOn == "SizeEditAdvance" then setEditGuiMode("advanced") end
end)


PlayerConfigButton.MouseButton1Click:Connect(function()
    playerConfigGui.Visible = not playerConfigGui.Visible
    if playerConfigGui.Visible then pcFeaturesScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, pcUIListLayout.AbsoluteContentSize.Y) end
end)

PlayerListButton.MouseButton1Click:Connect(function()
    playerListGui.Visible = not playerListGui.Visible
    if playerListGui.Visible then populatePlayerList() end
end)


CloseButton.MouseButton1Click:Connect(function() MainGui:Destroy() end)
MinimizeButton.MouseButton1Click:Connect(function()
    local isMinimized = MainFrame.Size.Y.Offset < UI_SIZE.Y.Offset
    if not isMinimized then
        MainFrame.Size = UDim2.new(0, UI_SIZE.X.Offset, 0, TitleBar.Size.Y.Offset + StatusLabel.Size.Y.Offset)
        MinimizeButton.Text = "+"
        FeaturesScrollingFrame.Visible = false
        StatusLabel.Visible = false
    else
        MainFrame.Size = UI_SIZE
        MinimizeButton.Text = "-"
        FeaturesScrollingFrame.Visible = true
        StatusLabel.Visible = true
    end
end)

-- GUI TELEPORT POINTS
local teleportPointsGui = Instance.new("Frame")
teleportPointsGui.Name = "TeleportPointsGui"
teleportPointsGui.Size = UDim2.new(0, 250, 0, 300)
teleportPointsGui.Position = UDim2.new(0.5, -125, 0.5, -150)
teleportPointsGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
teleportPointsGui.Active = true
teleportPointsGui.Draggable = true
teleportPointsGui.Visible = false
teleportPointsGui.Parent = MainGui

local tpTitleBar = Instance.new("Frame")
tpTitleBar.Size = UDim2.new(1, 0, 0, 30)
tpTitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tpTitleBar.Parent = teleportPointsGui

local tpTitleLabel = Instance.new("TextLabel")
tpTitleLabel.Size = UDim2.new(1, -60, 1, 0)
tpTitleLabel.Position = UDim2.new(0, 5, 0, 0)
tpTitleLabel.Text = "Teleport Points"
tpTitleLabel.TextColor3 = Color3.new(1, 1, 1)
tpTitleLabel.TextScaled = true
tpTitleLabel.Font = Enum.Font.SourceSansBold
tpTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
tpTitleLabel.Parent = tpTitleBar

local tpButtonsLayout = Instance.new("UIListLayout")
tpButtonsLayout.Padding = UDim.new(0, 5)
tpButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
tpButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tpButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
tpButtonsLayout.Parent = tpTitleBar

local tpCloseButton = Instance.new("TextButton")
tpCloseButton.Size = UDim2.new(0, 25, 0, 25)
tpCloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
tpCloseButton.Text = "X"
tpCloseButton.Font = Enum.Font.SourceSansBold
tpCloseButton.LayoutOrder = 1
tpCloseButton.Parent = tpTitleBar

local tpMinimizeButton = Instance.new("TextButton")
tpMinimizeButton.Size = UDim2.new(0, 25, 0, 25)
tpMinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
tpMinimizeButton.Text = "-"
tpMinimizeButton.Font = Enum.Font.SourceSansBold
tpMinimizeButton.LayoutOrder = 2
tpMinimizeButton.Parent = tpTitleBar

local tpHeaderFrame = Instance.new("Frame")
tpHeaderFrame.Size = UDim2.new(1, 0, 0, 85)
tpHeaderFrame.Position = UDim2.new(0, 0, 0, 30)
tpHeaderFrame.BackgroundTransparency = 1
tpHeaderFrame.Parent = teleportPointsGui

local saveButton = createButton("SaveButton", "Save Current Location", 1, tpHeaderFrame)
saveButton.Size = UDim2.new(1, -20, 0, 40)
saveButton.Position = UDim2.new(0, 10, 0, 5)
saveButton.BackgroundColor3 = Color3.fromRGB(70, 180, 70)

local copyCurrentPosBtn = createButton("CopyCurrentPosBtn", "Copy My Location", 2, tpHeaderFrame)
copyCurrentPosBtn.Size = UDim2.new(1, -20, 0, 35)
copyCurrentPosBtn.Position = UDim2.new(0, 10, 0, 45)
copyCurrentPosBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
copyCurrentPosBtn.MouseButton1Click:Connect(function()
    if RootPart then
        local p = RootPart.Position
        setclipboard(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z))
        showTempStatus("Copied your location!")
    end
end)

local tpListScrollingFrame = Instance.new("ScrollingFrame")
tpListScrollingFrame.Name = "TeleportListScrollingFrame"
tpListScrollingFrame.Size = UDim2.new(1, 0, 1, -120)
tpListScrollingFrame.Position = UDim2.new(0, 0, 0, 115)
tpListScrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tpListScrollingFrame.BackgroundTransparency = 1
tpListScrollingFrame.BorderSizePixel = 0
tpListScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
tpListScrollingFrame.Parent = teleportPointsGui

local tpListLayout = Instance.new("UIListLayout")
tpListLayout.Padding = UDim.new(0, 5)
tpListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tpListLayout.Parent = tpListScrollingFrame

local teleportPoints = {}

local function updateTeleportList()
    for _, child in pairs(tpListScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local layoutOrder = 1
    for name, pos in pairs(teleportPoints) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Size = UDim2.new(1, -20, 0, 40)
        entryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        entryFrame.LayoutOrder = layoutOrder
        entryFrame.Parent = tpListScrollingFrame
        local entryName = Instance.new("TextLabel")
        entryName.Size = UDim2.new(1, -60, 1, 0)
        entryName.Position = UDim2.new(0, 5, 0, 0)
        entryName.Text = name
        entryName.TextColor3 = Color3.new(1, 1, 1)
        entryName.TextScaled = true
        entryName.TextXAlignment = Enum.TextXAlignment.Left
        entryName.Font = Enum.Font.SourceSansBold
        entryName.Parent = entryFrame
        local teleportBtn = Instance.new("TextButton")
        teleportBtn.Size = UDim2.new(0, 25, 0, 25)
        teleportBtn.Position = UDim2.new(1, -55, 0, 7.5)
        teleportBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 180)
        teleportBtn.Text = "TP"
        teleportBtn.Font = Enum.Font.SourceSansBold
        teleportBtn.Parent = entryFrame
        local deleteBtn = Instance.new("TextButton")
        deleteBtn.Size = UDim2.new(0, 25, 0, 25)
        deleteBtn.Position = UDim2.new(1, -25, 0, 7.5)
        deleteBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        deleteBtn.Text = "X"
        deleteBtn.Font = Enum.Font.SourceSansBold
        deleteBtn.Parent = entryFrame
        teleportBtn.MouseButton1Click:Connect(function()
            if RootPart then RootPart.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
            showTempStatus("Teleported to " .. name) end
        end)
        deleteBtn.MouseButton1Click:Connect(function() teleportPoints[name] = nil; updateTeleportList() end)
        layoutOrder = layoutOrder + 1
    end
    tpListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, tpListLayout.AbsoluteContentSize.Y)
end

local dialogFrame = Instance.new("Frame")
dialogFrame.Size = UDim2.new(0, 250, 0, 150)
dialogFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
dialogFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dialogFrame.Visible = false
dialogFrame.Parent = MainGui

local dialogTitle = Instance.new("TextLabel")
dialogTitle.Size = UDim2.new(1, 0, 0, 30)
dialogTitle.Text = "Save Teleport Point"
dialogTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dialogTitle.TextColor3 = Color3.new(1, 1, 1)
dialogTitle.Font = Enum.Font.SourceSansBold
dialogTitle.Parent = dialogFrame

local nameTextBox = Instance.new("TextBox")
nameTextBox.Size = UDim2.new(1, -20, 0, 30)
nameTextBox.Position = UDim2.new(0, 10, 0, 50)
nameTextBox.PlaceholderText = "Masukkan nama titik teleport"
nameTextBox.Text = ""
nameTextBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
nameTextBox.TextColor3 = Color3.new(1, 1, 1)
nameTextBox.Parent = dialogFrame

local saveDialogBtn = createButton("SaveDialogButton", "Save", 1, dialogFrame)
saveDialogBtn.Size = UDim2.new(0.45, 0, 0, 30)
saveDialogBtn.Position = UDim2.new(0.05, 0, 0, 100)
saveDialogBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 70)

local cancelDialogBtn = createButton("CancelDialogButton", "Cancel", 2, dialogFrame)
cancelDialogBtn.Size = UDim2.new(0.45, 0, 0, 30)
cancelDialogBtn.Position = UDim2.new(0.5, 5, 0, 100)
cancelDialogBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)

saveButton.MouseButton1Click:Connect(function() if RootPart then nameTextBox.Text = "Teleport " .. (table.maxn(teleportPoints) + 1); dialogFrame.Visible = true end end)
saveDialogBtn.MouseButton1Click:Connect(function()
    local name = nameTextBox.Text
    if name and name ~= "" then
        if not teleportPoints[name] then teleportPoints[name] = RootPart.Position; updateTeleportList(); showTempStatus("Saved point: " .. name); dialogFrame.Visible = false
        else showTempStatus("Nama '" .. name .. "' sudah ada.") end
    end
end)
cancelDialogBtn.MouseButton1Click:Connect(function() dialogFrame.Visible = false end)

tpCloseButton.MouseButton1Click:Connect(function() teleportPointsGui.Visible = false end)
tpMinimizeButton.MouseButton1Click:Connect(function()
    local isMinimized = teleportPointsGui.Size.Y.Offset < 300
    if not isMinimized then teleportPointsGui.Size = UDim2.new(0, 250, 0, 30); tpMinimizeButton.Text = "+"; tpHeaderFrame.Visible = false; tpListScrollingFrame.Visible = false
    else teleportPointsGui.Size = UDim2.new(0, 250, 0, 300); tpMinimizeButton.Text = "-"; tpHeaderFrame.Visible = true; tpListScrollingFrame.Visible = true; updateTeleportList() end
end)

TeleportPointsButton.MouseButton1Click:Connect(function() teleportPointsGui.Visible = not teleportPointsGui.Visible; if teleportPointsGui.Visible then updateTeleportList() end end)

-- == PERBAIKAN FITUR: OBJECT SEARCH ==
local objectSearchGui = Instance.new("Frame")
objectSearchGui.Name = "ObjectSearchGui"
objectSearchGui.Size = UDim2.new(0, 350, 0, 400)
objectSearchGui.Position = UDim2.new(0.5, -175, 0.5, -200)
objectSearchGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
objectSearchGui.Active = true
objectSearchGui.Draggable = true
objectSearchGui.Visible = false
objectSearchGui.Parent = MainGui

local osTitleBar = Instance.new("Frame")
osTitleBar.Size = UDim2.new(1, 0, 0, 30)
osTitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
osTitleBar.Parent = objectSearchGui

local osTitleLabel = Instance.new("TextLabel")
osTitleLabel.Size = UDim2.new(1, -60, 1, 0)
osTitleLabel.Position = UDim2.new(0, 5, 0, 0)
osTitleLabel.Text = "Object Search"
osTitleLabel.TextColor3 = Color3.new(1, 1, 1)
osTitleLabel.TextScaled = true
osTitleLabel.Font = Enum.Font.SourceSansBold
osTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
osTitleLabel.Parent = osTitleBar

local osCloseButton = Instance.new("TextButton")
osCloseButton.Size = UDim2.new(0, 25, 0, 25)
osCloseButton.Position = UDim2.new(1, -30, 0, 2.5)
osCloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
osCloseButton.Text = "X"
osCloseButton.Font = Enum.Font.SourceSansBold
osCloseButton.Parent = osTitleBar
osCloseButton.MouseButton1Click:Connect(function() objectSearchGui.Visible = false end)

local osSearchFrame = Instance.new("Frame")
osSearchFrame.Size = UDim2.new(1, 0, 0, 40)
osSearchFrame.Position = UDim2.new(0, 0, 0, 30)
osSearchFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
osSearchFrame.Parent = objectSearchGui

local osSearchBox = Instance.new("TextBox")
osSearchBox.Size = UDim2.new(1, -110, 0, 30)
osSearchBox.Position = UDim2.new(0, 5, 0, 5)
osSearchBox.PlaceholderText = "Cari nama objek..."
osSearchBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
osSearchBox.TextColor3 = Color3.new(1, 1, 1)
osSearchBox.Parent = osSearchFrame

local osSearchButton = Instance.new("TextButton")
osSearchButton.Size = UDim2.new(0, 100, 0, 30)
osSearchButton.Position = UDim2.new(1, -105, 0, 5)
osSearchButton.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
osSearchButton.Text = "Cari"
osSearchButton.Parent = osSearchFrame

local osResultsScrollingFrame = Instance.new("ScrollingFrame")
osResultsScrollingFrame.Size = UDim2.new(1, 0, 1, -100)
osResultsScrollingFrame.Position = UDim2.new(0, 0, 0, 70)
osResultsScrollingFrame.BackgroundTransparency = 1
osResultsScrollingFrame.Parent = objectSearchGui

local osListLayout = Instance.new("UIListLayout")
osListLayout.Padding = UDim.new(0, 5)
osListLayout.Parent = osResultsScrollingFrame

local osResultLabel = Instance.new("TextLabel")
osResultLabel.Size = UDim2.new(1, 0, 0, 20)
osResultLabel.Position = UDim2.new(0,0,1,-25)
osResultLabel.Text = "Hasil: 0"
osResultLabel.TextColor3 = Color3.new(1, 1, 1)
osResultLabel.Parent = objectSearchGui

local function searchObjects(nameToSearch)
    for _, child in pairs(osResultsScrollingFrame:GetChildren()) do if child.Name == "ObjectResult" then child:Destroy() end end
    local foundObjects = {}
    local searchPattern = string.lower(nameToSearch)
    if searchPattern == "" then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isPlayerPart(obj) and not obj:IsDescendantOf(MainGui) and string.find(string.lower(obj.Name), searchPattern) and (obj:IsA("BasePart") or obj:IsA("Model")) then 
            table.insert(foundObjects, obj) 
        end
    end

    for _, obj in ipairs(foundObjects) do
        local resultFrame = Instance.new("Frame")
        resultFrame.Name = "ObjectResult"
        resultFrame.Size = UDim2.new(1, -10, 0, 45)
        resultFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        resultFrame.Parent = osResultsScrollingFrame
        
        local objName = Instance.new("TextLabel")
        objName.Size = UDim2.new(0.5, -5, 1, 0)
        objName.Position = UDim2.new(0, 5, 0, 0)
        objName.Text = obj.Name
        objName.TextColor3 = Color3.new(1, 1, 1)
        objName.TextXAlignment = Enum.TextXAlignment.Left
        objName.TextScaled = true
        objName.BackgroundTransparency = 1
        objName.Parent = resultFrame

        -- Tombol TP
        local tpBtn = createButton("TP", "TP", 1, resultFrame)
        tpBtn.Size = UDim2.new(0.15, -2, 0.8, 0)
        tpBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
        tpBtn.MouseButton1Click:Connect(function() 
            if RootPart then 
                local targetCFrame = obj:IsA("Model") and obj:GetModelCFrame() or obj.CFrame
                RootPart.CFrame = targetCFrame + Vector3.new(0, 5, 0)
                showTempStatus("Teleported to " .. obj.Name)
            end 
        end)

        -- Tombol ESP Objek
        local espBtn = createButton("ESP", "ESP", 2, resultFrame)
        espBtn.Size = UDim2.new(0.15, -2, 0.8, 0)
        espBtn.Position = UDim2.new(0.66, 0, 0.1, 0)
        espBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 45)
        espBtn.MouseButton1Click:Connect(function()
            if obj:FindFirstChild("ObjectHighlight") then
                obj.ObjectHighlight:Destroy()
                if obj:FindFirstChild("ObjectESP_UI") then obj.ObjectESP_UI:Destroy() end
                showTempStatus("ESP Removed for " .. obj.Name)
            else
                local highlight = Instance.new("Highlight")
                highlight.Name = "ObjectHighlight"
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.Parent = obj

                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ObjectESP_UI"
                billboard.Size = UDim2.new(0, 100, 0, 30)
                billboard.AlwaysOnTop = true
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.Adornee = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                billboard.Parent = obj

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "[ " .. obj.Name .. " ]"
                label.TextColor3 = Color3.new(0, 1, 0)
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 14
                label.Parent = billboard
                showTempStatus("ESP On for " .. obj.Name)
            end
        end)

        -- Tombol Delete Objek
        local delBtn = createButton("Del", "Del", 3, resultFrame)
        delBtn.Size = UDim2.new(0.15, -2, 0.8, 0)
        delBtn.Position = UDim2.new(0.82, 0, 0.1, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        delBtn.MouseButton1Click:Connect(function()
            local n = obj.Name
            local success, _ = pcall(function() obj:Destroy() end)
            if success then
                resultFrame:Destroy()
                showTempStatus("Deleted: " .. n)
            end
        end)
    end
    osResultLabel.Text = "Hasil: " .. #foundObjects
    osResultsScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, osListLayout.AbsoluteContentSize.Y)
end

ObjectSearchButton.MouseButton1Click:Connect(function() objectSearchGui.Visible = not objectSearchGui.Visible end)
osSearchButton.MouseButton1Click:Connect(function() searchObjects(osSearchBox.Text) end)

local teleportCoordsGui = Instance.new("Frame")
teleportCoordsGui.Name = "TeleportCoordsGui"
teleportCoordsGui.Size = UDim2.new(0, 250, 0, 150)
teleportCoordsGui.Position = UDim2.new(0.5, -125, 0.5, -75)
teleportCoordsGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
teleportCoordsGui.Visible = false
teleportCoordsGui.Parent = MainGui

local tcTitleBar = Instance.new("Frame")
tcTitleBar.Size = UDim2.new(1, 0, 0, 30)
tcTitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tcTitleBar.Parent = teleportCoordsGui

local tcCloseButton = Instance.new("TextButton")
tcCloseButton.Size = UDim2.new(0, 25, 0, 25)
tcCloseButton.Position = UDim2.new(1, -30, 0, 2.5)
tcCloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
tcCloseButton.Text = "X"
tcCloseButton.Parent = tcTitleBar
tcCloseButton.MouseButton1Click:Connect(function() teleportCoordsGui.Visible = false end)

local tcCoordsTextBox = Instance.new("TextBox")
tcCoordsTextBox.Size = UDim2.new(1, -20, 0, 30)
tcCoordsTextBox.Position = UDim2.new(0, 10, 0, 50)
tcCoordsTextBox.PlaceholderText = "X, Y, Z"
tcCoordsTextBox.Parent = teleportCoordsGui

local tcTeleportButton = createButton("TCTeleportButton", "Teleport", 1, teleportCoordsGui)
tcTeleportButton.Position = UDim2.new(0, 10, 0, 100)
tcTeleportButton.MouseButton1Click:Connect(function()
    local coords = splitString(tcCoordsTextBox.Text, ",")
    if #coords == 3 then RootPart.CFrame = CFrame.new(tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])) end
end)

TeleportCoordsButton.MouseButton1Click:Connect(function() teleportCoordsGui.Visible = not teleportCoordsGui.Visible end)

-- == FITUR BARU: PROXIMITY TOOLS (FAST INTERACTION & FINDER) ==
local proximityGui = Instance.new("Frame")
proximityGui.Name = "ProximityToolsGui"
proximityGui.Size = UDim2.new(0, 350, 0, 400)
proximityGui.Position = UDim2.new(0.5, -175, 0.5, -200)
proximityGui.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
proximityGui.Active = true
proximityGui.Draggable = true
proximityGui.Visible = false
proximityGui.Parent = MainGui

local prTitleBar = Instance.new("Frame")
prTitleBar.Size = UDim2.new(1, 0, 0, 30)
prTitleBar.BackgroundColor3 = Color3.fromRGB(45, 120, 180)
prTitleBar.Parent = proximityGui

local prTitleLabel = Instance.new("TextLabel")
prTitleLabel.Size = UDim2.new(1, -40, 1, 0)
prTitleLabel.Position = UDim2.new(0, 5, 0, 0)
prTitleLabel.Text = "Proximity & Interaction Manager"
prTitleLabel.TextColor3 = Color3.new(1, 1, 1)
prTitleLabel.TextScaled = true
prTitleLabel.Font = Enum.Font.SourceSansBold
prTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
prTitleLabel.Parent = prTitleBar

local prCloseButton = Instance.new("TextButton")
prCloseButton.Size = UDim2.new(0, 25, 0, 25)
prCloseButton.Position = UDim2.new(1, -30, 0, 2.5)
prCloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
prCloseButton.Text = "X"
prCloseButton.Parent = prTitleBar
prCloseButton.MouseButton1Click:Connect(function() proximityGui.Visible = false end)

local fastProxBtn = createButton("FastProxBtn", "Fast Proximity: OFF", 1, proximityGui)
fastProxBtn.Size = UDim2.new(1, -20, 0, 35)
fastProxBtn.Position = UDim2.new(0, 10, 0, 40)
fastProxBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local scanProxBtn = createButton("ScanProxBtn", "SCAN INTERACTIONS", 2, proximityGui)
scanProxBtn.Size = UDim2.new(1, -20, 0, 35)
scanProxBtn.Position = UDim2.new(0, 10, 0, 80)
scanProxBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)

local prScrollingFrame = Instance.new("ScrollingFrame")
prScrollingFrame.Size = UDim2.new(1, 0, 1, -125)
prScrollingFrame.Position = UDim2.new(0, 0, 0, 125)
prScrollingFrame.BackgroundTransparency = 1
prScrollingFrame.Parent = proximityGui

local prListLayout = Instance.new("UIListLayout")
prListLayout.Padding = UDim.new(0, 5)
prListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
prListLayout.Parent = prScrollingFrame

-- Logika Fast Proximity
fastProxBtn.MouseButton1Click:Connect(function()
    simultaneousFeatures.FastProximity = not simultaneousFeatures.FastProximity
    fastProxBtn.Text = "Fast Proximity: " .. (simultaneousFeatures.FastProximity and "ON" or "OFF")
    fastProxBtn.BackgroundColor3 = simultaneousFeatures.FastProximity and Color3.fromRGB(70, 180, 70) or Color3.fromRGB(60, 60, 60)
    updateStatusLabel()
end)

-- Loop Fast Proximity
RunService.Stepped:Connect(function()
    if simultaneousFeatures.FastProximity then
        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                p.HoldDuration = 0
                p.MaxActivationDistance = 20 -- Jarak interaksi ditingkatkan
            end
        end
    end
end)

local function scanProximities()
    for _, child in pairs(prScrollingFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local count = 0
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            count = count + 1
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -20, 0, 50)
            entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            entry.Parent = prScrollingFrame

            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(0.6, 0, 1, 0)
            info.Position = UDim2.new(0, 5, 0, 0)
            info.Text = "["..p.ActionText.."]\n"..p.ObjectText.." ("..p.Parent.Name..")"
            info.TextColor3 = Color3.new(1, 1, 1)
            info.TextScaled = true
            info.TextXAlignment = Enum.TextXAlignment.Left
            info.BackgroundTransparency = 1
            info.Parent = entry

            local tpBtn = createButton("TP", "TP", 1, entry)
            tpBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
            tpBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
            tpBtn.MouseButton1Click:Connect(function()
                if RootPart then 
                    stopFollowing()
                    RootPart.CFrame = p.Parent.CFrame + Vector3.new(0, 3, 0) 
                end
            end)

            local getBtn = createButton("TP Player", "Ke Player", 2, entry)
            getBtn.Size = UDim2.new(0.18, 0, 0.7, 0)
            getBtn.Position = UDim2.new(0.81, 0, 0.15, 0)
            getBtn.TextSize = 10
            getBtn.MouseButton1Click:Connect(function()
                -- Teleport Interaksi ke depan kita (Client Side)
                p.Parent.CFrame = RootPart.CFrame + RootPart.CFrame.LookVector * 5
                showTempStatus("Interaction moved to you!")
            end)
        end
    end
    prScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, prListLayout.AbsoluteContentSize.Y)
    showTempStatus("Found " .. count .. " Interactions!")
end

scanProxBtn.MouseButton1Click:Connect(scanProximities)
ProximityManagerButton.MouseButton1Click:Connect(function() proximityGui.Visible = not proximityGui.Visible end)

-- == TRIGGER FINDER (GUI & LOGIKA) ==
local triggerGui = Instance.new("Frame")
triggerGui.Name = "TriggerFinderGui"
triggerGui.Size = UDim2.new(0, 350, 0, 400)
triggerGui.Position = UDim2.new(0.5, -175, 0.5, -200)
triggerGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
triggerGui.Active = true
triggerGui.Draggable = true
triggerGui.Visible = false
triggerGui.Parent = MainGui

local trTitleBar = Instance.new("Frame")
trTitleBar.Size = UDim2.new(1, 0, 0, 30)
trTitleBar.BackgroundColor3 = Color3.fromRGB(80, 50, 100)
trTitleBar.Parent = triggerGui

local trTitleLabel = Instance.new("TextLabel")
trTitleLabel.Size = UDim2.new(1, -40, 1, 0)
trTitleLabel.Position = UDim2.new(0, 5, 0, 0)
trTitleLabel.Text = "Auto Trigger Finder (By Olodeh)"
trTitleLabel.TextColor3 = Color3.new(1, 1, 1)
trTitleLabel.TextScaled = true
trTitleLabel.Font = Enum.Font.SourceSansBold
trTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
trTitleLabel.Parent = trTitleBar

local trCloseButton = Instance.new("TextButton")
trCloseButton.Size = UDim2.new(0, 25, 0, 25)
trCloseButton.Position = UDim2.new(1, -30, 0, 2.5)
trCloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
trCloseButton.Text = "X"
trCloseButton.Parent = trTitleBar
trCloseButton.MouseButton1Click:Connect(function() triggerGui.Visible = false end)

local trScanButton = createButton("TRScanButton", "SCAN ALL TRIGGERS", 1, triggerGui)
trScanButton.Size = UDim2.new(1, -20, 0, 40)
trScanButton.Position = UDim2.new(0, 10, 0, 40)
trScanButton.BackgroundColor3 = Color3.fromRGB(120, 60, 180)

local trScrollingFrame = Instance.new("ScrollingFrame")
trScrollingFrame.Size = UDim2.new(1, 0, 1, -90)
trScrollingFrame.Position = UDim2.new(0, 0, 0, 90)
trScrollingFrame.BackgroundTransparency = 1
trScrollingFrame.Parent = triggerGui

local trListLayout = Instance.new("UIListLayout")
trListLayout.Padding = UDim.new(0, 5)
trListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
trListLayout.Parent = trScrollingFrame

local function scanTriggers()
    for _, child in pairs(trScrollingFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local found = 0
    
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent:IsA("BasePart") then
            local part = v.Parent
            if isPlayerPart(part) then continue end
            
            found = found + 1
            local category = "Unknown Event"
            local color = Color3.fromRGB(150, 150, 150)
            local n = part.Name:lower()

            -- Auto Categorize Logic
            if n:find("checkpoint") or n:find("spawn") or n:find("stage") then
                category = "Checkpoint"
                color = Color3.fromRGB(60, 180, 60)
            elseif n:find("kill") or n:find("lava") or n:find("damage") or n:find("trap") or n:find("dead") then
                category = "Danger/Kill"
                color = Color3.fromRGB(180, 60, 60)
            elseif n:find("teleport") or n:find("portal") or n:find("warp") or n:find("to") then
                category = "Teleporter"
                color = Color3.fromRGB(60, 120, 180)
            elseif n:find("finish") or n:find("win") or n:find("end") then
                category = "Finish/Goal"
                color = Color3.fromRGB(200, 180, 40)
            end

            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -20, 0, 50)
            entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            entry.Parent = trScrollingFrame

            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(0.45, 0, 1, 0)
            info.Position = UDim2.new(0, 5, 0, 0)
            info.Text = "[" .. category .. "]\n" .. part.Name
            info.TextColor3 = color
            info.TextScaled = true
            info.TextXAlignment = Enum.TextXAlignment.Left
            info.BackgroundTransparency = 1
            info.Parent = entry

            -- Tombol TP
            local tp = createButton("TP", "TP", 1, entry)
            tp.Size = UDim2.new(0.15, 0, 0.7, 0)
            tp.Position = UDim2.new(0.5, 0, 0.15, 0)
            tp.MouseButton1Click:Connect(function()
                if RootPart then 
                    stopFollowing()
                    RootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0) 
                end
            end)

            -- Tombol ESP
            local highlightBtn = createButton("ESP", "ESP", 2, entry)
            highlightBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
            highlightBtn.Position = UDim2.new(0.66, 0, 0.15, 0)
            highlightBtn.BackgroundColor3 = color
            highlightBtn.MouseButton1Click:Connect(function()
                if part:FindFirstChild("TR_Highlight") then
                    part.TR_Highlight:Destroy()
                else
                    local h = Instance.new("Highlight")
                    h.Name = "TR_Highlight"
                    h.FillColor = color
                    h.Parent = part
                    showTempStatus("ESP On: " .. part.Name)
                end
            end)

            -- Tombol DELETE
            local delTrigger = createButton("Del", "Del", 3, entry)
            delTrigger.Size = UDim2.new(0.15, 0, 0.7, 0)
            delTrigger.Position = UDim2.new(0.82, 0, 0.15, 0)
            delTrigger.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
            delTrigger.MouseButton1Click:Connect(function()
                local name = part.Name
                local success, _ = pcall(function() part:Destroy() end)
                if success then
                    entry:Destroy()
                    showTempStatus("Trigger Deleted: " .. name)
                end
            end)
        end
    end
    trScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, trListLayout.AbsoluteContentSize.Y)
    showTempStatus("Found " .. found .. " Triggers!")
end

trScanButton.MouseButton1Click:Connect(scanTriggers)
TriggerFinderButton.MouseButton1Click:Connect(function() triggerGui.Visible = not triggerGui.Visible end)

-- FINAL SETUP
updateCanvasSize()
Mouse.Button1Down:Connect(handleTap)

RunService.Heartbeat:Connect(function()
    if followingPlayer and followingPlayer.Character and followingPlayer.Character:FindFirstChild("HumanoidRootPart") and RootPart then
        local targetPos = followingPlayer.Character.HumanoidRootPart.Position
        if (RootPart.Position - targetPos).Magnitude > FOLLOW_PLAYER_DISTANCE then 
            Humanoid:MoveTo(targetPos - (targetPos - RootPart.Position).unit * FOLLOW_PLAYER_DISTANCE) 
        end
    end
end)

showTempStatus("Universal Tools By Olodeh 2026 Loaded!")

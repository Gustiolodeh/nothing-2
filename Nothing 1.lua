--! Delta Script: Ultimate Multi-Feature GUI

--[[
    Skrip ini telah diperbarui untuk:
    - Membuat fitur "Damage Nullifier" bisa diaktifkan/dinonaktifkan menggunakan tombol.
    - Menghilangkan aktivasi otomatis fitur tersebut saat skrip dimuat.
]]

--------------------------------------------------------------------------------
-- SERVICES AND VARIABLES
--------------------------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configurable lists for searching
local searchObjectNames = {}
local foundObjects = {}

local searchMonsterNames = {"Deep Mimic", "Lush Rock Person", "Mimic", "Rock Person"}
local foundMonsters = {}

local isObjectEspEnabled = false
local isMonsterEspEnabled = false
local isDamageNullified = false
local isMonsterFrozen = false
local isAutoBrightEnabled = false
local originalLightingProperties = {}
local originalMonsterWalkspeeds = {}
local originalTakeDamage = {}

local espConnection = nil
local objectEspRadius = 500
local monsterEspRadius = 500

-- Configurable shops
local shopList = {
    ["Shop Keeper"] = {eventName = "OpenShop", eventParameter = "Shop Keeper"},
    ["Shop Keeper 2"] = {eventName = "OpenShop", eventParameter = "Shop Keeper 2"},
    ["Shop Keeper 3"] = {eventName = "OpenShop", eventParameter = "Shop Keeper 3"},
    ["Bandit"] = {eventName = "OpenShop", eventParameter = "Bandit"}
}

--------------------------------------------------------------------------------
-- GUI CREATION
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainGUI"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BorderSizePixel = 0
mainFrame.Size = UDim2.new(0, 240, 0, 110)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = Color3.new(1, 0, 0)
mainStroke.Name = "RGBOutline"
mainStroke.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Text = "Ultimate Multi-Feature"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
titleLabel.Parent = topBar

local minMaxButton = Instance.new("TextButton")
minMaxButton.Name = "MinimizeButton"
minMaxButton.Text = "-"
minMaxButton.Font = Enum.Font.SourceSansBold
minMaxButton.TextSize = 20
minMaxButton.TextColor3 = Color3.new(1, 1, 1)
minMaxButton.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
minMaxButton.Size = UDim2.new(0, 30, 1, 0)
minMaxButton.Position = UDim2.new(1, -60, 0, 0)
minMaxButton.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "x"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Parent = topBar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.BackgroundTransparency = 1
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.Parent = mainFrame

local horizontalLayout = Instance.new("UIListLayout")
horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
horizontalLayout.Padding = UDim.new(0, 5)
horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
horizontalLayout.Parent = contentFrame

-- FINDER SECTION
local finderHeader = Instance.new("TextButton")
finderHeader.Name = "FinderHeader"
finderHeader.Text = "Object Finder"
finderHeader.TextColor3 = Color3.new(1, 1, 1)
finderHeader.Font = Enum.Font.SourceSansBold
finderHeader.TextSize = 16
finderHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
finderHeader.Size = UDim2.new(0, 110, 0, 30)
finderHeader.Parent = contentFrame

local finderContent = Instance.new("Frame")
finderContent.Name = "FinderContent"
finderContent.BackgroundTransparency = 1
finderContent.Size = UDim2.new(0, 200, 0, 200)
finderContent.Visible = false
finderContent.Parent = contentFrame

local finderLayout = Instance.new("UIListLayout")
finderLayout.FillDirection = Enum.FillDirection.Vertical
finderLayout.Padding = UDim.new(0, 5)
finderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
finderLayout.Parent = finderContent

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.PlaceholderText = "e.g., 'lithium', 'ore', 'rock'"
searchBox.Text = ""
searchBox.Font = Enum.Font.SourceSans
searchBox.TextSize = 16
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
searchBox.Size = UDim2.new(0.9, 0, 0, 30)
searchBox.Parent = finderContent

local findButton = Instance.new("TextButton")
findButton.Name = "FindButton"
findButton.Text = "Find Objects"
findButton.TextColor3 = Color3.new(1, 1, 1)
findButton.Font = Enum.Font.SourceSansBold
findButton.TextSize = 18
findButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.8)
findButton.Size = UDim2.new(0.9, 0, 0, 40)
findButton.Parent = finderContent

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Text = "Enter a search term."
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 14
statusLabel.BackgroundTransparency = 1
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Parent = finderContent

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "ObjectList"
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Size = UDim2.new(0.9, 0, 1, -120)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderColor3 = Color3.new(0, 0, 0)
scrollingFrame.BorderSizePixel = 1
scrollingFrame.Parent = finderContent

local scrollingLayout = Instance.new("UIListLayout")
scrollingLayout.FillDirection = Enum.FillDirection.Vertical
scrollingLayout.Padding = UDim.new(0, 5)
scrollingLayout.Parent = scrollingFrame

-- OBJECT ESP SECTION
local objectEspHeader = Instance.new("TextButton")
objectEspHeader.Name = "ObjectEspHeader"
objectEspHeader.Text = "Object ESP"
objectEspHeader.TextColor3 = Color3.new(1, 1, 1)
objectEspHeader.Font = Enum.Font.SourceSansBold
objectEspHeader.TextSize = 16
objectEspHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
objectEspHeader.Size = UDim2.new(0, 110, 0, 30)
objectEspHeader.Parent = contentFrame

local objectEspContent = Instance.new("Frame")
objectEspContent.Name = "ObjectEspContent"
objectEspContent.BackgroundTransparency = 1
objectEspContent.Size = UDim2.new(0, 200, 0, 80)
objectEspContent.Visible = false
objectEspContent.Parent = contentFrame

local objectEspLayout = Instance.new("UIListLayout")
objectEspLayout.FillDirection = Enum.FillDirection.Vertical
objectEspLayout.Padding = UDim.new(0, 5)
objectEspLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
objectEspLayout.Parent = objectEspContent

local objectEspRadiusBox = Instance.new("TextBox")
objectEspRadiusBox.Name = "RadiusBox"
objectEspRadiusBox.PlaceholderText = "ESP Radius (e.g., 500)"
objectEspRadiusBox.Text = "500"
objectEspRadiusBox.Font = Enum.Font.SourceSans
objectEspRadiusBox.TextSize = 16
objectEspRadiusBox.TextColor3 = Color3.new(1, 1, 1)
objectEspRadiusBox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
objectEspRadiusBox.Size = UDim2.new(0.9, 0, 0, 30)
objectEspRadiusBox.Parent = objectEspContent

local objectEspButton = Instance.new("TextButton")
objectEspButton.Name = "ObjectEspButton"
objectEspButton.Text = "ESP OFF"
objectEspButton.TextColor3 = Color3.new(1, 1, 1)
objectEspButton.Font = Enum.Font.SourceSansBold
objectEspButton.TextSize = 18
objectEspButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
objectEspButton.Size = UDim2.new(0.9, 0, 0, 40)
objectEspButton.Parent = objectEspContent

-- MONSTER ESP SECTION
local monsterEspHeader = Instance.new("TextButton")
monsterEspHeader.Name = "MonsterEspHeader"
monsterEspHeader.Text = "Monster ESP"
monsterEspHeader.TextColor3 = Color3.new(1, 1, 1)
monsterEspHeader.Font = Enum.Font.SourceSansBold
monsterEspHeader.TextSize = 16
monsterEspHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
monsterEspHeader.Size = UDim2.new(0, 110, 0, 30)
monsterEspHeader.Parent = contentFrame

local monsterEspContent = Instance.new("Frame")
monsterEspContent.Name = "MonsterEspContent"
monsterEspContent.BackgroundTransparency = 1
monsterEspContent.Size = UDim2.new(0, 200, 0, 175)
monsterEspContent.Visible = false
monsterEspContent.Parent = contentFrame

local monsterEspLayout = Instance.new("UIListLayout")
monsterEspLayout.FillDirection = Enum.FillDirection.Vertical
monsterEspLayout.Padding = UDim.new(0, 5)
monsterEspLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
monsterEspLayout.Parent = monsterEspContent

local monsterEspButton = Instance.new("TextButton")
monsterEspButton.Name = "MonsterEspButton"
monsterEspButton.Text = "ESP OFF"
monsterEspButton.TextColor3 = Color3.new(1, 1, 1)
monsterEspButton.Font = Enum.Font.SourceSansBold
monsterEspButton.TextSize = 18
monsterEspButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
monsterEspButton.Size = UDim2.new(0.9, 0, 0, 40)
monsterEspButton.Parent = monsterEspContent

local monsterFreezerButton = Instance.new("TextButton")
monsterFreezerButton.Name = "MonsterFreezerButton"
monsterFreezerButton.Text = "Freeze Monsters"
monsterFreezerButton.TextColor3 = Color3.new(1, 1, 1)
monsterFreezerButton.Font = Enum.Font.SourceSansBold
monsterFreezerButton.TextSize = 18
monsterFreezerButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
monsterFreezerButton.Size = UDim2.new(0.9, 0, 0, 40)
monsterFreezerButton.Parent = monsterEspContent

local damageNullifierButton = Instance.new("TextButton")
damageNullifierButton.Name = "DamageNullifierButton"
damageNullifierButton.Text = "Damage Nullifier"
damageNullifierButton.TextColor3 = Color3.new(1, 1, 1)
damageNullifierButton.Font = Enum.Font.SourceSansBold
damageNullifierButton.TextSize = 18
damageNullifierButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
damageNullifierButton.Size = UDim2.new(0.9, 0, 0, 40)
damageNullifierButton.Parent = monsterEspContent

-- REMOTE SHOP SECTION
local remoteShopHeader = Instance.new("TextButton")
remoteShopHeader.Name = "RemoteShopHeader"
remoteShopHeader.Text = "Remote Shop"
remoteShopHeader.TextColor3 = Color3.new(1, 1, 1)
remoteShopHeader.Font = Enum.Font.SourceSansBold
remoteShopHeader.TextSize = 16
remoteShopHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
remoteShopHeader.Size = UDim2.new(0, 110, 0, 30)
remoteShopHeader.Parent = contentFrame

local remoteShopContent = Instance.new("Frame")
remoteShopContent.Name = "RemoteShopContent"
remoteShopContent.BackgroundTransparency = 1
remoteShopContent.Size = UDim2.new(0, 200, 0, 180)
remoteShopContent.Visible = false
remoteShopContent.Parent = contentFrame

local remoteShopLayout = Instance.new("UIListLayout")
remoteShopLayout.FillDirection = Enum.FillDirection.Vertical
remoteShopLayout.Padding = UDim.new(0, 5)
remoteShopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
remoteShopLayout.Parent = remoteShopContent

-- VISUALS SECTION
local visualsHeader = Instance.new("TextButton")
visualsHeader.Name = "VisualsHeader"
visualsHeader.Text = "Visuals"
visualsHeader.TextColor3 = Color3.new(1, 1, 1)
visualsHeader.Font = Enum.Font.SourceSansBold
visualsHeader.TextSize = 16
visualsHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
visualsHeader.Size = UDim2.new(0, 110, 0, 30)
visualsHeader.Parent = contentFrame

local visualsContent = Instance.new("Frame")
visualsContent.Name = "VisualsContent"
visualsContent.BackgroundTransparency = 1
visualsContent.Size = UDim2.new(0, 200, 0, 50)
visualsContent.Visible = false
visualsContent.Parent = contentFrame

local visualsLayout = Instance.new("UIListLayout")
visualsLayout.FillDirection = Enum.FillDirection.Vertical
visualsLayout.Padding = UDim.new(0, 5)
visualsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
visualsLayout.Parent = visualsContent

local brightMapButton = Instance.new("TextButton")
brightMapButton.Name = "BrightMapButton"
brightMapButton.Text = "Auto Bright Map"
brightMapButton.TextColor3 = Color3.new(1, 1, 1)
brightMapButton.Font = Enum.Font.SourceSansBold
brightMapButton.TextSize = 18
brightMapButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
brightMapButton.Size = UDim2.new(0.9, 0, 0, 40)
brightMapButton.Parent = visualsContent

-- Set up content positions (horizontal)
local function updateContentPositions()
    local xOffset = 0
    for i, header in ipairs(contentFrame:GetChildren()) do
        if header:IsA("TextButton") then
            local content = contentFrame:FindFirstChild(header.Name:gsub("Header", "Content"))
            if content then
                content.Position = UDim2.new(0, xOffset, 0, 35)
                xOffset = xOffset + header.Size.X.Offset + 5
            end
        end
    end
end
updateContentPositions()


--------------------------------------------------------------------------------
-- DRAGGING AND GUI CONTROL LOGIC
--------------------------------------------------------------------------------
local isDragging = false
local dragStartPos = nil

-- Dictionary to manage collapsed state
local sections = {
    Finder = {header = finderHeader, content = finderContent, size = finderContent.Size},
    ObjectEsp = {header = objectEspHeader, content = objectEspContent, size = objectEspContent.Size},
    MonsterEsp = {header = monsterEspHeader, content = monsterEspContent, size = monsterEspContent.Size},
    RemoteShop = {header = remoteShopHeader, content = remoteShopContent, size = remoteShopContent.Size},
    Visuals = {header = visualsHeader, content = visualsContent, size = visualsContent.Size}
}

local function toggleSection(sectionName)
    local section = sections[sectionName]
    local isVisible = section.content.Visible
    section.content.Visible = not isVisible
    updateContentPositions()
end

for name, section in pairs(sections) do
    section.header.MouseButton1Click:Connect(function()
        toggleSection(name)
    end)
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = input.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        mainFrame.Position = mainFrame.Position + UDim2.new(0, delta.X, 0, delta.Y)
        dragStartPos = input.Position
    end
end)

local isMinimized = false
minMaxButton.MouseButton1Click:Connect(function()
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 240, 0, 110), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
        contentFrame.Visible = true
        minMaxButton.Text = "-"
    else
        mainFrame:TweenSize(UDim2.new(0, 240, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
        contentFrame.Visible = false
        minMaxButton.Text = "◻"
    end
    isMinimized = not isMinimized
end)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

--------------------------------------------------------------------------------
-- RGB OUTLINE ANIMATION
--------------------------------------------------------------------------------
local function runRGB()
    local colorTransitionSpeed = 0.005
    local hue = 0
    while true do
        hue = hue + colorTransitionSpeed
        if hue > 1 then hue = 0 end
        local color = Color3.fromHSV(hue, 1, 1)
        mainStroke.Color = color
        RunService.Heartbeat:Wait()
    end
end
spawn(runRGB)

--------------------------------------------------------------------------------
-- CORE FUNCTIONALITY
--------------------------------------------------------------------------------

local function createESP(object, color)
    local esp = Instance.new("BillboardGui")
    esp.Name = "ESP"
    esp.Adornee = object
    esp.Size = UDim2.new(0, 150, 0, 50)
    esp.ExtentsOffset = Vector3.new(0, object:IsA("BasePart") and object.Size.Y / 2 + 1 or 0, 0)
    esp.AlwaysOnTop = true
    esp.StudsOffset = Vector3.new(0, 10, 0)

    local label = Instance.new("TextLabel")
    label.Text = "Detecting..."
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextColor3 = color
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Parent = esp

    esp.Parent = object
    return esp, label
end

local function teleportTo(object)
    if not object or not humanoidRootPart then return end
    
    local teleportPosition
    if object:IsA("BasePart") then
        teleportPosition = object.Position
    elseif object:IsA("Model") and object.PrimaryPart then
        teleportPosition = object.PrimaryPart.Position
    else
        teleportPosition = object.Position
    end

    local newPosition = teleportPosition + Vector3.new(0, 5, 0)
    humanoidRootPart.CFrame = CFrame.new(newPosition)
end

local function findObjects(nameList)
    local results = {}
    for _, child in ipairs(workspace:GetDescendants()) do
        for _, name in ipairs(nameList) do
            if child.Name:lower():find(name:lower()) and (child:IsA("BasePart") or (child:IsA("Model") and child.PrimaryPart)) then
                table.insert(results, child)
                break
            end
        end
    end
    return results
end

local function populateList(objects)
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child.Name == "ListItem" then
            child:Destroy()
        end
    end
    
    foundObjects = objects

    if #objects == 0 then
        statusLabel.Text = "No objects found."
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        return
    end

    for _, object in ipairs(objects) do
        local newButton = Instance.new("TextButton")
        newButton.Name = "ListItem"
        newButton.Text = object.Name
        newButton.TextColor3 = Color3.new(1, 1, 1)
        newButton.Font = Enum.Font.SourceSans
        newButton.TextSize = 14
        newButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        newButton.Size = UDim2.new(1, -5, 0, 30)
        newButton.Parent = scrollingFrame

        newButton.MouseButton1Click:Connect(function()
            teleportTo(object)
            statusLabel.Text = "Teleported to " .. object.Name .. "!"
        end)
    end

    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #objects * (30 + 5))
    statusLabel.Text = "Found " .. #objects .. " objects. Select one to teleport."
end

-- Nullify Damage function for player (now a toggle)
local function nullifyDamage(enabled)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if enabled then
        if not originalTakeDamage[humanoid] then
            originalTakeDamage[humanoid] = humanoid.TakeDamage
            humanoid.TakeDamage = function() end
            statusLabel.Text = "All damage nullified."
        end
    else
        if originalTakeDamage[humanoid] then
            humanoid.TakeDamage = originalTakeDamage[humanoid]
            originalTakeDamage[humanoid] = nil
            statusLabel.Text = "Damage restored."
        end
    end
end

-- Remote Shop function
local function openShop(shopName)
    local shopData = shopList[shopName]
    if not shopData then
        statusLabel.Text = "Shop '" .. shopName .. "' not found."
        return
    end

    -- Attempt to find and fire a RemoteEvent
    local remoteEvent = ReplicatedStorage:FindFirstChild(shopData.eventName)
    if remoteEvent and remoteEvent:IsA("RemoteEvent") then
        if shopData.eventParameter then
            remoteEvent:FireServer(shopData.eventParameter)
        else
            remoteEvent:FireServer()
        end
        statusLabel.Text = "Trying to open " .. shopName .. "..."
    else
        statusLabel.Text = "Failed to find remote event for " .. shopName .. "."
    end
end

-- Freeze Monsters function
local function freezeMonsters(enabled)
    if enabled then
        local monsterFound = false
        for _, monster in ipairs(foundMonsters) do
            local humanoid = monster:FindFirstChildOfClass("Humanoid")
            if humanoid and not originalMonsterWalkspeeds[humanoid] then
                originalMonsterWalkspeeds[humanoid] = humanoid.WalkSpeed
                humanoid.WalkSpeed = 0
                monsterFound = true
            end
        end
        if not monsterFound then
            statusLabel.Text = "No monsters to freeze."
        else
            statusLabel.Text = "Monsters are frozen."
        end
    else
        for humanoid, originalSpeed in pairs(originalMonsterWalkspeeds) do
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = originalSpeed
            end
        end
        originalMonsterWalkspeeds = {}
        statusLabel.Text = "Monsters are unfrozen."
    end
end

-- Auto Bright Map function
local function autoBrightMap(enabled)
    if enabled then
        originalLightingProperties.Brightness = Lighting.Brightness
        originalLightingProperties.Ambient = Lighting.Ambient
        originalLightingProperties.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLightingProperties.ClockTime = Lighting.ClockTime
        
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(0.6, 0.6, 0.6)
        Lighting.OutdoorAmbient = Color3.new(0.6, 0.6, 0.6)
        Lighting.ClockTime = 12
        statusLabel.Text = "Auto bright map enabled."
    else
        Lighting.Brightness = originalLightingProperties.Brightness
        Lighting.Ambient = originalLightingProperties.Ambient
        Lighting.OutdoorAmbient = originalLightingProperties.OutdoorAmbient
        Lighting.ClockTime = originalLightingProperties.ClockTime
        statusLabel.Text = "Auto bright map disabled."
    end
end

-- Create buttons for each shop
for name, data in pairs(shopList) do
    local shopButton = Instance.new("TextButton")
    shopButton.Name = "ShopButton_" .. name:gsub(" ", "")
    shopButton.Text = "Open " .. name
    shopButton.TextColor3 = Color3.new(1, 1, 1)
    shopButton.Font = Enum.Font.SourceSansBold
    shopButton.TextSize = 18
    shopButton.BackgroundColor3 = Color3.new(0.3, 0.6, 0.9)
    shopButton.Size = UDim2.new(0.9, 0, 0, 40)
    shopButton.Parent = remoteShopContent

    shopButton.MouseButton1Click:Connect(function()
        openShop(name)
    end)
end

-- Main Button Logic
findButton.MouseButton1Click:Connect(function()
    local searchTerm = searchBox.Text
    if searchTerm == "" then
        statusLabel.Text = "Please enter a search term."
        return
    end

    findButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    findButton.Text = "Searching..."
    
    searchObjectNames = {searchTerm}
    local objects = findObjects(searchObjectNames)
    populateList(objects)

    findButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.8)
    findButton.Text = "Find Objects"
end)

objectEspButton.MouseButton1Click:Connect(function()
    if isObjectEspEnabled then
        isObjectEspEnabled = false
        objectEspButton.Text = "ESP OFF"
        objectEspButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
    else
        local newRadius = tonumber(objectEspRadiusBox.Text)
        if newRadius and newRadius > 0 then
            objectEspRadius = newRadius
        else
            statusLabel.Text = "Invalid ESP Radius!"
            return
        end

        isObjectEspEnabled = true
        objectEspButton.Text = "ESP ON"
        objectEspButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
    end
end)

monsterEspButton.MouseButton1Click:Connect(function()
    if isMonsterEspEnabled then
        isMonsterEspEnabled = false
        monsterEspButton.Text = "ESP OFF"
        monsterEspButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        
        for _, monster in ipairs(foundMonsters) do
            local existingEsp = monster:FindFirstChild("ESP")
            if existingEsp then
                existingEsp:Destroy()
            end
        end
    else
        isMonsterEspEnabled = true
        monsterEspButton.Text = "ESP ON"
        monsterEspButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)

        foundMonsters = findObjects(searchMonsterNames)
    end
end)

monsterFreezerButton.MouseButton1Click:Connect(function()
    isMonsterFrozen = not isMonsterFrozen
    if isMonsterFrozen then
        monsterFreezerButton.Text = "Monsters Frozen"
        monsterFreezerButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        freezeMonsters(true)
    else
        monsterFreezerButton.Text = "Freeze Monsters"
        monsterFreezerButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        freezeMonsters(false)
    end
end)

damageNullifierButton.MouseButton1Click:Connect(function()
    isDamageNullified = not isDamageNullified
    if isDamageNullified then
        damageNullifierButton.Text = "Damage Nullified ON"
        damageNullifierButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        nullifyDamage(true)
    else
        damageNullifierButton.Text = "Damage Nullifier OFF"
        damageNullifierButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        nullifyDamage(false)
    end
end)

brightMapButton.MouseButton1Click:Connect(function()
    isAutoBrightEnabled = not isAutoBrightEnabled
    if isAutoBrightEnabled then
        brightMapButton.Text = "Bright Map ON"
        brightMapButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        autoBrightMap(true)
    else
        brightMapButton.Text = "Auto Bright Map OFF"
        brightMapButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        autoBrightMap(false)
    end
end)

-- Heartbeat loop for dynamic ESP and Monster Freezer
RunService.Heartbeat:Connect(function()
    if not humanoidRootPart then return end
    
    local myPosition = humanoidRootPart.Position
    
    -- Object ESP
    if isObjectEspEnabled then
        for _, object in ipairs(foundObjects) do
            if object and object.Parent then
                local distance = (object.Position - myPosition).magnitude
                local existingEsp = object:FindFirstChild("ESP")

                if distance <= objectEspRadius then
                    if not existingEsp then
                        local esp, label = createESP(object, Color3.new(0, 1, 0))
                        label.Text = string.format("%s (%.1f)", object.Name, distance)
                    else
                        local label = existingEsp:FindFirstChildOfClass("TextLabel")
                        if label then
                            label.Text = string.format("%s (%.1f)", object.Name, distance)
                        end
                    end
                else
                    if existingEsp then
                        existingEsp:Destroy()
                    end
                end
            end
        end
    end
    
    -- Monster ESP
    if isMonsterEspEnabled then
        for _, monster in ipairs(foundMonsters) do
            if monster and monster.Parent then
                local position = monster:IsA("Model") and monster.PrimaryPart and monster.PrimaryPart.Position or monster.Position
                local distance = (position - myPosition).magnitude
                
                local existingEsp = monster:FindFirstChild("ESP")
                if distance <= monsterEspRadius then
                    if not existingEsp then
                        local esp, label = createESP(monster, Color3.new(1, 0, 0))
                        label.Text = string.format("%s (%.1f)", monster.Name, distance)
                    else
                        local label = existingEsp:FindFirstChildOfClass("TextLabel")
                        if label then
                            label.Text = string.format("%s (%.1f)", monster.Name, distance)
                        end
                    end
                else
                    if existingEsp then
                        existingEsp:Destroy()
                    end
                end
            end
        end
    end
end)

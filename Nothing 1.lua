--! Delta Script: Lithos Mining Tools By Gustiolodeh
-- Discord: gustiolodeh

--[[
    Versi skrip ini telah diperbarui dengan fitur-fitur berikut:
    - Smart TP Walk yang stabil dan mengikuti pergerakan pemain.
    - Fly Mode untuk terbang bebas.
    - Kedua fitur dapat diaktifkan/dinonaktifkan dan dikustomisasi.
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
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Configurable lists for searching
local searchObjectNames = {}
local foundObjects = {}

local searchMonsterNames = {"Deep Mimic", "Lush Rock Person", "Mimic", "Rock Person"}
local foundMonsters = {}

-- Initial settings
local isObjectEspEnabled = false
local objectEspRadius = 500
local isMonsterEspEnabled = false
local isDamageNullified = false
local isMonsterFrozen = false
local isAutoBrightEnabled = false
local isAutoMiningEnabled = false
local isTpwalkEnabled = false
local isFlyEnabled = false

local originalLightingProperties = {}
local originalMonsterWalkspeeds = {}
local originalTakeDamage = {}

local espConnection = nil
local monsterEspRadius = 500
local autoMiningRadius = 150
local autoMiningWait = 0.5

-- Waypoint storage
local waypoints = {}
local searchTerm = ""

-- TPWALK Variables
local TpwalkValue = 1
local TpwalkConnection = nil
local TpwalkNegativeValues = false

-- FLY Variables
local FlySpeed = 20
local FlyConnection = nil
local originalWalkSpeed = humanoid.WalkSpeed

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
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
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
titleLabel.Text = "Lithos Mining Tools"
titleLabel.TextColor3 = Color3.new(1, 1, 1) -- Ini akan diganti
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0.5, 0, 0.5, -10)
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
titleLabel.Parent = topBar

local creditLabel = Instance.new("TextLabel")
creditLabel.Name = "CreditLabel"
creditLabel.Text = "By Gustiolodeh"
creditLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
creditLabel.Font = Enum.Font.SourceSans
creditLabel.TextSize = 12
creditLabel.BackgroundTransparency = 1
creditLabel.Position = UDim2.new(0.5, 0, 0.5, 5)
creditLabel.AnchorPoint = Vector2.new(0.5, 0.5)
creditLabel.Parent = topBar

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

-- Konten utama sekarang berada di dalam ScrollingFrame
local contentScrollingFrame = Instance.new("ScrollingFrame")
contentScrollingFrame.Name = "ContentScrollingFrame"
contentScrollingFrame.BackgroundTransparency = 1
contentScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
contentScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
contentScrollingFrame.BorderSizePixel = 0
contentScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
contentScrollingFrame.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.BackgroundTransparency = 1
contentFrame.Size = UDim2.new(1, -20, 1, 0) -- -20 agar ada ruang untuk scrollbar
contentFrame.Position = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = contentScrollingFrame

local verticalLayout = Instance.new("UIListLayout")
verticalLayout.FillDirection = Enum.FillDirection.Vertical
verticalLayout.Padding = UDim.new(0, 5)
verticalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
verticalLayout.Parent = contentFrame

-- WAYPOINT MANAGER SECTION
local waypointHeader = Instance.new("TextButton")
waypointHeader.Name = "WaypointHeader"
waypointHeader.Text = "Waypoint Manager"
waypointHeader.TextColor3 = Color3.new(1, 1, 1)
waypointHeader.Font = Enum.Font.SourceSansBold
waypointHeader.TextSize = 16
waypointHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
waypointHeader.Size = UDim2.new(1, 0, 0, 30)
waypointHeader.Parent = contentFrame

local waypointContent = Instance.new("Frame")
waypointContent.Name = "WaypointContent"
waypointContent.BackgroundTransparency = 1
waypointContent.Size = UDim2.new(1, 0, 0, 250)
waypointContent.Visible = false
waypointContent.Parent = contentFrame

local waypointLayout = Instance.new("UIListLayout")
waypointLayout.FillDirection = Enum.FillDirection.Vertical
waypointLayout.Padding = UDim.new(0, 5)
waypointLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
waypointLayout.Parent = waypointContent

local waypointNameBox = Instance.new("TextBox")
waypointNameBox.Name = "WaypointNameBox"
waypointNameBox.PlaceholderText = "Enter waypoint name"
waypointNameBox.Text = ""
waypointNameBox.Font = Enum.Font.SourceSans
waypointNameBox.TextSize = 16
waypointNameBox.TextColor3 = Color3.new(1, 1, 1)
waypointNameBox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
waypointNameBox.Size = UDim2.new(0.9, 0, 0, 30)
waypointNameBox.Parent = waypointContent

local addWaypointButton = Instance.new("TextButton")
addWaypointButton.Name = "AddWaypointButton"
addWaypointButton.Text = "Add Current Location"
addWaypointButton.TextColor3 = Color3.new(1, 1, 1)
addWaypointButton.Font = Enum.Font.SourceSansBold
addWaypointButton.TextSize = 18
addWaypointButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
addWaypointButton.Size = UDim2.new(0.9, 0, 0, 40)
addWaypointButton.Parent = waypointContent

local waypointListScrollingFrame = Instance.new("ScrollingFrame")
waypointListScrollingFrame.Name = "WaypointList"
waypointListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
waypointListScrollingFrame.Size = UDim2.new(0.9, 0, 1, -80)
waypointListScrollingFrame.BackgroundTransparency = 1
waypointListScrollingFrame.BorderColor3 = Color3.new(0, 0, 0)
waypointListScrollingFrame.BorderSizePixel = 1
waypointListScrollingFrame.Parent = waypointContent

local waypointListLayout = Instance.new("UIListLayout")
waypointListLayout.FillDirection = Enum.FillDirection.Vertical
waypointListLayout.Padding = UDim.new(0, 5)
waypointListLayout.Parent = waypointListScrollingFrame

-- FINDER SECTION
local finderHeader = Instance.new("TextButton")
finderHeader.Name = "FinderHeader"
finderHeader.Text = "Object Finder"
finderHeader.TextColor3 = Color3.new(1, 1, 1)
finderHeader.Font = Enum.Font.SourceSansBold
finderHeader.TextSize = 16
finderHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
finderHeader.Size = UDim2.new(1, 0, 0, 30)
finderHeader.Parent = contentFrame

local finderContent = Instance.new("Frame")
finderContent.Name = "FinderContent"
finderContent.BackgroundTransparency = 1
finderContent.Size = UDim2.new(1, 0, 0, 250)
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

-- Auto Mine button
local autoMineButton = Instance.new("TextButton")
autoMineButton.Name = "AutoMineButton"
autoMineButton.Text = "Auto Mine OFF"
autoMineButton.TextColor3 = Color3.new(1, 1, 1)
autoMineButton.Font = Enum.Font.SourceSansBold
autoMineButton.TextSize = 18
autoMineButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
autoMineButton.Size = UDim2.new(0.9, 0, 0, 40)
autoMineButton.Parent = finderContent

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
scrollingFrame.Size = UDim2.new(0.9, 0, 1, -160)
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
objectEspHeader.Size = UDim2.new(1, 0, 0, 30)
objectEspHeader.Parent = contentFrame

local objectEspContent = Instance.new("Frame")
objectEspContent.Name = "ObjectEspContent"
objectEspContent.BackgroundTransparency = 1
objectEspContent.Size = UDim2.new(1, 0, 0, 80)
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
monsterEspHeader.Size = UDim2.new(1, 0, 0, 30)
monsterEspHeader.Parent = contentFrame

local monsterEspContent = Instance.new("Frame")
monsterEspContent.Name = "MonsterEspContent"
monsterEspContent.BackgroundTransparency = 1
monsterEspContent.Size = UDim2.new(1, 0, 0, 175)
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

-- VISUALS SECTION
local visualsHeader = Instance.new("TextButton")
visualsHeader.Name = "VisualsHeader"
visualsHeader.Text = "Visuals"
visualsHeader.TextColor3 = Color3.new(1, 1, 1)
visualsHeader.Font = Enum.Font.SourceSansBold
visualsHeader.TextSize = 16
visualsHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
visualsHeader.Size = UDim2.new(1, 0, 0, 30)
visualsHeader.Parent = contentFrame

local visualsContent = Instance.new("Frame")
visualsContent.Name = "VisualsContent"
visualsContent.BackgroundTransparency = 1
visualsContent.Size = UDim2.new(1, 0, 0, 50)
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

-- PLAYER FEATURES SECTION
local playerFeaturesHeader = Instance.new("TextButton")
playerFeaturesHeader.Name = "PlayerFeaturesHeader"
playerFeaturesHeader.Text = "Player Features"
playerFeaturesHeader.TextColor3 = Color3.new(1, 1, 1)
playerFeaturesHeader.Font = Enum.Font.SourceSansBold
playerFeaturesHeader.TextSize = 16
playerFeaturesHeader.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
playerFeaturesHeader.Size = UDim2.new(1, 0, 0, 30)
playerFeaturesHeader.Parent = contentFrame

local playerFeaturesContent = Instance.new("Frame")
playerFeaturesContent.Name = "PlayerFeaturesContent"
playerFeaturesContent.BackgroundTransparency = 1
playerFeaturesContent.Size = UDim2.new(1, 0, 0, 240)
playerFeaturesContent.Visible = false
playerFeaturesContent.Parent = contentFrame

local playerFeaturesLayout = Instance.new("UIListLayout")
playerFeaturesLayout.FillDirection = Enum.FillDirection.Vertical
playerFeaturesLayout.Padding = UDim.new(0, 5)
playerFeaturesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerFeaturesLayout.Parent = playerFeaturesContent

-- FLY Mode
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"
flyButton.Text = "Fly OFF"
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Font = Enum.Font.SourceSansBold
flyButton.TextSize = 18
flyButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
flyButton.Size = UDim2.new(0.9, 0, 0, 40)
flyButton.Parent = playerFeaturesContent

-- TPWALK Section
local tpwalkLabel = Instance.new("TextLabel")
tpwalkLabel.Name = "TpwalkValueLabel"
tpwalkLabel.Text = "TPWALK Value: 1"
tpwalkLabel.TextColor3 = Color3.new(1, 1, 1)
tpwalkLabel.Font = Enum.Font.SourceSansBold
tpwalkLabel.TextSize = 16
tpwalkLabel.BackgroundTransparency = 1
tpwalkLabel.Size = UDim2.new(0.9, 0, 0, 20)
tpwalkLabel.Parent = playerFeaturesContent

local tpwalkValueBox = Instance.new("TextBox")
tpwalkValueBox.Name = "TpwalkValueBox"
tpwalkValueBox.PlaceholderText = "TPWALK Value (e.g., 5)"
tpwalkValueBox.Text = "1"
tpwalkValueBox.Font = Enum.Font.SourceSans
tpwalkValueBox.TextSize = 16
tpwalkValueBox.TextColor3 = Color3.new(1, 1, 1)
tpwalkValueBox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
tpwalkValueBox.Size = UDim2.new(0.9, 0, 0, 30)
tpwalkValueBox.Parent = playerFeaturesContent

local tpwalkButton = Instance.new("TextButton")
tpwalkButton.Name = "TpwalkButton"
tpwalkButton.Text = "TPWALK OFF"
tpwalkButton.TextColor3 = Color3.new(1, 1, 1)
tpwalkButton.Font = Enum.Font.SourceSansBold
tpwalkButton.TextSize = 18
tpwalkButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
tpwalkButton.Size = UDim2.new(0.9, 0, 0, 40)
tpwalkButton.Parent = playerFeaturesContent

local tpwalkNegativeButton = Instance.new("TextButton")
tpwalkNegativeButton.Name = "TpwalkNegativeButton"
tpwalkNegativeButton.Text = "Negative Values OFF"
tpwalkNegativeButton.TextColor3 = Color3.new(1, 1, 1)
tpwalkNegativeButton.Font = Enum.Font.SourceSansBold
tpwalkNegativeButton.TextSize = 18
tpwalkNegativeButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
tpwalkNegativeButton.Size = UDim2.new(0.9, 0, 0, 40)
tpwalkNegativeButton.Parent = playerFeaturesContent

-- Add a resizable corner button
local resizeButton = Instance.new("TextButton")
resizeButton.Name = "ResizeButton"
resizeButton.Text = "" -- Tanpa teks
resizeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
resizeButton.Size = UDim2.new(0, 15, 0, 15)
resizeButton.Position = UDim2.new(1, -15, 1, -15)
resizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
resizeButton.ZIndex = 2
resizeButton.Parent = mainFrame

-- Character Status Display
local statusDisplay = Instance.new("TextLabel")
statusDisplay.Name = "StatusDisplay"
statusDisplay.Text = "Loading..."
statusDisplay.TextColor3 = Color3.new(1, 1, 1)
statusDisplay.TextSize = 16
statusDisplay.Font = Enum.Font.SourceSans
statusDisplay.Size = UDim2.new(0.4, 0, 0, 60)
statusDisplay.Position = UDim2.new(0.5, 0, 0.05, 0)
statusDisplay.AnchorPoint = Vector2.new(0.5, 0)
statusDisplay.BackgroundTransparency = 0.8
statusDisplay.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
statusDisplay.TextWrapped = true
statusDisplay.Parent = screenGui

--------------------------------------------------------------------------------
-- DRAGGING AND GUI CONTROL LOGIC
--------------------------------------------------------------------------------
local isDragging = false
local dragStartPos = nil
local isResizing = false
local resizeStartSize = nil
local resizeStartPos = nil

-- Dictionary to manage collapsed state
local sections = {
    Waypoint = {header = waypointHeader, content = waypointContent, size = waypointContent.Size},
    Finder = {header = finderHeader, content = finderContent, size = finderContent.Size},
    ObjectEsp = {header = objectEspHeader, content = objectEspContent, size = objectEspContent.Size},
    MonsterEsp = {header = monsterEspHeader, content = monsterEspContent, size = monsterEspContent.Size},
    Visuals = {header = visualsHeader, content = visualsContent, size = visualsContent.Size},
    PlayerFeatures = {header = playerFeaturesHeader, content = playerFeaturesContent, size = playerFeaturesContent.Size},
}

local function updateContentHeight()
    local totalHeight = 0
    -- Add the height of each section header and content frame if visible
    for _, section in pairs(sections) do
        totalHeight = totalHeight + section.header.Size.Y.Offset + verticalLayout.Padding.Offset
        if section.content.Visible then
            totalHeight = totalHeight + section.content.Size.Y.Offset + verticalLayout.Padding.Offset
        end
    end
    -- Set CanvasSize of ScrollingFrame
    contentScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

local function toggleSection(sectionName)
    local section = sections[sectionName]
    local isVisible = section.content.Visible
    section.content.Visible = not isVisible
    updateContentHeight()
end

for name, section in pairs(sections) do
    section.header.MouseButton1Click:Connect(function()
        toggleSection(name)
    end)
end

-- Dragging logic
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = input.Position
    end
end)

-- Resizing logic
resizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        resizeStartSize = mainFrame.AbsoluteSize
        resizeStartPos = input.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
        isResizing = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        mainFrame.Position = mainFrame.Position + UDim2.new(0, delta.X, 0, delta.Y)
        dragStartPos = input.Position
    elseif isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStartPos
        local newSizeX = math.max(150, resizeStartSize.X + delta.X)
        local newSizeY = math.max(100, resizeStartSize.Y + delta.Y)
        mainFrame.Size = UDim2.new(0, newSizeX, 0, newSizeY)
    end
end)

local isMinimized = false
minMaxButton.MouseButton1Click:Connect(function()
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, mainFrame.AbsoluteSize.X, 0, 300), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
        contentScrollingFrame.Visible = true
        resizeButton.Visible = true
        minMaxButton.Text = "-"
    else
        mainFrame:TweenSize(UDim2.new(0, mainFrame.AbsoluteSize.X, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
        contentScrollingFrame.Visible = false
        resizeButton.Visible = false
        minMaxButton.Text = "◻"
    end
    isMinimized = not isMinimized
end)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

--------------------------------------------------------------------------------
-- RGB OUTLINE AND TITLE ANIMATION
--------------------------------------------------------------------------------
local function runRGB()
    local colorTransitionSpeed = 0.005
    local hue = 0
    while true do
        hue = hue + colorTransitionSpeed
        if hue > 1 then hue = 0 end
        local color = Color3.fromHSV(hue, 1, 1)
        mainStroke.Color = color
        titleLabel.TextColor3 = color -- Tambahkan baris ini
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

local function teleportToPosition(position)
    if not humanoidRootPart then return end
    
    local newPosition = position + Vector3.new(0, 5, 0)
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

local function populateObjectList(objects)
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

-- Freeze Monsters function
local function freezeMonsters(enabled)
    if enabled then
        local monsterFound = false
        for _, monster in ipairs(foundMonsters) do
            local monsterHumanoid = monster:FindFirstChildOfClass("Humanoid")
            if monsterHumanoid and not originalMonsterWalkspeeds[monsterHumanoid] then
                originalMonsterWalkspeeds[monsterHumanoid] = monsterHumanoid.WalkSpeed
                monsterHumanoid.WalkSpeed = 0
                monsterFound = true
            end
        end
        if not monsterFound then
            statusLabel.Text = "No monsters to freeze."
        else
            statusLabel.Text = "Monsters are frozen."
        end
    else
        for monsterHumanoid, originalSpeed in pairs(originalMonsterWalkspeeds) do
            if monsterHumanoid and monsterHumanoid.Parent then
                monsterHumanoid.WalkSpeed = originalSpeed
            end
        end
        originalMonsterWalkspeeds = {}
        statusLabel.Text = "Monsters are unfrozen."
    end
end

-- Auto Bright Map function
local function autoBrightMap(enabled)
    local success, err = pcall(function()
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
    end)
    if not success then
        statusLabel.Text = "Error applying lighting settings: " .. (err or "unknown error")
    end
end

-- Auto Mining function
local function autoMine()
    while isAutoMiningEnabled do
        local myPosition = humanoidRootPart.Position

        -- Find the closest mineable object
        local closestOre = nil
        local closestDistance = autoMiningRadius + 1

        local allMineableObjects = findObjects({searchTerm})
        for _, object in ipairs(allMineableObjects) do
            if object and object.Parent then
                local position = object:IsA("Model") and object.PrimaryPart and object.PrimaryPart.Position or object.Position
                local distance = (position - myPosition).magnitude

                if distance <= autoMiningRadius and distance < closestDistance then
                    closestOre = object
                    closestDistance = distance
                end
            end
        end

        if closestOre then
            statusLabel.Text = "Auto-mining " .. closestOre.Name .. "..."

            -- Find a suitable pickaxe
            local pickaxe = nil
            -- Check if character is already holding a pickaxe
            if character.Humanoid.Parent and character.Humanoid.Parent:FindFirstChildOfClass("Tool") and string.find(character.Humanoid.Parent:FindFirstChildOfClass("Tool").Name:lower(), "pickaxe") then
                pickaxe = character.Humanoid.Parent:FindFirstChildOfClass("Tool")
            else
                -- Search backpack
                for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
                    if string.find(tool.Name:lower(), "pickaxe") then
                        pickaxe = tool
                        break
                    end
                end
            end
            
            if pickaxe then
                -- Equip the pickaxe if not already equipped
                if character.Humanoid.Parent:FindFirstChild(pickaxe.Name) == nil then
                    character.Humanoid:EquipTool(pickaxe)
                    task.wait(0.2) -- Wait for equip animation
                end
                
                -- Teleport to the ore for instant mining
                local orePosition = closestOre:IsA("Model") and closestOre.PrimaryPart and closestOre.PrimaryPart.Position or closestOre.Position
                local teleportPos = orePosition + (humanoidRootPart.Position - orePosition).unit * 5
                humanoidRootPart.Cframe = CFrame.new(teleportPos, orePosition)
                
                -- Simulate attack
                pickaxe:Activate()
            else
                statusLabel.Text = "No pickaxe found in inventory or backpack."
                isAutoMiningEnabled = false
                autoMineButton.Text = "Auto Mine OFF"
                autoMineButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
            end
        else
            statusLabel.Text = "No " .. searchTerm .. " found within range. Waiting..."
            -- To avoid an infinite loop in case of no ores
            task.wait(1)
        end
        
        task.wait(autoMiningWait)
    end
end

-- Waypoint functions
local function populateWaypointList()
    for _, child in ipairs(waypointListScrollingFrame:GetChildren()) do
        if child.Name == "WaypointItem" then
            child:Destroy()
        end
    end
    
    local totalHeight = 0
    for name, pos in pairs(waypoints) do
        local waypointItem = Instance.new("Frame")
        waypointItem.Name = "WaypointItem"
        waypointItem.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
        waypointItem.Size = UDim2.new(1, 0, 0, 30)
        waypointItem.Parent = waypointListScrollingFrame
        
        local waypointNameLabel = Instance.new("TextLabel")
        waypointNameLabel.Text = name
        waypointNameLabel.TextColor3 = Color3.new(1, 1, 1)
        waypointNameLabel.Font = Enum.Font.SourceSans
        waypointNameLabel.TextSize = 14
        waypointNameLabel.BackgroundTransparency = 1
        waypointNameLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
        waypointNameLabel.AnchorPoint = Vector2.new(0, 0.5)
        waypointNameLabel.Parent = waypointItem
        
        local teleportButton = Instance.new("TextButton")
        teleportButton.Text = "Teleport"
        teleportButton.TextColor3 = Color3.new(1, 1, 1)
        teleportButton.Font = Enum.Font.SourceSansBold
        teleportButton.TextSize = 14
        teleportButton.BackgroundColor3 = Color3.new(0.3, 0.6, 0.9)
        teleportButton.Size = UDim2.new(0, 70, 0.8, 0)
        teleportButton.Position = UDim2.new(1, -145, 0.5, 0)
        teleportButton.AnchorPoint = Vector2.new(1, 0.5)
        teleportButton.Parent = waypointItem
        
        teleportButton.MouseButton1Click:Connect(function()
            teleportToPosition(pos)
            statusLabel.Text = "Teleported to " .. name .. "!"
        end)
        
        local deleteButton = Instance.new("TextButton")
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = Color3.new(1, 1, 1)
        deleteButton.Font = Enum.Font.SourceSansBold
        deleteButton.TextSize = 14
        deleteButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        deleteButton.Size = UDim2.new(0, 50, 0.8, 0)
        deleteButton.Position = UDim2.new(1, -85, 0.5, 0)
        deleteButton.AnchorPoint = Vector2.new(1, 0.5)
        deleteButton.Parent = waypointItem
        
        deleteButton.MouseButton1Click:Connect(function()
            waypoints[name] = nil
            populateWaypointList()
            statusLabel.Text = "Waypoint '" .. name .. "' deleted."
        end)

        totalHeight = totalHeight + waypointItem.Size.Y.Offset + waypointListLayout.Padding.Offset
    end
    
    waypointListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    updateContentHeight()
end

-- TPWALK and FLY functions
local function startTpwalk()
    if not TpwalkConnection then
        TpwalkConnection = RunService.Heartbeat:Connect(function()
            if isTpwalkEnabled and humanoid and humanoidRootPart then
                humanoidRootPart.CFrame += (humanoid.MoveDirection * TpwalkValue)
                humanoidRootPart.CanCollide = true
            end
        end)
    end
end

local function stopTpwalk()
    if TpwalkConnection then
        TpwalkConnection:Disconnect()
        TpwalkConnection = nil
        if humanoid and humanoidRootPart then
            humanoidRootPart.CanCollide = false
        end
    end
end

local function startFly()
    if not FlyConnection then
        FlyConnection = RunService.Heartbeat:Connect(function()
            if isFlyEnabled and humanoidRootPart then
                local moveDirection = UserInputService:GetMoveVector()
                local flyVector = Vector3.new(moveDirection.X, (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0), moveDirection.Z)
                humanoidRootPart.CFrame += CFrame.new(flyVector * FlySpeed)
            end
        end)
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end

local function stopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
        humanoid.WalkSpeed = originalWalkSpeed
        humanoid.JumpPower = humanoid.WalkSpeed
    end
end

-- Main Button Logic
addWaypointButton.MouseButton1Click:Connect(function()
    local name = waypointNameBox.Text
    if name == "" then
        statusLabel.Text = "Please enter a name for the waypoint."
        return
    end
    
    if waypoints[name] then
        statusLabel.Text = "Waypoint '" .. name .. "' already exists. Overwriting..."
    end
    
    waypoints[name] = humanoidRootPart.Position
    statusLabel.Text = "Waypoint '" .. name .. "' added!"
    populateWaypointList()
end)

findButton.MouseButton1Click:Connect(function()
    searchTerm = searchBox.Text
    if searchTerm == "" then
        statusLabel.Text = "Please enter a search term."
        return
    end

    findButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    findButton.Text = "Searching..."
    
    searchObjectNames = {searchTerm}
    local objects = findObjects(searchObjectNames)
    populateObjectList(objects)

    findButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.8)
    findButton.Text = "Find Objects"
end)

autoMineButton.MouseButton1Click:Connect(function()
    isAutoMiningEnabled = not isAutoMiningEnabled

    if isAutoMiningEnabled then
        autoMineButton.Text = "Auto Mine ON"
        autoMineButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        spawn(autoMine)
    else
        autoMineButton.Text = "Auto Mine OFF"
        autoMineButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        statusLabel.Text = "Auto mining stopped."
    end
end)


objectEspButton.MouseButton1Click:Connect(function()
    local newRadius = tonumber(objectEspRadiusBox.Text)
    if newRadius and newRadius > 0 then
        objectEspRadius = newRadius
    else
        statusLabel.Text = "Invalid ESP Radius! Setting to default."
        objectEspRadius = 500
        objectEspRadiusBox.Text = "500"
    end

    isObjectEspEnabled = not isObjectEspEnabled

    if isObjectEspEnabled then
        objectEspButton.Text = "ESP ON"
        objectEspButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
    else
        objectEspButton.Text = "ESP OFF"
        objectEspButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
    end
end)

monsterEspButton.MouseButton1Click:Connect(function()
    isMonsterEspEnabled = not isMonsterEspEnabled

    if isMonsterEspEnabled then
        monsterEspButton.Text = "ESP ON"
        monsterEspButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        foundMonsters = findObjects(searchMonsterNames)
    else
        monsterEspButton.Text = "ESP OFF"
        monsterEspButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        
        for _, monster in ipairs(foundMonsters) do
            local existingEsp = monster:FindFirstChild("ESP")
            if existingEsp then
                existingEsp:Destroy()
            end
        end
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

flyButton.MouseButton1Click:Connect(function()
    isFlyEnabled = not isFlyEnabled
    if isFlyEnabled then
        isTpwalkEnabled = false
        tpwalkButton.Text = "TPWALK OFF"
        tpwalkButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        stopTpwalk()
        
        flyButton.Text = "Fly ON"
        flyButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        startFly()
    else
        flyButton.Text = "Fly OFF"
        flyButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        stopFly()
    end
end)

tpwalkButton.MouseButton1Click:Connect(function()
    isTpwalkEnabled = not isTpwalkEnabled
    if isTpwalkEnabled then
        isFlyEnabled = false
        flyButton.Text = "Fly OFF"
        flyButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        stopFly()

        tpwalkButton.Text = "TPWALK ON"
        tpwalkButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        startTpwalk()
    else
        tpwalkButton.Text = "TPWALK OFF"
        tpwalkButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        stopTpwalk()
    end
end)

tpwalkValueBox.FocusLost:Connect(function()
    local inputValue = tonumber(tpwalkValueBox.Text)
    if inputValue then
        if not TpwalkNegativeValues and inputValue <= 0 then
            tpwalkValueBox.Text = "1"
            TpwalkValue = 1
        else
            TpwalkValue = inputValue
        end
        tpwalkLabel.Text = "TPWALK Value: " .. TpwalkValue
    else
        tpwalkValueBox.Text = tostring(TpwalkValue)
    end
end)

tpwalkNegativeButton.MouseButton1Click:Connect(function()
    TpwalkNegativeValues = not TpwalkNegativeValues
    if TpwalkNegativeValues then
        tpwalkNegativeButton.Text = "Negative Values ON"
        tpwalkNegativeButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
    else
        tpwalkNegativeButton.Text = "Negative Values OFF"
        tpwalkNegativeButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        if TpwalkValue < 0 then
            TpwalkValue = 1
            tpwalkValueBox.Text = "1"
            tpwalkLabel.Text = "TPWALK Value: 1"
        end
    end
end)

-- Heartbeat loop for dynamic ESP and Character Status
RunService.Heartbeat:Connect(function()
    if not humanoidRootPart or not humanoid then return end
    
    local myPosition = humanoidRootPart.Position
    local currentHealth = math.floor(humanoid.Health)
    local characterStatus = humanoid.Health > 0 and "Alive" or "Dead"
    
    -- Update status display
    statusDisplay.Text = string.format(
        "Posisi: X:%.1f, Y:%.1f, Z:%.1f\nDarah: %d\nStatus: %s",
        myPosition.X, myPosition.Y, myPosition.Z,
        currentHealth,
        characterStatus
    )
    
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


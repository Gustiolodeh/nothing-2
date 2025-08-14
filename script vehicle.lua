--[[
  Fixed Vehicle Teleport by OLODEH

  This is a revised version of the original script.
  - Removed non-standard file I/O functions (readfile/writefile) for wider compatibility.
    Teleport points are now saved only for the current session.
  - Refined the GetVehicle function to be more reliable.
  - Improved UI handling to fix minor visual bugs.
  - The most reliable teleport method is CFrame. BodyForce and BodyVelocity are included
    but may be unstable.

  Instructions:
  1. Paste this entire script into your executor.
  2. Execute the script.
  3. Use the GUI to control your vehicle's teleportation.
]]

-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CORE VARIABLES
local TeleportPoints = {}
local IsLooping = false
local IsMinimized = false
local LoopDelay = 5
local CurrentTeleportMethod = "CFrame" -- Default method
local TWEEN_INFO_FADE = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_INFO_MINMAX = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--===================================================================
-- GUI CREATION
--===================================================================
local MainScreenGui = Instance.new("ScreenGui")
MainScreenGui.Name = "UniversalTeleportGUI"
MainScreenGui.Parent = PlayerGui

local NotificationFrame = Instance.new("Frame")
NotificationFrame.Name = "NotificationFrame"
NotificationFrame.Size = UDim2.new(0, 250, 0, 60)
NotificationFrame.Position = UDim2.new(1, -260, 0, 10)
NotificationFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
NotificationFrame.BorderSizePixel = 0
NotificationFrame.BackgroundTransparency = 1
NotificationFrame.Visible = false
NotificationFrame.ZIndex = 10
NotificationFrame.Parent = MainScreenGui

local NotificationText = Instance.new("TextLabel")
NotificationText.Name = "NotificationText"
NotificationText.Size = UDim2.new(1, -20, 1, -10)
NotificationText.Position = UDim2.new(0, 10, 0, 5)
NotificationText.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
NotificationText.TextColor3 = Color3.new(1, 1, 1)
NotificationText.Text = ""
NotificationText.Font = Enum.Font.SourceSansBold
NotificationText.TextSize = 16
NotificationText.TextWrapped = true
NotificationText.TextYAlignment = Enum.TextYAlignment.Center
NotificationText.BackgroundTransparency = 1
NotificationText.Parent = NotificationFrame

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Parent = MainScreenGui

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.Text = "Vehicle Teleport by OLODEH"
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 18
TitleBar.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.Parent = TitleBar

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -10, 1, -40)
TabFrame.Position = UDim2.new(0, 5, 0, 35)
TabFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 0, 25)
FooterLabel.Position = UDim2.new(0, 0, 1, -25)
FooterLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
FooterLabel.TextColor3 = Color3.new(1, 1, 1)
FooterLabel.Text = "OLODEH"
FooterLabel.Font = Enum.Font.SourceSansBold
FooterLabel.TextSize = 14
FooterLabel.Parent = MainFrame

-- Tab Buttons
local TabButtonFrame = Instance.new("Frame")
TabButtonFrame.Size = UDim2.new(1, 0, 0, 30)
TabButtonFrame.Position = UDim2.new(0, 0, 0, 0)
TabButtonFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
TabButtonFrame.Parent = TabFrame

local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0.5, 0, 1, 0)
MainButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
MainButton.TextColor3 = Color3.new(1, 1, 1)
MainButton.Text = "Main"
MainButton.Font = Enum.Font.SourceSansBold
MainButton.TextSize = 16
MainButton.Parent = TabButtonFrame

local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0.5, 0, 1, 0)
SettingsButton.Position = UDim2.new(0.5, 0, 0, 0)
SettingsButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
SettingsButton.TextColor3 = Color3.new(1, 1, 1)
SettingsButton.Text = "Settings"
SettingsButton.Font = Enum.Font.SourceSansBold
SettingsButton.TextSize = 16
SettingsButton.Parent = TabButtonFrame

-- Main Tab Content
local MainFrameContent = Instance.new("Frame")
MainFrameContent.Name = "MainFrameContent"
MainFrameContent.Size = UDim2.new(1, 0, 1, -30)
MainFrameContent.Position = UDim2.new(0, 0, 0, 30)
MainFrameContent.BackgroundTransparency = 1
MainFrameContent.Parent = TabFrame

local PointNameInput = Instance.new("TextBox")
PointNameInput.Size = UDim2.new(1, -20, 0, 30)
PointNameInput.Position = UDim2.new(0, 10, 0, 5)
PointNameInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
PointNameInput.TextColor3 = Color3.new(1, 1, 1)
PointNameInput.PlaceholderText = "Enter point name..."
PointNameInput.Font = Enum.Font.SourceSans
PointNameInput.TextSize = 14
PointNameInput.ClearTextOnFocus = true
PointNameInput.Parent = MainFrameContent

local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(1, -20, 0, 30)
SaveButton.Position = UDim2.new(0, 10, 0, 40)
SaveButton.BackgroundColor3 = Color3.new(0, 0.6, 0.2)
SaveButton.TextColor3 = Color3.new(1, 1, 1)
SaveButton.Text = "Save Current Position"
SaveButton.Font = Enum.Font.SourceSansBold
SaveButton.TextSize = 16
SaveButton.Parent = MainFrameContent

local ClearAllButton = Instance.new("TextButton")
ClearAllButton.Size = UDim2.new(1, -20, 0, 30)
ClearAllButton.Position = UDim2.new(0, 10, 0, 75)
ClearAllButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
ClearAllButton.TextColor3 = Color3.new(1, 1, 1)
ClearAllButton.Text = "Clear All Points"
ClearAllButton.Font = Enum.Font.SourceSansBold
ClearAllButton.TextSize = 16
ClearAllButton.Parent = MainFrameContent

local TeleportMethodLabel = Instance.new("TextLabel")
TeleportMethodLabel.Size = UDim2.new(1, -20, 0, 20)
TeleportMethodLabel.Position = UDim2.new(0, 10, 0, 110)
TeleportMethodLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
TeleportMethodLabel.TextColor3 = Color3.new(1, 1, 1)
TeleportMethodLabel.Text = "Teleport Method:"
TeleportMethodLabel.Font = Enum.Font.SourceSansBold
TeleportMethodLabel.TextSize = 14
TeleportMethodLabel.TextXAlignment = Enum.TextXAlignment.Left
TeleportMethodLabel.Parent = MainFrameContent

local TeleportMethodButtons = Instance.new("Frame")
TeleportMethodButtons.Size = UDim2.new(1, -20, 0, 30)
TeleportMethodButtons.Position = UDim2.new(0, 10, 0, 135)
TeleportMethodButtons.BackgroundTransparency = 1
TeleportMethodButtons.Parent = MainFrameContent

local CFrameButton = Instance.new("TextButton")
CFrameButton.Name = "CFrame"
CFrameButton.Size = UDim2.new(1/3, -4, 1, 0)
CFrameButton.BackgroundColor3 = Color3.new(0, 0.5, 0.8)
CFrameButton.TextColor3 = Color3.new(1, 1, 1)
CFrameButton.Text = "CFrame"
CFrameButton.Font = Enum.Font.SourceSans
CFrameButton.TextSize = 14
CFrameButton.Parent = TeleportMethodButtons

local BodyForceButton = Instance.new("TextButton")
BodyForceButton.Name = "BodyForce"
BodyForceButton.Size = UDim2.new(1/3, -4, 1, 0)
BodyForceButton.Position = UDim2.new(1/3, 2, 0, 0)
BodyForceButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
BodyForceButton.TextColor3 = Color3.new(1, 1, 1)
BodyForceButton.Text = "BodyForce"
BodyForceButton.Font = Enum.Font.SourceSans
BodyForceButton.TextSize = 14
BodyForceButton.Parent = TeleportMethodButtons

local BodyVelocityButton = Instance.new("TextButton")
BodyVelocityButton.Name = "BodyVelocity"
BodyVelocityButton.Size = UDim2.new(1/3, -4, 1, 0)
BodyVelocityButton.Position = UDim2.new(2/3, 4, 0, 0)
BodyVelocityButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
BodyVelocityButton.TextColor3 = Color3.new(1, 1, 1)
BodyVelocityButton.Text = "BodyVelocity"
BodyVelocityButton.Font = Enum.Font.SourceSans
BodyVelocityButton.TextSize = 14
BodyVelocityButton.Parent = TeleportMethodButtons

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 1, -165)
StatusLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Text = "Status: Ready"
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrameContent

local LoopButton = Instance.new("TextButton")
LoopButton.Size = UDim2.new(1, -20, 0, 30)
LoopButton.Position = UDim2.new(0, 10, 1, -135)
LoopButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
LoopButton.TextColor3 = Color3.new(1, 1, 1)
LoopButton.Text = "Start Loop (Delay: " .. LoopDelay .. "s)"
LoopButton.Font = Enum.Font.SourceSansBold
LoopButton.TextSize = 16
LoopButton.Parent = MainFrameContent

local TabScrollView = Instance.new("ScrollingFrame")
TabScrollView.Size = UDim2.new(1, -10, 0, 100)
TabScrollView.Position = UDim2.new(0, 5, 1, -100)
TabScrollView.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
TabScrollView.BorderSizePixel = 0
TabScrollView.Parent = MainFrameContent
TabScrollView.CanvasSize = UDim2.new(0, 1, 0, 0)
TabScrollView.HorizontalScrollBarPosition = Enum.ScrollBarPosition.Left
TabScrollView.VerticalScrollBarEnabled = false

local PointListContainer = Instance.new("Frame")
PointListContainer.Name = "PointListContainer"
PointListContainer.Size = UDim2.new(0, 0, 1, 0)
PointListContainer.BackgroundTransparency = 1
PointListContainer.Parent = TabScrollView

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellSize = UDim2.new(0, 100, 0, 60)
UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
UIGridLayout.FillDirection = Enum.FillDirection.Horizontal
UIGridLayout.Parent = PointListContainer

-- Settings Tab Content
local SettingsFrameContent = Instance.new("Frame")
SettingsFrameContent.Name = "SettingsFrameContent"
SettingsFrameContent.Size = UDim2.new(1, 0, 1, -30)
SettingsFrameContent.Position = UDim2.new(0, 0, 0, 30)
SettingsFrameContent.BackgroundTransparency = 1
SettingsFrameContent.Visible = false
SettingsFrameContent.Parent = TabFrame

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 80, 0, 25)
DelayLabel.Position = UDim2.new(0, 10, 0, 5)
DelayLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
DelayLabel.TextColor3 = Color3.new(1, 1, 1)
DelayLabel.Text = "Loop Delay:"
DelayLabel.Font = Enum.Font.SourceSans
DelayLabel.TextSize = 14
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = SettingsFrameContent

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(0, 50, 0, 25)
DelayInput.Position = UDim2.new(0, 95, 0, 5)
DelayInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
DelayInput.TextColor3 = Color3.new(1, 1, 1)
DelayInput.Text = tostring(LoopDelay)
DelayInput.Font = Enum.Font.SourceSans
DelayInput.TextSize = 14
DelayInput.ClearTextOnFocus = false
DelayInput.Parent = SettingsFrameContent

--===================================================================
-- CORE LOGIC FUNCTIONS
--===================================================================

function ShowNotification(message)
    NotificationText.Text = message
    NotificationFrame.Visible = true
    local fadeInTween = TweenService:Create(NotificationFrame, TWEEN_INFO_FADE, {BackgroundTransparency = 0})
    local textFadeInTween = TweenService:Create(NotificationText, TWEEN_INFO_FADE, {TextTransparency = 0})
    fadeInTween:Play()
    textFadeInTween:Play()

    task.spawn(function()
        task.wait(3)
        local fadeOutTween = TweenService:Create(NotificationFrame, TWEEN_INFO_FADE, {BackgroundTransparency = 1})
        local textFadeOutTween = TweenService:Create(NotificationText, TWEEN_INFO_FADE, {TextTransparency = 1})
        fadeOutTween:Play()
        textFadeOutTween:Play()
        task.wait(TWEEN_INFO_FADE.Time)
        NotificationFrame.Visible = false
    end)
end

function GetVehicle()
    local character = LocalPlayer.Character
    if not character or not character.Parent then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    -- Check if player is sitting in a VehicleSeat
    if humanoid.Seat and humanoid.Seat:IsA("VehicleSeat") then
        local vehicleSeat = humanoid.Seat
        if vehicleSeat.Parent and vehicleSeat.Parent:IsA("Model") then
            return vehicleSeat.Parent
        end
    end

    -- Check for a character's "root" part being welded to a vehicle model
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        for _, weld in ipairs(rootPart:GetJoints()) do
            local otherPart = weld.Part0 == rootPart and weld.Part1 or weld.Part0
            if otherPart and otherPart.Parent then
                local vehicleModel = otherPart:FindFirstAncestorOfClass("Model")
                if vehicleModel and vehicleModel ~= character and vehicleModel:FindFirstChildOfClass("VehicleSeat") then
                    return vehicleModel
                end
            end
        end
    end

    return nil
end

function TeleportVehicle(vehicle, position)
    if not vehicle or not vehicle.PrimaryPart then
        ShowNotification("Error: No vehicle found to teleport.")
        return
    end

    local teleportMethod = CurrentTeleportMethod
    if teleportMethod == "CFrame" then
        vehicle:SetPrimaryPartCFrame(CFrame.new(position))
    elseif teleportMethod == "BodyForce" then
        local bodyForce = Instance.new("BodyForce", vehicle.PrimaryPart)
        bodyForce.Force = (position - vehicle.PrimaryPart.Position).Unit * 10000 * vehicle.PrimaryPart.Mass
        task.wait(0.1)
        bodyForce:Destroy()
    elseif teleportMethod == "BodyVelocity" then
        local bodyVelocity = Instance.new("BodyVelocity", vehicle.PrimaryPart)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = (position - vehicle.PrimaryPart.Position) * 10
        task.wait(0.1)
        bodyVelocity:Destroy()
    end
    ShowNotification("Teleported to " .. tostring(math.floor(position.x)) .. ", " .. tostring(math.floor(position.y)) .. ", " .. tostring(math.floor(position.z)) .. ".")
end

--===================================================================
-- GUI LOGIC & FUNCTIONS
--===================================================================

function CreatePointFrame(pointData)
    local pointFrame = Instance.new("Frame")
    pointFrame.Name = pointData.Name
    pointFrame.Size = UDim2.new(0, 100, 1, 0)
    pointFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    pointFrame.Parent = PointListContainer

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Text = pointData.Name
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 14
    nameLabel.Parent = pointFrame

    local TeleportButton = Instance.new("TextButton")
    TeleportButton.Size = UDim2.new(1, 0, 0, 20)
    TeleportButton.Position = UDim2.new(0, 0, 0, 20)
    TeleportButton.BackgroundColor3 = Color3.new(0, 0.6, 0.2)
    TeleportButton.TextColor3 = Color3.new(1, 1, 1)
    TeleportButton.Text = "Go"
    TeleportButton.Font = Enum.Font.SourceSansBold
    TeleportButton.TextSize = 14
    TeleportButton.Parent = pointFrame
    TeleportButton.MouseButton1Click:Connect(function()
        local vehicle = GetVehicle()
        if vehicle then
            TeleportVehicle(vehicle, pointData.Position)
        else
            ShowNotification("Error: Cannot teleport, no vehicle found.")
        end
    end)

    local DeleteButton = Instance.new("TextButton")
    DeleteButton.Size = UDim2.new(1, 0, 0, 20)
    DeleteButton.Position = UDim2.new(0, 0, 0, 40)
    DeleteButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    DeleteButton.TextColor3 = Color3.new(1, 1, 1)
    DeleteButton.Text = "Delete"
    DeleteButton.Font = Enum.Font.SourceSansBold
    DeleteButton.TextSize = 14
    DeleteButton.Parent = pointFrame
    DeleteButton.MouseButton1Click:Connect(function()
        local indexToRemove = nil
        for i, point in ipairs(TeleportPoints) do
            if point.Name == pointData.Name then
                indexToRemove = i
                break
            end
        end
        if indexToRemove then
            table.remove(TeleportPoints, indexToRemove)
            pointFrame:Destroy()
            RefreshPointListUI()
            ShowNotification("Point '" .. pointData.Name .. "' deleted.")
        end
    end)
end

function RefreshPointListUI()
    for _, child in ipairs(PointListContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for _, pointData in ipairs(TeleportPoints) do
        CreatePointFrame(pointData)
    end

    local totalWidth = #TeleportPoints > 0 and #TeleportPoints * (UIGridLayout.CellSize.X.Offset + UIGridLayout.CellPadding.X.Offset) or 0
    PointListContainer.Size = UDim2.new(0, totalWidth, 1, 0)
    TabScrollView.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
end

function SetTeleportMethod(method)
    CurrentTeleportMethod = method
    CFrameButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    BodyForceButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    BodyVelocityButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    if method == "CFrame" then
        CFrameButton.BackgroundColor3 = Color3.new(0, 0.5, 0.8)
    elseif method == "BodyForce" then
        BodyForceButton.BackgroundColor3 = Color3.new(0, 0.5, 0.8)
    elseif method == "BodyVelocity" then
        BodyVelocityButton.BackgroundColor3 = Color3.new(0, 0.5, 0.8)
    end
    ShowNotification("Teleport method set to " .. method .. ".")
end

MainButton.MouseButton1Click:Connect(function()
    MainButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    SettingsButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    MainFrameContent.Visible = true
    SettingsFrameContent.Visible = false
end)

SettingsButton.MouseButton1Click:Connect(function()
    MainButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    SettingsButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    MainFrameContent.Visible = false
    SettingsFrameContent.Visible = true
end)

SaveButton.MouseButton1Click:Connect(function()
    local vehicle = GetVehicle()
    if vehicle then
        local pointName = PointNameInput.Text ~= "" and PointNameInput.Text or "Point " .. (#TeleportPoints + 1)
        local point = { Name = pointName, Position = vehicle.PrimaryPart.Position }
        table.insert(TeleportPoints, point)
        RefreshPointListUI()
        ShowNotification("Saved point '" .. pointName .. "'.")
        PointNameInput.Text = ""
    else
        ShowNotification("Error: Get in a vehicle to save a point.")
    end
end)

ClearAllButton.MouseButton1Click:Connect(function()
    if #TeleportPoints > 0 then
        if IsLooping then
            IsLooping = false
            LoopButton.Text = "Start Loop (Delay: " .. LoopDelay .. "s)"
        end
        TeleportPoints = {}
        RefreshPointListUI()
        ShowNotification("All teleport points have been cleared.")
    else
        ShowNotification("No teleport points to clear.")
    end
end)

LoopButton.MouseButton1Click:Connect(function()
    if not IsLooping then
        if #TeleportPoints < 2 then
            ShowNotification("Error: Need at least 2 points to loop.")
            return
        end
        IsLooping = true
        LoopButton.Text = "Stop Loop"
        ShowNotification("Loop teleport started.")
        task.spawn(function()
            while IsLooping do
                for _, point in ipairs(TeleportPoints) do
                    if not IsLooping then break end
                    local vehicle = GetVehicle()
                    if vehicle then
                        TeleportVehicle(vehicle, point.Position)
                    end
                    task.wait(LoopDelay)
                end
            end
        end)
    else
        IsLooping = false
        LoopButton.Text = "Start Loop (Delay: " .. LoopDelay .. "s)"
        ShowNotification("Loop teleport stopped.")
    end
end)

DelayInput.FocusLost:Connect(function()
    local newDelay = tonumber(DelayInput.Text)
    if newDelay and newDelay >= 0.1 then
        LoopDelay = newDelay
        ShowNotification("Loop delay set to " .. newDelay .. "s.")
        LoopButton.Text = "Start Loop (Delay: " .. LoopDelay .. "s)"
    else
        DelayInput.Text = tostring(LoopDelay)
        ShowNotification("Error: Invalid delay. Must be a number >= 0.1.")
    end
end)

CFrameButton.MouseButton1Click:Connect(function() SetTeleportMethod("CFrame") end)
BodyForceButton.MouseButton1Click:Connect(function() SetTeleportMethod("BodyForce") end)
BodyVelocityButton.MouseButton1Click:Connect(function() SetTeleportMethod("BodyVelocity") end)

MinimizeButton.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    local newSize = IsMinimized and UDim2.new(0, 150, 0, 30) or UDim2.new(0, 300, 0, 450)
    local tweenSize = TweenService:Create(MainFrame, TWEEN_INFO_MINMAX, {Size = newSize})

    if IsMinimized then
        TabFrame.Visible = false
        MinimizeButton.Text = "Max"
        MinimizeButton.Position = UDim2.new(0.5, -30, 0, 0)
        MinimizeButton.Size = UDim2.new(0, 60, 1, 0)
        MinimizeButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        tweenSize:Play()
    else
        MinimizeButton.Text = "-"
        MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
        MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
        MinimizeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
        TabFrame.Visible = true
        tweenSize:Play()
    end
end)

RefreshPointListUI()
SetTeleportMethod(CurrentTeleportMethod)

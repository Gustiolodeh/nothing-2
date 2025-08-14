--[[
	Universal Vehicle Manager and Speed Multiplier by Gemini

	This is a major rewrite of the previous script. It now features a dedicated
	Vehicle Manager that allows you to save and manage vehicles, each with its
	own configurable speed multiplier and teleport points.

	Features:
	- Save a vehicle's position and type to a list while sitting in it.
	- Dynamic GUI for managing saved vehicles.
	- Per-vehicle speed multiplier toggles.
	- Teleport to saved vehicle locations.
	- Mobile-friendly GUI and responsive design.

	Instructions:
	1. Paste this entire script into a LocalScript.
	2. Place the LocalScript in StarterPlayerScripts.
	3. Get into a vehicle and use the GUI to save and manage it.
]]

-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CORE VARIABLES
local SavedVehicles = {}
local CurrentTeleportMethod = "CFrame"
local ActiveSpeedControllers = {} -- Stores BodyVelocity instances for active multipliers
local IsMinimized = false

-- GUI CONSTANTS
local TWEEN_INFO_MINMAX = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local NOTIFICATION_TIME = 3

--===================================================================
-- GUI CREATION
--===================================================================
local MainScreenGui = Instance.new("ScreenGui")
MainScreenGui.Name = "VehicleManagerGUI"
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
TitleBar.Text = "Vehicle Manager"
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

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -10, 1, -40)
ContentFrame.Position = UDim2.new(0, 5, 0, 35)
ContentFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local SaveVehicleButton = Instance.new("TextButton")
SaveVehicleButton.Size = UDim2.new(1, -20, 0, 30)
SaveVehicleButton.Position = UDim2.new(0, 10, 0, 5)
SaveVehicleButton.BackgroundColor3 = Color3.new(0, 0.6, 0.2)
SaveVehicleButton.TextColor3 = Color3.new(1, 1, 1)
SaveVehicleButton.Text = "Save Current Vehicle"
SaveVehicleButton.Font = Enum.Font.SourceSansBold
SaveVehicleButton.TextSize = 16
SaveVehicleButton.Parent = ContentFrame

local ClearAllButton = Instance.new("TextButton")
ClearAllButton.Size = UDim2.new(1, -20, 0, 30)
ClearAllButton.Position = UDim2.new(0, 10, 0, 40)
ClearAllButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
ClearAllButton.TextColor3 = Color3.new(1, 1, 1)
ClearAllButton.Text = "Clear All Saved Vehicles"
ClearAllButton.Font = Enum.Font.SourceSansBold
ClearAllButton.TextSize = 16
ClearAllButton.Parent = ContentFrame

local VehicleScrollView = Instance.new("ScrollingFrame")
VehicleScrollView.Name = "VehicleScrollView"
VehicleScrollView.Size = UDim2.new(1, 0, 1, -75)
VehicleScrollView.Position = UDim2.new(0, 0, 0, 75)
VehicleScrollView.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
VehicleScrollView.BorderSizePixel = 0
VehicleScrollView.Parent = ContentFrame
VehicleScrollView.CanvasSize = UDim2.new(0, 0, 0, 0)
VehicleScrollView.ScrollBarImageColor3 = Color3.new(0.4, 0.4, 0.4)
VehicleScrollView.VerticalScrollBarPosition = Enum.ScrollBarPosition.Right

local VehicleListLayout = Instance.new("UIListLayout")
VehicleListLayout.Padding = UDim.new(0, 5)
VehicleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
VehicleListLayout.Parent = VehicleScrollView

--===================================================================
-- CORE LOGIC FUNCTIONS
--===================================================================

function ShowNotification(message)
    NotificationText.Text = message
    NotificationFrame.BackgroundTransparency = 0
    NotificationText.TextTransparency = 0
    NotificationFrame.Visible = true

    task.spawn(function()
        task.wait(NOTIFICATION_TIME)
        local fadeOutTween = TweenService:Create(NotificationFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        local textFadeOutTween = TweenService:Create(NotificationText, TweenInfo.new(0.5), {TextTransparency = 1})
        fadeOutTween:Play()
        textFadeOutTween:Play()
        fadeOutTween.Completed:Wait()
        NotificationFrame.Visible = false
    end)
end

function GetVehicle()
    local character = LocalPlayer.Character
    if not character or not character.Parent then return nil end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    if humanoid.Seat then
        return humanoid.Seat:FindFirstAncestorOfClass("Model")
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        for _, weld in ipairs(rootPart:GetJoints()) do
            local otherPart = weld.Part0 == rootPart and weld.Part1 or weld.Part0
            if otherPart and otherPart.Parent then
                local vehicleModel = otherPart:FindFirstAncestorOfClass("Model")
                if vehicleModel and vehicleModel ~= character and vehicleModel:FindFirstChild("PrimaryPart") then
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
    vehicle:SetPrimaryPartCFrame(CFrame.new(position))
    ShowNotification("Teleported to saved location.")
end

function ToggleSpeedMultiplier(vehicleModel)
    if not vehicleModel or not vehicleModel.PrimaryPart then
        return
    end

    if ActiveSpeedControllers[vehicleModel] then
        ActiveSpeedControllers[vehicleModel]:Destroy()
        ActiveSpeedControllers[vehicleModel] = nil
        ShowNotification("Speed boost disabled for " .. vehicleModel.Name .. ".")
    else
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "SpeedController"
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = vehicleModel.PrimaryPart
        ActiveSpeedControllers[vehicleModel] = bodyVelocity
        ShowNotification("Speed boost enabled for " .. vehicleModel.Name .. ".")
    end
end

--===================================================================
-- GUI LOGIC & FUNCTIONS
--===================================================================

function UpdateVehicleList()
    for _, child in ipairs(VehicleScrollView:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local layoutOrder = 1
    for vehicleName, data in pairs(SavedVehicles) do
        local vehicleFrame = Instance.new("Frame")
        vehicleFrame.Size = UDim2.new(1, 0, 0, 80)
        vehicleFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        vehicleFrame.BorderSizePixel = 0
        vehicleFrame.Parent = VehicleScrollView
        vehicleFrame.LayoutOrder = layoutOrder
        layoutOrder = layoutOrder + 1
        
        local vehicleNameLabel = Instance.new("TextLabel")
        vehicleNameLabel.Size = UDim2.new(1, -10, 0, 20)
        vehicleNameLabel.Position = UDim2.new(0, 5, 0, 5)
        vehicleNameLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        vehicleNameLabel.TextColor3 = Color3.new(1, 1, 1)
        vehicleNameLabel.Text = vehicleName
        vehicleNameLabel.Font = Enum.Font.SourceSansBold
        vehicleNameLabel.TextScaled = true
        vehicleNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        vehicleNameLabel.Parent = vehicleFrame

        local TeleportButton = Instance.new("TextButton")
        TeleportButton.Size = UDim2.new(1/3, -5, 0, 20)
        TeleportButton.Position = UDim2.new(0, 5, 0, 25)
        TeleportButton.BackgroundColor3 = Color3.new(0, 0.5, 0.8)
        TeleportButton.TextColor3 = Color3.new(1, 1, 1)
        TeleportButton.Text = "Teleport"
        TeleportButton.Font = Enum.Font.SourceSansBold
        TeleportButton.TextScaled = true
        TeleportButton.Parent = vehicleFrame
        TeleportButton.MouseButton1Click:Connect(function()
            local vehicle = GetVehicle()
            TeleportVehicle(vehicle, data.Position)
        end)

        local BoostButton = Instance.new("TextButton")
        BoostButton.Size = UDim2.new(1/3, -5, 0, 20)
        BoostButton.Position = UDim2.new(1/3, 7.5, 0, 25)
        BoostButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
        BoostButton.TextColor3 = Color3.new(1, 1, 1)
        BoostButton.Text = "Boost"
        BoostButton.Font = Enum.Font.SourceSansBold
        BoostButton.TextScaled = true
        BoostButton.Parent = vehicleFrame
        BoostButton.MouseButton1Click:Connect(function()
            -- Find the actual vehicle model to apply the boost
            local vehicle = GetVehicle()
            if vehicle and vehicle.Name == data.Name then
                ToggleSpeedMultiplier(vehicle)
            else
                ShowNotification("Error: You are not in the saved vehicle!")
            end
        end)

        local DeleteButton = Instance.new("TextButton")
        DeleteButton.Size = UDim2.new(1/3, -5, 0, 20)
        DeleteButton.Position = UDim2.new(2/3, 10, 0, 25)
        DeleteButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
        DeleteButton.TextColor3 = Color3.new(1, 1, 1)
        DeleteButton.Text = "Delete"
        DeleteButton.Font = Enum.Font.SourceSansBold
        DeleteButton.TextScaled = true
        DeleteButton.Parent = vehicleFrame
        DeleteButton.MouseButton1Click:Connect(function()
            SavedVehicles[vehicleName] = nil
            UpdateVehicleList()
            ShowNotification("Vehicle '" .. vehicleName .. "' deleted.")
        end)
    end
end

SaveVehicleButton.MouseButton1Click:Connect(function()
    local vehicle = GetVehicle()
    if not vehicle or not vehicle.PrimaryPart then
        ShowNotification("Error: Get in a vehicle to save it.")
        return
    end
    
    local vehicleName = vehicle.Name
    if SavedVehicles[vehicleName] then
        ShowNotification("Error: A vehicle with this name is already saved.")
        return
    end

    SavedVehicles[vehicleName] = {
        Name = vehicleName,
        Position = vehicle.PrimaryPart.Position
    }
    UpdateVehicleList()
    ShowNotification("Saved vehicle '" .. vehicleName .. "'.")
end)

ClearAllButton.MouseButton1Click:Connect(function()
    if #SavedVehicles > 0 then
        SavedVehicles = {}
        for _, controller in pairs(ActiveSpeedControllers) do
            controller:Destroy()
        end
        ActiveSpeedControllers = {}
        UpdateVehicleList()
        ShowNotification("All saved vehicles have been cleared.")
    else
        ShowNotification("No vehicles to clear.")
    end
end)

MinimizeButton.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    local newSize = IsMinimized and UDim2.new(0, 150, 0, 30) or UDim2.new(0, 300, 0, 450)
    local tweenSize = TweenService:Create(MainFrame, TWEEN_INFO_MINMAX, {Size = newSize})

    if IsMinimized then
        ContentFrame.Visible = false
        MinimizeButton.Text = "+"
        MinimizeButton.Position = UDim2.new(0.5, -15, 0, 0)
        MinimizeButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        tweenSize:Play()
    else
        MinimizeButton.Text = "-"
        MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
        MinimizeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
        tweenSize:Play()
        tweenSize.Completed:Wait()
        ContentFrame.Visible = true
    end
end)

-- Main loop to apply speed updates while enabled
RunService.Heartbeat:Connect(function()
    for _, controller in pairs(ActiveSpeedControllers) do
        local vehicle = controller.Parent.Parent
        if vehicle and vehicle:IsA("Model") and vehicle.PrimaryPart and vehicle.Parent then
            local velocity = vehicle.PrimaryPart.Velocity
            local lookVector = vehicle.PrimaryPart.CFrame.LookVector
            local currentForwardSpeed = velocity:Dot(lookVector)

            -- This is where the multiplier would be applied.
            -- You can change '2' to any number you want.
            controller.Velocity = lookVector * (currentForwardSpeed * 2)
        else
            controller:Destroy()
            ActiveSpeedControllers[vehicle] = nil
        end
    end
end)

UpdateVehicleList()

--[[
	Universal Vehicle Speed Multiplier by Gemini

	This is a client-side script designed to work with most vehicle systems in Roblox.
	It detects when the player is in a vehicle and applies a BodyVelocity to its
	PrimaryPart, effectively multiplying its forward speed.

	Features:
	- Universal vehicle detection (works with VehicleSeats and other seat types).
	- Client-side execution for zero latency.
	- Mobile-friendly GUI with scale-based design.
	- Adjustable speed multiplier.
	- Clear and informative status updates.
	- Works with any vehicle that has a PrimaryPart and a seat.

	Instructions:
	1. Paste this entire script into a LocalScript.
	2. Place the LocalScript in StarterPlayerScripts.
	3. Execute the game and get in a vehicle.
]]

-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CORE VARIABLES
local CurrentSpeedMultiplier = 2.0 -- Default multiplier
local IsInVehicle = false
local Connection = nil
local SpeedController = nil

local TWEEN_INFO_MINMAX = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--===================================================================
-- GUI CREATION
--===================================================================
local MainScreenGui = Instance.new("ScreenGui")
MainScreenGui.Name = "SpeedMultiplierGUI"
MainScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.2, 0, 0.25, 0) -- Scaled for mobile and desktop
MainFrame.Position = UDim2.new(0.8, -10, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(1, 0.5) -- Anchors to top-right
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Parent = MainScreenGui

local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint.AspectRatio = 1
UIAspectRatioConstraint.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0.1, 0)
TitleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.Text = "Vehicle Speed"
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextScaled = true
TitleBar.Parent = MainFrame

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -10, 0.8, -10)
TabFrame.Position = UDim2.new(0.5, 0, 0.55, 0)
TabFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TabFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellSize = UDim2.new(1, 0, 0.2, 0)
UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
UIGridLayout.FillDirection = Enum.FillDirection.Vertical
UIGridLayout.Parent = TabFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingBottom = UDim.new(0, 5)
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.Parent = TabFrame

local Label = Instance.new("TextLabel")
Label.Name = "MultiplierLabel"
Label.Size = UDim2.new(1, 0, 1, 0)
Label.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Label.TextColor3 = Color3.new(1, 1, 1)
Label.Text = "Multiplier: " .. tostring(CurrentSpeedMultiplier) .. "x"
Label.Font = Enum.Font.SourceSansBold
Label.TextScaled = true
Label.Parent = TabFrame

local MultiplierInput = Instance.new("TextBox")
MultiplierInput.Size = UDim2.new(1, 0, 1, 0)
MultiplierInput.PlaceholderText = "Enter Multiplier (e.g., 5.0)"
MultiplierInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
MultiplierInput.TextColor3 = Color3.new(1, 1, 1)
MultiplierInput.Font = Enum.Font.SourceSans
MultiplierInput.TextScaled = true
MultiplierInput.ClearTextOnFocus = true
MultiplierInput.Parent = TabFrame

local ApplyButton = Instance.new("TextButton")
ApplyButton.Size = UDim2.new(1, 0, 1, 0)
ApplyButton.BackgroundColor3 = Color3.new(0, 0.6, 0.2)
ApplyButton.TextColor3 = Color3.new(1, 1, 1)
ApplyButton.Text = "Apply"
ApplyButton.Font = Enum.Font.SourceSansBold
ApplyButton.TextScaled = true
ApplyButton.Parent = TabFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Text = "Enable"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextScaled = true
ToggleButton.Parent = TabFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Text = "Status: Disabled"
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextScaled = true
StatusLabel.Parent = TabFrame

--===================================================================
-- CORE LOGIC FUNCTIONS
--===================================================================

function GetVehicle()
    local character = LocalPlayer.Character
    if not character or not character.Parent then return nil end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    local seat = humanoid.Seat
    if seat then
        return seat:FindFirstAncestorOfClass("Model")
    end

    return nil
end

function ApplySpeedMultiplier()
    local vehicle = GetVehicle()
    if not vehicle or not vehicle.PrimaryPart then
        StatusLabel.Text = "Status: No Vehicle"
        return
    end

    if not SpeedController then
        SpeedController = Instance.new("BodyVelocity")
        SpeedController.Name = "SpeedController"
        SpeedController.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        SpeedController.Parent = vehicle.PrimaryPart
    end
    
    StatusLabel.Text = "Status: Enabled"
end

function StopSpeedMultiplier()
    if SpeedController then
        SpeedController:Destroy()
        SpeedController = nil
    end
    StatusLabel.Text = "Status: Disabled"
end

function UpdateSpeed()
    if SpeedController then
        local vehicle = GetVehicle()
        if vehicle and vehicle.PrimaryPart then
            local velocity = vehicle.PrimaryPart.Velocity
            local lookVector = vehicle.PrimaryPart.CFrame.LookVector
            local currentForwardSpeed = velocity:Dot(lookVector)

            SpeedController.Velocity = lookVector * (currentForwardSpeed * CurrentSpeedMultiplier)
        else
            StopSpeedMultiplier()
        end
    end
end

--===================================================================
-- GUI & INPUT CONNECTIONS
--===================================================================

ToggleButton.MouseButton1Click:Connect(function()
    if not IsInVehicle then
        IsInVehicle = true
        ToggleButton.Text = "Disable"
        ToggleButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
        ApplySpeedMultiplier()
    else
        IsInVehicle = false
        ToggleButton.Text = "Enable"
        ToggleButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
        StopSpeedMultiplier()
    end
end)

ApplyButton.MouseButton1Click:Connect(function()
    local newMultiplier = tonumber(MultiplierInput.Text)
    if newMultiplier and newMultiplier > 0 then
        CurrentSpeedMultiplier = newMultiplier
        Label.Text = "Multiplier: " .. tostring(CurrentSpeedMultiplier) .. "x"
        StatusLabel.Text = "Multiplier set to " .. tostring(CurrentSpeedMultiplier) .. "x"
    else
        MultiplierInput.Text = tostring(CurrentSpeedMultiplier)
        StatusLabel.Text = "Error: Invalid multiplier."
    end
end)

MultiplierInput.FocusLost:Connect(function()
    ApplyButton.MouseButton1Click:Fire()
end)

-- Main loop to apply speed updates while enabled
RunService.Heartbeat:Connect(function()
    if IsInVehicle then
        UpdateSpeed()
    end
end)

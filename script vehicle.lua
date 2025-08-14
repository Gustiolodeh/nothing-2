--[[
	Manual Vehicle Speed Controller for Custom Vehicle Games

	This script is designed for games like "Epic Offroad" and "Indonesian Car Driving"
	which use custom vehicle physics systems (e.g., A-Chassis). Instead of a generic
	speed boost, this script attempts to directly modify a common vehicle property.

	Features:
	- Manual input for a new speed value.
	- Attempts to find and modify a "MaxSpeed" or "Torque" NumberValue.
	- Falls back to a consistent BodyVelocity boost if a specific value is not found.
	- Mobile-friendly GUI with clear status updates.

	Instructions:
	1. Paste this entire script into a LocalScript.
	2. Place the LocalScript in StarterPlayerScripts.
	3. Get into a vehicle. The GUI will appear.
	4. Manually enter a new speed value (e.g., 250) and click "Apply".
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CORE VARIABLES
local AppliedSpeedValue = nil -- Holds the NumberValue instance we've modified
local BodyVelocityBooster = nil -- Holds the BodyVelocity instance for the fallback
local CurrentBoostMultiplier = 1.0 -- Fallback multiplier

--===================================================================
-- GUI CREATION
--===================================================================
local MainScreenGui = Instance.new("ScreenGui")
MainScreenGui.Name = "ManualSpeedGUI"
MainScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Parent = MainScreenGui

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.Text = "Manual Speed Control"
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 18
TitleBar.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -40)
ContentFrame.Position = UDim2.new(0, 10, 0, 35)
ContentFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 20)
StatusLabel.Position = UDim2.new(0, 5, 0, 5)
StatusLabel.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Text = "Status: Idle"
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextScaled = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = ContentFrame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -10, 0, 30)
InfoLabel.Position = UDim2.new(0, 5, 0, 30)
InfoLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
InfoLabel.TextColor3 = Color3.new(1, 1, 1)
InfoLabel.Text = "Enter a new speed value:"
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextScaled = true
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = ContentFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(1, -10, 0, 30)
SpeedInput.Position = UDim2.new(0, 5, 0, 60)
SpeedInput.PlaceholderText = "e.g., 250 (Default is usually ~150)"
SpeedInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextScaled = true
SpeedInput.ClearTextOnFocus = true
SpeedInput.Parent = ContentFrame

local ApplyButton = Instance.new("TextButton")
ApplyButton.Size = UDim2.new(1, -10, 0, 30)
ApplyButton.Position = UDim2.new(0, 5, 0, 95)
ApplyButton.BackgroundColor3 = Color3.new(0, 0.6, 0.2)
ApplyButton.TextColor3 = Color3.new(1, 1, 1)
ApplyButton.Text = "Apply Speed"
ApplyButton.Font = Enum.Font.SourceSansBold
ApplyButton.TextScaled = true
ApplyButton.Parent = ContentFrame

--===================================================================
-- CORE LOGIC FUNCTIONS
--===================================================================

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

function StopBoost()
    if BodyVelocityBooster then
        BodyVelocityBooster:Destroy()
        BodyVelocityBooster = nil
    end
end

function ApplyNewSpeed()
    local newSpeed = tonumber(SpeedInput.Text)
    if not newSpeed or newSpeed < 1 then
        StatusLabel.Text = "Error: Invalid number."
        return
    end

    local vehicle = GetVehicle()
    if not vehicle or not vehicle.PrimaryPart then
        StatusLabel.Text = "Status: Not in a vehicle."
        return
    end

    -- Attempt to find a configurable value to modify
    local success = false
    local valuesToSearch = {"MaxSpeed", "Torque", "Horsepower", "Power"}

    for _, valueName in ipairs(valuesToSearch) do
        local configValue = vehicle:FindFirstChild(valueName)
        if configValue and configValue:IsA("NumberValue") then
            -- Found a NumberValue, modify it directly
            AppliedSpeedValue = configValue
            AppliedSpeedValue.Value = newSpeed
            StatusLabel.Text = "Success! Modified '" .. valueName .. "' to " .. newSpeed .. "."
            success = true
            break
        end
    end

    if not success then
        -- Fallback to BodyVelocity if no configurable value is found
        StopBoost()
        
        BodyVelocityBooster = Instance.new("BodyVelocity")
        BodyVelocityBooster.Name = "SpeedBooster"
        BodyVelocityBooster.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocityBooster.Parent = vehicle.PrimaryPart
        CurrentBoostMultiplier = newSpeed / 100 -- Use a ratio to make the speed value more sensible
        StatusLabel.Text = "Fallback: Applied " .. CurrentBoostMultiplier .. "x speed boost."
    end
end

--===================================================================
-- GUI & INPUT CONNECTIONS
--===================================================================

ApplyButton.MouseButton1Click:Connect(ApplyNewSpeed)

SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        ApplyNewSpeed()
    end
end)

-- Main loop for the fallback boost
RunService.Heartbeat:Connect(function()
    if BodyVelocityBooster and BodyVelocityBooster.Parent then
        local vehicle = BodyVelocityBooster.Parent.Parent
        if vehicle and vehicle.PrimaryPart then
            local velocity = vehicle.PrimaryPart.Velocity
            local lookVector = vehicle.PrimaryPart.CFrame.LookVector
            local currentForwardSpeed = velocity:Dot(lookVector)
            
            -- Apply the boost
            BodyVelocityBooster.Velocity = lookVector * (currentForwardSpeed * CurrentBoostMultiplier)
        else
            -- Vehicle no longer exists, stop the boost
            StopBoost()
        end
    end
end)

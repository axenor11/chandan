local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local MAX_DISTANCE = 400
local LIMITED_TELEPORT = 50
local CLOSE_OBJECT_DISTANCE = 8

local floatForce
local velocityFixConnection

local function enableFloat(hrp)
	-- Purana remove karo
	if floatForce then
		floatForce:Destroy()
	end
	if velocityFixConnection then
		velocityFixConnection:Disconnect()
	end
	
	-- Gravity cancel
	floatForce = Instance.new("BodyForce")
	floatForce.Force = Vector3.new(0, hrp:GetMass() * workspace.Gravity, 0)
	floatForce.Parent = hrp
	
	-- Fall speed ko 0 rakhega
	velocityFixConnection = RunService.Heartbeat:Connect(function()
		if hrp then
			local vel = hrp.Velocity
			hrp.Velocity = Vector3.new(vel.X, 0, vel.Z)
		end
	end)
end

local function disableFloat()
	if floatForce then
		floatForce:Destroy()
		floatForce = nil
	end
	if velocityFixConnection then
		velocityFixConnection:Disconnect()
		velocityFixConnection = nil
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F then
		local character = player.Character
		if not character then return end
		
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		local targetPosition = mouse.Hit.Position
		local direction = (targetPosition - hrp.Position)
		local distance = direction.Magnitude
		
		-- Object rule (8m)
		if mouse.Target then
			local objectDistance = (mouse.Target.Position - hrp.Position).Magnitude
			
			if objectDistance <= CLOSE_OBJECT_DISTANCE then
				local sizeY = mouse.Target.Size.Y
				hrp.CFrame = CFrame.new(
					mouse.Target.Position + Vector3.new(0, sizeY/2 + 3, 0)
				)
				disableFloat()
				return
			end
		end
		
		-- 400m rule
		if distance > MAX_DISTANCE then
			local limitedPosition = hrp.Position + direction.Unit * LIMITED_TELEPORT
			hrp.CFrame = CFrame.new(limitedPosition)
		else
			hrp.CFrame = CFrame.new(targetPosition + Vector3.new(0,3,0))
		end
		
		-- Hamesha float enable (kabhi na gire)
		enableFloat(hrp)
	end
end)


--rj
-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

-- Function to create screen fade
local function createFade()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RejoinFade"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.BackgroundTransparency = 1 -- initially invisible
    frame.Parent = screenGui

    return frame
end

-- Fade tween function
local function fade(frame, targetTransparency, time)
    local tween = TweenService:Create(frame, TweenInfo.new(time), {BackgroundTransparency = targetTransparency})
    tween:Play()
    tween.Completed:Wait()
end

-- Rejoin function with fade
local function rejoinGame()
    local fadeFrame = createFade()
    -- fade out
    fade(fadeFrame, 0, 0.5)
    wait(0.1)
    -- teleport
    TeleportService:Teleport(game.PlaceId, player)
end

-- Listen to chat
player.Chatted:Connect(function(msg)
    if msg:lower() == "!rj" then
        rejoinGame()
    end
end)


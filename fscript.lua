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
-- LocalScript: StarterPlayerScripts me lagayenge
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Chat command handle
player.Chatted:Connect(function(message)
	local msg = message:lower() -- lowercase me compare
	if msg == "!rj" then
		-- Rejoin
		game:GetService("TeleportService"):Teleport(game.PlaceId, player)
	elseif msg == "!re" then
		-- Respawn
		if player.Character then
			player.Character:BreakJoints() -- respawn trigger
		end
	end
end)
-- LocalScript: StarterPlayerScripts me lagayenge
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local speed = 50 -- studs per second
local moveDirection = 0 -- 1 = up, -1 = down

-- Gravity aur collisions ignore karna
humanoid.PlatformStand = true
hrp.CanCollide = false

-- Key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		moveDirection = 1 -- upar
	elseif input.KeyCode == Enum.KeyCode.Q then
		moveDirection = -1 -- niche
	end
end)

-- Key release
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Q then
		moveDirection = 0 -- ruk jao
	end
end)

-- Smooth movement
RunService.RenderStepped:Connect(function(deltaTime)
	if moveDirection ~= 0 then
		hrp.CFrame = hrp.CFrame + Vector3.new(0, moveDirection * speed * deltaTime, 0)
	end
end)



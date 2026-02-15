local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local MAX_DISTANCE = 400
local LIMITED_TELEPORT = 50
local CLOSE_OBJECT_DISTANCE = 15

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

--re
-- LocalScript (StarterPlayerScripts)

local player = game:GetService("Players").LocalPlayer

-- Respawn function
local function respawnPlayer()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = 0
    end
end

-- Listen to chat
player.Chatted:Connect(function(msg)
    if msg:lower() == "!re" then
        respawnPlayer()
    end
end)
-- tags to spesial player
-- SUPER CHHOTA TAG SCRIPT + HINTS
-- 2 players ke tags: axenor11 → 👑 OWNER, fake_id002 → CO-OWNER
-- >50 dur (CAMERA se) → tag "👑" me badal jaye
-- Tags pe click → teleport
-- Tags bahut chhote + achha design
-- Edit hint: players table mein naam:title daalo (e.g. players["newguy"] = "VIP")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- ================= EDIT YAHAN =================
local players = {
    ["axenor11"] = {title = "👑 OWNER", color1 = Color3.fromRGB(255,180,0), color2 = Color3.fromRGB(200,100,0), stroke = Color3.fromRGB(255,220,60)},
    ["fake_id002"] = {title = "aku bkl", color1 = Color3.fromRGB(0,140,80), color2 = Color3.fromRGB(0,200,120), stroke = Color3.fromRGB(100,255,180)}
}
local showTags = true  -- default ON
local maxDist = 50     -- ab 50 meter (pehle 20 tha, ab badal diya)
-- =============================================

-- Tag banao function
local function makeTag(p, char, data)
    local head = char:WaitForChild("Head")
    local old = head:FindFirstChild("Tag")
    if old then old:Destroy() end

    local bb = Instance.new("BillboardGui", head)
    bb.Name = "Tag"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 100, 0, 25)  -- bahut chhota size (hint: yahan badlo)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = showTags

    local f = Instance.new("Frame", bb)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundTransparency = 0.3

    local c = Instance.new("UICorner", f)
    c.CornerRadius = UDim.new(0, 6)  -- chhota radius achhe design ke liye

    local g = Instance.new("UIGradient", f)
    g.Color = ColorSequence.new(data.color1, data.color2)

    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.2
    s.Color = data.stroke

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = data.title
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255,255,255)

    -- Click → teleport
    btn.MouseButton1Click:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)  -- teleport samne (hint: -3 adjust)
        end
    end)

    -- Distance check (CAMERA se)
    RunService.Heartbeat:Connect(function()
        if not char.Parent then return end
        local camPos = Workspace.CurrentCamera.CFrame.Position
        local headPos = head.Position
        local dist = (camPos - headPos).Magnitude  -- camera se distance
        if dist > maxDist then
            btn.Text = "👑"                   -- crown me badlo
            bb.Size = UDim2.new(0, 40, 0, 40)  -- chhota gol (hint: size adjust)
            c.CornerRadius = UDim.new(0.5, 0) -- gol shape
        else
            btn.Text = data.title
            bb.Size = UDim2.new(0, 100, 0, 25)
            c.CornerRadius = UDim.new(0, 6)
        end
    end)
end

-- Players setup
local function setup(p)
    local function onChar(char)
        local data = players[p.Name]
        if data then makeTag(p, char, data) end
    end
    if p.Character then onChar(p.Character) end
    p.CharacterAdded:Connect(onChar)
end

for _, p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerAdded:Connect(setup)

-- Chhota ON/OFF button
local sg = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 60, 0, 24)
btn.Position = UDim2.new(1, -70, 0, 5)
btn.Text = showTags and "ON" or "OFF"
btn.BackgroundColor3 = showTags and Color3.fromRGB(40,140,40) or Color3.fromRGB(140,40,40)
btn.TextColor3 = Color3.fromRGB(255,255,255)

btn.MouseButton1Click:Connect(function()
    showTags = not showTags
    btn.Text = showTags and "ON" or "OFF"
    btn.BackgroundColor3 = showTags and Color3.fromRGB(40,140,40) or Color3.fromRGB(140,40,40)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character.Head:FindFirstChild("Tag") then
            p.Character.Head.Tag.Enabled = showTags
        end
    end
end)

print("Ab max distance 50 meter kar diya! 50+ dur → 👑, click pe teleport. Test karo.")

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
--for tags -- CORRECTED AKU'S TAG SCRIPT v2
-- Sirf script execute karne wale players ke head pe "aku's [naam]"
-- Apne head pe hamesha "👑 OWNER"
-- Dusre normal players pe kuch nahi dikhega
-- Button se ON/OFF + draggable

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local showTags = false
local scriptUsers = {}   -- Yeh table track karega kon-kon ne script chalaya (client-side)

-- Apne aap ko script user mark kar do
scriptUsers[LocalPlayer.UserId] = true

-- ScreenGui + Draggable Toggle Button
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AkuToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local buttonFrame = Instance.new("Frame")
buttonFrame.Name = "ToggleButton"
buttonFrame.Size = UDim2.new(0, 120, 0, 45)
buttonFrame.Position = UDim2.new(1, -130, 0, 20)
buttonFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
buttonFrame.BackgroundTransparency = 0.25
buttonFrame.BorderSizePixel = 0
buttonFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = buttonFrame

local gradient = Instance.new("UIGradient")
gradient.Rotation = 45
gradient.Parent = buttonFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = 0.4
stroke.Parent = buttonFrame

local textBtn = Instance.new("TextButton")
textBtn.Size = UDim2.new(1, 0, 1, 0)
textBtn.BackgroundTransparency = 1
textBtn.Text = "AKU OFF"
textBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
textBtn.TextStrokeTransparency = 0
textBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
textBtn.TextScaled = true
textBtn.Font = Enum.Font.GothamBold
textBtn.Parent = buttonFrame

-- Draggable logic
local dragging, dragStart, startPos
textBtn.MouseButton1Down:Connect(function()
    dragging = true
    dragStart = UserInputService:GetMouseLocation()
    startPos = buttonFrame.Position
    local conn; conn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            buttonFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    local upConn; upConn = UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            conn:Disconnect()
            upConn:Disconnect()
        end
    end)
end)

-- Toggle function
local function updateButton()
    if showTags then
        textBtn.Text = "tags on"
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 255, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 0))
        }
        stroke.Color = Color3.fromRGB(0, 255, 100)
    else
        textBtn.Text = "tags off"
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 0))
        }
        stroke.Color = Color3.fromRGB(255, 80, 80)
    end
end

textBtn.Activated:Connect(function()
    showTags = not showTags
    updateButton()
    refreshAllTags()
end)

-- Tag refresh (visibility)
function refreshAllTags()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            local tag = plr.Character.Head:FindFirstChild("AkuCustomTag")
            if tag then
                tag.Enabled = showTags
            end
        end
    end
end

-- Tag create function
local function createTag(plr, character)
    local head = character:WaitForChild("Head", 6)
    if not head then return end
    
    local old = head:FindFirstChild("AkuCustomTag")
    if old then old:Destroy() end
    
    task.wait(0.25)
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "AkuCustomTag"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 210, 0, 34)
    bb.StudsOffset = Vector3.new(0, 2.4, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.ClipsDescendants = true
    bb.Enabled = showTags
    bb.Parent = head
    
    local f = Instance.new("Frame", bb)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.fromRGB(10,10,10)
    f.BackgroundTransparency = 0.45
    f.BorderSizePixel = 0
    
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    
    local grad = Instance.new("UIGradient", f)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220,40,40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140,0,0))
    }
    grad.Rotation = 50
    
    local glow = Instance.new("UIStroke", f)
    glow.Color = Color3.fromRGB(255, 220, 60)
    glow.Thickness = 1.8
    glow.Transparency = 0.35
    
    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1,-14,1,0)
    txt.Position = UDim2.new(0,7,0,0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    txt.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Text decide karo
    if plr == LocalPlayer then
        txt.Text = "👑 aku BKL"
    elseif scriptUsers[plr.UserId] then
        txt.Text = "aku's " .. plr.Name
    else
        bb:Destroy()   -- Normal player → tag mat banao
        return
    end
end

-- Player setup
local function onCharacterAdded(plr, char)
    task.spawn(function()
        createTag(plr, char)
    end)
end

local function setupPlayer(plr)
    if plr.Character then
        onCharacterAdded(plr, plr.Character)
    end
    plr.CharacterAdded:Connect(function(char)
        onCharacterAdded(plr, char)
    end)
end

-- Sab players ke liye (future-proof)
for _, plr in ipairs(Players:GetPlayers()) do
    setupPlayer(plr)
end

Players.PlayerAdded:Connect(setupPlayer)

-- Button initial state
updateButton()

print("✅ AKU TAG FIXED – sirf script chalane walon pe 'aku's [name]'")
print("✅ Apne head pe hamesha 👑 OWNER")
print("Button se ON/OFF + drag kar sakte ho")
 

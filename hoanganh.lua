-- HOÀNG ANHD CLIENT (Roblox Studio safe LocalScript)
-- Features: loading screen (image id 138877125395095), GUI, Speed, Fly, ESP, Teleport, Godmode.
-- Meant for Studio / testing and learning. Does NOT perform server exploits.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Wait for character
repeat task.wait() until LocalPlayer and LocalPlayer.Character

-- Utility
local function create(parent, class, props)
	local obj = Instance.new(class)
	if props then for k,v in pairs(props) do obj[k] = v end end
	obj.Parent = parent
	return obj
end

-- ---------- Loading Screen ----------
local gui = Instance.new("ScreenGui")
gui.Name = "HoangAnhdClientGui"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local loading = create(gui, "Frame", {
	Name="Loading", Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(10,10,10)
})
local bg = create(loading, "ImageLabel", {
	Size = UDim2.new(1,0,1,0), Position=UDim2.new(0,0,0,0),
	Image = "rbxassetid://138877125395095", BackgroundTransparency = 1, ImageTransparency = 0.25, ScaleType = Enum.ScaleType.Crop
})
local title = create(loading, "TextLabel", {
	Size=UDim2.new(1,0,0,60), Position=UDim2.new(0,0,0.45,0),
	Text="ĐANG TẢI HOÀNG ANHD...", TextColor3 = Color3.new(1,1,1), TextScaled = true,
	BackgroundTransparency = 1, Font = Enum.Font.GothamBold
})
local barBG = create(loading, "Frame", {
	Size = UDim2.new(0.4,0,0,10), Position = UDim2.new(0.3,0,0.56,0), BackgroundColor3 = Color3.fromRGB(40,40,40)
})
create(barBG, "UICorner", {CornerRadius = UDim.new(1,0)})
local barFill = create(barBG, "Frame", {Size = UDim2.new(0,0,1,0), BackgroundColor3 = Color3.fromRGB(0,170,255)})
create(barFill, "UICorner", {CornerRadius = UDim.new(1,0)})

-- simple progress
task.spawn(function()
	for i=1,100 do
		barFill:TweenSize(UDim2.new(i/100,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.02, true)
		task.wait(0.02)
	end
	title.Text = "HOÀNG ANHD ĐÃ SẴN SÀNG!"
	task.wait(0.5)
	loading:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.8)
	wait(0.9)
	loading:Destroy()
end)

-- ---------- Main GUI (Fluent-like simple) ----------
local mainGui = create(gui, "Frame", {
	Name="MainUI", Size = UDim2.new(0, 480, 0, 300),
	Position = UDim2.new(0.5, -240, 0.45, -150), BackgroundColor3 = Color3.fromRGB(20,20,20)
})
create(mainGui, "UICorner")

-- Header
local header = create(mainGui, "TextLabel", {
	Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,0,0),
	Text="HOÀNG ANHD CLIENT", Font=Enum.Font.GothamBold, TextSize=20, TextColor3=Color3.new(1,1,1),
	BackgroundTransparency = 1
})

-- Tabs container
local left = create(mainGui, "Frame", {Size=UDim2.new(0,0,1,0), SizeConstraint = Enum.SizeConstraint.RelativeYY})
left.Size = UDim2.new(0,120,1,0)
left.Position = UDim2.new(0,0,0,40)
left.BackgroundTransparency = 1

local function makeButton(parent, y, text)
	local b = create(parent, "TextButton", {
		Size = UDim2.new(1,-10,0,36), Position = UDim2.new(0,5,0,y),
		Text = text, BackgroundColor3 = Color3.fromRGB(30,30,30), AutoButtonColor = true, TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.Gotham, TextSize = 14
	})
	create(b, "UICorner")
	return b
end

local content = create(mainGui, "Frame", {Size = UDim2.new(1,-130,1,-40), Position = UDim2.new(0,130,0,40), BackgroundTransparency = 1})

-- Tab buttons
local tabs = {"Main","Mechanics","Settings"}
local tabButtons = {}
for i,name in ipairs(tabs) do
	tabButtons[i] = makeButton(left, (i-1)*44 + 6, name)
end

-- Helpers for toggles and labels
local function addToggle(parent, ypos, labelText, default)
	local lbl = create(parent, "TextLabel", {
		Size = UDim2.new(1,0,0,28), Position=UDim2.new(0,0,ypos,0), BackgroundTransparency = 1,
		Text = labelText, TextColor3 = Color3.new(1,1,1), Font=Enum.Font.Gotham, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
	})
	local toggle = create(parent, "TextButton", {
		Size = UDim2.new(0,90,0,24), Position = UDim2.new(1,-95,ypos+2,0),
		Text = default and "ON" or "OFF", BackgroundColor3 = default and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80),
		Font = Enum.Font.Gotham, TextSize=14
	})
	create(toggle, "UICorner")
	return toggle
end

-- ---------- Mechanic states ----------
local states = {
	Speed = false,
	Fly = false,
	ESP = false,
	Godmode = false,
	AutoFarm = false,
	AutoChop = false
}
local speedValue = 32 -- default speed when speed on
local origWalkSpeed = nil

-- ---------- CONTENT: Mechanics tab ----------
local mechFrame = create(content, "Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency = 1})
local y = 4
local speedToggle = addToggle(mechFrame, y, "Speed (local)", false); y = y + 36
local flyToggle = addToggle(mechFrame, y, "Fly (local)", false); y = y + 36
local espToggle = addToggle(mechFrame, y, "ESP (players)", false); y = y + 36
local godToggle = addToggle(mechFrame, y, "Godmode (local heal)", false); y = y + 36
local autoFarmToggle = addToggle(mechFrame, y, "Auto Farm (placeholder)", false); y = y + 36
local autoChopToggle = addToggle(mechFrame, y, "Auto Chop (placeholder)", false); y = y + 36

-- Teleport buttons in Main tab
local mainFrame = create(content, "Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = true})
local tpLabel = create(mainFrame, "TextLabel", {Size=UDim2.new(1,0,0,28), Position=UDim2.new(0,0,0,6), BackgroundTransparency=1, Text="Teleports:", TextColor3=Color3.new(1,1,1), Font=Enum.Font.Gotham, TextSize=14})
local tpSpawn = create(mainFrame, "TextButton", {Size=UDim2.new(0,0,0,28), Position=UDim2.new(0,0,0,36), Text="To Spawn", TextColor3=Color3.new(1,1,1), BackgroundColor3=Color3.fromRGB(40,40,40)})
tpSpawn.Size = UDim2.new(0.3,0,0,28); create(tpSpawn, "UICorner")
local tpSafe = create(mainFrame, "TextButton", {Size=UDim2.new(0.3,0,0,28), Position=UDim2.new(0.34,0,0,36), Text="To SafeZone", TextColor3=Color3.new(1,1,1), BackgroundColor3=Color3.fromRGB(40,40,40)})
create(tpSafe, "UICorner")

-- Simple settings tab
local settingsFrame = create(content, "Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
local labelSetting = create(settingsFrame, "TextLabel", {Text="Settings", Size=UDim2.new(1,0,0,28), BackgroundTransparency=1, TextColor3=Color3.new(1,1,1)})

-- Tab switching
for i,b in ipairs(tabButtons) do
	b.MouseButton1Click:Connect(function()
		for j=1,#tabButtons do tabButtons[j].BackgroundColor3 = Color3.fromRGB(30,30,30) end
		b.BackgroundColor3 = Color3.fromRGB(60,60,60)
		-- show frames
		mainFrame.Visible = (i==1)
		mechFrame.Visible = (i==2)
		settingsFrame.Visible = (i==3)
	end)
end
-- default select first
tabButtons[1].BackgroundColor3 = Color3.fromRGB(60,60,60)

-- ---------- Feature implementations ----------
-- Speed toggle
speedToggle.MouseButton1Click:Connect(function()
	states.Speed = not states.Speed
	speedToggle.Text = states.Speed and "ON" or "OFF"
	speedToggle.BackgroundColor3 = states.Speed and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80)
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			if states.Speed then
				origWalkSpeed = hum.WalkSpeed
				hum.WalkSpeed = speedValue
			else
				if origWalkSpeed then hum.WalkSpeed = origWalkSpeed end
			end
		end
	end
end)

-- Fly (client-side)
local flyScript = nil
flyToggle.MouseButton1Click:Connect(function()
	states.Fly = not states.Fly
	flyToggle.Text = states.Fly and "ON" or "OFF"
	flyToggle.BackgroundColor3 = states.Fly and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80)
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if states.Fly then
		if hum then hum.PlatformStand = true end
		local speed = 50
		local bodyVel = Instance.new("BodyVelocity")
		bodyVel.Name = "HoangFlyBV"
		bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
		bodyVel.Velocity = Vector3.new(0,0,0)
		bodyVel.Parent = hrp
		flyScript = RunService.Heartbeat:Connect(function()
			local cam = workspace.CurrentCamera
			local dir = Vector3.new(0,0,0)
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
			if dir.Magnitude > 0.1 then
				bodyVel.Velocity = dir.Unit * speed
			else
				bodyVel.Velocity = Vector3.new(0,0,0)
			end
		end)
	else
		if flyScript then flyScript:Disconnect(); flyScript = nil end
		local bv = hrp:FindFirstChild("HoangFlyBV")
		if bv then bv:Destroy() end
		if hum then hum.PlatformStand = false end
	end
end)

-- ESP (players)
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "HoangESP"
local function addESPForPlayer(p)
	if not p.Character then return end
	if p.Character:FindFirstChild("HoangESPBillboard") then return end
	local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
	if not root then return end
	local bb = Instance.new("BillboardGui", p.Character)
	bb.Name = "HoangESPBillboard"; bb.AlwaysOnTop = true; bb.Size = UDim2.new(0,100,0,30); bb.Adornee = root
	local label = Instance.new("TextLabel", bb)
	label.Size = UDim2.new(1,1,1,1); label.BackgroundTransparency = 1; label.Text = p.Name
	label.TextColor3 = Color3.new(1,0.6,0); label.Font = Enum.Font.GothamBold; label.TextScaled = true
end
local function removeESPForPlayer(p)
	if p.Character and p.Character:FindFirstChild("HoangESPBillboard") then
		p.Character:FindFirstChild("HoangESPBillboard"):Destroy()
	end
end
espToggle.MouseButton1Click:Connect(function()
	states.ESP = not states.ESP
	espToggle.Text = states.ESP and "ON" or "OFF"
	espToggle.BackgroundColor3 = states.ESP and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80)
	if states.ESP then
		for _,p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then addESPForPlayer(p) end
		end
		Players.PlayerAdded:Connect(function(p) addESPForPlayer(p) end)
		Players.PlayerRemoving:Connect(function(p) removeESPForPlayer(p) end)
	else
		for _,p in pairs(Players:GetPlayers()) do removeESPForPlayer(p) end
	end
end)

-- Godmode (client-side heal loop)
godToggle.MouseButton1Click:Connect(function()
	states.Godmode = not states.Godmode
	godToggle.Text = states.Godmode and "ON" or "OFF"
	godToggle.BackgroundColor3 = states.Godmode and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80)
	if states.Godmode then
		spawn(function()
			while states.Godmode do
				local char = LocalPlayer.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health < hum.MaxHealth then
						hum.Health = hum.MaxHealth
					end
				end
				task.wait(0.5)
			end
		end)
	end
end)

-- Teleports (local)
tpSpawn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildWhichIsA("SpawnLocation")
	if char and spawn and spawn:IsA("BasePart") then
		char:SetPrimaryPartCFrame(spawn.CFrame + Vector3.new(0,3,0))
	end
end)
tpSafe.MouseButton1Click:Connect(function()
	-- You can set a SafeZone part in workspace named "SafeZone" for teleport target
	local safePart = workspace:FindFirstChild("SafeZone")
	if safePart and LocalPlayer.Character then
		LocalPlayer.Character:SetPrimaryPartCFrame(safePart.CFrame + Vector3.new(0,3,0))
	else
		-- fallback: teleport to origin
		LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(0,10,0))
	end
end)

-- AutoFarm / AutoChop placeholders (require server-side implementation to actually gather)
autoFarmToggle.MouseButton1Click:Connect(function()
	states.AutoFarm = not states.AutoFarm
	autoFarmToggle.Text = states.AutoFarm and "ON" or "OFF"
	autoFarmToggle.BackgroundColor3 = states.AutoFarm and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80)
	if states.AutoFarm then
		warn("AutoFarm is a placeholder in this safe client script. To actually farm, server RPCs or RemoteEvents are required.")
	end
end)
autoChopToggle.MouseButton1Click:Connect(function()
	states.AutoChop = not states.AutoChop
	autoChopToggle.Text = states.AutoChop and "ON" or "OFF"
	autoChopToggle.BackgroundColor3 = states.AutoChop and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80)
	if states.AutoChop then
		warn("AutoChop is a placeholder in this safe client script. Implement server-side handling to perform chop actions.")
	end
end)

-- End of script
print("HOÀNG ANHD CLIENT (Studio-safe) loaded.")

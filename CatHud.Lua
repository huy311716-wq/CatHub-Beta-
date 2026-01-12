--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// ROOT
local ROOT = workspace:WaitForChild("ActiveBrainrots")

--// DATA
local SelectedFolder = nil
local SelectedModel = nil
local TeleportOffset = 5

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotTeleport"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

--// MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0,0)
main.Position = UDim2.fromScale(0.28,0.18)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
	Size = UDim2.fromScale(0.45,0.6)
}):Play()

--// DRAG
do
	local drag, startPos, startInput
	main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			startInput = i.Position
			startPos = main.Position
		end
	end)
	main.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - startInput
			main.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
		end
	end)
end

--// TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0.1,0)
title.Text = "🐱 <b>CAT HUB</b>"
title.RichText = true
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

--// MINUS
local hide = Instance.new("TextButton", main)
hide.Size = UDim2.new(0,30,0,30)
hide.Position = UDim2.new(1,-70,0,10)
hide.Text = "-"
hide.Font = Enum.Font.GothamBold
hide.TextSize = 22
hide.TextColor3 = Color3.new(1,1,1)
hide.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", hide)

hide.MouseButton1Click:Connect(function()
	main.Visible = false
end)

--// CLOSE
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,10)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(180,60,60)
Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--// PANELS
local function makePanel(pos)
	local f = Instance.new("ScrollingFrame", main)
	f.Position = pos
	f.Size = UDim2.new(0.3,0,0.8,0)
	f.CanvasSize = UDim2.new(0,0,5,0)
	f.ScrollBarImageTransparency = 0.3
	f.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Instance.new("UICorner", f)
	local l = Instance.new("UIListLayout", f)
	l.Padding = UDim.new(0,6)
	return f
end

local folderList = makePanel(UDim2.new(0.02,0,0.12,0))
local modelList  = makePanel(UDim2.new(0.35,0,0.12,0))

--// RIGHT PANEL
local panel = Instance.new("Frame", main)
panel.Position = UDim2.new(0.68,0,0.12,0)
panel.Size = UDim2.new(0.3,0,0.8,0)
panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", panel)

--// UTIL
local function clear(frame)
	for _,v in ipairs(frame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
end

local function makeButton(text, parent, cb)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,-10,0,36)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextScaled = true
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(55,55,55)
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(function() cb(b) end)
	return b
end

--// LOAD MODELS
local function loadModels(folder)
	clear(modelList)
	SelectedModel = nil
	for _,m in ipairs(folder:GetChildren()) do
		if m:IsA("Model") then
			makeButton(m.Name, modelList, function(btn)
				SelectedModel = m
				for _,v in ipairs(modelList:GetChildren()) do
					if v:IsA("TextButton") then
						v.BackgroundColor3 = Color3.fromRGB(55,55,55)
					end
				end
				btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
			end)
		end
	end
end

--// LOAD FOLDERS + AUTO RELOAD
local function loadFolders()
	clear(folderList)
	for _,f in ipairs(ROOT:GetChildren()) do
		if f:IsA("Folder") then
			makeButton(f.Name, folderList, function(btn)
				SelectedFolder = f
				loadModels(f)
				for _,v in ipairs(folderList:GetChildren()) do
					if v:IsA("TextButton") then
						v.BackgroundColor3 = Color3.fromRGB(55,55,55)
					end
				end
				btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
			end)
			f.ChildAdded:Connect(function()
				if f == SelectedFolder then loadModels(f) end
			end)
			f.ChildRemoved:Connect(function()
				if f == SelectedFolder then loadModels(f) end
			end)
		end
	end
end

ROOT.ChildAdded:Connect(loadFolders)
ROOT.ChildRemoved:Connect(loadFolders)
loadFolders()

--// SLIDER
local label = Instance.new("TextLabel", panel)
label.Size = UDim2.new(1,0,0.15,0)
label.Text = "Height: 5"
label.TextScaled = true
label.Font = Enum.Font.Gotham
label.TextColor3 = Color3.new(1,1,1)
label.BackgroundTransparency = 1

local slider = Instance.new("TextButton", panel)
slider.Position = UDim2.new(0.1,0,0.18,0)
slider.Size = UDim2.new(0.8,0,0.1,0)
slider.Text = ""
slider.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", slider)

local knob = Instance.new("Frame", slider)
knob.Size = UDim2.new(0.1,0,1,0)
knob.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", knob)

local dragSlider = false
slider.MouseButton1Down:Connect(function() dragSlider = true end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragSlider = false end
end)
UIS.InputChanged:Connect(function(i)
	if dragSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
		local x = math.clamp((i.Position.X - slider.AbsolutePosition.X)/slider.AbsoluteSize.X,0,1)
		knob.Position = UDim2.fromScale(x,0)
		TeleportOffset = math.floor(2 + x*25)
		label.Text = "Height: "..TeleportOffset
	end
end)

--// TELEPORT BRAINROT
local tp = Instance.new("TextButton", panel)
tp.Position = UDim2.new(0.15,0,0.4,0)
tp.Size = UDim2.new(0.7,0,0.16,0)
tp.Text = "TELEPORT"
tp.Font = Enum.Font.GothamBold
tp.TextScaled = true
tp.TextColor3 = Color3.new(1,1,1)
tp.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", tp)

tp.MouseButton1Click:Connect(function()
	if not SelectedModel then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local part = SelectedModel.PrimaryPart or SelectedModel:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	TweenService:Create(hrp, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
		CFrame = part.CFrame + Vector3.new(0,TeleportOffset,0)
	}):Play()
end)

--// TELEPORT SPEED SHOP (RIÊNG)
local tpShop = Instance.new("TextButton", panel)
tpShop.Position = UDim2.new(0.15,0,0.58,0)
tpShop.Size = UDim2.new(0.7,0,0.16,0)
tpShop.Text = "TP SPEED SHOP"
tpShop.Font = Enum.Font.GothamBold
tpShop.TextScaled = true
tpShop.TextColor3 = Color3.new(1,1,1)
tpShop.BackgroundColor3 = Color3.fromRGB(255,170,0)
Instance.new("UICorner", tpShop)

tpShop.MouseButton1Click:Connect(function()
	local shop = workspace:FindFirstChild("SpeedShop")
	if not shop then return end
	local roof = shop:FindFirstChild("Roof")
	if not roof or not roof:IsA("BasePart") then return end

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	TweenService:Create(hrp, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
		CFrame = roof.CFrame + Vector3.new(0,6,0)
	}):Play()
end)

--// DELETE TSUNAMI
local del = Instance.new("TextButton", main)
del.Size = UDim2.new(1,-20,0,40)
del.Position = UDim2.new(0,10,1,-50)
del.Text = "DELETE TSUNAMI Script By Huy"
del.Font = Enum.Font.GothamBold
del.TextScaled = true
del.TextColor3 = Color3.new(1,1,1)
del.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", del)

del.MouseButton1Click:Connect(function()
	local box = Instance.new("Frame", gui)
	box.Size = UDim2.fromScale(0.3,0.2)
	box.Position = UDim2.fromScale(0.35,0.4)
	box.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Instance.new("UICorner", box)

	local txt = Instance.new("TextLabel", box)
	txt.Size = UDim2.new(1,0,0.5,0)
	txt.Text = "Delete Tsunami???"
	txt.TextScaled = true
	txt.Font = Enum.Font.GothamBold
	txt.TextColor3 = Color3.new(1,1,1)
	txt.BackgroundTransparency = 1

	local function btn(text,pos,cb)
		local b = Instance.new("TextButton", box)
		b.Size = UDim2.new(0.4,0,0.25,0)
		b.Position = pos
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextScaled = true
		b.TextColor3 = Color3.new(1,1,1)
		b.BackgroundColor3 = Color3.fromRGB(80,80,80)
		Instance.new("UICorner", b)
		b.MouseButton1Click:Connect(cb)
	end

	btn("No", UDim2.new(0.05,0,0.65,0), function() box:Destroy() end)
	btn("Yee",UDim2.new(0.55,0,0.65,0), function()
		if workspace:FindFirstChild("ActiveTsunamis") then
			workspace.ActiveTsunamis:Destroy()
		end
		box:Destroy()
	end)
end)

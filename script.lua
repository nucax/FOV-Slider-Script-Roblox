local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "nucaxemGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 270, 0, 140)
frame.Position = UDim2.new(0.35, 0, 0.7, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = false
frame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "nucaxem"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0.5, -12)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -60, 0.5, -12)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextScaled = true
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = titleBar

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

local sliderBackground = Instance.new("Frame")
sliderBackground.Size = UDim2.new(0.8, 0, 0, 10)
sliderBackground.Position = UDim2.new(0.1, 0, 0.45, 0)
sliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBackground.BorderSizePixel = 0
sliderBackground.Parent = contentFrame

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 20, 0, 20)
sliderKnob.Position = UDim2.new(0, -10, 0.5, -10)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBackground

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, 0, 0, 25)
valueLabel.Position = UDim2.new(0, 0, 0.65, 10)
valueLabel.BackgroundTransparency = 1
valueLabel.Font = Enum.Font.Gotham
valueLabel.TextScaled = true
valueLabel.Parent = contentFrame

local MIN_FOV = 50
local MAX_FOV = 120
local DEFAULT_FOV = 70

local draggingSlider = false
local draggingFrame = false
local dragOffset = Vector2.new()
local minimized = false

local function setFOV(relative)
	local fov = MIN_FOV + (MAX_FOV - MIN_FOV) * relative
	camera.FieldOfView = fov
	valueLabel.Text = "FOV: " .. math.floor(fov)
	sliderKnob.Position = UDim2.new(relative, -10, 0.5, -10)
end

local function fovToRelative(fov)
	return math.clamp((fov - MIN_FOV) / (MAX_FOV - MIN_FOV), 0, 1)
end

local function updateSlider(inputX)
	local relative = math.clamp((inputX - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
	setFOV(relative)
end

sliderKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider = true
	end
end)

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingFrame = true
		local mousePos = input.Position
		dragOffset = Vector2.new(mousePos.X - frame.AbsolutePosition.X, mousePos.Y - frame.AbsolutePosition.Y)
	end
end)

userInput.InputChanged:Connect(function(input)
	if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateSlider(input.Position.X)
	elseif draggingFrame and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local newPos = UDim2.new(0, input.Position.X - dragOffset.X, 0, input.Position.Y - dragOffset.Y)
		frame.Position = newPos
	end
end)

userInput.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider = false
		draggingFrame = false
	end
end)

closeButton.MouseButton1Click:Connect(function()
	frame.Visible = false
	camera.FieldOfView = DEFAULT_FOV
end)

minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	contentFrame.Visible = not minimized
	if minimized then
		frame.Size = UDim2.new(0, 270, 0, 30)
	else
		frame.Size = UDim2.new(0, 270, 0, 140)
	end
end)

local hue = 0
runService.RenderStepped:Connect(function()
	hue = (hue + 0.005) % 1
	local rainbow = Color3.fromHSV(hue, 1, 1)
	title.TextColor3 = rainbow
	valueLabel.TextColor3 = rainbow
	closeButton.TextColor3 = rainbow
	minimizeButton.TextColor3 = rainbow
	sliderBackground.BackgroundColor3 = rainbow
end)

setFOV(fovToRelative(DEFAULT_FOV))

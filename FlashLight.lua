--------------------------
--        CREDITS
--------------------------
-- Made by Stormwindsky on GitHub
--------------------------
-- Icon by @tonypoor12323 (flashlight)
-- Here: https://www.roblox.com/users/1563844617/profile
--------------------------
-- Icon by @compititivetop (setting)
-- Here: https://www.roblox.com/users/3343725401/profile
--------------------------

local plugin = plugin or getfenv().plugin

local PLUGIN_NAME = "Flashlight"
local FLASHLIGHT_ICON = "rbxassetid://11148000249"
local SETTINGS_ICON = "rbxassetid://120891902776526"

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Selection = game:GetService("Selection")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

-- Default light settings
local LIGHT_SETTINGS = {
	Intensity = 10,
	Range = 50,
	Angle = 70,
	Color = Color3.fromRGB(255, 255, 255)
}

-- Plugin state
local states = {
	flashlight = {
		enabled = false,
		light = nil,
		attachment = nil,
		connection = nil
	}
}

-- Create toolbar
local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local flashlightButton = toolbar:CreateButton("Toggle Flashlight", "Toggle flashlight on/off", FLASHLIGHT_ICON)
local settingsButton = toolbar:CreateButton("Flashlight Settings", "Open flashlight configuration", SETTINGS_ICON)

-- Modern UI components
local function createModernFrame(parent, size, position, transparency)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = transparency
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(60, 60, 60)
	stroke.Thickness = 1
	stroke.Parent = frame

	frame.Parent = parent
	return frame
end

local function createModernLabel(parent, text, size, position)
	local label = Instance.new("TextLabel")
	label.Text = text
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	return label
end

local function createModernButton(parent, text, size, position)
	local button = Instance.new("TextButton")
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.fromRGB(220, 220, 220)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.AutoButtonColor = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 80, 80)
	stroke.Thickness = 1
	stroke.Parent = button

	-- Hover effects
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
	end)

	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
	end)

	button.Parent = parent
	return button
end

local function createModernTextBox(parent, size, position, placeholder)
	local textBox = Instance.new("TextBox")
	textBox.Size = size
	textBox.Position = position
	textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 14
	textBox.PlaceholderText = placeholder
	textBox.ClearTextOnFocus = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = textBox

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 70, 70)
	stroke.Thickness = 1
	stroke.Parent = textBox

	-- Focus effects
	textBox.Focused:Connect(function()
		TweenService:Create(textBox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
		TweenService:Create(textBox.UIStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(100, 100, 255)}):Play()
	end)

	textBox.FocusLost:Connect(function()
		TweenService:Create(textBox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
		TweenService:Create(textBox.UIStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 70)}):Play()
	end)

	textBox.Parent = parent
	return textBox
end

-- GUI for settings
local function createSettingsGui()
	local dockWidget = plugin:CreateDockWidgetPluginGui(
		"FlashlightSettings",
		DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
			false,
			false,
			250,
			350,
			250,
			350
		)
	)
	dockWidget.Title = "Flashlight Settings"
	dockWidget.Name = "FlashlightSettings"
	dockWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main container
	local mainFrame = createModernFrame(dockWidget, UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), 0.5)

	local uiList = Instance.new("UIListLayout")
	uiList.Padding = UDim.new(0, 12)
	uiList.Parent = mainFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = mainFrame

	-- Title
	local title = createModernLabel(mainFrame, "FLASHLIGHT SETTINGS", UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 0))
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(200, 200, 255)

	local function addSlider(name, min, max, default, callback)
		local container = createModernFrame(mainFrame, UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 0), 1)
		container.BackgroundTransparency = 1

		local label = createModernLabel(container, name, UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0))

		local sliderContainer = createModernFrame(container, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 25), 0.8)

		local valueBox = createModernTextBox(sliderContainer, UDim2.new(0.3, 0, 1, 0), UDim2.new(0.7, 5, 0, 0), tostring(default))
		valueBox.Text = tostring(default)

		local function updateValue(value)
			if value and value >= min and value <= max then
				valueBox.Text = tostring(math.floor(value * 10) / 10)
				callback(value)
			else
				valueBox.Text = tostring(default)
			end
		end

		valueBox.FocusLost:Connect(function()
			local value = tonumber(valueBox.Text)
			updateValue(value)
		end)

		local sliderButton = createModernButton(sliderContainer, "", UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 0, 0, 0))
		sliderButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		sliderButton.AutoButtonColor = false

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
		fill.BorderSizePixel = 0
		fill.Parent = sliderButton

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = fill

		local dragging = false

		sliderButton.MouseButton1Down:Connect(function()
			dragging = true
		end)

		sliderButton.MouseButton1Up:Connect(function()
			dragging = false
		end)

		game:GetService("UserInputService").InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		sliderButton.MouseMoved:Connect(function()
			if dragging then
				local x = (sliderButton.AbsolutePosition.X - sliderButton.AbsoluteSize.X) + game:GetService("UserInputService"):GetMouseLocation().X
				local percent = math.clamp(x / sliderButton.AbsoluteSize.X, 0, 1)
				local value = min + (max - min) * percent
				fill.Size = UDim2.new(percent, 0, 1, 0)
				updateValue(value)
			end
		end)
	end

	local function addColorInput(callback)
		local container = createModernFrame(mainFrame, UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 0), 1)
		container.BackgroundTransparency = 1

		local label = createModernLabel(container, "COLOR (R,G,B)", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0))

		local colorBox = createModernTextBox(container, UDim2.new(0.6, 0, 0, 30), UDim2.new(0, 0, 0, 25), "255, 255, 255")
		colorBox.Text = table.concat({math.floor(LIGHT_SETTINGS.Color.R * 255), math.floor(LIGHT_SETTINGS.Color.G * 255), math.floor(LIGHT_SETTINGS.Color.B * 255)}, ", ")

		local preview = createModernFrame(container, UDim2.new(0.35, 0, 0, 30), UDim2.new(0.65, 5, 0, 25), 0)
		preview.BackgroundColor3 = LIGHT_SETTINGS.Color

		colorBox.FocusLost:Connect(function()
			local parts = {}
			for part in colorBox.Text:gmatch("%d+") do
				table.insert(parts, tonumber(part))
			end

			if #parts == 3 then
				local r = math.clamp(parts[1], 0, 255)
				local g = math.clamp(parts[2], 0, 255)
				local b = math.clamp(parts[3], 0, 255)

				local newColor = Color3.fromRGB(r, g, b)
				LIGHT_SETTINGS.Color = newColor
				preview.BackgroundColor3 = newColor
				colorBox.Text = table.concat({r, g, b}, ", ")

				if states.flashlight.light then
					states.flashlight.light.Color = newColor
				end
			else
				colorBox.Text = table.concat({
					math.floor(LIGHT_SETTINGS.Color.R * 255),
					math.floor(LIGHT_SETTINGS.Color.G * 255),
					math.floor(LIGHT_SETTINGS.Color.B * 255)
				}, ", ")
			end
		end)

		-- Also add color picker button for convenience
		local pickerButton = createModernButton(container, "Pick Color", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 60))

		pickerButton.MouseButton1Click:Connect(function()
			local success, newColor = pcall(function()
				return GuiService:OpenColorPicker(LIGHT_SETTINGS.Color)
			end)

			if success and newColor then
				LIGHT_SETTINGS.Color = newColor
				preview.BackgroundColor3 = newColor
				colorBox.Text = table.concat({
					math.floor(newColor.R * 255),
					math.floor(newColor.G * 255),
					math.floor(newColor.B * 255)
				}, ", ")

				if states.flashlight.light then
					states.flashlight.light.Color = newColor
				end
			end
		end)
	end

	-- Add sliders for each setting
	addSlider("INTENSITY", 0, 50, LIGHT_SETTINGS.Intensity, function(value)
		LIGHT_SETTINGS.Intensity = value
		if states.flashlight.light then
			states.flashlight.light.Brightness = value
		end
	end)

	addSlider("RANGE", 10, 200, LIGHT_SETTINGS.Range, function(value)
		LIGHT_SETTINGS.Range = value
		if states.flashlight.light then
			states.flashlight.light.Range = value
		end
	end)

	addSlider("ANGLE", 10, 120, LIGHT_SETTINGS.Angle, function(value)
		LIGHT_SETTINGS.Angle = value
		if states.flashlight.light then
			states.flashlight.light.Angle = value
		end
	end)

	-- Add color input
	addColorInput(function(color)
		LIGHT_SETTINGS.Color = color
	end)

	-- Animation when opening
	mainFrame.Size = UDim2.new(1, -20, 0, 0)
	mainFrame.Position = UDim2.new(0, 10, 0, 10)

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(1, -20, 1, -20)}):Play()

	return dockWidget
end

local settingsGui = createSettingsGui()
settingsGui.Enabled = false

-- Flashlight logic (unchanged from original)
local function createLight()
	if states.flashlight.light then states.flashlight.light:Destroy() end
	if states.flashlight.attachment then states.flashlight.attachment:Destroy() end

	states.flashlight.attachment = Instance.new("Attachment")
	states.flashlight.attachment.Name = "EditorFlashlightAttachment"
	states.flashlight.attachment.Parent = Workspace.Terrain

	states.flashlight.light = Instance.new("SpotLight")
	states.flashlight.light.Name = "EditorFlashlight"
	states.flashlight.light.Brightness = LIGHT_SETTINGS.Intensity
	states.flashlight.light.Range = LIGHT_SETTINGS.Range
	states.flashlight.light.Angle = LIGHT_SETTINGS.Angle
	states.flashlight.light.Color = LIGHT_SETTINGS.Color
	states.flashlight.light.Shadows = true
	states.flashlight.light.Parent = states.flashlight.attachment
end

local function updateLightPosition()
	if not states.flashlight.light or not states.flashlight.attachment then return end
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local cameraCFrame = camera.CFrame
	states.flashlight.attachment.WorldCFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + cameraCFrame.LookVector) * CFrame.new(0, 0, -2)
end

local function enableFlashlight()
	if states.flashlight.enabled then return end
	createLight()
	states.flashlight.connection = RunService.RenderStepped:Connect(updateLightPosition)
	states.flashlight.enabled = true
	flashlightButton:SetActive(true)
end

local function disableFlashlight()
	if not states.flashlight.enabled then return end
	if states.flashlight.connection then
		states.flashlight.connection:Disconnect()
		states.flashlight.connection = nil
	end
	if states.flashlight.light then
		states.flashlight.light:Destroy()
		states.flashlight.light = nil
	end
	if states.flashlight.attachment then
		states.flashlight.attachment:Destroy()
		states.flashlight.attachment = nil
	end
	states.flashlight.enabled = false
	flashlightButton:SetActive(false)
end

-- Button connections
flashlightButton.Click:Connect(function()
	if states.flashlight.enabled then
		disableFlashlight()
	else
		enableFlashlight()
	end
end)

settingsButton.Click:Connect(function()
	settingsGui.Enabled = not settingsGui.Enabled
end)

-- Cleanup
plugin.Unloading:Connect(function()
	disableFlashlight()
	if settingsGui then
		settingsGui:Destroy()
	end
end)

print(PLUGIN_NAME .. " loaded successfully with modernized GUI!")

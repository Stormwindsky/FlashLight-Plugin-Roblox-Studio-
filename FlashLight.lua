


--------------------------


--        𝗖𝗥𝗘𝗗𝗜𝗧𝗦



--------------------------



-- Made by Stormwindsky on GitHub

--------------------------

--------------------------

-- Icon by @tonypoor12323 (flashlight)
-- Here: https://www.roblox.com/users/1563844617/profile

--------------------------

--------------------------



-- Icon by @compititivetop (setting)
-- Here: https://www.roblox.com/users/3343725401/profile



local plugin = plugin or getfenv().plugin

local PLUGIN_NAME = "Flashlight"
local FLASHLIGHT_ICON = "rbxassetid://11148000249"
local SETTINGS_ICON = "rbxassetid://120891902776526"

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Selection = game:GetService("Selection")
local GuiService = game:GetService("GuiService")

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

-- GUI for settings
local function createSettingsGui()
	local dockWidget = plugin:CreateDockWidgetPluginGui(
		"FlashlightSettings",
		DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
			false,
			false,
			200,
			300,
			200,
			300
		)
	)
	dockWidget.Title = "Flashlight Settings"

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	frame.Parent = dockWidget

	local uiList = Instance.new("UIListLayout")
	uiList.Padding = UDim.new(0, 10)
	uiList.Parent = frame

	local function addSlider(name, min, max, default, callback)
		local label = Instance.new("TextLabel")
		label.Text = name .. ": " .. default
		label.Size = UDim2.new(1, 0, 0, 30)
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.Parent = frame

		local slider = Instance.new("TextBox")
		slider.Text = tostring(default)
		slider.Size = UDim2.new(1, 0, 0, 30)
		slider.ClearTextOnFocus = false
		slider.Parent = frame

		slider.FocusLost:Connect(function()
			local value = tonumber(slider.Text)
			if value and value >= min and value <= max then
				callback(value)
				label.Text = name .. ": " .. value
			end
		end)
	end

	local function addColorPicker(callback)
		local label = Instance.new("TextLabel")
		label.Text = "Color"
		label.Size = UDim2.new(1, 0, 0, 30)
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.Parent = frame

		local colorButton = Instance.new("TextButton")
		colorButton.Text = "Choose Color"
		colorButton.Size = UDim2.new(1, 0, 0, 30)
		colorButton.Parent = frame

		colorButton.MouseButton1Click:Connect(function()
			local success, newColor = pcall(function()
				return GuiService:OpenColorPicker(LIGHT_SETTINGS.Color)
			end)
			if success and newColor then
				LIGHT_SETTINGS.Color = newColor
				if states.flashlight.light then
					states.flashlight.light.Color = newColor
				end
			end
		end)
	end

	addSlider("Intensity", 0, 50, LIGHT_SETTINGS.Intensity, function(value)
		LIGHT_SETTINGS.Intensity = value
		if states.flashlight.light then
			states.flashlight.light.Brightness = value
		end
	end)

	addSlider("Range", 10, 200, LIGHT_SETTINGS.Range, function(value)
		LIGHT_SETTINGS.Range = value
		if states.flashlight.light then
			states.flashlight.light.Range = value
		end
	end)

	addSlider("Angle", 10, 120, LIGHT_SETTINGS.Angle, function(value)
		LIGHT_SETTINGS.Angle = value
		if states.flashlight.light then
			states.flashlight.light.Angle = value
		end
	end)

	addColorPicker(function(color)
		LIGHT_SETTINGS.Color = color
	end)

	return dockWidget
end

local settingsGui = createSettingsGui()

-- Flashlight logic
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
	print("Flashlight enabled")
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
	print("Flashlight disabled")
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

print(PLUGIN_NAME .. " loaded successfully with GUI settings!")
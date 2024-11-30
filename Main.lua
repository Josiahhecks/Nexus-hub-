local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Nexus Hub", "Ocean")

-- Create Toggle Button
local ToggleGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("ImageButton")

-- GUI Settings
ToggleGui.Name = "ToggleGui"
ToggleGui.Parent = game:GetService("CoreGui")
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.ResetOnSpawn = false

-- Button Settings
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ToggleGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Position = UDim2.new(0.120833337, 0, 0.0952890813, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Image = "rbxassetid://7072725342" -- Toilet icon
ToggleButton.Draggable = true
ToggleButton.Active = true

-- Toggle Function
ToggleButton.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-- Main Tab
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Player Modifications")

MainSection:NewSlider("WalkSpeed", "Changes your walk speed", 500, 16, function(s)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

MainSection:NewSlider("JumpPower", "Changes your jump power", 350, 50, function(s)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
end)

MainSection:NewToggle("Infinite Jump", "Lets you jump infinitely", function(state)
    local InfiniteJumpEnabled = state
    game:GetService("UserInputService").JumpRequest:connect(function()
        if InfiniteJumpEnabled then
            game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
        end
    end)
end)

-- Visual Tab
local VisualTab = Window:NewTab("Visual")
local VisualSection = VisualTab:NewSection("Visual Modifications")

VisualSection:NewToggle("Full Bright", "Makes everything bright", function(state)
    if state then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").ClockTime = 12
        game:GetService("Lighting").FogEnd = 10000
        game:GetService("Lighting").GlobalShadows = true
    end
end)

-- Teleport Tab
local TeleportTab = Window:NewTab("Teleport")
local TeleportSection = TeleportTab:NewSection("Teleport Options")

TeleportSection:NewButton("Teleport to Random Player", "Teleports to a random player", function()
    local players = game:GetService("Players"):GetPlayers()
    local randomPlayer = players[math.random(1, #players)]
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame
end)

-- Combat Tab
local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Combat Features")

CombatSection:NewToggle("Auto Click", "Automatically clicks for you", function(state)
    getgenv().AutoClick = state
    while getgenv().AutoClick do
        wait(0.1)
        game:GetService("VirtualUser"):ClickButton1(Vector2.new())
    end
end)

-- Settings Tab
local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("UI Settings")

SettingsSection:NewKeybind("Toggle UI", "Toggle the UI visibility", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)

-- Credits Tab
local CreditsTab = Window:NewTab("Credits")
local CreditsSection = CreditsTab:NewSection("Created by Josiah")
CreditsSection:NewLabel("UI Library: Kavo UI")

-- Make the toggle button draggable
local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

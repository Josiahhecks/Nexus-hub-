local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/azure"))()

-- Create Nexus toggle button
local ToggleGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")

ToggleGui.Name = "NexusToggle"
ToggleGui.Parent = game:GetService("CoreGui")

ToggleButton.Name = "NexusButton"
ToggleButton.Parent = ToggleGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0.120833337, 0, 0.0952890813, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Image = "rbxassetid://18191179258"
ToggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)

UICorner.CornerRadius = UDim.new(0.2, 0)
UICorner.Parent = ToggleButton

-- Make toggle button draggable
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

-- Main Window
local Window = Library:CreateWindow("Nexus Hub", "V3.0", 10044538000)

-- Tabs
local MainTab = Window:Tab("Main")
local CombatTab = Window:Tab("Combat")
local VisualTab = Window:Tab("Visual")
local TrollTab = Window:Tab("Troll")
local MiscTab = Window:Tab("Misc")

-- Main Tab Features
MainTab:Toggle("WalkSpeed Boost", "Increases your walking speed", false, function(state)
    if state then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

MainTab:Toggle("Jump Boost", "Increases your jump power", false, function(state)
    if state then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
    else
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

MainTab:Toggle("Infinite Jump", "Allows infinite jumping", false, function(state)
    _G.InfJump = state
    game:GetService("UserInputService").JumpRequest:connect(function()
        if _G.InfJump then
            game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
        end
    end)
end)

-- Combat Tab Features
CombatTab:Toggle("Kill Aura", "Automatically damages nearby players", false, function(state)
    _G.KillAura = state
    while _G.KillAura and task.wait() do
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 15 then
                    local args = {
                        [1] = player.Character.Humanoid
                    }
                    game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
                end
            end
        end
    end
end)

-- Visual Tab Features
VisualTab:Toggle("ESP", "See players through walls", false, function(state)
    _G.ESP = state
    while _G.ESP and task.wait(1) do
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                if not player.Character:FindFirstChild("Highlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end)

VisualTab:Toggle("Full Bright", "Makes everything bright", false, function(state)
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

-- Troll Tab Features
TrollTab:Toggle("Chat Spam", "Spams the chat", false, function(state)
    _G.ChatSpam = state
    local messages = {
        "Nexus Hub on top!",
        "Get good!",
        "L + Ratio",
        "EZ WIN",
        "Too easy!",
        "Skills issue detected"
    }
    
    while _G.ChatSpam and task.wait(1) do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(messages[math.random(1, #messages)], "All")
    end
end)

TrollTab:Toggle("Fling All", "Flings nearby players", false, function(state)
    _G.Fling = state
    local player = game.Players.LocalPlayer
    while _G.Fling and task.wait() do
        for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                player.Character.HumanoidRootPart.CFrame = otherPlayer.Character.HumanoidRootPart.CFrame
                player.Character.HumanoidRootPart.Velocity = Vector3.new(500, 500, 500)
            end
        end
    end
end)

-- Misc Tab Features
MiscTab:Toggle("Noclip", "Walk through walls", false, function(state)
    _G.Noclip = state
    game:GetService('RunService').Stepped:Connect(function()
        if _G.Noclip then
            for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA('BasePart') then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

MiscTab:Toggle("Anti AFK", "Prevents being kicked for idling", false, function(state)
    _G.AntiAFK = state
    while _G.AntiAFK and task.wait(60) do
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Toggle UI with button
ToggleButton.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

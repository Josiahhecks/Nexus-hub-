-- Nexus Hub V3.0 Ultimate
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Create Window
local Window = Library:CreateWindow({
    Title = 'Nexus Hub V3.0 Ultimate',
    Center = true, 
    AutoShow = true,
})

-- Create Tabs
local Tabs = {
    Main = Window:AddTab('Main'),
    Combat = Window:AddTab('Combat'),
    Visual = Window:AddTab('Visual'),
    Movement = Window:AddTab('Movement'),
    Teleport = Window:AddTab('Teleport'),
    World = Window:AddTab('World'),
    Troll = Window:AddTab('Troll'),
    Misc = Window:AddTab('Misc'),
    Settings = Window:AddTab('Settings'),
}

-- Main Tab Features
local MainBox = Tabs.Main:AddLeftGroupbox('Character Modifications')

MainBox:AddSlider('WalkSpeed', {
    Text = 'Walk Speed',
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

MainBox:AddSlider('JumpPower', {
    Text = 'Jump Power',
    Default = 50,
    Min = 50,
    Max = 350,
    Rounding = 0,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

local MainBox2 = Tabs.Main:AddRightGroupbox('Character States')

MainBox2:AddToggle('GodMode', {
    Text = 'God Mode',
    Default = false,
    Callback = function(Value)
        if Value then
            local Character = game.Players.LocalPlayer.Character
            if Character then
                local Clone = Character:Clone()
                Clone.Parent = game.Workspace
                Character.Humanoid.BreakJointsOnDeath = false
                Character.Humanoid.Health = math.huge
            end
        end
    end
})

-- Combat Features
local CombatLeft = Tabs.Combat:AddLeftGroupbox('Combat')

CombatLeft:AddToggle('KillAura', {
    Text = 'Kill Aura',
    Default = false,
    Callback = function(Value)
        _G.KillAura = Value
        while _G.KillAura and task.wait() do
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
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
    end
})

-- Visual Features
local VisualLeft = Tabs.Visual:AddLeftGroupbox('ESP Features')

VisualLeft:AddToggle('PlayerESP', {
    Text = 'Player ESP',
    Default = false,
    Callback = function(Value)
        _G.ESP = Value
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
    end
})

-- Troll Features
local TrollLeft = Tabs.Troll:AddLeftGroupbox('Troll Features')

TrollLeft:AddToggle('FlingAll', {
    Text = 'Fling All Players',
    Default = false,
    Callback = function(Value)
        _G.Fling = Value
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            while _G.Fling and task.wait() do
                for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = otherPlayer.Character.HumanoidRootPart.CFrame
                        character.HumanoidRootPart.Velocity = Vector3.new(500, 500, 500)
                    end
                end
            end
        end
    end
})

TrollLeft:AddToggle('ChatSpam', {
    Text = 'Chat Spam',
    Default = false,
    Callback = function(Value)
        _G.ChatSpam = Value
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
    end
})

-- Movement Features
local MovementLeft = Tabs.Movement:AddLeftGroupbox('Movement')

MovementLeft:AddToggle('Flight', {
    Text = 'Flight',
    Default = false,
    Callback = function(Value)
        _G.Flight = Value
        local player = game.Players.LocalPlayer
        while _G.Flight and task.wait() do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
            end
        end
    end
})

MovementLeft:AddToggle('Noclip', {
    Text = 'Noclip',
    Default = false,
    Callback = function(Value)
        _G.Noclip = Value
        game:GetService('RunService').Stepped:Connect(function()
            if _G.Noclip then
                for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA('BasePart') then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
})

-- World Features
local WorldLeft = Tabs.World:AddLeftGroupbox('World Modifications')

WorldLeft:AddToggle('FullBright', {
    Text = 'Full Bright',
    Default = false,
    Callback = function(Value)
        if Value then
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
    end
})

-- Settings
local SettingsBox = Tabs.Settings:AddLeftGroupbox('Menu Settings')

-- Add Theme Manager
ThemeManager:ApplyToGroupbox(SettingsBox)

-- Add Save Manager
local SaveBox = Tabs.Settings:AddRightGroupbox('Save/Load Configuration')
SaveManager:ApplyToGroupbox(SaveBox)

-- Initialize
SaveManager:LoadAutoloadConfig()

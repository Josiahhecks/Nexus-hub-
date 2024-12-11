local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedHub/main/source"))()

-- Services
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Balls = workspace:WaitForChild("Balls", 9e9)

-- Global variables
local visualise = false
local distanceMultiplier = 1
local sphereColor = Color3.fromRGB(255, 0, 0)
local sphereTransparency = 0.5
local autoParryEnabled = false
local autoSpamEnabled = false
local spamInterval = 0.1

-- Core functions
local function get_player()
    return Players.LocalPlayer
end

local function get_character()
    local player = get_player()
    return player and player.Character
end

local function get_humanoid_root_part()
    local char = get_character()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function get_ball()
    local ballContainer = workspace:FindFirstChild("Balls")
    if not ballContainer then return nil end
    
    for _, v in pairs(ballContainer:GetChildren()) do
        if not v.Anchored then
            return v
        end
    end
    return nil
end

local function calculate_parry_distance()
    local ball = get_ball()
    if ball then
        local ping = get_player():GetNetworkPing() * 20
        return math.clamp(ball.Velocity.Magnitude / 2.4 + ping, 15, 200)
    end
    return 15
end

-- Create main window
local Window = Library:Window({
    Text = "Velocity Hub"
})

-- Combat section
local CombatTab = Window:Tab({
    Text = "Combat"
})

CombatTab:Toggle({
    Text = "Auto Parry",
    Callback = function(state)
        autoParryEnabled = state
    end
})

CombatTab:Toggle({
    Text = "Auto Spam",
    Callback = function(state)
        autoSpamEnabled = state
        while autoSpamEnabled do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(spamInterval)
        end
    end
})

CombatTab:Slider({
    Text = "Spam Interval",
    Min = 0.05,
    Max = 0.5,
    Default = 0.1,
    Callback = function(value)
        spamInterval = value
    end
})

-- Visual section
local VisualTab = Window:Tab({
    Text = "Visual"
})

VisualTab:Toggle({
    Text = "Show Range",
    Callback = function(state)
        visualise = state
    end
})

VisualTab:ColorPicker({
    Text = "Range Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        sphereColor = color
    end
})

VisualTab:Slider({
    Text = "Transparency",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        sphereTransparency = value / 100
    end
})

-- Info section
local InfoTab = Window:Tab({
    Text = "Info"
})

local playerInfo = InfoTab:Label({
    Text = "Loading player info..."
})

-- Update player stats
spawn(function()
    while wait(5) do
        local stats = string.format([[
Player: %s
Account Age: %d days
Ping: %d ms]], 
        Player.Name,
        Player.AccountAge,
        math.floor(Player:GetNetworkPing() * 1000))
        
        playerInfo:Set(stats)
    end
end)

-- Visualizer creation and monitoring
local function create_visualizer()
    local sphere = Instance.new("Part")
    sphere.Name = "ParryVisualizer"
    sphere.Shape = Enum.PartType.Ball
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.CastShadow = false
    sphere.Transparency = sphereTransparency
    sphere.Material = Enum.Material.ForceField
    sphere.Parent = workspace

    local function update_visualizer()
        if not visualise then
            sphere.Transparency = 1
            return
        end

        local humanoidRootPart = get_humanoid_root_part()
        if not humanoidRootPart then
            sphere.Transparency = 1
            return
        end

        sphere.Transparency = sphereTransparency
        local parryDistance = calculate_parry_distance() * distanceMultiplier
        sphere.Size = Vector3.new(parryDistance * 2, parryDistance * 2, parryDistance * 2)
        sphere.Position = humanoidRootPart.Position
        sphere.Color = sphereColor
    end

    local function is_ball_within_visualizer(ball)
        local humanoidRootPart = get_humanoid_root_part()
        if not humanoidRootPart or not ball then
            return false
        end
        local distance = (humanoidRootPart.Position - ball.Position).Magnitude
        return distance <= sphere.Size.X / 2
    end

    local function parry_if_valid(ball)
        if autoParryEnabled and ball and is_ball_within_visualizer(ball) and Player.Character:FindFirstChild("Highlight") then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end

    local function monitor_visualizer()
        RunService.RenderStepped:Connect(function()
            update_visualizer()
            local ball = get_ball()
            parry_if_valid(ball)
        end)

        local player = get_player()
        if player then
            player.CharacterAdded:Connect(function()
                task.wait(0.1)
                if visualise then
                    update_visualizer()
                end
            end)
        end
    end

    monitor_visualizer()
end

create_visualizer()

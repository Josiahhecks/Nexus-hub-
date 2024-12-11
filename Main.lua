local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

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

-- Combat settings
local autoParryModes = {
    normal = {
        enabled = false,
        delay = 0.5
    },
    aggressive = {
        enabled = false,
        delay = 0.25
    }
}

local spamModes = {
    manual = false,
    auto = false,
    interval = 0.1
}

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

local function getPlayerStats()
    local stats = {
        coins = Player.leaderstats.Coins.Value,
        skills = #Player.Skills:GetChildren(),
        swords = #Player.Inventory.Swords:GetChildren(),
        wins = Player.leaderstats.Wins.Value,
        level = Player.leaderstats.Level.Value
    }
    return stats
end

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Velocity Hub V2",
    LoadingTitle = "Velocity Hub",
    LoadingSubtitle = "by VelocityTeam",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VelocityConfig",
        FileName = "BladeConfig"
    }
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "Enhanced Auto Parry",
    CurrentValue = false,
    Flag = "enhancedParry",
    Callback = function(Value)
        autoParryModes.normal.enabled = Value
    end
})

CombatTab:CreateToggle({
    Name = "Aggressive Auto Parry",
    CurrentValue = false,
    Flag = "aggressiveParry",
    Callback = function(Value)
        autoParryModes.aggressive.enabled = Value
    end
})

CombatTab:CreateToggle({
    Name = "Auto Spam",
    CurrentValue = false,
    Flag = "autoSpam",
    Callback = function(Value)
        spamModes.auto = Value
        while spamModes.auto do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(spamModes.interval)
        end
    end
})

CombatTab:CreateKeybind({
    Name = "Manual Spam",
    CurrentKeybind = "X",
    HoldToInteract = true,
    Flag = "manualSpam",
    Callback = function(Value)
        while Value do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(0.1)
        end
    end
})

-- Visual Tab
local VisualTab = Window:CreateTab("Visual", 4483345998)

VisualTab:CreateToggle({
    Name = "Show Parry Range",
    CurrentValue = false,
    Flag = "parryVisual",
    Callback = function(Value)
        visualise = Value
    end
})

VisualTab:CreateColorPicker({
    Name = "Visualizer Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "visualColor",
    Callback = function(Value)
        sphereColor = Value
    end
})

VisualTab:CreateSlider({
    Name = "Visualizer Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Flag = "visualTransparency",
    Callback = function(Value)
        sphereTransparency = Value
    end
})

-- Stats Tab
local StatsTab = Window:CreateTab("Player Info", 4483345998)
local statsLabel = StatsTab:CreateLabel("Loading stats...")

-- Update stats periodically
spawn(function()
    while task.wait(5) do
        local stats = getPlayerStats()
        statsLabel:Set(string.format([[
Player: %s
Account Age: %d days
Coins: %d
Skills Unlocked: %d
Swords Owned: %d
Wins: %d
Level: %d
]], Player.Name, Player.AccountAge, stats.coins, stats.skills, stats.swords, stats.wins, stats.level))
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
        if ball and is_ball_within_visualizer(ball) and Player.Character:FindFirstChild("Highlight") then
            if autoParryModes.aggressive.enabled then
                task.wait(autoParryModes.aggressive.delay)
            elseif autoParryModes.normal.enabled then
                task.wait(autoParryModes.normal.delay)
            end
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

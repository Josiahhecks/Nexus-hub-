local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/stysscythe/script/main/LibTest.lua"))()

local Window = Library.Window('Nexus Hub V1')

-- Initialize Tabs
local MainTab = Window.CreateTab('Core')
local VisualTab = Window.CreateTab('Graphics')
local CameraTab = Window.CreateTab('Camera')
local PlayerTab = Window.CreateTab('Player')
local WorldTab = Window.CreateTab('World')

-- Core Features
MainTab.CreateDivider("Essential Features")

MainTab.CreateToggle("Auto Re-join", function(state)
    if state then
        game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == 'ErrorPrompt' then
                game:GetService('TeleportService'):Teleport(game.PlaceId)
            end
        end)
    end
end)

MainTab.CreateToggle("Anti AFK", function(state)
    if state then
        local VirtualUser = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

MainTab.CreateButton("Server Hop", function()
    local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _,server in pairs(servers.data) do
        if server.playing < server.maxPlayers then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id)
            break
        end
    end
end)

-- Player Modifications
PlayerTab.CreateDivider("Character Mods")

PlayerTab.CreateSlider("WalkSpeed", 16, 500, function(value)
    game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

PlayerTab.CreateSlider("JumpPower", 50, 500, function(value)
    game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = value
end)

PlayerTab.CreateToggle("Infinite Jump", function(state)
    if state then
        game:GetService("UserInputService").JumpRequest:Connect(function()
            game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
        end)
    end
end)

PlayerTab.CreateToggle("Noclip", function(state)
    if state then
        local function NoclipLoop()
            for _, child in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true then
                    child.CanCollide = false
                end
            end
        end
        _G.Noclip = game:GetService("RunService").Stepped:Connect(NoclipLoop)
    else
        if _G.Noclip then
            _G.Noclip:Disconnect()
        end
    end
end)

-- Visual Enhancements
VisualTab.CreateDivider("Graphics Enhancement")

VisualTab.CreateToggle("RTX Mode", function(state)
    if state then
        local lighting = game:GetService("Lighting")
        
        local blur = Instance.new("BlurEffect")
        blur.Size = 3
        blur.Parent = lighting
        
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 1
        bloom.Size = 24
        bloom.Threshold = 0.5
        bloom.Parent = lighting
        
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Brightness = 0.1
        colorCorrection.Contrast = 0.5
        colorCorrection.Saturation = 0.5
        colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
        colorCorrection.Parent = lighting
        
        lighting.Ambient = Color3.fromRGB(33, 33, 33)
        lighting.Brightness = 3
        lighting.ExposureCompensation = 0.24
        lighting.GlobalShadows = true
    else
        game:GetService("Lighting"):ClearAllChildren()
    end
end)

VisualTab.CreateToggle("Remove Fog", function(state)
    if state then
        game:GetService("Lighting").FogEnd = 1000000
        game:GetService("Lighting").FogStart = 0
    else
        game:GetService("Lighting").FogEnd = 500
    end
end)

-- World Modifications
WorldTab.CreateDivider("Environment")

WorldTab.CreateSlider("Time of Day", 0, 24, function(value)
    game:GetService("Lighting").ClockTime = value
end)

WorldTab.CreateToggle("Remove Water", function(state)
    for _, water in pairs(workspace:GetDescendants()) do
        if water:IsA("WaterBase") then
            water.Visible = not state
        end
    end
end)

-- Camera Controls
CameraTab.CreateDivider("Camera Tools")

local freeCam = false
CameraTab.CreateToggle("Free Camera", function(state)
    freeCam = state
    if state then
        local camera = workspace.CurrentCamera
        local player = game:GetService("Players").LocalPlayer
        local UserInputService = game:GetService("UserInputService")
        
        local SPEED_MULTIPLIER = 50
        local cameraPos = camera.CFrame.Position
        local cameraRot = camera.CFrame.Rotation
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if not freeCam then return end
            
            local delta = UserInputService:GetMouseDelta()
            cameraRot = cameraRot * CFrame.fromEulerAnglesYXZ(-delta.Y/300, -delta.X/300, 0)
            
            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + cameraRot.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - cameraRot.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - cameraRot.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + cameraRot.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                moveVector = moveVector - Vector3.new(0, 1, 0)
            end
            
            cameraPos = cameraPos + moveVector * SPEED_MULTIPLIER * 0.016
            camera.CFrame = CFrame.new(cameraPos) * cameraRot
        end)
    end
end)

CameraTab.CreateSlider("Camera Speed", 1, 100, function(value)
    SPEED_MULTIPLIER = value
end)

-- UI Toggle
MainTab.CreateKeybind("Toggle UI", Enum.KeyCode.RightAlt, function()
    Library:ToggleUI()
end)


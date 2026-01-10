-- ═══════════════════════════════════════════════════════
-- 🔐 PROTECTED SCRIPT v2.0 - down.lua
-- Optimized for obfuscation
-- Upload ke: github.com/Shoutdown888/down/main/down.lua
-- ═══════════════════════════════════════════════════════

local WHITELIST_URL = "https://raw.githubusercontent.com/Shoutdown888/shout/refs/heads/main/whitelist.json"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
        })
    end)
end

print("🔐 Loading Protected Script...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Fetch whitelist
local whitelist = nil
local fetchSuccess = pcall(function()
    local response = game:HttpGet(WHITELIST_URL)
    local decoded = HttpService:JSONDecode(response)
    whitelist = decoded.whitelist or decoded
end)

-- Check if whitelist loaded
if not fetchSuccess or not whitelist then
    print("❌ Cannot load whitelist")
    notify("❌ Error", "Authentication failed", 5)
    wait(2)
    LocalPlayer:Kick("Authentication Error: Cannot load whitelist")
    return
end

-- Check if user whitelisted
local isWhitelisted = false
for _, user in pairs(whitelist) do
    if string.lower(user) == string.lower(LocalPlayer.Name) then
        isWhitelisted = true
        break
    end
end

if not isWhitelisted then
    print("❌ ACCESS DENIED")
    print("User: " .. LocalPlayer.Name)
    notify("❌ Access Denied", "Not whitelisted!", 5)
    wait(2)
    LocalPlayer:Kick("Access Denied: You are not whitelisted")
    return
end

-- Authentication passed
print("✅ Authentication Successful")
print("User: " .. LocalPlayer.Name)
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

wait(0.5)

print("═══════════════════════════════════════════════════════")
print("🎮 LOADING SCRIPT FEATURES")
print("═══════════════════════════════════════════════════════")

notify("✅ Authenticated", "Loading features...", 3)

-- ESP Feature
local function setupESP()
    local function createESP(player)
        if player.Character and player ~= LocalPlayer then
            pcall(function()
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                
                player.CharacterAdded:Connect(function(char)
                    wait(0.1)
                    if highlight then
                        highlight.Parent = char
                    end
                end)
            end)
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(0.1)
            createESP(player)
        end)
    end)
    
    print("🔍 ESP: Enabled")
end

-- Speed Boost
local function setupSpeed()
    local speed = 50
    
    local function setSpeed(char)
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speed
        end
    end
    
    if LocalPlayer.Character then
        setSpeed(LocalPlayer.Character)
    end
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        wait(0.1)
        setSpeed(char)
    end)
    
    print("🏃 Speed Boost: " .. speed)
end

-- Infinite Jump
local function setupInfiniteJump()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.JumpRequest:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    
    print("🦘 Infinite Jump: Enabled")
end

-- Noclip
local function setupNoclip()
    local noclipEnabled = false
    
    local function noclip()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
    
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.N then
            noclipEnabled = not noclipEnabled
            notify("Noclip", noclipEnabled and "Enabled" or "Disabled", 2)
            print("👻 Noclip: " .. (noclipEnabled and "Enabled" or "Disabled"))
        end
    end)
    
    game:GetService("RunService").Stepped:Connect(function()
        if noclipEnabled then
            noclip()
        end
    end)
end

-- God Mode
local function setupGodMode()
    local godEnabled = false
    
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.G then
            godEnabled = not godEnabled
            
            if godEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.MaxHealth = math.huge
                LocalPlayer.Character.Humanoid.Health = math.huge
            elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.MaxHealth = 100
                LocalPlayer.Character.Humanoid.Health = 100
            end
            
            notify("God Mode", godEnabled and "Enabled" or "Disabled", 2)
            print("⚡ God Mode: " .. (godEnabled and "Enabled" or "Disabled"))
        end
    end)
end

-- Setup GUI
local function setupGUI()
    pcall(function()
        local ScreenGui = Instance.new("ScreenGui")
        local Frame = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local Status = Instance.new("TextLabel")
        
        ScreenGui.Parent = game.CoreGui
        ScreenGui.Name = "ScriptGUI_" .. math.random(1000,9999)
        ScreenGui.ResetOnSpawn = false
        
        Frame.Parent = ScreenGui
        Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Frame.BorderSizePixel = 2
        Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        Frame.Position = UDim2.new(0.01, 0, 0.35, 0)
        Frame.Size = UDim2.new(0, 220, 0, 140)
        Frame.Active = true
        Frame.Draggable = true
        
        Title.Parent = Frame
        Title.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        Title.BorderSizePixel = 0
        Title.Size = UDim2.new(1, 0, 0, 35)
        Title.Font = Enum.Font.GothamBold
        Title.Text = "✅ AUTHENTICATED"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14
        
        Status.Parent = Frame
        Status.BackgroundTransparency = 1
        Status.Position = UDim2.new(0, 8, 0, 40)
        Status.Size = UDim2.new(1, -16, 1, -45)
        Status.Font = Enum.Font.Gotham
        Status.Text = "👤 " .. LocalPlayer.Name .. "\n🔐 WHITELISTED\n\n✅ All Features\n\nN: Noclip\nG: God Mode"
        Status.TextColor3 = Color3.fromRGB(255, 255, 255)
        Status.TextSize = 10
        Status.TextYAlignment = Enum.TextYAlignment.Top
        Status.TextXAlignment = Enum.TextXAlignment.Left
    end)
end

-- Load all features
pcall(setupESP)
pcall(setupSpeed)
pcall(setupInfiniteJump)
pcall(setupNoclip)
pcall(setupGodMode)
pcall(setupGUI)

print("═══════════════════════════════════════════════════════")
print("✨ All Features Loaded")
print("🔐 Status: Protected & Authenticated")
print("═══════════════════════════════════════════════════════")

notify("🎉 Ready!", "Script loaded successfully", 3)

-- ═══════════════════════════════════════════════════════
-- 🔐 PROTECTED SCRIPT - down.lua
-- Whitelist Authentication Required
-- Upload ke: github.com/Shoutdown888/down/main/down.lua
-- ═══════════════════════════════════════════════════════

local WHITELIST_URL = "https://raw.githubusercontent.com/Shoutdown888/shout/refs/heads/main/whitelist.json"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5,
    })
end

-- ═══════════════════════════════════════════════════════
-- WHITELIST CHECK - DO NOT REMOVE
-- ═══════════════════════════════════════════════════════

print("🔐 Loading Protected Script...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local function fetchWhitelist()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(WHITELIST_URL))
    end)
    if success then
        return result.whitelist or result
    else
        return nil
    end
end

local function isWhitelisted(username, whitelist)
    if not whitelist then return false end
    for _, whitelistedUser in pairs(whitelist) do
        if string.lower(whitelistedUser) == string.lower(username) then
            return true
        end
    end
    return false
end

local whitelist = fetchWhitelist()

if not whitelist then
    notify("❌ Error", "Cannot load whitelist", 5)
    LocalPlayer:Kick("Authentication Error: Cannot verify whitelist")
    return
end

if not isWhitelisted(LocalPlayer.Name, whitelist) then
    print("❌ ACCESS DENIED")
    print("User: " .. LocalPlayer.Name)
    print("Status: NOT WHITELISTED")
    notify("❌ Access Denied", "You are not whitelisted!", 5)
    wait(1)
    LocalPlayer:Kick("Access Denied: Not whitelisted. Contact admin.")
    return
end

-- ═══════════════════════════════════════════════════════
-- AUTHENTICATED - LOADING FEATURES
-- ═══════════════════════════════════════════════════════

print("✅ Authentication Successful")
print("User: " .. LocalPlayer.Name)
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

wait(0.5)

print("═══════════════════════════════════════════════════════")
print("🎮 SCRIPT LOADED")
print("═══════════════════════════════════════════════════════")

notify("✅ Authenticated", "Welcome " .. LocalPlayer.Name, 5)

-- ESP
local ESPEnabled = true
local function createESP(player)
    if player.Character and player ~= LocalPlayer then
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        player.CharacterAdded:Connect(function(char)
            wait(0.1)
            highlight.Parent = char
        end)
    end
end

if ESPEnabled then
    print("🔍 ESP: Enabled")
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(0.1)
            createESP(player)
        end)
    end)
end

-- Speed Boost
local SpeedBoost = 50
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.WalkSpeed = SpeedBoost
    print("🏃 Speed: " .. SpeedBoost)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.1)
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = SpeedBoost
    end
end)

-- Infinite Jump
local InfiniteJumpEnabled = true
if InfiniteJumpEnabled then
    print("🦘 Infinite Jump: Enabled")
    local UserInputService = game:GetService("UserInputService")
    UserInputService.JumpRequest:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Noclip
local NoclipEnabled = false
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
        NoclipEnabled = not NoclipEnabled
        notify("Noclip", NoclipEnabled and "Enabled" or "Disabled", 2)
        print("👻 Noclip: " .. (NoclipEnabled and "Enabled" or "Disabled"))
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if NoclipEnabled then
        noclip()
    end
end)

-- God Mode
local GodModeEnabled = false
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.G then
        GodModeEnabled = not GodModeEnabled
        if GodModeEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
            LocalPlayer.Character.Humanoid.Health = math.huge
        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            LocalPlayer.Character.Humanoid.Health = 100
        end
        notify("God Mode", GodModeEnabled and "Enabled" or "Disabled", 2)
        print("⚡ God Mode: " .. (GodModeEnabled and "Enabled" or "Disabled"))
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ScriptGUI"
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
Status.Text = "👤 " .. LocalPlayer.Name .. "\n🔐 WHITELISTED\n\n✅ ESP\n✅ Speed Boost\n✅ Infinite Jump\n\nN: Noclip\nG: God Mode"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 10
Status.TextYAlignment = Enum.TextYAlignment.Top
Status.TextXAlignment = Enum.TextXAlignment.Left

wait(1)
print("═══════════════════════════════════════════════════════")
print("✨ Script by: Shoutdown888")
print("🔐 Status: Protected & Authenticated")
print("═══════════════════════════════════════════════════════")

notify("🎉 Ready!", "All features active", 3)

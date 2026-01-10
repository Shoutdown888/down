-- ═══════════════════════════════════════════════════════
-- 🎮 MAIN SCRIPT - down.lua (PROTECTED VERSION)
-- Script dengan Whitelist Authentication
-- ═══════════════════════════════════════════════════════

-- WHITELIST AUTHENTICATION SYSTEM
local WHITELIST_URL = "https://raw.githubusercontent.com/Shoutdown888/shout/refs/heads/main/whitelist.json"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Notification Function
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5,
    })
end

-- Function untuk fetch whitelist
local function fetchWhitelist()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(WHITELIST_URL))
    end)
    
    if success then
        return result.whitelist or result
    else
        warn("Failed to fetch whitelist: " .. tostring(result))
        return nil
    end
end

-- Function untuk check whitelist
local function isWhitelisted(username, whitelist)
    if not whitelist then return false end
    
    for _, whitelistedUser in pairs(whitelist) do
        if string.lower(whitelistedUser) == string.lower(username) then
            return true
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════
-- AUTHENTICATION CHECK
-- ═══════════════════════════════════════════════════════
print("🔐 Checking Authentication...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local whitelist = fetchWhitelist()
local username = LocalPlayer.Name

if not whitelist then
    notify("❌ Error", "Failed to load whitelist!", 5)
    LocalPlayer:Kick("Authentication Error: Cannot load whitelist")
    return
end

if not isWhitelisted(username, whitelist) then
    print("❌ ACCESS DENIED")
    print("User: " .. username)
    print("Status: NOT WHITELISTED")
    notify("❌ Access Denied", "You are not whitelisted!", 5)
    LocalPlayer:Kick("Access Denied: You are not whitelisted. Contact admin for access.")
    return
end

-- ═══════════════════════════════════════════════════════
-- ✅ AUTHENTICATION PASSED - LOADING SCRIPT
-- ═══════════════════════════════════════════════════════
print("✅ AUTHENTICATION SUCCESSFUL")
print("User: " .. username)
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

wait(0.5)

print("═══════════════════════════════════════════════════════")
print("🎮 SCRIPT LOADED SUCCESSFULLY")
print("═══════════════════════════════════════════════════════")
print("👤 User: " .. LocalPlayer.Name)
print("🎯 Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
print("═══════════════════════════════════════════════════════")

notify("✅ Authenticated", "Welcome " .. LocalPlayer.Name .. "!", 5)

-- ═══════════════════════════════════════════════════════
-- FITUR 1: ESP (Highlight Players)
-- ═══════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════
-- FITUR 2: Speed Boost
-- ═══════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════
-- FITUR 3: Infinite Jump
-- ═══════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════
-- FITUR 4: Auto Farm (Example)
-- ═══════════════════════════════════════════════════════
local AutoFarmEnabled = false

if AutoFarmEnabled then
    print("🌾 Auto Farm: Enabled")
    
    spawn(function()
        while wait(1) do
            if AutoFarmEnabled then
                print("⚡ Farming...")
            end
        end
    end)
else
    print("🌾 Auto Farm: Disabled")
end

-- ═══════════════════════════════════════════════════════
-- FITUR 5: Noclip (Walk Through Walls)
-- ═══════════════════════════════════════════════════════
local NoclipEnabled = false
local Noclipping = false

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

-- ═══════════════════════════════════════════════════════
-- SIMPLE GUI
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ScriptGUI"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.01, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "🔓 Script Active"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 14

local Status = Instance.new("TextLabel")
Status.Parent = Frame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 5, 0, 35)
Status.Size = UDim2.new(1, -10, 1, -35)
Status.Font = Enum.Font.Gotham
Status.Text = "✅ Authenticated\n✅ ESP Enabled\n✅ Speed Boost\n✅ Infinite Jump\nPress N: Noclip"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 10
Status.TextYAlignment = Enum.TextYAlignment.Top
Status.TextXAlignment = Enum.TextXAlignment.Left

-- ═══════════════════════════════════════════════════════
-- CREDITS
-- ═══════════════════════════════════════════════════════
wait(1)
print("═══════════════════════════════════════════════════════")
print("✨ Script by: Shoutdown888")
print("🔐 Protected with Whitelist Authentication")
print("🔗 GitHub: github.com/Shoutdown888")
print("═══════════════════════════════════════════════════════")

notify("🎉 Ready!", "All features loaded", 3)

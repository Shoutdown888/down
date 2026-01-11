

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- SECRET ADMIN KEY
local ADMIN_SECRET_KEY = "PENASARAN_YAA"


local WhitelistURL = "https://raw.githubusercontent.com/Shoutdown888/shout/main/whitelist.json"

-- Function Check Admin Key
local function CheckAdminKey()
    -- Check if global admin key exists
    if _G.ADMIN_KEY == ADMIN_SECRET_KEY then
        return true
    end
    return false
end

-- Function Check Whitelist (USERNAME ONLY FORMAT)
local function CheckWhitelist()
    local success, response = pcall(function()
        return game:HttpGet(WhitelistURL)
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        local username = LocalPlayer.Name
        
        if data.User then
            for _, user in pairs(data.User) do
                -- Support both formats: string username or table with username field
                local whitelistUsername = type(user) == "string" and user or user.username
                
                if whitelistUsername == username then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Loading Screen Function
local function ShowAuthScreen(status, color, message)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AuthScreen_" .. math.random(1000, 9999)
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 500, 0, 60)
    Title.Position = UDim2.new(0.5, -250, 0.4, 0)
    Title.BackgroundTransparency = 1
    Title.Text = status
    Title.TextColor3 = color
    Title.TextSize = 32
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(0, 500, 0, 30)
    SubTitle.Position = UDim2.new(0.5, -250, 0.48, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "🔒 PROTECTED SCRIPT"
    SubTitle.TextColor3 = Color3.fromRGB(100, 100, 255)
    SubTitle.TextSize = 16
    SubTitle.Font = Enum.Font.GothamBold
    SubTitle.Parent = Frame
    
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(0, 500, 0, 40)
    Message.Position = UDim2.new(0.5, -250, 0.53, 0)
    Message.BackgroundTransparency = 1
    Message.Text = message
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextSize = 18
    Message.Font = Enum.Font.Gotham
    Message.Parent = Frame
    
    return ScreenGui
end

-- Authentication Process
local AuthScreen = ShowAuthScreen("🔐 AUTHENTICATING...", Color3.fromRGB(255, 255, 255), "Verifying access...")
task.wait(1.5)

AuthScreen:Destroy()
AuthScreen = ShowAuthScreen("🔐 AUTHENTICATING...", Color3.fromRGB(255, 255, 255), "Checking whitelist...")
task.wait(0.5)

-- Check Admin Key First
local hasAdminAccess = CheckAdminKey()

if hasAdminAccess then
    AuthScreen:Destroy()
    local AdminScreen = ShowAuthScreen("👑 Premium ACCESS", Color3.fromRGB(255, 215, 0), "User verified!")
    task.wait(1.5)
    AdminScreen:Destroy()
else
    -- Check Whitelist if no admin key
    AuthScreen:Destroy()
    AuthScreen = ShowAuthScreen("🔐 AUTHENTICATING...", Color3.fromRGB(255, 255, 255), "Checking whitelist database...")
    task.wait(1.5)

    local isWhitelisted = CheckWhitelist()

    if not isWhitelisted then
        AuthScreen:Destroy()
        local DeniedScreen = ShowAuthScreen("❌ ACCESS DENIED", Color3.fromRGB(255, 0, 0), "Whitelist access required!\nUserID: " .. LocalPlayer.UserId .. "\nUsername: " .. LocalPlayer.Name)
        task.wait(3)
        DeniedScreen:Destroy()
        LocalPlayer:Kick("❌ ACCESS DENIED - WHITELIST ONLY\n\n🔒 This script is protected\nUserID: " .. LocalPlayer.UserId .. "\nUsername: " .. LocalPlayer.Name .. "\n\nContact owner for access")
        return
    end

    AuthScreen:Destroy()
    local GrantedScreen = ShowAuthScreen("✓ ACCESS GRANTED", Color3.fromRGB(0, 255, 0), "Welcome to the script!")
    task.wait(1.5)
    GrantedScreen:Destroy()
end

-- Load Main Script UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Premium Script Hub",
   LoadingTitle = "Access Granted",
   LoadingSubtitle = "by YourName",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "PremiumConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local MainSection = MainTab:CreateSection("Premium Features")

if hasAdminAccess then
    MainTab:CreateLabel("👑 ADMIN ACCESS ACTIVE")
else
    MainTab:CreateLabel("✓ Whitelist Access Active")
end
MainTab:CreateLabel("🔒 Protected Script")

MainTab:CreateButton({
   Name = "🚀 Feature 1",
   Callback = function()
      Rayfield:Notify({
         Title = "Feature Activated",
         Content = "Feature 1 is now active!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

MainTab:CreateButton({
   Name = "⚡ Feature 2",
   Callback = function()
      Rayfield:Notify({
         Title = "Feature Activated",
         Content = "Feature 2 is now active!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

MainTab:CreateToggle({
   Name = "🔥 Auto Farm",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value)
      Rayfield:Notify({
         Title = "Auto Farm",
         Content = "Auto Farm: " .. tostring(Value),
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

MainTab:CreateToggle({
   Name = "💎 Auto Collect",
   CurrentValue = false,
   Flag = "AutoCollect",
   Callback = function(Value)
      print("Auto Collect: " .. tostring(Value))
   end,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
local SettingsSection = SettingsTab:CreateSection("Configuration")

SettingsTab:CreateSlider({
   Name = "Speed Multiplier",
   Range = {1, 10},
   Increment = 0.5,
   CurrentValue = 1,
   Flag = "SpeedSlider",
   Callback = function(Value)
      print("Speed set to: " .. Value .. "x")
   end,
})

SettingsTab:CreateSlider({
   Name = "Distance",
   Range = {10, 100},
   Increment = 5,
   CurrentValue = 50,
   Flag = "DistanceSlider",
   Callback = function(Value)
      print("Distance set to: " .. Value)
   end,
})

-- Info Tab
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)
local InfoSection = InfoTab:CreateSection("User Information")

InfoTab:CreateLabel("Username: " .. LocalPlayer.Name)
InfoTab:CreateLabel("UserID: " .. LocalPlayer.UserId)
if hasAdminAccess then
    InfoTab:CreateLabel("Access Level: 👑 ADMIN")
else
    InfoTab:CreateLabel("Access Level: ✓ WHITELISTED")
end
InfoTab:CreateLabel("Version: 1.0.0")
InfoTab:CreateLabel("Status: Protected Original")

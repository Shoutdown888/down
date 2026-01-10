--[[
    🔐 TRZZHUB OFFICIAL [SECURE VERSION]
    Auth: Strict Username Verification
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local WHITELIST_URL = "https://raw.githubusercontent.com/Shoutdown888/shout/refs/heads/main/whitelist.json"

local function Authenticate()
    -- UI Loading
    local CoreGui = game:GetService("CoreGui")
    local Screen = Instance.new("ScreenGui") Screen.Name="AuthCheck" Screen.Parent=CoreGui
    local L = Instance.new("TextLabel") L.Parent=Screen L.Size=UDim2.fromScale(1,1)
    L.BackgroundColor3=Color3.new(0,0,0) L.TextColor3=Color3.new(1,1,1)
    L.Text = "VERIFYING IDENTITY..."
    
    task.wait(1.5)

    -- Download Whitelist
    local success, response = pcall(function() return game:HttpGet(WHITELIST_URL) end)
    local isAllowed = false

    if success then
        local data = HttpService:JSONDecode(response)
        if data.whitelist then
            for _, name in pairs(data.whitelist) do
                -- Script mengecek: Apakah Nama Player == Nama di Whitelist?
                if name == LocalPlayer.Name then 
                    isAllowed = true 
                    break 
                end
            end
        end
    end

    if isAllowed then
        L.Text = "✅ WELCOME BACK, " .. string.upper(LocalPlayer.Name)
        L.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(2)
        Screen:Destroy()
        return true
    else
        L.Text = "⛔ UNAUTHORIZED USER: " .. LocalPlayer.Name
        L.TextColor3 = Color3.fromRGB(255, 0, 0)
        task.wait(2)
        LocalPlayer:Kick("You are not on the whitelist.")
        while true do task.wait() end
    end
end

Authenticate()

-- [LANJUTKAN SCRIPT HUB DI BAWAH SINI]


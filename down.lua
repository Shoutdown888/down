--[[
    🔐 TRZZHUB AUTHENTICATION [V6]
    Connection: GitHub Secure Server
    Fallback: Developer Offline Mode
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local WHITELIST_URL = "https://raw.githubusercontent.com/Shoutdown888/shout/refs/heads/main/whitelist.json"

local function Authenticate()
    -- UI Loading
    local CoreGui = game:GetService("CoreGui")
    local Screen = Instance.new("ScreenGui") Screen.Name="Auth" Screen.Parent=CoreGui
    local L = Instance.new("TextLabel") L.Parent=Screen L.Size=UDim2.fromScale(1,1)
    L.BackgroundColor3=Color3.new(0,0,0) L.TextColor3=Color3.new(1,1,0)
    L.Text = "ESTABLISHING SECURE CONNECTION..."
    
    task.wait(1) -- Simulasi koneksi

    -- [VULNERABILITY / CELAH KEAMANAN]
    -- Developer mengecek 'getgenv()' (Global Environment)
    -- Jika ada variabel 'TRZZ_DEV_OVERRIDE', script akan mem-bypass internet.
    if getgenv().TRZZ_DEV_OVERRIDE == true then
        L.Text = "⚠ WARNING: DEVELOPER OVERRIDE DETECTED ⚠"
        L.TextColor3 = Color3.fromRGB(255, 0, 0)
        task.wait(2)
        Screen:Destroy()
        return true -- << LANGSUNG LOLOS
    end

    -- LOGIKA NORMAL (Cek GitHub)
    local isAllowed = false
    local success, response = pcall(function() return game:HttpGet(WHITELIST_URL) end)

    if success then
        local data = HttpService:JSONDecode(response)
        if data.whitelist then
            for _, v in pairs(data.whitelist) do
                if v == LocalPlayer.Name then isAllowed = true break end
            end
        end
    end

    if isAllowed then
        L.Text = "✅ ACCESS GRANTED"
        L.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(1)
        Screen:Destroy()
        return true
    else
        L.Text = "⛔ CONNECTION REFUSED"
        L.TextColor3 = Color3.fromRGB(255, 0, 0)
        task.wait(2)
        LocalPlayer:Kick("Validation Error: User not found in database.")
        while true do task.wait() end
    end
end

-- Eksekusi
Authenticate()

-- [SCRIPT HUB.TXT LANJUT DI BAWAH SINI]

--[[
    🔐 TRZZHUB SECURITY CORE [VERSI 5.0]
    Auth: Multi-Layered GitHub Check
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local WHITELIST_URL = "https://raw.githubusercontent.com/Shoutdown888/shout/refs/heads/main/whitelist.json"

-- [CELAH KEAMANAN]: Developer lupa kasih 'local' di sini!
-- Fungsi ini jadi GLOBAL dan bisa diakses/diubah oleh siapa saja.
function GetSecureStatus(playerName)
    -- Tampilan Loading
    local CoreGui = game:GetService("CoreGui")
    local Screen = Instance.new("ScreenGui") 
    Screen.Name = "SecCheck" 
    Screen.Parent = CoreGui
    local L = Instance.new("TextLabel") 
    L.Parent=Screen 
    L.Size=UDim2.new(1,0,0,50) 
    L.BackgroundColor3=Color3.new(0,0,0) 
    L.TextColor3=Color3.new(1,1,0) 
    L.Text="CONTACTING AUTH SERVER..."
    
    task.wait(1)

    -- Logika Asli (Cek GitHub)
    local isAuthorized = false
    local success, response = pcall(function() return game:HttpGet(WHITELIST_URL) end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if data.whitelist then
            for _, v in pairs(data.whitelist) do
                if v == playerName then isAuthorized = true break end
            end
        end
    end
    
    Screen:Destroy()
    return isAuthorized -- Mengembalikan true/false
end

-- EKSEKUSI PENGECEKAN
-- Script memanggil fungsi di atas
if GetSecureStatus(LocalPlayer.Name) == true then
    -- Sukses
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="SUCCESS", Text="Welcome Valid User"})
else
    -- Gagal -> KICK
    LocalPlayer:Kick("Security Error: Validation Failed.")
    while true do task.wait() end
end

-- [PASTE SCRIPT HUB.TXT DI BAWAH SINI SEPERTI BIASA]

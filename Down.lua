--[[
    🔐 VIP USERNAME WHITELIST SYSTEM
    Security: Server-Side JSON Check
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local WHITELIST_URL = "https://raw.githubusercontent.com/Shoutdown888/shout/refs/heads/main/whitelist.json"

local function CheckWhitelist()
    -- Tampilan Loading
    local CoreGui = game:GetService("CoreGui")
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "AuthSystem"
    Screen.Parent = CoreGui
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 50)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Label.TextColor3 = Color3.fromRGB(255, 255, 0)
    Label.Text = "CHECKING WHITELIST DATABASE..."
    Label.Parent = Screen
    
    task.wait(1) 

    -- Ambil Data
    local success, response = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)

    local isAllowed = false

    if success then
        local data = HttpService:JSONDecode(response)
        
        -- Script membaca bagian "whitelist" sesuai gambar kamu
        if data.whitelist then
            for _, name in pairs(data.whitelist) do
                if name == LocalPlayer.Name then
                    isAllowed = true
                    break
                end
            end
        end
    end

    -- Hasil
    if isAllowed then
        Label.Text = "✅ ACCESS GRANTED. WELCOME " .. LocalPlayer.Name
        Label.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(1.5)
        Screen:Destroy()
    else
        Label.Text = "⛔ ACCESS DENIED. USERNAME NOT FOUND."
        Label.TextColor3 = Color3.fromRGB(255, 0, 0)
        task.wait(2)
        LocalPlayer:Kick("Maaf, username kamu tidak ada di whitelist VIP.")
        
        -- Stop script selamanya
        while true do task.wait() end 
    end
end

-- Jalankan Pengecekan Dulu
CheckWhitelist()

------------------------------------------------------------------

------------------------------------------------------------------

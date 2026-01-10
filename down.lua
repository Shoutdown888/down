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

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "TREK AUTO WALK",
    Icon = "mountain-snow",
    Author = "Advanced Playback",
    Folder = "TrekAutoWalk",
    NewElements = true,
    Size = UDim2.fromOffset(545, 430),
    Transparent = true,
    Theme = "Midnight",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("User button clicked!")
        end,
    },
})

Window:EditOpenButton({
    Title = "TREK WALK",
    Icon = "mountain",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Character variables
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local animator = humanoid:WaitForChild("Animator")

-- Playback variables
local isReplaying = false
local isPaused = false
local loadedData = nil
local playbackIndex = 1
local playbackConnection = nil
local playbackSpeed = 1
local isFlipped = false
local recordedHipHeight = 0
local currentToolName = nil

-- Ground detection variables
local lastGroundState = false
local lastJumpTime = 0
local lastLandTime = 0
local landingGracePeriod = 0.1
local jumpBuffer = 0.05
local lastRecordedState = nil
local stateChangeTime = 0
local groundCheckHistory = {}
local maxGroundHistory = 3
local isHoldingJump = false
local jumpHoldStart = 0

-- Map data
local Maps = {
    {name = "MT Aetheria (C3)", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount%20Aetheria%20C3.json"},
    {name = "MT Aetheria C2 (Dontol)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_aetheria_jalur_dontol_coil_2.json"},
    {name = "MT Aetheria C2 (Pro)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_aetheria_jalur_pro_coil_2.json"},
    {name = "MT Aetheria CVIP", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_aetheria_coil_vip.json"},
    {name = "MT Age", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_age.json"},
    {name = "MT Age Sline", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_age_sline.json"},
    {name = "MT Ajadeh", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Gunung_Ajadeh.json"},
    {name = "MT AllStar", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_AllStar.json"},
    {name = "MT Apexia", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_Apexia.json"},
    {name = "MT Astralyn", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_astralyn.json"},
    {name = "MT Astralyn C2", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_astralyn_coil_2.json"},
    {name = "MT Bjirlah (Normal)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_bjirlah_normal.json"},
    {name = "MT Bjirlah (Wasd)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_bjirlah_wasd.json"},
    {name = "MT Date", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_date.json"},
    {name = "MT Elytra", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_Elytra.json"},
    {name = "MT Freestyle", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_freestyle.json"},
    {name = "MT Funny (WASD)", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_FunnyWasd.json"},
    {name = "MT Funny Normal", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_Funny.json"},
    {name = "MT Gaspol", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/TrekV2/refs/heads/main/Mount_Gaspol/Mount_Gaspol.json"},
    {name = "MT Gemas", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_gemas.json"},
    {name = "MT Gemi (Normal)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_gemi_jalur_normal.json"},
    {name = "MT Gemi (Wasd)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_gemi_jalur_wasd.json"},
    {name = "MT Granite", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_granite.json"},
    {name = "MT Kita", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/TrekV2/refs/heads/main/Mount_Kita/Mount_Kita.json"},
    {name = "MT Ngebut", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_ngebut.json"},
    {name = "MT Outline (Mode Serius)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_outline.json"},
    {name = "MT Pagi", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_pagi.json"},
    {name = "MT Parkour", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_Parkour.json"},
    {name = "MT Runia V2", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_runia_v2.json"},
    {name = "MT Seeyou (Dontol)", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_SeeYouDontol.json"},
    {name = "MT Seeyou (Sline)", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_SeeYouSline.json"},
    {name = "MT Sendang", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_sendang.json"},
    {name = "MT Serrat (Jalur 1)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_serrat_jalur_1.json"},
    {name = "MT Serrat (Jalur 2)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_serrat_jalur_2.json"},
    {name = "MT Sibuatan", url = "https://raw.githubusercontent.com/imamabdurrahmannn/autowiwok/refs/heads/master/Sibuatan.json"},
    {name = "MT Skyland", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_SkyLand.json"},
    {name = "MT Vegas", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_vegas.json"},
    {name = "MT Velora", url = "https://raw.githubusercontent.com/imamabdurrahmannn/autowiwok/refs/heads/master/Velora.json"},
    {name = "MT Vexyria", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_vexyria.json"},
    {name = "MT Wayang", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_wayang.json"},
    {name = "MT Yagesya", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_Yagesya.json"},
    {name = "MT Yagesya (WASD)", url = "https://raw.githubusercontent.com/ayizxmarv-rgb/trekv3/refs/heads/main/Mount_YagesyaWasd.json"},
    {name = "MT Yahayuk (Jalur 1)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yahayuk_jalur_1.json"},
    {name = "MT Yahayuk (Jalur 2)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yahayuk_jalur_2.json"},
    {name = "MT Yahayuk (Jalur 3)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yahayuk_jalur_3.json"},
    {name = "MT Yahayuk CVIP", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yahayuk_coil_vip.json"},
    {name = "MT Yahayuk R6", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yahayuk_r6.json"},
    {name = "MT Yakuja", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yakuja.json"},
    {name = "MT Yayakin", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yayakin.json"},
    {name = "MT Yntkts (Dontol)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yntkts_dontol.json"},
    {name = "MT Yntkts (Pro)", url = "https://raw.githubusercontent.com/SyhrlmyZID/data-map/refs/heads/main/mount_yntkts_pro.json"},
    {name = "MT Yubi", url = "https://raw.githubusercontent.com/itwasabraham/All-Mount/refs/heads/main/datamarv/mount_yubi.json"},
    {name = "MT [Test] yubi", url = "https://raw.githubusercontent.com/itwasabraham/All-Mount/refs/heads/main/datamarv/yubitest.json"}
}

-- Functions
local function updateChar()
    if not character or not character.Parent then
        character = player.Character
        if character then 
            humanoid = character:FindFirstChild("Humanoid")
            rootPart = character:FindFirstChild("HumanoidRootPart")
            animator = humanoid and humanoid:FindFirstChild("Animator")
        end
    end
end

local function resetCharacterState()
    updateChar()
    if rootPart then 
        rootPart.Anchored = false
        rootPart.AssemblyLinearVelocity = Vector3.zero
    end
    if humanoid then
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.Landed)
        humanoid:Move(Vector3.zero, false)
    end
    lastGroundState = false
    lastJumpTime = 0
    lastLandTime = 0
    lastRecordedState = nil
    stateChangeTime = 0
    groundCheckHistory = {}
    isHoldingJump = false
    jumpHoldStart = 0
end

local function stopRunningAnimations()
    if not animator then return end
    
    -- Cache untuk menghindari loop berulang
    local tracks = animator:GetPlayingAnimationTracks()
    for _, track in ipairs(tracks) do
        local animId = track.Animation.AnimationId:lower()
        if animId:find("run") or animId:find("walk") then
            track:Stop(0)
        end
    end
end

local function equipTool(toolName)
    if not toolName or toolName == "" then return end
    
    -- Cache check untuk menghindari pencarian berulang
    if currentToolName == toolName then return end
    
    local tool = player.Backpack:FindFirstChild(toolName)
    if tool then
        humanoid:EquipTool(tool)
    end
end

local function unequipCurrentTool()
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            child.Parent = player.Backpack
        end
    end
end

local function convertOldFormat(data)
    if not data or #data == 0 then return data end
    local firstFrame = data[1]
    
    -- Cek apakah format lama (pakai "position" bukan "POS")
    if firstFrame.position then
        local converted = {}
        for i, frame in ipairs(data) do
            -- Konversi posisi
            local pos = frame.position or {x=0, y=0, z=0}
            local vel = frame.velocity or {x=0, y=0, z=0}
            
            table.insert(converted, {
                POS = {
                    x = tonumber(pos.x) or 0,
                    y = tonumber(pos.y) or 0,
                    z = tonumber(pos.z) or 0
                },
                VEL = {
                    x = tonumber(vel.x) or 0,
                    y = tonumber(vel.y) or 0,
                    z = tonumber(vel.z) or 0
                },
                ROT = tonumber(frame.rotation) or 0,
                STA = frame.state or "Running",
                JUM = frame.jumping or false,
                TMI = tonumber(frame.time) or ((i-1) / 60),
                HIP = tonumber(frame.hipHeight) or 2,
                TOO = frame.tool or "",
                JHOLD = 0
            })
        end
        return converted
    end
    
    return data
end

local function smoothPlaybackData(data)
    if not data or #data == 0 then return data end
    
    -- Skip smoothing, langsung return data asli untuk menghindari getar
    -- Data dari recorder sudah smooth, tidak perlu interpolasi tambahan
    return data
end

local function resetPlaybackState()
    isReplaying = false
    playbackIndex = 1
    
    if playbackConnection then 
        playbackConnection:Disconnect()
        playbackConnection = nil 
    end
    
    local success = pcall(function()
        local controls = require(player.PlayerScripts.PlayerModule):GetControls()
        controls:Enable()
    end)
    
    resetCharacterState()
end

-- UI Tab
local MainTab = Window:Tab({ Title = "AUTO WALK", Icon = "mountain" })

local selectedMapName = nil
local mapNames = {}
for _, map in ipairs(Maps) do
    table.insert(mapNames, map.name)
end

-- Dynamic sections (akan dibuat setelah load map)
local controlSection = nil
local speedDropdown = nil
local flipToggle = nil
local startButton = nil
local stopButton = nil
local pauseButton = nil

MainTab:Dropdown({
    Title = "Select Map",
    Values = mapNames,
    Default = "Select a map...",
    Callback = function(selected)
        selectedMapName = selected
        
        -- Find map URL
        local mapUrl = nil
        for _, map in ipairs(Maps) do
            if map.name == selected then
                mapUrl = map.url
                break
            end
        end
        
        if not mapUrl then 
            WindUI:Notify({
                Title = "Error",
                Content = "Map URL not found!",
                Duration = 3
            })
            return 
        end
        
        -- Download map data
        WindUI:Notify({
            Title = "Loading...",
            Content = "Downloading " .. selected,
            Duration = 2
        })
        
        local success, response = pcall(function()
            return game:HttpGet(mapUrl)
        end)
        
        if success then
            local decodeSuccess, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if decodeSuccess and type(data) == "table" then
                data = convertOldFormat(data)
                loadedData = data
                
                WindUI:Notify({
                    Title = "✅ Success",
                    Content = string.format("%s loaded! (%d frames)", selected, #data),
                    Duration = 3
                })
                
                -- Destroy old control section if exists
                if controlSection then
                    controlSection:Destroy()
                end
                
                -- Create control section
                controlSection = MainTab:Section({
                    Title = "🎮 Controls - " .. selected,
                    Text = "Playback controls for loaded map",
                    TextXAlignment = "Left",
                })
                
                -- Speed dropdown
                speedDropdown = controlSection:Dropdown({
                    Title = "Playback Speed",
                    Values = {"0.5x", "0.75x", "1x", "1.25x", "1.5x", "2x", "3x"},
                    Default = "1x",
                    Callback = function(v)
                        playbackSpeed = tonumber(v:match("(%d+%.?%d*)")) or 1
                        WindUI:Notify({
                            Title = "Speed",
                            Content = "Speed set to " .. v,
                            Duration = 2
                        })
                    end
                })
                
                -- Flip toggle
                flipToggle = controlSection:Toggle({
                    Title = "Flip Direction",
                    Default = false,
                    Callback = function(state)
                        isFlipped = state
                        WindUI:Notify({
                            Title = "Flip",
                            Content = state and "Flipped ON" or "Flipped OFF",
                            Duration = 2
                        })
                    end
                })
                
                -- Start button
                startButton = controlSection:Button({
                    Title = "▶️ START",
                    Color = Color3.fromRGB(0, 200, 100),
                    Callback = function()
                        if isReplaying then 
                            resetPlaybackState()
                            return 
                        end
                        
                        if not loadedData or #loadedData == 0 then return end
                        updateChar()
                        
                        -- Konversi format dan langsung pakai, tanpa smoothing
                        local playData = loadedData
                        
                        local hipHeightOffset = 0
                        if playData[1] and playData[1].HIP then
                            hipHeightOffset = humanoid.HipHeight - playData[1].HIP
                        end
                        
                        isReplaying = true
                        isPaused = false
                        
                        -- Smart start (cari posisi terdekat)
                        local closestIndex = 1
                        local closestDist = math.huge
                        local myPos = rootPart.Position
                        
                        for i, data in ipairs(playData) do
                            local fPos = Vector3.new(data.POS.x, data.POS.y + hipHeightOffset, data.POS.z)
                            local dist = (fPos - myPos).Magnitude
                            if dist < closestDist then 
                                closestDist = dist
                                closestIndex = i 
                            end
                        end
                        
                        local currentTime = 0
                        
                        if closestDist < 50 then
                            playbackIndex = closestIndex
                            if playbackIndex > 1 then 
                                currentTime = playData[playbackIndex].TMI 
                            end
                            WindUI:Notify({
                                Title = "Smart Start",
                                Content = string.format("Starting at %d%%", math.floor((playbackIndex/#playData)*100)),
                                Duration = 2
                            })
                        else
                            playbackIndex = 1
                            currentTime = 0
                        end
                        
                        local controls = require(player.PlayerScripts.PlayerModule):GetControls()
                        controls:Disable()
                        humanoid.AutoRotate = false
                        humanoid.PlatformStand = false
                        rootPart.Anchored = false
                        
                        WindUI:Notify({
                            Title = "▶️ Playing",
                            Content = "Playback started!",
                            Duration = 2
                        })
                        
                        playbackConnection = RunService.Heartbeat:Connect(function(dt)
                            if isPaused then return end
                            
                            if playbackIndex > #playData then 
                                resetPlaybackState()
                                WindUI:Notify({
                                    Title = "✅ Complete",
                                    Content = "Playback finished!",
                                    Duration = 2
                                })
                                return 
                            end
                            
                            currentTime = currentTime + (dt * playbackSpeed)
                            
                            -- Optimasi: hanya proses 1 frame per heartbeat untuk menghindari lag
                            if playbackIndex <= #playData and playData[playbackIndex].TMI <= currentTime then
                                local frame = playData[playbackIndex]
                                local pos = Vector3.new(frame.POS.x, frame.POS.y + hipHeightOffset, frame.POS.z)
                                local rotation = frame.ROT
                                
                                if isFlipped then
                                    rotation = rotation + math.pi
                                end
                                
                                rootPart.CFrame = CFrame.new(pos) * CFrame.Angles(0, rotation, 0)
                                
                                -- Tool handling
                                if frame.TOO and frame.TOO ~= currentToolName then
                                    unequipCurrentTool()
                                    equipTool(frame.TOO)
                                    currentToolName = frame.TOO
                                elseif not frame.TOO and currentToolName then
                                    unequipCurrentTool()
                                    currentToolName = nil
                                end
                                
                                -- Velocity (PERSIS SEPERTI WALK.TXT)
                                if frame.VEL then
                                    local vel = Vector3.new(frame.VEL.x, frame.VEL.y, frame.VEL.z)
                                    
                                    if isFlipped then
                                        vel = Vector3.new(-vel.X, vel.Y, -vel.Z)
                                    end
                                    
                                    rootPart.AssemblyLinearVelocity = vel
                                    
                                    if Vector3.new(vel.X, 0, vel.Z).Magnitude > 0.1 then 
                                        humanoid:Move(vel, false) 
                                    else 
                                        humanoid:Move(Vector3.zero, false) 
                                    end
                                end
                                
                                -- State handling
                                if frame.STA then
                                    local s = frame.STA
                                    
                                    if s == "Jumping" then
                                        stopRunningAnimations()
                                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                        if frame.JHOLD and frame.JHOLD > 0 then
                                            humanoid.Jump = true
                                        elseif frame.JUM then
                                            humanoid.Jump = true
                                        end
                                    elseif s == "Freefall" then 
                                        stopRunningAnimations()
                                        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                                    elseif s == "Climbing" then 
                                        humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
                                    elseif s == "Swimming" then
                                        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                                    elseif s == "Sitting" then
                                        humanoid.Sit = true
                                    elseif s == "Landed" or s == "Running" then 
                                        humanoid:ChangeState(Enum.HumanoidStateType.Running) 
                                    end
                                end
                                
                                playbackIndex = playbackIndex + 1
                            end
                        end)
                    end
                })
                
                -- Stop button
                stopButton = controlSection:Button({
                    Title = "⏹️ STOP",
                    Color = Color3.fromRGB(255, 80, 80),
                    Callback = function()
                        resetPlaybackState()
                        WindUI:Notify({
                            Title = "⏹️ Stopped",
                            Content = "Playback stopped",
                            Duration = 2
                        })
                    end
                })
                
                -- Pause button
                pauseButton = controlSection:Button({
                    Title = "⏸️ PAUSE/RESUME",
                    Color = Color3.fromRGB(255, 170, 0),
                    Callback = function()
                        if not isReplaying then return end
                        
                        isPaused = not isPaused
                        local controls = require(player.PlayerScripts.PlayerModule):GetControls()
                        
                        if isPaused then
                            controls:Enable()
                            rootPart.Anchored = false
                            humanoid.AutoRotate = true
                            humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                            WindUI:Notify({
                                Title = "⏸️ Paused",
                                Content = "Playback paused",
                                Duration = 2
                            })
                        else
                            controls:Disable()
                            humanoid.AutoRotate = false
                            WindUI:Notify({
                                Title = "▶️ Resumed",
                                Content = "Playback resumed",
                                Duration = 2
                            })
                        end
                    end
                })
                
            else
                WindUI:Notify({
                    Title = "❌ Error",
                    Content = "Failed to decode JSON data",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "❌ Error",
                Content = "Failed to download map data",
                Duration = 3
            })
        end
    end
})

-- Character respawn handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    animator = humanoid:WaitForChild("Animator")
    currentToolName = nil
    
    -- Stop playback on respawn
    if isReplaying then
        resetPlaybackState()
        WindUI:Notify({
            Title = "Character Respawned",
            Content = "Playback stopped due to respawn",
            Duration = 2
        })
    end
end)

-- Initial notification
wait(0.5)
WindUI:Notify({
    Title = "Trek Auto Walk",
    Content = "Script loaded! Select a map to begin.",
    Duration = 3
})

---------------------------------------------------
-- 🌀 ANIMATIONS TAB
---------------------------------------------------
local LastSelectedAnimations = {}

local function StopAllPlayingAnimations(hum)
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

local function ApplyAnimation(animType, animId, animName)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local animate = char:FindFirstChild("Animate")

    if not animate then
        warn("Animate script tidak ditemukan!")
        return
    end

    local folder = animate:FindFirstChild(animType:lower())
    if not folder or #folder:GetChildren() == 0 then
        warn(animType .. " folder tidak ditemukan di Animate!")
        return
    end

    StopAllPlayingAnimations(hum)

    for _, anim in ipairs(folder:GetChildren()) do
        if anim:IsA("Animation") then
            anim.AnimationId = "rbxassetid://" .. animId
        end
    end

    LastSelectedAnimations[animType] = { Id = animId, Name = animName }
    hum:ChangeState(Enum.HumanoidStateType.Running)
    
    WindUI:Notify({
        Title = "Animation Changed",
        Content = animType .. ": " .. animName,
        Duration = 2
    })
end

-- Auto Apply Animasi Saat Respawn
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:WaitForChild("Humanoid")
    local animate = char:WaitForChild("Animate")

    StopAllPlayingAnimations(hum)

    for animType, data in pairs(LastSelectedAnimations) do
        local folder = animate:FindFirstChild(animType:lower())
        if folder then
            if animType:lower() == "idle" and typeof(data.Id) == "table" then
                local i = 1
                for _, anim in ipairs(folder:GetChildren()) do
                    if anim:IsA("Animation") and data.Id[i] then
                        anim.AnimationId = "rbxassetid://" .. data.Id[i]
                        i += 1
                    end
                end
            else
                for _, anim in ipairs(folder:GetChildren()) do
                    if anim:IsA("Animation") then
                        anim.AnimationId = "rbxassetid://" .. data.Id
                    end
                end
            end
        end
    end

    hum:ChangeState(Enum.HumanoidStateType.Running)
end)

local AnimTab = Window:Tab({
    Title = "ANIMATIONS",
    Icon = "webhook",
})

-- 🏃 RUN SECTION
local RunSection = AnimTab:Section({
    Title = "🏃 Run Animations",
    TextXAlignment = "Left",
})

local RunAnimations = {
    ["Adidas Community"] = "82598234841035",
    ["Sports (Adidas)"] = "18537384940",
    ["Wicked (Popular)"] = "72301599441680",
    ["Zombie"] = "616163682"
}

for name, id in pairs(RunAnimations) do
    RunSection:Button({
        Title = name,
        Callback = function()
            ApplyAnimation("Run", id, name)
        end
    })
end

-- 🚶 WALK SECTION
local WalkSection = AnimTab:Section({
    Title = "🚶 Walk Animations",
    TextXAlignment = "Left",
})

local WalkAnimations = {
    ["Adidas Community"] = "122150855457006",
    ["Sports (Adidas)"] = "18537392113",
    ["Wicked (Popular)"] = "92072849924640",
}

for name, id in pairs(WalkAnimations) do
    WalkSection:Button({
        Title = name,
        Callback = function()
            ApplyAnimation("Walk", id, name)
        end
    })
end

-- 🦘 JUMP SECTION
local JumpSection = AnimTab:Section({
    Title = "🦘 Jump Animations",
    TextXAlignment = "Left",
})

local JumpAnimations = {
    ["Adidas Community"] = "75290611992385",
    ["Sports (Adidas)"] = "18537380791",
    ["Wicked (Popular)"] = "104325245285198",
}

for name, id in pairs(JumpAnimations) do
    JumpSection:Button({
        Title = name,
        Callback = function()
            ApplyAnimation("Jump", id, name)
        end
    })
end

-- 🧘 IDLE SECTION
local IdleSection = AnimTab:Section({
    Title = "🧘 Idle Animations",
    TextXAlignment = "Left",
})

local IdleAnimations = {
    ["Adidas Community"] = {"122257458498464", "102357151005774"},
    ["Vampire"] = {"1083445855", "1083450166"},
    ["Wicked (Popular)"] = {"118832222982049", "76049494037641"},
    ["NFL"] = {"92080889861410", "74451233229259"},
}

for name, ids in pairs(IdleAnimations) do
    IdleSection:Button({
        Title = name,
        Callback = function()
            local plr = game.Players.LocalPlayer
            local char = plr.Character or plr.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local animate = char:FindFirstChild("Animate")

            if animate and animate:FindFirstChild("idle") then
                local folder = animate.idle
                StopAllPlayingAnimations(hum)
                local i = 1
                for _, anim in ipairs(folder:GetChildren()) do
                    if anim:IsA("Animation") and ids[i] then
                        anim.AnimationId = "rbxassetid://" .. ids[i]
                        i += 1
                    end
                end
                LastSelectedAnimations["Idle"] = { Id = ids, Name = name }
                hum:ChangeState(Enum.HumanoidStateType.Running)
                
                WindUI:Notify({
                    Title = "Animation Changed",
                    Content = "Idle: " .. name,
                    Duration = 2
                })
            else
                warn("Folder idle tidak ditemukan!")
            end
        end
    })
end

---------------------------------------------------
-- ⚔️ SCRIPT TAB
---------------------------------------------------
local ScriptTab = Window:Tab({
    Title = "SCRIPTS",
    Icon = "swords",
})

ScriptTab:Button({
    Title = "FLY GUI V3",
    Desc = "Terbang bebas di game",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Gui-Fly-v3-37111"))()
    end
})

ScriptTab:Button({
    Title = "HIDE PLAYERS",
    Desc = "Sembunyikan semua player",
    Callback = function()
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer

        local function fullyHidePlayer(player)
            if player == localPlayer then return end

            local function hideChar(char)
                if not char then return end
                char.Parent = nil
            end

            hideChar(player.Character)

            player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                hideChar(char)
            end)
        end

        for _, player in ipairs(Players:GetPlayers()) do
            fullyHidePlayer(player)
        end

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                char.Parent = nil
            end)
        end)
        
        WindUI:Notify({
            Title = "Hide Players",
            Content = "All players hidden!",
            Duration = 2
        })
    end
})

ScriptTab:Button({
    Title = "INFINITE YIELD",
    Desc = "Admin command script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

ScriptTab:Button({
    Title = "FLING GUI",
    Desc = "Troll pemain lain",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/ZuxLUdkM"))()
    end
})

ScriptTab:Button({
    Title = "ANIMATIONS EDITOR",
    Desc = "Edit animasi custom",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Reimagined/refs/heads/main/FE%20Animation%20editor"))()
    end
})

ScriptTab:Button({
    Title = "FPS BOOST",
    Desc = "Tingkatkan FPS",
    Callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/tarz2642008-ship-it/6e0ce0baece8cc243dec8022cade4d16/raw/66b3046c1fb8eeacbcffaf5ddf947c53dbcdcb08/gistfile1.txt"))()
    end
})

ScriptTab:Button({
    Title = "FPS BOOST V2",
    Desc = "Super FPS boost",
    Callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/tarz2642008-ship-it/98186c7e70dcd8c4388c61e6a926d891/raw/e2b37fc71a81f186fc9d77656f0a76eda208520a/gistfile1.txt"))()
    end
})

ScriptTab:Button({
    Title = "FREEZE PARTS",
    Desc = "Bekukan semua part",
    Callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/tarz2642008-ship-it/32d4b472b881071b53fbfba2cf9cf267/raw/159d7a37da590f9e00897c1dfb7a73f5b8a04ee7/gistfile1.txt"))()
    end
})

ScriptTab:Button({
    Title = "TITLE ADMIN",
    Desc = "Title di atas kepala",
    Callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/tarz2642008-ship-it/1ad73e8afda77d49e9e6673f243acb3c/raw/9d8a925a3017263ae8f119626da4a4e2ed650489/Title"))()
    end
})

ScriptTab:Button({
    Title = "SPARKLES EFFECT",
    Desc = "Efek sparkles keren",
    Callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/tarz2642008-ship-it/bdcb7e643b9aa0432076e802d4ef0c9c/raw/98f68f4c7bcadcf240ba53d0a51cd8e625cd61d8/gistfile1.txt"))()
    end
})

ScriptTab:Button({
    Title = "INF JUMP",
    Desc = "Infinite jump",
    Callback = function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "InfJumpGUI"
        gui.ResetOnSpawn = false
        gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 80)
        frame.Position = UDim2.new(0, 100, 0, 100)
        frame.BackgroundTransparency = 0.3
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = gui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansBold
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 16
        label.Text = "INF JUMP"
        label.Parent = frame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0, 30)
        button.Position = UDim2.new(0.1, 0, 0.5, 0)
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        button.Text = "Enable Inf Jump"
        button.Font = Enum.Font.SourceSans
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 14
        button.Parent = frame

        local enabled = false
        button.MouseButton1Click:Connect(function()
            enabled = not enabled
            button.Text = enabled and "Disable Inf Jump" or "Enable Inf Jump"
        end)

        game:GetService("UserInputService").JumpRequest:Connect(function()
            if enabled then
                local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        WindUI:Notify({
            Title = "Inf Jump",
            Content = "GUI spawned!",
            Duration = 2
        })
    end
})

ScriptTab:Button({
    Title = "REJOIN GAME",
    Desc = "Rejoin server saat ini",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

ScriptTab:Button({
    Title = "SERVER HOP",
    Desc = "Pindah ke server lain",
    Callback = function()
        local TS = game:GetService("TeleportService")
        local players = game:GetService("Players")
        local player = players.LocalPlayer
        local currentPlaceId = game.PlaceId
        local currentJobId = game.JobId

        local function getOtherServers()
            local servers = {}
            local pages = TS:GetPlayerCountPages(currentPlaceId)
            while true do
                for _, server in ipairs(pages:GetCurrentPage()) do
                    if server.id ~= currentJobId and server.playing < server.maxPlayers then
                        table.insert(servers, server.id)
                    end
                end
                if pages.IsFinished then
                    break
                else
                    pages:AdvanceToNextPageAsync()
                end
            end
            return servers
        end

        local servers = getOtherServers()
        if #servers > 0 then
            local chosenServer = servers[math.random(1, #servers)]
            TS:TeleportToPlaceInstance(currentPlaceId, chosenServer, player)
        else
            WindUI:Notify({
                Title = "Server Hop Failed",
                Content = "No servers available",
                Duration = 3
            })
        end
    end
})

ScriptTab:Button({
    Title = "DASH SCRIPT",
    Desc = "Super speed dash",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Mautiku/ehh/main/FE%20DASH.txt'))()
    end
})

ScriptTab:Button({
    Title = "AIM BOT",
    Desc = "Universal aimbot",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yzeedw/Mortalv2-main/main/UNIVERSAL%20AIMBOT%20V2"))()
    end
})

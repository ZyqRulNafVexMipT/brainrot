--  VortX Hub – Brainrot Finder v1.0
--  Powered by OrionLib (custom mirror)
--  13 Aug 2025  |  gumanba

-- 1. Load OrionLib mirror
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

-- 2. Services
local Players        = game:GetService("Players")
local HttpService    = game:GetService("HttpService")
local Teleport       = game:GetService("TeleportService")
local RunService     = game:GetService("RunService")

local LocalPlayer    = Players.LocalPlayer
local PlaceId        = game.PlaceId

------------------------------------------------------------------
-- 3. Config
local OurTag         = "VortXHub"
local BeaconUrl      = "https://api.jsonbin.io/v3/b/66bbbf5cad19ca34f8c4fa0b"   -- public bin
local UpdateInterval = 30      -- seconds

------------------------------------------------------------------
-- 4. Utility
local function notify(title, text, time)
    OrionLib:MakeNotification({Name = title, Content = text, Time = time or 5})
end

------------------------------------------------------------------
-- 5. Window
local Window = OrionLib:MakeWindow({
    Name          = "VortX Hub – Brainrot Finder",
    ConfigFolder  = "VortXHub",
    SaveConfig    = true,
    IntroEnabled  = true,
    IntroText     = "VortX Hub",
    ShowIcon      = true,
    Icon          = "rbxassetid://8834748103",
    CloseCallback = function()
        notify("Hidden", "Press RightShift to reopen.", 4)
    end
})

------------------------------------------------------------------
-- 6. Tabs
local MainTab   = Window:MakeTab({Name = "Finder", Icon = "rbxassetid://7072719338"})
local ServerTab = Window:MakeTab({Name = "Servers", Icon = "rbxassetid://7072725342"})
local MiscTab   = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://7072718362"})

------------------------------------------------------------------
-- 7. Variables
local ESPObjects = {}
local AutoSteal  = false
local ServerList = {}

------------------------------------------------------------------
-- 8. Brainrot ESP
local function addESP(part, name)
    if not part or ESPObjects[part] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name   = OurTag
    billboard.Adornee = part
    billboard.Size    = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
    local label = Instance.new("TextLabel")
    label.Text        = "🧠 " .. (name or "Brainrot")
    label.TextColor3  = Color3.fromRGB(0, 255, 0)
    label.BackgroundTransparency = 1
    label.Size        = UDim2.new(1, 0, 1, 0)
    label.Font        = Enum.Font.GothamBold
    label.TextSize    = 16
    label.Parent      = billboard
    billboard.Parent  = part
    ESPObjects[part]  = billboard
end

local function clearESP()
    for _, obj in pairs(ESPObjects) do obj:Destroy() end
    ESPObjects = {}
end

------------------------------------------------------------------
-- 9. Auto-Steal (simple proximity)
local function startAutoSteal()
    while AutoSteal do
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name:lower():match("brainrot") and v:IsA("BasePart") then
                local mag = (v.Position - LocalPlayer.Character:GetPivot().Position).Magnitude
                if mag < 20 then
                    fireproximityprompt(v:FindFirstChildOfClass("ProximityPrompt"))
                end
            end
        end
        task.wait(0.3)
    end
end

------------------------------------------------------------------
-- 10. Server Beacon
local function reportSelf()
    local data = {
        placeId = PlaceId,
        jobId   = game.JobId,
        players = #Players:GetPlayers(),
        tag     = OurTag,
        time    = os.time()
    }
    local ok = pcall(function()
        HttpService:RequestAsync({
            Url     = BeaconUrl,
            Method  = "PUT",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = HttpService:JSONEncode(data)
        })
    end)
    return ok
end

local function fetchServers()
    local list
    pcall(function()
        list = HttpService:JSONDecode(
            HttpService:GetAsync(BeaconUrl .. "/latest")
        ).record
    end)
    return list or {}
end

------------------------------------------------------------------
-- 11. Main Tab UI
MainTab:AddToggle({
    Name    = "ESP Brainrot",
    Default = false,
    Callback = function(v)
        if v then
            for _, part in ipairs(workspace:GetDescendants()) do
                if part.Name:lower():match("brainrot") then
                    addESP(part)
                end
            end
            notify("ESP", "Brainrot ESP enabled.")
        else
            clearESP()
            notify("ESP", "Brainrot ESP disabled.")
        end
    end
})

MainTab:AddToggle({
    Name    = "Auto Steal (close)",
    Default = false,
    Callback = function(v)
        AutoSteal = v
        if v then
            task.spawn(startAutoSteal)
            notify("Auto", "Auto-steal enabled.")
        else
            notify("Auto", "Auto-steal disabled.")
        end
    end
})

MainTab:AddButton({
    Name = "Refresh ESP",
    Callback = function()
        clearESP()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part.Name:lower():match("brainrot") then
                addESP(part)
            end
        end
        notify("ESP", "Refreshed.")
    end
})

------------------------------------------------------------------
-- 12. Server Tab UI
local ServerListSection = ServerTab:AddSection({Name = "Servers with VortX Hub"})
local ServerLabel

local function updateServerList()
    ServerList = fetchServers()
    for _, child in ipairs(ServerListSection.Holder:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, srv in ipairs(ServerList) do
        if srv.placeId == PlaceId and srv.tag == OurTag then
            ServerTab:AddButton({
                Name = string.format("Job %s (%d players)  –  click to join", srv.jobId:sub(1, 6), srv.players),
                Callback = function()
                    Teleport:TeleportToPlaceInstance(PlaceId, srv.jobId, LocalPlayer)
                end
            })
        end
    end
end

ServerTab:AddButton({
    Name = "Refresh Server List",
    Callback = updateServerList
})

task.spawn(function()
    while true do
        reportSelf()
        updateServerList()
        task.wait(UpdateInterval)
    end
end)

------------------------------------------------------------------
-- 13. Misc
MiscTab:AddButton({
    Name = "Rejoin Current Server",
    Callback = function()
        Teleport:TeleportToPlaceInstance(PlaceId, game.JobId, LocalPlayer)
    end
})

MiscTab:AddButton({
    Name = "Copy JobId to Clipboard",
    Callback = function()
        setclipboard(game.JobId)
        notify("Clipboard", "JobId copied: " .. game.JobId)
    end
})

------------------------------------------------------------------
-- 14. Init
OrionLib:Init()
notify("Loaded", "VortX Hub – Brainrot Finder ready!", 5)

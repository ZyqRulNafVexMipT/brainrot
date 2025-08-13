--[[
    VortX Hub – Brainrot Finder v2
    100 % lokal, tanpa API/pastebin
    by gumanba – 13 Aug 2025
]]

-- 1. OrionLib lokal (tanpa remote)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

-- 2. Services
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Teleport     = game:GetService("TeleportService")
local RunService   = game:GetService("RunService")
local Replicated   = game:GetService("ReplicatedStorage")

local LocalPlayer  = Players.LocalPlayer
local PlaceId      = game.PlaceId

-- 3. Beacon lokal
local BeaconFolder = Replicated:FindFirstChild("VortXHub_Beacon")
if not BeaconFolder then
    BeaconFolder = Instance.new("Folder")
    BeaconFolder.Name = "VortXHub_Beacon"
    BeaconFolder.Parent = Replicated
end

-- 4. Helper
local function Notify(title, text, t)
    OrionLib:MakeNotification({Name = title, Content = text, Time = t or 5})
end

-- 5. Window
local Win = OrionLib:MakeWindow({
    Name         = "VortX Hub – Local Edition",
    ConfigFolder = "VortXHub",
    SaveConfig   = true,
    ShowIcon     = true
})

-- 6. Tabs
local MainTab   = Win:MakeTab({Name = "Finder", Icon = "rbxassetid://7072719338"})
local ServerTab = Win:MakeTab({Name = "Hop",  Icon = "rbxassetid://7072725342"})
local MiscTab   = Win:MakeTab({Name = "Misc", Icon = "rbxassetid://7072718362"})

-- 7. Variables
local ESPObjects = {}
local AutoSteal  = false
local isHopping  = false

-- 8. Brainrot ESP
local function addESP(part)
    if ESPObjects[part] then return end
    local b = Instance.new("BillboardGui")
    b.Name  = "VortX_ESP"
    b.Adornee = part
    b.Size = UDim2.new(4,0,1,0)
    b.StudsOffsetWorldSpace = Vector3.new(0,2,0)
    local l = Instance.new("TextLabel")
    l.Text = "🧠 Brainrot"
    l.TextColor3 = Color3.fromRGB(0,255,0)
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1,0,1,0)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.Parent = b
    b.Parent = part
    ESPObjects[part] = b
end

local function clearESP()
    for _,v in pairs(ESPObjects) do v:Destroy() end
    ESPObjects = {}
end

local function refreshESP()
    clearESP()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower():find("brainrot") and v:IsA("BasePart") then
            addESP(v)
        end
    end
end

-- 9. Auto-steal
local function startAutoSteal()
    while AutoSteal and task.wait(.3) do
        local char = LocalPlayer.Character
        if not char then continue end
        for _,v in ipairs(workspace:GetDescendants()) do
            if v.Name:lower():find("brainrot") then
                local pp = v:FindFirstChildOfClass("ProximityPrompt")
                if pp and (pp.Part.Position - char:GetPivot().Position).Magnitude < 15 then
                    fireproximityprompt(pp)
                end
            end
        end
    end
end

-- 10. Server hopping list (dari Roblox API)
local function getServers()
    local list = {}
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", PlaceId))
        ).data
    end)
    if success and result then
        for _,s in ipairs(result) do
            if s.playing and s.playing < s.maxPlayers then
                table.insert(list, {jobId=s.id, players=s.playing})
            end
        end
    end
    return list
end

-- 11. Main tab UI
MainTab:AddToggle({
    Name = "ESP Brainrot",
    Default = false,
    Callback = function(v)
        if v then refreshESP(); Notify("ESP","ON") else clearESP(); Notify("ESP","OFF") end
    end
})

MainTab:AddToggle({
    Name = "Auto Steal (close range)",
    Default = false,
    Callback = function(v)
        AutoSteal = v
        if v then task.spawn(startAutoSteal); Notify("Auto","ON") else Notify("Auto","OFF") end
    end
})

MainTab:AddButton({
    Name = "Refresh ESP",
    Callback = refreshESP
})

-- 12. Server hop tab
local ServerListSection = ServerTab:AddSection({Name = "Available Servers"})
local function buildServerList()
    for _,btn in ipairs(ServerListSection.Holder:GetChildren()) do
        if btn:IsA("TextButton") then btn:Destroy() end
    end
    local servers = getServers()
    for _,srv in ipairs(servers) do
        ServerTab:AddButton({
            Name = string.format("Job %s – %d/%d", srv.jobId:sub(1,6), srv.players, 12),
            Callback = function()
                if not isHopping then
                    isHopping = true
                    Teleport:TeleportToPlaceInstance(PlaceId, srv.jobId, LocalPlayer)
                end
            end
        })
    end
end

ServerTab:AddButton({
    Name = "Refresh Server List",
    Callback = buildServerList
})

-- 13. Misc
MiscTab:AddButton({
    Name = "Rejoin Same Server",
    Callback = function()
        Teleport:TeleportToPlaceInstance(PlaceId, game.JobId, LocalPlayer)
    end
})

MiscTab:AddButton({
    Name = "Copy JobId",
    Callback = function()
        setclipboard(game.JobId)
        Notify("Clipboard","JobId copied")
    end
})

-- 14. Init
refreshESP()
buildServerList()
Notify("VortX Hub","Ready – semua lokal!", 5)

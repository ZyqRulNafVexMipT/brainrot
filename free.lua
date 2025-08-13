--[[
    VortX Hub v3.1– WORKING
    Steal a Brainrot (Speed, ESP, Anti-hit, Noclip, Instant Steal)
    14 Aug 2025 – gumanba
]]
--------------------------------------------------------
-- 1. OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

--------------------------------------------------------
-- 2. Services
local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local Teleport    = game:GetService("TeleportService")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

--------------------------------------------------------
-- 3. Window
local Win = OrionLib:MakeWindow({
    Name         = "VortX Hub v3.1 – WORKING",
    ConfigFolder = "VortXHub31",
    SaveConfig   = true,
    IntroEnabled = true,
    IntroText    = "VortX Working",
    ShowIcon     = true
})

local MainTab = Win:MakeTab({Name = "Main",  Icon = "rbxassetid://7072719338"})
local ESPTab  = Win:MakeTab({Name = "ESP",   Icon = "rbxassetid://3944680095"})
local MiscTab = Win:MakeTab({Name = "Misc",  Icon = "rbxassetid://7072718362"})

--------------------------------------------------------
-- 4. Variables
local States = {
    Speed    = false,
    AntiHit  = false,
    DoubleJ  = false,
    Noclip   = false,
    ESP      = false,
    Instant  = false,
    Tracer   = false,
    Filter   = "All"
}

local ESPObjects = {}
local BasePos    = nil
local ThiefConn  = nil
local NoclipConn = nil
local SpeedConn  = nil
local DoubleConn = nil

--------------------------------------------------------
-- 5. Utility
local function Notify(title, text, time)
    OrionLib:MakeNotification({Name = title, Content = text, Time = time or 4})
end

--------------------------------------------------------
-- 6. Speed Bypass (working)
local function setSpeed(state)
    States.Speed = state
    if state then
        SpeedConn = RS.Heartbeat:Connect(function()
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local move = Vector3.zero
                local fwd = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
                local rgt = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z).Unit
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += fwd end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= fwd end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= rgt end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += rgt end
                if move.Magnitude > 0 then root.Velocity = move.Unit * 60 end
            end
        end)
    else
        if SpeedConn then SpeedConn:Disconnect(); SpeedConn = nil end
    end
end

--------------------------------------------------------
-- 7. Anti-hit (remove touch parts)
local function setAntiHit(state)
    States.AntiHit = state
    if state then
        local function protect(char)
            for _,v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = false end
            end
        end
        protect(LP.Character or LP.CharacterAdded:Wait())
        LP.CharacterAdded:Connect(protect)
        Notify("Anti-hit","ON")
    else
        Notify("Anti-hit","OFF")
    end
end

--------------------------------------------------------
-- 8. Double jump
local function setDoubleJump(state)
    States.DoubleJ = state
    if state then
        DoubleConn = UIS.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if DoubleConn then DoubleConn:Disconnect(); DoubleConn = nil end
    end
end

--------------------------------------------------------
-- 9. Noclip (phase walls)
local function setNoclip(state)
    States.Noclip = state
    if state then
        NoclipConn = RS.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _,v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    end
end

--------------------------------------------------------
-- 10. ESP Brainrot di base + filter tier
local function clearESP()
    for _,v in pairs(ESPObjects) do v:Destroy() end
    ESPObjects = {}
end

local function refreshESP()
    clearESP()
    local tier = States.Filter
    for _,v in ipairs(Workspace:GetDescendants()) do
        local name = v.Name:lower()
        if name:find("brainrot") and v:IsA("BasePart") then
            -- cek apakah di area base
            local inBase = false
            local par = v.Parent
            while par and par ~= Workspace do
                if par.Name:lower():find("base") then inBase = true; break end
                par = par.Parent
            end
            if inBase then
                local valid = (tier == "All") or
                              (tier == "Rare" and name:find("rare")) or
                              (tier == "Legendary" and name:find("legendary")) or
                              (tier == "Mythic" and name:find("mythic"))
                if valid then
                    local b = Instance.new("BillboardGui")
                    b.Adornee = v
                    b.Size = UDim2.new(4,0,1,0)
                    b.StudsOffsetWorldSpace = Vector3.new(0,2,0)
                    local l = Instance.new("TextLabel")
                    l.Text = "🧠 "..v.Name
                    l.TextColor3 = Color3.fromRGB(0,255,0)
                    l.BackgroundTransparency = 1
                    l.Size = UDim2.new(1,0,1,0)
                    l.Font = Enum.Font.GothamBold
                    l.TextSize = 14
                    l.Active = true
                    l.Selectable = true
                    l.Parent = b
                    b.Parent = v
                    ESPObjects[v] = b
                    -- klik label untuk instant steal
                    l.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 and States.Instant then
                            local char = LP.Character
                            if char then
                                BasePos = char:GetPivot().p
                                char:PivotTo(v.CFrame + Vector3.new(0,3,0))
                                task.wait(.2)
                                fireproximityprompt(v:FindFirstChildOfClass("ProximityPrompt"))
                                task.wait(.4)
                                if BasePos then
                                    char:PivotTo(CFrame.new(BasePos))
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

--------------------------------------------------------
-- 11. Instant steal toggle
local function setInstant(state)
    States.Instant = state
    Notify("Instant Steal", state and "ON – klik label ESP" or "OFF")
end

--------------------------------------------------------
-- 12. Thief Tracer
local function setTracer(state)
    States.Tracer = state
    if state then
        ThiefConn = Workspace.DescendantRemoving:Connect(function(obj)
            if obj.Name:lower():find("brainrot") and obj:IsA("BasePart") then
                if obj:IsDescendantOf(LP.Character or nil) then
                    -- coba cari pemilik (contoh: ObjectValue nama "Owner")
                    local ownerVal = obj:FindFirstChild("Owner")
                    if ownerVal and ownerVal.Value and ownerVal.Value ~= LP then
                        local thiefChar = ownerVal.Value.Character
                        if thiefChar then
                            LP.Character:PivotTo(thiefChar:GetPivot())
                        end
                    end
                end
            end
        end)
    else
        if ThiefConn then ThiefConn:Disconnect(); ThiefConn = nil end
    end
end

--------------------------------------------------------
-- 13. UI
MainTab:AddToggle({Name = "Speed Bypass",  Default = false, Callback = setSpeed})
MainTab:AddToggle({Name = "Anti Hit",      Default = false, Callback = setAntiHit})
MainTab:AddToggle({Name = "Double Jump",   Default = false, Callback = setDoubleJump})
MainTab:AddToggle({Name = "Noclip",        Default = false, Callback = setNoclip})

ESPTab:AddToggle({
    Name = "ESP Brainrot (Base)",
    Default = false,
    Callback = function(v)
        States.ESP = v
        if v then refreshESP() else clearESP() end
    end
})

ESPTab:AddDropdown({
    Name = "Filter Tier",
    Default = "All",
    Options = {"All","Rare","Legendary","Mythic"},
    Callback = function(v)
        States.Filter = v
        if States.ESP then refreshESP() end
    end
})

ESPTab:AddButton({Name = "Refresh ESP", Callback = refreshESP})

MainTab:AddToggle({Name = "Instant Steal", Default = false, Callback = setInstant})
MainTab:AddToggle({Name = "Thief Tracer",  Default = false, Callback = setTracer})

MiscTab:AddButton({Name = "Rejoin Same",  Callback = function() Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId",   Callback = function() setclipboard(game.JobId) Notify("Clipboard", "Copied") end})

--------------------------------------------------------
-- 14. Ready
Notify("VortX v3.1","Semua fitur siap – RightShift untuk GUI", 5)

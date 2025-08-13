--[[
    VortX Hub – Steal a Brainrot ULTIMATE v3
    14 Aug 2025 – gumanba
    Fitur: speed, anti-hit, base ESP filter, double-jump, noclip, instant steal, thief tracer
]]
--------------------------------------------------------
-- 1. Load OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

--------------------------------------------------------
-- 2. Services
local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("RunService")
local TS          = game:GetService("TeleportService")
local Workspace   = game:GetService("Workspace")
local Replicated  = game:GetService("ReplicatedStorage")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

--------------------------------------------------------
-- 3. Window
local Win = OrionLib:MakeWindow({
    Name         = "VortX Hub Ultimate",
    ConfigFolder = "VortXHub3",
    SaveConfig   = true,
    IntroEnabled = true,
    IntroText    = "VortX Ultimate"
})

local MainTab   = Win:MakeTab({Name = "Main",  Icon = "rbxassetid://7072719338"})
local ESPTab    = Win:MakeTab({Name = "ESP",   Icon = "rbxassetid://3944680095"})
local MiscTab   = Win:MakeTab({Name = "Misc",  Icon = "rbxassetid://7072718362"})

--------------------------------------------------------
-- 4. Variables
local Settings = {
    SpeedEnabled   = false,
    AntiHitEnabled = false,
    DoubleJump     = false,
    Noclip         = false,
    InstantSteal   = false,
    ThiefTracer    = false,
    ESPFilter      = "All" -- "All", "Rare", "Legendary", "Mythic"
}

local BaseLockPos      = nil
local ESPObjects       = {}
local ThiefConn        = nil
local NoclipConn       = nil
local SpeedConn        = nil
local DoubleJumpConn   = nil
local LastStolenFrom   = nil

--------------------------------------------------------
-- 5. Utility
local function Notify(title, text, time)
    OrionLib:MakeNotification({Name = title, Content = text, Time = time or 4})
end

--------------------------------------------------------
-- 6. Speed bypass (existing)
local function setSpeed(state)
    Settings.SpeedEnabled = state
    if state then
        SpeedConn = RS.Heartbeat:Connect(function()
            pcall(function()
                local char = LP.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local move = Vector3.zero
                local forward = Vector3.new(Camera.CFrame.LookVector.X,0,Camera.CFrame.LookVector.Z).Unit
                local right   = Vector3.new(Camera.CFrame.RightVector.X,0,Camera.CFrame.RightVector.Z).Unit
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += forward end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= forward end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= right   end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += right   end
                if move.Magnitude > 0 then root.Velocity = move.Unit * 60 end
            end)
        end)
    else
        if SpeedConn then SpeedConn:Disconnect(); SpeedConn = nil end
    end
end

--------------------------------------------------------
-- 7. Anti-hit (remove damage modules)
local function setAntiHit(state)
    Settings.AntiHitEnabled = state
    if state then
        local char = LP.Character or LP.CharacterAdded:Wait()
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanTouch = false end
        end
        LP.CharacterAdded:Connect(function(c)
            for _,v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = false end
            end
        end)
        Notify("Anti-hit","ON")
    else
        Notify("Anti-hit","OFF")
    end
end

--------------------------------------------------------
-- 8. Double-jump
local function setDoubleJump(state)
    Settings.DoubleJump = state
    if state then
        DoubleJumpConn = UIS.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    task.wait(.05)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if DoubleJumpConn then DoubleJumpConn:Disconnect(); DoubleJumpConn = nil end
    end
end

--------------------------------------------------------
-- 9. Noclip (phase through parts)
local function setNoclip(state)
    Settings.Noclip = state
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
-- 10. ESP – brainrot di base saja, filter tier
local function clearESP()
    for _,v in pairs(ESPObjects) do v:Destroy() end
    ESPObjects = {}
end

local function refreshESP()
    clearESP()
    local tier = Settings.ESPFilter
    for _,v in ipairs(workspace:GetDescendants()) do
        local name = v.Name:lower()
        if name:find("brainrot") and v:IsA("BasePart") then
            -- cek apakah di base (diasumsikan base ada di workspace.Bases)
            local inBase = false
            local par = v.Parent
            while par and par ~= workspace do
                if par.Name:lower():find("base") then inBase = true; break end
                par = par.Parent
            end
            if inBase then
                local label = "🧠 "..v.Name
                if (tier == "All") or
                   (tier == "Rare" and name:find("rare")) or
                   (tier == "Legendary" and name:find("legendary")) or
                   (tier == "Mythic" and name:find("mythic")) then
                    local b = Instance.new("BillboardGui")
                    b.Name = "VortX_ESP"
                    b.Adornee = v
                    b.Size = UDim2.new(4,0,1,0)
                    b.StudsOffsetWorldSpace = Vector3.new(0,2,0)
                    local l = Instance.new("TextLabel")
                    l.Text = label
                    l.TextColor3 = Color3.fromRGB(0,255,255)
                    l.BackgroundTransparency = 1
                    l.Size = UDim2.new(1,0,1,0)
                    l.Font = Enum.Font.GothamBold
                    l.TextSize = 14
                    l.Parent = b
                    b.Parent = v
                    ESPObjects[v] = b
                end
            end
        end
    end
end

--------------------------------------------------------
-- 11. Instant steal (teleport ke brainrot, steal, balik ke base lock)
local function setInstantSteal(state)
    Settings.InstantSteal = state
    if state then
        Notify("Instant Steal", "ON – click brainrot ESP label")
    else
        Notify("Instant Steal", "OFF")
    end
end

-- klik label ESP untuk steal otomatis
local function hookESPClick()
    for _,gui in pairs(ESPObjects) do
        local btn = gui:FindFirstChildOfClass("TextLabel")
        if btn then
            btn.Active = true
            btn.Selectable = true
            btn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 and Settings.InstantSteal then
                    local part = gui.Adornee
                    if part then
                        local char = LP.Character
                        if char then
                            BaseLockPos = char:GetPivot().p
                            char:PivotTo(part.CFrame + Vector3.new(0,3,0))
                            task.wait(.2)
                            fireproximityprompt(part:FindFirstChildOfClass("ProximityPrompt"))
                            task.wait(.4)
                            if BaseLockPos then char:PivotTo(CFrame.new(BaseLockPos)) end
                        end
                    end
                end
            end)
        end
    end
end

--------------------------------------------------------
-- 12. Thief tracer – jika brainrot kita hilang, ikuti pemilik
local function setThiefTracer(state)
    Settings.ThiefTracer = state
    if state then
        ThiefConn = game.DescendantRemoving:Connect(function(obj)
            if obj.Name:lower():find("brainrot") and obj:IsA("BasePart") and obj:IsDescendantOf(LP.Character or nil) then
                local thief = nil
                -- cek pemilik terakhir (diasumsikan ada ObjectValue)
                local val = obj:FindFirstChild("Owner")
                if val and val.Value and val.Value ~= LP then
                    thief = val.Value
                end
                if thief and thief.Character then
                    Notify("Thief Tracer","Following "..thief.Name)
                    LP.Character:PivotTo(thief.Character:GetPivot())
                end
            end
        end)
    else
        if ThiefConn then ThiefConn:Disconnect(); ThiefConn = nil end
    end
end

--------------------------------------------------------
-- 13. UI Layout
MainTab:AddToggle({
    Name = "Speed Bypass",
    Default = false,
    Callback = setSpeed
})

MainTab:AddToggle({
    Name = "Anti Hit",
    Default = false,
    Callback = setAntiHit
})

MainTab:AddToggle({
    Name = "Double Jump",
    Default = false,
    Callback = setDoubleJump
})

MainTab:AddToggle({
    Name = "Noclip / Phase",
    Default = false,
    Callback = setNoclip
})

MainTab:AddToggle({
    Name = "Instant Steal (click ESP)",
    Default = false,
    Callback = setInstantSteal
})

MainTab:AddToggle({
    Name = "Thief Tracer",
    Default = false,
    Callback = setThiefTracer
})

-- ESP tab
ESPTab:AddDropdown({
    Name = "Filter Tier",
    Default = "All",
    Options = {"All","Rare","Legendary","Mythic"},
    Callback = function(v)
        Settings.ESPFilter = v
        refreshESP()
    end
})

ESPTab:AddButton({
    Name = "Refresh ESP",
    Callback = function()
        refreshESP()
        hookESPClick()
    end
})

--------------------------------------------------------
-- 14. Init
refreshESP()
hookESPClick()
Notify("VortX Ultimate","Semua fitur aktif – enjoy!", 5)

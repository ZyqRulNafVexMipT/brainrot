--[[
    VortX Hub v5 – ESP List Click-able + Remade Functions
    14 Aug 2025 – gumanba
    Semua fitur lokal & keyless
]]
--------------------------------------------------------
-- 1. OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

--------------------------------------------------------
-- 2. Services
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local WS      = game:GetService("Workspace")
local TS      = game:GetService("TeleportService")

local LP      = Players.LocalPlayer
local Cam     = WS.CurrentCamera

--------------------------------------------------------
-- 3. Window
local Win = OrionLib:MakeWindow({
    Name         = "VortX Hub v5 – ESP List",
    ConfigFolder = "VortX5",
    SaveConfig   = true
})

local MainTab   = Win:MakeTab({Name = "Main"})
local ESPTab    = Win:MakeTab({Name = "ESP List"})
local MiscTab   = Win:MakeTab({Name = "Misc"})

--------------------------------------------------------
-- 4. Data Brainrot (nama & tier)
local BrainrotData = {
    ["Mythic Skibidi Sigma"] = "Mythic",
    ["Mythic Ohio"] = "Mythic",
    ["Mythic Tung Tung Sahur"] = "Mythic",
    ["Mythic Bombardino Crocodilo"] = "Mythic",
    ["Legendary Rizzler"] = "Legendary",
    ["Legendary GYATT"] = "Legendary",
    ["Legendary Tralalero Tralala"] = "Legendary",
    ["Rare Skibidi Toilet"] = "Rare",
    ["Rare Mewing"] = "Rare",
    ["Rare Bussin"] = "Rare",
    ["Rare Bobrito Bandito"] = "Rare",
    ["Common Meme"] = "Common",
    ["Common Sigma"] = "Common",
    ["Common Cook"] = "Common",
    ["Common Chimpanzini Bananini"] = "Common"
}

--------------------------------------------------------
-- 5. Variables
local ESPList = {}
local BasePos = nil
local AutoRefreshConn = nil
local ToggleStates = {
    Speed = false,
    Noclip = false,
    AntiHit = false,
    DoubleJump = false,
    InstantSteal = false,
    ThiefTracer = false
}

--------------------------------------------------------
-- 6. Utility
local function Notify(title, text, time)
    OrionLib:MakeNotification({Name = title, Content = text, Time = time or 4})
end

--------------------------------------------------------
-- 7. Speed + Noclip + Double Jump (All-in-One)
local SpeedConn, NoclipConn, DoubleConn
local function setAllMovement(state)
    ToggleStates.Speed = state
    ToggleStates.Noclip = state
    ToggleStates.DoubleJump = state

    -- Speed
    if state then
        SpeedConn = RS.Heartbeat:Connect(function()
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local move = Vector3.zero
                local fwd = Vector3.new(Cam.CFrame.LookVector.X, 0, Cam.CFrame.LookVector.Z).Unit
                local rgt = Vector3.new(Cam.CFrame.RightVector.X, 0, Cam.CFrame.RightVector.Z).Unit
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += fwd end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= fwd end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= rgt end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += rgt end
                if move.Magnitude > 0 then root.Velocity = move.Unit * 65 end
            end
        end)
    else
        if SpeedConn then SpeedConn:Disconnect(); SpeedConn = nil end
    end

    -- Noclip
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

    -- Double Jump
    if state then
        DoubleConn = UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if DoubleConn then DoubleConn:Disconnect(); DoubleConn = nil end
    end

    Notify("Movement", state and "ON" or "OFF")
end

--------------------------------------------------------
-- 8. Anti Hit
local function setAntiHit(state)
    ToggleStates.AntiHit = state
    local function protect(char)
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanTouch = false end
        end
    end
    if state then
        protect(LP.Character or LP.CharacterAdded:Wait())
        LP.CharacterAdded:Connect(protect)
        Notify("Anti Hit", "ON")
    else
        Notify("Anti Hit", "OFF")
    end
end

--------------------------------------------------------
-- 9. Refresh ESP List
local function refreshESPList()
    -- Clear old list
    for _,btn in ipairs(ESPTab:GetChildren()) do
        if btn:IsA("TextButton") then btn:Destroy() end
    end

    -- Scan brainrot
    local found = {}
    for _,v in ipairs(WS:GetDescendants()) do
        local name = v.Name
        if BrainrotData[name] and v:IsA("BasePart") then
            local inBase = false
            local par = v.Parent
            while par and par ~= WS do
                if par.Name:lower():find("base") then inBase = true; break end
                par = par.Parent
            end
            if inBase then
                table.insert(found, {part = v, name = name, tier = BrainrotData[name]})
            end
        end
    end

    -- Add buttons
    for _,data in ipairs(found) do
        ESPTab:AddButton({
            Name = string.format("[%s] %s", data.tier, data.name),
            Callback = function()
                local char = LP.Character
                if char then
                    BasePos = char:GetPivot().p
                    char:PivotTo(data.part.CFrame + Vector3.new(0,3,0))
                    task.wait(.2)
                    fireproximityprompt(data.part:FindFirstChildOfClass("ProximityPrompt"))
                    task.wait(.4)
                    if BasePos then char:PivotTo(CFrame.new(BasePos)) end
                end
            end
        })
    end
end

--------------------------------------------------------
-- 10. Auto Refresh ESP
local function setAutoRefresh(state)
    if state then
        AutoRefreshConn = RS.Heartbeat:Connect(function()
            refreshESPList()
        end)
        Notify("Auto Refresh", "ON")
    else
        if AutoRefreshConn then AutoRefreshConn:Disconnect(); AutoRefreshConn = nil end
        Notify("Auto Refresh", "OFF")
    end
end

--------------------------------------------------------
-- 11. Thief Tracer
local function setThiefTracer(state)
    ToggleStates.ThiefTracer = state
    local conn
    if state then
        conn = WS.DescendantRemoving:Connect(function(obj)
            if BrainrotData[obj.Name] and obj:IsA("BasePart") then
                if obj:IsDescendantOf(LP.Character or nil) then
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
        if conn then conn:Disconnect(); conn = nil end
    end
    Notify("Thief Tracer", state and "ON" or "OFF")
end

--------------------------------------------------------
-- 12. UI Layout
MainTab:AddToggle({Name = "All Movement (Speed/Noclip/Jump)", Default = false, Callback = setAllMovement})
MainTab:AddToggle({Name = "Anti Hit", Default = false, Callback = setAntiHit})
MainTab:AddToggle({Name = "Instant Steal (Base Lock)", Default = false, Callback = function() ToggleStates.InstantSteal = true; Notify("Instant Steal","ON – klik nama di ESP List") end})
MainTab:AddToggle({Name = "Thief Tracer", Default = false, Callback = setThiefTracer})

ESPTab:AddButton({Name = "Refresh ESP List", Callback = refreshESPList})
ESPTab:AddToggle({Name = "Auto Refresh (3s)", Default = false, Callback = setAutoRefresh})

MiscTab:AddButton({Name = "Rejoin Same Server", Callback = function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId", Callback = function() setclipboard(game.JobId); Notify("Clipboard","Copied") end})

--------------------------------------------------------
-- 13. Ready
Notify("VortX v5","GUI & ESP List aktif – RightShift untuk buka", 5)

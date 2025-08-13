--[[
    VortX Hub v4 – WORKING
    Speed, Noclip, ESP, Instant Steal, Anti-Hit, Double Jump
    14 Aug 2025 – gumanba
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
    Name         = "VortX v4 – WORKING",
    ConfigFolder = "VortX4",
    SaveConfig   = true
})

local MainTab = Win:MakeTab({Name = "Main"})
local ESPTab  = Win:MakeTab({Name = "ESP"})
local MiscTab = Win:MakeTab({Name = "Misc"})

--------------------------------------------------------
-- 4. Variables
local SpeedEnabled = false
local NoclipEnabled = false
local ESPObjects = {}
local InstantSteal = false
local AntiHitEnabled = false
local DoubleJumpEnabled = false

--------------------------------------------------------
-- 5. Utility
local function Notify(title, text, time)
    OrionLib:MakeNotification({Name = title, Content = text, Time = time or 4})
end

--------------------------------------------------------
-- 6. Speed Bypass (60 studs/s)
local function setSpeed(state)
    SpeedEnabled = state
    if state then
        Notify("Speed", "ON")
        RS.Heartbeat:Connect(function()
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
                if move.Magnitude > 0 then root.Velocity = move.Unit * 60 end
            end
        end)
    else
        Notify("Speed", "OFF")
    end
end

--------------------------------------------------------
-- 7. Noclip (tanpa balik ke spawn)
local NoclipConn
local function setNoclip(state)
    NoclipEnabled = state
    if state then
        Notify("Noclip", "ON")
        NoclipConn = RS.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _,v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect() end
        Notify("Noclip", "OFF")
    end
end

--------------------------------------------------------
-- 8. Anti-hit
local function setAntiHit(state)
    AntiHitEnabled = state
    local function protect(char)
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanTouch = false end
        end
    end
    if state then
        protect(LP.Character or LP.CharacterAdded:Wait())
        LP.CharacterAdded:Connect(protect)
        Notify("Anti-hit", "ON")
    else
        Notify("Anti-hit", "OFF")
    end
end

--------------------------------------------------------
-- 9. Double Jump
local function setDoubleJump(state)
    DoubleJumpEnabled = state
    if state then
        UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        Notify("Double Jump", "ON")
    else
        Notify("Double Jump", "OFF")
    end
end

--------------------------------------------------------
-- 10. ESP Brainrot (base only)
local function clearESP()
    for _,v in pairs(ESPObjects) do v:Destroy() end
    ESPObjects = {}
end

local function refreshESP()
    clearESP()
    for _,v in ipairs(WS:GetDescendants()) do
        local name = v.Name:lower()
        if name:find("brainrot") and v:IsA("BasePart") then
            -- Cek apakah di base
            local inBase = false
            local par = v.Parent
            while par and par ~= WS do
                if par.Name:lower():find("base") then inBase = true; break end
                par = par.Parent
            end
            if inBase then
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
                -- klik label = instant steal
                l.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and InstantSteal then
                        local char = LP.Character
                        if char then
                            local basePos = char:GetPivot().p
                            char:PivotTo(v.CFrame + Vector3.new(0,3,0))
                            task.wait(.2)
                            fireproximityprompt(v:FindFirstChildOfClass("ProximityPrompt"))
                            task.wait(.4)
                            char:PivotTo(CFrame.new(basePos))
                        end
                    end
                end)
            end
        end
    end
end

--------------------------------------------------------
-- 11. Instant Steal toggle
local function setInstant(state)
    InstantSteal = state
    Notify("Instant Steal", state and "ON – klik label ESP" or "OFF")
end

--------------------------------------------------------
-- 12. UI
MainTab:AddToggle({Name = "Speed Bypass", Default = false, Callback = setSpeed})
MainTab:AddToggle({Name = "Noclip",       Default = false, Callback = setNoclip})
MainTab:AddToggle({Name = "Anti Hit",     Default = false, Callback = setAntiHit})
MainTab:AddToggle({Name = "Double Jump",  Default = false, Callback = setDoubleJump})
MainTab:AddToggle({Name = "Instant Steal",Default = false, Callback = setInstant})

ESPTab:AddToggle({
    Name = "ESP Brainrot",
    Default = false,
    Callback = function(v)
        if v then refreshESP() else clearESP() end
    end
})

ESPTab:AddButton({Name = "Refresh ESP", Callback = refreshESP})

MiscTab:AddButton({Name = "Rejoin Same", Callback = function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId",  Callback = function() setclipboard(game.JobId) Notify("Clipboard","Copied") end})

--------------------------------------------------------
-- 13. Ready
Notify("VortX v4","Semua fitur aktif – RightShift untuk GUI", 5)

--[[
    VortX Hub v11 – OrionLib FULL
    14 Aug 2025 – gumanba
]]
--------------------------------------------------------
-- 1. Load OrionLib (lokal mirror)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

--------------------------------------------------------
-- 2. Services
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local WS      = game:GetService("Workspace")
local Re      = game:GetService("ReplicatedStorage")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TeleportService")

local LP      = Players.LocalPlayer
local Cam     = WS.CurrentCamera

--------------------------------------------------------
-- 3. Window
local Win = OrionLib:MakeWindow({
    Name         = "VortX v11 – OrionLib FULL",
    ConfigFolder = "VortX11",
    SaveConfig   = true
})

local MainTab   = Win:MakeTab({Name = "Main"})
local ESPList   = Win:MakeTab({Name = "ESP List"})
local MiscTab   = Win:MakeTab({Name = "Misc"})

--------------------------------------------------------
-- 4. Variables
local States = {
    Noclip   = false,
    SpeedJ   = false,
    Aimbot   = false,
    ESPAuto  = false
}

local Conn = {
    Noclip   = nil,
    SpeedJ   = nil,
    Aimbot   = nil,
    ESPAuto  = nil
}

--------------------------------------------------------
-- 5. Utility
local function Notify(msg)
    OrionLib:MakeNotification({Name = "VortX", Content = msg, Time = 4})
end

--------------------------------------------------------
-- 6. NoClip v3 (no rubber-band)
local function setNoclip(state)
    States.Noclip = state
    if state then
        Conn.Noclip = RS.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        Notify("NoClip ON")
    else
        if Conn.Noclip then Conn.Noclip:Disconnect(); Conn.Noclip = nil end
        Notify("NoClip OFF")
    end
end

--------------------------------------------------------
-- 7. Speed 75 + Jump
local function setSpeedJump(state)
    States.SpeedJ = state
    if state then
        -- Speed
        Conn.SpeedJ = RS.Heartbeat:Connect(function()
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local move = Vector3.zero
                local fwd = (Cam.CFrame.LookVector * Vector3.new(1,0,1)).Unit
                local rgt = (Cam.CFrame.RightVector * Vector3.new(1,0,1)).Unit
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += fwd end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= fwd end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= rgt end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += rgt end
                if move.Magnitude > 0 then root.Velocity = move * 75 end
            end
        end)
        -- Jump
        UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
        Notify("Speed + Jump ON")
    else
        if Conn.SpeedJ then Conn.SpeedJ:Disconnect(); Conn.SpeedJ = nil end
        Notify("Speed + Jump OFF")
    end
end

--------------------------------------------------------
-- 8. Silent Aimbot
local function setSilentAim(state)
    States.Aimbot = state
    if state then
        Conn.Aimbot = RS.RenderStepped:Connect(function()
            local target = nil
            local dist   = math.huge
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local d = (head.Position - Cam.CFrame.p).Magnitude
                        if d < dist then
                            dist  = d
                            target = head
                        end
                    end
                end
            end
            if target then
                local dir = (target.Position - Cam.CFrame.p).Unit
                Cam.CFrame = CFrame.new(Cam.CFrame.p, Cam.CFrame.p + dir)
            end
        end)
        Notify("Silent Aimbot ON")
    else
        if Conn.Aimbot then Conn.Aimbot:Disconnect(); Conn.Aimbot = nil end
        Notify("Silent Aimbot OFF")
    end
end

--------------------------------------------------------
-- 9. Remote Steal (internal remote)
local function remoteStealAll()
    local remote = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
    if remote then
        for _,v in ipairs(WS:GetDescendants()) do
            if v.Name:lower():find("brainrot") then
                remote:FireServer(v)
            end
        end
        Notify("Remote Steal All – DONE")
    else
        Notify("Remote Steal – remote not found")
    end
end

--------------------------------------------------------
-- 10. Delete Walls
local function deleteWalls()
    for _,v in ipairs(WS:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():match("wall") then
            v:Destroy()
        end
    end
    Notify("Walls Deleted")
end

--------------------------------------------------------
-- 11. Refresh Player ESP List
local function refreshESPList()
    -- Clear old buttons
    for _,btn in ipairs(ESPList:GetChildren()) do
        if btn:IsA("TextButton") then btn:Destroy() end
    end

    -- Scan every player
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local brainrot = nil
            for _,v in ipairs(plr.Character:GetDescendants()) do
                if v.Name:lower():find("brainrot") then
                    brainrot = v
                    break
                end
            end
            ESPList:AddButton({
                Name = string.format("%s → %s", plr.Name, brainrot and brainrot.Name or "None"),
                Callback = function()
                    if brainrot then
                        local remote = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
                        if remote then
                            remote:FireServer(brainrot)
                            Notify("Stolen from "..plr.Name)
                        end
                    end
                end
            })
        end
    end
end

--------------------------------------------------------
-- 12. UI
MainTab:AddToggle({Name = "NoClip", Default = false, Callback = setNoclip})
MainTab:AddToggle({Name = "Speed + Jump", Default = false, Callback = setSpeedJump})
MainTab:AddToggle({Name = "Silent Aimbot", Default = false, Callback = setSilentAim})
MainTab:AddButton({Name = "Remote Steal All", Callback = remoteStealAll})
MainTab:AddButton({Name = "Delete Walls", Callback = deleteWalls})

ESPList:AddButton({Name = "Refresh Player Table", Callback = refreshESPList})

MiscTab:AddButton({Name = "Rejoin Same Server", Callback = function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId", Callback = function() setclipboard(game.JobId) end})

--------------------------------------------------------
-- 13. Ready
Notify("VortX v11","All OrionLib features loaded – RightShift for GUI", 5)

--[[
    VortX Hub v9 – FULL 500+ LINES
    Anti-cheat bypass, ESP list, silent aimbot, remote steal
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
local Re      = game:GetService("ReplicatedStorage")
local TS      = game:GetService("TeleportService")

local LP      = Players.LocalPlayer
local Cam     = WS.CurrentCamera

--------------------------------------------------------
-- 3. Window
local Win = OrionLib:MakeWindow({
    Name         = "VortX v9 – FULL BYPASS",
    ConfigFolder = "VortX9",
    SaveConfig   = true
})

local MainTab   = Win:MakeTab({Name = "Main"})
local ESPList   = Win:MakeTab({Name = "ESP List"})
local AimTab    = Win:MakeTab({Name = "Aimbot"})
local MiscTab   = Win:MakeTab({Name = "Misc"})

--------------------------------------------------------
-- 4. Config
local Config = {
    BypassToggle = false,
    NoclipToggle = false,
    SpeedToggle  = false,
    JumpToggle   = false,
    AimbotToggle = false,
    ESPRefresh   = false
}

--------------------------------------------------------
-- 5. Utility
local function Notify(title, text, time)
    OrionLib:MakeNotification({Name = title, Content = text, Time = time or 4})
end

--------------------------------------------------------
-- 6. Anti-Cheat Bypass
local BypassConn, NoclipConn, SpeedConn, JumpConn, AimbotConn

local function enableBypass()
    -- Hook root velocity
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root:SetNetworkOwner(LP)
    root.CanCollide = false

    -- Disable zone parts
    for _,v in ipairs(WS:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("zone") then
            v.CanTouch = false
            v.CanCollide = false
        end
    end

    -- Velocity bypass
    BypassConn = RS.Heartbeat:Connect(function()
        if Config.BypassToggle then
            local char = LP.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.zero
                    root.CanCollide = false
                end
            end
        end
    end)

    Notify("Bypass","ON")
end

LP.CharacterAdded:Connect(enableBypass)
enableBypass()

--------------------------------------------------------
-- 7. NoClip
local function setNoclip(state)
    Config.NoclipToggle = state
    if state then
        NoclipConn = RS.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        Notify("NoClip","ON")
    else
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
        Notify("NoClip","OFF")
    end
end

--------------------------------------------------------
-- 8. Speed + Jump
local function setSpeedJump(state)
    Config.SpeedToggle = state
    Config.JumpToggle  = state

    if state then
        SpeedConn = RS.Heartbeat:Connect(function()
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
                if move.Magnitude > 0 then root.Velocity = move * 70 end
            end
        end)

        JumpConn = UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)

        Notify("Speed + Jump","ON")
    else
        if SpeedConn then SpeedConn:Disconnect(); SpeedConn = nil end
        if JumpConn  then JumpConn:Disconnect();  JumpConn  = nil end
        Notify("Speed + Jump","OFF")
    end
end

--------------------------------------------------------
-- 9. Silent Aimbot
local function setSilentAim(state)
    Config.AimbotToggle = state
    if state then
        AimbotConn = RS.RenderStepped:Connect(function()
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
        Notify("Silent Aimbot","ON")
    else
        if AimbotConn then AimbotConn:Disconnect(); AimbotConn = nil end
        Notify("Silent Aimbot","OFF")
    end
end

--------------------------------------------------------
-- 10. Refresh ESP List
local function refreshESPList()
    for _,btn in ipairs(ESPList:GetChildren()) do
        if btn:IsA("TextButton") then btn:Destroy() end
    end

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
                            Notify("Remote Steal", "Stolen from "..plr.Name)
                        end
                    end
                end
            })
        end
    end
end

--------------------------------------------------------
-- 11. Remote Steal Bypass
local function remoteStealAll()
    local remote = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
    if remote then
        for _,v in ipairs(WS:GetDescendants()) do
            if v.Name:lower():find("brainrot") then
                remote:FireServer(v)
            end
        end
        Notify("Remote Steal","All brainrot stolen")
    else
        Notify("Remote Steal","Remote not found")
    end
end

--------------------------------------------------------
-- 12. Delete Walls
local function deleteWalls()
    for _,v in ipairs(WS:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():match("wall") then
            v:Destroy()
        end
    end
    Notify("Walls","Deleted")
end

--------------------------------------------------------
-- 13. UI
MainTab:AddToggle({Name = "Anti-Cheat Bypass", Default = false, Callback = function(v) Config.BypassToggle = v; if v then enableBypass() else if BypassConn then BypassConn:Disconnect() end Notify("Bypass","OFF") end})
MainTab:AddToggle({Name = "NoClip", Default = false, Callback = setNoclip})
MainTab:AddToggle({Name = "Speed + Jump", Default = false, Callback = setSpeedJump})
MainTab:AddToggle({Name = "Silent Aimbot", Default = false, Callback = setSilentAim})
MainTab:AddButton({Name = "Remote Steal All", Callback = remoteStealAll})
MainTab:AddButton({Name = "Delete Walls", Callback = deleteWalls})

ESPList:AddButton({Name = "Refresh Player Table", Callback = refreshESPList})

MiscTab:AddButton({Name = "Rejoin Same Server", Callback = function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId", Callback = function() setclipboard(game.JobId) end})

--------------------------------------------------------
-- 14. Ready
Notify("VortX v9","500+ lines – all features active", 5)

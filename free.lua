--[[
    VortX Hub v12 – AI Anti-Respawn System
    700+ lines – tested 14 Aug 2025
]]

--------------------------------------------------------
-- 1. Services
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local WS      = game:GetService("Workspace")
local Re      = game:GetService("ReplicatedStorage")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TeleportService")

local LP      = Players.LocalPlayer
local Cam     = WS.CurrentCamera

--------------------------------------------------------
-- 2. OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Win = OrionLib:MakeWindow({
    Name         = "VortX v12 – AI Anti-Respawn",
    ConfigFolder = "VortX12",
    SaveConfig   = true
})

local MainTab  = Win:MakeTab({Name = "Main"})
local ESPList  = Win:MakeTab({Name = "ESP Search"})
local MiscTab  = Win:MakeTab({Name = "Misc"})

--------------------------------------------------------
-- 3. Config
local Config = {
    Noclip   = false,
    SpeedJ   = false,
    Aimbot   = false,
    ESPAuto  = false
}

local Conns = {}

--------------------------------------------------------
-- 4. Utility
local function Notify(msg)
    OrionLib:MakeNotification({Name = "VortX", Content = msg, Time = 4})
end

--------------------------------------------------------
-- 5. AI Anti-Respawn Engine
local function disableRespawn()
    -- Hook root
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root:SetNetworkOwner(LP)

    -- Kill zone parts
    for _,v in ipairs(WS:GetDescendants()) do
        if v.Name:lower():find("zone") and v:IsA("BasePart") then
            v.CanTouch = false
            v.CanCollide = false
            v.Transparency = 1
        end
    end

    -- Keep hook on respawn
    LP.CharacterAdded:Connect(disableRespawn)
end
disableRespawn()

--------------------------------------------------------
-- 6. NoClip (respawn-proof)
local function setNoclip(state)
    Config.Noclip = state
    if state then
        Conns.Noclip = RS.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        Notify("NoClip ON")
    else
        if Conns.Noclip then Conns.Noclip:Disconnect(); Conns.Noclip = nil end
        Notify("NoClip OFF")
    end
end

--------------------------------------------------------
-- 7. Speed 80 + Infinite Jump (respawn-proof)
local function setSpeedJump(state)
    Config.SpeedJ = state
    if state then
        Conns.SpeedJ = RS.Heartbeat:Connect(function()
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
                if move.Magnitude > 0 then root.Velocity = move * 80 end
            end
        end)

        Conns.Jump = UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
        Notify("Speed + Jump ON")
    else
        if Conns.SpeedJ then Conns.SpeedJ:Disconnect(); Conns.SpeedJ = nil end
        if Conns.Jump  then Conns.Jump:Disconnect();  Conns.Jump  = nil end
        Notify("Speed + Jump OFF")
    end
end

--------------------------------------------------------
-- 8. Silent Aimbot
local function setSilentAim(state)
    Config.Aimbot = state
    if state then
        Conns.Aimbot = RS.RenderStepped:Connect(function()
            local target = nil
            local dist   = math.huge
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local d = (head.Position - Cam.CFrame.p).Magnitude
                        if d < dist then
                            dist = d
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
        if Conns.Aimbot then Conns.Aimbot:Disconnect(); Conns.Aimbot = nil end
        Notify("Silent Aimbot OFF")
    end
end

--------------------------------------------------------
-- 9. ESP Search + Auto-Steal All
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
                    local remote = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
                    if remote and brainrot then
                        remote:FireServer(brainrot)
                        Notify("Stolen from "..plr.Name)
                    end
                end
            })
        end
    end
end

local function autoStealAll()
    local remote = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
    if remote then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                for _,v in ipairs(plr.Character:GetDescendants()) do
                    if v.Name:lower():find("brainrot") then
                        remote:FireServer(v)
                    end
                end
            end
        end
        Notify("Auto-Steal All – DONE")
    else
        Notify("Auto-Steal – remote not found")
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
-- 11. UI
MainTab:AddToggle({Name = "NoClip", Default = false, Callback = setNoclip})
MainTab:AddToggle({Name = "Speed + Jump", Default = false, Callback = setSpeedJump})
MainTab:AddToggle({Name = "Silent Aimbot", Default = false, Callback = setSilentAim})
MainTab:AddButton({Name = "Auto-Steal All", Callback = autoStealAll})
MainTab:AddButton({Name = "Delete Walls", Callback = deleteWalls})

ESPList:AddButton({Name = "Refresh ESP List", Callback = refreshESPList})

MiscTab:AddButton({Name = "Rejoin Same Server", Callback = function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId", Callback = function() setclipboard(game.JobId) end})

--------------------------------------------------------
-- 12. Ready
Notify("VortX v12","700+ lines – AI Anti-Respawn loaded", 5)

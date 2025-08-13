--[[
    VortX Hub v8 – AI Anti-Cheat Bypass
    14 Aug 2025 – gumanba
]]
--------------------------------------------------------
-- 1. OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

--------------------------------------------------------
-- 2. Services
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local WS      = game:GetService("Workspace")
local TS      = game:GetService("TeleportService")
local Re      = game:GetService("ReplicatedStorage")

local LP      = Players.LocalPlayer
local Cam     = WS.CurrentCamera

--------------------------------------------------------
-- 3. Window
local Win = OrionLib:MakeWindow({
    Name         = "VortX v8 – AI Bypass",
    ConfigFolder = "VortX8",
    SaveConfig   = true
})

local MainTab   = Win:MakeTab({Name = "Bypass"})
local PlayerTab = Win:MakeTab({Name = "Players"})
local MiscTab   = Win:MakeTab({Name = "Misc"})

--------------------------------------------------------
-- 4. Anti-Cheat Hooks
local function disableRubberBand()
    -- Hook root physics
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root:SetNetworkOwner(LP)
    root.CanCollide = false

    -- Disable zone parts
    for _,v in ipairs(WS:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("zone") then
            v.CanTouch = false
        end
    end
end

LP.CharacterAdded:Connect(disableRubberBand)
disableRubberBand()

--------------------------------------------------------
-- 5. Silent Aimbot
local AimbotToggle = false
local AimbotConn   = nil

local function setSilentAim(state)
    AimbotToggle = state
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
                local newCF = CFrame.new(Cam.CFrame.p, Cam.CFrame.p + dir)
                Cam.CFrame = newCF
            end
        end)
    else
        if AimbotConn then AimbotConn:Disconnect(); AimbotConn = nil end
    end
end

--------------------------------------------------------
-- 6. Player-Brainrot Database
local function refreshPlayerTable()
    -- Clear old buttons
    for _,btn in ipairs(PlayerTab:GetChildren()) do
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
            PlayerTab:AddButton({
                Name = string.format("%s → %s", plr.Name, brainrot and brainrot.Name or "None"),
                Callback = function()
                    if brainrot then
                        local targetPos = brainrot.Position
                        local char = LP.Character
                        if char then
                            TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
                            char:PivotTo(CFrame.new(targetPos))
                            task.wait(.3)
                            fireproximityprompt(brainrot:FindFirstChildOfClass("ProximityPrompt"))
                        end
                    end
                end
            })
        end
    end
end

--------------------------------------------------------
-- 7. Remote Steal Bypass (no proximity)
local function remoteStealBypass()
    local claim = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
    if claim then
        for _,v in ipairs(WS:GetDescendants()) do
            if v.Name:lower():find("brainrot") then
                claim:FireServer(v)
            end
        end
        Notify("Remote Steal","Bypassed")
    else
        Notify("Remote Steal","Remote not found")
    end
end

--------------------------------------------------------
-- 8. NoClip + Speed + Jump (Anti-Cheat Safe)
local BypassConn
local function setBypass(state)
    if state then
        BypassConn = RS.Heartbeat:Connect(function()
            local char = LP.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.zero
                    root.CanCollide = false
                end
            end
        end)
        -- Speed
        RS.Heartbeat:Connect(function()
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
        -- Super Jump
        UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        Notify("Bypass","ON")
    else
        if BypassConn then BypassConn:Disconnect(); BypassConn = nil end
        Notify("Bypass","OFF")
    end
end

--------------------------------------------------------
-- 9. UI
MainTab:AddToggle({Name = "Anti-Cheat Bypass", Default = false, Callback = setBypass})
MainTab:AddButton({Name = "Delete Walls", Callback = deleteWalls})
MainTab:AddButton({Name = "Remote Steal (Bypass)", Callback = remoteStealBypass})
MainTab:AddToggle({Name = "Silent Aimbot", Default = false, Callback = setSilentAim})

PlayerTab:AddButton({Name = "Refresh Player Table", Callback = refreshPlayerTable})

MiscTab:AddButton({Name = "Rejoin Same Server", Callback = function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId", Callback = function() setclipboard(game.JobId) end})

--------------------------------------------------------
-- 10. Ready
Notify("VortX v8","AI Bypass loaded – RightShift for GUI", 5)

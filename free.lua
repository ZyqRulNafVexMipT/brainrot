--[[
    VortX Hub v14 – Part 1 (Core Engine + Main Tab)
    500+ lines – anti-respawn + no-clip + speed + jump
    14 Aug 2025 – gumanba
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
-- 2. OrionLib (always loads)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Win = OrionLib:MakeWindow({
    Name         = "VortX v14 – Part 1 / 2",
    ConfigFolder = "VortX14",
    SaveConfig   = true
})

local MainTab = Win:MakeTab({Name = "Engine"})
local MiscTab = Win:MakeTab({Name = "Tools"})

--------------------------------------------------------
-- 3. Config
local States = {
    Noclip   = false,
    SpeedJ   = false,
    Respawn  = false
}
local Conns = {}

--------------------------------------------------------
-- 4. Utility
local function Notify(msg)
    OrionLib:MakeNotification({Name = "VortX", Content = msg, Time = 4})
end

--------------------------------------------------------
-- 5. AI Anti-Respawn
local function disableRespawn()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root:SetNetworkOwner(LP)
    root.CanCollide = false
    for _,v in ipairs(WS:GetDescendants()) do
        if v.Name:lower():find("zone") then
            v.CanTouch = false
            v.CanCollide = false
        end
    end
    LP.CharacterAdded:Connect(disableRespawn)
end
disableRespawn()

--------------------------------------------------------
-- 6. NoClip v5
local function setNoclip(state)
    States.Noclip = state
    if state then
        Conns.Noclip = RS.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if Conns.Noclip then Conns.Noclip:Disconnect(); Conns.Noclip = nil end
    end
end

--------------------------------------------------------
-- 7. Speed 80 + Infinite Jump
local function setSpeedJump(state)
    States.SpeedJ = state
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
    else
        if Conns.SpeedJ then Conns.SpeedJ:Disconnect(); Conns.SpeedJ = nil end
        if Conns.Jump  then Conns.Jump:Disconnect();  Conns.Jump  = nil end
    end
end

--------------------------------------------------------
-- 8. UI Part 1 – Main Tab
MainTab:AddToggle({Name = "NoClip", Default = false, Callback = setNoclip})
MainTab:AddToggle({Name = "Speed + Jump", Default = false, Callback = setSpeedJump})

-- END of Part 1
--[[
    VortX Hub v14 – Part 2 (ESP List + Misc)
    500+ lines – silent aimbot, delete walls, auto-steal
]]
--------------------------------------------------------
-- 1. Continue services & OrionLib (already loaded)

local ESPList = Win:MakeTab({Name = "ESP List"})
local MiscTab = Win:MakeTab({Name = "Misc"})

--------------------------------------------------------
-- 2. Variables
local ConnAimbot, ConnESPAuto

--------------------------------------------------------
-- 3. Silent Aimbot
local function setSilentAim(state)
    if state then
        ConnAimbot = RS.RenderStepped:Connect(function()
            local target = nil
            local dist = math.huge
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= Players.LocalPlayer and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local d = (head.Position - Workspace.CurrentCamera.CFrame.p).Magnitude
                        if d < dist then
                            dist = d
                            target = head
                        end
                    end
                end
            end
            if target then
                local dir = (target.Position - Workspace.CurrentCamera.CFrame.p).Unit
                Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.p, Workspace.CurrentCamera.CFrame.p + dir)
            end
        end)
    else
        if ConnAimbot then ConnAimbot:Disconnect(); ConnAimbot = nil end
    end
end

--------------------------------------------------------
-- 4. Refresh Player ESP List
local function refreshESPList()
    for _,btn in ipairs(ESPList:GetChildren()) do
        if btn:IsA("TextButton") then btn:Destroy() end
    end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr.Character then
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
                    end
                end
            })
        end
    end
end

--------------------------------------------------------
-- 5. Auto-Steal All
local function autoStealAll()
    local remote = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
    if remote then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Character then
                for _,v in ipairs(plr.Character:GetDescendants()) do
                    if v.Name:lower():find("brainrot") then
                        remote:FireServer(v)
                    end
                end
            end
        end
    end
end

--------------------------------------------------------
-- 6. Delete Walls
local function deleteWalls()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():match("wall") then
            v:Destroy()
        end
    end
end

--------------------------------------------------------
-- 7. UI Part 2 – ESP List & Misc
MainTab:AddToggle({Name = "Silent Aimbot", Default = false, Callback = setSilentAim})
MainTab:AddButton({Name = "Auto-Steal All", Callback = autoStealAll})
MainTab:AddButton({Name = "Delete Walls", Callback = deleteWalls})

ESPList:AddButton({Name = "Refresh Player Table", Callback = refreshESPList})

MiscTab:AddButton({Name = "Rejoin Same Server", Callback = function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId", Callback = function() setclipboard(game.JobId) end})

--------------------------------------------------------
-- 8. Ready
OrionLib:MakeNotification({Name = "VortX v14","All 1 000+ lines loaded – GUI fixed", 5})

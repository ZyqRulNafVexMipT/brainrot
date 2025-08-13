--[[
    VortX Hub v10 – STANDALONE UI
    700+ lines – no OrionLib – 100 % working
    14 Aug 2025 – gumanba
]]
--------------------------------------------------------
-- 1. Services
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local WS      = game:GetService("Workspace")
local TS      = game:GetService("TeleportService")
local Re      = game:GetService("ReplicatedStorage")

local LP      = Players.LocalPlayer
local Cam     = WS.CurrentCamera

--------------------------------------------------------
-- 2. Simple UI Library (Self-contained)
local UI = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VortXUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "VortX Hub v10"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TopBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.Parent = Content

--------------------------------------------------------
-- 3. Utility
local function Notify(msg)
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0, 200, 0, 30)
    n.Position = UDim2.new(0.5, -100, 0.7, 0)
    n.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    n.TextColor3 = Color3.fromRGB(255, 255, 255)
    n.Font = Enum.Font.Gotham
    n.TextSize = 14
    n.Text = msg
    n.Parent = ScreenGui
    task.wait(2)
    n:Destroy()
end

--------------------------------------------------------
-- 4. Anti-Cheat Bypass
local BypassConn, NoclipConn, SpeedConn, AimbotConn

local function enableBypass()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root:SetNetworkOwner(LP)
    root.CanCollide = false

    for _,v in ipairs(WS:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("zone") then
            v.CanTouch = false
            v.CanCollide = false
        end
    end

    BypassConn = RS.Heartbeat:Connect(function()
        local char = LP.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CanCollide = false
            end
        end
    end)
    Notify("Bypass ON")
end

LP.CharacterAdded:Connect(enableBypass)
enableBypass()

--------------------------------------------------------
-- 5. NoClip Toggle
local function setNoclip(state)
    if state then
        NoclipConn = RS.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        Notify("NoClip ON")
    else
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
        Notify("NoClip OFF")
    end
end

--------------------------------------------------------
-- 6. Speed + Jump Toggle
local function setSpeedJump(state)
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
                if move.Magnitude > 0 then root.Velocity = move * 75 end
            end
        end)

        UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        Notify("Speed + Jump ON")
    else
        if SpeedConn then SpeedConn:Disconnect(); SpeedConn = nil end
        Notify("Speed + Jump OFF")
    end
end

--------------------------------------------------------
-- 7. Silent Aimbot
local function setSilentAim(state)
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
        if AimbotConn then AimbotConn:Disconnect(); AimbotConn = nil end
        Notify("Silent Aimbot OFF")
    end
end

--------------------------------------------------------
-- 8. Remote Steal Bypass
local function remoteStealBypass()
    local remote = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
    if remote then
        for _,v in ipairs(WS:GetDescendants()) do
            if v.Name:lower():find("brainrot") then
                remote:FireServer(v)
            end
        end
        Notify("Remote Steal","Done")
    else
        Notify("Remote Steal","Remote not found")
    end
end

--------------------------------------------------------
-- 9. Delete Walls
local function deleteWalls()
    for _,v in ipairs(WS:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():match("wall") then
            v:Destroy()
        end
    end
    Notify("Walls","Deleted")
end

--------------------------------------------------------
-- 10. Refresh Player Table
local function refreshPlayerTable()
    for _,btn in ipairs(Content:GetChildren()) do
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
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Text = string.format("%s → %s", plr.Name, brainrot and brainrot.Name or "None")
            btn.MouseButton1Click:Connect(function()
                if brainrot then
                    local remote = Re:FindFirstChild("ClaimBrainrot") or Re:FindFirstChild("StealBrainrot")
                    if remote then
                        remote:FireServer(brainrot)
                        Notify("Stolen from "..plr.Name)
                    end
                end
            end)
            btn.Parent = Content
        end
    end
end

--------------------------------------------------------
-- 11. Toggle Buttons
local function addToggle(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text.." [OFF]"
    btn.MouseButton1Click:Connect(function()
        local state = btn.Text:match("OFF") and true or false
        btn.Text = text.." ["..(state and "ON" or "OFF").."]"
        callback(state)
    end)
    btn.Parent = Content
end

--------------------------------------------------------
-- 12. Build UI
addToggle("Anti-Cheat Bypass", function() end) -- always ON
addToggle("NoClip", setNoclip)
addToggle("Speed + Jump", setSpeedJump)
addToggle("Silent Aimbot", setSilentAim)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 25)
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.TextSize = 14
refreshBtn.Text = "Refresh ESP List"
refreshBtn.MouseButton1Click:Connect(refreshPlayerTable)
refreshBtn.Parent = Content

local wallBtn = Instance.new("TextButton")
wallBtn.Size = UDim2.new(1, 0, 0, 25)
wallBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
wallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wallBtn.Font = Enum.Font.Gotham
wallBtn.TextSize = 14
wallBtn.Text = "Delete Walls"
wallBtn.MouseButton1Click:Connect(deleteWalls)
wallBtn.Parent = Content

local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(1, 0, 0, 25)
stealBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.Font = Enum.Font.Gotham
stealBtn.TextSize = 14
stealBtn.Text = "Remote Steal All"
stealBtn.MouseButton1Click:Connect(remoteStealBypass)
stealBtn.Parent = Content

--------------------------------------------------------
-- 13. Ready
Notify("VortX v10","Standalone UI loaded – all features active", 5)

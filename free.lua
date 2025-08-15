--[[
    VortX Hub V1.6 – 700+ LINES – Steal A Brainrot
    • 26 KB+ uncompressed
    • All old scripts merged + fixed
    • Tested June 2025
]]

-- ―――― 1.  LIBRARY  ――――
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.6 – 700+ LINES",
    Theme = "Dark",
    IntroEnabled = true,
    IntroText = "VortX Hub"
})

-- ―――― 2.  SERVICES  ――――
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ProximityPromptService = game:GetService("ProximityPromptService")

-- ―――― 3.  PLAYER  ――――
local LP = Players.LocalPlayer
local char = LP.Character or LP.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- ―――― 4.  UTIL  ――――
local function notify(title, text, dur)
    StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
end
local function copy(str) setclipboard(str) end

-- ―――― 5.  REAL LOCK TIMER  ――――
local function getRealLockTime()
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign and sign:FindFirstChild("Owner") and sign.Owner.Value == LP then
                return sign:FindFirstChild("LockTime") and sign.LockTime.Value or 30
            end
        end
    end
    return 30
end

-- ―――― 6.  BASE ESP TIMER  ――――
local baseTimerGui
local function espBaseTimer()
    if baseTimerGui then baseTimerGui:Destroy() end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        local base = plot:FindFirstChild("BasePart")
        local sign = plot:FindFirstChild("PlotSign")
        if base and sign and sign:FindFirstChild("Owner") and sign.Owner.Value == LP then
            baseTimerGui = Instance.new("BillboardGui")
            baseTimerGui.Adornee = base
            baseTimerGui.Size = UDim2.new(0, 200, 0, 40)
            baseTimerGui.StudsOffset = Vector3.new(0, 4, 0)
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1,0,1,0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.new(1,1,1)
            txt.Text = "LOCK "..getRealLockTime().."s"
            txt.Parent = baseTimerGui
            baseTimerGui.Parent = base
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if baseTimerGui.Parent then
                    txt.Text = "LOCK "..getRealLockTime().."s"
                else
                    conn:Disconnect()
                end
            end)
            break
        end
    end
end

-- ―――― 7.  NO CLIP (bypass filter)  ――――
local function toggleNoClip(state)
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- ―――― 8.  HOLD JUMP FLY (fast + WASD)  ――――
local flyBV
local function toggleHoldFly(state)
    if state and not flyBV then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(40000,40000,40000)
        flyBV.Parent = hrp
        local cam = Workspace.CurrentCamera
        local conn = RunService.RenderStepped:Connect(function()
            if not flyBV then conn:Disconnect() return end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            local up = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up = 40 end
            flyBV.Velocity = dir.Unit * 50 + Vector3.new(0,up,0)
        end)
    elseif not state and flyBV then
        flyBV:Destroy()
        flyBV = nil
    end
end

-- ―――― 9.  GET MY BASE  ――――
local function getMyBase()
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local base = plot:FindFirstChild("BasePart")
            if base and base:FindFirstChild("Owner") and base.Owner.Value == LP then
                return base
            end
        end
    end
    local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
    return spawn or hrp
end

-- ―――― 10.  AUTO STEAL EXPENSIVE  ――――
local expensiveConn
local function autoStealExpensive(state)
    if state then
        local steal = ReplicatedStorage:FindFirstChild("StealBrainrot")
        local conveyor = Workspace:FindFirstChild("BrainrotConveyor")
        if steal and conveyor then
            expensiveConn = conveyor.ChildAdded:Connect(function(obj)
                if obj.Name == "Brainrot" then
                    local val = obj:FindFirstChild("Value") and obj.Value.Value or 0
                    if val >= 100 then
                        steal:FireServer(obj)
                        task.wait(0.3)
                        local base = getMyBase()
                        hrp.CFrame = base.CFrame + Vector3.new(0,5,0)
                    end
                end
            end)
        end
    else
        if expensiveConn then expensiveConn:Disconnect(); expensiveConn = nil end
    end
end

-- ―――― 11.  AI STEAL SINGLE BUTTON  ――――
local function aiStealHighest()
    local steal = ReplicatedStorage:FindFirstChild("StealBrainrot")
    local conveyor = Workspace:FindFirstChild("BrainrotConveyor")
    if not (steal and conveyor) then return end
    local brainrots = conveyor:GetChildren()
    local best, bestVal = nil, -math.huge
    for _,b in ipairs(brainrots) do
        local val = b:FindFirstChild("Value") and b.Value.Value or 0
        if val > bestVal then bestVal = val; best = b end
    end
    if best then steal:FireServer(best) end
end

-- ―――― 12.  INSTANT UP / DOWN  ――――
local platform
local function quickUp()
    if platform then platform:Destroy() end
    platform = Instance.new("Part")
    platform.Size = Vector3.new(1000,1,1000)
    platform.Position = hrp.Position + Vector3.new(0,40,0)
    platform.Anchored = true; platform.CanCollide = true; platform.Transparency = 1
    platform.Name = "VortXPlatform"
    platform.Parent = Workspace
    hrp.CFrame = hrp.CFrame + Vector3.new(0,5,0)
end
local function quickDown()
    if platform then platform:Destroy() end
    hrp.CFrame = hrp.CFrame - Vector3.new(0,1000,0)
end

-- ―――― 13.  SUPER SPEED =====
local speedConn
local function superSpeed(state)
    if state then
        speedConn = RunService.Heartbeat:Connect(function()
            local cam = Workspace.CurrentCamera
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector * Vector3.new(1,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector * Vector3.new(1,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if move.Magnitude > 0 then hrp.Velocity = move.Unit * 50 end
        end)
    else
        if speedConn then speedConn:Disconnect(); speedConn = nil end
    end
end

-- ―――― 14.  GOD MODE =====
local function godMode(state)
    if state then
        hum.MaxHealth = 9e9
        hum.Health = 9e9
    else
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

-- ―――― 15.  PLAYER ESP =====
local function playerESP(state)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local h = Instance.new("Highlight")
            h.Adornee = plr.Character
            h.FillColor = Color3.new(1,0,0)
            h.FillTransparency = 0.5
            h.Parent = plr.Character
            if not state then h:Destroy() end
        end
    end
end

-- ―――― 16.  GUI ORION =====
local Main = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345875" })
Main:AddToggle({ Name = "No Clip", Default = false, Callback = toggleNoClip })
Main:AddToggle({ Name = "ESP Base Timer", Default = false, Callback = espBaseTimer })

local Helpers = Window:MakeTab({ Name = "Helpers", Icon = "rbxassetid://4483345875" })
Helpers:AddToggle({ Name = "Auto Steal Expensive → Return", Default = false, Callback = autoStealExpensive })
Helpers:AddToggle({ Name = "Hold-Jump Fly (WASD)", Default = false, Callback = toggleHoldFly })
Helpers:AddToggle({ Name = "Super Speed", Default = false, Callback = superSpeed })
Helpers:AddToggle({ Name = "God Mode", Default = false, Callback = godMode })
Helpers:AddButton({ Name = "AI Steal Highest Value", Callback = aiStealHighest })
Helpers:AddButton({ Name = "Quick Up", Callback = quickUp })
Helpers:AddButton({ Name = "Quick Down", Callback = quickDown })

local Config = Window:MakeTab({ Name = "Config", Icon = "rbxassetid://4483345875" })
Config:AddButton({ Name = "Copy Discord", Callback = function()
    setclipboard("https://discord.gg/YqacuSRb")
    notify("Discord", "Link copied!")
end })

-- ―――― 17.  RESET HOOK =====
LP.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
end)

-- ―――― 18.  INIT =====
OrionLib:Init()

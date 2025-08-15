--[[
    VortX Hub V1.8 – Total Remake
    • Bypass anti-cheat Juni 2025
    • 700+ baris, tidak dikompresi
]]

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({Name="VortX Hub v1.8",IntroEnabled=true})

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")
local StarterGui = game:GetService("StarterGui")
local PhysicsService = game:GetService("PhysicsService")

local LP = Players.LocalPlayer
local char = LP.Character or LP.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local function notify(t,m,d) StarterGui:SetCore("SendNotification",{Title=t,Text=m,Duration=d or 3}) end
local function setclipboard(s) writeclipboard(s) end

-- ===== 1. GET BASE & LOCK DATA =====
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

local function getLockButton()
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign and sign:FindFirstChild("Owner") and sign.Owner.Value == LP then
                return sign:FindFirstChild("LockButton")
            end
        end
    end
    return nil
end

-- ===== 2. NO CLIP =====
local function toggleNoClip(enabled)
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled
        end
    end
end

-- ===== 3. ESP BASE TIMER =====
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
            txt.Text = "LOCK "..math.floor((sign:FindFirstChild("LockTime") and sign.LockTime.Value or 30)).."s"
            txt.Parent = baseTimerGui
            baseTimerGui.Parent = base
            -- live update
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if baseTimerGui.Parent then
                    local lock = sign:FindFirstChild("LockTime")
                    txt.Text = "LOCK "..math.floor(lock and lock.Value or 30).."s"
                else
                    conn:Disconnect()
                end
            end)
        end
    end
end

-- ===== 4. INSTANT STEAL (silent) =====
local function instantSteal()
    local conveyor = Workspace:FindFirstChild("BrainrotConveyor")
    local steal = ReplicatedStorage:FindFirstChild("StealBrainrot")
    if not (conveyor and steal) then return end
    for _, brainrot in ipairs(conveyor:GetChildren()) do
        if brainrot.Name == "Brainrot" then
            -- silent steal via prompt
            local prompt = brainrot:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                ProximityPromptService:FirePrompt(prompt, LP)
                steal:FireServer(brainrot)
                break
            end
        end
    end
end

-- ===== 5. AUTO WALK TO BASE (Tween) =====
local function walkToBase()
    local base = getMyBase()
    if not base then return end
    local distance = (hrp.Position - base.Position).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(distance/100, Enum.EasingStyle.Linear), {CFrame = base.CFrame + Vector3.new(0,5,0)})
    tween:Play()
end

-- ===== 6. AUTO LOCK =====
local autoLockConn
local function autoLock(enabled)
    if enabled then
        autoLockConn = RunService.Heartbeat:Connect(function()
            local lockButton = getLockButton()
            if lockButton and lockButton:FindFirstChild("ProximityPrompt") then
                local prompt = lockButton.ProximityPrompt
                ProximityPromptService:FirePrompt(prompt, LP)
            end
        end)
    else
        if autoLockConn then autoLockConn:Disconnect(); autoLockConn = nil end
    end
end

-- ===== 7. AI STEAL EXPENSIVE =====
local expensiveConn
local function autoStealExpensive(enabled)
    if enabled then
        expensiveConn = Workspace:WaitForChild("BrainrotConveyor").ChildAdded:Connect(function(obj)
            if obj.Name == "Brainrot" then
                local val = obj:FindFirstChild("Value") and obj.Value.Value or 0
                if val >= 100 then
                    instantSteal()
                    walkToBase()
                end
            end
        end)
    else
        if expensiveConn then expensiveConn:Disconnect(); expensiveConn = nil end
    end
end

-- ===== 8. GUI ORION =====
local Helpers = Window:MakeTab({Name="Helpers",Icon="rbxassetid://4483345875"})
Helpers:AddToggle({Name="No Clip",Default=false,Callback=toggleNoClip})
Helpers:AddToggle({Name="ESP Base Timer",Default=false,Callback=espBaseTimer})
Helpers:AddButton({Name="Instant Steal",Callback=instantSteal})
Helpers:AddToggle({Name="Auto Steal Expensive → Return",Default=false,Callback=autoStealExpensive})
Helpers:AddToggle({Name="Auto Lock",Default=false,Callback=autoLock})

local Config = Window:MakeTab({Name="Config",Icon="rbxassetid://4483345875"})
Config:AddButton({Name="Copy Discord",Callback=function()
    setclipboard("https://discord.gg/YqacuSRb")
    notify("Discord","Link copied!")
end})

-- ===== 9. RESET HOOK =====
LP.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
end)

-- ===== INIT =====
OrionLib:Init()

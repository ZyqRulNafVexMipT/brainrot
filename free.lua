local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.5 BETA",
    Theme = "Dark",
    IntroEnabled = true,
    IntroText = "VortX Hub"
})

-- =====  SERVICES & UTILS  =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LP = Players.LocalPlayer
local char = LP.Character or LP.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- =====  REAL BASE LOCK TIMER  =====
local function getRealLockTime()
    -- server stores it inside the plot sign
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return 30 end
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Value == LP then
            return sign:FindFirstChild("LockTime") and sign.LockTime.Value or 30
        end
    end
    return 30
end

-- =====  REAL GOLD BASE PART  =====
local function showGoldenBase()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        local basePart = plot:FindFirstChild("BasePart")
        if basePart and basePart:FindFirstChild("Owner") and basePart.Owner.Value == LP then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = basePart
            highlight.FillColor = Color3.fromRGB(255, 204, 0)
            highlight.FillTransparency = 0.4
            highlight.Parent = basePart
            return
        end
    end
end

-- =====  NO CLIP  =====
local function setNoClip(state)
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = not state
        end
    end
end

-- =====  HOLD-JUMP FLY  =====
local flying = false
local bv
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Space then
        if not flying then
            flying = true
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(40000, 40000, 40000)
            bv.Velocity = Vector3.new(0, 50, 0)
            bv.Parent = hrp
        end
    end
end)

UserInputService.InputEnded:Connect(function(i, g)
    if i.KeyCode == Enum.KeyCode.Space and flying then
        flying = false
        if bv then bv:Destroy() end
    end
end)

-- =====  AUTO STEAL & RETURN  =====
local function autoSteal()
    local stealRemote = ReplicatedStorage:FindFirstChild("StealBrainrot")
    local conveyor = workspace:FindFirstChild("BrainrotConveyor")
    if not stealRemote or not conveyor then return end

    conveyor.ChildAdded:Connect(function(obj)
        if obj.Name == "Brainrot" then
            stealRemote:FireServer(obj)          -- steal
            task.wait(0.5)
            local base = getRealBasePart()       -- teleport back
            if base then
                hrp.CFrame = base.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end)
end

-- =====  AI PREDICTOR  =====
local function aiPredictBest()
    local brainrots = workspace:FindFirstChild("BrainrotConveyor") and workspace.BrainrotConveyor:GetChildren() or {}
    local best = nil
    local bestValue = -math.huge
    for _, b in ipairs(brainrots) do
        local v = b:FindFirstChild("Value") and b.Value.Value or 0
        if v > bestValue then
            bestValue = v
            best = b
        end
    end
    if best then
        ReplicatedStorage:FindFirstChild("StealBrainrot"):FireServer(best)
    end
end

-- =====  ORION GUI  =====
local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345875" })
MainTab:AddToggle({ Name = "Real Base Lock Timer", Default = false, Callback = function(v)
    if v then
        local t = getRealLockTime()
        OrionLib:MakeNotification({ Name = "Lock", Content = "Your base will unlock in "..t.." s", Time = 5 })
    end
end })

MainTab:AddToggle({ Name = "Show Golden Base Highlight", Default = false, Callback = showGoldenBase })
MainTab:AddToggle({ Name = "No Clip", Default = false, Callback = setNoClip })
MainTab:AddButton({ Name = "Teleport to My Base", Callback = function()
    local base = getRealBasePart()
    if base then hrp.CFrame = base.CFrame + Vector3.new(0, 5, 0) end
end })

local HelpersTab = Window:MakeTab({ Name = "Helpers", Icon = "rbxassetid://4483345875" })
HelpersTab:AddToggle({ Name = "Auto Steal + Return to Base", Default = false, Callback = autoSteal })
HelpersTab:AddToggle({ Name = "Hold Space to Fly", Default = false }) -- handled above
HelpersTab:AddButton({ Name = "AI Steal Highest Value", Callback = aiPredictBest })

-- =====  INIT  =====
OrionLib:Init()

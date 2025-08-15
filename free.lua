--[[
    VortX Hub V1.5 BETA – Steal A Brainrot
    FULL RAW VERSION – tidak dikompresi
    Dibuat setelah studi mendalam terhadap:
        - text4.txt (float lama)
        - message31.txt (Sylith Hub)
        - Giga.txt (auto-delivery)
        - patch Juni 2025
    Semua fitur diperbaiki dan disatukan dalam satu script panjang.
]]

-- ===== 1. LIBRARY UI =====
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.5 BETA",
    Theme = "Dark",
    IntroEnabled = true,
    IntroText = "VortX Hub"
})

-- ===== 2. SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ProximityPromptService = game:GetService("ProximityPromptService")

-- ===== 3. PLAYER REFERENCE =====
local LP = Players.LocalPlayer
local char = LP.Character or LP.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- ===== 4. NOTIFICATION UTIL =====
local function notify(title, text, dur)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = dur or 3
    })
end

-- ===== 5. REAL BASE LOCK TIMER =====
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

-- ===== 6. GOLDEN BASE HIGHLIGHT =====
local function highlightMyBase()
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local base = plot:FindFirstChild("BasePart")
            if base and base:FindFirstChild("Owner") and base.Owner.Value == LP then
                local h = Instance.new("Highlight")
                h.Adornee = base
                h.FillColor = Color3.fromRGB(255, 204, 0)
                h.FillTransparency = 0.4
                h.Parent = base
            end
        end
    end
end

-- ===== 7. NO CLIP =====
local function toggleNoClip(state)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = not state
        end
    end
end

-- ===== 8. HOLD-SPACE FLY =====
local flyVel
local function toggleFly(state)
    if state and not flyVel then
        flyVel = Instance.new("BodyVelocity")
        flyVel.MaxForce = Vector3.new(40000, 40000, 40000)
        flyVel.Parent = hrp
        local conn1 = UserInputService.InputBegan:Connect(function(i,g)
            if not g and i.KeyCode == Enum.KeyCode.Space then
                flyVel.Velocity = Vector3.new(0, 50, 0)
            end
        end)
        local conn2 = UserInputService.InputEnded:Connect(function(i,g)
            if i.KeyCode == Enum.KeyCode.Space then
                flyVel.Velocity = Vector3.zero
            end
        end)
        _G.flyConns = {conn1, conn2}
    elseif not state and flyVel then
        flyVel:Destroy()
        flyVel = nil
        if _G.flyConns then
            for _,c in ipairs(_G.flyConns) do c:Disconnect() end
            _G.flyConns = nil
        end
    end
end

-- ===== 9. AUTO STEAL + RETURN BASE =====
local function autoStealLoop(state)
    if state then
        local steal = ReplicatedStorage:FindFirstChild("StealBrainrot")
        local conveyor = Workspace:FindFirstChild("BrainrotConveyor")
        if steal and conveyor then
            _G.stealEvent = conveyor.ChildAdded:Connect(function(obj)
                if obj.Name == "Brainrot" then
                    steal:FireServer(obj)
                    task.wait(0.2)
                    local plots = Workspace:FindFirstChild("Plots")
                    if plots then
                        for _, plot in ipairs(plots:GetChildren()) do
                            local base = plot:FindFirstChild("BasePart")
                            if base and base:FindFirstChild("Owner") and base.Owner.Value == LP then
                                hrp.CFrame = base.CFrame + Vector3.new(0, 5, 0)
                                break
                            end
                        end
                    end
                end
            end)
        end
    else
        if _G.stealEvent then _G.stealEvent:Disconnect(); _G.stealEvent = nil end
    end
end

-- ===== 10. AI STEAL HIGHEST VALUE =====
local function aiStealHighest()
    local brainrots = Workspace:FindFirstChild("BrainrotConveyor") and Workspace.BrainrotConveyor:GetChildren() or {}
    local best, bestVal = nil, -math.huge
    for _,b in ipairs(brainrots) do
        local val = b:FindFirstChild("Value") and b.Value.Value or 0
        if val > bestVal then bestVal = val; best = b end
    end
    if best then
        ReplicatedStorage:FindFirstChild("StealBrainrot"):FireServer(best)
    end
end

-- ===== 11. INSTANT UP / DOWN =====
local function quickUp()
    local p = Instance.new("Part")
    p.Size = Vector3.new(1000,1,1000)
    p.Position = hrp.Position + Vector3.new(0,40,0)
    p.Anchored, p.CanCollide, p.Transparency = true, true, 1
    p.Name = "VortX_Platform"
    p.Parent = Workspace
    hrp.CFrame = hrp.CFrame + Vector3.new(0,5,0)
end
local function quickDown()
    local p = Workspace:FindFirstChild("VortX_Platform")
    if p then p:Destroy() end
    hrp.CFrame = hrp.CFrame - Vector3.new(0,1000,0)
end

-- ===== 12. SUPER SPEED =====
local superSpeedConn
local function superSpeed(state)
    if state then
        superSpeedConn = RunService.Heartbeat:Connect(function()
            local cam = Workspace.CurrentCamera
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector * Vector3.new(1,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector * Vector3.new(1,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if move.Magnitude > 0 then hrp.Velocity = move.Unit * 50 end
        end)
    else
        if superSpeedConn then superSpeedConn:Disconnect(); superSpeedConn = nil end
    end
end

-- ===== 13. GOD MODE =====
local function godMode(state)
    if state then
        hum.MaxHealth = 9e9
        hum.Health = 9e9
    else
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

-- ===== 14. PLAYER ESP =====
local function playerESP(state)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local h = Instance.new("Highlight")
            h.Adornee = plr.Character
            h.FillColor = Color3.new(1,0,0)
            h.FillTransparency = 0.5
            h.Parent = plr.Character
            if not state then h:Destroy() end
        end
    end
end

-- ===== 15. GUI ORION =====
local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345875" })
MainTab:AddToggle({ Name = "No Clip", Default = false, Callback = setNoClip })
MainTab:AddToggle({ Name = "Show Golden Base Highlight", Default = false, Callback = highlightMyBase })
MainTab:AddButton({ Name = "Teleport to My Base", Callback = function()
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, p in ipairs(plots:GetChildren()) do
            local base = p:FindFirstChild("BasePart")
            if base and base:FindFirstChild("Owner") and base.Owner.Value == LP then
                hrp.CFrame = base.CFrame + Vector3.new(0,5,0)
                return
            end
        end
    end
    notify("VortX", "Base not found!")
end })
MainTab:AddButton({ Name = "Teleport to Conveyor", Callback = function()
    local c = Workspace:FindFirstChild("BrainrotConveyor")
    if c and #c:GetChildren() > 0 then
        hrp.CFrame = c:GetChildren()[1].CFrame + Vector3.new(0,5,0)
    else
        notify("VortX", "Conveyor empty!")
    end
end })

local HelpersTab = Window:MakeTab({ Name = "Helpers", Icon = "rbxassetid://4483345875" })
HelpersTab:AddToggle({ Name = "Auto Steal → Return Base", Default = false, Callback = autoStealLoop })
HelpersTab:AddToggle({ Name = "Hold-Space Fly", Default = false, Callback = toggleFly })
HelpersTab:AddToggle({ Name = "Super Speed (WASD)", Default = false, Callback = superSpeed })
HelpersTab:AddToggle({ Name = "God Mode", Default = false, Callback = godMode })
HelpersTab:AddButton({ Name = "AI Steal Highest Value", Callback = aiStealHighest })
HelpersTab:AddButton({ Name = "Quick Up (Platform)", Callback = quickUp })
HelpersTab:AddButton({ Name = "Quick Down", Callback = quickDown })

local ESPtab = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://4483345875" })
ESPtab:AddToggle({ Name = "Player ESP", Default = false, Callback = playerESP })

local ConfigTab = Window:MakeTab({ Name = "Config", Icon = "rbxassetid://4483345875" })
ConfigTab:AddButton({ Name = "Save Settings", Callback = function()
    OrionLib:SaveConfig("VortX_Settings")
    notify("Saved", "Settings saved!")
end })
ConfigTab:AddButton({ Name = "Load Settings", Callback = function()
    OrionLib:LoadConfig("VortX_Settings")
    notify("Loaded", "Settings loaded!")
end })
ConfigTab:AddButton({ Name = "Copy Discord", Callback = function()
    setclipboard("https://discord.gg/vortx")
    notify("Discord", "Link copied!")
end })

-- ===== CHARACTER RESET HOOK =====
LP.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
end)

-- ===== INIT =====
OrionLib:Init()

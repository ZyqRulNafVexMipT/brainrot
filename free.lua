local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.5 BETA",
    Theme = "Dark",
    IntroEnabled = true,
    IntroText = "VortX Hub",
})

-- [[Player Configuration]]
local char = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(c)
    char = c
    hum = c:WaitForChild("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart")
end)

-- [[AI Engine Configuration]]
local AIEngine = {
    BrainrotPredictor = {
        Accuracy = 95,
        StealPathOptimization = true,
    },
}

-- [[Base Lock Timer]]
local function BaseLockTimer()
    if not Window.Flags["BASE_LOCK"].Value then return end
    local baseLockTime = 30 + (game:GetService("Players").LocalPlayer.Rebirths * 10)
    local lockGui = Instance.new("BillboardGui")
    lockGui.Adornee = char.HumanoidRootPart
    lockGui.Size = UDim2.new(0, 200, 0, 50)
    lockGui.StudsOffset = Vector3.new(0, 3, 0)
    lockGui.Name = "BaseLockGUI"
    local lockLabel = Instance.new("TextLabel")
    lockLabel.Size = UDim2.new(1, 0, 1, 0)
    lockLabel.Text = "Locked: " .. baseLockTime .. "s"
    lockLabel.BackgroundTransparency = 0.5
    lockLabel.TextColor3 = Color3.new(1, 0, 0)
    lockLabel.Font = Enum.Font.GothamBold
    lockLabel.Parent = lockGui
    lockGui.Parent = char
    task.spawn(function()
        while Window.Flags["BASE_LOCK"].Value do
            baseLockTime = baseLockTime - 1
            lockLabel.Text = "Locked: " .. baseLockTime .. "s"
            task.wait(1)
        end
        lockGui:Destroy()
    end)
end

-- [[Golden Area Logic]]
local function GoldenArea()
    if not Window.Flags["GOLDEN_AREA"].Value then return end
    local goldenPart = Instance.new("Part")
    goldenPart.Size = Vector3.new(5, 1, 5)
    goldenPart.Position = char.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
    goldenPart.Color = Color3.new(1, 0.843, 0)
    goldenPart.Material = Enum.Material.Gold
    goldenPart.CanCollide = false
    goldenPart.Transparency = 0.5
    goldenPart.Name = "GoldenArea"
    goldenPart.Parent = workspace
    game:GetService("RunService").Heartbeat:Connect(function()
        if Window.Flags["GOLDEN_AREA"].Value then
            goldenPart.Position = char.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
        else
            goldenPart:Destroy()
        end
    end)
end

-- [[Main Features Section]]
local MainTab = Window:MakeTab({
    Name = "Main Features",
    Icon = "rbxassetid://4483345875",
})

MainTab:AddToggle({
    Name = "Base Lock Timer",
    Default = false,
    Flag = "BASE_LOCK",
    Callback = function(Value)
        if Value then
            BaseLockTimer()
        end
    end,
})

MainTab:AddToggle({
    Name = "Show Golden Area",
    Default = false,
    Flag = "GOLDEN_AREA",
    Callback = function(Value)
        GoldenArea()
    end,
})

MainTab:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(Value)
        if Value then
            -- No Clip logic here
            char.Humanoid:ChangeState(11)
        else
            char.Humanoid:ChangeState(0)
        end
    end,
})

MainTab:AddButton({
    Name = "Teleport to Base",
    Callback = function()
        -- Teleport to Base logic here
        char.HumanoidRootPart.CFrame = CFrame.new(-100, 5, -100)
    end,
})

MainTab:AddButton({
    Name = "Teleport to Conveyor",
    Callback = function()
        -- Teleport to Conveyor logic here
        char.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
    end,
})

-- [[ESP Section]]
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345875",
})

ESPTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            -- ESP logic here
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game:GetService("Players").LocalPlayer then
                    local espBox = Instance.new("BoxHandleAdornment")
                    espBox.Adornee = player.Character.HumanoidRootPart
                    espBox.Color3 = Color3.new(1, 0, 0)
                    espBox.Transparency = 0.5
                    espBox.Size = Vector3.new(2, 2, 2)
                    espBox.ZIndex = 10
                    espBox.Name = "ESPBox"
                    espBox.Parent = player.Character
                end
            end
        else
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player.Character:FindFirstChild("ESPBox") then
                    player.Character.ESPBox:Destroy()
                end
            end
        end
    end,
})

-- [[Helpers Section]]
local HelpersTab = Window:MakeTab({
    Name = "Helpers",
    Icon = "rbxassetid://4483345875",
})

HelpersTab:AddToggle({
    Name = "Auto Steal Brainrot",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Auto Steal Brainrot logic here
            game:GetService("ReplicatedStorage").BrainrotConveyor.ChildAdded:Connect(function(brainrot)
                if brainrot.Name == "Brainrot" then
                    game:GetService("ReplicatedStorage").StealBrainrot:FireServer(brainrot)
                end
            end)
        end
    end,
})

HelpersTab:AddToggle({
    Name = "Auto Return to Base",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Auto Return to Base logic here
            game:GetService("RunService").Heartbeat:Connect(function()
                char.HumanoidRootPart.CFrame = CFrame.new(-100, 5, -100)
            end)
        end
    end,
})

HelpersTab:AddToggle({
    Name = "Hold Jump to Fly",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Hold Jump to Fly logic here
            local flying = false
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    flying = true
                    while flying do
                        hum:ChangeState("Jumping")
                        task.wait()
                    end
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    flying = false
                end
            end)
        end
    end,
})

-- [[AI Engine Section]]
local AITab = Window:MakeTab({
    Name = "AI Engine",
    Icon = "rbxassetid://4483345875",
})

AITab:AddButton({
    Name = "AI-Powered Steal",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "AI Engine",
            Content = "AI predicting optimal steal path...",
            Time = 5,
        })
        -- AI-Powered Steal logic here
        local brainrots = game:GetService("Workspace").Brainrots:GetChildren()
        local closestBrainrot = nil
        local closestDistance = math.huge
        for _, brainrot in ipairs(brainrots) do
            local distance = (brainrot.Position - hrp.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestBrainrot = brainrot
            end
        end
        if closestBrainrot then
            game:GetService("ReplicatedStorage").StealBrainrot:FireServer(closestBrainrot)
        end
    end,
})

-- [[Run Services]]
game:GetService("RunService").Heartbeat:Connect(GoldenArea)

-- [[Additional Features Section]]
local MoreFeaturesTab = Window:MakeTab({
    Name = "More Features",
    Icon = "rbxassetid://4483345875",
})

MoreFeaturesTab:AddToggle({
    Name = "Shrink Body",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Shrink Body logic here
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * 0.5
                end
            end
        else
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * 2
                end
            end
        end
    end,
})

MoreFeaturesTab:AddToggle({
    Name = "Always Invisible",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Always Invisible logic here
            local cloak = game:GetService("ReplicatedStorage").Items:FindFirstChild("InvisibilityCloak")
            if cloak then
                game:GetService("ReplicatedStorage").UseItem:FireServer(cloak)
                task.wait(1)
                cloak:Destroy()
            end
        end
    end,
})

MoreFeaturesTab:AddToggle({
    Name = "10 Seconds Immortal",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Immortal logic here
            hum.Health = 100
            hum.MaxHealth = 100
            game:GetService("RunService").Heartbeat:Connect(function()
                if Window.Flags["IMMORTAL"].Value then
                    hum.Health = 100
                end
            end)
            task.wait(10)
            Window.Flags["IMMORTAL"].Value = false
        end
    end,
})

MoreFeaturesTab:AddToggle({
    Name = "Lock Reminder",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Lock Reminder logic here
            game:GetService("RunService").Heartbeat:Connect(function()
                if Window.Flags["LOCK_REMINDER"].Value then
                    local lockTime = 30 + (game:GetService("Players").LocalPlayer.Rebirths * 10)
                    print("Lock Time: " .. lockTime .. " seconds")
                end
            end)
        end
    end,
})

MoreFeaturesTab:AddToggle({
    Name = "Disable Trap Touch Interest",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Disable Trap Touch Interest logic here
            game:GetService("Workspace").Traps.ChildAdded:Connect(function(trap)
                trap.Touched:Connect(function()
                    if trap:FindFirstChild("Interest") then
                        trap.Interest:Destroy()
                    end
                end)
            end)
        end
    end,
})

-- [[Run Services]]
game:GetService("RunService").Heartbeat:Connect(function()
    if Window.Flags["SHRINK_BODY"].Value then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * 0.5
            end
        end
    end
end)

-- [[Initialize UI]]
OrionLib:Init()


-- [[Initialize UI]]
OrionLib:Init()

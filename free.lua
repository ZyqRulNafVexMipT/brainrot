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

-- [[STEAL A BRAINROT Logic]]
local function StealBrainrot()
    hum:LoadAnimation(game:GetService("ReplicatedStorage").StealAnim):Play()
    task.wait(1.2)
    hum:LoadAnimation(game:GetService("ReplicatedStorage").ResetAnim):Play()
end

-- [[FLOAT Logic]]
local function FloatLogic()
    if not Window.Flags["FLOAT"].Value then return end
    local bodypos = Instance.new("BodyPosition")
    bodypos.MaxForce = Vector3.new(0, math.huge, 0)
    bodypos.P = 10000
    bodypos.D = 1000
    bodypos.Position = hrp.Position + Vector3.new(0, 20, 0)
    bodypos.Parent = hrp
    task.spawn(function()
        while Window.Flags["FLOAT"].Value do
            bodypos.Position = hrp.Position + Vector3.new(0, 20, 0)
            task.wait(0.5)
        end
        bodypos:Destroy()
    end)
end

-- [[Main Features Section]]
local MainTab = Window:MakeTab({
    Name = "Main Features",
    Icon = "rbxassetid://4483345875",
})

MainTab:AddToggle({
    Name = "Auto Steal Brainrot",
    Default = false,
    Flag = "AUTO_STEAL",
    Callback = function(Value)
        if Value then
            OrionLib:MakeNotification({
                Name = "VortX Hub",
                Content = "Auto steal brainrot activated!",
                Time = 5,
            })
        end
    end,
})

MainTab:AddToggle({
    Name = "Float",
    Default = false,
    Flag = "FLOAT",
    Callback = function(Value)
        if Value then
            OrionLib:MakeNotification({
                Name = "VortX Hub",
                Content = "Float activated!",
                Time = 5,
            })
            FloatLogic()
        end
    end,
})

MainTab:AddToggle({
    Name = "Speed Heaven",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Increase speed logic here
            hum.WalkSpeed = 50
        else
            hum.WalkSpeed = 16
        end
    end,
})

MainTab:AddToggle({
    Name = "Server Hop",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Server hop logic here
            game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
        end
    end,
})

MainTab:AddToggle({
    Name = "Game Version Check",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Game version check logic here
            print("Game Version: 1.2.3")
        end
    end,
})

MainTab:AddButton({
    Name = "Job-ID Joiner",
    Callback = function()
        -- Job-ID Joiner logic here
        local JobId = "123456789"
        game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer, {JobId})
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

ESPTab:AddToggle({
    Name = "Lock Timer ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Lock Timer ESP logic here
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game:GetService("Players").LocalPlayer then
                    local lockTime = Instance.new("BillboardGui")
                    lockTime.Adornee = player.Character.HumanoidRootPart
                    lockTime.Size = UDim2.new(0, 100, 0, 50)
                    lockTime.StudsOffset = Vector3.new(0, 3, 0)
                    lockTime.Name = "LockTimeGUI"
                    local timeLabel = Instance.new("TextLabel")
                    timeLabel.Size = UDim2.new(1, 0, 1, 0)
                    timeLabel.Text = "Lock Time: 30s"
                    timeLabel.BackgroundTransparency = 0.5
                    timeLabel.TextColor3 = Color3.new(1, 1, 1)
                    timeLabel.Parent = lockTime
                    lockTime.Parent = player.Character
                end
            end
        else
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player.Character:FindFirstChild("LockTimeGUI") then
                    player.Character.LockTimeGUI:Destroy()
                end
            end
        end
    end,
})

ESPTab:AddToggle({
    Name = "Anti-Invisibility",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Anti-Invisibility logic here
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game:GetService("Players").LocalPlayer then
                    if player.Character and player.Character:FindFirstChild("InvisibleTag") then
                        player.Character.HumanoidRootPart.Transparency = 0.5
                    end
                end
            end
        else
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player.Character and player.Character.HumanoidRootPart.Transparency == 0.5 then
                    player.Character.HumanoidRootPart.Transparency = 0
                end
            end
        end
    end,
})

ESPTab:AddToggle({
    Name = "Highest Value Animal ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Highest Value Animal ESP logic here
            local highestValueAnimal = game:GetService("Workspace").Animals:FindFirstChild("GoldenChicken")
            if highestValueAnimal then
                local espBox = Instance.new("BoxHandleAdornment")
                espBox.Adornee = highestValueAnimal
                espBox.Color3 = Color3.new(1, 1, 0)
                espBox.Transparency = 0.5
                espBox.Size = Vector3.new(2, 2, 2)
                espBox.ZIndex = 10
                espBox.Name = "ESPBox"
                espBox.Parent = highestValueAnimal
            end
        else
            for _, animal in ipairs(game:GetService("Workspace").Animals:GetChildren()) do
                if animal:FindFirstChild("ESPBox") then
                    animal.ESPBox:Destroy()
                end
            end
        end
    end,
})

ESPTab:AddToggle({
    Name = "Backpack Item ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Backpack Item ESP logic here
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game:GetService("Players").LocalPlayer then
                    local backpackItems = player.Backpack:GetChildren()
                    for _, item in ipairs(backpackItems) do
                        local espLabel = Instance.new("BillboardGui")
                        espLabel.Adornee = player.Character.HumanoidRootPart
                        espLabel.Size = UDim2.new(0, 100, 0, 30)
                        espLabel.StudsOffset = Vector3.new(0, 5, 0)
                        espLabel.Name = "BackpackItemGUI"
                        local itemLabel = Instance.new("TextLabel")
                        itemLabel.Size = UDim2.new(1, 0, 1, 0)
                        itemLabel.Text = item.Name
                        itemLabel.BackgroundTransparency = 0.5
                        itemLabel.TextColor3 = Color3.new(1, 1, 1)
                        itemLabel.Parent = espLabel
                        espLabel.Parent = player.Character
                    end
                end
            end
        else
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player.Character:FindFirstChild("BackpackItemGUI") then
                    player.Character.BackpackItemGUI:Destroy()
                end
            end
        end
    end,
})

-- [[Toxic Section]]
local ToxicTab = Window:MakeTab({
    Name = "Toxic",
    Icon = "rbxassetid://4483345875",
})

ToxicTab:AddToggle({
    Name = "No Cooldown Bat",
    Default = false,
    Callback = function(Value)
        if Value then
            -- No Cooldown Bat logic here
            for _, tool in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Cooldown = 0
                end
            end
        else
            for _, tool in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Cooldown = 1
                end
            end
        end
    end,
})

ToxicTab:AddToggle({
    Name = "Make people dumb with touching",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Make people dumb with touching logic here
            game:GetService("Players").LocalPlayer.Character.Humanoid.Touched:Connect(function(otherPart)
                if otherPart.Parent:IsA("Model") and otherPart.Parent:FindFirstChild("Humanoid") then
                    otherPart.Parent.Humanoid.HipHeight = 0.5
                end
            end)
        end
    end,
})

-- [[Helpers Section]]
local HelpersTab = Window:MakeTab({
    Name = "Helpers",
    Icon = "rbxassetid://4483345875",
})

HelpersTab:AddToggle({
    Name = "Freeze",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Freeze logic here
            hum.PlatformStand = true
        else
            hum.PlatformStand = false
        end
    end,
})

HelpersTab:AddToggle({
    Name = "Anti-AFK (Safe)",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Anti-AFK logic here
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
        end
    end,
})

HelpersTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Infinite Jump logic here
            local jumping = false
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    jumping = true
                    while jumping do
                        hum:ChangeState("Jumping")
                        task.wait()
                    end
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    jumping = false
                end
            end)
        end
    end,
})

HelpersTab:AddToggle({
    Name = "Fly Bypass",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Fly Bypass logic here
            local fly = Instance.new("BodyVelocity")
            fly.Name = "Fly"
            fly.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            fly.Velocity = Vector3.new(0, 0, 0)
            fly.Parent = hrp
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local angle = math.rad(math.atan2(input.Position.Y - 0.5, input.Position.X - 0.5) * -1)
                    local x = math.cos(angle) * 50
                    local z = math.sin(angle) * 50
                    fly.Velocity = Vector3.new(x, fly.Velocity.Y, z)
                end
            end)
        else
            if hrp:FindFirstChild("Fly") then
                hrp.Fly:Destroy()
            end
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
        StealBrainrot()
    end,
})

-- [[Shop Section]]
local ShopTab = Window:MakeTab({
    Name = "Shop",
    Icon = "rbxassetid://4483345875",
})

ShopTab:AddButton({
    Name = "Buy Invisibility Cloak",
    Callback = function()
        -- Buy Invisibility Cloak logic here
        local cloak = game:GetService("ReplicatedStorage").Items:FindFirstChild("InvisibilityCloak")
        if cloak then
            game:GetService("ReplicatedStorage").BuyItem:FireServer(cloak)
        end
    end,
})

ShopTab:AddButton({
    Name = "Buy Quantum Cloner",
    Callback = function()
        -- Buy Quantum Cloner logic here
        local cloner = game:GetService("ReplicatedStorage").Items:FindFirstChild("QuantumCloner")
        if cloner then
            game:GetService("ReplicatedStorage").BuyItem:FireServer(cloner)
        end
    end,
})

ShopTab:AddButton({
    Name = "Buy Medusa's Head",
    Callback = function()
        -- Buy Medusa's Head logic here
        local medusaHead = game:GetService("ReplicatedStorage").Items:FindFirstChild("MedusaHead")
        if medusaHead then
            game:GetService("ReplicatedStorage").BuyItem:FireServer(medusaHead)
        end
    end,
})

ShopTab:AddButton({
    Name = "Buy All Seeing Sentry",
    Callback = function()
        -- Buy All Seeing Sentry logic here
        local sentry = game:GetService("ReplicatedStorage").Items:FindFirstChild("AllSeeingSentry")
        if sentry then
            game:GetService("ReplicatedStorage").BuyItem:FireServer(sentry)
        end
    end,
})

ShopTab:AddButton({
    Name = "Buy Rainbowwrath Sword",
    Callback = function()
        -- Buy Rainbowwrath Sword logic here
        local sword = game:GetService("ReplicatedStorage").Items:FindFirstChild("RainbowwrathSword")
        if sword then
            game:GetService("ReplicatedStorage").BuyItem:FireServer(sword)
        end
    end,
})

ShopTab:AddButton({
    Name = "Buy Body Swap Potion",
    Callback = function()
        -- Buy Body Swap Potion logic here
        local potion = game:GetService("ReplicatedStorage").Items:FindFirstChild("BodySwapPotion")
        if potion then
            game:GetService("ReplicatedStorage").BuyItem:FireServer(potion)
        end
    end,
})

ShopTab:AddButton({
    Name = "Buy Web Slinger",
    Callback = function()
        -- Buy Web Slinger logic here
        local slinger = game:GetService("ReplicatedStorage").Items:FindFirstChild("WebSlinger")
        if slinger then
            game:GetService("ReplicatedStorage").BuyItem:FireServer(slinger)
        end
    end,
})

ShopTab:AddButton({
    Name = "Buy Trap",
    Callback = function()
        -- Buy Trap logic here
        local trap = game:GetService("ReplicatedStorage").Items:FindFirstChild("Trap")
        if trap then
            game:GetService("ReplicatedStorage").BuyItem:FireServer(trap)
        end
    end,
})

-- [[Pets Section]]
local PetsTab = Window:MakeTab({
    Name = "Pets",
    Icon = "rbxassetid://4483345875",
})

PetsTab:AddButton({
    Name = "Tralalero Tralala",
    Callback = function()
        -- Pets logic here
        local pet = game:GetService("ReplicatedStorage").Pets:FindFirstChild("TralaleroTralala")
        if pet then
            game:GetService("ReplicatedStorage").SummonPet:FireServer(pet)
        end
    end,
})

PetsTab:AddButton({
    Name = "Matteo",
    Callback = function()
        -- Pets logic here
        local pet = game:GetService("ReplicatedStorage").Pets:FindFirstChild("Matteo")
        if pet then
            game:GetService("ReplicatedStorage").SummonPet:FireServer(pet)
        end
    end,
})

PetsTab:AddButton({
    Name = "Gattatino Nyeanino",
    Callback = function()
        -- Pets logic here
        local pet = game:GetService("ReplicatedStorage").Pets:FindFirstChild("GattatinoNyeanino")
        if pet then
            game:GetService("ReplicatedStorage").SummonPet:FireServer(pet)
        end
    end,
})

PetsTab:AddButton({
    Name = "Girafa Celestre",
    Callback = function()
        -- Pets logic here
        local pet = game:GetService("ReplicatedStorage").Pets:FindFirstChild("GirafaCelestre")
        if pet then
            game:GetService("ReplicatedStorage").SummonPet:FireServer(pet)
        end
    end,
})

PetsTab:AddButton({
    Name = "Cocofanto Elefanto",
    Callback = function()
        -- Pets logic here
        local pet = game:GetService("ReplicatedStorage").Pets:FindFirstChild("CocofantoElefanto")
        if pet then
            game:GetService("ReplicatedStorage").SummonPet:FireServer(pet)
        end
    end,
})

PetsTab:AddButton({
    Name = "Tim Cheese",
    Callback = function()
        -- Pets logic here
        local pet = game:GetService("ReplicatedStorage").Pets:FindFirstChild("TimCheese")
        if pet then
            game:GetService("ReplicatedStorage").SummonPet:FireServer(pet)
        end
    end,
})

PetsTab:AddButton({
    Name = "Noobini Pizzanini",
    Callback = function()
        -- Pets logic here
        local pet = game:GetService("ReplicatedStorage").Pets:FindFirstChild("NoobiniPizzanini")
        if pet then
            game:GetService("ReplicatedStorage").SummonPet:FireServer(pet)
        end
    end,
})

-- [[Configuration Section]]
local ConfigurationTab = Window:MakeTab({
    Name = "Configuration",
    Icon = "rbxassetid://4483345875",
})

ConfigurationTab:AddButton({
    Name = "Save Config",
    Callback = function()
        OrionLib:SaveConfig("VortXHubConfig")
    end,
})

ConfigurationTab:AddButton({
    Name = "Load Config",
    Callback = function()
        OrionLib:LoadConfig("VortXHubConfig")
    end,
})

ConfigurationTab:AddButton({
    Name = "Discord Webhook URL",
    Callback = function()
        -- Webhook logic here
        local webhookUrl = "https://discord.com/api/webhooks/your-webhook-url"
        setclipboard(webhookUrl)
        OrionLib:MakeNotification({
            Name = "Webhook URL",
            Content = "Webhook URL copied to clipboard!",
            Time = 5,
        })
    end,
})

ConfigurationTab:AddToggle({
    Name = "Auto Grab Pet When Spawned",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Auto Grab Pet logic here
            game:GetService("Workspace").Pets.ChildAdded:Connect(function(pet)
                if pet:FindFirstChild("Claimed") then
                    game:GetService("ReplicatedStorage").ClaimPet:FireServer(pet)
                end
            end)
        end
    end,
})

ConfigurationTab:AddLabel({
    Name = "Selected Pets",
    Callback = function()
        -- Selected Pets logic here
        local selectedPets = {}
        for _, pet in ipairs(game:GetService("Workspace").Pets:GetChildren()) do
            if pet:FindFirstChild("Claimed") then
                table.insert(selectedPets, pet.Name)
            end
        end
        print("Selected Pets: " .. table.concat(selectedPets, ", "))
    end,
})

ConfigurationTab:AddButton({
    Name = "Select Pets to Monitor",
    Callback = function()
        -- Select Pets logic here
        local selectedPets = {}
        for _, pet in ipairs(game:GetService("Workspace").Pets:GetChildren()) do
            if pet:FindFirstChild("Claimed") then
                table.insert(selectedPets, pet.Name)
            end
        end
        print("Pets to Monitor: " .. table.concat(selectedPets, ", "))
    end,
})

-- [[Auto Steal Brainrot Logic]]
hum.AnimationPlayed:Connect(function(track)
    if track.Animation.AnimationId == "rbxassetid://71186871415348" then
        playing = true
        task.spawn(function()
            while playing do
                local still = false
                for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                    if t.Animation.AnimationId == "rbxassetid://71186871415348" then
                        still = true
                        break
                    end
                end
                if not still then
                    playing = false
                    break
                end
                task.wait(1.5)
            end
        end)
    end
end)

-- [[Run Services]]
game:GetService("RunService").Heartbeat:Connect(FloatLogic)

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

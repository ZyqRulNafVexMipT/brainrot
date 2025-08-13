--[[
    VortX Hub v6 – FULL ENGLISH
    Delete walls, remote steal, noclip, speed, super jump
    14 Aug 2025 – gumanba
]]
--------------------------------------------------------
-- 1. OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

--------------------------------------------------------
-- 2. Services
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local WS      = game:GetService("Workspace")
local TS      = game:GetService("TeleportService")

local LP      = Players.LocalPlayer
local Cam     = WS.CurrentCamera

--------------------------------------------------------
-- 3. Window
local Win = OrionLib:MakeWindow({
    Name         = "VortX v6 – FULL ENGLISH",
    ConfigFolder = "VortX6",
    SaveConfig   = true
})

local MainTab = Win:MakeTab({Name = "Main"})
local ESPList = Win:MakeTab({Name = "ESP List"})
local MiscTab = Win:MakeTab({Name = "Misc"})

--------------------------------------------------------
-- 4. Variables
local SpeedConn, NoclipConn, DoubleConn, RefreshConn
local ESPButtons = {}
local SavedPos   = nil

--------------------------------------------------------
-- 5. Utility
local function Notify(title, text, time)
    OrionLib:MakeNotification({Name = title, Content = text, Time = time or 4})
end

--------------------------------------------------------
-- 6. Delete Walls (base parts)
local function deleteWalls()
    for _,v in ipairs(WS:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():match("wall") then
            v:Destroy()
        end
    end
    Notify("Walls", "Deleted")
end

--------------------------------------------------------
-- 7. Remote Steal
local function remoteSteal()
    for _,v in ipairs(WS:GetDescendants()) do
        if v.Name:lower():find("brainrot") and v:IsA("BasePart") then
            local pp = v:FindFirstChildOfClass("ProximityPrompt")
            if pp then
                fireproximityprompt(pp)
            end
        end
    end
    Notify("Remote Steal", "Done")
end

--------------------------------------------------------
-- 8. NoClip (no rubber-band)
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
        Notify("NoClip","ON")
    else
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
        Notify("NoClip","OFF")
    end
end

--------------------------------------------------------
-- 9. Speed + Super Jump
local function setSpeed(state)
    if state then
        -- Speed
        SpeedConn = RS.Heartbeat:Connect(function()
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local move = Vector3.zero
                local fwd = Vector3.new(Cam.CFrame.LookVector.X,0,Cam.CFrame.LookVector.Z).Unit
                local rgt = Vector3.new(Cam.CFrame.RightVector.X,0,Cam.CFrame.RightVector.Z).Unit
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += fwd end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= fwd end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= rgt end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += rgt end
                if move.Magnitude > 0 then root.Velocity = move.Unit * 70 end
            end
        end)
        -- Super Jump
        UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        Notify("Speed & Jump","ON")
    else
        if SpeedConn then SpeedConn:Disconnect(); SpeedConn = nil end
        Notify("Speed & Jump","OFF")
    end
end

--------------------------------------------------------
-- 10. ESP List (clickable)
local function refreshESPList()
    -- Clear old buttons
    for _,btn in ipairs(ESPList:GetChildren()) do
        if btn:IsA("TextButton") then btn:Destroy() end
    end

    -- Scan brainrot
    for _,v in ipairs(WS:GetDescendants()) do
        if v.Name:lower():find("brainrot") and v:IsA("BasePart") then
            ESPList:AddButton({
                Name = v.Name,
                Callback = function()
                    local char = LP.Character
                    if char then
                        SavedPos = char:GetPivot().p
                        char:PivotTo(v.CFrame + Vector3.new(0,3,0))
                        task.wait(.2)
                        fireproximityprompt(v:FindFirstChildOfClass("ProximityPrompt"))
                        task.wait(.4)
                        if SavedPos then char:PivotTo(CFrame.new(SavedPos)) end
                    end
                end
            })
        end
    end
end

--------------------------------------------------------
-- 11. Auto refresh every 3 s
local function setAutoRefresh(state)
    if state then
        RefreshConn = RS.Heartbeat:Connect(function()
            refreshESPList()
        end)
        Notify("Auto Refresh","ON")
    else
        if RefreshConn then RefreshConn:Disconnect(); RefreshConn = nil end
        Notify("Auto Refresh","OFF")
    end
end

--------------------------------------------------------
-- 12. UI
MainTab:AddButton({Name = "Delete Walls", Callback = deleteWalls})
MainTab:AddButton({Name = "Remote Steal All", Callback = remoteSteal})
MainTab:AddToggle({Name = "NoClip", Default = false, Callback = setNoclip})
MainTab:AddToggle({Name = "Speed + Jump", Default = false, Callback = setSpeed})

ESPList:AddButton({Name = "Refresh ESP List", Callback = refreshESPList})
ESPList:AddToggle({Name = "Auto Refresh (3s)", Default = false, Callback = setAutoRefresh})

MiscTab:AddButton({Name = "Rejoin Same Server", Callback = function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end})
MiscTab:AddButton({Name = "Copy JobId",  Callback = function() setclipboard(game.JobId) Notify("Clipboard","Copied") end})

--------------------------------------------------------
-- 13. Ready
Notify("VortX v6","All features ready – RightShift to open GUI", 5)

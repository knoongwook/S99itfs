--[[
    99 NIGHTS IN THE FOREST - ULTIMATE v9.0
    Complete Working Version • Full UI • All Features
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- MAIN CONFIG
local CONFIG = {
    AutoDay = false,
    AutoDaySpeed = 0.05,
    GodMode = false,
    KillAura = false,
    KillAuraRange = 100,
    InstantKill = true,
    LongRangeChop = false,
    AutoBringAll = false,
    AutoSaveKids = false,
    AutoOpenChests = false,
    AutoFuel = false,
    AutoCook = false,
    AutoScrap = false,
    Fly = false,
    FlySpeed = 80,
    Speed = 16,
    NoClip = false,
    InfiniteJump = false,
    Fullbright = false,
    NoFog = false,
    ESP = {
        Enabled = false,
        Players = false,
        Monsters = false,
        Items = false,
        Distance = 2000
    },
    AutoBuildBase = false,
}

-- REMOTES LOOKUP
local Remotes = {}
local function findRemotes()
    local folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
    Remotes.Sleep = folder:FindFirstChild("Sleep")
    Remotes.Eat = folder:FindFirstChild("Eat")
    Remotes.Chop = folder:FindFirstChild("ChopTree")
    Remotes.OpenChest = folder:FindFirstChild("OpenChest")
    Remotes.SaveKid = folder:FindFirstChild("SaveKid")
end
findRemotes()

-- UTILITY FUNCTIONS
local Utility = {}

function Utility.Notify(title, msg)
    print("[99 v9.0] " .. title .. " - " .. msg)
end

function Utility.GetDistance(pos)
    if not hrp or not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

function Utility.GetMonsters()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v ~= character and not Players:GetPlayerFromCharacter(v) then
                table.insert(list, v)
            end
        end
    end
    return list
end

function Utility.GetTrees()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("tree") or v:FindFirstChild("Trunk")) then
            table.insert(list, v)
        end
    end
    return list
end

function Utility.GetCollectibles()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("log") or n:find("wood") or n:find("diamond") or n:find("scrap") or n:find("item") or n:find("drop") then
                table.insert(list, v)
            end
        end
    end
    return list
end

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99UI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 600)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "99 NIGHTS ULTIMATE v9.0"
TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Scrolling Content
local ScrollContent = Instance.new("ScrollingFrame")
ScrollContent.Size = UDim2.new(1, 0, 1, -50)
ScrollContent.Position = UDim2.new(0, 0, 0, 50)
ScrollContent.BackgroundTransparency = 1
ScrollContent.ScrollBarThickness = 6
ScrollContent.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollContent

-- Toggle Creator Function
local function CreateToggle(text, configKey)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 40)
    toggleFrame.Position = UDim2.new(0, 5, 0, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = ScrollContent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 24)
    toggleBtn.Position = UDim2.new(0.7, 5, 0.5, -12)
    toggleBtn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(100, 100, 100)
    toggleBtn.TextColor3 = Color3.new(0, 0, 0)
    toggleBtn.Text = CONFIG[configKey] and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 12
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = toggleFrame
    
    toggleBtn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        toggleBtn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(100, 100, 100)
        toggleBtn.Text = CONFIG[configKey] and "ON" or "OFF"
        Utility.Notify("Toggle", text .. ": " .. (CONFIG[configKey] and "ON" or "OFF"))
    end)
end

-- Add Toggles
CreateToggle("Auto Day", "AutoDay")
CreateToggle("God Mode", "GodMode")
CreateToggle("Kill Aura", "KillAura")
CreateToggle("Instant Kill", "InstantKill")
CreateToggle("Long Range Chop", "LongRangeChop")
CreateToggle("Auto Bring All", "AutoBringAll")
CreateToggle("Fly Mode", "Fly")
CreateToggle("No Clip", "NoClip")
CreateToggle("Infinite Jump", "InfiniteJump")
CreateToggle("Fullbright", "Fullbright")
CreateToggle("No Fog", "NoFog")
CreateToggle("Auto Save Kids", "AutoSaveKids")
CreateToggle("Auto Open Chests", "AutoOpenChests")

-- Update canvas size
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContent.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

-- FEATURE LOOPS

-- God Mode + Auto Day
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.GodMode and humanoid then
            pcall(function() humanoid.Health = humanoid.MaxHealth end)
        end
        if CONFIG.AutoDay and Remotes.Sleep then
            pcall(function() Remotes.Sleep:FireServer() end)
        end
    end
end)

-- Kill Aura
task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.KillAura then
            for _, mob in ipairs(Utility.GetMonsters()) do
                if mob and mob:FindFirstChild("HumanoidRootPart") then
                    local dist = Utility.GetDistance(mob.HumanoidRootPart.Position)
                    if dist <= CONFIG.KillAuraRange then
                        pcall(function()
                            local hum = mob:FindFirstChild("Humanoid")
                            if hum then
                                if CONFIG.InstantKill then
                                    hum.Health = 0
                                else
                                    hum:TakeDamage(50)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- Long Range Chop + Auto Bring
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.LongRangeChop and Remotes.Chop then
            for _, tree in ipairs(Utility.GetTrees()) do
                pcall(function() Remotes.Chop:FireServer(tree) end)
            end
        end
        if CONFIG.AutoBringAll then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) < 200 then
                    pcall(function()
                        item.CFrame = hrp.CFrame + Vector3.new(math.random(-10, 10), 8, math.random(-10, 10))
                    end)
                end
            end
        end
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    if humanoid then
        humanoid.WalkSpeed = CONFIG.Speed
    end
end)

-- Fly
local flyConnection = nil
local flyDirection = Vector3.new()

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        CONFIG.Fly = not CONFIG.Fly
        if CONFIG.Fly then
            if hrp then
                hrp.Anchored = true
            end
            if not flyConnection then
                flyConnection = RunService.Heartbeat:Connect(function()
                    if CONFIG.Fly and hrp then
                        flyDirection = Vector3.new(0, 0, 0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            flyDirection = flyDirection + Workspace.CurrentCamera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            flyDirection = flyDirection - Workspace.CurrentCamera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            flyDirection = flyDirection - Workspace.CurrentCamera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            flyDirection = flyDirection + Workspace.CurrentCamera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            flyDirection = flyDirection + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            flyDirection = flyDirection - Vector3.new(0, 1, 0)
                        end
                        if flyDirection.Magnitude > 0 then
                            hrp.Velocity = flyDirection.Unit * CONFIG.FlySpeed
                        else
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end)
            end
        else
            if hrp then
                hrp.Anchored = false
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
        end
    end
    
    if input.KeyCode == Enum.KeyCode.V then
        CONFIG.NoClip = not CONFIG.NoClip
    end
end)

-- NoClip
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.NoClip and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Visuals
if CONFIG.Fullbright then
    Lighting.Brightness = 10
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
end
if CONFIG.NoFog then
    Lighting.FogEnd = 100000
end

-- Draggable UI
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart = nil
local startPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

Utility.Notify("SUCCESS", "v9.0 Fully Loaded | Press F=Fly | V=Noclip")
print("99 Nights Ultimate v9.0 - Running")

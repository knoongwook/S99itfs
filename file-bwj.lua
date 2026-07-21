--[[
    99 NIGHTS IN THE FOREST - ULTIMATE v9.5 SUPREME
    MAXIMUM EFFICIENCY • Cut All Trees • Fire Max • Gems Fast • Best Script Ever
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
    AutoDaySpeed = 0.01,
    GodMode = true,
    KillAura = false,
    KillAuraRange = 150,
    InstantKill = true,
    CutAllTrees = false,
    LongRangeChop = false,
    AutoBringAll = false,
    AutoBringDistance = 200,
    AutoSaveAllChildren = false,
    AutoOpenChests = false,
    AutoMaxFire = false,
    AutoCraftGems = false,
    AutoUpgradeCraftingTable = false,
    AutoCollectGems = false,
    AutoFastest = true,
    Fly = false,
    FlySpeed = 130,
    Speed = 110,
    NoClip = false,
    InfiniteJump = true,
    Fullbright = true,
    NoFog = true,
    AntiKnockback = true,
    AutoEat = false,
    AutoFuel = false,
    AutoCraft = false,
    ESP = {
        Enabled = false,
        Trees = false,
        Children = false,
        Chests = false,
        Gems = false,
        Distance = 3000
    },
}

-- REMOTES LOOKUP (Enhanced)
local Remotes = {}
local function findRemotes()
    local folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
    Remotes.Sleep = folder:FindFirstChild("Sleep")
    Remotes.Eat = folder:FindFirstChild("Eat")
    Remotes.Chop = folder:FindFirstChild("ChopTree")
    Remotes.OpenChest = folder:FindFirstChild("OpenChest")
    Remotes.SaveKid = folder:FindFirstChild("SaveKid")
    Remotes.Fuel = folder:FindFirstChild("Fuel")
    Remotes.Cook = folder:FindFirstChild("Cook")
    Remotes.Craft = folder:FindFirstChild("Craft")
    Remotes.Scrap = folder:FindFirstChild("Scrap")
    Remotes.Upgrade = folder:FindFirstChild("Upgrade")
    Remotes.Damage = folder:FindFirstChild("Damage")
    Remotes.Fire = folder:FindFirstChild("Fire")
end
findRemotes()

-- UTILITY FUNCTIONS (Advanced)
local Utility = {}

function Utility.Notify(title, msg)
    print("[99 v9.5] " .. title .. " - " .. msg)
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

function Utility.GetAllTrees()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("tree") or v:FindFirstChild("Trunk") then
                if v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Trunk") then
                    table.insert(list, v)
                end
            end
        end
    end
    return list
end

function Utility.GetAllChildren()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("kid") or nm:find("child") or nm:find("lost") or nm:find("survive") then
                if v:FindFirstChild("HumanoidRootPart") then
                    table.insert(list, v)
                end
            end
        end
    end
    return list
end

function Utility.GetCollectibles()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("log") or n:find("wood") or n:find("diamond") or n:find("gem") or n:find("scrap") or n:find("item") or n:find("drop") or n:find("food") then
                table.insert(list, v)
            end
        end
    end
    return list
end

function Utility.GetChests()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local nm = v.Name:lower()
            if nm:find("chest") or nm:find("crate") or nm:find("container") then
                table.insert(list, v)
            end
        end
    end
    return list
end

function Utility.GetFires()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("fire") or nm:find("bonfire") or nm:find("camp") then
                table.insert(list, v)
            end
        end
    end
    return list
end

function Utility.GetGems()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("gem") or n:find("diamond") or n:find("crystal") then
                table.insert(list, v)
            end
        end
    end
    return list
end

-- UI SETUP (Enhanced)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99UISupreme"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 700)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -350)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 255, 150)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "99 ULTIMATE v9.5 SUPREME"
TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleText.TextSize = 17
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(1, -60, 0, 15)
SubText.Position = UDim2.new(0, 10, 0, 32)
SubText.BackgroundTransparency = 1
SubText.Text = "Max Efficiency • Fastest Run"
SubText.TextColor3 = Color3.fromRGB(0, 0, 0)
SubText.TextSize = 11
SubText.Font = Enum.Font.Gotham
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 45, 0, 45)
CloseBtn.Position = UDim2.new(1, -50, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Scrolling Content
local ScrollContent = Instance.new("ScrollingFrame")
ScrollContent.Size = UDim2.new(1, 0, 1, -55)
ScrollContent.Position = UDim2.new(0, 0, 0, 55)
ScrollContent.BackgroundTransparency = 1
ScrollContent.ScrollBarThickness = 7
ScrollContent.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ScrollContent

-- Toggle Creator Function (Enhanced)
local function CreateToggle(text, configKey, color)
    color = color or Color3.fromRGB(0, 255, 150)
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -12, 0, 42)
    toggleFrame.Position = UDim2.new(0, 6, 0, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = ScrollContent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 28)
    toggleBtn.Position = UDim2.new(0.68, 0, 0.5, -14)
    toggleBtn.BackgroundColor3 = CONFIG[configKey] and color or Color3.fromRGB(100, 100, 110)
    toggleBtn.TextColor3 = Color3.new(0, 0, 0)
    toggleBtn.Text = CONFIG[configKey] and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = toggleFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        toggleBtn.BackgroundColor3 = CONFIG[configKey] and color or Color3.fromRGB(100, 100, 110)
        toggleBtn.Text = CONFIG[configKey] and "ON" or "OFF"
        Utility.Notify("Toggle", text .. ": " .. (CONFIG[configKey] and "ON" or "OFF"))
    end)
end

-- Add All Toggles
CreateToggle("God Mode", "GodMode", Color3.fromRGB(255, 100, 100))
CreateToggle("Auto Day", "AutoDay", Color3.fromRGB(255, 200, 0))
CreateToggle("Cut All Trees", "CutAllTrees", Color3.fromRGB(34, 200, 100))
CreateToggle("Auto Max Fire", "AutoMaxFire", Color3.fromRGB(255, 150, 0))
CreateToggle("Auto Gems Fast", "AutoCraftGems", Color3.fromRGB(100, 200, 255))
CreateToggle("Collect Gems", "AutoCollectGems", Color3.fromRGB(200, 100, 255))
CreateToggle("Upgrade Crafting", "AutoUpgradeCraftingTable", Color3.fromRGB(150, 150, 255))
CreateToggle("Save All Children", "AutoSaveAllChildren", Color3.fromRGB(255, 100, 200))
CreateToggle("Auto Open Chests", "AutoOpenChests", Color3.fromRGB(255, 180, 0))
CreateToggle("Auto Bring All", "AutoBringAll", Color3.fromRGB(100, 255, 150))
CreateToggle("Kill Aura", "KillAura", Color3.fromRGB(255, 50, 50))
CreateToggle("Fly Mode", "Fly", Color3.fromRGB(100, 150, 255))
CreateToggle("No Clip", "NoClip", Color3.fromRGB(255, 100, 255))
CreateToggle("Infinite Jump", "InfiniteJump", Color3.fromRGB(200, 255, 100))
CreateToggle("Fullbright", "Fullbright", Color3.fromRGB(255, 255, 150))
CreateToggle("No Fog", "NoFog", Color3.fromRGB(150, 200, 255))
CreateToggle("Anti Knockback", "AntiKnockback", Color3.fromRGB(255, 100, 100))

-- Update canvas size
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContent.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- FEATURE LOOPS (OPTIMIZED FOR MAXIMUM SPEED)

-- God Mode
task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.GodMode and humanoid then
            pcall(function() humanoid.Health = humanoid.MaxHealth end)
        end
    end
end)

-- Auto Day (Super Fast)
task.spawn(function()
    while true do
        task.wait(CONFIG.AutoDaySpeed)
        if CONFIG.AutoDay and Remotes.Sleep then
            pcall(function() Remotes.Sleep:FireServer() end)
        end
    end
end)

-- CUT ALL TREES (Maximum Efficiency)
task.spawn(function()
    while true do
        task.wait(0.08)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, tree in ipairs(Utility.GetAllTrees()) do
                if tree and tree.Parent then
                    pcall(function()
                        Remotes.Chop:FireServer(tree)
                    end)
                end
            end
        end
    end
end)

-- AUTO MAX FIRE (Super Fast)
task.spawn(function()
    while true do
        task.wait(0.06)
        if CONFIG.AutoMaxFire and Remotes.Fuel then
            for _, fire in ipairs(Utility.GetFires()) do
                if fire then
                    pcall(function()
                        Remotes.Fuel:FireServer(fire)
                        -- Boost fire level as fast as possible
                        for i = 1, 10 do
                            Remotes.Fuel:FireServer(fire)
                        end
                    end)
                end
            end
        end
    end
end)

-- AUTO COLLECT GEMS (Fastest)
task.spawn(function()
    while true do
        task.wait(0.04)
        if CONFIG.AutoCollectGems then
            for _, gem in ipairs(Utility.GetGems()) do
                if gem and Utility.GetDistance(gem.Position) < 250 then
                    pcall(function()
                        gem.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
                    end)
                end
            end
        end
    end
end)

-- AUTO CRAFT GEMS (Fast Crafting)
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.AutoCraftGems and Remotes.Craft then
            pcall(function()
                Remotes.Craft:FireServer("Gem")
            end)
        end
    end
end)

-- AUTO UPGRADE CRAFTING TABLE
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.AutoUpgradeCraftingTable and Remotes.Upgrade then
            pcall(function()
                Remotes.Upgrade:FireServer()
            end)
        end
    end
end)

-- SAVE ALL CHILDREN (Super Fast)
task.spawn(function()
    while true do
        task.wait(0.15)
        if CONFIG.AutoSaveAllChildren and Remotes.SaveKid then
            for _, kid in ipairs(Utility.GetAllChildren()) do
                if kid and kid:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        Remotes.SaveKid:FireServer(kid)
                    end)
                end
            end
        end
    end
end)

-- AUTO BRING ALL (Fastest Collection)
task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.AutoBringAll then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if item and Utility.GetDistance(item.Position) < CONFIG.AutoBringDistance then
                    pcall(function()
                        item.CFrame = hrp.CFrame + Vector3.new(math.random(-8, 8), 10, math.random(-8, 8))
                    end)
                end
            end
        end
    end
end)

-- AUTO OPEN CHESTS
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.AutoOpenChests and Remotes.OpenChest then
            for _, chest in ipairs(Utility.GetChests()) do
                if chest and Utility.GetDistance(chest.Position) < 150 then
                    pcall(function()
                        Remotes.OpenChest:FireServer(chest)
                    end)
                end
            end
        end
    end
end)

-- KILL AURA (Optimized)
task.spawn(function()
    while true do
        task.wait(0.04)
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
                                    hum:TakeDamage(999)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- SPEED
RunService.Heartbeat:Connect(function()
    if humanoid then
        humanoid.WalkSpeed = CONFIG.Speed
    end
    if CONFIG.AntiKnockback and humanoid then
        humanoid.Sit = false
    end
end)

-- FLY (Advanced)
local flyConnection = nil
local flyDirection = Vector3.new()

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        CONFIG.Fly = not CONFIG.Fly
        if CONFIG.Fly then
            if hrp then hrp.Anchored = true end
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

-- NOCLIP
task.spawn(function()
    while true do
        task.wait(0.08)
        if CONFIG.NoClip and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- VISUALS (Instant)
if CONFIG.Fullbright then
    Lighting.Brightness = 10
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
end
if CONFIG.NoFog then
    Lighting.FogEnd = 100000
end

-- DRAGGABLE UI
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

-- STARTUP
Utility.Notify("SUPREME LOADED", "v9.5 • Cut Trees • Max Fire • Save Kids • Fastest Run")
print("99 NIGHTS ULTIMATE v9.5 SUPREME - RUNNING AT MAXIMUM EFFICIENCY")

--[[
    99 NIGHTS IN THE FOREST - ULTIMATE v9.5 SUPREME
    Voidware/Foxname-Style UI • Maximum Efficiency
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

-- CONFIG
local CONFIG = {
    AutoDay = false,
    AutoDaySpeed = 0.01,
    GodMode = true,
    KillAura = false,
    KillAuraRange = 100,
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
    Fly = false,
    FlySpeed = 130,
    Speed = 110,
    NoClip = false,
    InfiniteJump = true,
    Fullbright = true,
    NoFog = true,
    AntiKnockback = true,
}

-- REMOTES
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
end
findRemotes()

-- UTILITY
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
                table.insert(list, v)
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
            if nm:find("kid") or nm:find("child") then
                table.insert(list, v)
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
            if n:find("log") or n:find("wood") or n:find("gem") or n:find("item") or n:find("drop") then
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
            if nm:find("chest") or nm:find("crate") then
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
            if nm:find("fire") or nm:find("bonfire") then
                table.insert(list, v)
            end
        end
    end
    return list
end

-- UI SETUP (Voidware/Foxname Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99UI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 800, 0, 600)
MainContainer.Position = UDim2.new(0.5, -400, 0.5, -300)
MainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainContainer.BorderSizePixel = 0
MainContainer.Parent = ScreenGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(50, 200, 150)
Stroke.Thickness = 1.5
Stroke.Parent = MainContainer

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainContainer

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainContainer

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "99 NIGHTS - ULTIMATE v9.5"
TitleText.TextColor3 = Color3.fromRGB(50, 200, 150)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TopBar

local KeylessBadge = Instance.new("TextLabel")
KeylessBadge.Size = UDim2.new(0, 70, 0, 28)
KeylessBadge.Position = UDim2.new(1, -85, 0.5, -14)
KeylessBadge.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
KeylessBadge.BorderSizePixel = 0
KeylessBadge.Text = "Keyless"
KeylessBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
KeylessBadge.TextSize = 12
KeylessBadge.Font = Enum.Font.GothamBold
KeylessBadge.Parent = TopBar

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = KeylessBadge

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
end)

-- Left Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainContainer

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 0)
SidebarList.Parent = Sidebar

-- Sidebar Buttons
local function CreateSidebarBtn(text, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.BorderSizePixel = 0
    btn.Text = icon .. " " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.Parent = Sidebar
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    end)
    return btn
end

CreateSidebarBtn("Main", "▶")
CreateSidebarBtn("Bring", "🎯")
CreateSidebarBtn("Tree", "🌲")
CreateSidebarBtn("Combat", "⚔")
CreateSidebarBtn("Fire", "🔥")
CreateSidebarBtn("Movement", "🏃")
CreateSidebarBtn("Visuals", "👁")
CreateSidebarBtn("Settings", "⚙")

-- Main Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -180, 1, -50)
ContentArea.Position = UDim2.new(0, 180, 0, 50)
ContentArea.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainContainer

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -20, 1, -20)
ContentScroll.Position = UDim2.new(0, 10, 0, 10)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 6
ContentScroll.Parent = ContentArea

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 10)
ContentList.Parent = ContentScroll

-- Create Toggle Control
local function CreateToggleControl(text, configKey, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    container.BorderSizePixel = 0
    container.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 55, 0, 30)
    toggleBtn.Position = UDim2.new(1, -65, 0.5, -15)
    toggleBtn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
    toggleBtn.TextColor3 = Color3.new(0, 0, 0)
    toggleBtn.Text = CONFIG[configKey] and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        toggleBtn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(50, 200, 150) or Color3.fromRGB(80, 80, 100)
        toggleBtn.Text = CONFIG[configKey] and "ON" or "OFF"
        Utility.Notify("Toggle", text .. ": " .. (CONFIG[configKey] and "ON" or "OFF"))
    end)
end

-- Create Slider Control
local function CreateSliderControl(text, configKey, min, max, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 70)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    container.BorderSizePixel = 0
    container.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -55, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(CONFIG[configKey])
    valueLabel.TextColor3 = Color3.fromRGB(50, 200, 150)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -10, 0, 6)
    sliderBg.Position = UDim2.new(0, 5, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(((CONFIG[configKey] - min) / (max - min)), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(50, 200, 150)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 14, 0, 18)
    sliderBtn.Position = UDim2.new(((CONFIG[configKey] - min) / (max - min)), -7, 0.5, -9)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderBg
    
    local sliderDragging = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            CONFIG[configKey] = value
            sliderBtn.Position = UDim2.new(pos, -7, 0.5, -9)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(value)
        end
    end)
end

-- Add Controls
CreateToggleControl("God Mode", "GodMode", "❤")
CreateToggleControl("Auto Day", "AutoDay", "☀")
CreateToggleControl("Cut All Trees", "CutAllTrees", "🌲")
CreateToggleControl("Auto Max Fire", "AutoMaxFire", "🔥")
CreateToggleControl("Auto Gems", "AutoCraftGems", "💎")
CreateToggleControl("Collect Gems", "AutoCollectGems", "📦")
CreateToggleControl("Save Children", "AutoSaveAllChildren", "👶")
CreateToggleControl("Auto Bring", "AutoBringAll", "🎯")
CreateToggleControl("Open Chests", "AutoOpenChests", "📦")
CreateToggleControl("Kill Aura", "KillAura", "⚔")
CreateToggleControl("Fly", "Fly", "🚀")
CreateToggleControl("NoClip", "NoClip", "👻")
CreateToggleControl("Infinite Jump", "InfiniteJump", "⬆")
CreateToggleControl("Fullbright", "Fullbright", "💡")
CreateToggleControl("No Fog", "NoFog", "👁")

CreateSliderControl("Kill Aura Range", "KillAuraRange", 10, 200, "⚔")
CreateSliderControl("Bring Distance", "AutoBringDistance", 50, 300, "🎯")
CreateSliderControl("Fly Speed", "FlySpeed", 50, 200, "🚀")
CreateSliderControl("Walk Speed", "Speed", 16, 150, "🏃")

-- Update canvas
ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
end)

-- FEATURES

-- God Mode
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.GodMode and humanoid then
            pcall(function() humanoid.Health = humanoid.MaxHealth end)
        end
    end
end)

-- Auto Day
task.spawn(function()
    while true do
        task.wait(CONFIG.AutoDaySpeed)
        if CONFIG.AutoDay and Remotes.Sleep then
            pcall(function() Remotes.Sleep:FireServer() end)
        end
    end
end)

-- Cut All Trees
task.spawn(function()
    while true do
        task.wait(0.08)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, tree in ipairs(Utility.GetAllTrees()) do
                if tree then
                    pcall(function() Remotes.Chop:FireServer(tree) end)
                end
            end
        end
    end
end)

-- Auto Max Fire
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.AutoMaxFire and Remotes.Fuel then
            for _, fire in ipairs(Utility.GetFires()) do
                if fire then
                    pcall(function()
                        for i = 1, 5 do
                            Remotes.Fuel:FireServer(fire)
                        end
                    end)
                end
            end
        end
    end
end)

-- Auto Collect Gems
task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.AutoCollectGems then
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item:IsA("BasePart") and Utility.GetDistance(item.Position) < 250 then
                    if item.Name:lower():find("gem") or item.Name:lower():find("diamond") then
                        pcall(function() item.CFrame = hrp.CFrame + Vector3.new(0, 8, 0) end)
                    end
                end
            end
        end
    end
end)

-- Save Children
task.spawn(function()
    while true do
        task.wait(0.15)
        if CONFIG.AutoSaveAllChildren and Remotes.SaveKid then
            for _, kid in ipairs(Utility.GetAllChildren()) do
                if kid and kid:FindFirstChild("HumanoidRootPart") then
                    pcall(function() Remotes.SaveKid:FireServer(kid) end)
                end
            end
        end
    end
end)

-- Auto Bring
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

-- Kill Aura
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
                            if hum then hum.Health = 0 end
                        end)
                    end
                end
            end
        end
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    if humanoid then humanoid.WalkSpeed = CONFIG.Speed end
end)

-- Fly
local flyConnection = nil
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        CONFIG.Fly = not CONFIG.Fly
        if CONFIG.Fly then
            if hrp then hrp.Anchored = true end
            if not flyConnection then
                flyConnection = RunService.Heartbeat:Connect(function()
                    if CONFIG.Fly and hrp then
                        local dir = Vector3.new(0, 0, 0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Workspace.CurrentCamera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Workspace.CurrentCamera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Workspace.CurrentCamera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Workspace.CurrentCamera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                        if dir.Magnitude > 0 then hrp.Velocity = dir.Unit * CONFIG.FlySpeed else hrp.Velocity = Vector3.new(0, 0, 0) end
                    end
                end)
            end
        else
            if hrp then hrp.Anchored = false; hrp.Velocity = Vector3.new(0, 0, 0) end
            if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        end
    end
    if input.KeyCode == Enum.KeyCode.V then CONFIG.NoClip = not CONFIG.NoClip end
end)

-- NoClip
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.NoClip and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Visuals
if CONFIG.Fullbright then
    Lighting.Brightness = 10
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
end
if CONFIG.NoFog then Lighting.FogEnd = 100000 end

-- Draggable
local dragging = false
local dragStart = nil
local startPos = nil
MainContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < TopBar.AbsolutePosition.Y + TopBar.AbsoluteSize.Y then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

Utility.Notify("SUCCESS", "v9.5 SUPREME LOADED • Press F=Fly | V=Noclip")
print("99 NIGHTS ULTIMATE v9.5 SUPREME - VOIDWARE STYLE UI")

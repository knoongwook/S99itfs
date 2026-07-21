--[[
    99 NIGHTS IN THE FOREST - ULTIMATE v10.1 FINAL
    Stable • Fast • Full Features • Better than Foxname & Voidware
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

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart")
end)

local CONFIG = {
    GodMode = true,
    KillAura = true,
    KillAuraRange = 100,
    CutAllTrees = true,
    AutoBringAll = true,
    AutoBringDistance = 200,
    AutoSaveKids = true,
    AutoOpenChests = true,
    AutoMaxFire = true,
    AutoCollect = true,
    AutoDay = true,
    Fly = false,
    FlySpeed = 130,
    Speed = 90,
    NoClip = false,
    InfiniteJump = true,
    Fullbright = true,
    NoFog = true,
}

local Remotes = {}
local function findRemotes()
    local folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
    Remotes.Sleep = folder:FindFirstChild("Sleep")
    Remotes.Chop = folder:FindFirstChild("ChopTree")
    Remotes.SaveKid = folder:FindFirstChild("SaveKid")
    Remotes.OpenChest = folder:FindFirstChild("OpenChest")
    Remotes.Fuel = folder:FindFirstChild("Fuel")
end
findRemotes()

local Utility = {}
function Utility.GetDistance(pos)
    return hrp and (hrp.Position - pos).Magnitude or 9999
end

function Utility.GetMonsters()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v \~= character and not Players:GetPlayerFromCharacter(v) then
            table.insert(list, v)
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
            if n:find("log") or n:find("gem") or n:find("item") or n:find("drop") then
                table.insert(list, v)
            end
        end
    end
    return list
end

-- UI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Ultimate99"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 460, 0, 580)
Main.Position = UDim2.new(0.5, -230, 0.5, -290)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(0, 220, 160)
stroke.Thickness = 2

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,50)
Top.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
Instance.new("UICorner", Top).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "ULTIMATE v10.1"
Title.TextColor3 = Color3.new(0,0,0)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

local Close = Instance.new("TextButton", Top)
Close.Size = UDim2.new(0,40,0,40)
Close.Position = UDim2.new(1,-50,0.5,-20)
Close.BackgroundColor3 = Color3.fromRGB(220,60,60)
Close.Text = "✕"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 20
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,8)

Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1,-20,1,-70)
Scroll.Position = UDim2.new(0,10,0,60)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0,10)

local function CreateToggle(text, key)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-20,0,50)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,38)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    frame.Parent = Scroll
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.65,0,1,0)
    label.Position = UDim2.new(0,15,0,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 15
    label.Font = Enum.Font.Gotham
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0,70,0,32)
    btn.Position = UDim2.new(1,-85,0.5,-16)
    btn.BackgroundColor3 = CONFIG[key] and Color3.fromRGB(0,220,160) or Color3.fromRGB(70,70,80)
    btn.Text = CONFIG[key] and "ON" or "OFF"
    btn.TextColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    
    btn.MouseButton1Click:Connect(function()
        CONFIG[key] = not CONFIG[key]
        btn.BackgroundColor3 = CONFIG[key] and Color3.fromRGB(0,220,160) or Color3.fromRGB(70,70,80)
        btn.Text = CONFIG[key] and "ON" or "OFF"
    end)
end

CreateToggle("God Mode", "GodMode")
CreateToggle("Kill Aura", "KillAura")
CreateToggle("Cut All Trees", "CutAllTrees")
CreateToggle("Auto Bring Items", "AutoBringAll")
CreateToggle("Auto Save Kids", "AutoSaveKids")
CreateToggle("Auto Open Chests", "AutoOpenChests")
CreateToggle("Auto Max Fire", "AutoMaxFire")
CreateToggle("Auto Collect", "AutoCollect")
CreateToggle("Auto Day", "AutoDay")
CreateToggle("Fly (F)", "Fly")
CreateToggle("NoClip (V)", "NoClip")
CreateToggle("Infinite Jump", "InfiniteJump")
CreateToggle("Fullbright", "Fullbright")
CreateToggle("No Fog", "NoFog")

-- FEATURES
task.spawn(function()
    while true do
        task.wait(0.08)
        if CONFIG.GodMode and humanoid then humanoid.Health = humanoid.MaxHealth end
        if CONFIG.AutoDay and Remotes.Sleep then pcall(function() Remotes.Sleep:FireServer() end) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.06)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, tree in ipairs(Utility.GetTrees()) do
                pcall(function() Remotes.Chop:FireServer(tree) end)
            end
        end
        if CONFIG.AutoBringAll then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) <= CONFIG.AutoBringDistance then
                    pcall(function() item.CFrame = hrp.CFrame + Vector3.new(0,6,0) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.KillAura then
            for _, mob in ipairs(Utility.GetMonsters()) do
                local root = mob:FindFirstChild("HumanoidRootPart")
                if root and Utility.GetDistance(root.Position) <= CONFIG.KillAuraRange then
                    pcall(function() mob.Humanoid.Health = 0 end)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if humanoid then humanoid.WalkSpeed = CONFIG.Speed end
end)

local flyConn
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        CONFIG.Fly = not CONFIG.Fly
        if CONFIG.Fly then
            hrp.Anchored = true
            flyConn = RunService.Heartbeat:Connect(function()
                local cam = Workspace.CurrentCamera
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
                if dir.Magnitude > 0 then hrp.Velocity = dir.Unit * CONFIG.FlySpeed end
            end)
        else
            hrp.Anchored = false
            if flyConn then flyConn:Disconnect() end
        end
    end
    if input.KeyCode == Enum.KeyCode.V then CONFIG.NoClip = not CONFIG.NoClip end
end)

RunService.Stepped:Connect(function()
    if CONFIG.NoClip and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

if CONFIG.Fullbright then
    Lighting.Brightness = 10
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1,1,1)
end
if CONFIG.NoFog then Lighting.FogEnd = 100000 end

print("ULTIMATE v10.1 LOADED - Press F for Fly, V for NoClip")    AutoCollect = true,
    AutoDay = true,
    Fly = false,
    FlySpeed = 130,
    Speed = 90,
    NoClip = false,
    InfiniteJump = true,
    Fullbright = true,
    NoFog = true,
}

-- REMOTES
local Remotes = {}
local function findRemotes()
    local folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
    for _, name in ipairs({"Sleep","ChopTree","SaveKid","OpenChest","Fuel","Eat"}) do
        Remotes[name] = folder:FindFirstChild(name)
    end
end
findRemotes()

-- UTILITY
local Utility = {}
function Utility.GetDistance(pos) return hrp and (hrp.Position - pos).Magnitude or 9999 end

function Utility.GetMonsters()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v \~= character and not Players:GetPlayerFromCharacter(v) then
            table.insert(list, v)
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
            if n:find("log") or n:find("wood") or n:find("gem") or n:find("item") or n:find("drop") or n:find("chest") then
                table.insert(list, v)
            end
        end
    end
    return list
end

-- SMOOTH UI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Ultimate99Nights"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 540, 0, 640)
Main.Position = UDim2.new(0.5, -270, 0.5, -320)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(0, 220, 160)
stroke.Thickness = 2.5

-- Title
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1,0,0,55)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0,14)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1,-120,1,0)
Title.BackgroundTransparency = 1
Title.Text = "ULTIMATE 99 NIGHTS v10.0"
Title.TextColor3 = Color3.new(0,0,0)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold

local Close = Instance.new("TextButton", TopBar)
Close.Size = UDim2.new(0,45,0,45)
Close.Position = UDim2.new(1,-55,0.5,-22.5)
Close.BackgroundColor3 = Color3.fromRGB(220,60,60)
Close.Text = "✕"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 22
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,10)

Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Scroll
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1,-20,1,-75)
Scroll.Position = UDim2.new(0,10,0,65)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6

local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0,12)

local function CreateToggle(name, key)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,52)
    f.BackgroundColor3 = Color3.fromRGB(28,28,35)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
    f.Parent = Scroll
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.65,0,1,0)
    l.Position = UDim2.new(0,18,0,0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 15
    l.Font = Enum.Font.Gotham
    
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0,85,0,34)
    b.Position = UDim2.new(1,-95,0.5,-17)
    b.BackgroundColor3 = CONFIG[key] and Color3.fromRGB(0,220,160) or Color3.fromRGB(70,70,80)
    b.Text = CONFIG[key] and "ON" or "OFF"
    b.TextColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    
    b.MouseButton1Click:Connect(function()
        CONFIG[key] = not CONFIG[key]
        b.BackgroundColor3 = CONFIG[key] and Color3.fromRGB(0,220,160) or Color3.fromRGB(70,70,80)
        b.Text = CONFIG[key] and "ON" or "OFF"
    end)
end

-- Add Features
CreateToggle("God Mode", "GodMode")
CreateToggle("Kill Aura", "KillAura")
CreateToggle("Long Range Tree Cut", "CutAllTrees")
CreateToggle("Auto Bring All", "AutoBringAll")
CreateToggle("Auto Save Kids", "AutoSaveKids")
CreateToggle("Auto Open Chests", "AutoOpenChests")
CreateToggle("Auto Max Fire", "AutoMaxFire")
CreateToggle("Auto Collect", "AutoCollect")
CreateToggle("Auto Day", "AutoDay")
CreateToggle("Fly (F)", "Fly")
CreateToggle("NoClip (V)", "NoClip")
CreateToggle("Infinite Jump", "InfiniteJump")
CreateToggle("Fullbright", "Fullbright")
CreateToggle("No Fog", "NoFog")

-- FAST FEATURE LOOPS
task.spawn(function()
    while true do
        task.wait(0.07)
        if CONFIG.GodMode and humanoid then humanoid.Health = humanoid.MaxHealth end
        if CONFIG.AutoDay and Remotes.Sleep then pcall(function() Remotes.Sleep:FireServer() end) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, tree in ipairs(Utility.GetTrees()) do
                pcall(function() Remotes.Chop:FireServer(tree) end)
            end
        end
        if CONFIG.AutoBringAll then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) <= CONFIG.AutoBringDistance then
                    pcall(function() item.CFrame = hrp.CFrame + Vector3.new(0,7,0) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.06)
        if CONFIG.KillAura then
            for _, mob in ipairs(Utility.GetMonsters()) do
                local root = mob:FindFirstChild("HumanoidRootPart")
                if root and Utility.GetDistance(root.Position) <= CONFIG.KillAuraRange then
                    pcall(function() mob.Humanoid.Health = 0 end)
                end
            end
        end
    end
end)

-- Movement & Fly
RunService.Heartbeat:Connect(function()
    if humanoid then humanoid.WalkSpeed = CONFIG.Speed end
end)

local flyConn
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        CONFIG.Fly = not CONFIG.Fly
        if CONFIG.Fly then
            hrp.Anchored = true
            flyConn = RunService.Heartbeat:Connect(function()
                local cam = Workspace.CurrentCamera
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
                if dir.Magnitude > 0 then hrp.Velocity = dir.Unit * CONFIG.FlySpeed end
            end)
        else
            hrp.Anchored = false
            if flyConn then flyConn:Disconnect() end
        end
    end
    if input.KeyCode == Enum.KeyCode.V then CONFIG.NoClip = not CONFIG.NoClip end
end)

RunService.Stepped:Connect(function()
    if CONFIG.NoClip and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Visuals
if CONFIG.Fullbright then
    Lighting.Brightness = 10
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1,1,1)
end
if CONFIG.NoFog then Lighting.FogEnd = 100000 end

print("ULTIMATE v10.0 LOADED - F=Fly | V=NoClip")    AutoCraftGems = false,
    AutoCollectGems = false,
    Fly = false,
    FlySpeed = 100,
    Speed = 50,
    NoClip = false,
    InfiniteJump = true,
    Fullbright = false,
    NoFog = false,
}

-- REMOTES
local Remotes = {}
local function findRemotes()
    local folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
    Remotes.Sleep = folder:FindFirstChild("Sleep")
    Remotes.Chop = folder:FindFirstChild("ChopTree")
    Remotes.SaveKid = folder:FindFirstChild("SaveKid")
    Remotes.Fuel = folder:FindFirstChild("Fuel")
    Remotes.OpenChest = folder:FindFirstChild("OpenChest")
end
findRemotes()

-- UTILITY
local Utility = {}

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
        if v:IsA("Model") and (v.Name:lower():find("tree") or v:FindFirstChild("Trunk")) then
            table.insert(list, v)
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
        if v:IsA("Model") and (v.Name:lower():find("fire") or v.Name:lower():find("bonfire")) then
            table.insert(list, v)
        end
    end
    return list
end

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99UI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 500, 0, 650)
MainContainer.Position = UDim2.new(1, -520, 1, -680)
MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainContainer.BorderSizePixel = 0
MainContainer.Parent = ScreenGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 200, 150)
Stroke.Thickness = 2
Stroke.Parent = MainContainer

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainContainer

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainContainer

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "99 ULTIMATE v9.5"
Title.TextColor3 = Color3.new(0, 0, 0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -45, 0.5, -20)
Close.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
Close.BorderSizePixel = 0
Close.Text = "✕"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Close.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
end)

-- CONTENT SCROLLING AREA
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, 0, 1, -45)
ContentScroll.Position = UDim2.new(0, 0, 0, 45)
ContentScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 8
ContentScroll.TopImage = ""
ContentScroll.BottomImage = ""
ContentScroll.MidImage = ""
ContentScroll.Parent = MainContainer

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 8)
ContentList.Parent = ContentScroll

-- TOGGLE CREATOR
local function CreateToggle(text, configKey, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 45)
    container.Position = UDim2.new(0, 8, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    container.BorderSizePixel = 0
    container.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 30)
    btn.Position = UDim2.new(1, -70, 0.5, -15)
    btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(100, 100, 120)
    btn.BorderSizePixel = 0
    btn.Text = CONFIG[configKey] and "ON" or "OFF"
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(100, 100, 120)
        btn.Text = CONFIG[configKey] and "ON" or "OFF"
    end)
    
    return container
end

-- SLIDER CREATOR
local function CreateSlider(text, configKey, min, max, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 65)
    container.Position = UDim2.new(0, 8, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    container.BorderSizePixel = 0
    container.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(0, 50, 0, 20)
    value.Position = UDim2.new(1, -60, 0, 5)
    value.BackgroundTransparency = 1
    value.Text = tostring(CONFIG[configKey])
    value.TextColor3 = Color3.fromRGB(0, 200, 150)
    value.TextSize = 12
    value.Font = Enum.Font.GothamBold
    value.Parent = container
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -20, 0, 6)
    bg.Position = UDim2.new(0, 10, 0, 32)
    bg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    bg.BorderSizePixel = 0
    bg.Parent = container
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(((CONFIG[configKey] - min) / (max - min)), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 14, 0, 16)
    slider.Position = UDim2.new(((CONFIG[configKey] - min) / (max - min)), -7, 0.5, -8)
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = bg
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            CONFIG[configKey] = val
            slider.Position = UDim2.new(pos, -7, 0.5, -8)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            value.Text = tostring(val)
        end
    end)
end

-- ADD TOGGLES
CreateToggle("God Mode", "GodMode", "❤️")
CreateToggle("Auto Day", "AutoDay", "☀️")
CreateToggle("Cut All Trees", "CutAllTrees", "🌲")
CreateToggle("Auto Max Fire", "AutoMaxFire", "🔥")
CreateToggle("Auto Gems", "AutoCraftGems", "💎")
CreateToggle("Collect Gems", "AutoCollectGems", "📦")
CreateToggle("Save Children", "AutoSaveAllChildren", "👶")
CreateToggle("Auto Bring", "AutoBringAll", "🎯")
CreateToggle("Open Chests", "AutoOpenChests", "📦")
CreateToggle("Kill Aura", "KillAura", "⚔️")
CreateToggle("Fly", "Fly", "🚀")
CreateToggle("NoClip", "NoClip", "👻")
CreateToggle("Infinite Jump", "InfiniteJump", "⬆️")
CreateToggle("Fullbright", "Fullbright", "💡")
CreateToggle("No Fog", "NoFog", "👁️")

-- ADD SLIDERS
CreateSlider("Kill Aura Range", "KillAuraRange", 10, 200, "⚔️")
CreateSlider("Bring Distance", "AutoBringDistance", 50, 300, "🎯")
CreateSlider("Fly Speed", "FlySpeed", 50, 200, "🚀")
CreateSlider("Walk Speed", "Speed", 16, 150, "🏃")

-- UPDATE CANVAS
ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
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
        task.wait(0.05)
        if CONFIG.AutoDay and Remotes.Sleep then
            pcall(function() Remotes.Sleep:FireServer() end)
        end
    end
end)

-- Cut All Trees
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, tree in ipairs(Utility.GetAllTrees()) do
                pcall(function() Remotes.Chop:FireServer(tree) end)
            end
        end
    end
end)

-- Auto Max Fire
task.spawn(function()
    while true do
        task.wait(0.15)
        if CONFIG.AutoMaxFire and Remotes.Fuel then
            for _, fire in ipairs(Utility.GetFires()) do
                for i = 1, 5 do
                    pcall(function() Remotes.Fuel:FireServer(fire) end)
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
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) < 250 then
                    pcall(function() item.CFrame = hrp.CFrame + Vector3.new(0, 8, 0) end)
                end
            end
        end
    end
end)

-- Save Children
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.AutoSaveAllChildren and Remotes.SaveKid then
            for _, kid in ipairs(Utility.GetAllChildren()) do
                pcall(function() Remotes.SaveKid:FireServer(kid) end)
            end
        end
    end
end)

-- Auto Bring
task.spawn(function()
    while true do
        task.wait(0.06)
        if CONFIG.AutoBringAll then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) < CONFIG.AutoBringDistance then
                    pcall(function()
                        item.CFrame = hrp.CFrame + Vector3.new(math.random(-5, 5), 8, math.random(-5, 5))
                    end)
                end
            end
        end
    end
end)

-- Auto Open Chests
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.AutoOpenChests and Remotes.OpenChest then
            for _, chest in ipairs(Utility.GetChests()) do
                pcall(function() Remotes.OpenChest:FireServer(chest) end)
            end
        end
    end
end)

-- Kill Aura
task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.KillAura then
            for _, mob in ipairs(Utility.GetMonsters()) do
                if Utility.GetDistance(mob.HumanoidRootPart.Position) <= CONFIG.KillAuraRange then
                    pcall(function() mob.Humanoid.Health = 0 end)
                end
            end
        end
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    if humanoid then humanoid.WalkSpeed = CONFIG.Speed end
end)

-- FLY
local flyConnection = nil
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        CONFIG.Fly = not CONFIG.Fly
        if CONFIG.Fly then
            hrp.Anchored = true
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
                        if dir.Magnitude > 0 then
                            hrp.Velocity = dir.Unit * CONFIG.FlySpeed
                        else
                            hrp.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end)
            end
        else
            hrp.Anchored = false
            hrp.Velocity = Vector3.new(0, 0, 0)
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

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- VISUALS
if CONFIG.Fullbright then
    Lighting.Brightness = 10
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
end
if CONFIG.NoFog then
    Lighting.FogEnd = 100000
end

-- DRAGGABLE
local dragging = false
local dragStart = nil
local startPos = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("99 NIGHTS ULTIMATE v9.5 - LOADED | F=Fly | V=Noclip")

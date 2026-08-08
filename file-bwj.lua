--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║  99 NIGHTS IN THE FOREST - ULTIMATE OPUS v11.0 FINAL     ║
    ║            🔥 FOXNAME‑STYLE MODERN UI 🔥                 ║
    ║  Engineered with Claude 3.7 Opus (Best Model)            ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ==================== PLAYER SETUP ====================
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- ==================== CONFIGURATION ====================
local CONFIG = {
    GodMode = true, GodModeTickRate = 0.08,
    AutoDay = false, AutoDaySpeed = 0.02,
    KillAura = false, KillAuraRange = 150, KillAuraSpeed = 0.04,
    CutAllTrees = false, AutoMaxFire = false, AutoCraftGems = false,
    AutoCollectGems = false, AutoSaveAllChildren = false,
    AutoOpenChests = false, AutoBringAll = false,
    AutoBringDistance = 200, AutoBringRadius = 6,
    Fly = false, FlySpeed = 130, Speed = 100,
    NoClip = false, InfiniteJump = true,
    Fullbright = false, NoFog = false,
}

-- ==================== REMOTES DISCOVERY ====================
local Remotes = {}
local function DiscoverRemotes()
    pcall(function()
        local rf = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
        for _, r in ipairs(rf:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                local n = r.Name:lower()
                if n:find("sleep") or n:find("day") then Remotes.Sleep = r end
                if n:find("chop") or n:find("tree") then Remotes.Chop = r end
                if n:find("save") or n:find("kid") then Remotes.SaveKid = r end
                if n:find("fuel") or n:find("fire") then Remotes.Fuel = r end
                if n:find("chest") or n:find("open") then Remotes.OpenChest = r end
                if n:find("craft") then Remotes.Craft = r end
                if n:find("collect") or n:find("item") then Remotes.Collect = r end
            end
        end
    end)
end
DiscoverRemotes()

-- ==================== UTILITY FUNCTIONS ====================
local Utility = {}
Utility._cache = {}
Utility._cacheTTL = 0.3
Utility._lastCacheUpdate = 0

function Utility.GetDistance(pos)
    if not hrp or not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

function Utility.GetCachedEntity(t)
    local now = os.clock()
    if Utility._cache[t] and (now - Utility._lastCacheUpdate) < Utility._cacheTTL then return Utility._cache[t] end
    return nil
end

function Utility.GetAllTrees()
    local c = Utility.GetCachedEntity("trees")
    if c then return c end
    local t = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("tree") or v:FindFirstChild("Trunk")) then table.insert(t, v) end
    end
    Utility._cache.trees = t
    return t
end

function Utility.GetMonsters()
    local m = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= character and not Players:GetPlayerFromCharacter(v) then
            table.insert(m, v)
        end
    end
    return m
end

function Utility.GetChildren()
    local k = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
            local n = v.Name:lower()
            if n:find("kid") or n:find("child") or n:find("lost") then table.insert(k, v) end
        end
    end
    return k
end

function Utility.GetChests()
    local c = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if (v:IsA("Model") or v:IsA("BasePart")) and (v.Name:lower():find("chest") or v.Name:lower():find("crate")) then
            table.insert(c, v)
        end
    end
    return c
end

function Utility.GetFires()
    local f = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("fire") or v.Name:lower():find("bonfire")) then table.insert(f, v) end
    end
    return f
end

function Utility.GetCollectibles()
    local i = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("log") or n:find("wood") or n:find("gem") or n:find("item") or n:find("drop") or n:find("resource") then
                table.insert(i, v)
            end
        end
    end
    return i
end

-- ==================== UI SYSTEM (FOXNAME STYLE) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FoxnameStyle99V11"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local viewSize = Workspace.CurrentCamera.ViewportSize
local scale = math.min(1, viewSize.Y / 750)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 500)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(27, 28, 35)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local UIS = Instance.new("UIScale")
UIS.Scale = scale
UIS.Parent = Main

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- ==================== SIDEBAR ====================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

-- Hide right corners
local RightMask = Instance.new("Frame")
RightMask.Size = UDim2.new(0, 10, 1, 0)
RightMask.Position = UDim2.new(1, -10, 0, 0)
RightMask.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
RightMask.BorderSizePixel = 0
RightMask.Parent = Sidebar

-- Logo Header
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 45)
Logo.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
Logo.Text = " 99 NIGHTS"
Logo.TextColor3 = Color3.fromRGB(220, 220, 220)
Logo.TextSize = 14
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = Sidebar

local LogoPad = Instance.new("UIPadding")
LogoPad.PaddingLeft = UDim.new(0, 12)
LogoPad.Parent = Logo

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 4)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 50)
SidebarPad.PaddingLeft = UDim.new(0, 8)
SidebarPad.PaddingRight = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

-- ==================== TOP BAR & CONTENT ====================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -180, 0, 40)
TopBar.Position = UDim2.new(0, 180, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Main

local WinBtns = Instance.new("Frame")
WinBtns.Size = UDim2.new(0, 90, 0, 30)
WinBtns.Position = UDim2.new(1, -10, 0.5, -15)
WinBtns.AnchorPoint = Vector2.new(1, 0.5)
WinBtns.BackgroundTransparency = 1
WinBtns.Parent = TopBar

local function MakeWinBtn(text, color, action)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 30, 0, 30)
    b.BackgroundTransparency = 1
    b.Text = text
    b.TextColor3 = color
    b.Font = Enum.Font.Gotham
    b.Parent = WinBtns
    b.MouseButton1Click:Connect(action)
    return b
end

MakeWinBtn("—", Color3.new(1,1,1), function() Main.Visible = false end)
local closeBtn = MakeWinBtn("✕", Color3.fromRGB(255, 60, 60), function() ScreenGui:Destroy() end)

-- Right content pane
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -180, 1, -40)
ContentFrame.Position = UDim2.new(0, 180, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(27, 28, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = Main

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -10, 1, -10)
ContentScroll.Position = UDim2.new(0, 5, 0, 5)
ContentScroll.BackgroundColor3 = Color3.fromRGB(27, 28, 35)
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 4
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
ContentScroll.Parent = ContentFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScroll

local ContentPad = Instance.new("UIPadding")
ContentPad.PaddingTop = UDim.new(0, 5)
ContentPad.PaddingLeft = UDim.new(0, 5)
ContentPad.PaddingRight = UDim.new(0, 5)
ContentPad.Parent = ContentScroll

-- ==================== UI COMPONENTS ====================
local function AddCard(text)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = Color3.fromRGB(33, 35, 45)
    card.BorderSizePixel = 0
    card.Parent = ContentScroll

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local titlePad = Instance.new("UIPadding")
    titlePad.PaddingTop = UDim.new(0, 8)
    titlePad.PaddingLeft = UDim.new(0, 12)
    titlePad.Parent = title

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = card

    return {Card = card, Layout = layout, Pad = pad, Title = title}
end

local function AddToggle(parent, text, key)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = parent.Card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 185, 190)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local isOn = CONFIG[key]
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -48, 0.5, -12)
    track.BackgroundColor3 = isOn and Color3.fromRGB(0, 210, 140) or Color3.fromRGB(70, 70, 80)
    track.BorderSizePixel = 0
    track.Parent = row

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 12)
    tCorner.Parent = track

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = isOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = track

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 9)
    dCorner.Parent = dot

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        CONFIG[key] = not CONFIG[key]
        local newPos = CONFIG[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = newPos}):Play()
        TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG[key] and Color3.fromRGB(0, 210, 140) or Color3.fromRGB(70, 70, 80)}):Play()
    end)
end

local function AddSlider(parent, text, key, min, max)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundTransparency = 1
    row.Parent = parent.Card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 185, 190)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.5, 0, 0, 18)
    valLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(math.floor(CONFIG[key]))
    valLabel.TextColor3 = Color3.fromRGB(180, 185, 190)
    valLabel.TextSize = 12
    valLabel.Font = Enum.Font.Gotham
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row

    local valNorm = math.clamp((CONFIG[key] - min) / (max - min), 0, 1)
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 3)
    track.Position = UDim2.new(0, 0, 1, -8)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    track.BorderSizePixel = 0
    track.Parent = row

    local trCorner = Instance.new("UICorner")
    trCorner.CornerRadius = UDim.new(0, 2)
    trCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(valNorm, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 210, 140)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 2)
    fCorner.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(valNorm, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.Parent = track

    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(0, 6)
    kCorner.Parent = knob

    local dragging = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absX = track.AbsolutePosition.X
            local absW = track.AbsoluteSize.X
            local posX = math.clamp((input.Position.X - absX) / absW, 0, 1)
            local val = math.floor(min + (max - min) * posX)
            CONFIG[key] = val
            valLabel.Text = tostring(val)
            knob.Position = UDim2.new(posX, -6, 0.5, -6)
            fill.Size = UDim2.new(posX, 0, 1, 0)
        end
    end)
end

-- ==================== TAB SYSTEM ====================
local currentTab = "Main"
local function SwitchTab(tabName)
    for _, c in ipairs(ContentScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    if tabName == "Main" then
        local c = AddCard("Core")
        AddToggle(c, "God Mode", "GodMode")
        AddToggle(c, "Auto Day", "AutoDay")
        AddSlider(c, "Day Speed", "AutoDaySpeed", 0.01, 0.5)
    elseif tabName == "Combat" then
        local c = AddCard("Combat")
        AddToggle(c, "Kill Aura", "KillAura")
        AddSlider(c, "Aura Range", "KillAuraRange", 25, 300)
        AddSlider(c, "Aura Speed", "KillAuraSpeed", 0.01, 0.2)
    elseif tabName == "Farming" then
        local c = AddCard("Farming")
        AddToggle(c, "Cut Trees", "CutAllTrees")
        AddToggle(c, "Max Fire", "AutoMaxFire")
        AddToggle(c, "Collect Gems", "AutoCollectGems")
        AddToggle(c, "Save Kids", "AutoSaveAllChildren")
        AddToggle(c, "Open Chests", "AutoOpenChests")
        AddToggle(c, "Auto Bring", "AutoBringAll")
        AddSlider(c, "Bring Distance", "AutoBringDistance", 50, 400)
    elseif tabName == "Movement" then
        local c = AddCard("Movement")
        AddToggle(c, "Fly", "Fly")
        AddSlider(c, "Fly Speed", "FlySpeed", 50, 250)
        AddSlider(c, "Walk Speed", "Speed", 16, 200)
        AddToggle(c, "NoClip", "NoClip")
        AddToggle(c, "Inf. Jump", "InfiniteJump")
    elseif tabName == "Visuals" then
        local c = AddCard("Visuals")
        AddToggle(c, "Fullbright", "Fullbright")
        AddToggle(c, "No Fog", "NoFog")
    end

    task.wait(0.1)
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end

-- ==================== SIDEBAR BUTTONS ====================
local function CreateTabBtn(text, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
    btn.Text = "   " .. icon .. "   " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = btn

    btn.MouseButton1Click:Connect(function()
        currentTab = text
        for _, b in ipairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(33, 35, 45)
        SwitchTab(text)
    end)
    return btn
end

local btnMain = CreateTabBtn("Main", "❯")
CreateTabBtn("Combat", "⚔")
CreateTabBtn("Farming", "🌱")
CreateTabBtn("Movement", "💨")
CreateTabBtn("Visuals", "👁")
btnMain.BackgroundColor3 = Color3.fromRGB(33, 35, 45)
SwitchTab("Main")

-- ==================== DRAGGABLE (MOUSE + TOUCH) ====================
local drag = false, dragStart, startPos
Logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position.X - dragStart.X), startPos.Y.Scale, startPos.Y.Offset + (input.Position.Y - dragStart.Y))
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

-- ==================== FEATURE LOOPS (UNCHANGED) ====================
task.spawn(function()
    while true do
        task.wait(CONFIG.GodModeTickRate)
        if CONFIG.GodMode and humanoid then
            pcall(function()
                humanoid.Health = 0/0
                humanoid.Health = humanoid.MaxHealth
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(CONFIG.AutoDaySpeed or 0.05)
        if CONFIG.AutoDay and Remotes.Sleep then
            pcall(function() Remotes.Sleep:FireServer() end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.08)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, t in ipairs(Utility.GetAllTrees()) do pcall(function() Remotes.Chop:FireServer(t) end) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.12)
        if CONFIG.AutoMaxFire and Remotes.Fuel then
            for _, f in ipairs(Utility.GetFires()) do
                for i=1,3 do pcall(function() Remotes.Fuel:FireServer(f) end) end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.04)
        if CONFIG.AutoCollectGems then
            for _, i in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(i.Position) < 280 then pcall(function() i.CFrame = hrp.CFrame + Vector3.new(0,10,0) end) end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if CONFIG.AutoSaveAllChildren and Remotes.SaveKid then
            for _, k in ipairs(Utility.GetChildren()) do pcall(function() Remotes.SaveKid:FireServer(k) end) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.AutoOpenChests and Remotes.OpenChest then
            for _, c in ipairs(Utility.GetChests()) do pcall(function() Remotes.OpenChest:FireServer(c) end) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.AutoBringAll then
            for _, i in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(i.Position) < CONFIG.AutoBringDistance then
                    pcall(function()
                        i.CFrame = hrp.CFrame + Vector3.new(math.random(-CONFIG.AutoBringRadius, CONFIG.AutoBringRadius), 12, math.random(-CONFIG.AutoBringRadius, CONFIG.AutoBringRadius))
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(CONFIG.KillAuraSpeed or 0.04)
        if CONFIG.KillAura then
            for _, m in ipairs(Utility.GetMonsters()) do
                if Utility.GetDistance(m.HumanoidRootPart.Position) <= CONFIG.KillAuraRange then
                    pcall(function() m.Humanoid.Health = 0 end)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if humanoid then humanoid.WalkSpeed = CONFIG.Speed end
end)

local flyConn
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F then
        CONFIG.Fly = not CONFIG.Fly
        if CONFIG.Fly then
            if hrp then hrp.Anchored = true end
            if not flyConn then
                flyConn = RunService.Heartbeat:Connect(function()
                    if CONFIG.Fly and hrp then
                        local cam = Workspace.CurrentCamera
                        local dir = Vector3.new()
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
                        hrp.Velocity = (dir.Magnitude > 0) and dir.Unit * CONFIG.FlySpeed or Vector3.new()
                    end
                end)
            end
        else
            if hrp then hrp.Anchored = false; hrp.Velocity = Vector3.new() end
            if flyConn then flyConn:Disconnect(); flyConn = nil end
        end
    end
    if inp.KeyCode == Enum.KeyCode.V then CONFIG.NoClip = not CONFIG.NoClip end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.NoClip and character then
            for _, p in pairs(character:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

if CONFIG.Fullbright then Lighting.Brightness = 12; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.new(1,1,1) end
if CONFIG.NoFog then Lighting.FogEnd = 100000 end

-- Anti‑AFK
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

print("✅ 99 NIGHTS – FOXNAME STYLE UI LOADED")
print("💡 Tap the sidebar tabs | Drag top-left logo")
print("🎯 Features: God Mode, Kill Aura, Farming, Fly, NoClip + more")
local function DiscoverRemotes()
    local ok = pcall(function()
        local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
        
        -- Search for remotes with common names
        for _, remote in ipairs(remoteFolder:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                
                if name:find("sleep") or name:find("day") then Remotes.Sleep = remote end
                if name:find("chop") or name:find("tree") then Remotes.Chop = remote end
                if name:find("save") or name:find("kid") then Remotes.SaveKid = remote end
                if name:find("fuel") or name:find("fire") then Remotes.Fuel = remote end
                if name:find("chest") or name:find("open") then Remotes.OpenChest = remote end
                if name:find("craft") then Remotes.Craft = remote end
                if name:find("eat") then Remotes.Eat = remote end
                if name:find("collect") or name:find("item") then Remotes.Collect = remote end
            end
        end
    end)
    return ok
end

DiscoverRemotes()

-- ==================== UTILITY FUNCTIONS ====================
local Utility = {}

-- Smart caching system
Utility._cache = {}
Utility._cacheTTL = 0.3
Utility._lastCacheUpdate = 0

function Utility.GetDistance(pos)
    if not hrp or not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

function Utility.GetCachedEntity(entityType)
    local now = os.clock()
    if Utility._cache[entityType] and (now - Utility._lastCacheUpdate) < Utility._cacheTTL then
        return Utility._cache[entityType]
    end
    return nil
end

function Utility.GetAllTrees()
    local cached = Utility.GetCachedEntity("trees")
    if cached then return cached end
    
    local trees = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("tree") or v:FindFirstChild("Trunk") then
                table.insert(trees, v)
            end
        end
    end
    Utility._cache.trees = trees
    return trees
end

function Utility.GetMonsters()
    local monsters = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v ~= character and not Players:GetPlayerFromCharacter(v) then
                table.insert(monsters, v)
            end
        end
    end
    return monsters
end

function Utility.GetChildren()
    local kids = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("kid") or nm:find("child") or nm:find("lost") then
                if v:FindFirstChild("HumanoidRootPart") then
                    table.insert(kids, v)
                end
            end
        end
    end
    return kids
end

function Utility.GetChests()
    local chests = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local nm = v.Name:lower()
            if nm:find("chest") or nm:find("crate") or nm:find("box") then
                table.insert(chests, v)
            end
        end
    end
    return chests
end

function Utility.GetFires()
    local fires = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("fire") or nm:find("bonfire") or nm:find("camp") then
                table.insert(fires, v)
            end
        end
    end
    return fires
end

function Utility.GetCollectibles()
    local items = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("log") or n:find("wood") or n:find("gem") or n:find("item") 
               or n:find("drop") or n:find("coal") or n:find("stone") or n:find("resource") then
                table.insert(items, v)
            end
        end
    end
    return items
end

-- ==================== UI SYSTEM ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99V11"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Auto‑scale for mobile (based on screen height)
local viewportSize = Workspace.CurrentCamera.ViewportSize
local scaleFactor = math.min(1, (viewportSize.Y / 800) * 0.9)  -- shrink on small screens

local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 520, 0, 700)
MainContainer.Position = UDim2.new(1, -540, 1, -730)
MainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainContainer.BorderSizePixel = 0
MainContainer.Parent = ScreenGui

-- UIScale for responsive sizing
local UIScale = Instance.new("UIScale")
UIScale.Scale = scaleFactor
UIScale.Parent = MainContainer

-- Border/Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 220, 160)
Stroke.Thickness = 2.5
Stroke.Parent = MainContainer

-- Corner Radius
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainContainer

-- ==================== TOP BAR ====================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainContainer

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 16)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎮 99 NIGHTS v11.0"
TitleLabel.TextColor3 = Color3.new(0, 0, 0)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local VersionBadge = Instance.new("TextLabel")
VersionBadge.Size = UDim2.new(0, 65, 0, 28)
VersionBadge.Position = UDim2.new(1, -75, 0.5, -14)
VersionBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VersionBadge.BorderSizePixel = 0
VersionBadge.Text = "OPUS"
VersionBadge.TextColor3 = Color3.fromRGB(0, 220, 160)
VersionBadge.TextSize = 11
VersionBadge.Font = Enum.Font.GothamBold
VersionBadge.Parent = TopBar

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0, 6)
VersionCorner.Parent = VersionBadge

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
end)

-- ==================== CONTENT AREA ====================
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, 0, 1, -50)
ContentScroll.Position = UDim2.new(0, 0, 0, 50)
ContentScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 8
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 220, 160)
ContentScroll.Parent = MainContainer

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 10)
ContentList.Parent = ContentScroll

-- ==================== UI BUILDERS ====================
local function CreateToggle(text, configKey, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 48)
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    container.BorderSizePixel = 0
    container.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 32)
    btn.Position = UDim2.new(1, -75, 0.5, -16)
    btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 220, 160) or Color3.fromRGB(90, 90, 110)
    btn.BorderSizePixel = 0
    btn.Text = CONFIG[configKey] and "ON" or "OFF"
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 220, 160) or Color3.fromRGB(90, 90, 110)
        btn.Text = CONFIG[configKey] and "ON" or "OFF"
    end)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(110, 110, 130)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 220, 160) or Color3.fromRGB(90, 90, 110)
    end)
end

local function CreateSlider(text, configKey, min, max, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 72)
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    container.BorderSizePixel = 0
    container.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -62, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(CONFIG[configKey]))
    valueLabel.TextColor3 = Color3.fromRGB(0, 220, 160)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 8)
    sliderBg.Position = UDim2.new(0, 12, 0, 38)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((CONFIG[configKey] - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 16, 0, 20)
    slider.Position = UDim2.new(math.clamp((CONFIG[configKey] - min) / (max - min), 0, 1), -8, 0.5, -10)
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = sliderBg
    
    local sliderCorner2 = Instance.new("UICorner")
    sliderCorner2.CornerRadius = UDim.new(0, 4)
    sliderCorner2.Parent = slider
    
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
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            CONFIG[configKey] = val
            slider.Position = UDim2.new(pos, -8, 0.5, -10)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(val)
        end
    end)
end

local function CreateSeparator(text)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -16, 0, 35)
    sep.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
    sep.BorderSizePixel = 0
    sep.Parent = ContentScroll
    
    local sepCorner = Instance.new("UICorner")
    sepCorner.CornerRadius = UDim.new(0, 8)
    sepCorner.Parent = sep
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "⚙ " .. text
    label.TextColor3 = Color3.new(0, 0, 0)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = sep
end

-- ==================== POPULATE UI ====================
CreateSeparator("CORE FEATURES")
CreateToggle("God Mode", "GodMode", "❤️")
CreateToggle("Auto Day", "AutoDay", "☀️")
CreateSlider("Day Speed", "AutoDaySpeed", 0.01, 0.5, "⏱️")

CreateSeparator("COMBAT")
CreateToggle("Kill Aura", "KillAura", "⚔️")
CreateSlider("Aura Range", "KillAuraRange", 25, 300, "📏")
CreateSlider("Aura Speed", "KillAuraSpeed", 0.01, 0.2, "⚡")

CreateSeparator("FARMING")
CreateToggle("Cut Trees", "CutAllTrees", "🌲")
CreateToggle("Max Fire", "AutoMaxFire", "🔥")
CreateToggle("Auto Gems", "AutoCraftGems", "💎")
CreateToggle("Collect Gems", "AutoCollectGems", "📦")
CreateToggle("Save Kids", "AutoSaveAllChildren", "👶")
CreateToggle("Open Chests", "AutoOpenChests", "🎁")
CreateToggle("Auto Bring", "AutoBringAll", "🎯")
CreateSlider("Bring Distance", "AutoBringDistance", 50, 400, "📍")

CreateSeparator("MOVEMENT")
CreateToggle("Fly", "Fly", "🚀")
CreateSlider("Fly Speed", "FlySpeed", 50, 250, "💨")
CreateSlider("Walk Speed", "Speed", 16, 200, "🏃")
CreateToggle("NoClip", "NoClip", "👻")
CreateToggle("Inf. Jump", "InfiniteJump", "⬆️")

CreateSeparator("VISUALS")
CreateToggle("Fullbright", "Fullbright", "💡")
CreateToggle("No Fog", "NoFog", "👁️")

-- Update canvas size
ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
end)

-- ==================== FEATURE LOOPS ====================

-- GOD MODE (FIXED – uses NaN for invulnerability)
task.spawn(function()
    while true do
        task.wait(CONFIG.GodModeTickRate)
        if CONFIG.GodMode and humanoid then
            pcall(function()
                -- New meta: 0/0 = NaN (invulnerable)
                humanoid.Health = 0/0
                -- Backup: set to max health (in case NaN doesn't stick)
                humanoid.Health = humanoid.MaxHealth
            end)
        end
    end
end)

-- AUTO DAY
task.spawn(function()
    while true do
        task.wait(CONFIG.AutoDaySpeed or 0.05)
        if CONFIG.AutoDay and Remotes.Sleep then
            pcall(function()
                Remotes.Sleep:FireServer()
            end)
        end
    end
end)

-- CUT ALL TREES
task.spawn(function()
    while true do
        task.wait(0.08)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, tree in ipairs(Utility.GetAllTrees()) do
                pcall(function()
                    Remotes.Chop:FireServer(tree)
                end)
            end
        end
    end
end)

-- AUTO MAX FIRE
task.spawn(function()
    while true do
        task.wait(0.12)
        if CONFIG.AutoMaxFire and Remotes.Fuel then
            for _, fire in ipairs(Utility.GetFires()) do
                for i = 1, 3 do
                    pcall(function()
                        Remotes.Fuel:FireServer(fire)
                    end)
                end
            end
        end
    end
end)

-- AUTO COLLECT GEMS
task.spawn(function()
    while true do
        task.wait(0.04)
        if CONFIG.AutoCollectGems then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) < 280 then
                    pcall(function()
                        item.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
                    end)
                end
            end
        end
    end
end)

-- SAVE CHILDREN
task.spawn(function()
    while true do
        task.wait(0.15)
        if CONFIG.AutoSaveAllChildren and Remotes.SaveKid then
            for _, kid in ipairs(Utility.GetChildren()) do
                pcall(function()
                    Remotes.SaveKid:FireServer(kid)
                end)
            end
        end
    end
end)

-- OPEN CHESTS
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.AutoOpenChests and Remotes.OpenChest then
            for _, chest in ipairs(Utility.GetChests()) do
                pcall(function()
                    Remotes.OpenChest:FireServer(chest)
                end)
            end
        end
    end
end)

-- AUTO BRING
task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.AutoBringAll then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) < CONFIG.AutoBringDistance then
                    pcall(function()
                        item.CFrame = hrp.CFrame + Vector3.new(
                            math.random(-CONFIG.AutoBringRadius, CONFIG.AutoBringRadius),
                            12,
                            math.random(-CONFIG.AutoBringRadius, CONFIG.AutoBringRadius)
                        )
                    end)
                end
            end
        end
    end
end)

-- KILL AURA
task.spawn(function()
    while true do
        task.wait(CONFIG.KillAuraSpeed or 0.04)
        if CONFIG.KillAura then
            for _, mob in ipairs(Utility.GetMonsters()) do
                if Utility.GetDistance(mob.HumanoidRootPart.Position) <= CONFIG.KillAuraRange then
                    pcall(function()
                        mob.Humanoid.Health = 0
                    end)
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
end)

-- FLY SYSTEM
local flyConnection = nil
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
                        local camera = Workspace.CurrentCamera
                        local direction = Vector3.new(0, 0, 0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end
                        
                        if direction.Magnitude > 0 then
                            hrp.Velocity = direction.Unit * CONFIG.FlySpeed
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
        task.wait(0.1)
        if CONFIG.NoClip and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.CanCollide = false
                    end)
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

-- FULLBRIGHT
if CONFIG.Fullbright then
    Lighting.Brightness = 12
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
end

if CONFIG.NoFog then
    Lighting.FogEnd = 100000
end

-- ==================== DRAGGABLE UI (MOUSE + TOUCH) ====================
local dragging = false
local dragStart = nil
local startPos = nil

-- Helper function to handle drag start
local function onDragStart(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
    end
end

-- Helper function to handle drag move
local function onDragMove(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

-- Helper function to handle drag end
local function onDragEnd(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end

-- Connect events
TopBar.InputBegan:Connect(onDragStart)
UserInputService.InputChanged:Connect(onDragMove)
UserInputService.InputEnded:Connect(onDragEnd)

-- ==================== ANTI-AFK ====================
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- ==================== STARTUP ====================
print("✅ 99 NIGHTS ULTIMATE v11.0 OPUS - LOADED")
print("📍 F = Fly (desktop) | V = NoClip (desktop)")
print("📱 On mobile: toggle Fly/NoClip from the UI")
print("🎯 All features optimized with Claude 3.7 Opus")-- ==================== REMOTES DISCOVERY ====================
local Remotes = {}

local function DiscoverRemotes()
    local ok = pcall(function()
        local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
        
        -- Search for remotes with common names
        for _, remote in ipairs(remoteFolder:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                
                if name:find("sleep") or name:find("day") then Remotes.Sleep = remote end
                if name:find("chop") or name:find("tree") then Remotes.Chop = remote end
                if name:find("save") or name:find("kid") then Remotes.SaveKid = remote end
                if name:find("fuel") or name:find("fire") then Remotes.Fuel = remote end
                if name:find("chest") or name:find("open") then Remotes.OpenChest = remote end
                if name:find("craft") then Remotes.Craft = remote end
                if name:find("eat") then Remotes.Eat = remote end
                if name:find("collect") or name:find("item") then Remotes.Collect = remote end
            end
        end
    end)
    return ok
end

DiscoverRemotes()

-- ==================== UTILITY FUNCTIONS ====================
local Utility = {}

-- Smart caching system
Utility._cache = {}
Utility._cacheTTL = 0.3
Utility._lastCacheUpdate = 0

function Utility.GetDistance(pos)
    if not hrp or not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

function Utility.GetCachedEntity(entityType)
    local now = os.clock()
    if Utility._cache[entityType] and (now - Utility._lastCacheUpdate) < Utility._cacheTTL then
        return Utility._cache[entityType]
    end
    return nil
end

function Utility.GetAllTrees()
    local cached = Utility.GetCachedEntity("trees")
    if cached then return cached end
    
    local trees = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("tree") or v:FindFirstChild("Trunk") then
                table.insert(trees, v)
            end
        end
    end
    Utility._cache.trees = trees
    return trees
end

function Utility.GetMonsters()
    local monsters = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v ~= character and not Players:GetPlayerFromCharacter(v) then
                table.insert(monsters, v)
            end
        end
    end
    return monsters
end

function Utility.GetChildren()
    local kids = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("kid") or nm:find("child") or nm:find("lost") then
                if v:FindFirstChild("HumanoidRootPart") then
                    table.insert(kids, v)
                end
            end
        end
    end
    return kids
end

function Utility.GetChests()
    local chests = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local nm = v.Name:lower()
            if nm:find("chest") or nm:find("crate") or nm:find("box") then
                table.insert(chests, v)
            end
        end
    end
    return chests
end

function Utility.GetFires()
    local fires = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local nm = v.Name:lower()
            if nm:find("fire") or nm:find("bonfire") or nm:find("camp") then
                table.insert(fires, v)
            end
        end
    end
    return fires
end

function Utility.GetCollectibles()
    local items = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("log") or n:find("wood") or n:find("gem") or n:find("item") 
               or n:find("drop") or n:find("coal") or n:find("stone") or n:find("resource") then
                table.insert(items, v)
            end
        end
    end
    return items
end

-- ==================== UI SYSTEM ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99V11"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 520, 0, 700)
MainContainer.Position = UDim2.new(1, -540, 1, -730)
MainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainContainer.BorderSizePixel = 0
MainContainer.Parent = ScreenGui

-- Border/Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 220, 160)
Stroke.Thickness = 2.5
Stroke.Parent = MainContainer

-- Corner Radius
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainContainer

-- ==================== TOP BAR ====================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainContainer

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 16)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎮 99 NIGHTS v11.0"
TitleLabel.TextColor3 = Color3.new(0, 0, 0)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local VersionBadge = Instance.new("TextLabel")
VersionBadge.Size = UDim2.new(0, 65, 0, 28)
VersionBadge.Position = UDim2.new(1, -75, 0.5, -14)
VersionBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VersionBadge.BorderSizePixel = 0
VersionBadge.Text = "OPUS"
VersionBadge.TextColor3 = Color3.fromRGB(0, 220, 160)
VersionBadge.TextSize = 11
VersionBadge.Font = Enum.Font.GothamBold
VersionBadge.Parent = TopBar

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0, 6)
VersionCorner.Parent = VersionBadge

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
end)

-- ==================== CONTENT AREA ====================
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, 0, 1, -50)
ContentScroll.Position = UDim2.new(0, 0, 0, 50)
ContentScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 8
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 220, 160)
ContentScroll.Parent = MainContainer

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 10)
ContentList.Parent = ContentScroll

-- ==================== UI BUILDERS ====================
local function CreateToggle(text, configKey, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 48)
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    container.BorderSizePixel = 0
    container.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 32)
    btn.Position = UDim2.new(1, -75, 0.5, -16)
    btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 220, 160) or Color3.fromRGB(90, 90, 110)
    btn.BorderSizePixel = 0
    btn.Text = CONFIG[configKey] and "ON" or "OFF"
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 220, 160) or Color3.fromRGB(90, 90, 110)
        btn.Text = CONFIG[configKey] and "ON" or "OFF"
    end)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(110, 110, 130)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(0, 220, 160) or Color3.fromRGB(90, 90, 110)
    end)
end

local function CreateSlider(text, configKey, min, max, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 72)
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    container.BorderSizePixel = 0
    container.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -62, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(CONFIG[configKey]))
    valueLabel.TextColor3 = Color3.fromRGB(0, 220, 160)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 8)
    sliderBg.Position = UDim2.new(0, 12, 0, 38)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((CONFIG[configKey] - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 16, 0, 20)
    slider.Position = UDim2.new(math.clamp((CONFIG[configKey] - min) / (max - min), 0, 1), -8, 0.5, -10)
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = sliderBg
    
    local sliderCorner2 = Instance.new("UICorner")
    sliderCorner2.CornerRadius = UDim.new(0, 4)
    sliderCorner2.Parent = slider
    
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
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            CONFIG[configKey] = val
            slider.Position = UDim2.new(pos, -8, 0.5, -10)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(val)
        end
    end)
end

local function CreateSeparator(text)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -16, 0, 35)
    sep.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
    sep.BorderSizePixel = 0
    sep.Parent = ContentScroll
    
    local sepCorner = Instance.new("UICorner")
    sepCorner.CornerRadius = UDim.new(0, 8)
    sepCorner.Parent = sep
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "⚙ " .. text
    label.TextColor3 = Color3.new(0, 0, 0)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = sep
end

-- ==================== POPULATE UI ====================
CreateSeparator("CORE FEATURES")
CreateToggle("God Mode", "GodMode", "❤️")
CreateToggle("Auto Day", "AutoDay", "☀️")
CreateSlider("Day Speed", "AutoDaySpeed", 0.01, 0.5, "⏱️")

CreateSeparator("COMBAT")
CreateToggle("Kill Aura", "KillAura", "⚔️")
CreateSlider("Aura Range", "KillAuraRange", 25, 300, "📏")
CreateSlider("Aura Speed", "KillAuraSpeed", 0.01, 0.2, "⚡")

CreateSeparator("FARMING")
CreateToggle("Cut Trees", "CutAllTrees", "🌲")
CreateToggle("Max Fire", "AutoMaxFire", "🔥")
CreateToggle("Auto Gems", "AutoCraftGems", "💎")
CreateToggle("Collect Gems", "AutoCollectGems", "📦")
CreateToggle("Save Kids", "AutoSaveAllChildren", "👶")
CreateToggle("Open Chests", "AutoOpenChests", "🎁")
CreateToggle("Auto Bring", "AutoBringAll", "🎯")
CreateSlider("Bring Distance", "AutoBringDistance", 50, 400, "📍")

CreateSeparator("MOVEMENT")
CreateToggle("Fly", "Fly", "🚀")
CreateSlider("Fly Speed", "FlySpeed", 50, 250, "💨")
CreateSlider("Walk Speed", "Speed", 16, 200, "🏃")
CreateToggle("NoClip", "NoClip", "👻")
CreateToggle("Inf. Jump", "InfiniteJump", "⬆️")

CreateSeparator("VISUALS")
CreateToggle("Fullbright", "Fullbright", "💡")
CreateToggle("No Fog", "NoFog", "👁️")

-- Update canvas size
ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
end)

-- ==================== FEATURE LOOPS ====================

-- GOD MODE
task.spawn(function()
    while true do
        task.wait(CONFIG.GodModeTickRate)
        if CONFIG.GodMode and humanoid then
            pcall(function()
                humanoid.Health = humanoid.MaxHealth
            end)
        end
    end
end)

-- AUTO DAY
task.spawn(function()
    while true do
        task.wait(CONFIG.AutoDaySpeed or 0.05)
        if CONFIG.AutoDay and Remotes.Sleep then
            pcall(function()
                Remotes.Sleep:FireServer()
            end)
        end
    end
end)

-- CUT ALL TREES
task.spawn(function()
    while true do
        task.wait(0.08)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, tree in ipairs(Utility.GetAllTrees()) do
                pcall(function()
                    Remotes.Chop:FireServer(tree)
                end)
            end
        end
    end
end)

-- AUTO MAX FIRE
task.spawn(function()
    while true do
        task.wait(0.12)
        if CONFIG.AutoMaxFire and Remotes.Fuel then
            for _, fire in ipairs(Utility.GetFires()) do
                for i = 1, 3 do
                    pcall(function()
                        Remotes.Fuel:FireServer(fire)
                    end)
                end
            end
        end
    end
end)

-- AUTO COLLECT GEMS
task.spawn(function()
    while true do
        task.wait(0.04)
        if CONFIG.AutoCollectGems then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) < 280 then
                    pcall(function()
                        item.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
                    end)
                end
            end
        end
    end
end)

-- SAVE CHILDREN
task.spawn(function()
    while true do
        task.wait(0.15)
        if CONFIG.AutoSaveAllChildren and Remotes.SaveKid then
            for _, kid in ipairs(Utility.GetChildren()) do
                pcall(function()
                    Remotes.SaveKid:FireServer(kid)
                end)
            end
        end
    end
end)

-- OPEN CHESTS
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.AutoOpenChests and Remotes.OpenChest then
            for _, chest in ipairs(Utility.GetChests()) do
                pcall(function()
                    Remotes.OpenChest:FireServer(chest)
                end)
            end
        end
    end
end)

-- AUTO BRING
task.spawn(function()
    while true do
        task.wait(0.05)
        if CONFIG.AutoBringAll then
            for _, item in ipairs(Utility.GetCollectibles()) do
                if Utility.GetDistance(item.Position) < CONFIG.AutoBringDistance then
                    pcall(function()
                        item.CFrame = hrp.CFrame + Vector3.new(
                            math.random(-CONFIG.AutoBringRadius, CONFIG.AutoBringRadius),
                            12,
                            math.random(-CONFIG.AutoBringRadius, CONFIG.AutoBringRadius)
                        )
                    end)
                end
            end
        end
    end
end)

-- KILL AURA
task.spawn(function()
    while true do
        task.wait(CONFIG.KillAuraSpeed or 0.04)
        if CONFIG.KillAura then
            for _, mob in ipairs(Utility.GetMonsters()) do
                if Utility.GetDistance(mob.HumanoidRootPart.Position) <= CONFIG.KillAuraRange then
                    pcall(function()
                        mob.Humanoid.Health = 0
                    end)
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
end)

-- FLY SYSTEM
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
                        local camera = Workspace.CurrentCamera
                        local direction = Vector3.new(0, 0, 0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end
                        
                        if direction.Magnitude > 0 then
                            hrp.Velocity = direction.Unit * CONFIG.FlySpeed
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
                    pcall(function()
                        part.CanCollide = false
                    end)
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

-- FULLBRIGHT
if CONFIG.Fullbright then
    Lighting.Brightness = 12
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
end

if CONFIG.NoFog then
    Lighting.FogEnd = 100000
end

-- ==================== DRAGGABLE UI ====================
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

-- ==================== ANTI-AFK ====================
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- ==================== STARTUP ====================
print("✅ 99 NIGHTS ULTIMATE v11.0 OPUS - LOADED")
print("📍 F = Fly | V = NoClip | Drag Title Bar = Move UI")
print("🎯 All features optimized with Claude 3.7 Opus")

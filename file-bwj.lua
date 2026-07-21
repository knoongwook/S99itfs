--[[
    99 NIGHTS IN THE FOREST - ULTIMATE POWER SCRIPT
    Version: 6.9
    Features: Auto Day, Kill Aura, ESP, Teleport, Bring All, God Mode, Auto Farm Everything
    UI: Modern, Smooth, Draggable, Animated
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

--// CONFIGURATION SYSTEM
local CONFIG = {
    -- Combat
    KillAura = false,
    KillAuraRange = 50,
    KillAuraSpeed = 0.05,
    InstantKill = false,
    GodMode = false,
    AntiRagdoll = false,
    
    -- Automation Core
    AutoDay = false,
    AutoDaySpeed = 0.1,
    AutoSaveKids = false,
    AutoCollectDrops = false,
    AutoFarmDiamonds = false,
    AutoOpenChests = false,
    AutoChopTrees = false,
    AutoEat = false,
    AutoCraft = false,
    AutoFuelFire = false,
    
    -- ESP
    ESP = {
        Enabled = false,
        Players = false,
        Monsters = false,
        Items = false,
        Chests = false,
        Kids = false,
        Deer = false,
        Distance = 2000,
        Tracers = false,
        Boxes = true,
        Names = true,
        Health = true
    },
    
    -- Movement
    SpeedBoost = false,
    SpeedValue = 100,
    Fly = false,
    FlySpeed = 80,
    NoClip = false,
    InfiniteJump = false,
    AutoSprint = true,
    
    -- Visual
    Fullbright = false,
    NoFog = false,
    XRay = false,
    
    -- Teleport
    AutoTeleport = false,
    TeleportSpeed = 50
}

--// SERVICES & REMOTES
local Remotes = {
    Sleep = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Sleep"),
    Eat = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Eat"),
    Damage = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Damage"),
    Collect = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CollectItem"),
    Chop = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ChopTree"),
    OpenChest = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("OpenChest"),
    SaveKid = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SaveKid")
}

--// UTILITY FUNCTIONS
local Utility = {}

function Utility.Notify(title, text, duration)
    duration = duration or 3
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "Notification"
    notifyGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(1, -320, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Parent = notifyGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 25)
    textLabel.Position = UDim2.new(0, 10, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 150)
    stroke.Thickness = 1
    stroke.Parent = frame
    
    TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(1, -320, 1, -80)}):Play()
    
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(1, 20, 1, -80)}):Play()
        task.wait(0.5)
        notifyGui:Destroy()
    end)
end

function Utility.GetDistance(pos)
    return (hrp.Position - pos).Magnitude
end

function Utility.TweenTo(pos, speed)
    local distance = Utility.GetDistance(pos)
    local time = distance / speed
    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    return tween
end

function Utility.GetAllItems()
    local items = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            local name = v.Name:lower()
            if name:find("item") or name:find("drop") or name:find("loot") or 
               name:find("berry") or name:find("mushroom") or name:find("meat") or
               name:find("wood") or name:find("stone") or name:find("coal") or
               name:find("scrap") or name:find("diamond") or name:find("gem") then
                table.insert(items, v)
            end
        end
    end
    return items
end

function Utility.GetMonsters()
    local monsters = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v ~= character and not Players:GetPlayerFromCharacter(v) then
                table.insert(monsters, v)
            end
        end
    end
    return monsters
end

function Utility.GetKids()
    local kids = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("kid") or v.Name:lower():find("child") or v.Name:lower():find("lost")) then
            if v:FindFirstChild("HumanoidRootPart") then
                table.insert(kids, v)
            end
        end
    end
    return kids
end

function Utility.GetChests()
    local chests = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            if v.Name:lower():find("chest") or v.Name:lower():find("crate") then
                table.insert(chests, v)
            end
        end
    end
    return chests
end

function Utility.GetTrees()
    local trees = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("tree") then
            table.insert(trees, v)
        end
    end
    return trees
end

--// ESP SYSTEM
local ESP = {}
ESP.Connections = {}
ESP.Drawings = {}

function ESP.CreateDrawing(type, props)
    local drawing = Drawing.new(type)
    for k, v in pairs(props) do
        drawing[k] = v
    end
    return drawing
end

function ESP.AddEntity(entity, type, color)
    if ESP.Drawings[entity] then return end
    
    ESP.Drawings[entity] = {
        Box = ESP.CreateDrawing("Square", {
            Visible = false,
            Thickness = 1,
            Color = color,
            Filled = false,
            Transparency = 1
        }),
        Name = ESP.CreateDrawing("Text", {
            Visible = false,
            Text = entity.Name,
            Size = 13,
            Center = true,
            Outline = true,
            Color = Color3.new(1, 1, 1),
            Transparency = 1
        }),
        Health = ESP.CreateDrawing("Text", {
            Visible = false,
            Text = "",
            Size = 11,
            Center = true,
            Outline = true,
            Color = Color3.new(1, 0, 0),
            Transparency = 1
        }),
        Tracer = ESP.CreateDrawing("Line", {
            Visible = false,
            Thickness = 1,
            Color = color,
            Transparency = 0.5
        }),
        Type = type,
        Entity = entity
    }
end

function ESP.RemoveEntity(entity)
    if ESP.Drawings[entity] then
        for _, drawing in pairs(ESP.Drawings[entity]) do
            if typeof(drawing) == "table" and drawing.Remove then
                drawing:Remove()
            end
        end
        ESP.Drawings[entity] = nil
    end
end

function ESP.Update()
    if not CONFIG.ESP.Enabled then
        for _, drawings in pairs(ESP.Drawings) do
            for _, drawing in pairs(drawings) do
                if typeof(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
        end
        return
    end
    
    local camera = Workspace.CurrentCamera
    local centerScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    
    for entity, drawings in pairs(ESP.Drawings) do
        local shouldShow = false
        
        if CONFIG.ESP.Players and drawings.Type == "Player" then shouldShow = true end
        if CONFIG.ESP.Monsters and drawings.Type == "Monster" then shouldShow = true end
        if CONFIG.ESP.Items and drawings.Type == "Item" then shouldShow = true end
        if CONFIG.ESP.Chests and drawings.Type == "Chest" then shouldShow = true end
        if CONFIG.ESP.Kids and drawings.Type == "Kid" then shouldShow = true end
        
        if shouldShow and entity and entity.Parent then
            local pos, onScreen
            local hrp = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("Torso") or entity:FindFirstChildOfClass("Part")
            
            if hrp then
                pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                local distance = Utility.GetDistance(hrp.Position)
                
                if onScreen and distance <= CONFIG.ESP.Distance then
                    local size = math.clamp(1000 / distance, 10, 100)
                    local x, y = pos.X, pos.Y
                    
                    -- Box
                    if CONFIG.ESP.Boxes then
                        drawings.Box.Size = Vector2.new(size, size * 1.5)
                        drawings.Box.Position = Vector2.new(x - size/2, y - size*0.75)
                        drawings.Box.Visible = true
                    else
                        drawings.Box.Visible = false
                    end
                    
                    -- Name
                    if CONFIG.ESP.Names then
                        drawings.Name.Position = Vector2.new(x, y - size)
                        drawings.Name.Visible = true
                    else
                        drawings.Name.Visible = false
                    end
                    
                    -- Health
                    if CONFIG.ESP.Health and entity:FindFirstChild("Humanoid") then
                        drawings.Health.Text = math.floor(entity.Humanoid.Health) .. "/" .. math.floor(entity.Humanoid.MaxHealth)
                        drawings.Health.Position = Vector2.new(x, y + size * 0.8)
                        drawings.Health.Visible = true
                    else
                        drawings.Health.Visible = false
                    end
                    
                    -- Tracer
                    if CONFIG.ESP.Tracers then
                        drawings.Tracer.From = centerScreen
                        drawings.Tracer.To = Vector2.new(x, y)
                        drawings.Tracer.Visible = true
                    else
                        drawings.Tracer.Visible = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                    drawings.Health.Visible = false
                    drawings.Tracer.Visible = false
                end
            end
        else
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.Health.Visible = false
            drawings.Tracer.Visible = false
        end
    end
end

--// UI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99NightsV2"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 150)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "99 NIGHTS - ULTIMATE"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Size = UDim2.new(0.5, 0, 0.5, 0)
Subtitle.Position = UDim2.new(0, 15, 0.5, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "POWERED BY VOID + COBRA + SPEED"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 10
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "Minimize"
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -80, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "Tabs"
TabContainer.Size = UDim2.new(0, 130, 1, -55)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 8)
TabCorner.Parent = TabContainer

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "Content"
ContentContainer.Size = UDim2.new(1, -150, 1, -55)
ContentContainer.Position = UDim2.new(0, 145, 0, 50)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentContainer

--// TAB SYSTEM
local Tabs = {}
local CurrentTab = nil

local TabList = {
    {Name = "Main", Icon = "⚡"},
    {Name = "Combat", Icon = "⚔️"},
    {Name = "Farm", Icon = "🌾"},
    {Name = "ESP", Icon = "👁️"},
    {Name = "TP", Icon = "🚀"},
    {Name = "Visual", Icon = "👀"}
}

-- Create Tab Buttons
for i, tabInfo in ipairs(TabList) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabInfo.Name
    TabBtn.Size = UDim2.new(1, -10, 0, 40)
    TabBtn.Position = UDim2.new(0, 5, 0, (i-1) * 45 + 5)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TabBtn.Text = tabInfo.Icon .. " " .. tabInfo.Name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Parent = TabContainer
    
    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabBtn
    
    -- Tab Content
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = tabInfo.Name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
    TabContent.Visible = false
    TabContent.Parent = ContentContainer
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.Parent = TabContent
    
    Tabs[tabInfo.Name] = {
        Button = TabBtn,
        Content = TabContent
    }
    
    TabBtn.MouseButton1Click:Connect(function()
        if CurrentTab then
            Tabs[CurrentTab].Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            Tabs[CurrentTab].Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            Tabs[CurrentTab].Content.Visible = false
        end
        
        CurrentTab = tabInfo.Name
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        TabContent.Visible = true
    end)
end

--// TOGGLE CREATION FUNCTION
local function CreateToggle(parent, text, configKey, subKey, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.95, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleFrame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 60, 0, 28)
    ToggleBtn.Position = UDim2.new(1, -70, 0.5, -14)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 14)
    ToggleCorner.Parent = ToggleBtn
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 22, 0, 22)
    Circle.Position = UDim2.new(0, 3, 0.5, -11)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = ToggleBtn
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    local isOn = subKey and CONFIG[configKey][subKey] or CONFIG[configKey]
    
    local function UpdateToggle()
        if isOn then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -25, 0.5, -11)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -11)}):Play()
        end
    end
    
    UpdateToggle()
    
    ToggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if subKey then
            CONFIG[configKey][subKey] = isOn
        else
            CONFIG[configKey] = isOn
        end
        UpdateToggle()
        if callback then callback(isOn) end
    end)
    
    return ToggleFrame
end

--// SLIDER CREATION FUNCTION
local function CreateSlider(parent, text, configKey, min, max, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.95, 0, 0, 70)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SliderFrame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, -10, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(CONFIG[configKey])
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(0.95, 0, 0, 8)
    SliderBG.Position = UDim2.new(0.025, 0, 0, 45)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = SliderFrame
    
    local SliderBGCorner = Instance.new("UICorner")
    SliderBGCorner.CornerRadius = UDim.new(0, 4)
    SliderBGCorner.Parent = SliderBG
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((CONFIG[configKey] - min) / (max - min), 1, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 4)
    SliderFillCorner.Parent = SliderFill
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 16, 0, 16)
    SliderBtn.Position = UDim2.new((CONFIG[configKey] - min) / (max - min), -8, 0.5, -8)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderBtn.Text = ""
    SliderBtn.Parent = SliderBG
    
    local SliderBtnCorner = Instance.new("UICorner")
    SliderBtnCorner.CornerRadius = UDim.new(1, 0)
    SliderBtnCorner.Parent = SliderBtn
    
    local dragging = false
    
    SliderBtn.InputBegan:Connect(function(input)
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
            local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            CONFIG[configKey] = value
            ValueLabel.Text = tostring(value)
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            SliderBtn.Position = UDim2.new(pos, -8, 0.5, -8)
            if callback then callback(value) end
        end
    end)
    
    return SliderFrame
end

--// BUTTON CREATION FUNCTION
local function CreateButton(parent, text, callback)
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(0.95, 0, 0, 45)
    BtnFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    BtnFrame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = BtnFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Position = UDim2.new(0, 10, 0.5, -17)
    Button.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(0, 0, 0)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = BtnFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return BtnFrame
end

--// POPULATE TABS

-- MAIN TAB
CreateToggle(Tabs.Main.Content, "Auto Day (Fastest 99 Nights)", "AutoDay")
CreateSlider(Tabs.Main.Content, "Auto Day Speed", "AutoDaySpeed", 0.01, 1)
CreateToggle(Tabs.Main.Content, "Auto Save Kids", "AutoSaveKids")
CreateToggle(Tabs.Main.Content, "Auto Collect Drops", "AutoCollectDrops")
CreateToggle(Tabs.Main.Content, "Auto Farm Diamonds", "AutoFarmDiamonds")
CreateToggle(Tabs.Main.Content, "Auto Open Chests", "AutoOpenChests")
CreateButton(Tabs.Main.Content, "BRING ALL ITEMS", function()
    for _, item in pairs(Utility.GetAllItems()) do
        pcall(function() item.CFrame = hrp.CFrame end)
    end
    Utility.Notify("Success", "All items brought to you!")
end)

-- COMBAT TAB
CreateToggle(Tabs.Combat.Content, "Kill Aura", "KillAura")
CreateSlider(Tabs.Combat.Content, "Kill Aura Range", "KillAuraRange", 10, 100)
CreateSlider(Tabs.Combat.Content, "Kill Aura Speed", "KillAuraSpeed", 0.01, 0.5)
CreateToggle(Tabs.Combat.Content, "Instant Kill", "InstantKill")
CreateToggle(Tabs.Combat.Content, "God Mode", "GodMode")
CreateToggle(Tabs.Combat.Content, "Anti Ragdoll", "AntiRagdoll")

-- FARM TAB
CreateToggle(Tabs.Farm.Content, "Auto Chop Trees", "AutoChopTrees")
CreateToggle(Tabs.Farm.Content, "Auto Eat (No Hunger)", "AutoEat")
CreateToggle(Tabs.Farm.Content, "Auto Craft", "AutoCraft")
CreateToggle(Tabs.Farm.Content, "Auto Fuel Fire", "AutoFuelFire")
CreateButton(Tabs.Farm.Content, "COLLECT ALL RESOURCES", function()
    for _, item in pairs(Utility.GetAllItems()) do
        if Utility.GetDistance(item.Position) <= 50 then
            pcall(function() item.CFrame = hrp.CFrame end)
        end
    end
end)

-- ESP TAB
CreateToggle(Tabs.ESP.Content, "Master ESP Switch", "ESP", "Enabled")
CreateToggle(Tabs.ESP.Content, "Show Players", "ESP", "Players")
CreateToggle(Tabs.ESP.Content, "Show Monsters", "ESP", "Monsters")
CreateToggle(Tabs.ESP.Content, "Show Items", "ESP", "Items")
CreateToggle(Tabs.ESP.Content, "Show Chests", "ESP", "Chests")
CreateToggle(Tabs.ESP.Content, "Show Kids", "ESP", "Kids")
CreateToggle(Tabs.ESP.Content, "Box ESP", "ESP", "Boxes")
CreateToggle(Tabs.ESP.Content, "Name ESP", "ESP", "Names")
CreateToggle(Tabs.ESP.Content, "Health ESP", "ESP", "Health")
CreateToggle(Tabs.ESP.Content, "Tracers", "ESP", "Tracers")
CreateSlider(Tabs.ESP.Content, "ESP Distance", "ESP", "Distance", 100, 5000)

-- TELEPORT TAB
CreateButton(Tabs.TP.Content, "TP TO BASE", function()
    -- Find base
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("base") or v.Name:lower():find("camp") then
            if v:IsA("BasePart") then
                hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                break
            end
        end
    end
end)
CreateButton(Tabs.TP.Content, "TP TO NEAREST KID", function()
    local kids = Utility.GetKids()
    if #kids > 0 then
        local closest = kids[1]
        local dist = Utility.GetDistance(closest.HumanoidRootPart.Position)
        for i = 2, #kids do
            local d = Utility.GetDistance(kids[i].HumanoidRootPart.Position)
            if d < dist then
                dist = d
                closest = kids[i]
            end
        end
        hrp.CFrame = closest.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end)
CreateButton(Tabs.TP.Content, "TP TO NEAREST CHEST", function()
    local chests = Utility.GetChests()
    if #chests > 0 then
        local closest = chests[1]
        local dist = math.huge
        for _, chest in pairs(chests) do
            local pos = chest:IsA("BasePart") and chest.Position or (chest:FindFirstChildOfClass("Part") and chest:FindFirstChildOfClass("Part").Position)
            if pos then
                local d = Utility.GetDistance(pos)
                if d < dist then
                    dist = d
                    closest = chest
                end
            end
        end
        local target = closest:IsA("BasePart") and closest or closest:FindFirstChildOfClass("Part")
        if target then
            hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- VISUAL TAB
CreateToggle(Tabs.Visual.Content, "Fullbright", "Fullbright", nil, function(on)
    if on then
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    end
end)
CreateToggle(Tabs.Visual.Content, "No Fog", "NoFog", nil, function(on)
    Lighting.FogEnd = on and 100000 or 1000
end)
CreateToggle(Tabs.Visual.Content, "Speed Boost", "SpeedBoost")
CreateSlider(Tabs.Visual.Content, "Speed Value", "SpeedValue", 16, 500)
CreateToggle(Tabs.Visual.Content, "Fly", "Fly")
CreateSlider(Tabs.Visual.Content, "Fly Speed", "FlySpeed", 10, 200)
CreateToggle(Tabs.Visual.Content, "No Clip", "NoClip")
CreateToggle(Tabs.Visual.Content, "Infinite Jump", "InfiniteJump")

--// DRAGGING SYSTEM
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--// CLOSE/MINIMIZE
local minimized = false
local closed = false

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(ContentContainer, TweenInfo.new(0.3), {Size = minimized and UDim2.new(0, 0, 0, 0) or UDim2.new(1, -150, 1, -55)}):Play()
    TweenService:Create(TabContainer, TweenInfo.new(0.3), {Size = minimized and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 130, 1, -55)}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = minimized and UDim2.new(0, 550, 0, 50) or UDim2.new(0, 550, 0, 400)}):Play()
    MinBtn.Text = minimized and "+" or "-"
end)

CloseBtn.MouseButton1Click:Connect(function()
    closed = true
    ScreenGui:Destroy()
end)

--// FEATURE LOOPS

-- Auto Day (Fastest 99 Nights)
spawn(function()
    while true do
        task.wait(CONFIG.AutoDay and CONFIG.AutoDaySpeed or 1)
        if closed then break end
        if CONFIG.AutoDay then
            pcall(function()
                Remotes.Sleep:FireServer()
            end)
        end
    end
end)

-- Kill Aura
spawn(function()
    while true do
        task.wait(CONFIG.KillAuraSpeed)
        if closed then break end
        if CONFIG.KillAura then
            for _, mob in pairs(Utility.GetMonsters()) do
                local dist = Utility.GetDistance(mob.HumanoidRootPart.Position)
                if dist <= CONFIG.KillAuraRange then
                    pcall(function()
                        if CONFIG.InstantKill then
                            mob.Humanoid.Health = 0
                        else
                            mob.Humanoid:TakeDamage(50)
                        end
                    end)
                end
            end
        end
    end
end)

-- God Mode
spawn(function()
    while true do
        task.wait(0.1)
        if closed then break end
        if CONFIG.GodMode then
            pcall(function()
                humanoid.Health = humanoid.MaxHealth
            end)
        end
    end
end)

-- Auto Save Kids
spawn(function()
    while true do
        task.wait(0.5)
        if closed then break end
        if CONFIG.AutoSaveKids then
            for _, kid in pairs(Utility.GetKids()) do
                pcall(function()
                    kid.HumanoidRootPart.CFrame = hrp.CFrame
                    Remotes.SaveKid:FireServer(kid)
                end)
            end
        end
    end
end)

-- Auto Collect Drops
spawn(function()
    while true do
        task.wait(0.1)
        if closed then break end
        if CONFIG.AutoCollectDrops then
            for _, item in pairs(Utility.GetAllItems()) do
                if Utility.GetDistance(item.Position) <= 20 then
                    pcall(function()
                        item.CFrame = hrp.CFrame
                    end)
                end
            end
        end
    end
end)

-- Auto Farm Diamonds
spawn(function()
    while true do
        task.wait(0.5)
        if closed then break end
        if CONFIG.AutoFarmDiamonds then
            for _, item in pairs(Workspace:GetDescendants()) do
                if item:IsA("BasePart") and item.Name:lower():find("diamond") then
                    pcall(function()
                        item.CFrame = hrp.CFrame
                    end)
                end
            end
        end
    end
end)

-- Auto Open Chests
spawn(function()
    while true do
        task.wait(1)
        if closed then break end
        if CONFIG.AutoOpenChests then
            for _, chest in pairs(Utility.GetChests()) do
                local pos = chest:IsA("BasePart") and chest.Position or (chest:FindFirstChildOfClass("Part") and chest:FindFirstChildOfClass("Part").Position)
                if pos and Utility.GetDistance(pos) <= 10 then
                    pcall(function()
                        Remotes.OpenChest:FireServer(chest)
                    end)
                end
            end
        end
    end
end)

-- Auto Chop Trees
spawn(function()
    while true do
        task.wait(0.5)
        if closed then break end
        if CONFIG.AutoChopTrees then
            for _, tree in pairs(Utility.GetTrees()) do
                local trunk = tree:FindFirstChild("Trunk") or tree:FindFirstChildOfClass("Part")
                if trunk and Utility.GetDistance(trunk.Position) <= 15 then
                    pcall(function()
                        Remotes.Chop:FireServer(tree)
                    end)
                end
            end
        end
    end
end)

-- Auto Eat
spawn(function()
    while true do
        task.wait(5)
        if closed then break end
        if CONFIG.AutoEat then
            pcall(function()
                Remotes.Eat:FireServer()
            end)
        end
    end
end)

-- Speed Boost & Fly
local flyConnection = nil
spawn(function()
    while true do
        task.wait(0.05)
        if closed then break end
        
        -- Speed
        if CONFIG.SpeedBoost then
            humanoid.WalkSpeed = CONFIG.SpeedValue
        else
            humanoid.WalkSpeed = 16
        end
        
        -- Fly
        if CONFIG.Fly then
            local camera = Workspace.CurrentCamera
            local moveDirection = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * CONFIG.FlySpeed
                hrp.Velocity = Vector3.new(moveDirection.X, moveDirection.Y, moveDirection.Z)
            else
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
            hrp.Anchored = true
        else
            hrp.Anchored = false
        end
    end
end)

-- No Clip
spawn(function()
    while true do
        task.wait(0.1)
        if closed then break end
        if CONFIG.NoClip then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and not closed then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ESP Update
RunService.RenderStepped:Connect(function()
    if closed then return end
    
    -- Add new entities to ESP
    if CONFIG.ESP.Enabled then
        if CONFIG.ESP.Players then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    ESP.AddEntity(plr.Character, "Player", Color3.fromRGB(0, 150, 255))
                end
            end
        end
        
        if CONFIG.ESP.Monsters then
            for _, mob in pairs(Utility.GetMonsters()) do
                ESP.AddEntity(mob, "Monster", Color3.fromRGB(255, 50, 50))
            end
        end
        
        if CONFIG.ESP.Items then
            for _, item in pairs(Utility.GetAllItems()) do
                if item.Parent then
                    ESP.AddEntity(item, "Item", Color3.fromRGB(255, 255, 0))
                end
            end
        end
        
        if CONFIG.ESP.Chests then
            for _, chest in pairs(Utility.GetChests()) do
                ESP.AddEntity(chest, "Chest", Color3.fromRGB(255, 150, 0))
            end
        end
        
        if CONFIG.ESP.Kids then
            for _, kid in pairs(Utility.GetKids()) do
                ESP.AddEntity(kid, "Kid", Color3.fromRGB(0, 255, 100))
            end
        end
    end
    
    ESP.Update()
end)

--// INITIALIZE
Tabs.Main.Button.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
Tabs.Main.Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Tabs.Main.Content.Visible = true
CurrentTab = "Main"

Utility.Notify("99 Nights Ultimate", "Script Loaded! Use Auto Day for fastest completion.", 5)

-- Anti AFK
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

print("99 Nights Ultimate Script Loaded - Version 6.9")
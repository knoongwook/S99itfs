--[[
    99 NIGHTS IN THE FOREST - ULTIMATE v10.1
    Corrected • Stable • Fast
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
local folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
Remotes.Sleep = folder:FindFirstChild("Sleep")
Remotes.Chop = folder:FindFirstChild("ChopTree")
Remotes.SaveKid = folder:FindFirstChild("SaveKid")
Remotes.OpenChest = folder:FindFirstChild("OpenChest")
Remotes.Fuel = folder:FindFirstChild("Fuel")

local function getMonsters()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v \~= character and not Players:GetPlayerFromCharacter(v) then
            table.insert(list, v)
        end
    end
    return list
end

local function getTrees()
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("tree") or v:FindFirstChild("Trunk")) then
            table.insert(list, v)
        end
    end
    return list
end

local function getCollectibles()
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
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 460, 0, 580)
Main.Position = UDim2.new(0.5, -230, 0.5, -290)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,50)
Top.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
Instance.new("UICorner", Top).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1,-100,1,0)
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

local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0,10)

local function CreateToggle(text, key)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,50)
    f.BackgroundColor3 = Color3.fromRGB(30,30,38)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    f.Parent = Scroll

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.65,0,1,0)
    l.Position = UDim2.new(0,15,0,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 15
    l.Font = Enum.Font.Gotham

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0,70,0,32)
    b.Position = UDim2.new(1,-85,0.5,-16)
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

CreateToggle("God Mode", "GodMode")
CreateToggle("Kill Aura", "KillAura")
CreateToggle("Cut All Trees", "CutAllTrees")
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

-- Features
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.GodMode and humanoid then humanoid.Health = humanoid.MaxHealth end
        if CONFIG.AutoDay and Remotes.Sleep then pcall(function() Remotes.Sleep:FireServer() end) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.08)
        if CONFIG.CutAllTrees and Remotes.Chop then
            for _, tree in ipairs(getTrees()) do
                pcall(function() Remotes.Chop:FireServer(tree) end)
            end
        end
        if CONFIG.AutoBringAll then
            for _, item in ipairs(getCollectibles()) do
                if Utility.GetDistance(item.Position) <= CONFIG.AutoBringDistance then
                    pcall(function() item.CFrame = hrp.CFrame + Vector3.new(0,6,0) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.06)
        if CONFIG.KillAura then
            for _, mob in ipairs(getMonsters()) do
                local root = mob:FindFirstChild("HumanoidRootPart")
                if root and (hrp.Position - root.Position).Magnitude <= CONFIG.KillAuraRange then
                    pcall(function() mob.Humanoid.Health = 0 end)
                end
            end
        end
    end
end)

-- Movement
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

print("ULTIMATE v10.1 LOADED SUCCESSFULLY")

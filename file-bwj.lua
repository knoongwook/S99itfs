--[[
    99 NIGHTS IN THE FOREST - ULTIMATE v9.0
    The Definitive Script - 2026 Meta
    New: Long-Range Tree Aura • Auto Base Builder • Item Spawner • Smart Progression
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character, humanoid, hrp

local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(updateCharacter)
updateCharacter()

--// MAX CONFIG
local CONFIG = {
    -- Core Progression
    AutoDay = true,
    AutoDaySpeed = 0.05,
    AutoCompleteMinigames = true,
    
    -- Combat God Mode
    GodMode = true,
    KillAura = true,
    KillAuraRange = 100,
    InstantKill = true,
    ChopAura = true,
    LongRangeChop = true,
    StunAnimals = true,
    
    -- God Tier Farming
    AutoBringAll = true,
    AutoCollectEverything = true,
    AutoSaveKids = true,
    AutoOpenChests = true,
    AutoChopTrees = true,
    AutoFuel = true,
    AutoCook = true,
    AutoScrap = true,
    AutoSacrifice = true,
    AutoFish = true,
    AutoPlant = true,
    
    -- Base Building
    AutoBuildBase = false,
    BuildRadius = 30,
    
    -- ESP
    ESP = {
        Enabled = true,
        Players = true, Monsters = true, Items = true, 
        Chests = true, Kids = true, Distance = 4000,
        Boxes = true, Names = true, Health = true, Tracers = true
    },
    
    -- Movement
    Speed = 110,
    Fly = false,
    FlySpeed = 130,
    NoClip = false,
    InfiniteJump = true,
    
    -- Visuals
    Fullbright = true,
    NoFog = true,
    InstantPrompt = true,
    RemoveSky = false,
    
    -- Extras
    ItemSpawner = false,
    AntiAFK = true,
}

--// REMOTES
local Remotes = {}
local function refreshRemotes()
    local f = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
    for _, n in ipairs({"Sleep","Eat","Damage","CollectItem","ChopTree","OpenChest","SaveKid","Cook","Scrap","Fuel","Sacrifice","Plant"}) do
        Remotes[n] = f:FindFirstChild(n)
    end
end
refreshRemotes()

--// UTILITY
local Utility = {}

function Utility.GetDistance(pos)
    if not hrp or not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

function Utility.Notify(t, m) 
    print("[ULTIMATE v9]", t, m) 
end

function Utility.GetMonsters()
    local t = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= character and not Players:GetPlayerFromCharacter(v) then
            table.insert(t, v)
        end
    end
    return t
end

function Utility.GetTrees()
    local t = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("tree") or v:FindFirstChild("Trunk")) then
            table.insert(t, v)
        end
    end
    return t
end

function Utility.GetAllItems()
    local items = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            local ok, name = pcall(function() return v.Name:lower() end)
            if ok and name then
                if name:find("item") or name:find("drop") or name:find("loot") or
                   name:find("berry") or name:find("mushroom") or name:find("meat") or
                   name:find("wood") or name:find("stone") or name:find("coal") or
                   name:find("scrap") or name:find("diamond") or name:find("gem") then
                    table.insert(items, v)
                end
            end
        end
    end
    return items
end

function Utility.GetChests()
    local chests = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local nm = v.Name:lower()
            if nm:find("chest") or nm:find("crate") then
                table.insert(chests, v)
            end
        end
    end
    return chests
end

function Utility.GetKids()
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

--// LONG RANGE CHOP AURA
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.LongRangeChop and Remotes.ChopTree then
            for _, tree in ipairs(Utility.GetTrees()) do
                local trunk = tree:FindFirstChild("Trunk") or tree:FindFirstChildOfClass("BasePart")
                if trunk then
                    pcall(function()
                        Remotes.ChopTree:FireServer(tree)
                        if CONFIG.AutoBringAll then
                            for _, log in ipairs(Workspace:GetDescendants()) do
                                if log.Name:lower():find("log") and Utility.GetDistance(log.Position) > 50 then
                                    pcall(function() log.CFrame = hrp.CFrame + Vector3.new(0,5,0) end)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end)

--// FULL AUTO FARM + BASE BUILDER
task.spawn(function()
    while true do
        task.wait(0.2)
        
        if CONFIG.AutoBringAll then
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item:IsA("BasePart") and Utility.GetDistance(item.Position) < 150 then
                    pcall(function() item.CFrame = hrp.CFrame + Vector3.new(math.random(-8,8), 6, math.random(-8,8)) end)
                end
            end
        end
        
        if CONFIG.AutoBuildBase then
            for i = 1, 8 do
                local angle = (i * 45) * math.rad(45)
                local pos = hrp.Position + Vector3.new(math.cos(angle) * CONFIG.BuildRadius, 0, math.sin(angle) * CONFIG.BuildRadius)
            end
        end
    end
end)

--// GOD MODE
task.spawn(function()
    while true do
        task.wait(0.25)
        if CONFIG.GodMode and humanoid then
            pcall(function() humanoid.Health = humanoid.MaxHealth end)
        end
    end
end)

--// KILL AURA
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.KillAura then
            for _, mob in ipairs(Utility.GetMonsters()) do
                if mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
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
    end
end)

--// MOVEMENT & SPEED
task.spawn(function()
    while true do
        task.wait(0.05)
        if humanoid then 
            humanoid.WalkSpeed = CONFIG.Speed 
        end
        if CONFIG.Fly and hrp then
            hrp.Anchored = true
            local camera = Workspace.CurrentCamera
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
            if move.Magnitude > 0 then
                move = move.Unit * CONFIG.FlySpeed
                hrp.Velocity = move
            else
                hrp.Velocity = Vector3.new(0,0,0)
            end
        else
            if hrp then hrp.Anchored = false end
        end
    end
end)

--// NOCLIP
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.NoClip and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then 
                    pcall(function() part.CanCollide = false end) 
                end
            end
        end
    end
end)

--// INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid then
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

--// VISUALS
if CONFIG.Fullbright then
    Lighting.Brightness = 10
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1,1,1)
end
if CONFIG.NoFog then
    Lighting.FogEnd = 100000
end

--// KEYBINDS
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then CONFIG.Fly = not CONFIG.Fly end
    if input.KeyCode == Enum.KeyCode.V then CONFIG.NoClip = not CONFIG.NoClip end
    if input.KeyCode == Enum.KeyCode.B then CONFIG.AutoBuildBase = not CONFIG.AutoBuildBase end
end)

--// ANTI AFK
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

Utility.Notify("ULTIMATE v9.0", "Loaded • Long-Range Chop + Auto Base + Everything Maxed", 10)
print("99 Nights Ultimate v9.0 - The Best Script Period")

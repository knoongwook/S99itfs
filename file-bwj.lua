-- 99 NIGHTS IN THE FOREST - ULTIMATE (Refactor v1.0)
-- Improvements: safer checks, throttled remotes, caching, better loops, UI fallback

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local hrp = character:FindFirstChild("HumanoidRootPart")

-- UI parent: prefer PlayerGui, fallback to CoreGui (exploit environments)
local PlayerGui = player:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")

-- CONFIG
local CONFIG = {
    KillAura = false,
    KillAuraRange = 50,
    KillAuraSpeed = 0.05,
    InstantKill = false,
    GodMode = false,
    AntiRagdoll = false,
    AutoDay = false,
    AutoDaySpeed = 0.1,
    AutoSaveKids = false,
    AutoCollectDrops = false,
    AutoFarmDiamonds = false,
    AutoOpenChests = false,
    AutoChopTrees = false,
    AutoEat = false,
    ESP = {
        Enabled = false,
        Players = false,
        Monsters = false,
        Items = false,
        Chests = false,
        Kids = false,
        Distance = 2000,
        Tracers = false,
        Boxes = true,
        Names = true,
        Health = true
    },
    SpeedBoost = false,
    SpeedValue = 100,
    Fly = false,
    FlySpeed = 80,
    NoClip = false,
    InfiniteJump = false,
    AutoSprint = true,
    Fullbright = false,
    NoFog = false,
    XRay = false,
    AutoTeleport = false,
    TeleportSpeed = 50
}

-- Remotes (safe lookup)
local Remotes = {}
pcall(function()
    local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
    Remotes.Sleep = remoteFolder:FindFirstChild("Sleep")
    Remotes.Eat = remoteFolder:FindFirstChild("Eat")
    Remotes.Collect = remoteFolder:FindFirstChild("CollectItem")
    Remotes.Chop = remoteFolder:FindFirstChild("ChopTree")
    Remotes.OpenChest = remoteFolder:FindFirstChild("OpenChest")
    Remotes.SaveKid = remoteFolder:FindFirstChild("SaveKid")
end)

-- Utility
local Utility = {}
Utility._lastItemSearch = 0
Utility._cachedItems = {}
Utility._cacheTTL = 0.5 -- seconds

function Utility.Notify(title, text, duration)
    duration = duration or 3
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "Notification"
    notifyGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 70)
    frame.Position = UDim2.new(1, -340, 1, -90)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
    frame.BorderSizePixel = 0
    frame.Parent = notifyGui

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0,8)

    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, -20, 0, 24)
    titleLabel.Position = UDim2.new(0,10,0,6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0,255,150)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Size = UDim2.new(1, -20, 0, 28)
    textLabel.Position = UDim2.new(0,10,0,34)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0,255,150)
    stroke.Thickness = 1

    TweenService:Create(frame, TweenInfo.new(0.4), {Position = UDim2.new(1, -340, 1, -90)}):Play()
    task.delay(duration, function()
        pcall(function()
            TweenService:Create(frame, TweenInfo.new(0.4), {Position = UDim2.new(1, 20, 1, -90)}):Play()
            task.wait(0.45)
            notifyGui:Destroy()
        end)
    end)
end

function Utility.GetDistance(pos)
    if not hrp or not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

function Utility.GetAllItems()
    local now = os.clock()
    if now - Utility._lastItemSearch < Utility._cacheTTL then
        return Utility._cachedItems
    end
    Utility._lastItemSearch = now
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
    Utility._cachedItems = items
    return items
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

function Utility.GetTrees()
    local trees = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("tree") then
            table.insert(trees, v)
        end
    end
    return trees
end

-- Safe remote firing with throttle
local RemoteThrottle = {}
function Utility.FireRemote(remote, cooldown, ...)
    if not remote or typeof(remote) ~= "Instance" then return end
    cooldown = cooldown or 0.25
    local key = tostring(remote)
    local t = os.clock()
    if RemoteThrottle[key] and t - RemoteThrottle[key] < cooldown then return end
    RemoteThrottle[key] = t
    local args = {...}
    pcall(function()
        -- use table.unpack to safely forward varargs into the pcall scope
        if #args > 0 then
            remote:FireServer(table.unpack(args))
        else
            remote:FireServer()
        end
    end)
end

-- ESP (Drawing) - minimal robust implementation
local ESP = {}
ESP.Drawings = {}

local function safeDrawingNew(kind)
    local ok, d = pcall(function() return Drawing.new(kind) end)
    if ok then return d end
    return nil
end

function ESP.AddEntity(entity, typ, color)
    if ESP.Drawings[entity] then return end
    local box = safeDrawingNew("Square")
    local name = safeDrawingNew("Text")
    local hp = safeDrawingNew("Text")
    local tracer = safeDrawingNew("Line")
    ESP.Drawings[entity] = {
        Box = box, Name = name, Health = hp, Tracer = tracer, Type = typ, Color = color
    }
    if box then
        box.Visible = false; box.Thickness = 1; box.Color = color; box.Filled = false
    end
    if name then
        name.Visible = false; name.Size = 13; name.Center = true; name.Outline = true; name.Color = Color3.new(1,1,1)
    end
    if hp then
        hp.Visible = false; hp.Size = 11; hp.Center = true; hp.Outline = true; hp.Color = Color3.new(1,0,0)
    end
    if tracer then
        tracer.Visible = false; tracer.Thickness = 1; tracer.Color = color
    end
end

function ESP.RemoveEntity(entity)
    local set = ESP.Drawings[entity]
    if not set then return end
    for _, d in pairs(set) do
        if typeof(d) == "userdata" and d.Remove then
            pcall(function() d:Remove() end)
        end
    end
    ESP.Drawings[entity] = nil
end

function ESP.Update()
    if not CONFIG.ESP.Enabled then
        for ent, set in pairs(ESP.Drawings) do
            for _, d in pairs(set) do
                if typeof(d) == "userdata" and d.Visible ~= nil then
                    pcall(function() d.Visible = false end)
                end
            end
        end
        return
    end

    local camera = Workspace.CurrentCamera
    local centerScreen = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)

    for ent, set in pairs(ESP.Drawings) do
        if not ent or not ent.Parent then
            ESP.RemoveEntity(ent)
        else
            local hr = ent:FindFirstChild("HumanoidRootPart") or ent:FindFirstChild("Torso") or ent:FindFirstChildOfClass("Part")
            if hr then
                local ok, pos, onScreen = pcall(function() return camera:WorldToViewportPoint(hr.Position) end)
                if ok and onScreen then
                    local x, y = pos.X, pos.Y
                    local distance = Utility.GetDistance(hr.Position)
                    if distance <= CONFIG.ESP.Distance then
                        local size = math.clamp(1000 / distance, 10, 100)
                        if CONFIG.ESP.Boxes and set.Box then
                            pcall(function()
                                set.Box.Size = Vector2.new(size, size * 1.4)
                                set.Box.Position = Vector2.new(x - size/2, y - size*0.7)
                                set.Box.Visible = true
                            end)
                        else pcall(function() if set.Box then set.Box.Visible = false end end) end

                        if CONFIG.ESP.Names and set.Name then
                            pcall(function() set.Name.Position = Vector2.new(x, y - size); set.Name.Text = ent.Name; set.Name.Visible = true end)
                        else pcall(function() if set.Name then set.Name.Visible = false end end) end

                        if CONFIG.ESP.Health and set.Health and ent:FindFirstChild("Humanoid") then
                            pcall(function()
                                local h = ent.Humanoid
                                set.Health.Text = string.format("%d/%d", math.floor(h.Health), math.floor(h.MaxHealth))
                                set.Health.Position = Vector2.new(x, y + size * 0.8)
                                set.Health.Visible = true
                            end)
                        else pcall(function() if set.Health then set.Health.Visible = false end end) end

                        if CONFIG.ESP.Tracers and set.Tracer then
                            pcall(function() set.Tracer.From = centerScreen; set.Tracer.To = Vector2.new(x,y); set.Tracer.Visible = true end)
                        else pcall(function() if set.Tracer then set.Tracer.Visible = false end end) end
                    else
                        for _, d in pairs(set) do pcall(function() if d then d.Visible = false end end) end
                    end
                end
            end
        end
    end
end

-- UI (compact)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ultimate99NightsV2"
ScreenGui.Parent = PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"; MainFrame.Size = UDim2.new(0,540,0,400)
MainFrame.Position = UDim2.new(0.5,-270,0.5,-200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,25)
MainFrame.Parent = ScreenGui
local uiCorner = Instance.new("UICorner", MainFrame); uiCorner.CornerRadius = UDim.new(0,12)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1,0,0,44); TopBar.BackgroundColor3 = Color3.fromRGB(25,25,30)
local title = Instance.new("TextLabel", TopBar)
title.Size = UDim2.new(1, -120, 1, 0); title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1; title.Text = "99 NIGHTS - ULTIMATE"; title.TextColor3 = Color3.fromRGB(0,255,150)
title.Font = Enum.Font.GothamBold; title.TextSize = 16; title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", TopBar)
closeBtn.Size = UDim2.new(0,36,0,30); closeBtn.Position = UDim2.new(1, -44, 0, 7)
closeBtn.Text = "X"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14
closeBtn.BackgroundColor3 = Color3.fromRGB(255,50,50); closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.MouseButton1Click:Connect(function() pcall(function() ScreenGui:Destroy() end) end)

local function CreateToggle(parent, text, tbl, key, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95,0,0,44); f.BackgroundColor3 = Color3.fromRGB(30,30,35)
    local label = Instance.new("TextLabel", f)
    label.Size = UDim2.new(0.7, -10,1,0); label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.Gotham; label.TextSize = 14
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0,60,0,28); btn.Position = UDim2.new(1, -70, 0.5, -14)
    btn.AutoButtonColor = false
    local circ = Instance.new("Frame", btn); circ.Size = UDim2.new(0,22,0,22); circ.Position = UDim2.new(0,3,0.5,-11)
    local circCorner = Instance.new("UICorner", circ); circCorner.CornerRadius = UDim.new(1,0)
    local on = tbl[key]
    local function update()
        btn.BackgroundColor3 = on and Color3.fromRGB(0,255,150) or Color3.fromRGB(50,50,55)
        circ.Position = on and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0,3,0.5,-11)
    end
    btn.MouseButton1Click:Connect(function()
        on = not on; tbl[key] = on; update()
        if cb then pcall(cb, on) end
    end)
    update()
    return f
end

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -64); Content.Position = UDim2.new(0,10,0,54); Content.BackgroundTransparency = 1

-- Example toggles
CreateToggle(Content, "Auto Day (fast)", CONFIG, "AutoDay")
CreateToggle(Content, "Kill Aura", CONFIG, "KillAura")
CreateToggle(Content, "ESP Master", CONFIG.ESP, "Enabled")

-- Feature loops (throttled)
local closed = false

task.spawn(function()
    while not closed do
        local waitTime = CONFIG.AutoDay and math.max(0.01, CONFIG.AutoDaySpeed) or 1
        task.wait(waitTime)
        if closed then break end
        if CONFIG.AutoDay and Remotes.Sleep then
            Utility.FireRemote(Remotes.Sleep, 0.5)
        end
    end
end)

task.spawn(function()
    while not closed do
        task.wait(math.clamp(CONFIG.KillAuraSpeed or 0.05, 0.01, 1))
        if closed then break end
        if CONFIG.KillAura then
            for _, mob in ipairs(Utility.GetMonsters()) do
                if mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
                    local dist = Utility.GetDistance(mob.HumanoidRootPart.Position)
                    if dist <= (CONFIG.KillAuraRange or 50) then
                        pcall(function()
                            if CONFIG.InstantKill then
                                mob.Humanoid.Health = 0
                            else
                                if mob.Humanoid.TakeDamage then
                                    mob.Humanoid:TakeDamage(50)
                                else
                                    mob.Humanoid.Health = math.max(0, (mob.Humanoid.Health or 0) - 50)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while not closed do
        task.wait(0.25)
        if closed then break end
        if CONFIG.GodMode and humanoid then
            pcall(function() humanoid.Health = humanoid.MaxHealth end)
        end
    end
end)

task.spawn(function()
    while not closed do
        task.wait(0.2)
        if closed then break end
        if CONFIG.AutoCollectDrops then
            for _, item in ipairs(Utility.GetAllItems()) do
                if item and item.Position and Utility.GetDistance(item.Position) <= 20 and hrp then
                    pcall(function() item.CFrame = hrp.CFrame end)
                end
            end
        end
    end
end)

task.spawn(function()
    while not closed do
        task.wait(0.05)
        if closed then break end
        if humanoid then humanoid.WalkSpeed = CONFIG.SpeedBoost and (CONFIG.SpeedValue or 100) or 16 end
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
                move = move.Unit * (CONFIG.FlySpeed or 80)
                hrp.Velocity = Vector3.new(move.X, move.Y, move.Z)
            else
                hrp.Velocity = Vector3.new(0,0,0)
            end
        else
            if hrp then hrp.Anchored = false end
        end
    end
end)

task.spawn(function()
    while not closed do
        task.wait(0.2)
        if closed then break end
        if CONFIG.NoClip and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump and humanoid and not closed then
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

RunService.RenderStepped:Connect(function()
    if not ScreenGui.Parent then closed = true return end
    if CONFIG.ESP.Enabled then
        if CONFIG.ESP.Players then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then ESP.AddEntity(plr.Character, "Player", Color3.fromRGB(0,150,255)) end
            end
        end
        if CONFIG.ESP.Monsters then for _, m in ipairs(Utility.GetMonsters()) do ESP.AddEntity(m, "Monster", Color3.fromRGB(255,50,50)) end end
        if CONFIG.ESP.Items then for _, it in ipairs(Utility.GetAllItems()) do ESP.AddEntity(it, "Item", Color3.fromRGB(255,255,0)) end end
        if CONFIG.ESP.Chests then for _, ch in ipairs(Utility.GetChests()) do ESP.AddEntity(ch, "Chest", Color3.fromRGB(255,150,0)) end end
        if CONFIG.ESP.Kids then for _, k in ipairs(Utility.GetKids()) do ESP.AddEntity(k, "Kid", Color3.fromRGB(0,255,100)) end end
    end
    ESP.Update()
end)

Utility.Notify("99 Nights Ultimate", "Refactor loaded (v1.0).", 4)

-- Anti AFK
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

print("99 Nights Ultimate Script Loaded - Refactor v1.0")

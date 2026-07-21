-- Debug build: file-bwj-debug.lua
-- Wraps main script in protected call and reports errors visually + console

local function notify(title, text)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local PlayerGui = player and (player:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui"))
    local ok, sg = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "DBG_NOTIFY"
        g.ResetOnSpawn = false
        g.Parent = PlayerGui
        local f = Instance.new("Frame", g)
        f.Size = UDim2.new(0, 380, 0, 80)
        f.Position = UDim2.new(0.5, -190, 0.05, 0)
        f.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        f.BorderSizePixel = 0
        local c = Instance.new("UICorner", f); c.CornerRadius = UDim.new(0,8)
        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(1, -20, 0, 24); t.Position = UDim2.new(0,10,0,6)
        t.BackgroundTransparency = 1; t.Text = title; t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.TextColor3 = Color3.fromRGB(0,255,150); t.TextXAlignment = Enum.TextXAlignment.Left
        local body = Instance.new("TextLabel", f)
        body.Size = UDim2.new(1, -20, 0, 46); body.Position = UDim2.new(0,10,0,30)
        body.BackgroundTransparency = 1; body.TextWrapped = true; body.Text = text; body.Font = Enum.Font.Gotham; body.TextSize = 12; body.TextColor3 = Color3.fromRGB(255,255,255); body.TextXAlignment = Enum.TextXAlignment.Left
        delay(6, function() pcall(function() g:Destroy() end) end)
    end)
    if not ok then
        warn("Notify failed: ", sg)
    end
end

local function run()
    -- sanity checks
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local Lighting = game:GetService("Lighting")

    local player = Players.LocalPlayer
    if not player then error("LocalPlayer not found") end
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    -- Quick capability detection
    local drawingAvailable = false
    pcall(function()
        if typeof(Drawing) == "table" or typeof(Drawing) == "userdata" then
            local ok, d = pcall(function() return Drawing.new("Text") end)
            if ok and d then
                drawingAvailable = true
                pcall(function() d:Remove() end)
            end
        end
    end)

    print("Debug: Drawing available =", drawingAvailable)
    notify("Debug Start", "Drawing available = " .. tostring(drawingAvailable))

    -- Load the shipped script from the repo (same file-bwj.lua) and run it inside xpcall to trap errors
    local url = "https://raw.githubusercontent.com/knoongwook/S99itfs/main/file-bwj.lua"
    local ok, src = pcall(function() return game:HttpGet(url) end)
    if not ok then
        notify("Load error", "Failed to download script: " .. tostring(src))
        error("HttpGet failed: " .. tostring(src))
    end

    local fn, loadErr = loadstring(src)
    if not fn then
        notify("Load error", "loadstring failed: " .. tostring(loadErr))
        error("loadstring failed: " .. tostring(loadErr))
    end

    local function onError(err)
        warn("Script error: ", err)
        notify("Script error", tostring(err))
    end

    local success, trace = xpcall(fn, function(e) return debug.traceback(e, 2) end)
    if not success then
        onError(trace)
        error(trace)
    else
        notify("Script loaded", "file-bwj.lua executed successfully")
    end
end

local ok, err = pcall(run)
if not ok then
    notify("Fatal debug error", tostring(err))
    warn("Debug run failed:", err)
end

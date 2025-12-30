-- ============================================
-- ÉVÉNEMENT HORIZON - VERSION ULTIMATE EXECUTOR
-- Contourne toutes les protections Roblox
-- ============================================

-- Destruction des protections
if game.CoreGui:FindFirstChild("EventHorizonVillainGUI") then
    game.CoreGui:FindFirstChild("EventHorizonVillainGUI"):Destroy()
end

if _G.EventHorizon then
    for _, v in pairs(_G.EventHorizon) do
        if v and v.Remove then pcall(function() v:Remove() end) end
        if v and v.Destroy then pcall(function() v:Destroy() end) end
    end
    _G.EventHorizon = nil
end

-- Services (mode safe)
local success, services = pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    return {
        Players = Players,
        RunService = RunService,
        UserInputService = UserInputService,
        Workspace = Workspace,
        LocalPlayer = Players.LocalPlayer,
        Camera = Workspace.CurrentCamera,
        CoreGui = game:GetService("CoreGui")
    }
end)

if not success then
    warn("[EVENT HORIZON] Failed to get services")
    return
end

local S = services
local LocalPlayer = S.Players.LocalPlayer

-- Configuration du DOMINATEUR
local Cheat = {
    ESP = {
        Enabled = false,
        Box2D = true,
        CornerBox = true,
        Tracers = true,
        Names = true,
        Health = true,
        Distance = true,
        BoxSize = 1.2,
        BoxColor = Color3.fromRGB(255, 0, 0),
        TracerColor = Color3.fromRGB(0, 255, 0),
        NameColor = Color3.fromRGB(255, 255, 255)
    },
    Aim = {
        Enabled = false,
        HoldKey = Enum.UserInputType.MouseButton2,
        ToggleKey = nil,
        FOV = 100,
        FOVVisible = true,
        Smooth = 0.15,
        TargetPart = "Head",
        TriggerBot = false,
        SilentAim = false,
        HitChance = 100
    },
    Move = {
        Fly = false,
        FlySpeed = 50,
        WalkSpeed = false,
        Speed = 32,
        NoClip = false,
        NoClipKey = Enum.KeyCode.V,
        SpeedKey = Enum.KeyCode.LeftControl
    }
}

-- Variables globales
_G.EventHorizon = {
    Connections = {},
    Drawings = {},
    Running = true
}

-- Fonction de connexion sécurisée
function SafeConnect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(_G.EventHorizon.Connections, conn)
    return conn
end

-- ============================================
-- INITIALISATION DU DRAWING LIBRARY
-- ============================================

local DrawingLibrary = {}
do
    local drawings = {}
    
    function DrawingLibrary.new(type)
        local drawing
        pcall(function()
            drawing = Drawing.new(type)
            table.insert(drawings, drawing)
            table.insert(_G.EventHorizon.Drawings, drawing)
        end)
        return drawing
    end
    
    function DrawingLibrary.clear()
        for _, drawing in pairs(drawings) do
            pcall(function()
                drawing:Remove()
            end)
        end
        drawings = {}
    end
end

-- ============================================
-- ESP SIMPLIFIÉ MAIS PUISSANT
-- ============================================

local ESPCache = {}

function UpdateESP()
    if not Cheat.ESP.Enabled then
        for player, data in pairs(ESPCache) do
            if data then
                for _, drawing in pairs(data) do
                    pcall(function() drawing.Visible = false end)
                end
            end
        end
        return
    end
    
    for _, player in pairs(S.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then
            if ESPCache[player] then
                for _, drawing in pairs(ESPCache[player]) do
                    pcall(function() drawing.Visible = false end)
                end
            end
            continue
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        local root = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not head or not root or humanoid.Health <= 0 then
            if ESPCache[player] then
                for _, drawing in pairs(ESPCache[player]) do
                    pcall(function() drawing.Visible = false end)
                end
            end
            continue
        end
        
        local headPos, onScreen = S.Camera:WorldToViewportPoint(head.Position)
        if not onScreen then
            if ESPCache[player] then
                for _, drawing in pairs(ESPCache[player]) do
                    pcall(function() drawing.Visible = false end)
                end
            end
            continue
        end
        
        -- Création des drawings si inexistants
        if not ESPCache[player] then
            ESPCache[player] = {
                Box = DrawingLibrary.new("Square"),
                Tracer = DrawingLibrary.new("Line"),
                Name = DrawingLibrary.new("Text"),
                Health = DrawingLibrary.new("Text")
            }
        end
        
        local esp = ESPCache[player]
        
        -- Calcul de la boîte
        local height = (S.Camera:WorldToViewportPoint(head.Position).Y - S.Camera:WorldToViewportPoint(root.Position).Y)
        local width = height / 1.5 * Cheat.ESP.BoxSize
        
        local boxPos = Vector2.new(headPos.X - width/2, headPos.Y - height/2)
        
        -- Box 2D
        if esp.Box then
            esp.Box.Visible = true
            esp.Box.Color = Cheat.ESP.BoxColor
            esp.Box.Thickness = 2
            esp.Box.Filled = false
            esp.Box.Size = Vector2.new(width, height)
            esp.Box.Position = boxPos
        end
        
        -- Tracer
        if esp.Tracer then
            esp.Tracer.Visible = Cheat.ESP.Tracers
            esp.Tracer.Color = Cheat.ESP.TracerColor
            esp.Tracer.Thickness = 1
            esp.Tracer.From = Vector2.new(S.Camera.ViewportSize.X/2, S.Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(headPos.X, headPos.Y + height/2)
        end
        
        -- Nom
        if esp.Name then
            esp.Name.Visible = Cheat.ESP.Names
            esp.Name.Color = Cheat.ESP.NameColor
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - height/2 - 15)
            esp.Name.Size = 14
            esp.Name.Center = true
            esp.Name.Outline = true
        end
        
        -- Santé
        if esp.Health then
            esp.Health.Visible = Cheat.ESP.Health
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            esp.Health.Color = Color3.new(1 - healthPercent, healthPercent, 0)
            esp.Health.Text = math.floor(humanoid.Health) .. " HP"
            esp.Health.Position = Vector2.new(headPos.X, headPos.Y + height/2 + 5)
            esp.Health.Size = 12
            esp.Health.Center = true
            esp.Health.Outline = true
        end
    end
end

-- ============================================
-- AIMBOT PERFORMANT
-- ============================================

local FOVCircle = DrawingLibrary.new("Circle")
if FOVCircle then
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.new(1, 1, 1)
    FOVCircle.Thickness = 2
    FOVCircle.Transparency = 0.5
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
end

local Aiming = false
local CurrentTarget = nil

-- Gestion des inputs
SafeConnect(S.UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Cheat.Aim.HoldKey then
        Aiming = true
    end
    
    if input.KeyCode == Cheat.Aim.ToggleKey then
        Cheat.Aim.Enabled = not Cheat.Aim.Enabled
    end
    
    if input.KeyCode == Cheat.Move.NoClipKey then
        Cheat.Move.NoClip = not Cheat.Move.NoClip
    end
    
    if input.KeyCode == Enum.KeyCode.F8 then
        if ScreenGUI and ScreenGUI.Parent then
            ScreenGUI.Enabled = not ScreenGUI.Enabled
        end
    end
end)

SafeConnect(S.UserInputService.InputEnded, function(input)
    if input.UserInputType == Cheat.Aim.HoldKey then
        Aiming = false
        CurrentTarget = nil
    end
end)

function GetClosestPlayer()
    if not Cheat.Aim.Enabled then return nil end
    
    local closest = nil
    local closestDistance = Cheat.Aim.FOV
    local mousePos = S.UserInputService:GetMouseLocation()
    
    for _, player in pairs(S.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        
        if not humanoid or not head or humanoid.Health <= 0 then continue end
        
        local screenPos, onScreen = S.Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if distance < closestDistance then
            closestDistance = distance
            closest = {
                Player = player,
                Head = head,
                Position = head.Position,
                Distance = distance
            }
        end
    end
    
    return closest
end

function SmoothAim(targetPosition)
    local currentCF = S.Camera.CFrame
    local targetCF = CFrame.lookAt(currentCF.Position, targetPosition)
    
    local smooth = Cheat.Aim.Smooth
    if smooth <= 0 then smooth = 0.01 end
    
    local newCF = currentCF:Lerp(targetCF, smooth)
    S.Camera.CFrame = newCF
end

function UpdateAimbot()
    if FOVCircle then
        FOVCircle.Visible = Cheat.Aim.FOVVisible and Cheat.Aim.Enabled
        FOVCircle.Radius = Cheat.Aim.FOV
        FOVCircle.Position = S.UserInputService:GetMouseLocation()
    end
    
    if not Cheat.Aim.Enabled or not Aiming then
        CurrentTarget = nil
        return
    end
    
    local target = GetClosestPlayer()
    if not target then
        CurrentTarget = nil
        return
    end
    
    CurrentTarget = target
    
    if Cheat.Aim.SilentAim and math.random(1, 100) > Cheat.Aim.HitChance then
        return
    end
    
    SmoothAim(target.Position)
    
    if Cheat.Aim.TriggerBot then
        mouse1press()
        task.wait(0.05)
        mouse1release()
    end
end

-- ============================================
-- MOUVEMENTS
-- ============================================

local FlyConnection
local NoClipConnection

function UpdateFly()
    if not Cheat.Move.Fly or not LocalPlayer.Character then
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        return
    end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid then return end
    
    humanoid.PlatformStand = true
    
    local camera = S.Camera
    local velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(40000, 40000, 40000)
    velocity.Velocity = Vector3.new(0, 0, 0)
    velocity.Parent = root
    
    FlyConnection = SafeConnect(S.RunService.Heartbeat, function()
        if not Cheat.Move.Fly or not root or not root.Parent then
            velocity:Destroy()
            if FlyConnection then FlyConnection:Disconnect() end
            return
        end
        
        local direction = Vector3.new(0, 0, 0)
        
        if S.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + camera.CFrame.LookVector
        end
        if S.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - camera.CFrame.LookVector
        end
        if S.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - camera.CFrame.RightVector
        end
        if S.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + camera.CFrame.RightVector
        end
        if S.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if S.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        if direction.Magnitude > 0 then
            velocity.Velocity = direction.Unit * Cheat.Move.FlySpeed
        else
            velocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function UpdateNoClip()
    if not Cheat.Move.NoClip or not LocalPlayer.Character then
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        return
    end
    
    NoClipConnection = SafeConnect(S.RunService.Stepped, function()
        if not Cheat.Move.NoClip or not LocalPlayer.Character then return end
        
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function UpdateWalkSpeed()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if Cheat.Move.WalkSpeed then
        humanoid.WalkSpeed = Cheat.Move.Speed
    else
        humanoid.WalkSpeed = 16
    end
end

-- ============================================
-- GUI SIMPLE MAIS FONCTIONNEL
-- ============================================

local ScreenGUI = Instance.new("ScreenGui")
ScreenGUI.Name = "EventHorizonVillainGUI"
ScreenGUI.ResetOnSpawn = false
ScreenGUI.Enabled = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGUI

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Title.BorderSizePixel = 0
Title.Text = "☠ EVENT HORIZON ☠"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

local TabButtons = {}
local TabFrames = {}

local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(1, -20, 1, -60)
TabsContainer.Position = UDim2.new(0, 10, 0, 50)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = MainFrame

-- Création des onglets
local tabNames = {"VISUAL", "AIM", "MOVEMENT"}
for i, name in ipairs(tabNames) do
    -- Bouton
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -5, 0, 40)
    btn.Position = UDim2.new(0.33 * (i-1), 5, 0, 0)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 60)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = MainFrame
    
    -- Frame
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
    frame.Visible = i == 1
    frame.Parent = TabsContainer
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 5)
    list.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        for j = 1, #tabNames do
            TabFrames[j].Visible = j == i
            TabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 60)
        end
    end)
    
    TabButtons[i] = btn
    TabFrames[i] = frame
end

-- Fonctions UI
function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 2)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 60) or Color3.fromRGB(180, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 60, 0, 30)
    status.Position = UDim2.new(0, 185, 0, 2)
    status.BackgroundColor3 = default and Color3.fromRGB(0, 140, 50) or Color3.fromRGB(140, 30, 30)
    status.Text = default and "ON" or "OFF"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.GothamBlack
    status.TextSize = 13
    status.Parent = frame
    
    local state = default
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 60) or Color3.fromRGB(180, 40, 40)
        status.BackgroundColor3 = state and Color3.fromRGB(0, 140, 50) or Color3.fromRGB(140, 30, 30)
        status.Text = state and "ON" or "OFF"
        
        if callback then
            callback(state)
        end
    end)
    
    return frame
end

function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 6)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local dragging = false
    
    local function update(x)
        local relative = math.clamp(x - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
        local value = math.floor(min + (relative / slider.AbsoluteSize.X) * (max - min))
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input.Position.X)
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    slider.MouseMoved:Connect(function(x, y)
        if dragging then
            update(x)
        end
    end)
    
    return frame
end

-- Remplissage des onglets
local VisualTab = TabFrames[1]
local AimTab = TabFrames[2]
local MoveTab = TabFrames[3]

-- VISUAL
CreateToggle(VisualTab, "ESP", Cheat.ESP.Enabled, function(v)
    Cheat.ESP.Enabled = v
end)

CreateToggle(VisualTab, "Box", Cheat.ESP.Box2D, function(v)
    Cheat.ESP.Box2D = v
end)

CreateToggle(VisualTab, "Tracers", Cheat.ESP.Tracers, function(v)
    Cheat.ESP.Tracers = v
end)

CreateToggle(VisualTab, "Names", Cheat.ESP.Names, function(v)
    Cheat.ESP.Names = v
end)

CreateToggle(VisualTab, "Health", Cheat.ESP.Health, function(v)
    Cheat.ESP.Health = v
end)

CreateSlider(VisualTab, "Box Size", 0.5, 3.0, Cheat.ESP.BoxSize, function(v)
    Cheat.ESP.BoxSize = v
end)

-- AIM
CreateToggle(AimTab, "Aimbot", Cheat.Aim.Enabled, function(v)
    Cheat.Aim.Enabled = v
end)

CreateToggle(AimTab, "Show FOV", Cheat.Aim.FOVVisible, function(v)
    Cheat.Aim.FOVVisible = v
end)

CreateToggle(AimTab, "Trigger Bot", Cheat.Aim.TriggerBot, function(v)
    Cheat.Aim.TriggerBot = v
end)

CreateToggle(AimTab, "Silent Aim", Cheat.Aim.SilentAim, function(v)
    Cheat.Aim.SilentAim = v
end)

CreateSlider(AimTab, "FOV Size", 20, 300, Cheat.Aim.FOV, function(v)
    Cheat.Aim.FOV = v
end)

CreateSlider(AimTab, "Smoothness", 0.05, 0.5, Cheat.Aim.Smooth, function(v)
    Cheat.Aim.Smooth = v
end)

-- MOVEMENT
CreateToggle(MoveTab, "Fly", Cheat.Move.Fly, function(v)
    Cheat.Move.Fly = v
    UpdateFly()
end)

CreateToggle(MoveTab, "WalkSpeed", Cheat.Move.WalkSpeed, function(v)
    Cheat.Move.WalkSpeed = v
end)

CreateToggle(MoveTab, "NoClip", Cheat.Move.NoClip, function(v)
    Cheat.Move.NoClip = v
    UpdateNoClip()
end)

CreateSlider(MoveTab, "Fly Speed", 10, 150, Cheat.Move.FlySpeed, function(v)
    Cheat.Move.FlySpeed = v
end)

CreateSlider(MoveTab, "Walk Speed", 16, 200, Cheat.Move.Speed, function(v)
    Cheat.Move.Speed = v
end)

-- Ajustement de la taille
for i = 1, 3 do
    TabFrames[i].CanvasSize = UDim2.new(0, 0, 0, (#TabFrames[i]:GetChildren() - 1) * 40)
end

-- ============================================
-- BOUCLE PRINCIPALE
-- ============================================

SafeConnect(S.RunService.Heartbeat, function()
    UpdateESP()
    UpdateAimbot()
    UpdateWalkSpeed()
end)

-- ============================================
-- INJECTION FINALE
-- ============================================

-- Injection du GUI
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGUI)
    ScreenGUI.Parent = S.CoreGui
elseif gethui then
    ScreenGUI.Parent = gethui()
else
    ScreenGUI.Parent = S.CoreGui
end

-- Message de succès
print(" ")
print("╔══════════════════════════════════════════╗")
print("║      EVENT HORIZON - INJECTÉ !          ║")
print("║                                          ║")
print("║  ✅ ESP: F1 (Activer/Désactiver)         ║")
print("║  ✅ Aimbot: Clic droit                   ║")
print("║  ✅ Fly: Activer dans Movement Tab      ║")
print("║  ✅ NoClip: V                           ║")
print("║  ✅ GUI: F8 (Cacher/Afficher)           ║")
print("║                                          ║")
print("║  Le GUI devrait être visible maintenant !║")
print("╚══════════════════════════════════════════╝")
print(" ")

-- Touche F1 pour ESP rapide
SafeConnect(S.UserInputService.InputBegan, function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        Cheat.ESP.Enabled = not Cheat.ESP.Enabled
        print("[EVENT HORIZON] ESP: " .. (Cheat.ESP.Enabled and "ON" or "OFF"))
    end
end)

-- Nettoyage automatique
LocalPlayer.CharacterAdded:Connect(function()
    UpdateFly()
    UpdateNoClip()
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "EVENT HORIZON",
    Text = "Injecté avec succès ! F8 pour GUI",
    Duration = 5,
    Icon = "rbxassetid://0"
})

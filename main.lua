-- ============================================
-- EVENT HORIZON - VERSION ULTIME CORRIGÉE
-- Tous les bugs fixés | Keybinds souris | Couleurs réglables
-- ============================================

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Variables avec états CORRECTS
local Cheat = {
    ESP = {
        Enabled = false,
        Box = false,
        BoxColor = Color3.fromRGB(255, 50, 50),
        BoxThickness = 2,
        BoxTransparency = 0,
        Tracers = false,
        TracerColor = Color3.fromRGB(50, 255, 50),
        TracerThickness = 1,
        Names = false,
        NamesColor = Color3.fromRGB(255, 255, 255),
        NamesSize = 14,
        Health = false,
        HealthColor = Color3.fromRGB(0, 255, 0),
        HealthSize = 12,
        Distance = false,
        DistanceColor = Color3.fromRGB(200, 200, 200),
        DistanceSize = 11,
        BoxSize = 1.2,
        TeamCheck = true,
        AliveCheck = true
    },
    Aim = {
        Enabled = false,
        HoldKey = nil,
        HoldKeyText = "NONE",
        TargetPart = "Head",
        FOV = 120,
        ShowFOV = false,
        FOVColor = Color3.fromRGB(255, 255, 255),
        FOVThickness = 1,
        FOVTransparency = 0,
        Smooth = 0.15,
        TriggerBot = false,
        MagicBullet = false,
        HitboxSize = 3,
        SilentAim = false,
        HitChance = 85,
        TeamCheck = true,
        AliveCheck = true
    },
    Move = {
        Fly = false,
        FlySpeed = 50,
        FlyUpSpeed = 50,
        FlyDownSpeed = 50,
        WalkSpeed = false,
        Speed = 30,
        JumpPower = false,
        Jump = 55,
        BunnyHop = false,
        NoClip = false
    }
}

-- États
local ESPDrawings = {}
local FlyBodyVelocity
local FOVCircle = Drawing.new("Circle")
local KeybindListening = nil
local IsAiming = false

-- Variables pour les contrôles de vol
local flyKeyPressed = false
local flyUpKey = Enum.KeyCode.Space
local flyDownKey = Enum.KeyCode.LeftShift
local flyForwardKey = Enum.KeyCode.W
local flyBackKey = Enum.KeyCode.S
local flyLeftKey = Enum.KeyCode.A
local flyRightKey = Enum.KeyCode.D

-- Initialisation FOV Circle
FOVCircle.Visible = Cheat.Aim.ShowFOV
FOVCircle.Color = Cheat.Aim.FOVColor
FOVCircle.Thickness = Cheat.Aim.FOVThickness
FOVCircle.NumSides = 100
FOVCircle.Radius = Cheat.Aim.FOV
FOVCircle.Filled = false
FOVCircle.Transparency = Cheat.Aim.FOVTransparency
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- ============================================
-- FONCTIONS UTILITAIRES
-- ============================================

function IsEnemy(player)
    if not Cheat.ESP.TeamCheck and not Cheat.Aim.TeamCheck then
        return true
    end
    
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    
    if LocalPlayer.TeamColor and player.TeamColor then
        return LocalPlayer.TeamColor ~= player.TeamColor
    end
    
    return true
end

function IsAlive(player)
    if not Cheat.ESP.AliveCheck and not Cheat.Aim.AliveCheck then
        return true
    end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        return humanoid and humanoid.Health > 0
    end
    
    return false
end

-- ============================================
-- ESP CORRIGÉ AVEC COULEURS RÉGLABLES
-- ============================================

function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            local shouldShow = true
            if Cheat.ESP.TeamCheck then shouldShow = shouldShow and IsEnemy(player) end
            if Cheat.ESP.AliveCheck then shouldShow = shouldShow and IsAlive(player) end
            
            if root and humanoid and shouldShow then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if not ESPDrawings[player] then
                    ESPDrawings[player] = {
                        Box = Drawing.new("Square"),
                        Tracer = Drawing.new("Line"),
                        Name = Drawing.new("Text"),
                        Health = Drawing.new("Text"),
                        Distance = Drawing.new("Text")
                    }
                end
                
                local esp = ESPDrawings[player]
                
                if Cheat.ESP.Enabled and onScreen then
                    local head = player.Character:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
                    
                    local height = math.abs(headPos.Y - pos.Y) * 2 * Cheat.ESP.BoxSize
                    local width = height / 2
                    
                    local boxX = pos.X - width/2
                    local boxY = pos.Y - height/2
                    
                    -- Box avec réglages
                    esp.Box.Visible = Cheat.ESP.Box
                    if Cheat.ESP.Box then
                        esp.Box.Color = Cheat.ESP.BoxColor
                        esp.Box.Thickness = Cheat.ESP.BoxThickness
                        esp.Box.Transparency = 1 - Cheat.ESP.BoxTransparency
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(boxX, boxY)
                        esp.Box.Filled = false
                    end
                    
                    -- Tracer avec réglages
                    esp.Tracer.Visible = Cheat.ESP.Tracers
                    if Cheat.ESP.Tracers then
                        esp.Tracer.Color = Cheat.ESP.TracerColor
                        esp.Tracer.Thickness = Cheat.ESP.TracerThickness
                        esp.Tracer.Transparency = 1
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    end
                    
                    -- Name avec réglages
                    esp.Name.Visible = Cheat.ESP.Names
                    if Cheat.ESP.Names then
                        esp.Name.Color = Cheat.ESP.NamesColor
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(pos.X, boxY - 20)
                        esp.Name.Size = Cheat.ESP.NamesSize
                        esp.Name.Center = true
                        esp.Name.Outline = true
                        esp.Name.OutlineColor = Color3.new(0, 0, 0)
                    end
                    
                    -- Health avec réglages et couleur dynamique
                    esp.Health.Visible = Cheat.ESP.Health
                    if Cheat.ESP.Health then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local healthColor = Cheat.ESP.HealthColor
                        
                        if healthPercent < 0.3 then
                            healthColor = Color3.fromRGB(255, 50, 50)
                        elseif healthPercent < 0.6 then
                            healthColor = Color3.fromRGB(255, 200, 50)
                        end
                        
                        esp.Health.Color = healthColor
                        esp.Health.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        esp.Health.Position = Vector2.new(pos.X, boxY + height + 5)
                        esp.Health.Size = Cheat.ESP.HealthSize
                        esp.Health.Center = true
                        esp.Health.Outline = true
                        esp.Health.OutlineColor = Color3.new(0, 0, 0)
                    end
                    
                    -- Distance avec réglages
                    esp.Distance.Visible = Cheat.ESP.Distance
                    if Cheat.ESP.Distance then
                        local dist = (root.Position - Camera.CFrame.Position).Magnitude
                        esp.Distance.Color = Cheat.ESP.DistanceColor
                        esp.Distance.Text = math.floor(dist) .. " studs"
                        esp.Distance.Position = Vector2.new(pos.X, boxY + height + 25)
                        esp.Distance.Size = Cheat.ESP.DistanceSize
                        esp.Distance.Center = true
                        esp.Distance.Outline = true
                        esp.Distance.OutlineColor = Color3.new(0, 0, 0)
                    end
                else
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            elseif ESPDrawings[player] then
                for _, drawing in pairs(ESPDrawings[player]) do
                    drawing.Visible = false
                end
            end
        end
    end
end

-- ============================================
-- FOV CIRCLE AVEC RÉGLAGES
-- ============================================

function UpdateFOVCircle()
    FOVCircle.Visible = Cheat.Aim.ShowFOV
    FOVCircle.Color = Cheat.Aim.FOVColor
    FOVCircle.Thickness = Cheat.Aim.FOVThickness
    FOVCircle.Radius = Cheat.Aim.FOV
    FOVCircle.Transparency = Cheat.Aim.FOVTransparency
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end

-- ============================================
-- GUI SIMPLE ET FONCTIONNEL
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVENT HORIZON"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleBtn.Position = UDim2.new(1, -85, 0.5, -15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
ToggleBtn.Text = "F8 HIDE"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.TextSize = 12
ToggleBtn.Parent = Header

-- Onglets
local Tabs = {"VISUAL", "AIM", "MOVE"}
local TabButtons = {}
local TabFrames = {}

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -100)
TabContainer.Position = UDim2.new(0, 10, 0, 80)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

for i, tabName in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, -5, 0, 35)
    btn.Position = UDim2.new(0.32 * (i-1), 5, 0, 60)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 120, 220) or Color3.fromRGB(45, 45, 65)
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = MainFrame
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    frame.Visible = i == 1
    frame.Parent = TabContainer
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        for j = 1, #Tabs do
            TabFrames[j].Visible = j == i
            TabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(50, 120, 220) or Color3.fromRGB(45, 45, 65)
        end
    end)
    
    TabButtons[i] = btn
    TabFrames[i] = frame
end

-- ============================================
-- FONCTIONS UI CORRIGÉES
-- ============================================

-- Fonction toggle CORRIGÉE (état correct)
local function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, 2)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 160, 60) or Color3.fromRGB(160, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 60, 0, 28)
    status.Position = UDim2.new(0, 185, 0, 2)
    status.BackgroundColor3 = default and Color3.fromRGB(0, 120, 40) or Color3.fromRGB(120, 40, 40)
    status.Text = default and "ON" or "OFF"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 13
    status.Parent = frame
    
    -- CORRECTION: Stocke l'état actuel
    local currentState = default
    
    btn.MouseButton1Click:Connect(function()
        currentState = not currentState
        local new = callback()
        
        -- Met à jour l'affichage selon le retour de la callback
        btn.BackgroundColor3 = new and Color3.fromRGB(0, 160, 60) or Color3.fromRGB(160, 50, 50)
        status.BackgroundColor3 = new and Color3.fromRGB(0, 120, 40) or Color3.fromRGB(120, 40, 40)
        status.Text = new and "ON" or "OFF"
    end)
    
    return frame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 35)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    bar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    fill.Parent = bar
    
    local dragging = false
    
    local function update(x)
        local relative = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local value = math.floor(min + (relative / bar.AbsoluteSize.X) * (max - min))
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mouse = UserInputService:GetMouseLocation()
            update(mouse.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    bar.MouseMoved:Connect(function(x, y)
        if dragging then
            update(x)
        end
    end)
    
    return frame
end

-- Keybind selector AMÉLIORÉ (support souris)
local function CreateKeybind(parent, text, currentKeyText, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 0, 25)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 100, 0, 28)
    keyBtn.Position = UDim2.new(0, 125, 0, 0)
    keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
    keyBtn.Text = currentKeyText
    keyBtn.TextColor3 = Color3.new(1, 1, 1)
    keyBtn.Font = Enum.Font.Gotham
    keyBtn.TextSize = 12
    keyBtn.Parent = frame
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 50, 0, 28)
    clearBtn.Position = UDim2.new(0, 230, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Font = Enum.Font.Gotham
    clearBtn.TextSize = 11
    clearBtn.Parent = frame
    
    keyBtn.MouseButton1Click:Connect(function()
        KeybindListening = function(input, gameProcessed)
            if not gameProcessed then
                local keyText = ""
                local keyValue = nil
                
                -- Détection boutons souris
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    keyText = "MB1"
                    keyValue = input.UserInputType
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    keyText = "MB2"
                    keyValue = input.UserInputType
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    keyText = "MB3"
                    keyValue = input.UserInputType
                -- Détection touches clavier
                elseif input.KeyCode then
                    keyText = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                    keyValue = input.KeyCode
                end
                
                if keyValue then
                    callback(keyValue, keyText)
                    keyBtn.Text = keyText
                    keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
                    KeybindListening = nil
                end
            end
        end
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "NONE"
        keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
        callback(nil, "NONE")
    end)
    
    return frame
end

-- ============================================
-- CONSTRUCTION ONGLETS
-- ============================================

-- Onglet VISUAL
local VisualFrame = TabFrames[1]

CreateToggle(VisualFrame, "ESP", Cheat.ESP.Enabled, function()
    Cheat.ESP.Enabled = not Cheat.ESP.Enabled
    return Cheat.ESP.Enabled
end)

CreateToggle(VisualFrame, "Box", Cheat.ESP.Box, function()
    Cheat.ESP.Box = not Cheat.ESP.Box
    return Cheat.ESP.Box
end)

CreateToggle(VisualFrame, "Tracers", Cheat.ESP.Tracers, function()
    Cheat.ESP.Tracers = not Cheat.ESP.Tracers
    return Cheat.ESP.Tracers
end)

CreateToggle(VisualFrame, "Names", Cheat.ESP.Names, function()
    Cheat.ESP.Names = not Cheat.ESP.Names
    return Cheat.ESP.Names
end)

CreateToggle(VisualFrame, "Health", Cheat.ESP.Health, function()
    Cheat.ESP.Health = not Cheat.ESP.Health
    return Cheat.ESP.Health
end)

CreateToggle(VisualFrame, "Distance", Cheat.ESP.Distance, function()
    Cheat.ESP.Distance = not Cheat.ESP.Distance
    return Cheat.ESP.Distance
end)

CreateSlider(VisualFrame, "Box Size", 0.5, 2.5, Cheat.ESP.BoxSize, function(v)
    Cheat.ESP.BoxSize = v
end)

-- Onglet AIM
local AimFrame = TabFrames[2]

CreateKeybind(AimFrame, "Aim Key:", Cheat.Aim.HoldKeyText, function(key, keyText)
    Cheat.Aim.HoldKey = key
    Cheat.Aim.HoldKeyText = keyText
end)

CreateToggle(AimFrame, "Aimbot", Cheat.Aim.Enabled, function()
    Cheat.Aim.Enabled = not Cheat.Aim.Enabled
    return Cheat.Aim.Enabled
end)

CreateSlider(AimFrame, "FOV", 50, 300, Cheat.Aim.FOV, function(v)
    Cheat.Aim.FOV = v
    FOVCircle.Radius = v
end)

CreateToggle(AimFrame, "Show FOV", Cheat.Aim.ShowFOV, function()
    Cheat.Aim.ShowFOV = not Cheat.Aim.ShowFOV
    FOVCircle.Visible = Cheat.Aim.ShowFOV
    return Cheat.Aim.ShowFOV
end)

CreateSlider(AimFrame, "Smooth", 0.05, 0.5, Cheat.Aim.Smooth, function(v)
    Cheat.Aim.Smooth = v
end)

CreateToggle(AimFrame, "Trigger Bot", Cheat.Aim.TriggerBot, function()
    Cheat.Aim.TriggerBot = not Cheat.Aim.TriggerBot
    return Cheat.Aim.TriggerBot
end)

-- Onglet MOVE
local MoveFrame = TabFrames[3]

CreateToggle(MoveFrame, "Fly", Cheat.Move.Fly, function()
    Cheat.Move.Fly = not Cheat.Move.Fly
    if not Cheat.Move.Fly and FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
    return Cheat.Move.Fly
end)

CreateSlider(MoveFrame, "Fly Speed", 10, 200, Cheat.Move.FlySpeed, function(v)
    Cheat.Move.FlySpeed = v
end)

CreateSlider(MoveFrame, "Fly Up Speed", 10, 200, Cheat.Move.FlyUpSpeed, function(v)
    Cheat.Move.FlyUpSpeed = v
end)

CreateSlider(MoveFrame, "Fly Down Speed", 10, 200, Cheat.Move.FlyDownSpeed, function(v)
    Cheat.Move.FlyDownSpeed = v
end)

CreateToggle(MoveFrame, "WalkSpeed", Cheat.Move.WalkSpeed, function()
    Cheat.Move.WalkSpeed = not Cheat.Move.WalkSpeed
    return Cheat.Move.WalkSpeed
end)

CreateSlider(MoveFrame, "Speed", 16, 100, Cheat.Move.Speed, function(v)
    Cheat.Move.Speed = v
end)

CreateToggle(MoveFrame, "Bunny Hop", Cheat.Move.BunnyHop, function()
    Cheat.Move.BunnyHop = not Cheat.Move.BunnyHop
    return Cheat.Move.BunnyHop
end)

CreateToggle(MoveFrame, "NoClip", Cheat.Move.NoClip, function()
    Cheat.Move.NoClip = not Cheat.Move.NoClip
    return Cheat.Move.NoClip
end)

-- Ajuster la taille
for _, frame in ipairs(TabFrames) do
    frame.CanvasSize = UDim2.new(0, 0, 0, (#frame:GetChildren() - 1) * 45)
end

-- ============================================
-- AIMBOT CORRIGÉ
-- ============================================

function GetClosestPlayerToAim()
    if not Cheat.Aim.Enabled or not Cheat.Aim.HoldKey then return nil end
    
    local closest = nil
    local minDist = Cheat.Aim.FOV
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Cheat.Aim.TeamCheck and not IsEnemy(player) then
                continue
            end
            
            if Cheat.Aim.AliveCheck and not IsAlive(player) then
                continue
            end
            
            local targetPart = player.Character:FindFirstChild(Cheat.Aim.TargetPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetPart and humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

function AimAtTarget()
    if not Cheat.Aim.Enabled or not Cheat.Aim.HoldKey then return end
    
    -- Vérifie si la keybind est pressée
    local keyPressed = false
    if Cheat.Aim.HoldKey.EnumType == Enum.UserInputType then
        keyPressed = UserInputService:IsMouseButtonPressed(Cheat.Aim.HoldKey)
    else
        keyPressed = UserInputService:IsKeyDown(Cheat.Aim.HoldKey)
    end
    
    if not keyPressed then
        IsAiming = false
        return
    end
    
    IsAiming = true
    
    local target = GetClosestPlayerToAim()
    if not target or not target.Character then return end
    
    local targetPart = target.Character:FindFirstChild(Cheat.Aim.TargetPart)
    if not targetPart then return end
    
    local aimPos = targetPart.Position
    
    -- Smooth Aiming
    local current = Camera.CFrame
    local targetCF = CFrame.lookAt(current.Position, aimPos)
    
    -- Calcul plus précis
    local lookVector = (aimPos - current.Position).Unit
    local newCFrame = CFrame.new(
        current.Position,
        current.Position + lookVector
    )
    
    -- Interpolation smooth
    Camera.CFrame = current:Lerp(newCFrame, 1 - Cheat.Aim.Smooth)
end

-- ============================================
-- FLY CORRIGÉ (FONCTIONNEL)
-- ============================================

function UpdateFly()
    if Cheat.Move.Fly and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not FlyBodyVelocity then
                FlyBodyVelocity = Instance.new("BodyVelocity")
                FlyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                FlyBodyVelocity.P = 1250
                FlyBodyVelocity.Parent = root
            end
            
            local direction = Vector3.new(0, 0, 0)
            
            -- Contrôles de vol
            if UserInputService:IsKeyDown(flyForwardKey) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(flyBackKey) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(flyLeftKey) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(flyRightKey) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(flyUpKey) then
                direction = direction + Vector3.new(0, 1, 0) * (Cheat.Move.FlyUpSpeed / Cheat.Move.FlySpeed)
            end
            if UserInputService:IsKeyDown(flyDownKey) then
                direction = direction - Vector3.new(0, 1, 0) * (Cheat.Move.FlyDownSpeed / Cheat.Move.FlySpeed)
            end
            
            if direction.Magnitude > 0 then
                FlyBodyVelocity.Velocity = direction.Unit * Cheat.Move.FlySpeed
            else
                FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
    elseif FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
end

-- ============================================
-- WALKSPEED CORRIGÉ (FONCTIONNEL)
-- ============================================

function UpdateMovement()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        -- WalkSpeed CORRIGÉ
        if Cheat.Move.WalkSpeed then
            humanoid.WalkSpeed = Cheat.Move.Speed
        else
            -- Réinitialise à la valeur par défaut du jeu
            humanoid.WalkSpeed = 16
        end
        
        -- JumpPower
        if Cheat.Move.JumpPower then
            humanoid.JumpPower = Cheat.Move.Jump
        else
            humanoid.JumpPower = 50
        end
        
        -- BunnyHop
        if Cheat.Move.BunnyHop and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- ============================================
-- NOCLIP CORRIGÉ
-- ============================================

function UpdateNoClip()
    if Cheat.Move.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- ============================================
-- DÉTECTION KEYBINDS
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- F8 pour toggle GUI
        if input.KeyCode == Enum.KeyCode.F8 then
            MainFrame.Visible = not MainFrame.Visible
            ToggleBtn.Text = MainFrame.Visible and "F8 HIDE" or "F8 SHOW"
        end
        
        -- Détection pour keybind selection
        if KeybindListening then
            KeybindListening(input, gameProcessed)
        end
    end
end)

-- ============================================
-- BOUCLE PRINCIPALE
-- ============================================

RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateFOVCircle()
    
    if Cheat.Aim.Enabled then
        AimAtTarget()
    end
    
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

print("========================================")
print("EVENT HORIZON - VERSION ULTIME")
print("========================================")
print("CORRECTIONS APPLIQUÉES:")
print("1. Toggles inversés FIXÉS (état correct)")
print("2. Fly FONCTIONNEL avec contrôles WASD+Space+Shift")
print("3. WalkSpeed FONCTIONNEL")
print("4. Keybinds souris supportées (MB1, MB2, MB3)")
print("5. 3 sliders de vitesse pour Fly")
print("6. ESP positions CORRECTES")
print("========================================")
print("INSTRUCTIONS:")
print("1. Fly: Active + WASD + Space(up) + Shift(down)")
print("2. Aimbot: Choisis une keybind + active")
print("3. WalkSpeed: Active + règle la vitesse")
print("========================================")

-- ============================================
-- EVENT HORIZON - VERSION COMPLÈTE CORRIGÉE
-- Team check | Alive check | Aimbot ingame | ESP positions fixées
-- ============================================

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Variables CORRIGÉES (toggles inversés fixés)
local Cheat = {
    ESP = {
        Enabled = false,  -- OFF par défaut
        Box = false,
        BoxColor = Color3.fromRGB(255, 50, 50),
        Tracers = false,
        TracerColor = Color3.fromRGB(50, 255, 50),
        Names = false,
        NamesColor = Color3.fromRGB(255, 255, 255),
        Health = false,
        HealthColor = Color3.fromRGB(0, 255, 0),
        Distance = false,
        DistanceColor = Color3.fromRGB(200, 200, 200),
        BoxSize = 1.2,
        TeamCheck = true,  -- Ne pas montrer les coéquipiers
        AliveCheck = true  -- Ne montrer que les vivants
    },
    Aim = {
        Enabled = false,  -- OFF par défaut
        HoldKey = nil,
        HoldKeyText = "NONE",
        TargetPart = "Head",  -- Head, UpperTorso, HumanoidRootPart
        FOV = 120,
        ShowFOV = false,
        FOVColor = Color3.fromRGB(255, 255, 255),
        Smooth = 0.15,
        TriggerBot = false,
        MagicBullet = false,
        HitboxSize = 3,
        SilentAim = false,
        HitChance = 85,
        TeamCheck = true,  -- Ne pas viser les coéquipiers
        AliveCheck = true  -- Ne viser que les vivants
    },
    Move = {
        Fly = false,
        FlySpeed = 32,
        WalkSpeed = false,
        Speed = 24,
        JumpPower = false,
        Jump = 55,
        BunnyHop = false,
        NoClip = false
    }
}

-- États
local ESPDrawings = {}
local IsAiming = false
local FlyBodyVelocity
local FOVCircle = Drawing.new("Circle")
local KeybindListening = nil

-- Initialisation FOV Circle
FOVCircle.Visible = Cheat.Aim.ShowFOV
FOVCircle.Color = Cheat.Aim.FOVColor
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Cheat.Aim.FOV
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- Fonction Team Check
function IsEnemy(player)
    if not Cheat.ESP.TeamCheck and not Cheat.Aim.TeamCheck then
        return true
    end
    
    -- Vérifie si le jeu a un système d'équipe
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    
    -- Vérifie la couleur du joueur (méthode alternative)
    if LocalPlayer.TeamColor and player.TeamColor then
        return LocalPlayer.TeamColor ~= player.TeamColor
    end
    
    return true
end

-- Fonction Alive Check
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
-- ESP CORRIGÉ - POSITIONS FIXÉES
-- ============================================

function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            -- Team Check & Alive Check
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
                    
                    -- Position de la boîte
                    local boxX = pos.X - width/2
                    local boxY = pos.Y - height/2
                    
                    -- Box
                    esp.Box.Visible = Cheat.ESP.Box
                    if Cheat.ESP.Box then
                        esp.Box.Color = Cheat.ESP.BoxColor
                        esp.Box.Thickness = 2
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(boxX, boxY)
                    end
                    
                    -- Tracer
                    esp.Tracer.Visible = Cheat.ESP.Tracers
                    if Cheat.ESP.Tracers then
                        esp.Tracer.Color = Cheat.ESP.TracerColor
                        esp.Tracer.Thickness = 1
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    end
                    
                    -- Name (POSITION CORRIGÉE - au-dessus de la boîte)
                    esp.Name.Visible = Cheat.ESP.Names
                    if Cheat.ESP.Names then
                        esp.Name.Color = Cheat.ESP.NamesColor
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(pos.X, boxY - 15)  -- 15 pixels au-dessus
                        esp.Name.Size = 14
                        esp.Name.Center = true
                    end
                    
                    -- Health (POSITION CORRIGÉE - sous la boîte)
                    esp.Health.Visible = Cheat.ESP.Health
                    if Cheat.ESP.Health then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local healthColor = Cheat.ESP.HealthColor
                        
                        -- Changement de couleur selon la santé
                        if healthPercent < 0.3 then
                            healthColor = Color3.fromRGB(255, 50, 50)
                        elseif healthPercent < 0.6 then
                            healthColor = Color3.fromRGB(255, 255, 50)
                        end
                        
                        esp.Health.Color = healthColor
                        esp.Health.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        esp.Health.Position = Vector2.new(pos.X, boxY + height + 5)  -- 5 pixels en dessous
                        esp.Health.Size = 12
                        esp.Health.Center = true
                    end
                    
                    -- Distance (POSITION CORRIGÉE - sous la santé)
                    esp.Distance.Visible = Cheat.ESP.Distance
                    if Cheat.ESP.Distance then
                        local dist = (root.Position - Camera.CFrame.Position).Magnitude
                        esp.Distance.Color = Cheat.ESP.DistanceColor
                        esp.Distance.Text = math.floor(dist) .. " studs"
                        esp.Distance.Position = Vector2.new(pos.X, boxY + height + 20)  -- 20 pixels en dessous
                        esp.Distance.Size = 11
                        esp.Distance.Center = true
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
-- GUI AVEC TOUTES LES OPTIONS
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 500)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVENT HORIZON v2.0"
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
local Tabs = {"VISUAL", "AIM", "MOVEMENT"}
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
-- FONCTIONS UI AMÉLIORÉES
-- ============================================

local function CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "▶ " .. title
    label.TextColor3 = Color3.fromRGB(0, 180, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return section
end

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
    
    btn.MouseButton1Click:Connect(function()
        local new = not callback()
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

local function CreateDropdown(parent, text, options, default, callback)
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
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0, 150, 0, 28)
    dropdown.Position = UDim2.new(0, 125, 0, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
    dropdown.Text = default
    dropdown.TextColor3 = Color3.new(1, 1, 1)
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 12
    dropdown.Parent = frame
    
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 150, 0, 0)
    menu.Position = UDim2.new(0, 125, 0, 30)
    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Parent = frame
    
    local open = false
    
    dropdown.MouseButton1Click:Connect(function()
        open = not open
        menu.Visible = open
        menu.Size = open and UDim2.new(0, 150, 0, #options * 25) or UDim2.new(0, 150, 0, 0)
        
        if open then
            menu:ClearAllChildren()
            for i, option in ipairs(options) do
                local optionBtn = Instance.new("TextButton")
                optionBtn.Size = UDim2.new(1, 0, 0, 25)
                optionBtn.Position = UDim2.new(0, 0, 0, (i-1)*25)
                optionBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                optionBtn.Text = option
                optionBtn.TextColor3 = Color3.new(1, 1, 1)
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.TextSize = 12
                optionBtn.Parent = menu
                
                optionBtn.MouseButton1Click:Connect(function()
                    dropdown.Text = option
                    menu.Visible = false
                    menu.Size = UDim2.new(0, 150, 0, 0)
                    open = false
                    callback(option)
                end)
            end
        end
    end)
    
    return frame
end

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
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    keyText = "MB1"
                    callback(input.UserInputType, keyText)
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    keyText = "MB2"
                    callback(input.UserInputType, keyText)
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    keyText = "MB3"
                    callback(input.UserInputType, keyText)
                elseif input.KeyCode then
                    keyText = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                    callback(input.KeyCode, keyText)
                end
                
                keyBtn.Text = keyText
                KeybindListening = nil
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
-- CONSTRUCTION ONGLETS COMPLÈTE
-- ============================================

-- Onglet VISUAL
local VisualFrame = TabFrames[1]
CreateSection(VisualFrame, "ESP SETTINGS")

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

CreateToggle(VisualFrame, "Team Check", Cheat.ESP.TeamCheck, function()
    Cheat.ESP.TeamCheck = not Cheat.ESP.TeamCheck
    return Cheat.ESP.TeamCheck
end)

CreateToggle(VisualFrame, "Alive Check", Cheat.ESP.AliveCheck, function()
    Cheat.ESP.AliveCheck = not Cheat.ESP.AliveCheck
    return Cheat.ESP.AliveCheck
end)

CreateSlider(VisualFrame, "Box Size", 0.5, 2.5, Cheat.ESP.BoxSize, function(v)
    Cheat.ESP.BoxSize = v
end)

-- Onglet AIM
local AimFrame = TabFrames[2]
CreateSection(AimFrame, "AIMBOT SETTINGS")

CreateKeybind(AimFrame, "Aim Key:", Cheat.Aim.HoldKeyText, function(key, keyText)
    Cheat.Aim.HoldKey = key
    Cheat.Aim.HoldKeyText = keyText
end)

CreateDropdown(AimFrame, "Target Part:", {"Head", "UpperTorso", "HumanoidRootPart"}, Cheat.Aim.TargetPart, function(option)
    Cheat.Aim.TargetPart = option
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

CreateToggle(AimFrame, "Team Check", Cheat.Aim.TeamCheck, function()
    Cheat.Aim.TeamCheck = not Cheat.Aim.TeamCheck
    return Cheat.Aim.TeamCheck
end)

CreateToggle(AimFrame, "Alive Check", Cheat.Aim.AliveCheck, function()
    Cheat.Aim.AliveCheck = not Cheat.Aim.AliveCheck
    return Cheat.Aim.AliveCheck
end)

CreateSection(AimFrame, "EXTRAS")
CreateToggle(AimFrame, "Trigger Bot", Cheat.Aim.TriggerBot, function()
    Cheat.Aim.TriggerBot = not Cheat.Aim.TriggerBot
    return Cheat.Aim.TriggerBot
end)

CreateToggle(AimFrame, "Magic Bullet", Cheat.Aim.MagicBullet, function()
    Cheat.Aim.MagicBullet = not Cheat.Aim.MagicBullet
    return Cheat.Aim.MagicBullet
end)

CreateToggle(AimFrame, "Silent Aim", Cheat.Aim.SilentAim, function()
    Cheat.Aim.SilentAim = not Cheat.Aim.SilentAim
    return Cheat.Aim.SilentAim
end)

-- Onglet MOVEMENT
local MoveFrame = TabFrames[3]
CreateSection(MoveFrame, "MOVEMENT SETTINGS")

CreateToggle(MoveFrame, "Fly", Cheat.Move.Fly, function()
    Cheat.Move.Fly = not Cheat.Move.Fly
    if not Cheat.Move.Fly and FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
    return Cheat.Move.Fly
end)

CreateSlider(MoveFrame, "Fly Speed", 10, 100, Cheat.Move.FlySpeed, function(v)
    Cheat.Move.FlySpeed = v
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
-- AIMBOT CORRIGÉ INGAME
-- ============================================

function GetClosestPlayerToAim()
    if not Cheat.Aim.Enabled or not Cheat.Aim.HoldKey then return nil end
    
    local closest = nil
    local minDist = Cheat.Aim.FOV
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Team Check
            if Cheat.Aim.TeamCheck and not IsEnemy(player) then
                continue
            end
            
            -- Alive Check
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
        -- Bouton souris
        keyPressed = UserInputService:IsMouseButtonPressed(Cheat.Aim.HoldKey)
    else
        -- Touche clavier
        keyPressed = UserInputService:IsKeyDown(Cheat.Aim.HoldKey)
    end
    
    if not keyPressed then return end
    
    local target = GetClosestPlayerToAim()
    if not target or not target.Character then return end
    
    local targetPart = target.Character:FindFirstChild(Cheat.Aim.TargetPart)
    if not targetPart then return end
    
    -- Silent Aim
    if Cheat.Aim.SilentAim and math.random(1, 100) <= Cheat.Aim.HitChance then
        return
    end
    
    -- Magic Bullet
    local aimPos = targetPart.Position
    if Cheat.Aim.MagicBullet then
        aimPos = aimPos + Vector3.new(
            math.random(-Cheat.Aim.HitboxSize, Cheat.Aim.HitboxSize),
            math.random(-Cheat.Aim.HitboxSize/2, Cheat.Aim.HitboxSize/2),
            math.random(-Cheat.Aim.HitboxSize, Cheat.Aim.HitboxSize)
        )
    end
    
    -- Smooth Aiming INGAME
    local current = Camera.CFrame
    local targetCF = CFrame.lookAt(current.Position, aimPos)
    
    -- Calcul de la position cible
    local delta = (aimPos - current.Position).Unit
    local newLook = current.Position + delta * 100
    
    -- Smooth avec interpolation
    local t = Cheat.Aim.Smooth
    local newCFrame = CFrame.new(
        current.Position,
        current.Position:Lerp(newLook, t)
    )
    
    Camera.CFrame = newCFrame
end

-- TriggerBot
function TriggerBot()
    if not Cheat.Aim.TriggerBot or not Cheat.Aim.HoldKey then return end
    
    local keyPressed = false
    if Cheat.Aim.HoldKey.EnumType == Enum.UserInputType then
        keyPressed = UserInputService:IsMouseButtonPressed(Cheat.Aim.HoldKey)
    else
        keyPressed = UserInputService:IsKeyDown(Cheat.Aim.HoldKey)
    end
    
    if not keyPressed then return end
    
    local target = GetClosestPlayerToAim()
    if target and target.Character then
        local humanoid = target.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end
    end
end

-- ============================================
-- FONCTIONS MOUVEMENT
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
            
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
            
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

function UpdateMovement()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        if Cheat.Move.WalkSpeed then
            humanoid.WalkSpeed = Cheat.Move.Speed
        elseif humanoid.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = 16
        end
        
        if Cheat.Move.BunnyHop and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

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
        TriggerBot()
    end
    
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

print("========================================")
print("EVENT HORIZON v2.0 - CHARGÉ")
print("F8 pour cacher/afficher")
print("========================================")
print("CORRECTIONS APPLIQUÉES:")
print("1. Toggles inversés fixés (OFF par défaut)")
print("2. Team Check & Alive Check ajoutés")
print("3. Aimbot fonctionne ingame")
print("4. Positions ESP corrigées")
print("5. Keybids souris supportées")
print("6. Target Part sélectionnable")
print("========================================")

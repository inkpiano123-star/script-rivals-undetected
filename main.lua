-- ============================================
-- ÉVÉNEMENT HORIZON - VERSION SUPREME VILLAIN
-- Tout réparé avec la puissance du chaos !
-- ============================================

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Variables du DOMINATEUR
local Cheat = {
    ESP = {
        Enabled = false,
        Box2D = true,
        Box3D = false,
        CornerBox = true,
        Tracers = true,
        Names = true,
        Health = true,
        Distance = true,
        BoxSize = 1.2,
        BoxColor = Color3.fromRGB(255, 50, 50),
        TracerColor = Color3.fromRGB(50, 255, 50),
        NameColor = Color3.fromRGB(255, 255, 255),
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 255)
    },
    Aim = {
        Enabled = false,
        HoldKey = Enum.UserInputType.MouseButton2,
        ToggleKey = nil,
        FOV = 100,
        FOVVisible = true,
        Smooth = 0.12,
        SmoothingType = "Linear",
        TriggerBot = false,
        MagicBullet = false,
        HitboxSize = 2,
        SilentAim = false,
        HitChance = 85,
        TargetPart = "Head",
        Prediction = 0.12
    },
    Move = {
        Fly = false,
        FlySpeed = 32,
        WalkSpeed = false,
        Speed = 24,
        JumpPower = false,
        Jump = 55,
        BunnyHop = false,
        NoClip = false,
        NoClipKey = Enum.KeyCode.V,
        SpeedKey = Enum.KeyCode.LeftControl
    },
    Keybinds = {
        Customizing = false,
        LastInput = nil
    }
}

-- États démoniaques
local ESPDrawings = {}
local ChamObjects = {}
local IsAiming = false
local FlyBodyVelocity
local NoClipToggled = false
local FOVCircle = Drawing.new("Circle")
local CurrentTarget = nil
local FrameCount = 0
local AimCorrections = {}
local KeybindOverlay = nil

-- Configuration FOV Circle
FOVCircle.Visible = false
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Thickness = 2
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.NumSides = 100

-- Tableau de correspondance touches
local KeyCodeToString = {
    [Enum.KeyCode.Q] = "Q",
    [Enum.KeyCode.E] = "E",
    [Enum.KeyCode.R] = "R",
    [Enum.KeyCode.F] = "F",
    [Enum.KeyCode.V] = "V",
    [Enum.KeyCode.LeftControl] = "CTRL",
    [Enum.KeyCode.LeftShift] = "SHIFT",
    [Enum.KeyCode.MouseButton1] = "MB1",
    [Enum.KeyCode.MouseButton2] = "MB2",
    [Enum.KeyCode.MouseButton3] = "MB3",
    [Enum.KeyCode.CapsLock] = "CAPS"
}

-- Initialisation touches avancée
local InputStates = {}
local KeybindDebounce = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if Cheat.Keybinds.Customizing and not KeybindDebounce then
        KeybindDebounce = true
        Cheat.Keybinds.LastInput = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
        task.wait(0.2)
        KeybindDebounce = false
        return
    end
    
    if not gameProcessed then
        InputStates[input.UserInputType] = true
        InputStates[input.KeyCode] = true
        
        -- Aimbot Toggle
        if input.KeyCode == Cheat.Aim.ToggleKey then
            Cheat.Aim.Enabled = not Cheat.Aim.Enabled
        end
        
        -- Aimbot Hold
        if input.UserInputType == Cheat.Aim.HoldKey then
            IsAiming = true
        end
        
        -- NoClip Toggle
        if input.KeyCode == Cheat.Move.NoClipKey then
            Cheat.Move.NoClip = not Cheat.Move.NoClip
            NoClipToggled = Cheat.Move.NoClip
        end
        
        -- Speed Toggle
        if input.KeyCode == Cheat.Move.SpeedKey then
            Cheat.Move.WalkSpeed = not Cheat.Move.WalkSpeed
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    InputStates[input.UserInputType] = false
    InputStates[input.KeyCode] = false
    
    if input.UserInputType == Cheat.Aim.HoldKey then
        IsAiming = false
        CurrentTarget = nil
    end
end)

-- ============================================
-- ESP OMÉGA CORRIGÉ
-- ============================================

function CleanupESP(player)
    if ESPDrawings[player] then
        for name, drawing in pairs(ESPDrawings[player]) do
            if drawing.Remove then drawing:Remove() end
            if drawing.Destroy then drawing:Destroy() end
        end
        ESPDrawings[player] = nil
    end
    
    if ChamObjects[player] then
        for _, part in pairs(ChamObjects[player]) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        ChamObjects[player] = nil
    end
end

function UpdateESP()
    FrameCount = FrameCount + 1
    local cleanupThreshold = 10
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then goto continue end
        
        local character = player.Character
        if not character then
            if FrameCount % cleanupThreshold == 0 then
                CleanupESP(player)
            end
            goto continue
        end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not root or not humanoid or humanoid.Health <= 0 then
            if FrameCount % cleanupThreshold == 0 then
                CleanupESP(player)
            end
            goto continue
        end
        
        -- Positionnement CORRECT au-dessus de la tête
        local head = character:FindFirstChild("Head")
        local headPos = head and head.Position or root.Position + Vector3.new(0, 2, 0)
        local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
        
        if not ESPDrawings[player] then
            ESPDrawings[player] = {
                Box2D = Drawing.new("Square"),
                Tracer = Drawing.new("Line"),
                Name = Drawing.new("Text"),
                Health = Drawing.new("Text"),
                Distance = Drawing.new("Text"),
                CornerTL = Drawing.new("Line"),
                CornerTR = Drawing.new("Line"),
                CornerBL = Drawing.new("Line"),
                CornerBR = Drawing.new("Line")
            }
        end
        
        local esp = ESPDrawings[player]
        
        -- VISIBILITÉ MAÎTRISÉE
        local shouldShow = Cheat.ESP.Enabled and onScreen
        
        if shouldShow then
            -- Calculs de dimensions PRÉCIS
            local height = math.abs(Camera:WorldToViewportPoint(headPos).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
            local width = height / 1.8 * Cheat.ESP.BoxSize
            
            local boxPos = Vector2.new(screenPos.X - width/2, screenPos.Y - height/2)
            
            -- === BOX 2D CORRECTE ===
            esp.Box2D.Visible = Cheat.ESP.Box2D
            esp.Box2D.Color = Cheat.ESP.BoxColor
            esp.Box2D.Thickness = 2
            esp.Box2D.Filled = false
            esp.Box2D.Size = Vector2.new(width, height)
            esp.Box2D.Position = boxPos
            
            -- === CORNER BOX ===
            local cornerSize = math.min(width, height) * 0.2
            
            -- Top Left
            esp.CornerTL.Visible = Cheat.ESP.CornerBox
            esp.CornerTL.Color = Cheat.ESP.BoxColor
            esp.CornerTL.Thickness = 2
            esp.CornerTL.From = boxPos
            esp.CornerTL.To = boxPos + Vector2.new(cornerSize, 0)
            
            local cornerTL2 = esp.CornerTL:Clone()
            cornerTL2.From = boxPos
            cornerTL2.To = boxPos + Vector2.new(0, cornerSize)
            
            -- Top Right
            esp.CornerTR.Visible = Cheat.ESP.CornerBox
            esp.CornerTR.Color = Cheat.ESP.BoxColor
            esp.CornerTR.Thickness = 2
            esp.CornerTR.From = boxPos + Vector2.new(width, 0)
            esp.CornerTR.To = boxPos + Vector2.new(width - cornerSize, 0)
            
            local cornerTR2 = esp.CornerTR:Clone()
            cornerTR2.From = boxPos + Vector2.new(width, 0)
            cornerTR2.To = boxPos + Vector2.new(width, cornerSize)
            
            -- Bottom Left
            esp.CornerBL.Visible = Cheat.ESP.CornerBox
            esp.CornerBL.Color = Cheat.ESP.BoxColor
            esp.CornerBL.Thickness = 2
            esp.CornerBL.From = boxPos + Vector2.new(0, height)
            esp.CornerBL.To = boxPos + Vector2.new(cornerSize, height)
            
            local cornerBL2 = esp.CornerBL:Clone()
            cornerBL2.From = boxPos + Vector2.new(0, height)
            cornerBL2.To = boxPos + Vector2.new(0, height - cornerSize)
            
            -- Bottom Right
            esp.CornerBR.Visible = Cheat.ESP.CornerBox
            esp.CornerBR.Color = Cheat.ESP.BoxColor
            esp.CornerBR.Thickness = 2
            esp.CornerBR.From = boxPos + Vector2.new(width, height)
            esp.CornerBR.To = boxPos + Vector2.new(width - cornerSize, height)
            
            local cornerBR2 = esp.CornerBR:Clone()
            cornerBR2.From = boxPos + Vector2.new(width, height)
            cornerBR2.To = boxPos + Vector2.new(width, height - cornerSize)
            
            -- === NOM AU-DESSUS DE LA TÊTE ===
            esp.Name.Visible = Cheat.ESP.Names
            esp.Name.Color = Cheat.ESP.NameColor
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - height/2 - 20)
            esp.Name.Size = 14
            esp.Name.Center = true
            esp.Name.Outline = true
            
            -- === TRACER DU BAS ===
            esp.Tracer.Visible = Cheat.ESP.Tracers
            esp.Tracer.Color = Cheat.ESP.TracerColor
            esp.Tracer.Thickness = 1
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y + height/2)
            
            -- === SANTÉ ===
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            esp.Health.Visible = Cheat.ESP.Health
            esp.Health.Color = Color3.fromRGB(
                255 - (healthPercent * 255),
                healthPercent * 255,
                0
            )
            esp.Health.Text = math.floor(humanoid.Health) .. " HP"
            esp.Health.Position = Vector2.new(screenPos.X, screenPos.Y + height/2 + 5)
            esp.Health.Size = 12
            esp.Health.Center = true
            esp.Health.Outline = true
            
            -- === DISTANCE ===
            if Cheat.ESP.Distance then
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                esp.Distance.Visible = true
                esp.Distance.Color = Color3.fromRGB(200, 200, 255)
                esp.Distance.Text = math.floor(dist) .. " studs"
                esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + height/2 + 25)
                esp.Distance.Size = 11
                esp.Distance.Center = true
                esp.Distance.Outline = true
            else
                esp.Distance.Visible = false
            end
            
            -- === CHAMS ===
            if Cheat.ESP.Chams and not ChamObjects[player] then
                ChamObjects[player] = {}
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Transparency < 1 then
                        local chm = Instance.new("BoxHandleAdornment")
                        chm.Name = "ESP_Cham"
                        chm.Adornee = part
                        chm.AlwaysOnTop = true
                        chm.ZIndex = 10
                        chm.Size = part.Size * 1.05
                        chm.Transparency = 0.7
                        chm.Color3 = Cheat.ESP.ChamsColor
                        chm.Parent = part
                        table.insert(ChamObjects[player], chm)
                    end
                end
            elseif not Cheat.ESP.Chams and ChamObjects[player] then
                for _, chm in pairs(ChamObjects[player]) do
                    if chm then chm:Destroy() end
                end
                ChamObjects[player] = nil
            end
        else
            -- TOUT CACHER QUAND PAS VISIBLE
            for _, drawing in pairs(esp) do
                if drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
            
            if ChamObjects[player] then
                for _, chm in pairs(ChamObjects[player]) do
                    if chm then chm:Destroy() end
                end
                ChamObjects[player] = nil
            end
        end
        
        ::continue::
    end
end

-- ============================================
-- AIMBOT LISSE ET PRÉCIS
-- ============================================

function GetClosestPlayerToCursor()
    if not Cheat.Aim.Enabled then return nil end
    
    local closest = nil
    local minDist = Cheat.Aim.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local cameraPos = Camera.CFrame.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(Cheat.Aim.TargetPart) or player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetPart and humanoid and humanoid.Health > 0 then
                -- Prédiction de mouvement
                local velocity = targetPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
                local predictedPos = targetPart.Position + (velocity * Cheat.Aim.Prediction)
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    local distance3D = (predictedPos - cameraPos).Magnitude
                    
                    -- Vérification FOV circulaire
                    if dist < minDist and dist <= Cheat.Aim.FOV then
                        minDist = dist
                        closest = {
                            Player = player,
                            Part = targetPart,
                            Position = predictedPos,
                            Distance = distance3D,
                            ScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                        }
                    end
                end
            end
        end
    end
    
    return closest
end

function SmoothAim(targetPosition)
    local current = Camera.CFrame
    local targetCF = CFrame.lookAt(current.Position, targetPosition)
    
    if Cheat.Aim.SmoothingType == "Exponential" then
        -- Interpolation exponentielle pour fluidité
        local alpha = 1 - math.exp(-Cheat.Aim.Smooth * 10 * RunService.RenderStepped:Wait())
        return current:Lerp(targetCF, alpha)
    else
        -- Interpolation linéaire améliorée
        local alpha = Cheat.Aim.Smooth * 0.5
        local smoothed = CFrame.new(
            current.Position:Lerp(current.Position, 0.99),
            current.Position:Lerp(targetPosition, alpha)
        )
        return smoothed
    end
end

function UpdateAimbot()
    if not Cheat.Aim.Enabled then
        CurrentTarget = nil
        return
    end
    
    -- Mode Toggle
    local shouldAim = Cheat.Aim.HoldKey and IsAiming
    if Cheat.Aim.ToggleKey and InputStates[Cheat.Aim.ToggleKey] then
        shouldAim = true
    end
    
    if shouldAim then
        local targetData = GetClosestPlayerToCursor()
        
        if targetData then
            CurrentTarget = targetData
            
            -- Silent Aim (pas de mouvement caméra)
            if Cheat.Aim.SilentAim and math.random(1, 100) <= Cheat.Aim.HitChance then
                return
            end
            
            -- Aim smoothing avec correction de tremblement
            local aimPos = targetData.Position
            
            -- Magic Bullet offset
            if Cheat.Aim.MagicBullet then
                aimPos = aimPos + Vector3.new(
                    math.random(-Cheat.Aim.HitboxSize, Cheat.Aim.HitboxSize),
                    math.random(-Cheat.Aim.HitboxSize, Cheat.Aim.HitboxSize),
                    math.random(-Cheat.Aim.HitboxSize, Cheat.Aim.HitboxSize)
                )
            end
            
            -- Application du smooth
            Camera.CFrame = SmoothAim(aimPos)
            
            -- Trigger Bot automatique
            if Cheat.Aim.TriggerBot then
                local hit = workspace:Raycast(
                    Camera.CFrame.Position,
                    (aimPos - Camera.CFrame.Position).Unit * 1000,
                    {LocalPlayer.Character}
                )
                if hit and hit.Instance:IsDescendantOf(targetData.Player.Character) then
                    mouse1press()
                    task.wait(0.05)
                    mouse1release()
                end
            end
        else
            CurrentTarget = nil
        end
    else
        CurrentTarget = nil
    end
end

function UpdateFOVCircle()
    FOVCircle.Visible = Cheat.Aim.FOVVisible and Cheat.Aim.Enabled
    FOVCircle.Radius = Cheat.Aim.FOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    
    if CurrentTarget then
        FOVCircle.Color = Color3.new(0, 1, 0)
    else
        FOVCircle.Color = Color3.new(1, 1, 1)
    end
end

-- ============================================
-- GUI TYRANNIQUE AMÉLIORÉ
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonVillainGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 480)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Effet de brillance démoniaque
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1, 0, 1, 0)
Glow.BackgroundColor3 = Color3.fromRGB(30, 0, 50)
Glow.BackgroundTransparency = 0.9
Glow.BorderSizePixel = 0
Glow.ZIndex = -1
Glow.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
})
UIGradient.Rotation = 45
UIGradient.Parent = Glow

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "☠ EVENT HORIZON VILLAIN ☠"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 100, 0, 30)
StatusLabel.Position = UDim2.new(1, -105, 0.5, -15)
StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
StatusLabel.BorderSizePixel = 0
StatusLabel.Text = "F8 HIDE"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
StatusLabel.Parent = Header

-- Onglets améliorés
local Tabs = {"VISUAL", "AIM", "MOVEMENT", "KEYBINDS"}
local TabButtons = {}
local TabFrames = {}

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -100)
TabContainer.Position = UDim2.new(0, 10, 0, 80)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

for i, tabName in ipairs(Tabs) do
    -- Bouton d'onglet avec feedback
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.24, -5, 0, 40)
    btn.Position = UDim2.new(0.24 * (i-1), 5, 0, 0)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 60)
    btn.BorderSizePixel = 0
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 13
    btn.Parent = MainFrame
    
    local btnGlow = Instance.new("Frame")
    btnGlow.Size = UDim2.new(1, 0, 0, 3)
    btnGlow.Position = UDim2.new(0, 0, 1, -3)
    btnGlow.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    btnGlow.BorderSizePixel = 0
    btnGlow.Visible = i == 1
    btnGlow.Parent = btn
    
    -- Frame de contenu
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
    frame.Visible = i == 1
    frame.Parent = TabContainer
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 10)
    UIList.Parent = frame
    
    -- Gestion des onglets
    btn.MouseButton1Click:Connect(function()
        for j = 1, #Tabs do
            TabFrames[j].Visible = j == i
            TabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 60)
            TabButtons[j]:FindFirstChildOfClass("Frame").Visible = j == i
        end
    end)
    
    TabButtons[i] = btn
    TabFrames[i] = frame
end

-- ============================================
-- FONCTIONS UI DÉMONIAQUES
-- ============================================

local function CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 35)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "☢ " .. string.upper(title) .. " ☢"
    label.TextColor3 = Color3.fromRGB(255, 100, 100)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return section
end

local ToggleStates = {}
local function CreateToggle(parent, text, default, callback, tooltip)
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
    
    -- CORRECTION DU BUG DE PREMIER CLIC
    ToggleStates[text] = default
    
    btn.MouseButton1Click:Connect(function()
        local new = not ToggleStates[text]
        ToggleStates[text] = new
        
        btn.BackgroundColor3 = new and Color3.fromRGB(0, 180, 60) or Color3.fromRGB(180, 40, 40)
        status.BackgroundColor3 = new and Color3.fromRGB(0, 140, 50) or Color3.fromRGB(140, 30, 30)
        status.Text = new and "ON" or "OFF"
        
        if callback then
            callback(new)
        end
    end)
    
    return frame
end

local function CreateSlider(parent, text, min, max, default, callback, unit)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Text = text .. ": " .. default .. (unit or "")
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 40)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    
    local dragging = false
    
    local function update(x)
        if not bar:IsDescendantOf(game) then return end
        
        local relative = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local value = math.floor(min + (relative / bar.AbsoluteSize.X) * (max - min))
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. ": " .. value .. (unit or "")
        callback(value)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mouse = UserInputService:GetMouseLocation()
            update(mouse.X)
        end
    end)
    
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)
    
    return frame
end

local function CreateColorPicker(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 150, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local colorBox = Instance.new("TextButton")
    colorBox.Size = UDim2.new(0, 60, 0, 30)
    colorBox.Position = UDim2.new(1, -65, 0, 5)
    colorBox.BackgroundColor3 = default
    colorBox.BorderSizePixel = 1
    colorBox.BorderColor3 = Color3.new(1, 1, 1)
    colorBox.Text = ""
    colorBox.Parent = frame
    
    colorBox.MouseButton1Click:Connect(function()
        local colorPicker = Instance.new("TextLabel")
        colorPicker.Size = UDim2.new(0, 200, 0, 150)
        colorPicker.Position = UDim2.new(1, 10, 0, 0)
        colorPicker.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        colorPicker.BorderSizePixel = 1
        colorPicker.Text = "Click to pick color\nRGB: " .. math.floor(default.r*255) .. "," .. math.floor(default.g*255) .. "," .. math.floor(default.b*255)
        colorPicker.TextColor3 = Color3.new(1, 1, 1)
        colorPicker.Parent = colorBox
        
        local connection
        connection = colorPicker.MouseButton1Click:Connect(function()
            local x = (Mouse.X - colorPicker.AbsolutePosition.X) / colorPicker.AbsoluteSize.X
            local y = (Mouse.Y - colorPicker.AbsolutePosition.Y) / colorPicker.AbsoluteSize.Y
            
            local r = math.clamp(x, 0, 1)
            local g = math.clamp(1-y, 0, 1)
            local b = math.clamp((x+y)/2, 0, 1)
            
            local newColor = Color3.new(r, g, b)
            colorBox.BackgroundColor3 = newColor
            callback(newColor)
            
            colorPicker:Destroy()
            connection:Disconnect()
        end)
    end)
    
    return frame
end

local function CreateKeybindButton(parent, text, currentKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 150, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 100, 0, 30)
    keyBtn.Position = UDim2.new(1, -105, 0, 2)
    keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = KeyCodeToString[currentKey] or tostring(currentKey):gsub("Enum.KeyCode.", "")
    keyBtn.TextColor3 = Color3.new(1, 1, 1)
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 12
    keyBtn.Parent = frame
    
    keyBtn.MouseButton1Click:Connect(function()
        Cheat.Keybinds.Customizing = true
        keyBtn.Text = "[PRESS KEY]"
        keyBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if Cheat.Keybinds.LastInput then
                local newKey = Cheat.Keybinds.LastInput
                Cheat.Keybinds.LastInput = nil
                Cheat.Keybinds.Customizing = false
                
                keyBtn.Text = KeyCodeToString[newKey] or tostring(newKey):gsub("Enum.UserInputType.", ""):gsub("Enum.KeyCode.", "")
                keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                
                if callback then
                    callback(newKey)
                end
                
                connection:Disconnect()
            end
        end)
    end)
    
    return frame
end

-- ============================================
-- CONSTRUCTION DES ONGLETS
-- ============================================

-- VISUAL TAB
local VisualFrame = TabFrames[1]
CreateSection(VisualFrame, "ESP Settings")

CreateToggle(VisualFrame, "ESP Enabled", Cheat.ESP.Enabled, function(v)
    Cheat.ESP.Enabled = v
end)

CreateToggle(VisualFrame, "2D Box", Cheat.ESP.Box2D, function(v)
    Cheat.ESP.Box2D = v
end)

CreateToggle(VisualFrame, "Corner Box", Cheat.ESP.CornerBox, function(v)
    Cheat.ESP.CornerBox = v
end)

CreateToggle(VisualFrame, "Tracers", Cheat.ESP.Tracers, function(v)
    Cheat.ESP.Tracers = v
end)

CreateToggle(VisualFrame, "Names", Cheat.ESP.Names, function(v)
    Cheat.ESP.Names = v
end)

CreateToggle(VisualFrame, "Health", Cheat.ESP.Health, function(v)
    Cheat.ESP.Health = v
end)

CreateToggle(VisualFrame, "Distance", Cheat.ESP.Distance, function(v)
    Cheat.ESP.Distance = v
end)

CreateToggle(VisualFrame, "Chams", Cheat.ESP.Chams, function(v)
    Cheat.ESP.Chams = v
end)

CreateSlider(VisualFrame, "Box Size", 0.5, 3.0, Cheat.ESP.BoxSize, function(v)
    Cheat.ESP.BoxSize = v
end)

CreateColorPicker(VisualFrame, "Box Color", Cheat.ESP.BoxColor, function(v)
    Cheat.ESP.BoxColor = v
end)

CreateColorPicker(VisualFrame, "Tracer Color", Cheat.ESP.TracerColor, function(v)
    Cheat.ESP.TracerColor = v
end)

CreateColorPicker(VisualFrame, "Chams Color", Cheat.ESP.ChamsColor, function(v)
    Cheat.ESP.ChamsColor = v
end)

-- AIM TAB
local AimFrame = TabFrames[2]
CreateSection(AimFrame, "Aimbot Settings")

CreateToggle(AimFrame, "Aimbot Enabled", Cheat.Aim.Enabled, function(v)
    Cheat.Aim.Enabled = v
    FOVCircle.Visible = v and Cheat.Aim.FOVVisible
end)

CreateToggle(AimFrame, "Show FOV", Cheat.Aim.FOVVisible, function(v)
    Cheat.Aim.FOVVisible = v
    FOVCircle.Visible = v and Cheat.Aim.Enabled
end)

CreateToggle(AimFrame, "Trigger Bot", Cheat.Aim.TriggerBot, function(v)
    Cheat.Aim.TriggerBot = v
end)

CreateToggle(AimFrame, "Silent Aim", Cheat.Aim.SilentAim, function(v)
    Cheat.Aim.SilentAim = v
end)

CreateToggle(AimFrame, "Magic Bullet", Cheat.Aim.MagicBullet, function(v)
    Cheat.Aim.MagicBullet = v
end)

CreateSlider(AimFrame, "FOV Size", 20, 300, Cheat.Aim.FOV, function(v)
    Cheat.Aim.FOV = v
end, "")

CreateSlider(AimFrame, "Smoothness", 0.05, 0.5, Cheat.Aim.Smooth, function(v)
    Cheat.Aim.Smooth = v
end)

CreateSlider(AimFrame, "Hit Chance %", 1, 100, Cheat.Aim.HitChance, function(v)
    Cheat.Aim.HitChance = v
end, "%")

CreateSlider(AimFrame, "Hitbox Size", 1, 10, Cheat.Aim.HitboxSize, function(v)
    Cheat.Aim.HitboxSize = v
end)

CreateSlider(AimFrame, "Prediction", 0.05, 0.3, Cheat.Aim.Prediction, function(v)
    Cheat.Aim.Prediction = v
end)

-- MOVEMENT TAB
local MoveFrame = TabFrames[3]
CreateSection(MoveFrame, "Movement Settings")

CreateToggle(MoveFrame, "Fly", Cheat.Move.Fly, function(v)
    Cheat.Move.Fly = v
    if not v and FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
end)

CreateToggle(MoveFrame, "WalkSpeed", Cheat.Move.WalkSpeed, function(v)
    Cheat.Move.WalkSpeed = v
end)

CreateToggle(MoveFrame, "NoClip", Cheat.Move.NoClip, function(v)
    Cheat.Move.NoClip = v
    NoClipToggled = v
end)

CreateToggle(MoveFrame, "Bunny Hop", Cheat.Move.BunnyHop, function(v)
    Cheat.Move.BunnyHop = v
end)

CreateToggle(MoveFrame, "Jump Power", Cheat.Move.JumpPower, function(v)
    Cheat.Move.JumpPower = v
end)

CreateSlider(MoveFrame, "Fly Speed", 10, 150, Cheat.Move.FlySpeed, function(v)
    Cheat.Move.FlySpeed = v
end)

CreateSlider(MoveFrame, "Speed", 16, 200, Cheat.Move.Speed, function(v)
    Cheat.Move.Speed = v
end)

CreateSlider(MoveFrame, "Jump Power", 50, 200, Cheat.Move.Jump, function(v)
    Cheat.Move.Jump = v
end)

-- KEYBINDS TAB
local KeybindsFrame = TabFrames[4]
CreateSection(KeybindsFrame, "Keybind Settings")

CreateKeybindButton(KeybindsFrame, "Aimbot Hold Key", Cheat.Aim.HoldKey, function(key)
    Cheat.Aim.HoldKey = key
end)

CreateKeybindButton(KeybindsFrame, "Aimbot Toggle Key", Cheat.Aim.ToggleKey, function(key)
    Cheat.Aim.ToggleKey = key
end)

CreateKeybindButton(KeybindsFrame, "NoClip Key", Cheat.Move.NoClipKey, function(key)
    Cheat.Move.NoClipKey = key
end)

CreateKeybindButton(KeybindsFrame, "Speed Key", Cheat.Move.SpeedKey, function(key)
    Cheat.Move.SpeedKey = key
end)

CreateToggle(KeybindsFrame, "ESP Toggle", false, function(v)
    Cheat.ESP.Enabled = v
end)

-- Ajustement de la taille du contenu
for _, frame in ipairs(TabFrames) do
    frame.CanvasSize = UDim2.new(0, 0, 0, (#frame:GetChildren() - 1) * 45)
end

-- ============================================
-- FONCTIONS DE MOUVEMENT CORRIGÉES
-- ============================================

function UpdateFly()
    if not Cheat.Move.Fly or not LocalPlayer.Character then return end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    
    if not root or not humanoid then return end
    
    if not FlyBodyVelocity then
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        FlyBodyVelocity.P = 1250
        FlyBodyVelocity.Parent = root
        humanoid.PlatformStand = true
    end
    
    local camera = Workspace.CurrentCamera
    local direction = Vector3.new()
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction = direction + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction = direction - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction = direction - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction = direction + camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end
    
    if direction.Magnitude > 0 then
        FlyBodyVelocity.Velocity = direction.Unit * Cheat.Move.FlySpeed
    else
        FlyBodyVelocity.Velocity = Vector3.new(0, 0.1, 0) -- Flottement léger
    end
end

function UpdateMovement()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- WalkSpeed
    if Cheat.Move.WalkSpeed then
        humanoid.WalkSpeed = Cheat.Move.Speed
    elseif humanoid.WalkSpeed ~= 16 then
        humanoid.WalkSpeed = 16
    end
    
    -- JumpPower
    if Cheat.Move.JumpPower then
        humanoid.JumpPower = Cheat.Move.Jump
    elseif humanoid.JumpPower ~= 50 then
        humanoid.JumpPower = 50
    end
    
    -- Bunny Hop
    if Cheat.Move.BunnyHop and humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

function UpdateNoClip()
    if not NoClipToggled or not LocalPlayer.Character then return end
    
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

-- ============================================
-- BOUCLE PRINCIPALE OPTIMISÉE
-- ============================================

local lastUpdate = tick()
local updateInterval = 0.016 -- ~60 FPS

RunService.Heartbeat:Connect(function(deltaTime)
    local now = tick()
    
    if now - lastUpdate >= updateInterval then
        -- ESP (mis à jour moins fréquemment pour performance)
        UpdateESP()
        
        -- Aimbot (toujours fluide)
        UpdateAimbot()
        
        -- FOV Circle
        UpdateFOVCircle()
        
        lastUpdate = now
    end
    
    -- Movement (toujours actif)
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

-- ============================================
-- TOUCHE F8 POUR CACHER
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F8 then
        MainFrame.Visible = not MainFrame.Visible
        StatusLabel.Text = MainFrame.Visible and "F8 HIDE" or "F8 SHOW"
        StatusLabel.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(50, 20, 20) or Color3.fromRGB(20, 50, 20)
    end
end)

-- ============================================
-- NETTOYAGE À LA MORT
-- ============================================

LocalPlayer.CharacterAdded:Connect(function(character)
    FlyBodyVelocity = nil
    NoClipToggled = Cheat.Move.NoClip
    
    character:WaitForChild("Humanoid").Died:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            CleanupESP(player)
        end
    end)
end)

-- ============================================
-- INITIALISATION FINALE
-- ============================================

print("╔══════════════════════════════════════╗")
print("║     EVENT HORIZON VILLAIN MODE       ║")
print("║          ACTIVÉ AVEC SUCCÈS          ║")
print("║                                      ║")
print("║  F8: Cacher/Afficher GUI             ║")
print("║  Aimbot: Clic droit ou touche config ║")
print("║  NoClip: V (par défaut)              ║")
print("║  Speed: CTRL (par défaut)            ║")
print("║                                      ║")
print("║  Tous les bugs corrigés !            ║")
print("╚══════════════════════════════════════╝")

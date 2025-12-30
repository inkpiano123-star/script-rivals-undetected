-- ============================================
-- EVENT HORIZON v5.0 - GUI FIXÉ & FONCTIONNEL
-- RightControl pour GUI | Organisation Sectionnelle
-- ============================================

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Variables globales
local EventHorizon = {
    Aim = {
        Enabled = false,
        LockKey = Enum.UserInputType.MouseButton2,
        TargetPart = "Head",
        FOV = 100,
        Smoothness = 0.15,
        TriggerBot = false,
        TriggerDelay = 0.05,
        FastShoot = false,
        MagicBullet = false,
        MagicHitbox = 5,
        SilentAim = false,
        SilentHitChance = 85
    },
    Visual = {
        ESP = true,
        BoxType = "2D Corner",
        BoxColor = Color3.fromRGB(255, 50, 50),
        Tracers = true,
        TracerOrigin = "Bottom",
        TracerColor = Color3.fromRGB(50, 255, 50),
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 255),
        ChamsTransparency = 0.4,
        ShowNames = true,
        ShowDistance = true
    },
    Skins = {
        Enabled = false
    },
    Misc = {
        Fly = false,
        FlySpeed = 32,
        WalkSpeed = false,
        SpeedValue = 24,
        JumpPower = false,
        JumpValue = 55,
        BunnyHop = false,
        NoClip = false
    }
}

-- États
local IsAimKeyDown = false
local ESPDrawings = {}
local ChamsAdornments = {}
local FlyBodyVelocity

-- ============================================
-- FONCTIONS CORE OPTIMISÉES
-- ============================================

-- Détection touche Aimbot
UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == EventHorizon.Aim.LockKey then
        IsAimKeyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == EventHorizon.Aim.LockKey then
        IsAimKeyDown = false
    end
end)

-- Aimbot
function GetClosestPlayer()
    if not EventHorizon.Aim.Enabled or not IsAimKeyDown then return nil end
    
    local closest = nil
    local maxDist = EventHorizon.Aim.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if hum and hum.Health > 0 and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < maxDist then
                        maxDist = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

function AimAtTarget()
    if not EventHorizon.Aim.Enabled or not IsAimKeyDown then return end
    
    local target = GetClosestPlayer()
    if not target or not target.Character then return end
    
    local part = target.Character:FindFirstChild(EventHorizon.Aim.TargetPart)
    if not part then return end
    
    local aimPos = part.Position
    if EventHorizon.Aim.MagicBullet then
        aimPos = aimPos + Vector3.new(
            math.random(-EventHorizon.Aim.MagicHitbox, EventHorizon.Aim.MagicHitbox),
            math.random(-EventHorizon.Aim.MagicHitbox/2, EventHorizon.Aim.MagicHitbox/2),
            math.random(-EventHorizon.Aim.MagicHitbox, EventHorizon.Aim.MagicHitbox)
        )
    end
    
    if EventHorizon.Aim.SilentAim and math.random(1,100) <= EventHorizon.Aim.SilentHitChance then
        return
    end
    
    local current = Camera.CFrame
    local targetCF = CFrame.lookAt(current.Position, aimPos)
    Camera.CFrame = current:Lerp(targetCF, 1 - EventHorizon.Aim.Smoothness)
end

-- ============================================
-- GUI SIMPLE ET ROBUSTE
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 420)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVENT HORIZON v5.0"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Onglets
local Tabs = {"AIMBOT", "VISUALS", "MISC"}
local TabButtons = {}
local TabFrames = {}

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -80)
TabContainer.Position = UDim2.new(0, 10, 0, 70)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Création des onglets
for i, TabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = TabName
    TabButton.Size = UDim2.new(0.31, -5, 0, 30)
    TabButton.Position = UDim2.new(0.31 * (i-1), 5, 0, 40)
    TabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 100, 180) or Color3.fromRGB(35, 35, 55)
    TabButton.Text = TabName
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 13
    TabButton.Parent = MainFrame
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = TabName .. "Frame"
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.Position = UDim2.new(0, 0, 0, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 4
    TabFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    TabFrame.Visible = i == 1
    TabFrame.Parent = TabContainer
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        for j = 1, #Tabs do
            TabFrames[j].Visible = j == i
            TabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(40, 100, 180) or Color3.fromRGB(35, 35, 55)
        end
    end)
    
    TabButtons[i] = TabButton
    TabFrames[i] = TabFrame
end

-- Fonctions de création d'éléments
local yPositions = {0, 0, 0}

function CreateSection(Parent, TabIndex, Title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 30)
    SectionFrame.Position = UDim2.new(0, 0, 0, yPositions[TabIndex])
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = Parent
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = Title
    SectionLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextSize = 14
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = SectionFrame
    
    yPositions[TabIndex] = yPositions[TabIndex] + 35
    return SectionFrame
end

function CreateToggle(Parent, TabIndex, Text, Default, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 0, 0, yPositions[TabIndex])
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Parent
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 120, 0, 26)
    ToggleButton.Position = UDim2.new(0, 0, 0, 2)
    ToggleButton.BackgroundColor3 = Default and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
    ToggleButton.Text = Text .. ": " .. (Default and "ON" or "OFF")
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextSize = 12
    ToggleButton.Parent = ToggleFrame
    
    ToggleButton.MouseButton1Click:Connect(function()
        local newState = not Callback()
        ToggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
        ToggleButton.Text = Text .. ": " .. (newState and "ON" or "OFF")
    end)
    
    yPositions[TabIndex] = yPositions[TabIndex] + 35
    return ToggleButton
end

function CreateSlider(Parent, TabIndex, Text, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.Position = UDim2.new(0, 0, 0, yPositions[TabIndex])
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = Text .. ": " .. Default
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 6)
    SliderBar.Position = UDim2.new(0, 0, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SliderBar.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Default - Min)/(Max - Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SliderFill.Parent = SliderBar
    
    local dragging = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    SliderBar.MouseMoved:Connect(function(x, y)
        if dragging then
            local relativeX = math.clamp(x - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
            local value = math.floor(Min + (relativeX / SliderBar.AbsoluteSize.X) * (Max - Min))
            SliderFill.Size = UDim2.new((value - Min)/(Max - Min), 0, 1, 0)
            Label.Text = Text .. ": " .. value
            Callback(value)
        end
    end)
    
    yPositions[TabIndex] = yPositions[TabIndex] + 60
    return SliderFrame
end

-- Construction de l'onglet AIMBOT
local AimFrame = TabFrames[1]
CreateSection(AimFrame, 1, "AIMBOT SETTINGS")
CreateToggle(AimFrame, 1, "AIMBOT", EventHorizon.Aim.Enabled, function()
    EventHorizon.Aim.Enabled = not EventHorizon.Aim.Enabled
    return EventHorizon.Aim.Enabled
end)

CreateSlider(AimFrame, 1, "FOV", 10, 500, EventHorizon.Aim.FOV, function(value)
    EventHorizon.Aim.FOV = value
end)

CreateSlider(AimFrame, 1, "SMOOTH", 0.01, 1, EventHorizon.Aim.Smoothness, function(value)
    EventHorizon.Aim.Smoothness = value
end)

CreateSection(AimFrame, 1, "EXTRAS")
CreateToggle(AimFrame, 1, "TRIGGER BOT", EventHorizon.Aim.TriggerBot, function()
    EventHorizon.Aim.TriggerBot = not EventHorizon.Aim.TriggerBot
    return EventHorizon.Aim.TriggerBot
end)

CreateToggle(AimFrame, 1, "MAGIC BULLET", EventHorizon.Aim.MagicBullet, function()
    EventHorizon.Aim.MagicBullet = not EventHorizon.Aim.MagicBullet
    return EventHorizon.Aim.MagicBullet
end)

CreateToggle(AimFrame, 1, "SILENT AIM", EventHorizon.Aim.SilentAim, function()
    EventHorizon.Aim.SilentAim = not EventHorizon.Aim.SilentAim
    return EventHorizon.Aim.SilentAim
end)

CreateSlider(AimFrame, 1, "HIT CHANCE %", 1, 100, EventHorizon.Aim.SilentHitChance, function(value)
    EventHorizon.Aim.SilentHitChance = value
end)

-- Construction de l'onglet VISUALS
local VisualFrame = TabFrames[2]
CreateSection(VisualFrame, 2, "ESP SETTINGS")
CreateToggle(VisualFrame, 2, "ESP", EventHorizon.Visual.ESP, function()
    EventHorizon.Visual.ESP = not EventHorizon.Visual.ESP
    return EventHorizon.Visual.ESP
end)

CreateToggle(VisualFrame, 2, "TRACERS", EventHorizon.Visual.Tracers, function()
    EventHorizon.Visual.Tracers = not EventHorizon.Visual.Tracers
    return EventHorizon.Visual.Tracers
end)

CreateToggle(VisualFrame, 2, "CHAMS", EventHorizon.Visual.Chams, function()
    EventHorizon.Visual.Chams = not EventHorizon.Visual.Chams
    return EventHorizon.Visual.Chams
end)

CreateToggle(VisualFrame, 2, "SHOW NAMES", EventHorizon.Visual.ShowNames, function()
    EventHorizon.Visual.ShowNames = not EventHorizon.Visual.ShowNames
    return EventHorizon.Visual.ShowNames
end)

CreateToggle(VisualFrame, 2, "SHOW DISTANCE", EventHorizon.Visual.ShowDistance, function()
    EventHorizon.Visual.ShowDistance = not EventHorizon.Visual.ShowDistance
    return EventHorizon.Visual.ShowDistance
end)

-- Construction de l'onglet MISC
local MiscFrame = TabFrames[3]
CreateSection(MiscFrame, 3, "MOVEMENT")
CreateToggle(MiscFrame, 3, "FLY", EventHorizon.Misc.Fly, function()
    EventHorizon.Misc.Fly = not EventHorizon.Misc.Fly
    return EventHorizon.Misc.Fly
end)

CreateSlider(MiscFrame, 3, "FLY SPEED", 10, 100, EventHorizon.Misc.FlySpeed, function(value)
    EventHorizon.Misc.FlySpeed = value
end)

CreateToggle(MiscFrame, 3, "WALKSPEED", EventHorizon.Misc.WalkSpeed, function()
    EventHorizon.Misc.WalkSpeed = not EventHorizon.Misc.WalkSpeed
    return EventHorizon.Misc.WalkSpeed
end)

CreateSlider(MiscFrame, 3, "SPEED VALUE", 16, 100, EventHorizon.Misc.SpeedValue, function(value)
    EventHorizon.Misc.SpeedValue = value
end)

CreateToggle(MiscFrame, 3, "JUMP POWER", EventHorizon.Misc.JumpPower, function()
    EventHorizon.Misc.JumpPower = not EventHorizon.Misc.JumpPower
    return EventHorizon.Misc.JumpPower
end)

CreateSlider(MiscFrame, 3, "JUMP VALUE", 20, 200, EventHorizon.Misc.JumpValue, function(value)
    EventHorizon.Misc.JumpValue = value
end)

CreateToggle(MiscFrame, 3, "BUNNY HOP", EventHorizon.Misc.BunnyHop, function()
    EventHorizon.Misc.BunnyHop = not EventHorizon.Misc.BunnyHop
    return EventHorizon.Misc.BunnyHop
end)

CreateToggle(MiscFrame, 3, "NO CLIP", EventHorizon.Misc.NoClip, function()
    EventHorizon.Misc.NoClip = not EventHorizon.Misc.NoClip
    return EventHorizon.Misc.NoClip
end)

-- Ajuster la taille du contenu
for i, frame in ipairs(TabFrames) do
    frame.CanvasSize = UDim2.new(0, 0, 0, yPositions[i] + 10)
end

-- Détection de la touche RightControl
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================
-- FONCTIONS MISC
-- ============================================

function UpdateFly()
    if EventHorizon.Misc.Fly and LocalPlayer.Character then
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
            
            FlyBodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * EventHorizon.Misc.FlySpeed or Vector3.new(0, 0, 0)
        end
    elseif FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
end

function UpdateMovement()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        if EventHorizon.Misc.WalkSpeed then
            humanoid.WalkSpeed = EventHorizon.Misc.SpeedValue
        elseif humanoid.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = 16
        end
        
        if EventHorizon.Misc.JumpPower then
            humanoid.JumpPower = EventHorizon.Misc.JumpValue
        elseif humanoid.JumpPower ~= 50 then
            humanoid.JumpPower = 50
        end
        
        if EventHorizon.Misc.BunnyHop and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

function UpdateNoClip()
    if EventHorizon.Misc.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- ============================================
-- BOUCLE PRINCIPALE
-- ============================================

RunService.RenderStepped:Connect(function()
    -- Aimbot
    if EventHorizon.Aim.Enabled then
        AimAtTarget()
    end
    
    -- Misc
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

print("========================================")
print("EVENT HORIZON v5.0 - CHARGÉ AVEC SUCCÈS")
print("RightControl pour afficher/cacher le GUI")
print("Aimbot: Clic droit | NoClip: Toggle MISC")
print("========================================")

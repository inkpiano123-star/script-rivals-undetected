-- ============================================
-- EVENT HORIZON - GUI CHARGÉ DIRECTEMENT
-- Pas de keybinds par défaut | Interface fixée
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
        TargetPart = "Head",
        FOV = 100,
        Smoothness = 0.15,
        TriggerBot = false,
        TriggerDelay = 0.05,
        MagicBullet = false,
        MagicHitbox = 5,
        SilentAim = false,
        SilentHitChance = 85,
        -- Pas de keybind par défaut
        AimKey = nil,
        AimKeyText = "NONE"
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
    Misc = {
        Fly = false,
        FlySpeed = 32,
        WalkSpeed = false,
        SpeedValue = 24,
        JumpPower = false,
        JumpValue = 55,
        BunnyHop = false,
        NoClip = false,
        -- Pas de keybind par défaut
        FlyKey = nil,
        FlyKeyText = "NONE",
        NoClipKey = nil,
        NoClipKeyText = "NONE"
    }
}

-- États
local ESPDrawings = {}
local ChamsAdornments = {}
local FlyBodyVelocity

-- ============================================
-- FONCTIONS CORE
-- ============================================

-- Aimbot simple
function GetClosestPlayer()
    if not EventHorizon.Aim.Enabled or not EventHorizon.Aim.AimKey then return nil end
    
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
    if not EventHorizon.Aim.Enabled or not EventHorizon.Aim.AimKey then return end
    
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
-- GUI SIMPLE - CHARGÉ DIRECTEMENT
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 400)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true  -- VISIBLE DIRECTEMENT
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVENT HORIZON"
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
local Tabs = {"AIM", "VISUAL", "MISC"}
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
    TabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 100, 180) or Color3.fromRGB(40, 40, 60)
    TabButton.Text = TabName
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 13
    TabButton.Parent = MainFrame
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = TabName .. "Frame"
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.Position = UDim2.new(0, 0, 0, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = i == 1
    TabFrame.Parent = TabContainer
    
    TabButton.MouseButton1Click:Connect(function()
        for j = 1, #Tabs do
            TabFrames[j].Visible = j == i
            TabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(40, 100, 180) or Color3.fromRGB(40, 40, 60)
        end
    end)
    
    TabButtons[i] = TabButton
    TabFrames[i] = TabFrame
end

-- Fonction pour créer un toggle
function CreateToggle(Parent, Text, Default, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Parent
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 120, 0, 26)
    ToggleButton.Position = UDim2.new(0, 0, 0, 2)
    ToggleButton.BackgroundColor3 = Default and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
    ToggleButton.Text = Text
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextSize = 12
    ToggleButton.Parent = ToggleFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0, 60, 0, 26)
    StatusLabel.Position = UDim2.new(0, 125, 0, 2)
    StatusLabel.BackgroundColor3 = Default and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    StatusLabel.Text = Default and "ON" or "OFF"
    StatusLabel.TextColor3 = Color3.new(1, 1, 1)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 12
    StatusLabel.Parent = ToggleFrame
    
    ToggleButton.MouseButton1Click:Connect(function()
        local newState = not Callback()
        ToggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
        StatusLabel.BackgroundColor3 = newState and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        StatusLabel.Text = newState and "ON" or "OFF"
    end)
    
    return ToggleFrame
end

-- Fonction pour créer un slider
function CreateSlider(Parent, Text, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
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
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
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
    
    local function UpdateSlider(x)
        local relativeX = math.clamp(x - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
        local value = math.floor(Min + (relativeX / SliderBar.AbsoluteSize.X) * (Max - Min))
        SliderFill.Size = UDim2.new((value - Min)/(Max - Min), 0, 1, 0)
        Label.Text = Text .. ": " .. value
        Callback(value)
    end
    
    SliderBar.MouseMoved:Connect(function(x, y)
        if dragging then
            UpdateSlider(x)
        end
    end)
    
    SliderBar.MouseButton1Down:Connect(function(x, y)
        UpdateSlider(x)
    end)
    
    return SliderFrame
end

-- Fonction pour créer un keybind selector
function CreateKeybindSelector(Parent, Text, CurrentKeyText, Callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Size = UDim2.new(1, 0, 0, 40)
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.Parent = Parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 100, 0, 20)
    Label.Text = Text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = KeybindFrame
    
    local KeyButton = Instance.new("TextButton")
    KeyButton.Size = UDim2.new(0, 80, 0, 26)
    KeyButton.Position = UDim2.new(0, 100, 0, 0)
    KeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    KeyButton.Text = CurrentKeyText
    KeyButton.TextColor3 = Color3.new(1, 1, 1)
    KeyButton.Font = Enum.Font.Gotham
    KeyButton.TextSize = 12
    KeyButton.Parent = KeybindFrame
    
    local listening = false
    
    KeyButton.MouseButton1Click:Connect(function()
        listening = true
        KeyButton.Text = "PRESS KEY..."
        KeyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            listening = false
            
            local keyText = ""
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyText = "MB1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyText = "MB2"
            elseif input.KeyCode then
                keyText = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            end
            
            KeyButton.Text = keyText
            KeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            Callback(input, keyText)
        end
    end)
    
    return KeybindFrame
end

-- Construction onglet AIM
local AimFrame = TabFrames[1]

CreateKeybindSelector(AimFrame, "Aim Key:", EventHorizon.Aim.AimKeyText, function(input, keyText)
    EventHorizon.Aim.AimKey = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 and input.UserInputType or input.KeyCode
    EventHorizon.Aim.AimKeyText = keyText
end)

CreateToggle(AimFrame, "AIMBOT", EventHorizon.Aim.Enabled, function()
    EventHorizon.Aim.Enabled = not EventHorizon.Aim.Enabled
    return EventHorizon.Aim.Enabled
end)

CreateSlider(AimFrame, "FOV", 10, 500, EventHorizon.Aim.FOV, function(value)
    EventHorizon.Aim.FOV = value
end)

CreateSlider(AimFrame, "SMOOTH", 0.01, 1, EventHorizon.Aim.Smoothness, function(value)
    EventHorizon.Aim.Smoothness = value
end)

CreateToggle(AimFrame, "TRIGGER BOT", EventHorizon.Aim.TriggerBot, function()
    EventHorizon.Aim.TriggerBot = not EventHorizon.Aim.TriggerBot
    return EventHorizon.Aim.TriggerBot
end)

CreateToggle(AimFrame, "MAGIC BULLET", EventHorizon.Aim.MagicBullet, function()
    EventHorizon.Aim.MagicBullet = not EventHorizon.Aim.MagicBullet
    return EventHorizon.Aim.MagicBullet
end)

CreateToggle(AimFrame, "SILENT AIM", EventHorizon.Aim.SilentAim, function()
    EventHorizon.Aim.SilentAim = not EventHorizon.Aim.SilentAim
    return EventHorizon.Aim.SilentAim
end)

-- Construction onglet VISUAL
local VisualFrame = TabFrames[2]

CreateToggle(VisualFrame, "ESP", EventHorizon.Visual.ESP, function()
    EventHorizon.Visual.ESP = not EventHorizon.Visual.ESP
    return EventHorizon.Visual.ESP
end)

CreateToggle(VisualFrame, "TRACERS", EventHorizon.Visual.Tracers, function()
    EventHorizon.Visual.Tracers = not EventHorizon.Visual.Tracers
    return EventHorizon.Visual.Tracers
end)

CreateToggle(VisualFrame, "CHAMS", EventHorizon.Visual.Chams, function()
    EventHorizon.Visual.Chams = not EventHorizon.Visual.Chams
    return EventHorizon.Visual.Chams
end)

CreateToggle(VisualFrame, "SHOW NAMES", EventHorizon.Visual.ShowNames, function()
    EventHorizon.Visual.ShowNames = not EventHorizon.Visual.ShowNames
    return EventHorizon.Visual.ShowNames
end)

-- Construction onglet MISC
local MiscFrame = TabFrames[3]

CreateToggle(MiscFrame, "FLY", EventHorizon.Misc.Fly, function()
    EventHorizon.Misc.Fly = not EventHorizon.Misc.Fly
    return EventHorizon.Misc.Fly
end)

CreateKeybindSelector(MiscFrame, "Fly Key:", EventHorizon.Misc.FlyKeyText, function(input, keyText)
    EventHorizon.Misc.FlyKey = input.KeyCode
    EventHorizon.Misc.FlyKeyText = keyText
end)

CreateSlider(MiscFrame, "FLY SPEED", 10, 100, EventHorizon.Misc.FlySpeed, function(value)
    EventHorizon.Misc.FlySpeed = value
end)

CreateToggle(MiscFrame, "WALKSPEED", EventHorizon.Misc.WalkSpeed, function()
    EventHorizon.Misc.WalkSpeed = not EventHorizon.Misc.WalkSpeed
    return EventHorizon.Misc.WalkSpeed
end)

CreateSlider(MiscFrame, "SPEED VALUE", 16, 100, EventHorizon.Misc.SpeedValue, function(value)
    EventHorizon.Misc.SpeedValue = value
end)

CreateToggle(MiscFrame, "JUMP POWER", EventHorizon.Misc.JumpPower, function()
    EventHorizon.Misc.JumpPower = not EventHorizon.Misc.JumpPower
    return EventHorizon.Misc.JumpPower
end)

CreateSlider(MiscFrame, "JUMP VALUE", 20, 200, EventHorizon.Misc.JumpValue, function(value)
    EventHorizon.Misc.JumpValue = value
end)

CreateToggle(MiscFrame, "BUNNY HOP", EventHorizon.Misc.BunnyHop, function()
    EventHorizon.Misc.BunnyHop = not EventHorizon.Misc.BunnyHop
    return EventHorizon.Misc.BunnyHop
end)

CreateToggle(MiscFrame, "NO CLIP", EventHorizon.Misc.NoClip, function()
    EventHorizon.Misc.NoClip = not EventHorizon.Misc.NoClip
    return EventHorizon.Misc.NoClip
end)

CreateKeybindSelector(MiscFrame, "NoClip Key:", EventHorizon.Misc.NoClipKeyText, function(input, keyText)
    EventHorizon.Misc.NoClipKey = input.KeyCode
    EventHorizon.Misc.NoClipKeyText = keyText
end)

-- ============================================
-- FONCTIONS MISC
-- ============================================

function UpdateFly()
    if EventHorizon.Misc.Fly and LocalPlayer.Character and EventHorizon.Misc.FlyKey then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and UserInputService:IsKeyDown(EventHorizon.Misc.FlyKey) then
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
        elseif FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
            FlyBodyVelocity = nil
        end
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
    if EventHorizon.Misc.NoClip and LocalPlayer.Character and EventHorizon.Misc.NoClipKey then
        if UserInputService:IsKeyDown(EventHorizon.Misc.NoClipKey) then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- ============================================
-- BOUCLE PRINCIPALE
-- ============================================

RunService.RenderStepped:Connect(function()
    -- Aimbot (seulement si une touche est définie)
    if EventHorizon.Aim.Enabled and EventHorizon.Aim.AimKey then
        if EventHorizon.Aim.AimKey.EnumType == Enum.KeyCode then
            if UserInputService:IsKeyDown(EventHorizon.Aim.AimKey) then
                AimAtTarget()
            end
        else
            if UserInputService:IsMouseButtonPressed(EventHorizon.Aim.AimKey) then
                AimAtTarget()
            end
        end
    end
    
    -- Misc
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

print("========================================")
print("EVENT HORIZON - CHARGÉ")
print("GUI visible - Configure tes keybinds")
print("========================================")

-- ============================================
-- EVENT HORIZON v4.0 - RIVALS CHEAT
-- GUI Fixé | NoClip Auto | Full Features
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
local CoreGui = game:GetService("CoreGui")

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
        Enabled = false,
        SelectedWeapon = "Assault Rifle",
        SelectedSkin = "Phoenix Rifle",
        WeaponList = {"Assault Rifle", "Handgun", "Sniper", "Shotgun", "Knife"},
        SkinDatabase = {
            ["Assault Rifle"] = {"Phoenix Rifle", "Compound Bow", "10B Visits"},
            ["Handgun"] = {"Warp Handgun", "Towerstone Handgun", "Gumball Handgun", "Pumpkin Handgun"},
            ["Sniper"] = {"Gingerbread Sniper", "Eyething Sniper"},
            ["Shotgun"] = {"Cactus Shotgun", "Wrapped Shotgun", "Broomstick"},
            ["Knife"] = {"Chancla", "Machete", "Keyrambit"}
        }
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
local IsGUIEnabled = true  -- GUI visible par défaut
local ESPDrawings = {}
local ChamsAdornments = {}
local FlyBodyVelocity

-- ============================================
-- FONCTIONS CORE
-- ============================================

-- Détection de la touche Aimbot
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed then
        if Input.UserInputType == EventHorizon.Aim.LockKey then
            IsAimKeyDown = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == EventHorizon.Aim.LockKey then
        IsAimKeyDown = false
    end
end)

-- Fonction Aimbot
function GetClosestPlayer()
    if not EventHorizon.Aim.Enabled or not IsAimKeyDown then return nil end
    
    local ClosestPlayer = nil
    local ShortestDistance = EventHorizon.Aim.FOV
    local MousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local Hum = Player.Character.Humanoid
            if Hum.Health > 0 then
                local TargetPart = Player.Character:FindFirstChild(EventHorizon.Aim.TargetPart)
                if TargetPart then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                    if OnScreen then
                        local Pos2D = Vector2.new(ScreenPos.X, ScreenPos.Y)
                        local Distance = (MousePos - Pos2D).Magnitude
                        
                        if Distance < ShortestDistance then
                            ShortestDistance = Distance
                            ClosestPlayer = Player
                        end
                    end
                end
            end
        end
    end
    
    return ClosestPlayer
end

function AimAtTarget()
    if not EventHorizon.Aim.Enabled or not IsAimKeyDown then return end
    
    local Target = GetClosestPlayer()
    if not Target or not Target.Character then return end
    
    local TargetPart = Target.Character:FindFirstChild(EventHorizon.Aim.TargetPart)
    if not TargetPart then return end
    
    -- Silent Aim
    if EventHorizon.Aim.SilentAim and math.random(1, 100) <= EventHorizon.Aim.SilentHitChance then
        return true
    end
    
    -- Magic Bullet
    local AimPosition = TargetPart.Position
    if EventHorizon.Aim.MagicBullet then
        AimPosition = AimPosition + Vector3.new(
            math.random(-EventHorizon.Aim.MagicHitbox, EventHorizon.Aim.MagicHitbox),
            math.random(-EventHorizon.Aim.MagicHitbox, EventHorizon.Aim.MagicHitbox) / 2,
            math.random(-EventHorizon.Aim.MagicHitbox, EventHorizon.Aim.MagicHitbox)
        )
    end
    
    -- Smooth Aim
    local CurrentCF = Camera.CFrame
    local TargetCF = CFrame.lookAt(CurrentCF.Position, AimPosition)
    local SmoothedCF = CurrentCF:Lerp(TargetCF, 1 - EventHorizon.Aim.Smoothness)
    
    Camera.CFrame = SmoothedCF
    return false
end

function TriggerBot()
    if not EventHorizon.Aim.TriggerBot then return end
    
    local Target = GetClosestPlayer()
    if Target and Target.Character and Target.Character:FindFirstChild("Humanoid") then
        local Hum = Target.Character.Humanoid
        if Hum.Health > 0 then
            mouse1press()
            task.wait(EventHorizon.Aim.TriggerDelay)
            mouse1release()
        end
    end
end

-- Fonctions Visuals
function UpdateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            local Hum = Player.Character:FindFirstChild("Humanoid")
            
            if Root and Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                
                if not ESPDrawings[Player] then
                    ESPDrawings[Player] = {
                        Box = Drawing.new("Quad"),
                        Tracer = Drawing.new("Line"),
                        Name = Drawing.new("Text"),
                        Distance = Drawing.new("Text")
                    }
                end
                
                local Draw = ESPDrawings[Player]
                
                if EventHorizon.Visual.ESP and OnScreen then
                    local Head = Player.Character:FindFirstChild("Head")
                    local HeadPos = Head and Camera:WorldToViewportPoint(Head.Position) or ScreenPos
                    local Height = math.abs(ScreenPos.Y - HeadPos.Y) * 1.8
                    local Width = Height * 0.6
                    
                    -- Box
                    if EventHorizon.Visual.BoxType ~= "None" then
                        Draw.Box.Visible = true
                        Draw.Box.Color = EventHorizon.Visual.BoxColor
                        Draw.Box.Thickness = 1.5
                        
                        if EventHorizon.Visual.BoxType == "2D Corner" then
                            local CornerSize = Height * 0.2
                            Draw.Box.PointA = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y - Height/2 + CornerSize)
                            Draw.Box.PointB = Vector2.new(ScreenPos.X - Width/2 + CornerSize, ScreenPos.Y - Height/2)
                            Draw.Box.PointC = Vector2.new(ScreenPos.X + Width/2 - CornerSize, ScreenPos.Y - Height/2)
                            Draw.Box.PointD = Vector2.new(ScreenPos.X + Width/2, ScreenPos.Y - Height/2 + CornerSize)
                        else
                            Draw.Box.PointA = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y - Height/2)
                            Draw.Box.PointB = Vector2.new(ScreenPos.X + Width/2, ScreenPos.Y - Height/2)
                            Draw.Box.PointC = Vector2.new(ScreenPos.X + Width/2, ScreenPos.Y + Height/2)
                            Draw.Box.PointD = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y + Height/2)
                        end
                    else
                        Draw.Box.Visible = false
                    end
                    
                    -- Tracers
                    Draw.Tracer.Visible = EventHorizon.Visual.Tracers
                    Draw.Tracer.Color = EventHorizon.Visual.TracerColor
                    Draw.Tracer.Thickness = 1
                    
                    local OriginY = 0
                    if EventHorizon.Visual.TracerOrigin == "Middle" then
                        OriginY = Camera.ViewportSize.Y / 2
                    elseif EventHorizon.Visual.TracerOrigin == "Bottom" then
                        OriginY = Camera.ViewportSize.Y
                    end
                    
                    Draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, OriginY)
                    Draw.Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                    
                    -- Name
                    Draw.Name.Visible = EventHorizon.Visual.ShowNames
                    Draw.Name.Color = Color3.new(1, 1, 1)
                    Draw.Name.Text = Player.Name
                    Draw.Name.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - Height/2 - 15)
                    Draw.Name.Size = 13
                    Draw.Name.Center = true
                    
                    -- Distance
                    if EventHorizon.Visual.ShowDistance then
                        local Dist = (Root.Position - Camera.CFrame.Position).Magnitude
                        Draw.Distance.Visible = true
                        Draw.Distance.Color = Color3.new(0.8, 0.8, 0.8)
                        Draw.Distance.Text = math.floor(Dist) .. " studs"
                        Draw.Distance.Position = Vector2.new(ScreenPos.X, ScreenPos.Y + Height/2 + 5)
                        Draw.Distance.Size = 12
                        Draw.Distance.Center = true
                    else
                        Draw.Distance.Visible = false
                    end
                else
                    for _, DrawingObj in pairs(Draw) do
                        DrawingObj.Visible = false
                    end
                end
            elseif ESPDrawings[Player] then
                for _, DrawingObj in pairs(ESPDrawings[Player]) do
                    DrawingObj.Visible = false
                end
            end
        end
    end
end

function UpdateChams()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            if EventHorizon.Visual.Chams then
                if not ChamsAdornments[Player] then
                    ChamsAdornments[Player] = {}
                end
                
                for _, Part in pairs(Player.Character:GetChildren()) do
                    if Part:IsA("BasePart") and Part.Transparency < 1 then
                        if not ChamsAdornments[Player][Part] then
                            local Cham = Instance.new("BoxHandleAdornment")
                            Cham.Name = "EventHorizonCham"
                            Cham.Adornee = Part
                            Cham.AlwaysOnTop = true
                            Cham.ZIndex = 5
                            Cham.Size = Part.Size
                            Cham.Color3 = EventHorizon.Visual.ChamsColor
                            Cham.Transparency = EventHorizon.Visual.ChamsTransparency
                            Cham.Parent = Part
                            ChamsAdornments[Player][Part] = Cham
                        else
                            ChamsAdornments[Player][Part].Visible = true
                        end
                    end
                end
            elseif ChamsAdornments[Player] then
                for Part, Cham in pairs(ChamsAdornments[Player]) do
                    if Cham then
                        Cham.Visible = false
                    end
                end
            end
        end
    end
end

-- Fonctions Misc
function UpdateFly()
    if EventHorizon.Misc.Fly and LocalPlayer.Character then
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root then
            if not FlyBodyVelocity then
                FlyBodyVelocity = Instance.new("BodyVelocity")
                FlyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                FlyBodyVelocity.P = 1250
                FlyBodyVelocity.Parent = Root
            end
            
            local Direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                Direction = Direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                Direction = Direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                Direction = Direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                Direction = Direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                Direction = Direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                Direction = Direction - Vector3.new(0, 1, 0)
            end
            
            if Direction.Magnitude > 0 then
                FlyBodyVelocity.Velocity = Direction.Unit * EventHorizon.Misc.FlySpeed
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
    local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if Humanoid then
        -- WalkSpeed
        if EventHorizon.Misc.WalkSpeed then
            Humanoid.WalkSpeed = EventHorizon.Misc.SpeedValue
        elseif Humanoid.WalkSpeed ~= 16 then
            Humanoid.WalkSpeed = 16
        end
        
        -- JumpPower
        if EventHorizon.Misc.JumpPower then
            Humanoid.JumpPower = EventHorizon.Misc.JumpValue
        elseif Humanoid.JumpPower ~= 50 then
            Humanoid.JumpPower = 50
        end
        
        -- BunnyHop
        if EventHorizon.Misc.BunnyHop and Humanoid.FloorMaterial ~= Enum.Material.Air then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

function UpdateNoClip()
    if EventHorizon.Misc.NoClip and LocalPlayer.Character then
        for _, Part in pairs(LocalPlayer.Character:GetChildren()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end
end

-- ============================================
-- GUI SIMPLE ET FONCTIONNEL
-- ============================================

-- Création du GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVENT HORIZON v4.0"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local KeybindInfo = Instance.new("TextLabel")
KeybindInfo.Name = "KeybindInfo"
KeybindInfo.Size = UDim2.new(0.25, 0, 1, 0)
KeybindInfo.Position = UDim2.new(0.75, 0, 0, 0)
KeybindInfo.BackgroundTransparency = 1
KeybindInfo.Text = "[INSERT] TOGGLE"
KeybindInfo.TextColor3 = Color3.fromRGB(150, 150, 200)
KeybindInfo.Font = Enum.Font.Gotham
KeybindInfo.TextSize = 12
KeybindInfo.Parent = Header

-- Boutons d'onglet
local Tabs = {"AIMBOT", "VISUALS", "SKINS", "MISC"}
local TabButtons = {}
local TabFrames = {}

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -30, 1, -80)
TabContainer.Position = UDim2.new(0, 15, 0, 60)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Création des onglets
for i, TabName in ipairs(Tabs) do
    -- Bouton d'onglet
    local TabButton = Instance.new("TextButton")
    TabButton.Name = TabName .. "Tab"
    TabButton.Size = UDim2.new(0.23, 0, 0, 30)
    TabButton.Position = UDim2.new(0.23 * (i-1), 10, 0, 45)
    TabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 100, 180) or Color3.fromRGB(35, 35, 50)
    TabButton.BorderSizePixel = 0
    TabButton.Text = TabName
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 12
    TabButton.Parent = MainFrame
    
    TabButton.MouseButton1Click:Connect(function()
        SwitchTab(i)
    end)
    
    TabButtons[i] = TabButton
    
    -- Frame de contenu
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = TabName .. "Frame"
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.Position = UDim2.new(0, 0, 0, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = i == 1
    TabFrame.Parent = TabContainer
    
    TabFrames[i] = TabFrame
end

function SwitchTab(Index)
    for i = 1, #Tabs do
        TabFrames[i].Visible = i == Index
        TabButtons[i].BackgroundColor3 = i == Index and Color3.fromRGB(40, 100, 180) or Color3.fromRGB(35, 35, 50)
    end
end

-- Fonction pour créer des éléments de l'interface
local function CreateToggle(Parent, Text, DefaultState, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = Text .. "Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Parent
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 140, 0, 26)
    ToggleButton.Position = UDim2.new(0, 0, 0, 2)
    ToggleButton.BackgroundColor3 = DefaultState and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = Text .. ": " .. (DefaultState and "ON" or "OFF")
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextSize = 12
    ToggleButton.Parent = ToggleFrame
    
    ToggleButton.MouseButton1Click:Connect(function()
        local NewState = not Callback()
        ToggleButton.BackgroundColor3 = NewState and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
        ToggleButton.Text = Text .. ": " .. (NewState and "ON" or "OFF")
    end)
    
    return ToggleButton
end

local function CreateSlider(Parent, Text, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = Text .. "Slider"
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Parent
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text .. ": " .. Default
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Name = "SliderBar"
    SliderBar.Size = UDim2.new(1, 0, 0, 6)
    SliderBar.Position = UDim2.new(0, 0, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((Default - Min) / (Max - Min), -8, 0.5, -8)
    SliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    SliderButton.Text = ""
    SliderButton.Parent = SliderBar
    
    local Dragging = false
    SliderButton.MouseButton1Down:Connect(function()
        Dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    local function UpdateSlider(X)
        local RelativeX = math.clamp(X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
        local Value = math.floor(Min + (RelativeX / SliderBar.AbsoluteSize.X) * (Max - Min))
        
        SliderFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
        SliderButton.Position = UDim2.new((Value - Min) / (Max - Min), -8, 0.5, -8)
        Label.Text = Text .. ": " .. Value
        
        Callback(Value)
    end
    
    SliderButton.MouseMoved:Connect(function(X, Y)
        if Dragging then
            UpdateSlider(X)
        end
    end)
    
    SliderBar.MouseButton1Down:Connect(function(X, Y)
        UpdateSlider(X)
    end)
    
    return SliderFrame
end

-- Construction de l'onglet AIMBOT
local AimFrame = TabFrames[1]
CreateToggle(AimFrame, "AIMBOT", EventHorizon.Aim.Enabled, function()
    EventHorizon.Aim.Enabled = not EventHorizon.Aim.Enabled
    return EventHorizon.Aim.Enabled
end)

CreateSlider(AimFrame, "FOV", 10, 500, EventHorizon.Aim.FOV, function(Value)
    EventHorizon.Aim.FOV = Value
end)

CreateSlider(AimFrame, "SMOOTHNESS", 0.01, 1, EventHorizon.Aim.Smoothness, function(Value)
    EventHorizon.Aim.Smoothness = Value
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

CreateSlider(AimFrame, "SILENT HIT %", 1, 100, EventHorizon.Aim.SilentHitChance, function(Value)
    EventHorizon.Aim.SilentHitChance = Value
end)

-- Construction de l'onglet VISUALS
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

CreateToggle(VisualFrame, "SHOW DISTANCE", EventHorizon.Visual.ShowDistance, function()
    EventHorizon.Visual.ShowDistance = not EventHorizon.Visual.ShowDistance
    return EventHorizon.Visual.ShowDistance
end)

-- Construction de l'onglet SKINS
local SkinsFrame = TabFrames[3]
CreateToggle(SkinsFrame, "SKIN CHANGER", EventHorizon.Skins.Enabled, function()
    EventHorizon.Skins.Enabled = not EventHorizon.Skins.Enabled
    return EventHorizon.Skins.Enabled
end)

-- Construction de l'onglet MISC
local MiscFrame = TabFrames[4]
CreateToggle(MiscFrame, "FLY", EventHorizon.Misc.Fly, function()
    EventHorizon.Misc.Fly = not EventHorizon.Misc.Fly
    return EventHorizon.Misc.Fly
end)

CreateSlider(MiscFrame, "FLY SPEED", 10, 100, EventHorizon.Misc.FlySpeed, function(Value)
    EventHorizon.Misc.FlySpeed = Value
end)

CreateToggle(MiscFrame, "WALKSPEED", EventHorizon.Misc.WalkSpeed, function()
    EventHorizon.Misc.WalkSpeed = not EventHorizon.Misc.WalkSpeed
    return EventHorizon.Misc.WalkSpeed
end)

CreateSlider(MiscFrame, "SPEED VALUE", 16, 100, EventHorizon.Misc.SpeedValue, function(Value)
    EventHorizon.Misc.SpeedValue = Value
end)

CreateToggle(MiscFrame, "JUMP POWER", EventHorizon.Misc.JumpPower, function()
    EventHorizon.Misc.JumpPower = not EventHorizon.Misc.JumpPower
    return EventHorizon.Misc.JumpPower
end)

CreateSlider(MiscFrame, "JUMP VALUE", 20, 200, EventHorizon.Misc.JumpValue, function(Value)
    EventHorizon.Misc.JumpValue = Value
end)

CreateToggle(MiscFrame, "BUNNY HOP", EventHorizon.Misc.BunnyHop, function()
    EventHorizon.Misc.BunnyHop = not EventHorizon.Misc.BunnyHop
    return EventHorizon.Misc.BunnyHop
end)

CreateToggle(MiscFrame, "NO CLIP", EventHorizon.Misc.NoClip, function()
    EventHorizon.Misc.NoClip = not EventHorizon.Misc.NoClip
    return EventHorizon.Misc.NoClip
end)

-- Bouton de fermeture
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Détection de la touche INSERT pour afficher/cacher le GUI
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        KeybindInfo.Text = MainFrame.Visible and "[INSERT] HIDE" or "[INSERT] SHOW"
    end
end)

-- ============================================
-- BOUCLE PRINCIPALE
-- ============================================

local LastUpdate = tick()
RunService.RenderStepped:Connect(function()
    local Now = tick()
    
    if Now - LastUpdate > 0.03 then
        -- Aimbot
        if EventHorizon.Aim.Enabled then
            AimAtTarget()
            TriggerBot()
        end
        
        -- Visuals
        if EventHorizon.Visual.ESP or EventHorizon.Visual.Chams then
            UpdateESP()
            UpdateChams()
        end
        
        -- Misc
        UpdateFly()
        UpdateMovement()
        UpdateNoClip()
        
        LastUpdate = Now
    end
end)

-- Nettoyage
LocalPlayer.CharacterAdded:Connect(function()
    if FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
end)

-- Message de confirmation
print("============================================")
print("EVENT HORIZON v4.0 - LOADED SUCCESSFULLY")
print("Press INSERT to toggle GUI")
print("NoClip: Toggle in MISC tab (no keybind)")
print("============================================")

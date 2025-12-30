-- ============================================
-- EVENT HORIZON - RIVALS CHEAT (VERSION CORRIGÉE)
-- GUI Roblox Standard | Aimbot | Visuals | Skins | Misc
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
local HttpService = game:GetService("HttpService")

-- Variables globales du cheat
local EventHorizon = {
    Aim = {
        Enabled = false,
        LockKey = Enum.UserInputType.MouseButton2, -- Clic droit par défaut
        TargetPart = "Head",
        FOV = 150,
        Smoothness = 0.15,
        UseTriggerBot = false,
        TriggerDelay = 0.05,
        FastShoot = false,
        ShootSpeed = 0.02,
        MagicBullet = false,
        MagicHitboxSize = 5,
        SilentAim = false,
        SilentHitChance = 85
    },
    Visual = {
        ESP = true,
        BoxType = "2D Corner", -- "2D Box", "2D Corner", "3D Box"
        BoxColor = Color3.fromRGB(255, 50, 50),
        Tracers = true,
        TracerOrigin = "Bottom", -- "Top", "Middle", "Bottom"
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
        NoClip = false,
        NoClipKey = Enum.KeyCode.H
    }
}

-- Détection de la touche enfoncée pour l'Aimbot
local IsAimKeyDown = false
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.UserInputType == EventHorizon.Aim.LockKey then
        IsAimKeyDown = true
    end
end)
UserInputService.InputEnded:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.UserInputType == EventHorizon.Aim.LockKey then
        IsAimKeyDown = false
    end
end)

-- Détection de la touche NoClip
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == EventHorizon.Misc.NoClipKey then
        EventHorizon.Misc.NoClip = not EventHorizon.Misc.NoClip
        UpdateGUI() -- Pour mettre à jour l'affichage du bouton
    end
end)

-- ============================================
-- FONCTIONS CORE
-- ============================================

-- Trouve le joueur le plus proche dans le FOV
function GetClosestPlayer()
    if not EventHorizon.Aim.Enabled or not IsAimKeyDown then return nil end
    
    local ClosestPlayer = nil
    local ShortestDistance = EventHorizon.Aim.FOV
    local MousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
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
    
    return ClosestPlayer
end

-- Aimbot avec Smooth et options
local LastAimTick = tick()
function AimAtTarget()
    if not EventHorizon.Aim.Enabled or not IsAimKeyDown then return end
    if tick() - LastAimTick < (EventHorizon.Aim.FastShoot and EventHorizon.Aim.ShootSpeed or 0.05) then return end
    
    local Target = GetClosestPlayer()
    if not Target or not Target.Character then return end
    
    local TargetPart = Target.Character:FindFirstChild(EventHorizon.Aim.TargetPart)
    if not TargetPart then return end
    
    -- Silent Aim : Calcul de la position cible (avec chance de toucher)
    local AimPosition = TargetPart.Position
    if EventHorizon.Aim.SilentAim and math.random(1, 100) <= EventHorizon.Aim.SilentHitChance then
        -- On garde la même position (le tir sera redirigé silencieusement)
        LastAimTick = tick()
        return true -- Indique qu'un silent aim a eu lieu
    end
    
    -- Magic Bullet : Agrandissement de la hitbox
    if EventHorizon.Aim.MagicBullet then
        AimPosition = AimPosition + Vector3.new(
            math.random(-EventHorizon.Aim.MagicHitboxSize, EventHorizon.Aim.MagicHitboxSize),
            math.random(-EventHorizon.Aim.MagicHitboxSize, EventHorizon.Aim.MagicHitboxSize) / 2,
            math.random(-EventHorizon.Aim.MagicHitboxSize, EventHorizon.Aim.MagicHitboxSize)
        )
    end
    
    -- Aim normal avec Smooth
    local CurrentCF = Camera.CFrame
    local TargetCF = CFrame.lookAt(CurrentCF.Position, AimPosition)
    local SmoothedCF = CurrentCF:Lerp(TargetCF, 1 - EventHorizon.Aim.Smoothness)
    
    Camera.CFrame = SmoothedCF
    LastAimTick = tick()
    return false
end

-- Trigger Bot
function TriggerBot()
    if not EventHorizon.Aim.UseTriggerBot then return end
    
    local Target = GetClosestPlayer()
    if Target and Target.Character and Target.Character:FindFirstChild("Humanoid") then
        local Hum = Target.Character.Humanoid
        if Hum.Health > 0 then
            -- Simulation d'un tir (peut nécessiter un hook spécifique selon le jeu)
            mouse1press()
            task.wait(EventHorizon.Aim.TriggerDelay)
            mouse1release()
        end
    end
end

-- ============================================
-- VISUALS (ESP, CHAMS, TRACERS)
-- ============================================

local ESPDrawings = {}
local ChamsAdornments = {}

function UpdateVisuals()
    -- ESP et Tracers
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            local Hum = Player.Character:FindFirstChild("Humanoid")
            
            if Root and Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                
                -- Créer les dessins s'ils n'existent pas
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
                    -- Calcul de la boîte
                    local Head = Player.Character:FindFirstChild("Head")
                    local HeadPos = Head and Camera:WorldToViewportPoint(Head.Position) or ScreenPos
                    local Height = math.abs(ScreenPos.Y - HeadPos.Y) * 1.8
                    local Width = Height * 0.6
                    
                    -- Boîte 2D
                    if EventHorizon.Visual.BoxType == "2D Box" then
                        Draw.Box.Visible = true
                        Draw.Box.Color = EventHorizon.Visual.BoxColor
                        Draw.Box.Thickness = 1.5
                        Draw.Box.PointA = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y - Height/2)
                        Draw.Box.PointB = Vector2.new(ScreenPos.X + Width/2, ScreenPos.Y - Height/2)
                        Draw.Box.PointC = Vector2.new(ScreenPos.X + Width/2, ScreenPos.Y + Height/2)
                        Draw.Box.PointD = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y + Height/2)
                    elseif EventHorizon.Visual.BoxType == "2D Corner" then
                        Draw.Box.Visible = true
                        Draw.Box.Color = EventHorizon.Visual.BoxColor
                        Draw.Box.Thickness = 1.5
                        local CornerSize = Height * 0.2
                        Draw.Box.PointA = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y - Height/2 + CornerSize)
                        Draw.Box.PointB = Vector2.new(ScreenPos.X - Width/2 + CornerSize, ScreenPos.Y - Height/2)
                        Draw.Box.PointC = Vector2.new(ScreenPos.X + Width/2 - CornerSize, ScreenPos.Y - Height/2)
                        Draw.Box.PointD = Vector2.new(ScreenPos.X + Width/2, ScreenPos.Y - Height/2 + CornerSize)
                    else
                        Draw.Box.Visible = false
                    end
                    
                    -- Tracers
                    Draw.Tracer.Visible = EventHorizon.Visual.Tracers
                    Draw.Tracer.Color = EventHorizon.Visual.TracerColor
                    Draw.Tracer.Thickness = 1
                    
                    local OriginY
                    if EventHorizon.Visual.TracerOrigin == "Top" then
                        OriginY = 0
                    elseif EventHorizon.Visual.TracerOrigin == "Middle" then
                        OriginY = Camera.ViewportSize.Y / 2
                    else
                        OriginY = Camera.ViewportSize.Y
                    end
                    
                    Draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, OriginY)
                    Draw.Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                    
                    -- Nom et distance
                    Draw.Name.Visible = EventHorizon.Visual.ShowNames
                    Draw.Name.Color = Color3.new(1, 1, 1)
                    Draw.Name.Text = Player.Name
                    Draw.Name.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - Height/2 - 15)
                    Draw.Name.Size = 13
                    Draw.Name.Center = true
                    
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
            
            -- Chams
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

-- ============================================
-- SKIN CHANGER (pour Rivals)
-- ============================================

function ApplySkin()
    if not EventHorizon.Skins.Enabled then return end
    
    if LocalPlayer.Character then
        local Tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if Tool then
            -- Cette fonction est un template. Dans un vrai cheat, il faudrait
            -- remplacer les propriétés du Mesh/Texture de l'arme selon le skin choisi.
            -- C'est plus complexe et dépend de la structure interne du jeu.
            local Handle = Tool:FindFirstChild("Handle") or Tool:FindFirstChildWhichIsA("BasePart")
            if Handle then
                -- Exemple de modification visuelle (couleur)
                if EventHorizon.Skins.SelectedSkin == "Phoenix Rifle" then
                    Handle.Color = Color3.fromRGB(255, 69, 0) -- Orange feu
                elseif EventHorizon.Skins.SelectedSkin == "Warp Handgun" then
                    Handle.Color = Color3.fromRGB(138, 43, 226) -- Violet
                elseif EventHorizon.Skins.SelectedSkin == "10B Visits" then
                    Handle.Color = Color3.fromRGB(255, 215, 0) -- Or
                end
            end
        end
    end
end

-- ============================================
-- MISC (Fly, WalkSpeed, etc.)
-- ============================================

local FlyBodyVelocity
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

function UpdateMisc()
    -- Fly
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
    
    -- WalkSpeed & JumpPower
    local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if Humanoid then
        if EventHorizon.Misc.WalkSpeed then
            Humanoid.WalkSpeed = EventHorizon.Misc.SpeedValue
        elseif Humanoid.WalkSpeed ~= OriginalWalkSpeed then
            Humanoid.WalkSpeed = OriginalWalkSpeed
        end
        
        if EventHorizon.Misc.JumpPower then
            Humanoid.JumpPower = EventHorizon.Misc.JumpValue
        elseif Humanoid.JumpPower ~= OriginalJumpPower then
            Humanoid.JumpPower = OriginalJumpPower
        end
        
        -- BunnyHop
        if EventHorizon.Misc.BunnyHop and Humanoid.FloorMaterial ~= Enum.Material.Air then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    -- NoClip
    if EventHorizon.Misc.NoClip and LocalPlayer.Character then
        for _, Part in pairs(LocalPlayer.Character:GetChildren()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end
end

-- ============================================
-- INTERFACE GRAPHIQUE (Roblox Standard)
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 60)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Titre avec effet
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 36)
TitleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVENT HORIZON CHEAT v2.0"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TitleFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 16)
SubTitle.Position = UDim2.new(0, 0, 0, 36)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "RIVALS | By Villain Mode"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 180)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.Parent = TitleFrame

-- Onglets
local Tabs = {"AIM", "VISUAL", "SKINS", "MISC"}
local TabButtons = {}
local TabFrames = {}
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -80)
TabContainer.Position = UDim2.new(0, 10, 0, 70)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Création des onglets
function CreateTab(Name, Index)
    -- Bouton de l'onglet
    local TabButton = Instance.new("TextButton")
    TabButton.Name = Name .. "Tab"
    TabButton.Size = UDim2.new(0.24, -2, 0, 28)
    TabButton.Position = UDim2.new(0.25 * (Index-1), 5, 0, 52)
    TabButton.BackgroundColor3 = Index == 1 and Color3.fromRGB(40, 100, 180) or Color3.fromRGB(40, 40, 60)
    TabButton.Text = Name
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 13
    TabButton.Parent = MainFrame
    
    TabButton.MouseButton1Click:Connect(function()
        SwitchTab(Index)
    end)
    
    TabButtons[Index] = TabButton
    
    -- Frame du contenu
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = Name .. "Frame"
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.Position = UDim2.new(0, 0, 0, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 4
    TabFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    TabFrame.Visible = Index == 1
    TabFrame.Parent = TabContainer
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabFrame
    
    TabFrames[Index] = TabFrame
end

for i, TabName in ipairs(Tabs) do
    CreateTab(TabName, i)
end

function SwitchTab(Index)
    for i, Frame in ipairs(TabFrames) do
        Frame.Visible = i == Index
        TabButtons[i].BackgroundColor3 = i == Index and Color3.fromRGB(40, 100, 180) or Color3.fromRGB(40, 40, 60)
    end
end

-- Fonctions pour créer les éléments d'interface
function CreateToggle(Parent, Text, DefaultState, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 28)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Parent
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 120, 0, 24)
    ToggleButton.Position = UDim2.new(0, 10, 0, 2)
    ToggleButton.BackgroundColor3 = DefaultState and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 0, 0)
    ToggleButton.Text = Text
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextSize = 12
    ToggleButton.Parent = ToggleFrame
    
    ToggleButton.MouseButton1Click:Connect(function()
        local NewState = not Callback()
        ToggleButton.BackgroundColor3 = NewState and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 0, 0)
        ToggleButton.Text = Text .. " [" .. (NewState and "ON" or "OFF") .. "]"
    end)
    
    ToggleButton.Text = Text .. " [" .. (DefaultState and "ON" or "OFF") .. "]"
    return ToggleButton
end

function CreateSlider(Parent, Text, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text .. ": " .. Default
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 25)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderButton = Instance.new("TextButton")
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

function CreateDropdown(Parent, Text, Options, Default, Callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 50)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = Parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, -20, 0, 28)
    DropdownButton.Position = UDim2.new(0, 10, 0, 20)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    DropdownButton.Text = Default
    DropdownButton.TextColor3 = Color3.new(1, 1, 1)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 12
    DropdownButton.Parent = DropdownFrame
    
    local DropdownMenu = Instance.new("Frame")
    DropdownMenu.Size = UDim2.new(1, -20, 0, 0)
    DropdownMenu.Position = UDim2.new(0, 10, 0, 50)
    DropdownMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    DropdownMenu.BorderSizePixel = 1
    DropdownMenu.BorderColor3 = Color3.fromRGB(60, 60, 80)
    DropdownMenu.Visible = false
    DropdownMenu.Parent = DropdownFrame
    
    local MenuLayout = Instance.new("UIListLayout")
    MenuLayout.Parent = DropdownMenu
    
    for _, Option in pairs(Options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 24)
        OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        OptionButton.Text = Option
        OptionButton.TextColor3 = Color3.new(1, 1, 1)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 11
        OptionButton.Parent = DropdownMenu
        
        OptionButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = Option
            DropdownMenu.Visible = false
            DropdownMenu.Size = UDim2.new(1, -20, 0, 0)
            Callback(Option)
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        DropdownMenu.Visible = not DropdownMenu.Visible
        DropdownMenu.Size = DropdownMenu.Visible and UDim2.new(1, -20, 0, #Options * 24) or UDim2.new(1, -20, 0, 0)
    end)
    
    return DropdownFrame
end

-- Construction de l'onglet AIM
local AimFrame = TabFrames[1]
CreateToggle(AimFrame, "AIMBOT", EventHorizon.Aim.Enabled, function()
    EventHorizon.Aim.Enabled = not EventHorizon.Aim.Enabled
    return EventHorizon.Aim.Enabled
end)

CreateDropdown(AimFrame, "LOCK KEY", {"MouseButton2", "MouseButton1", "LeftControl"}, "MouseButton2", function(Value)
    EventHorizon.Aim.LockKey = Enum.UserInputType[Value]
end)

CreateDropdown(AimFrame, "TARGET PART", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(Value)
    EventHorizon.Aim.TargetPart = Value
end)

CreateSlider(AimFrame, "FOV", 10, 500, EventHorizon.Aim.FOV, function(Value)
    EventHorizon.Aim.FOV = Value
end)

CreateSlider(AimFrame, "SMOOTH", 0.01, 1, EventHorizon.Aim.Smoothness, function(Value)
    EventHorizon.Aim.Smoothness = Value
end)

CreateToggle(AimFrame, "TRIGGER BOT", EventHorizon.Aim.UseTriggerBot, function()
    EventHorizon.Aim.UseTriggerBot = not EventHorizon.Aim.UseTriggerBot
    return EventHorizon.Aim.UseTriggerBot
end)

CreateToggle(AimFrame, "FAST SHOOT", EventHorizon.Aim.FastShoot, function()
    EventHorizon.Aim.FastShoot = not EventHorizon.Aim.FastShoot
    return EventHorizon.Aim.FastShoot
end)

CreateToggle(AimFrame, "MAGIC BULLET", EventHorizon.Aim.MagicBullet, function()
    EventHorizon.Aim.MagicBullet = not EventHorizon.Aim.MagicBullet
    return EventHorizon.Aim.MagicBullet
end)

CreateSlider(AimFrame, "MAGIC HITBOX", 1, 20, EventHorizon.Aim.MagicHitboxSize, function(Value)
    EventHorizon.Aim.MagicHitboxSize = Value
end)

CreateToggle(AimFrame, "SILENT AIM", EventHorizon.Aim.SilentAim, function()
    EventHorizon.Aim.SilentAim = not EventHorizon.Aim.SilentAim
    return EventHorizon.Aim.SilentAim
end)

CreateSlider(AimFrame, "SILENT HIT %", 1, 100, EventHorizon.Aim.SilentHitChance, function(Value)
    EventHorizon.Aim.SilentHitChance = Value
end)

-- Construction de l'onglet VISUAL
local VisualFrame = TabFrames[2]
CreateToggle(VisualFrame, "ESP", EventHorizon.Visual.ESP, function()
    EventHorizon.Visual.ESP = not EventHorizon.Visual.ESP
    return EventHorizon.Visual.ESP
end)

CreateDropdown(VisualFrame, "BOX TYPE", {"2D Box", "2D Corner", "3D Box"}, "2D Corner", function(Value)
    EventHorizon.Visual.BoxType = Value
end)

CreateToggle(VisualFrame, "TRACERS", EventHorizon.Visual.Tracers, function()
    EventHorizon.Visual.Tracers = not EventHorizon.Visual.Tracers
    return EventHorizon.Visual.Tracers
end)

CreateDropdown(VisualFrame, "TRACER ORIGIN", {"Top", "Middle", "Bottom"}, "Bottom", function(Value)
    EventHorizon.Visual.TracerOrigin = Value
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
    if EventHorizon.Skins.Enabled then
        ApplySkin()
    end
    return EventHorizon.Skins.Enabled
end)

CreateDropdown(SkinsFrame, "WEAPON", EventHorizon.Skins.WeaponList, "Assault Rifle", function(Value)
    EventHorizon.Skins.SelectedWeapon = Value
    -- Mettre à jour les skins disponibles pour cette arme
end)

CreateDropdown(SkinsFrame, "SKIN", EventHorizon.Skins.SkinDatabase["Assault Rifle"], "Phoenix Rifle", function(Value)
    EventHorizon.Skins.SelectedSkin = Value
    if EventHorizon.Skins.Enabled then
        ApplySkin()
    end
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

local NoclipToggle = CreateToggle(MiscFrame, "NO CLIP [H]", EventHorizon.Misc.NoClip, function()
    EventHorizon.Misc.NoClip = not EventHorizon.Misc.NoClip
    return EventHorizon.Misc.NoClip
end)

function UpdateGUI()
    NoclipToggle.Text = "NO CLIP [H] [" .. (EventHorizon.Misc.NoClip and "ON" or "OFF") .. "]"
    NoclipToggle.BackgroundColor3 = EventHorizon.Misc.NoClip and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 0, 0)
end

-- Bouton de fermeture
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 12
CloseButton.Parent = TitleFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============================================
-- BOUCLE PRINCIPALE
-- ============================================

local LastUpdate = tick()
RunService.RenderStepped:Connect(function()
    local Now = tick()
    
    -- Mise à jour toutes les 0.03 secondes pour la performance
    if Now - LastUpdate > 0.03 then
        -- Aimbot
        AimAtTarget()
        TriggerBot()
        
        -- Visuals
        UpdateVisuals()
        
        -- Misc
        UpdateMisc()
        
        LastUpdate = Now
    end
end)

-- Nettoyage lors de la fermeture
LocalPlayer.CharacterAdded:Connect(function()
    if FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed then
        -- Touche pour afficher/cacher le GUI (F5)
        if Input.KeyCode == Enum.KeyCode.F5 then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

print("============================================")
print("EVENT HORIZON CHEAT v2.0 LOADED SUCCESSFULLY")
print("GUI Key: F5 | NoClip Key: H")
print("============================================")

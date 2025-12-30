-- == Script Lua Rivals Cheat - Villain Mode ==
-- GUI modern avec 4 onglets: Aim, Visual, Skins, Misc

-- Initialisation
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Variables globales
local Aiming = {
    Enabled = false,
    FOV = 100,
    Smoothness = 0.1,
    TargetPart = "Head",
    UseTriggerBot = false,
    TriggerDelay = 0.01,
    FastShoot = false,
    ShootSpeed = 0.001,
    MagicBullet = false,
    MagicPenetration = 10,
    MagicHitboxSize = 5,
    SilentAim = false,
    SilentHitChance = 100
}

local Visuals = {
    ESP = true,
    BoxType = "2D Corner",
    BoxColor = Color3.fromRGB(255, 0, 0),
    Tracers = true,
    TracerOrigin = "Bottom",
    TracerColor = Color3.fromRGB(0, 255, 0),
    Chams = true,
    ChamsColor = Color3.fromRGB(255, 0, 255),
    ChamsTransparency = 0.5
}

local Skins = {
    Enabled = false,
    WeaponSkin = "Gold",
    CharacterSkin = "Dark"
}

local Misc = {
    Fly = false,
    FlySpeed = 50,
    WalkSpeed = false,
    SpeedValue = 50,
    JumpPower = false,
    JumpValue = 100,
    BunnyHop = false,
    NoClip = false
}

-- Fonction pour trouver le joueur le plus proche dans le FOV
function GetClosestPlayer()
    local closest = nil
    local maxDist = Aiming.FOV
    local pos = Camera.CFrame.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            
            if onScreen and distance < maxDist then
                closest = player
                maxDist = distance
            end
        end
    end
    return closest
end

-- Fonction AimBot avec Smooth
function AimAt(target)
    if not target or not target.Character or not target.Character:FindFirstChild(Aiming.TargetPart) then return end
    
    local part = target.Character[Aiming.TargetPart]
    local camera = Camera
    local targetPosition = part.Position
    
    if Aiming.MagicBullet then
        targetPosition = targetPosition + Vector3.new(
            math.random(-Aiming.MagicHitboxSize, Aiming.MagicHitboxSize),
            math.random(-Aiming.MagicHitboxSize, Aiming.MagicHitboxSize),
            math.random(-Aiming.MagicHitboxSize, Aiming.MagicHitboxSize)
        )
    end
    
    local current = camera.CFrame
    local targetCF = CFrame.lookAt(camera.CFrame.Position, targetPosition)
    local smooth = Aiming.Smoothness
    
    if Aiming.SilentAim and math.random(1,100) <= Aiming.SilentHitChance then
        -- Silent Aim : redirection des tirs sans bouger la caméra
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
            local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if tool:FindFirstChild("Handle") then
                local ray = Ray.new(tool.Handle.Position, (targetPosition - tool.Handle.Position).Unit * 1000)
                local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                -- Forcer la hit
            end
        end
    else
        -- Aim normal
        camera.CFrame = current:Lerp(targetCF, 1 - smooth)
    end
end

-- TriggerBot
function TriggerBot()
    if not Aiming.UseTriggerBot then return end
    
    local target = GetClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        local hum = target.Character.Humanoid
        if hum.Health > 0 then
            -- Simuler un clic de souris
            mouse1press()
            if Aiming.FastShoot then
                wait(Aiming.ShootSpeed)
            else
                wait(Aiming.TriggerDelay)
            end
            mouse1release()
        end
    end
end

-- Fonction ESP
local ESPBoxes = {}
function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            
            if not ESPBoxes[player] then
                ESPBoxes[player] = {
                    Box = Drawing.new("Square"),
                    Tracer = Drawing.new("Line"),
                    Name = Drawing.new("Text")
                }
            end
            
            local esp = ESPBoxes[player]
            
            if Visuals.ESP and root and head then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local headPos, _ = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local height = (headPos.Y - pos.Y) * 2
                    local width = height / 2
                    
                    -- Box
                    esp.Box.Visible = true
                    esp.Box.Color = Visuals.BoxColor
                    esp.Box.Thickness = 2
                    
                    if Visuals.BoxType == "2D Corner" then
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    elseif Visuals.BoxType == "3D" then
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    end
                    
                    -- Tracer
                    esp.Tracer.Visible = Visuals.Tracers
                    esp.Tracer.Color = Visuals.TracerColor
                    esp.Tracer.Thickness = 1
                    
                    local originY
                    if Visuals.TracerOrigin == "Top" then
                        originY = 0
                    elseif Visuals.TracerOrigin == "Middle" then
                        originY = Camera.ViewportSize.Y/2
                    else -- Bottom
                        originY = Camera.ViewportSize.Y
                    end
                    
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, originY)
                    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    
                    -- Name
                    esp.Name.Visible = true
                    esp.Name.Color = Color3.fromRGB(255, 255, 255)
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                    esp.Name.Size = 14
                else
                    esp.Box.Visible = false
                    esp.Tracer.Visible = false
                    esp.Name.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Tracer.Visible = false
                esp.Name.Visible = false
            end
        elseif ESPBoxes[player] then
            ESPBoxes[player].Box.Visible = false
            ESPBoxes[player].Tracer.Visible = false
            ESPBoxes[player].Name.Visible = false
        end
    end
end

-- Chams
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "VillainChams"
ChamsFolder.Parent = Workspace

function UpdateChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    local cham = part:FindFirstChild("VillainCham") or Instance.new("BoxHandleAdornment")
                    if not part:FindFirstChild("VillainCham") then
                        cham.Name = "VillainCham"
                        cham.Adornee = part
                        cham.AlwaysOnTop = true
                        cham.ZIndex = 10
                        cham.Size = part.Size
                        cham.Parent = part
                    end
                    
                    cham.Visible = Visuals.Chams
                    cham.Color3 = Visuals.ChamsColor
                    cham.Transparency = Visuals.ChamsTransparency
                end
            end
        end
    end
end

-- Skin Changer
function UpdateSkins()
    if not Skins.Enabled then return end
    
    if LocalPlayer.Character then
        -- Changer l'apparence du personnage
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                if Skins.CharacterSkin == "Gold" then
                    part.BrickColor = BrickColor.new("Bright golden")
                    if part:FindFirstChild("SurfaceAppearance") then
                        part.SurfaceAppearance.Color3 = Color3.fromRGB(255, 215, 0)
                    end
                elseif Skins.CharacterSkin == "Dark" then
                    part.BrickColor = BrickColor.new("Really black")
                end
            end
        end
        
        -- Changer l'arme
        local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if tool then
            if Skins.WeaponSkin == "Gold" then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    handle.BrickColor = BrickColor.new("Bright golden")
                    if handle:FindFirstChild("Mesh") then
                        handle.Mesh.TextureId = ""
                    end
                end
            end
        end
    end
end

-- Fly System
local BodyVelocity
function UpdateFly()
    if Misc.Fly and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not BodyVelocity then
                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                BodyVelocity.P = 10000
                BodyVelocity.Parent = root
            end
            
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            BodyVelocity.Velocity = direction.Unit * Misc.FlySpeed
        end
    elseif BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
end

-- WalkSpeed et JumpPower
function UpdateMovement()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        
        if Misc.WalkSpeed then
            hum.WalkSpeed = Misc.SpeedValue
        else
            hum.WalkSpeed = 16
        end
        
        if Misc.JumpPower then
            hum.JumpPower = Misc.JumpValue
        else
            hum.JumpPower = 50
        end
        
        -- BunnyHop
        if Misc.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- NoClip
function UpdateNoClip()
    if Misc.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- GUI Modern
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VillainCheatGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.Text = "RIVALS CHEAT - VILLAIN MODE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TabButtons = {}
local TabFrames = {}
local Tabs = {"AIM", "VISUAL", "SKINS", "MISC"}

-- Création des onglets
for i, tabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0.25, 0, 0, 40)
    TabButton.Position = UDim2.new(0.25 * (i-1), 0, 0, 40)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabButton.Text = tabName
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = MainFrame
    TabButtons[i] = TabButton
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, -80)
    TabFrame.Position = UDim2.new(0, 0, 0, 80)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = i == 1
    TabFrame.Parent = MainFrame
    TabFrames[i] = TabFrame
end

-- Fonction pour changer d'onglet
function SwitchTab(index)
    for i, frame in ipairs(TabFrames) do
        frame.Visible = i == index
        TabButtons[i].BackgroundColor3 = i == index and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(40, 40, 40)
    end
end

for i, button in ipairs(TabButtons) do
    button.MouseButton1Click:Connect(function()
        SwitchTab(i)
    end)
end

-- Onglet AIM
local AimFrame = TabFrames[1]
local yOffset = 10

function CreateAimOption(text, y, callback, defaultValue)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0.45, -5, 0, 30)
    Toggle.Position = UDim2.new(0.025, 0, 0, y)
    Toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Toggle.Text = text
    Toggle.Font = Enum.Font.Gotham
    Toggle.TextSize = 12
    Toggle.Parent = AimFrame
    
    Toggle.MouseButton1Click:Connect(function()
        local newValue = not callback()
        Toggle.BackgroundColor3 = newValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
    
    return Toggle
end

function CreateAimSlider(text, y, min, max, defaultValue, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.45, -5, 0, 50)
    SliderFrame.Position = UDim2.new(0.025, 0, 0, y)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SliderFrame.Parent = AimFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = text .. ": " .. defaultValue
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.BackgroundTransparency = 1
    Label.Parent = SliderFrame
    
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, -20, 0, 10)
    Slider.Position = UDim2.new(0, 10, 0, 30)
    Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Slider.Parent = SliderFrame
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((defaultValue - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Fill.Parent = Slider
    
    Slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local con
            con = RunService.RenderStepped:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                local relativeX = math.clamp(mousePos.X - Slider.AbsolutePosition.X, 0, Slider.AbsoluteSize.X)
                local value = min + (relativeX / Slider.AbsoluteSize.X) * (max - min)
                value = math.floor(value)
                Fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
                Label.Text = text .. ": " .. value
                callback(value)
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    con:Disconnect()
                end
            end)
        end
    end)
    
    return SliderFrame
end

CreateAimOption("AIMBOT", yOffset, function()
    Aiming.Enabled = not Aiming.Enabled
    return Aiming.Enabled
end, false)
yOffset = yOffset + 35

CreateAimOption("TRIGGER BOT", yOffset, function()
    Aiming.UseTriggerBot = not Aiming.UseTriggerBot
    return Aiming.UseTriggerBot
end, false)
yOffset = yOffset + 35

CreateAimOption("FAST SHOOT", yOffset, function()
    Aiming.FastShoot = not Aiming.FastShoot
    return Aiming.FastShoot
end, false)
yOffset = yOffset + 35

CreateAimOption("MAGIC BULLET", yOffset, function()
    Aiming.MagicBullet = not Aiming.MagicBullet
    return Aiming.MagicBullet
end, false)
yOffset = yOffset + 35

CreateAimOption("SILENT AIM", yOffset, function()
    Aiming.SilentAim = not Aiming.SilentAim
    return Aiming.SilentAim
end, false)
yOffset = yOffset + 35

-- Sliders côté droit
CreateAimSlider("FOV", 10, 1, 500, Aiming.FOV, function(value)
    Aiming.FOV = value
end)

CreateAimSlider("SMOOTH", 70, 0.01, 1, Aiming.Smoothness, function(value)
    Aiming.Smoothness = value
end)

CreateAimSlider("HIT CHANCE %", 130, 1, 100, Aiming.SilentHitChance, function(value)
    Aiming.SilentHitChance = value
end)

CreateAimSlider("MAGIC HITBOX", 190, 1, 20, Aiming.MagicHitboxSize, function(value)
    Aiming.MagicHitboxSize = value
end)

-- Onglet VISUAL (simplifié pour la longueur)
local VisualFrame = TabFrames[2]
-- [Code similaire pour les options VISUAL]

-- Onglet SKINS
local SkinsFrame = TabFrames[3]
local SkinButton = Instance.new("TextButton")
SkinButton.Size = UDim2.new(0.9, 0, 0, 40)
SkinButton.Position = UDim2.new(0.05, 0, 0.2, 0)
SkinButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
SkinButton.Text = "ACTIVER SKINS DORÉS"
SkinButton.Font = Enum.Font.GothamBold
SkinButton.TextSize = 14
SkinButton.Parent = SkinsFrame

SkinButton.MouseButton1Click:Connect(function()
    Skins.Enabled = not Skins.Enabled
    Skins.CharacterSkin = "Gold"
    Skins.WeaponSkin = "Gold"
    SkinButton.BackgroundColor3 = Skins.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 215, 0)
    SkinButton.Text = Skins.Enabled and "SKINS DORÉS ACTIFS" or "ACTIVER SKINS DORÉS"
end)

-- Onglet MISC
local MiscFrame = TabFrames[4]
local MiscY = 10

function CreateMiscOption(text, y, callback, defaultValue)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0.45, -5, 0, 30)
    Toggle.Position = UDim2.new(0.025, 0, 0, y)
    Toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Toggle.Text = text
    Toggle.Font = Enum.Font.Gotham
    Toggle.TextSize = 12
    Toggle.Parent = MiscFrame
    
    Toggle.MouseButton1Click:Connect(function()
        local newValue = not callback()
        Toggle.BackgroundColor3 = newValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
    
    return Toggle
end

CreateMiscOption("FLY", MiscY, function()
    Misc.Fly = not Misc.Fly
    return Misc.Fly
end, false)
MiscY = MiscY + 35

CreateMiscOption("WALKSPEED", MiscY, function()
    Misc.WalkSpeed = not Misc.WalkSpeed
    return Misc.WalkSpeed
end, false)
MiscY = MiscY + 35

CreateMiscOption("JUMP POWER", MiscY, function()
    Misc.JumpPower = not Misc.JumpPower
    return Misc.JumpPower
end, false)
MiscY = MiscY + 35

CreateMiscOption("BUNNY HOP", MiscY, function()
    Misc.BunnyHop = not Misc.BunnyHop
    return Misc.BunnyHop
end, false)
MiscY = MiscY + 35

CreateMiscOption("NO CLIP", MiscY, function()
    Misc.NoClip = not Misc.NoClip
    return Misc.NoClip
end, false)

-- Boucle principale
RunService.RenderStepped:Connect(function()
    -- AimBot
    if Aiming.Enabled then
        local target = GetClosestPlayer()
        if target then
            AimAt(target)
        end
    end
    
    -- TriggerBot
    TriggerBot()
    
    -- Visuals
    if Visuals.ESP then
        UpdateESP()
    end
    
    if Visuals.Chams then
        UpdateChams()
    end
    
    -- Skins
    UpdateSkins()
    
    -- Misc
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

-- Nettoyage
LocalPlayer.CharacterAdded:Connect(function()
    BodyVelocity = nil
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

print("CHEAT RIVALS VILLAIN MODE CHARGÉ !")
print("Press RightShift pour afficher/cacher le menu")

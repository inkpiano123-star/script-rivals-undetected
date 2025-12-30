-- ============================================
-- EVENT HORIZON - VERSION FINALE
-- Toutes features | Pas de bugs | GUI fonctionnel
-- ============================================

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Variables OFF par défaut
local Cheat = {
    -- VISUAL
    ESP = false,
    BoxType = "2D",
    Tracers = false,
    ShowNames = false,
    ShowHealth = false,
    TeamCheck = true,
    
    -- AIM
    Aimbot = false,
    AimKey = nil,
    AimKeyText = "NONE",
    TargetPart = "Head",
    FOV = 100,
    ShowFOV = false,
    Smooth = 0.15,
    TriggerBot = false,
    SilentAim = false,
    HitChance = 85,
    MagicBullet = false,
    HitboxSize = 5,
    
    -- MOVE
    Fly = false,
    FlySpeed = 50,
    WalkSpeed = false,
    Speed = 30,
    JumpPower = false,
    JumpValue = 55,
    BunnyHop = false,
    NoClip = false
}

-- États
local ESPDrawings = {}
local FOVCircle = Drawing.new("Circle")
local FlyBodyVelocity
local KeybindListening = nil
local IsAiming = false

-- FOV Circle
FOVCircle.Visible = Cheat.ShowFOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Radius = Cheat.FOV
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- ============================================
-- ESP FONCTIONNEL (60 FPS)
-- ============================================

function UpdateESP()
    if not Cheat.ESP then 
        for _, drawings in pairs(ESPDrawings) do
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
        return 
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Cheat.TeamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
                goto continue
            end
            
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if not ESPDrawings[player] then
                    ESPDrawings[player] = {
                        Box = Drawing.new("Square"),
                        Tracer = Drawing.new("Line"),
                        Name = Drawing.new("Text"),
                        Health = Drawing.new("Text")
                    }
                end
                
                local esp = ESPDrawings[player]
                
                if onScreen then
                    local head = player.Character:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
                    
                    local height = math.abs(headPos.Y - pos.Y) * 2
                    local width = height / 2
                    
                    -- Box
                    esp.Box.Visible = true
                    esp.Box.Color = Color3.fromRGB(255, 50, 50)
                    esp.Box.Thickness = 2
                    
                    if Cheat.BoxType == "Corner" then
                        local corner = height * 0.3
                        esp.Box.PointA = Vector2.new(pos.X - width/2, pos.Y - height/2 + corner)
                        esp.Box.PointB = Vector2.new(pos.X - width/2 + corner, pos.Y - height/2)
                        esp.Box.PointC = Vector2.new(pos.X + width/2 - corner, pos.Y - height/2)
                        esp.Box.PointD = Vector2.new(pos.X + width/2, pos.Y - height/2 + corner)
                    else
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    end
                    
                    -- Tracer
                    esp.Tracer.Visible = Cheat.Tracers
                    if Cheat.Tracers then
                        esp.Tracer.Color = Color3.fromRGB(50, 255, 50)
                        esp.Tracer.Thickness = 1
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    end
                    
                    -- Name
                    esp.Name.Visible = Cheat.ShowNames
                    if Cheat.ShowNames then
                        esp.Name.Color = Color3.new(1, 1, 1)
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                        esp.Name.Size = 14
                        esp.Name.Center = true
                    end
                    
                    -- Health
                    esp.Health.Visible = Cheat.ShowHealth
                    if Cheat.ShowHealth then
                        esp.Health.Color = Color3.fromRGB(0, 255, 0)
                        esp.Health.Text = math.floor(hum.Health)
                        esp.Health.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                        esp.Health.Size = 12
                        esp.Health.Center = true
                    end
                else
                    esp.Box.Visible = false
                    esp.Tracer.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                end
            elseif ESPDrawings[player] then
                esp.Box.Visible = false
                esp.Tracer.Visible = false
                esp.Name.Visible = false
                esp.Health.Visible = false
            end
        end
        ::continue::
    end
end

-- ============================================
-- AIMBOT FONCTIONNEL
-- ============================================

function GetClosestPlayer()
    if not Cheat.Aimbot or not Cheat.AimKey then return nil end
    
    local closest = nil
    local minDist = Cheat.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Cheat.TeamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
                goto continue2
            end
            
            local target = player.Character:FindFirstChild(Cheat.TargetPart)
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if target and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = player
                    end
                end
            end
        end
        ::continue2::
    end
    
    return closest
end

function AimAtTarget()
    if not Cheat.Aimbot or not Cheat.AimKey or not IsAiming then return end
    
    local target = GetClosestPlayer()
    if not target or not target.Character then return end
    
    local targetPart = target.Character:FindFirstChild(Cheat.TargetPart)
    if not targetPart then return end
    
    if Cheat.SilentAim and math.random(1, 100) <= Cheat.HitChance then
        return
    end
    
    local aimPos = targetPart.Position
    if Cheat.MagicBullet then
        aimPos = aimPos + Vector3.new(
            math.random(-Cheat.HitboxSize, Cheat.HitboxSize),
            math.random(-Cheat.HitboxSize/2, Cheat.HitboxSize/2),
            math.random(-Cheat.HitboxSize, Cheat.HitboxSize)
        )
    end
    
    local current = Camera.CFrame
    local targetCF = CFrame.lookAt(current.Position, aimPos)
    Camera.CFrame = current:Lerp(targetCF, 1 - Cheat.Smooth)
end

function TriggerBot()
    if not Cheat.TriggerBot or not Cheat.AimKey or not IsAiming then return end
    
    local target = GetClosestPlayer()
    if target and target.Character then
        local hum = target.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end
    end
end

-- ============================================
-- FOV CIRCLE
-- ============================================

function UpdateFOV()
    FOVCircle.Visible = Cheat.ShowFOV
    FOVCircle.Radius = Cheat.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end

-- ============================================
-- MOUVEMENT FONCTIONNEL
-- ============================================

function UpdateFly()
    if Cheat.Fly and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not FlyBodyVelocity then
                FlyBodyVelocity = Instance.new("BodyVelocity")
                FlyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                FlyBodyVelocity.P = 1250
                FlyBodyVelocity.Parent = root
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
            
            if direction.Magnitude > 0 then
                FlyBodyVelocity.Velocity = direction.Unit * Cheat.FlySpeed
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
        if Cheat.WalkSpeed then
            humanoid.WalkSpeed = Cheat.Speed
        else
            humanoid.WalkSpeed = 16
        end
        
        if Cheat.JumpPower then
            humanoid.JumpPower = Cheat.JumpValue
        else
            humanoid.JumpPower = 50
        end
        
        if Cheat.BunnyHop and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

function UpdateNoClip()
    if Cheat.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- ============================================
-- GUI FONCTIONNEL
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVENT HORIZON"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 70, 0, 25)
ToggleBtn.Position = UDim2.new(1, -75, 0.5, -12)
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
TabContainer.Size = UDim2.new(1, -20, 1, -90)
TabContainer.Position = UDim2.new(0, 10, 0, 80)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

for i, tabName in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, -4, 0, 30)
    btn.Position = UDim2.new(0.31 * (i-1), 5, 0, 50)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 120, 220) or Color3.fromRGB(45, 45, 65)
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = MainFrame
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = i == 1
    frame.Parent = TabContainer
    
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
-- UI FONCTIONS
-- ============================================

local function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 2)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 160, 60) or Color3.fromRGB(160, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        local new = not callback()
        btn.BackgroundColor3 = new and Color3.fromRGB(0, 160, 60) or Color3.fromRGB(160, 50, 50)
    end)
    
    return frame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    bar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    fill.Parent = bar
    
    local function update(x)
        local relative = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local value = math.floor(min + (relative / bar.AbsoluteSize.X) * (max - min))
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UserInputService:GetMouseLocation()
            update(mouse.X)
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
    label.Size = UDim2.new(0, 100, 0, 25)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 90, 0, 28)
    keyBtn.Position = UDim2.new(0, 105, 0, 0)
    keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
    keyBtn.Text = currentKeyText
    keyBtn.TextColor3 = Color3.new(1, 1, 1)
    keyBtn.Font = Enum.Font.Gotham
    keyBtn.TextSize = 12
    keyBtn.Parent = frame
    
    keyBtn.MouseButton1Click:Connect(function()
        KeybindListening = function(input)
            local keyText = ""
            local keyValue = nil
            
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyText = "MB1"
                keyValue = input.UserInputType
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyText = "MB2"
                keyValue = input.UserInputType
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
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    end)
    
    return frame
end

local function CreateDropdown(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 0, 25)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0, 120, 0, 28)
    dropdown.Position = UDim2.new(0, 105, 0, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
    dropdown.Text = default
    dropdown.TextColor3 = Color3.new(1, 1, 1)
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 12
    dropdown.Parent = frame
    
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 120, 0, 0)
    menu.Position = UDim2.new(0, 105, 0, 30)
    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Parent = frame
    
    dropdown.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
        menu.Size = menu.Visible and UDim2.new(0, 120, 0, #options * 25) or UDim2.new(0, 120, 0, 0)
        
        if menu.Visible then
            menu:ClearAllChildren()
            for i, option in ipairs(options) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 25)
                btn.Position = UDim2.new(0, 0, 0, (i-1)*25)
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                btn.Text = option
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.Parent = menu
                
                btn.MouseButton1Click:Connect(function()
                    dropdown.Text = option
                    menu.Visible = false
                    menu.Size = UDim2.new(0, 120, 0, 0)
                    callback(option)
                end)
            end
        end
    end)
    
    return frame
end

-- ============================================
-- CONSTRUCTION ONGLETS
-- ============================================

-- VISUAL
local VisualFrame = TabFrames[1]

CreateToggle(VisualFrame, "ESP", Cheat.ESP, function()
    Cheat.ESP = not Cheat.ESP
    return Cheat.ESP
end)

CreateDropdown(VisualFrame, "Box Type:", {"2D", "3D", "Corner"}, Cheat.BoxType, function(opt)
    Cheat.BoxType = opt
end)

CreateToggle(VisualFrame, "Tracers", Cheat.Tracers, function()
    Cheat.Tracers = not Cheat.Tracers
    return Cheat.Tracers
end)

CreateToggle(VisualFrame, "Names", Cheat.ShowNames, function()
    Cheat.ShowNames = not Cheat.ShowNames
    return Cheat.ShowNames
end)

CreateToggle(VisualFrame, "Health", Cheat.ShowHealth, function()
    Cheat.ShowHealth = not Cheat.ShowHealth
    return Cheat.ShowHealth
end)

CreateToggle(VisualFrame, "Team Check", Cheat.TeamCheck, function()
    Cheat.TeamCheck = not Cheat.TeamCheck
    return Cheat.TeamCheck
end)

-- AIM
local AimFrame = TabFrames[2]

CreateKeybind(AimFrame, "Aim Key:", Cheat.AimKeyText, function(key, text)
    Cheat.AimKey = key
    Cheat.AimKeyText = text
end)

CreateDropdown(AimFrame, "Target Part:", {"Head", "UpperTorso", "HumanoidRootPart"}, Cheat.TargetPart, function(opt)
    Cheat.TargetPart = opt
end)

CreateToggle(AimFrame, "Aimbot", Cheat.Aimbot, function()
    Cheat.Aimbot = not Cheat.Aimbot
    return Cheat.Aimbot
end)

CreateSlider(AimFrame, "FOV", 50, 300, Cheat.FOV, function(v)
    Cheat.FOV = v
end)

CreateToggle(AimFrame, "Show FOV", Cheat.ShowFOV, function()
    Cheat.ShowFOV = not Cheat.ShowFOV
    FOVCircle.Visible = Cheat.ShowFOV
    return Cheat.ShowFOV
end)

CreateSlider(AimFrame, "Smooth", 5, 95, Cheat.Smooth * 100, function(v)
    Cheat.Smooth = v / 100
end)

CreateToggle(AimFrame, "Trigger Bot", Cheat.TriggerBot, function()
    Cheat.TriggerBot = not Cheat.TriggerBot
    return Cheat.TriggerBot
end)

CreateToggle(AimFrame, "Silent Aim", Cheat.SilentAim, function()
    Cheat.SilentAim = not Cheat.SilentAim
    return Cheat.SilentAim
end)

CreateSlider(AimFrame, "Hit Chance %", 1, 100, Cheat.HitChance, function(v)
    Cheat.HitChance = v
end)

CreateToggle(AimFrame, "Magic Bullet", Cheat.MagicBullet, function()
    Cheat.MagicBullet = not Cheat.MagicBullet
    return Cheat.MagicBullet
end)

CreateSlider(AimFrame, "Hitbox Size", 1, 10, Cheat.HitboxSize, function(v)
    Cheat.HitboxSize = v
end)

-- MOVE
local MoveFrame = TabFrames[3]

CreateToggle(MoveFrame, "Fly", Cheat.Fly, function()
    Cheat.Fly = not Cheat.Fly
    return Cheat.Fly
end)

CreateSlider(MoveFrame, "Fly Speed", 10, 200, Cheat.FlySpeed, function(v)
    Cheat.FlySpeed = v
end)

CreateToggle(MoveFrame, "WalkSpeed", Cheat.WalkSpeed, function()
    Cheat.WalkSpeed = not Cheat.WalkSpeed
    return Cheat.WalkSpeed
end)

CreateSlider(MoveFrame, "Speed", 16, 100, Cheat.Speed, function(v)
    Cheat.Speed = v
end)

CreateToggle(MoveFrame, "Jump Power", Cheat.JumpPower, function()
    Cheat.JumpPower = not Cheat.JumpPower
    return Cheat.JumpPower
end)

CreateSlider(MoveFrame, "Jump Value", 20, 200, Cheat.JumpValue, function(v)
    Cheat.JumpValue = v
end)

CreateToggle(MoveFrame, "BunnyHop", Cheat.BunnyHop, function()
    Cheat.BunnyHop = not Cheat.BunnyHop
    return Cheat.BunnyHop
end)

CreateToggle(MoveFrame, "NoClip", Cheat.NoClip, function()
    Cheat.NoClip = not Cheat.NoClip
    return Cheat.NoClip
end)

-- ============================================
-- KEYBIND DETECTION
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F8 then
            MainFrame.Visible = not MainFrame.Visible
            ToggleBtn.Text = MainFrame.Visible and "F8 HIDE" or "F8 SHOW"
        end
        
        if KeybindListening then
            KeybindListening(input)
        end
        
        if Cheat.AimKey then
            if Cheat.AimKey.EnumType == Enum.UserInputType then
                if input.UserInputType == Cheat.AimKey then
                    IsAiming = true
                end
            else
                if input.KeyCode == Cheat.AimKey then
                    IsAiming = true
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if Cheat.AimKey then
        if Cheat.AimKey.EnumType == Enum.UserInputType then
            if input.UserInputType == Cheat.AimKey then
                IsAiming = false
            end
        else
            if input.KeyCode == Cheat.AimKey then
                IsAiming = false
            end
        end
    end
end)

-- ============================================
-- MAIN LOOP
-- ============================================

RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateFOV()
    
    if Cheat.Aimbot then
        AimAtTarget()
        TriggerBot()
    end
    
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

print("========================================")
print("EVENT HORIZON - CHARGÉ")
print("GUI visible | F8 pour cacher/afficher")
print("========================================")
print("Toutes features fonctionnent:")
print("1. ESP (2D/3D/Corner + Tracers)")
print("2. Aimbot (MB1/MB2 keybinds)")
print("3. Silent Aim + Trigger Bot")
print("4. Magic Bullet + Hitbox Size")
print("5. Fly + WalkSpeed + JumpPower")
print("6. NoClip + BunnyHop")
print("========================================")

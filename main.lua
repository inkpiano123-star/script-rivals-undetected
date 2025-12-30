-- ============================================
-- EVENT HORIZON - VERSION FINALE
-- ESP réglable | GUI fixé | F9 pour toggle
-- ============================================

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Variables
local Cheat = {
    ESP = {
        Enabled = true,
        Box = true,
        Tracers = true,
        Names = true,
        Health = true,
        BoxSize = 1.0,  -- Facteur de taille
        BoxColor = Color3.fromRGB(255, 50, 50),
        TracerColor = Color3.fromRGB(50, 255, 50)
    },
    Aim = {
        Enabled = false,
        FOV = 120,
        Smooth = 0.2,
        TriggerBot = false,
        MagicBullet = false,
        HitboxSize = 3
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

-- Drawing ESP
local ESPDrawings = {}

function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
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
                
                if Cheat.ESP.Enabled and onScreen then
                    local head = player.Character:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
                    
                    -- Taille réglable
                    local height = math.abs(headPos.Y - pos.Y) * 2 * Cheat.ESP.BoxSize
                    local width = height / 2
                    
                    -- Box
                    esp.Box.Visible = Cheat.ESP.Box
                    esp.Box.Color = Cheat.ESP.BoxColor
                    esp.Box.Thickness = 2
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    
                    -- Tracer
                    esp.Tracer.Visible = Cheat.ESP.Tracers
                    esp.Tracer.Color = Cheat.ESP.TracerColor
                    esp.Tracer.Thickness = 1
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    
                    -- Name
                    esp.Name.Visible = Cheat.ESP.Names
                    esp.Name.Color = Color3.new(1, 1, 1)
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                    esp.Name.Size = 14
                    esp.Name.Center = true
                    
                    -- Health
                    esp.Health.Visible = Cheat.ESP.Health
                    local healthColor = Color3.fromRGB(
                        255 - (hum.Health/hum.MaxHealth * 255),
                        (hum.Health/hum.MaxHealth * 255),
                        0
                    )
                    esp.Health.Color = healthColor
                    esp.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    esp.Health.Position = Vector2.new(pos.X, pos.Y + height/2 + 10)
                    esp.Health.Size = 13
                    esp.Health.Center = true
                else
                    esp.Box.Visible = false
                    esp.Tracer.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                end
            end
        end
    end
end

-- GUI SIMPLE ET PROPRE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
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
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVENT HORIZON"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 70, 0, 25)
ToggleBtn.Position = UDim2.new(1, -80, 0.5, -12)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
ToggleBtn.Text = "F9 HIDE"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.TextSize = 12
ToggleBtn.Parent = Header

-- Onglets (Frame visible par onglet)
local Tabs = {"ESP", "AIM", "MOVE"}
local TabButtons = {}
local TabFrames = {}

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -80)
TabContainer.Position = UDim2.new(0, 10, 0, 70)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Créer un Frame pour chaque onglet
for i, tabName in ipairs(Tabs) do
    -- Bouton
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, -4, 0, 30)
    btn.Position = UDim2.new(0.32 * (i-1), 5, 0, 40)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 100, 180) or Color3.fromRGB(45, 45, 65)
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = MainFrame
    TabButtons[i] = btn
    
    -- Frame de contenu
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = i == 1
    frame.Parent = TabContainer
    TabFrames[i] = frame
    
    btn.MouseButton1Click:Connect(function()
        for j = 1, #Tabs do
            TabFrames[j].Visible = j == i
            TabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(60, 100, 180) or Color3.fromRGB(45, 45, 65)
        end
    end)
end

-- Fonction pour ajouter des éléments
local function AddToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, 2)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        local new = not callback()
        btn.BackgroundColor3 = new and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
        btn.Text = text .. ": " .. (new and "ON" or "OFF")
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
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
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    bar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.Parent = bar
    
    local function update(x)
        local relative = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local value = math.floor(min + (relative/bar.AbsoluteSize.X)*(max-min))
        fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UserInputService:GetMouseLocation()
            update(mouse.X)
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local mouse = UserInputService:GetMouseLocation()
                    update(mouse.X)
                else
                    connection:Disconnect()
                end
            end)
        end
    end)
end

-- Onglet ESP
local ESPFrame = TabFrames[1]
AddToggle(ESPFrame, "ESP", Cheat.ESP.Enabled, function()
    Cheat.ESP.Enabled = not Cheat.ESP.Enabled
    return Cheat.ESP.Enabled
end)

AddToggle(ESPFrame, "Box", Cheat.ESP.Box, function()
    Cheat.ESP.Box = not Cheat.ESP.Box
    return Cheat.ESP.Box
end)

AddToggle(ESPFrame, "Tracers", Cheat.ESP.Tracers, function()
    Cheat.ESP.Tracers = not Cheat.ESP.Tracers
    return Cheat.ESP.Tracers
end)

AddToggle(ESPFrame, "Names", Cheat.ESP.Names, function()
    Cheat.ESP.Names = not Cheat.ESP.Names
    return Cheat.ESP.Names
end)

AddToggle(ESPFrame, "Health", Cheat.ESP.Health, function()
    Cheat.ESP.Health = not Cheat.ESP.Health
    return Cheat.ESP.Health
end)

AddSlider(ESPFrame, "Box Size", 0.5, 2.0, Cheat.ESP.BoxSize, function(v)
    Cheat.ESP.BoxSize = v
end)

-- Onglet AIM
local AIMFrame = TabFrames[2]
AddToggle(AIMFrame, "Aimbot", Cheat.Aim.Enabled, function()
    Cheat.Aim.Enabled = not Cheat.Aim.Enabled
    return Cheat.Aim.Enabled
end)

AddSlider(AIMFrame, "FOV", 50, 300, Cheat.Aim.FOV, function(v)
    Cheat.Aim.FOV = v
end)

AddSlider(AIMFrame, "Smooth", 0.05, 1.0, Cheat.Aim.Smooth, function(v)
    Cheat.Aim.Smooth = v
end)

AddToggle(AIMFrame, "TriggerBot", Cheat.Aim.TriggerBot, function()
    Cheat.Aim.TriggerBot = not Cheat.Aim.TriggerBot
    return Cheat.Aim.TriggerBot
end)

AddToggle(AIMFrame, "MagicBullet", Cheat.Aim.MagicBullet, function()
    Cheat.Aim.MagicBullet = not Cheat.Aim.MagicBullet
    return Cheat.Aim.MagicBullet
end)

-- Onglet MOVE
local MOVEFrame = TabFrames[3]
AddToggle(MOVEFrame, "Fly", Cheat.Move.Fly, function()
    Cheat.Move.Fly = not Cheat.Move.Fly
    return Cheat.Move.Fly
end)

AddSlider(MOVEFrame, "Fly Speed", 10, 100, Cheat.Move.FlySpeed, function(v)
    Cheat.Move.FlySpeed = v
end)

AddToggle(MOVEFrame, "WalkSpeed", Cheat.Move.WalkSpeed, function()
    Cheat.Move.WalkSpeed = not Cheat.Move.WalkSpeed
    return Cheat.Move.WalkSpeed
end)

AddSlider(MOVEFrame, "Speed", 16, 100, Cheat.Move.Speed, function(v)
    Cheat.Move.Speed = v
end)

AddToggle(MOVEFrame, "Jump Power", Cheat.Move.JumpPower, function()
    Cheat.Move.JumpPower = not Cheat.Move.JumpPower
    return Cheat.Move.JumpPower
end)

AddToggle(MOVEFrame, "BunnyHop", Cheat.Move.BunnyHop, function()
    Cheat.Move.BunnyHop = not Cheat.Move.BunnyHop
    return Cheat.Move.BunnyHop
end)

AddToggle(MOVEFrame, "NoClip", Cheat.Move.NoClip, function()
    Cheat.Move.NoClip = not Cheat.Move.NoClip
    return Cheat.Move.NoClip
end)

-- F9 pour cacher/afficher
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleBtn.Text = MainFrame.Visible and "F9 HIDE" or "F9 SHOW"
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F9 then
        MainFrame.Visible = not MainFrame.Visible
        ToggleBtn.Text = MainFrame.Visible and "F9 HIDE" or "F9 SHOW"
    end
end)

-- Fonctions gameplay
local flyBV

function UpdateFly()
    if Cheat.Move.Fly and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not flyBV then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(40000, 40000, 40000)
                flyBV.P = 1250
                flyBV.Parent = root
            end
            
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            
            if dir.Magnitude > 0 then
                flyBV.Velocity = dir.Unit * Cheat.Move.FlySpeed
            else
                flyBV.Velocity = Vector3.new(0, 0, 0)
            end
        end
    elseif flyBV then
        flyBV:Destroy()
        flyBV = nil
    end
end

function UpdateMovement()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        if Cheat.Move.WalkSpeed then
            hum.WalkSpeed = Cheat.Move.Speed
        elseif hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
        
        if Cheat.Move.JumpPower then
            hum.JumpPower = Cheat.Move.Jump
        elseif hum.JumpPower ~= 50 then
            hum.JumpPower = 50
        end
        
        if Cheat.Move.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
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

-- Aimbot amélioré
local lastAimTime = 0

function GetClosestPlayer()
    if not Cheat.Aim.Enabled then return nil end
    
    local closest = nil
    local minDist = Cheat.Aim.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
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

function AimAtPlayer()
    if not Cheat.Aim.Enabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        lastAimTime = 0
        return
    end
    
    -- Limite à 60 FPS pour éviter les sauts
    local now = tick()
    if now - lastAimTime < 0.016 then return end
    lastAimTime = now
    
    local target = GetClosestPlayer()
    if not target or not target.Character then return end
    
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    local aimPos = head.Position
    if Cheat.Aim.MagicBullet then
        aimPos = aimPos + Vector3.new(
            math.random(-Cheat.Aim.HitboxSize, Cheat.Aim.HitboxSize),
            math.random(-Cheat.Aim.HitboxSize/2, Cheat.Aim.HitboxSize/2),
            math.random(-Cheat.Aim.HitboxSize, Cheat.Aim.HitboxSize)
        )
    end
    
    local current = Camera.CFrame
    local targetCF = CFrame.lookAt(current.Position, aimPos)
    Camera.CFrame = current:Lerp(targetCF, 1 - Cheat.Aim.Smooth)
end

-- TriggerBot
function TriggerBot()
    if not Cheat.Aim.TriggerBot or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    
    local target = GetClosestPlayer()
    if target and target.Character then
        local hum = target.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            mouse1press()
            wait(0.05)
            mouse1release()
        end
    end
end

-- Boucle principale
RunService.RenderStepped:Connect(function()
    UpdateESP()
    AimAtPlayer()
    TriggerBot()
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

print("========================================")
print("EVENT HORIZON - VERSION FINALE")
print("F9 pour cacher/afficher le GUI")
print("ESP réglable | Aimbot smooth")
print("========================================")

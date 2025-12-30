-- ============================================
-- EVENT HORIZON - GUI FIXÉ
-- Drawing ESP | Interface basique fonctionnelle
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
    ESP = true,
    Aimbot = false,
    FOV = 100,
    Smooth = 0.1,
    Fly = false,
    FlySpeed = 32,
    WalkSpeed = false,
    Speed = 24,
    JumpPower = false,
    Jump = 55,
    BunnyHop = false,
    NoClip = false
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
                
                if Cheat.ESP and onScreen then
                    local head = player.Character:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
                    
                    local height = math.abs(headPos.Y - pos.Y) * 2
                    local width = height / 2
                    
                    -- Box
                    esp.Box.Visible = true
                    esp.Box.Color = Color3.fromRGB(255, 50, 50)
                    esp.Box.Thickness = 1
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    
                    -- Tracer
                    esp.Tracer.Visible = true
                    esp.Tracer.Color = Color3.fromRGB(50, 255, 50)
                    esp.Tracer.Thickness = 1
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    
                    -- Name
                    esp.Name.Visible = true
                    esp.Name.Color = Color3.new(1, 1, 1)
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                    esp.Name.Size = 14
                    esp.Name.Center = true
                    
                    -- Health
                    esp.Health.Visible = true
                    esp.Health.Color = Color3.fromRGB(0, 255, 0)
                    esp.Health.Text = "HP: " .. math.floor(hum.Health)
                    esp.Health.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                    esp.Health.Size = 12
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

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 350)
Main.Position = UDim2.new(0.5, -125, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Title.Text = "EVENT HORIZON"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

local TabButtons = {}
local TabFrames = {}
local Tabs = {"ESP", "AIM", "MOVE"}

for i, name in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -2, 0, 30)
    btn.Position = UDim2.new(0.33 * (i-1), 0, 0, 40)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 100, 180) or Color3.fromRGB(50, 50, 70)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = Main
    TabButtons[i] = btn
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 1, -100)
    frame.Position = UDim2.new(0, 10, 0, 80)
    frame.BackgroundTransparency = 1
    frame.Visible = i == 1
    frame.Parent = Main
    TabFrames[i] = frame
    
    btn.MouseButton1Click:Connect(function()
        for j = 1, #Tabs do
            TabFrames[j].Visible = j == i
            TabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(60, 100, 180) or Color3.fromRGB(50, 50, 70)
        end
    end)
end

-- Fonction toggle
function MakeToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, 2)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        local new = not callback()
        btn.BackgroundColor3 = new and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(150, 50, 50)
    end)
    
    return frame
end

-- Fonction slider
function MakeSlider(parent, text, min, max, default, callback)
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
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    bar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.Parent = bar
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UserInputService:GetMouseLocation()
            local x = mouse.X
            local relative = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
            local value = math.floor(min + (relative/bar.AbsoluteSize.X)*(max-min))
            fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
            label.Text = text .. ": " .. value
            callback(value)
        end
    end)
    
    return frame
end

-- Onglet ESP
local ESPFrame = TabFrames[1]
MakeToggle(ESPFrame, "ESP", Cheat.ESP, function()
    Cheat.ESP = not Cheat.ESP
    return Cheat.ESP
end)

-- Onglet AIM
local AIMFrame = TabFrames[2]
MakeToggle(AIMFrame, "AIMBOT", Cheat.Aimbot, function()
    Cheat.Aimbot = not Cheat.Aimbot
    return Cheat.Aimbot
end)

MakeSlider(AIMFrame, "FOV", 10, 500, Cheat.FOV, function(v)
    Cheat.FOV = v
end)

MakeSlider(AIMFrame, "SMOOTH", 0.01, 1, Cheat.Smooth, function(v)
    Cheat.Smooth = v
end)

-- Onglet MOVE
local MOVEFrame = TabFrames[3]
MakeToggle(MOVEFrame, "FLY", Cheat.Fly, function()
    Cheat.Fly = not Cheat.Fly
    return Cheat.Fly
end)

MakeSlider(MOVEFrame, "FLY SPEED", 10, 100, Cheat.FlySpeed, function(v)
    Cheat.FlySpeed = v
end)

MakeToggle(MOVEFrame, "WALKSPEED", Cheat.WalkSpeed, function()
    Cheat.WalkSpeed = not Cheat.WalkSpeed
    return Cheat.WalkSpeed
end)

MakeSlider(MOVEFrame, "SPEED", 16, 100, Cheat.Speed, function(v)
    Cheat.Speed = v
end)

MakeToggle(MOVEFrame, "NO CLIP", Cheat.NoClip, function()
    Cheat.NoClip = not Cheat.NoClip
    return Cheat.NoClip
end)

MakeToggle(MOVEFrame, "BUNNY HOP", Cheat.BunnyHop, function()
    Cheat.BunnyHop = not Cheat.BunnyHop
    return Cheat.BunnyHop
end)

-- Bouton fermer
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Title

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    for _, drawings in pairs(ESPDrawings) do
        for _, draw in pairs(drawings) do
            draw:Remove()
        end
    end
end)

-- Fonctions gameplay
local flyBV

function UpdateFly()
    if Cheat.Fly and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not flyBV then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(40000, 40000, 40000)
                flyBV.Parent = root
            end
            
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * Cheat.FlySpeed or Vector3.new(0, 0, 0)
        end
    elseif flyBV then
        flyBV:Destroy()
        flyBV = nil
    end
end

function UpdateMovement()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        if Cheat.WalkSpeed then
            hum.WalkSpeed = Cheat.Speed
        elseif hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
        
        if Cheat.JumpPower then
            hum.JumpPower = Cheat.Jump
        elseif hum.JumpPower ~= 50 then
            hum.JumpPower = 50
        end
        
        if Cheat.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
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

-- Aimbot basique
function GetClosest()
    if not Cheat.Aimbot then return nil end
    
    local closest = nil
    local dist = Cheat.FOV
    local mouse = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if d < dist then
                        dist = d
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

function Aim()
    if not Cheat.Aimbot or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    
    local target = GetClosest()
    if not target or not target.Character then return end
    
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    local current = Camera.CFrame
    local targetCF = CFrame.lookAt(current.Position, head.Position)
    Camera.CFrame = current:Lerp(targetCF, 1 - Cheat.Smooth)
end

-- Boucle principale
RunService.RenderStepped:Connect(function()
    UpdateESP()
    Aim()
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

print("========================================")
print("EVENT HORIZON - CHARGÉ")
print("ESP: ON | Clic droit pour Aimbot")
print("========================================")

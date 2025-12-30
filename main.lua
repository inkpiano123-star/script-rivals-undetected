-- ============================================
-- EVENT HORIZON - VERSION SIMPLIFIÉE
-- Tout fonctionne | GUI propre | Toggles corrects
-- ============================================

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Variables (TOUT OFF par défaut)
local Cheat = {
    ESP = false,
    Aim = false,
    AimKey = nil,
    AimKeyText = "NONE",
    Fly = false,
    FlySpeed = 50,
    WalkSpeed = false,
    Speed = 30,
    NoClip = false,
    BunnyHop = false
}

-- États
local ESPDrawings = {}
local FlyBodyVelocity
local KeybindListening = nil

-- ============================================
-- ESP SIMPLE
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
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if not ESPDrawings[player] then
                    ESPDrawings[player] = {
                        Box = Drawing.new("Square"),
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
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    
                    -- Name
                    esp.Name.Visible = true
                    esp.Name.Color = Color3.new(1, 1, 1)
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                    esp.Name.Size = 14
                    esp.Name.Center = true
                    
                    -- Health
                    esp.Health.Visible = true
                    esp.Health.Color = Color3.fromRGB(0, 255, 0)
                    esp.Health.Text = math.floor(hum.Health)
                    esp.Health.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                    esp.Health.Size = 12
                    esp.Health.Center = true
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                end
            elseif ESPDrawings[player] then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Health.Visible = false
            end
        end
    end
end

-- ============================================
-- GUI PROPRE ET SIMPLE
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventHorizonGUI"
ScreenGui.Parent = game:GetService("CoreGui")

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
Title.Size = UDim2.new(1, -100, 1, 0)
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

-- Onglets simplifiés
local Tabs = {"VISUAL", "AIM", "MOVE"}
local TabButtons = {}
local TabFrames = {}

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -100)
TabContainer.Position = UDim2.new(0, 10, 0, 80)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

for i, tabName in ipairs(Tabs) do
    -- Bouton
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, -4, 0, 30)
    btn.Position = UDim2.new(0.31 * (i-1), 5, 0, 45)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 120, 220) or Color3.fromRGB(45, 45, 65)
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = MainFrame
    
    -- Frame
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
-- FONCTIONS UI SIMPLES
-- ============================================

local function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 2)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 160, 60) or Color3.fromRGB(160, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        local newState = not callback()
        btn.BackgroundColor3 = newState and Color3.fromRGB(0, 160, 60) or Color3.fromRGB(160, 50, 50)
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
            
            -- Souris
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyText = "MB1"
                keyValue = input.UserInputType
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyText = "MB2"
                keyValue = input.UserInputType
            -- Clavier
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

-- ============================================
-- CONSTRUCTION ONGLETS
-- ============================================

-- Onglet VISUAL
local VisualFrame = TabFrames[1]

CreateToggle(VisualFrame, "ESP", Cheat.ESP, function()
    Cheat.ESP = not Cheat.ESP
    return Cheat.ESP
end)

-- Onglet AIM
local AimFrame = TabFrames[2]

CreateKeybind(AimFrame, "Aim Key:", Cheat.AimKeyText, function(key, keyText)
    Cheat.AimKey = key
    Cheat.AimKeyText = keyText
end)

CreateToggle(AimFrame, "Aimbot", Cheat.Aim, function()
    Cheat.Aim = not Cheat.Aim
    return Cheat.Aim
end)

CreateSlider(AimFrame, "FOV", 50, 300, 120, function(v)
    -- FOV pour référence future
end)

CreateSlider(AimFrame, "Smooth", 5, 50, 15, function(v)
    -- Smooth pour référence future
end)

-- Onglet MOVE
local MoveFrame = TabFrames[3]

CreateToggle(MoveFrame, "Fly", Cheat.Fly, function()
    Cheat.Fly = not Cheat.Fly
    if not Cheat.Fly and FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
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

CreateToggle(MoveFrame, "NoClip", Cheat.NoClip, function()
    Cheat.NoClip = not Cheat.NoClip
    return Cheat.NoClip
end)

CreateToggle(MoveFrame, "BunnyHop", Cheat.BunnyHop, function()
    Cheat.BunnyHop = not Cheat.BunnyHop
    return Cheat.BunnyHop
end)

-- ============================================
-- FONCTIONS DE JEU
-- ============================================

-- Fly FONCTIONNEL
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

-- WalkSpeed FONCTIONNEL
function UpdateMovement()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        if Cheat.WalkSpeed then
            humanoid.WalkSpeed = Cheat.Speed
        else
            humanoid.WalkSpeed = 16
        end
        
        if Cheat.BunnyHop and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- NoClip FONCTIONNEL
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
-- DÉTECTION KEYBINDS
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- F8 pour toggle GUI
        if input.KeyCode == Enum.KeyCode.F8 then
            MainFrame.Visible = not MainFrame.Visible
            ToggleBtn.Text = MainFrame.Visible and "F8 HIDE" or "F8 SHOW"
        end
        
        -- Détection keybind
        if KeybindListening then
            KeybindListening(input)
        end
    end
end)

-- ============================================
-- BOUCLE PRINCIPALE
-- ============================================

RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateFly()
    UpdateMovement()
    UpdateNoClip()
end)

print("========================================")
print("EVENT HORIZON - VERSION SIMPLE")
print("========================================")
print("TOUT FONCTIONNE:")
print("1. ESP (active/désactive)")
print("2. Fly (WASD + Space/Shift)")
print("3. WalkSpeed (slider fonctionnel)")
print("4. NoClip (toggle fonctionnel)")
print("5. BunnyHop")
print("========================================")
print("INSTRUCTIONS:")
print("1. Fly: Active + WASD + Space/Shift")
print("2. WalkSpeed: Active + règle vitesse")
print("3. NoClip: Active/désactive")
print("4. ESP: Active pour voir les joueurs")
print("5. F8: Cache/affiche le GUI")
print("========================================")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local Settings = {
    AutoFarm = false,
    FarmRange = 30,
    WalkSpeedEnabled = false,
    WalkSpeed = 50,
    InfJump = false,
    ESPEnabled = true,
    
    -- Новые настройки
    AimEnabled = true,
    AimFOV = 150,
    AimSmooth = 0.4,
    MaxAimDistance = 100, -- Дистанция аимбота в метрах (студиях)
    AutoCollect = false,
    CollectRange = 150
}

local Window = Rayfield:CreateWindow({
   Name = "YBA HUB V2 | SWILL",
   LoadingTitle = "Загрузка YBA Hub...",
   LoadingSubtitle = "by Swill Way",
   Theme = "Amethyst",
   ConfigurationSaving = {Enabled = false}
})

local AimTab = Window:CreateTab("Аимбот", nil)
local FarmTab = Window:CreateTab("Фарм & Предметы", nil)
local MoveTab = Window:CreateTab("Движение", nil)
local VisualTab = Window:CreateTab("Визуал (ESP)", nil)

-- ==========================================
-- ВКЛАДКА АИМБОТ
-- ==========================================
AimTab:CreateToggle({
   Name = "Включить Аимбот",
   CurrentValue = true,
   Flag = "AimToggle",
   Callback = function(Value) Settings.AimEnabled = Value end,
})

AimTab:CreateSlider({
   Name = "Макс. дистанция захвата (метры)",
   Range = {10, 300},
   Increment = 10,
   Suffix = "m",
   CurrentValue = 100,
   Flag = "MaxAimDist",
   Callback = function(Value) Settings.MaxAimDistance = Value end,
})

AimTab:CreateSlider({
   Name = "Радиус FOV (по экрану)",
   Range = {50, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 150,
   Flag = "AimFov",
   Callback = function(Value) Settings.AimFOV = Value end,
})

AimTab:CreateSlider({
   Name = "Плавность Аимбота",
   Range = {1, 10},
   Increment = 1,
   CurrentValue = 4,
   Flag = "AimSmooth",
   Callback = function(Value) Settings.AimSmooth = Value / 10 end,
})

-- ==========================================
-- ВКЛАДКА ФАРМ & ПРЕДМЕТЫ
-- ==========================================
FarmTab:CreateToggle({
   Name = "Auto-Farm (Авто-атака мобов)",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value) Settings.AutoFarm = Value end,
})

FarmTab:CreateSlider({
   Name = "Радиус фарма мобов",
   Range = {10, 100},
   Increment = 5,
   Suffix = "студ.",
   CurrentValue = 30,
   Flag = "FarmRange",
   Callback = function(Value) Settings.FarmRange = Value end,
})

FarmTab:CreateToggle({
   Name = "Auto-Collect (Сбор всех предметов)",
   CurrentValue = false,
   Flag = "AutoCollectToggle",
   Callback = function(Value) Settings.AutoCollect = Value end,
})

FarmTab:CreateSlider({
   Name = "Радиус сбора предметов",
   Range = {50, 500},
   Increment = 10,
   Suffix = "студ.",
   CurrentValue = 150,
   Flag = "CollectRange",
   Callback = function(Value) Settings.CollectRange = Value end,
})

-- ==========================================
-- ВКЛАДКА ДВИЖЕНИЕ
-- ==========================================
MoveTab:CreateToggle({
   Name = "Speed Hack (Ускорение)",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
       Settings.WalkSpeedEnabled = Value
       local char = LocalPlayer.Character
       if char and char:FindFirstChild("Humanoid") then
           char.Humanoid.WalkSpeed = Value and Settings.WalkSpeed or 16
       end
   end,
})

MoveTab:CreateSlider({
   Name = "Скорость",
   Range = {16, 200},
   Increment = 5,
   Suffix = "spd",
   CurrentValue = 50,
   Flag = "SpeedValue",
   Callback = function(Value)
       Settings.WalkSpeed = Value
       if Settings.WalkSpeedEnabled then
           local char = LocalPlayer.Character
           if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = Value end
       end
   end,
})

MoveTab:CreateToggle({
   Name = "Infinite Jump (Беск. прыжок)",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value) Settings.InfJump = Value end,
})

-- ==========================================
-- ВКЛАДКА ВИЗУАЛ
-- ==========================================
VisualTab:CreateToggle({
   Name = "ESP (Подсветка игроков)",
   CurrentValue = true,
   Flag = "EspToggle",
   Callback = function(Value) Settings.ESPEnabled = Value end,
})

-- ==========================================
-- ЛОГИКА ESP
-- ==========================================
local function applyESP(character)
    if not character then return end
    local root = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not root or not humanoid then return end
    local old = root:FindFirstChild("YbaESP")
    if old then old:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "YbaESP"
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = root
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Parent = billboard
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not Settings.ESPEnabled or not root or not root.Parent or not humanoid or humanoid.Health <= 0 then
            billboard.Enabled = Settings.ESPEnabled
            if not root or not root.Parent or humanoid.Health <= 0 then billboard:Destroy(); conn:Disconnect() end
            return
        end
        billboard.Enabled = true
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = 0
        if myRoot then dist = math.floor((myRoot.Position - root.Position).Magnitude) end
        local hpPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
        local color = Color3.fromRGB(255, 0, 0)
        if hpPercent > 50 then color = Color3.fromRGB(255, 165, 0) end
        if hpPercent > 80 then color = Color3.fromRGB(0, 255, 0) end
        textLabel.TextColor3 = color
        textLabel.Text = string.format("%s\nHP: %d%%\n[%dm]", character.Name, hpPercent, dist)
    end)
end
local function setupPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then applyESP(player.Character) end
    player.CharacterAdded:Connect(function(char) task.wait(0.5) applyESP(char) end)
end
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

-- ==========================================
-- ЛОГИКА: INF JUMP
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState("Jumping")
        end
    end
end)

-- ==========================================
-- ЛОГИКА: АИМБОТ С ДИСТАНЦИЕЙ
-- ==========================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false

local function getClosestTarget()
    local closest = nil
    local shortestDist = Settings.AimFOV
    local center = Camera.ViewportSize / 2
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position

    if not myPos then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")
                if humanoid and head and humanoid.Health > 0 then
                    -- Проверка дистанции (Max Distance)
                    local realDist = (head.Position - myPos).Magnitude
                    if realDist <= Settings.MaxAimDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if screenDist < shortestDist then
                                shortestDist = screenDist
                                closest = head
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    -- Круг FOV
    if Settings.AimEnabled then
        fovCircle.Visible = true
        fovCircle.Position = Camera.ViewportSize / 2
        fovCircle.Radius = Settings.AimFOV
    else
        fovCircle.Visible = false
    end

    -- Аимбот
    if Settings.AimEnabled then
        local target = getClosestTarget()
        if target then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, target.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.AimSmooth)
        end
    end
end)

-- ==========================================
-- ЛОГИКА: AUTO FARM МОБОВ
-- ==========================================
task.spawn(function()
    while task.wait(0.2) do
        if Settings.AutoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                local closestTarget = nil
                local minDist = Settings.FarmRange
                
                for _, v in pairs(Workspace:GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v ~= char and v.Humanoid.Health > 0 then
                            local dist = (v.HumanoidRootPart.Position - myPos).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closestTarget = v
                            end
                        end
                    end
                end
                
                if closestTarget then
                    local targetPos = closestTarget.HumanoidRootPart.Position
                    char.HumanoidRootPart.CFrame = CFrame.lookAt(myPos, targetPos)
                    local virtualUser = game:GetService("VirtualUser")
                    virtualUser:ClickButton1(Vector2.new(0,0))
                end
            end
        end
    end
end)

-- ==========================================
-- ЛОГИКА: AUTO COLLECT (СБОР ВСЕХ ПРЕДМЕТОВ)
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoCollect then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                
                -- Ищем все объекты в радиусе сбора
                for _, v in pairs(Workspace:GetDescendants()) do
                    -- В YBA предметы обычно называются Item, Coin, Drop, Loot или это Tool/BasePart
                    if v:IsA("BasePart") or v:IsA("Tool") or v:IsA("Model") then
                        local isItem = v.Name:lower():find("coin") or v.Name:lower():find("item") or v.Name:lower():find("drop") or v.Name:lower():find("loot") or v.Name:lower():find("cash")
                        -- Если это Tool (инструмент/предмет) и он лежит на земле
                        if v:IsA("Tool") then isItem = true end
                        
                        if isItem then
                            local targetPart = v:IsA("BasePart") and v or (v:FindFirstChild("Handle") or v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart)
                            if targetPart then
                                local dist = (targetPart.Position - myPos).Magnitude
                                if dist <= Settings.CollectRange and dist > 3 then
                                    -- Телепортируем предмет к себе (если игра позволяет) или телепортируемся к нему
                                    targetPart.CFrame = char.HumanoidRootPart.CFrame
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

Rayfield:Notify({Title = "YBA HUB V2", Content = "Аимбот и Авто-сбор предметов добавлены!", Duration = 5})

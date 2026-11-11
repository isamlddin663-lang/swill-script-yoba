local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Settings = {
    -- Аимбот
    AimEnabled = false, AimFOV = 150, AimSmooth = 0.4, MaxAimDistance = 100,
    LockTarget = true, CurrentTarget = nil,
    
    -- Фарм
    AutoFarm = false, FarmRange = 45,
    AutoItemFarm = false, ItemFarmRange = 500, TPBack = true,
    
    -- Движение
    WalkSpeedEnabled = false, WalkSpeed = 50, InfJump = false,
    
    -- Визуал & Блок
    ESPEnabled = true,
    ESPTextSize = 14,
    ESPDistance = 300,
    AutoBlock = false,
    LastHealth = 100
}

local Window = Rayfield:CreateWindow({
   Name = "YBA GOD MODE V8 | SWILL",
   LoadingTitle = "Загрузка...",
   LoadingSubtitle = "by Swill Way",
   Theme = "Amethyst",
   ConfigurationSaving = {Enabled = false}
})

local AimTab = Window:CreateTab("Аимбот", nil)
local FarmTab = Window:CreateTab("Фарм", nil)
local MoveTab = Window:CreateTab("Движение", nil)
local CombatTab = Window:CreateTab("Бой & Блок", nil)
local VisualTab = Window:CreateTab("Визуал & Оптимизация", nil)

-- ==========================================
-- АИМБОТ
-- ==========================================
AimTab:CreateToggle({Name = "Включить Аимбот", CurrentValue = false, Flag = "AimToggle", Callback = function(Value) Settings.AimEnabled = Value; if not Value then Settings.CurrentTarget = nil end end})
AimTab:CreateToggle({Name = "Lock Target (Залипание)", CurrentValue = true, Flag = "LockToggle", Callback = function(Value) Settings.LockTarget = Value end})
AimTab:CreateSlider({Name = "Макс. дистанция (метры)", Range = {10, 300}, Increment = 10, Suffix = "m", CurrentValue = 100, Flag = "MaxAimDist", Callback = function(Value) Settings.MaxAimDistance = Value end})
AimTab:CreateSlider({Name = "Радиус FOV (экран)", Range = {50, 500}, Increment = 10, Suffix = "px", CurrentValue = 150, Flag = "AimFov", Callback = function(Value) Settings.AimFOV = Value end})
AimTab:CreateSlider({Name = "Плавность", Range = {1, 10}, Increment = 1, CurrentValue = 4, Flag = "AimSmooth", Callback = function(Value) Settings.AimSmooth = Value / 10 end})

-- ==========================================
-- ФАРМ
-- ==========================================
FarmTab:CreateToggle({Name = "Auto-Farm Мобов", CurrentValue = false, Flag = "AutoFarm", Callback = function(Value) Settings.AutoFarm = Value end})
FarmTab:CreateSlider({Name = "Радиус мобов", Range = {10, 100}, Increment = 5, Suffix = "студ.", CurrentValue = 45, Flag = "FarmRange", Callback = function(Value) Settings.FarmRange = Value end})
FarmTab:CreateToggle({Name = "Auto-Item Farm (Умный)", CurrentValue = false, Flag = "AutoItemFarm", Callback = function(Value) Settings.AutoItemFarm = Value end})
FarmTab:CreateSlider({Name = "Радиус поиска", Range = {50, 2000}, Increment = 50, Suffix = "студ.", CurrentValue = 500, Flag = "ItemFarmRange", Callback = function(Value) Settings.ItemFarmRange = Value end})
FarmTab:CreateToggle({Name = "TP Back (Возврат)", CurrentValue = true, Flag = "TPBack", Callback = function(Value) Settings.TPBack = Value end})

-- ==========================================
-- БОЙ & БЛОК
-- ==========================================
CombatTab:CreateToggle({Name = "Auto-Block (Только по урону)", CurrentValue = false, Flag = "AutoBlockToggle", Callback = function(Value) Settings.AutoBlock = Value end})

-- ==========================================
-- ДВИЖЕНИЕ
-- ==========================================
MoveTab:CreateToggle({Name = "Speed Hack (Ускорение)", CurrentValue = false, Flag = "SpeedToggle", Callback = function(Value) Settings.WalkSpeedEnabled = Value; local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = Value and Settings.WalkSpeed or 16 end end})
MoveTab:CreateSlider({Name = "Скорость", Range = {16, 200}, Increment = 5, Suffix = "spd", CurrentValue = 50, Flag = "SpeedValue", Callback = function(Value) Settings.WalkSpeed = Value; if Settings.WalkSpeedEnabled then local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = Value end end end})
MoveTab:CreateToggle({Name = "Infinite Jump (Беск. прыжок)", CurrentValue = false, Flag = "InfJumpToggle", Callback = function(Value) Settings.InfJump = Value end})

-- ==========================================
-- ВИЗУАЛ & ОПТИМИЗАЦИЯ
-- ==========================================
VisualTab:CreateSlider({Name = "Размер текста ESP", Range = {8, 24}, Increment = 1, CurrentValue = 14, Flag = "ESPTextSize", Callback = function(Value) Settings.ESPTextSize = Value end})
VisualTab:CreateSlider({Name = "Дальность ESP (метры)", Range = {50, 1000}, Increment = 50, CurrentValue = 300, Flag = "ESPDistance", Callback = function(Value) Settings.ESPDistance = Value end})

VisualTab:CreateButton({
   Name = "ULTRA FPS BOOST (Без скинов + Отключение света)",
   Callback = function()
       pcall(function()
           settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
           settings().Rendering.AntiAliasingQuality = Enum.AntiAliasingQuality.QualityLevel1
       end)
       Lighting.GlobalShadows = false
       Lighting.FogEnd = 9e9
       for _, v in pairs(Lighting:GetDescendants()) do
           if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
       end
       for _, v in pairs(Workspace:GetDescendants()) do
           if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v:Destroy() end
           if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
           if v:IsA("BasePart") and v.Material ~= Enum.Material.Plastic and v.Material ~= Enum.Material.SmoothPlastic and v.Material ~= Enum.Material.Neon then v.Material = Enum.Material.SmoothPlastic end
           if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v:Destroy() end
       end
       local function stripCharacter(char)
           if char then for _, v in pairs(char:GetDescendants()) do if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("Highlight") then v:Destroy() end end end
       end
       for _, plr in ipairs(Players:GetPlayers()) do if plr.Character then stripCharacter(plr.Character) end end
       Players.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Connect(function(char) task.wait(0.5) stripCharacter(char) end) end)
       Rayfield:Notify({Title = "ULTRA BOOST", Content = "Свет и скины отключены!", Duration = 5})
   end,
})
VisualTab:CreateToggle({Name = "ESP (Подсветка игроков)", CurrentValue = true, Flag = "EspToggle", Callback = function(Value) Settings.ESPEnabled = Value end})

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
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = root
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = false
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = Settings.ESPTextSize
    textLabel.Parent = billboard
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not Settings.ESPEnabled or not root or not root.Parent or not humanoid or humanoid.Health <= 0 then
            billboard.Enabled = Settings.ESPEnabled
            if not root or not root.Parent or humanoid.Health <= 0 then billboard:Destroy(); conn:Disconnect() end
            return
        end
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = 0
        if myRoot then dist = math.floor((myRoot.Position - root.Position).Magnitude) end
        if dist <= Settings.ESPDistance then
            billboard.Enabled = true
            textLabel.TextSize = Settings.ESPTextSize
            local hpPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            local color = Color3.fromRGB(255, 0, 0)
            if hpPercent > 50 then color = Color3.fromRGB(255, 165, 0) end
            if hpPercent > 80 then color = Color3.fromRGB(0, 255, 0) end
            textLabel.TextColor3 = color
            textLabel.Text = string.format("%s\nHP: %d%%\n[%dm]", character.Name, hpPercent, dist)
        else
            billboard.Enabled = false
        end
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
-- ЛОГИКА INF JUMP & АИМБОТ
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState("Jumping") end
    end
end)

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1; fovCircle.Color = Color3.fromRGB(255, 255, 255); fovCircle.Filled = false; fovCircle.Visible = false

local function isTargetValid(targetChar)
    if not targetChar or not targetChar.Parent then return false end
    local hum = targetChar:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not myPos then return false end
    local dist = (targetChar.Head.Position - myPos).Magnitude
    return dist <= Settings.MaxAimDistance
end

local function findBestTarget()
    local closest = nil; local shortestDist = Settings.AimFOV; local center = Camera.ViewportSize / 2
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not myPos then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild("Head") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local realDist = (char.Head.Position - myPos).Magnitude
                    if realDist <= Settings.MaxAimDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                        if onScreen then
                            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if screenDist < shortestDist then shortestDist = screenDist; closest = char end
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Settings.AimEnabled then
        fovCircle.Visible = true; fovCircle.Position = Camera.ViewportSize / 2; fovCircle.Radius = Settings.AimFOV
        if Settings.LockTarget then
            if Settings.CurrentTarget and isTargetValid(Settings.CurrentTarget) then else Settings.CurrentTarget = findBestTarget() end
        else Settings.CurrentTarget = findBestTarget() end
        if Settings.CurrentTarget and Settings.CurrentTarget:FindFirstChild("Head") then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, Settings.CurrentTarget.Head.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.AimSmooth)
        end
    else fovCircle.Visible = false; Settings.CurrentTarget = nil end
end)

-- ==========================================
-- AUTO-FARM МОБОВ
-- ==========================================
task.spawn(function()
    while task.wait(0.2) do
        if Settings.AutoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position; local closestTarget = nil; local minDist = Settings.FarmRange
                for _, v in pairs(Workspace:GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v ~= char and v.Humanoid.Health > 0 then
                            local dist = (v.HumanoidRootPart.Position - myPos).Magnitude
                            if dist < minDist then minDist = dist; closestTarget = v end
                        end
                    end
                end
                if closestTarget then
                    char.HumanoidRootPart.CFrame = CFrame.lookAt(myPos, closestTarget.HumanoidRootPart.Position)
                    VirtualUser:ClickButton1(Vector2.new(0,0))
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO-ITEM FARM (УМНЫЙ ПОДБОР)
-- ==========================================
local ITEM_NAMES = {
    ["Mysterious Arrow"] = true, ["Rokakaka"] = true, ["Pure Rokakaka"] = true,
    ["Gold Coin"] = true, ["Ancient Scroll"] = true, ["Rib Cage of The Saint's Corpse"] = true,
    ["Diamond"] = true, ["Stone Mask"] = true
}

task.spawn(function()
    while task.wait(1) do
        if Settings.AutoItemFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local originalCFrame = char.HumanoidRootPart.CFrame
                local foundItem = nil
                local foundName = ""

                local itemFolder = Workspace:FindFirstChild("Item_Spawns")
                if itemFolder then
                    local itemsFolder = itemFolder:FindFirstChild("Items")
                    if itemsFolder then
                        for _, v in pairs(itemsFolder:GetDescendants()) do
                            if v:IsA("MeshPart") or v:IsA("Model") then
                                local objName = v.Name
                                if ITEM_NAMES[objName] then foundItem = v; foundName = objName; break end
                            end
                        end
                    end
                end

                if foundItem then
                    char.HumanoidRootPart.CFrame = foundItem.CFrame
                    task.wait(0.3)
                    local prompt = foundItem:FindFirstChildOfClass("ProximityPrompt") or foundItem.Parent:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) else
                        VirtualInputManager:SendKeyEvent(true, "E", false, game); task.wait(0.2); VirtualInputManager:SendKeyEvent(false, "E", false, game)
                    end
                    task.wait(0.4)
                    if Settings.TPBack then char.HumanoidRootPart.CFrame = originalCFrame end
                    Rayfield:Notify({Title = "Найден предмет!", Content = foundName, Duration = 3})
                end
            end
        end
    end
end)

-- ==========================================
-- ЛОГИКА AUTO-BLOCK (ТОЛЬКО ПО УРОНУ)
-- ==========================================
local blockHeld = false
local blockTimer = 0

task.spawn(function()
    while task.wait(0.05) do -- Проверяем каждые 0.05 сек для мгновенной реакции
        if Settings.AutoBlock then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                
                -- Если HP стало меньше, чем было (получили урон)
                if Settings.LastHealth and hum.Health < Settings.LastHealth then
                    -- Зажимаем блок
                    if not blockHeld then
                        VirtualInputManager:SendKeyEvent(true, "F", false, game)
                        blockHeld = true
                    end
                    -- Обновляем таймер (держать блок 1 секунду после последнего урона)
                    blockTimer = 1
                end
                
                Settings.LastHealth = hum.Health
                
                -- Если блок зажат, отсчитываем время
                if blockHeld then
                    if blockTimer > 0 then
                        blockTimer = blockTimer - 0.05
                    else
                        -- Время вышло, отпускаем
                        VirtualInputManager:SendKeyEvent(false, "F", false, game)
                        blockHeld = false
                    end
                end
            end
        else
            -- Если функцию выключили, отпускаем кнопку
            if blockHeld then
                VirtualInputManager:SendKeyEvent(false, "F", false, game)
                blockHeld = false
            end
        end
    end
end)

Rayfield:Notify({Title = "YBA GOD MODE V8", Content = "Реактивный блок готов! Бьем и блокируем!", Duration = 5})

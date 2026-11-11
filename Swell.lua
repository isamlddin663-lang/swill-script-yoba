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
    
    -- Фарм мобов
    AutoFarm = false, FarmRange = 30,
    
    -- Фарм предметов
    AutoItemFarm = false, ItemFarmRange = 500, TPBack = true,
    
    -- Движение
    WalkSpeedEnabled = false, WalkSpeed = 50, InfJump = false,
    
    -- Визуал
    ESPEnabled = true
}

local Window = Rayfield:CreateWindow({
   Name = "YBA GOD MODE | SWILL",
   LoadingTitle = "Загрузка...",
   LoadingSubtitle = "by Swill Way",
   Theme = "Amethyst",
   ConfigurationSaving = {Enabled = false}
})

local AimTab = Window:CreateTab("Аимбот", nil)
local FarmTab = Window:CreateTab("Фарм", nil)
local MoveTab = Window:CreateTab("Движение", nil)
local VisualTab = Window:CreateTab("Визуал & Оптимизация", nil)

-- ==========================================
-- ВКЛАДКА АИМБОТ
-- ==========================================
AimTab:CreateToggle({Name = "Включить Аимбот", CurrentValue = false, Flag = "AimToggle", Callback = function(Value) Settings.AimEnabled = Value; if not Value then Settings.CurrentTarget = nil end end})
AimTab:CreateToggle({Name = "Lock Target (Залипание)", CurrentValue = true, Flag = "LockToggle", Callback = function(Value) Settings.LockTarget = Value end})
AimTab:CreateSlider({Name = "Макс. дистанция (метры)", Range = {10, 300}, Increment = 10, Suffix = "m", CurrentValue = 100, Flag = "MaxAimDist", Callback = function(Value) Settings.MaxAimDistance = Value end})
AimTab:CreateSlider({Name = "Радиус FOV (экран)", Range = {50, 500}, Increment = 10, Suffix = "px", CurrentValue = 150, Flag = "AimFov", Callback = function(Value) Settings.AimFOV = Value end})
AimTab:CreateSlider({Name = "Плавность", Range = {1, 10}, Increment = 1, CurrentValue = 4, Flag = "AimSmooth", Callback = function(Value) Settings.AimSmooth = Value / 10 end})

-- ==========================================
-- ВКЛАДКА ФАРМ
-- ==========================================
FarmTab:CreateToggle({Name = "Auto-Farm Мобов", CurrentValue = false, Flag = "AutoFarm", Callback = function(Value) Settings.AutoFarm = Value end})
FarmTab:CreateSlider({Name = "Радиус мобов", Range = {10, 100}, Increment = 5, Suffix = "студ.", CurrentValue = 30, Flag = "FarmRange", Callback = function(Value) Settings.FarmRange = Value end})

FarmTab:CreateToggle({Name = "Auto-Item Farm (Стрелы/Рокака)", CurrentValue = false, Flag = "AutoItemFarm", Callback = function(Value) Settings.AutoItemFarm = Value end})
FarmTab:CreateSlider({Name = "Радиус поиска предметов", Range = {50, 1000}, Increment = 50, Suffix = "студ.", CurrentValue = 500, Flag = "ItemFarmRange", Callback = function(Value) Settings.ItemFarmRange = Value end})
FarmTab:CreateToggle({Name = "TP Back (Возврат на место)", CurrentValue = true, Flag = "TPBack", Callback = function(Value) Settings.TPBack = Value end})

-- ==========================================
-- ВКЛАДКА ДВИЖЕНИЕ
-- ==========================================
MoveTab:CreateToggle({Name = "Speed Hack (Ускорение)", CurrentValue = false, Flag = "SpeedToggle", Callback = function(Value) Settings.WalkSpeedEnabled = Value; local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = Value and Settings.WalkSpeed or 16 end end})
MoveTab:CreateSlider({Name = "Скорость", Range = {16, 200}, Increment = 5, Suffix = "spd", CurrentValue = 50, Flag = "SpeedValue", Callback = function(Value) Settings.WalkSpeed = Value; if Settings.WalkSpeedEnabled then local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = Value end end end})
MoveTab:CreateToggle({Name = "Infinite Jump (Беск. прыжок)", CurrentValue = false, Flag = "InfJumpToggle", Callback = function(Value) Settings.InfJump = Value end})

-- ==========================================
-- ВКЛАДКА ВИЗУАЛ & ОПТИМИЗАЦИЯ
-- ==========================================
VisualTab:CreateButton({
   Name = "FPS BOOST (Снести текстуры)",
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
       end
       Rayfield:Notify({Title = "FPS BOOST", Content = "Графика снижена!", Duration = 3})
   end,
})
VisualTab:CreateToggle({Name = "ESP (Подсветка игроков)", CurrentValue = true, Flag = "EspToggle", Callback = function(Value) Settings.ESPEnabled = Value end})

-- ==========================================
-- ЛОГИКА ESP (ТОЛЬКО БЛИЗКИЕ ИГРОКИ)
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
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = 0
        if myRoot then dist = math.floor((myRoot.Position - root.Position).Magnitude) end
        
        -- Показываем только тех, кто в радиусе 300 метров
        if dist <= 300 then
            billboard.Enabled = true
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
-- ЛОГИКА INF JUMP
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState("Jumping") end
    end
end)

-- ==========================================
-- ЛОГИКА АИМБОТА (С ЗАЛИПАНИЕМ)
-- ==========================================
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
        if Settings.LockTarget then
            if Settings.CurrentTarget and isTargetValid(Settings.CurrentTarget) then
                -- Держим текущую
            else
                Settings.CurrentTarget = findBestTarget()
            end
        else
            Settings.CurrentTarget = findBestTarget()
        end

        if Settings.CurrentTarget and Settings.CurrentTarget:FindFirstChild("Head") then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, Settings.CurrentTarget.Head.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.AimSmooth)
        end
    else
        Settings.CurrentTarget = nil
    end
end)

-- ==========================================
-- ЛОГИКА AUTO-FARM МОБОВ (БЕЗ ВЫЛЕТОВ)
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
-- ЛОГИКА AUTO-ITEM FARM (ТЕЛЕПОРТ + КНОПКА E)
-- ==========================================
task.spawn(function()
    while task.wait(1.5) do
        if Settings.AutoItemFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local originalCFrame = char.HumanoidRootPart.CFrame
                local myPos = originalCFrame.Position
                local foundItem = nil

                for _, v in pairs(Workspace:GetDescendants()) do
                    local itemName = v.Name:lower()
                    if (itemName:find("arrow") or itemName:find("rokakaka") or itemName:find("item") or itemName:find("drop")) and not v:IsDescendantOf(char) then
                        local targetPart = v:IsA("BasePart") and v or v:FindFirstChild("Handle") or v.PrimaryPart
                        if targetPart then
                            local dist = (targetPart.Position - myPos).Magnitude
                            if dist <= Settings.ItemFarmRange then
                                foundItem = targetPart
                                break
                            end
                        end
                    end
                end

                if foundItem then
                    char.HumanoidRootPart.CFrame = foundItem.CFrame
                    task.wait(0.3)
                    VirtualInputManager:SendKeyEvent(true, "E", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "E", false, game)
                    if Settings.TPBack then
                        task.wait(0.3)
                        char.HumanoidRootPart.CFrame = originalCFrame
                    end
                end
            end
        end
    end
end)

Rayfield:Notify({Title = "YBA GOD MODE", Content = "Готово к работе!", Duration = 5})

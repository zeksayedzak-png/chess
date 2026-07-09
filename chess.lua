local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local stealing = false
local targetBuild = nil

-- Функция получения всех частей постройки
local function getAllParts(model)
    local parts = {}
    local function recursiveSearch(instance)
        if instance:IsA("BasePart") then
            table.insert(parts, instance)
        end
        for _, child in ipairs(instance:GetChildren()) do
            recursiveSearch(child)
        end
    end
    recursiveSearch(model)
    return parts
end

-- Функция клонирования постройки игрока
local function stealBuild(playerName)
    local targetPlayer = nil
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name == playerName then
            targetPlayer = plr
            break
        end
    end
    if not targetPlayer then
        warn("[PC Stealer] Игрок не найден")
        return false
    end
    
    local character = targetPlayer.Character
    if not character then return false end
    
    local buildModel = nil
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") == nil then
            buildModel = child
            break
        end
    end
    if not buildModel then return false end
    
    local parts = getAllParts(buildModel)
    local clones = {}
    for _, part in ipairs(parts) do
        local clone = part:Clone()
        clone.CFrame = part.CFrame + Vector3.new(0, 10, 0)
        clone.Parent = workspace
        table.insert(clones, clone)
    end
    
    -- Перепривязка механизмов
    for _, clone in ipairs(clones) do
        for _, constraint in ipairs(clone:GetChildren()) do
            if constraint:IsA("JointInstance") then
                local origPart0 = constraint.Part0
                local origPart1 = constraint.Part1
                if origPart0 and origPart1 then
                    local newPart0 = nil
                    local newPart1 = nil
                    for _, c in ipairs(clones) do
                        if c.Name == origPart0.Name and c.Position == origPart0.Position then
                            newPart0 = c
                        end
                        if c.Name == origPart1.Name and c.Position == origPart1.Position then
                            newPart1 = c
                        end
                    end
                    if newPart0 and newPart1 then
                        constraint.Part0 = newPart0
                        constraint.Part1 = newPart1
                    end
                end
            end
        end
    end
    
    print("[PC Stealer] Постройка украдена и размещена в workspace")
    return true
end

-- GUI интерфейс для выбора цели
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 1
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Plane Crazy Build Stealer"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.BackgroundTransparency = 1
title.Parent = mainFrame

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -10, 1, -80)
playerList.Position = UDim2.new(0, 5, 0, 35)
playerList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
playerList.Parent = mainFrame

local stealButton = Instance.new("TextButton")
stealButton.Size = UDim2.new(1, -10, 0, 30)
stealButton.Position = UDim2.new(0, 5, 1, -35)
stealButton.Text = "STEAL"
stealButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stealButton.Parent = mainFrame

local function refreshPlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local yOffset = 0
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 25)
            btn.Position = UDim2.new(0, 2, 0, yOffset)
            btn.Text = plr.Name
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Parent = playerList
            btn.MouseButton1Click:Connect(function()
                targetBuild = plr.Name
                for _, b in ipairs(playerList:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            end)
            yOffset = yOffset + 28
        end
    end
    playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

stealButton.MouseButton1Click:Connect(function()
    if targetBuild then
        stealBuild(targetBuild)
    else
        warn("[PC Stealer] Выберите цель")
    end
end)

refreshPlayerList()
game.Players.PlayerAdded:Connect(function() refreshPlayerList() end)
game.Players.PlayerRemoving:Connect(function() refreshPlayerList() end)
print("[PC Stealer] Загружен. Выберите игрока и нажмите STEAL.")

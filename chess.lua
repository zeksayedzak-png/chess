-- Plane Crazy (Roblox) Build Stealer Script v2 - Working Steal Function
-- Исполнитель: Synapse X / Krnl / ScriptWare (уровень 8+)

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local selectedTarget = nil

-- Функция поиска активной постройки игрока (модель, которую он строит/держит)
local function findPlayerBuild(plr)
    local character = plr.Character
    if not character then return nil end
    
    -- Plane Crazy хранит постройку либо в руках (Tool), либо как дочернюю модель
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") == nil then
            -- Проверка: есть ли части с массой > 0
            local hasParts = false
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("BasePart") then
                    hasParts = true
                    break
                end
            end
            if hasParts then return child end
        end
    end
    
    -- Альтернатива: ищем прикреплённые части через Welds
    local attachedParts = {}
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChild("WeldConstraint") then
            table.insert(attachedParts, part)
        end
    end
    if #attachedParts > 0 then
        local fakeModel = Instance.new("Model")
        fakeModel.Name = "StolenBuild"
        for _, p in ipairs(attachedParts) do
            p.Parent = fakeModel
        end
        return fakeModel
    end
    
    return nil
end

-- Полное копирование постройки с сохранением соединений
local function deepCopyBuild(originalModel)
    if not originalModel then return nil end
    
    local partMap = {}
    local newModel = Instance.new("Model")
    newModel.Name = "CopiedBuild_" .. os.time()
    newModel.Parent = workspace
    
    -- Копируем все части
    local function clonePart(part)
        local clone = part:Clone()
        clone.CFrame = part.CFrame + Vector3.new(0, 5, 0)
        clone.Parent = newModel
        partMap[part] = clone
        return clone
    end
    
    for _, part in ipairs(originalModel:GetDescendants()) do
        if part:IsA("BasePart") then
            clonePart(part)
        end
    end
    
    -- Восстанавливаем соединения (Weld, WeldConstraint, HingeConstraint и т.д.)
    for _, part in ipairs(originalModel:GetDescendants()) do
        if part:IsA("BasePart") and partMap[part] then
            local clonePart = partMap[part]
            for _, constraint in ipairs(part:GetChildren()) do
                if constraint:IsA("JointInstance") or constraint:IsA("Constraint") then
                    local constraintClone = constraint:Clone()
                    constraintClone.Parent = clonePart
                    
                    -- Переназначаем Part0/Part1
                    if constraintClone:IsA("Weld") or constraintClone:IsA("Snap") or constraintClone:IsA("WeldConstraint") then
                        local origPart0 = constraint.Part0
                        local origPart1 = constraint.Part1
                        if origPart0 and partMap[origPart0] then
                            constraintClone.Part0 = partMap[origPart0]
                        end
                        if origPart1 and partMap[origPart1] then
                            constraintClone.Part1 = partMap[origPart1]
                        end
                    elseif constraintClone:IsA("HingeConstraint") then
                        local origAttach0 = constraint.Attachment0
                        local origAttach1 = constraint.Attachment1
                        if origAttach0 and origAttach0.Parent and partMap[origAttach0.Parent] then
                            local newAttach = Instance.new("Attachment")
                            newAttach.CFrame = origAttach0.CFrame
                            newAttach.Parent = partMap[origAttach0.Parent]
                            constraintClone.Attachment0 = newAttach
                        end
                        if origAttach1 and origAttach1.Parent and partMap[origAttach1.Parent] then
                            local newAttach = Instance.new("Attachment")
                            newAttach.CFrame = origAttach1.CFrame
                            newAttach.Parent = partMap[origAttach1.Parent]
                            constraintClone.Attachment1 = newAttach
                        end
                    end
                end
            end
        end
    end
    
    return newModel
end

-- Основная функция кражи
local function stealFromPlayer(targetPlayerName)
    local target = nil
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name:lower() == targetPlayerName:lower() then
            target = plr
            break
        end
    end
    if not target then
        warn("[Stealer] Игрок не найден: " .. targetPlayerName)
        return false
    end
    
    local build = findPlayerBuild(target)
    if not build then
        warn("[Stealer] У игрока " .. target.Name .. " нет активной постройки")
        return false
    end
    
    local stolen = deepCopyBuild(build)
    if stolen and stolen:FindFirstChildWhichIsA("BasePart") then
        print("[Stealer] Постройка игрока " .. target.Name .. " украдена! Копия в workspace")
        -- Выделяем копию рамкой для наглядности
        for _, part in ipairs(stolen:GetDescendants()) do
            if part:IsA("BasePart") then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.Parent = part
                game.Debris:AddItem(highlight, 3)
            end
        end
        return true
    else
        warn("[Stealer] Ошибка копирования")
        return false
    end
end

-- GUI для выбора жертвы
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 240)
frame.Position = UDim2.new(0.5, -160, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "PLANE CRAZY BUILD STEALER"
title.TextColor3 = Color3.fromRGB(255, 100, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -10, 1, -95)
list.Position = UDim2.new(0, 5, 0, 40)
list.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
list.BorderSizePixel = 0
list.Parent = frame

local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(1, -10, 0, 35)
stealBtn.Position = UDim2.new(0, 5, 1, -40)
stealBtn.Text = "УКРАСТЬ ПОСТРОЙКУ"
stealBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.Font = Enum.Font.GothamBold
stealBtn.Parent = frame

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 60, 0, 25)
refreshBtn.Position = UDim2.new(1, -65, 0, 5)
refreshBtn.Text = "Обн."
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
refreshBtn.Parent = frame

local function updatePlayerList()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local y = 0
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.Text = plr.Name
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = list
            btn.MouseButton1Click:Connect(function()
                selectedTarget = plr.Name
                for _, b in ipairs(list:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            end)
            y = y + 35
        end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

stealBtn.MouseButton1Click:Connect(function()
    if selectedTarget then
        stealFromPlayer(selectedTarget)
    else
        warn("[Stealer] Сначала выберите игрока из списка")
    end
end)

refreshBtn.MouseButton1Click:Connect(updatePlayerList)
updatePlayerList()
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

print("[Stealer] Скрипт загружен. Выберите цель из списка и нажмите кнопку кражи.")

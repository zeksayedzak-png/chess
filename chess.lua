-- MozerHub Chess V5 (Professional & Mobile Optimized)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local LeftSidebar = Instance.new("Frame")
local BoardArea = Instance.new("Frame")
local MinimizedFrame = Instance.new("TextButton")

-- Game State
local Board = {}
local Squares = {}
local SelectedSquare = nil
local PlayerColor = "White"
local Turn = "White"
local GameActive = false
local WTime, BTime = 600, 600

-- GUI Config
ScreenGui.Name = "MozerChessV5"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Size = UDim2.new(0, 480, 0, 320) -- حجم أصغر ومناسب
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Sidebar
LeftSidebar.Parent = MainFrame
LeftSidebar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
LeftSidebar.Size = UDim2.new(0, 130, 1, 0)
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", LeftSidebar)
Title.Text = "CHESS PRO"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.FredokaOne
Title.BackgroundTransparency = 1

-- Board Setup (Green & Beige)
BoardArea.Parent = MainFrame
BoardArea.Position = UDim2.new(0, 140, 0, 10)
BoardArea.Size = UDim2.new(0, 300, 0, 300)
BoardArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local Grid = Instance.new("UIGridLayout", BoardArea)
Grid.CellSize = UDim2.new(0, 37, 0, 37)
Grid.Spacing = UDim2.new(0, 0, 0, 0)

-- Piece Icons
local Icons = {
    White = {P="♙", R="♖", N="♘", B="♗", Q="♕", K="♔"},
    Black = {P="♟", R="♜", N="♞", B="♝", Q="♛", K="♚"}
}

-- Create Grid
for r = 1, 8 do
    Squares[r] = {}
    for c = 1, 8 do
        local sq = Instance.new("TextButton", BoardArea)
        sq.Text = ""
        sq.TextSize = 25
        sq.Font = Enum.Font.GothamBold
        sq.AutoButtonColor = false
        sq.BackgroundColor3 = (r + c) % 2 == 0 and Color3.fromRGB(238, 238, 210) or Color3.fromRGB(118, 150, 86)
        Squares[r][c] = sq
    end
end

-- Logic: Get Moves
local function GetPiece(r, c) return Board[r] and Board[r][c] end

local function GetValidMoves(r, c)
    local p = GetPiece(r, c)
    if not p then return {} end
    local moves = {}
    local color = p.Color
    local type = p.Type

    local function add(nr, nc)
        if nr<1 or nr>8 or nc<1 or nc>8 then return false end
        local target = GetPiece(nr, nc)
        if not target then table.insert(moves, {nr, nc}) return true end
        if target.Color ~= color then table.insert(moves, {nr, nc}) end
        return false
    end

    if type == "P" then
        local d = (color == "White") and -1 or 1
        if not GetPiece(r+d, c) then 
            table.insert(moves, {r+d, c})
            if ((color=="White" and r==7) or (color=="Black" and r==2)) and not GetPiece(r+2*d, c) then table.insert(moves, {r+2*d, c}) end
        end
        for _, dc in pairs({-1, 1}) do
            local t = GetPiece(r+d, c+dc)
            if t and t.Color ~= color then table.insert(moves, {r+d, c+dc}) end
        end
    elseif type == "N" then
        local m = {{2,1},{2,-1},{-2,1},{-2,-1},{1,2},{1,-2},{-1,2},{-1,-2}}
        for _, v in pairs(m) do add(r+v[1], c+v[2]) end
    elseif type == "R" or type == "B" or type == "Q" or type == "K" then
        local dirs = {}
        if type=="R" or type=="Q" then table.insert(dirs,{1,0}); table.insert(dirs,{-1,0}); table.insert(dirs,{0,1}); table.insert(dirs,{0,-1}) end
        if type=="B" or type=="Q" then table.insert(dirs,{1,1}); table.insert(dirs,{1,-1}); table.insert(dirs,{-1,1}); table.insert(dirs,{-1,-1}) end
        if type=="K" then dirs={{1,0},{-1,0},{0,1},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1}} end
        for _, dr in pairs(dirs) do
            for i=1,8 do
                if not add(r+dr[1]*i, c+dr[2]*i) or type=="K" then break end
            end
        end
    end
    return moves
end

local function UpdateUI()
    for r=1,8 do for c=1,8 do
        local p = Board[r][c]
        Squares[r][c].Text = p and Icons[p.Color][p.Type] or ""
        Squares[r][c].TextColor3 = (p and p.Color=="White") and Color3.new(1,1,1) or Color3.new(0,0,0)
        Squares[r][c].BackgroundColor3 = (r+c)%2==0 and Color3.fromRGB(238, 238, 210) or Color3.fromRGB(118, 150, 86)
    end end
end

-- Smart AI
local function AIMove()
    if not GameActive or Turn == PlayerColor then return end
    task.wait(0.8)
    local aiColor = (PlayerColor == "White") and "Black" or "White"
    local moves = {}
    for r=1,8 do for c=1,8 do
        local p = Board[r][c]
        if p and p.Color == aiColor then
            for _, m in pairs(GetValidMoves(r, c)) do table.insert(moves, {f={r,c}, t=m}) end
        end
    end end
    if #moves > 0 then
        local move = moves[math.random(#moves)]
        Board[move.t[1]][move.t[2]] = Board[move.f[1]][move.f[2]]
        Board[move.f[1]][move.f[2]] = nil
        Turn = PlayerColor
        UpdateUI()
    end
end

-- Interactions
for r=1,8 do for c=1,8 do
    Squares[r][c].MouseButton1Click:Connect(function()
        if not GameActive or Turn ~= PlayerColor then return end
        if SelectedSquare then
            local valid = false
            for _, m in pairs(GetValidMoves(SelectedSquare.r, SelectedSquare.c)) do
                if m[1] == r and m[2] == c then valid = true break end
            end
            if valid then
                Board[r][c] = Board[SelectedSquare.r][SelectedSquare.c]
                Board[SelectedSquare.r][SelectedSquare.c] = nil
                Turn = (PlayerColor == "White") and "Black" or "White"
                SelectedSquare = nil
                UpdateUI()
                AIMove()
            else
                SelectedSquare = nil
                UpdateUI()
            end
        else
            local p = Board[r][c]
            if p and p.Color == PlayerColor then
                SelectedSquare = {r=r, c=c}
                for _, m in pairs(GetValidMoves(r, c)) do
                    Squares[m[1]][m[2]].BackgroundColor3 = Color3.fromRGB(247, 247, 105)
                end
            end
        end
    end)
end end

-- Start/Reset Game
local function StartGame(color)
    PlayerColor = color
    Turn = "White"
    GameActive = true
    Board = {}
    for r=1,8 do Board[r] = {} end
    local l = {"R","N","B","Q","K","B","N","R"}
    for i=1,8 do
        Board[1][i]={Type=l[i],Color="Black"}; Board[2][i]={Type="P",Color="Black"}
        Board[7][i]={Type="P",Color="White"}; Board[8][i]={Type=l[i],Color="White"}
    end
    UpdateUI()
    if PlayerColor == "Black" then AIMove() end
end

-- Sidebar Buttons
local function CreateBtn(text, pos, color, func)
    local btn = Instance.new("TextButton", LeftSidebar)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(func)
end

CreateBtn("العب بالأبيض ⚪", UDim2.new(0, 10, 0, 60), Color3.fromRGB(80, 80, 80), function() StartGame("White") end)
CreateBtn("العب بالأسود ⚫", UDim2.new(0, 10, 0, 105), Color3.fromRGB(20, 20, 20), function() StartGame("Black") end)
CreateBtn("إعادة المباراة 🔄", UDim2.new(0, 10, 0, 150), Color3.fromRGB(180, 50, 50), function() StartGame(PlayerColor) end)

-- Draggable Logic (Corrected for Mobile)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Close Button
local Close = Instance.new("TextButton", MainFrame)
Close.Text = "X"
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundTransparency = 1
Close.TextColor3 = Color3.new(1, 0, 0)
Close.Font = Enum.Font.GothamBold
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

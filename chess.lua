-- MozerHub V7 - Final Mobile Optimized Chess
local UserInputService = game:GetService("UserInputService")
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local LeftSidebar = Instance.new("Frame")
local BoardArea = Instance.new("Frame")

-- Game State
local Board = {}
local Squares = {}
local SelectedSquare = nil
local Turn = "White"
local PlayerColor = "White"
local GameActive = false

-- Theme (Chess.com)
local LightSq = Color3.fromRGB(235, 236, 208)
local DarkSq = Color3.fromRGB(119, 149, 86)
local HighlightColor = Color3.fromRGB(255, 255, 0)

ScreenGui.Name = "MozerChessMobile"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Main Frame (تصغير الحجم ليتناسب مع الجوال)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Size = UDim2.new(0, 440, 0, 280)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -140)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Sidebar
LeftSidebar.Parent = MainFrame
LeftSidebar.Size = UDim2.new(0, 120, 1, 0)
LeftSidebar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", LeftSidebar)
Title.Text = "MOZER CHESS"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 16
Title.BackgroundTransparency = 1

-- Board Area (توسيط الطاولة)
BoardArea.Name = "Board"
BoardArea.Parent = MainFrame
BoardArea.Position = UDim2.new(0, 130, 0, 10)
BoardArea.Size = UDim2.new(0, 260, 0, 260)
BoardArea.BackgroundTransparency = 1

local Grid = Instance.new("UIGridLayout", BoardArea)
Grid.CellSize = UDim2.new(0, 32, 0, 32)
Grid.Spacing = UDim2.new(0, 0, 0, 0)

-- Icons
local Icons = {
	White = {P="♙", R="♖", N="♘", B="♗", Q="♕", K="♔"},
	Black = {P="♟", R="♜", N="♞", B="♝", Q="♛", K="♚"}
}

-- Create Board
for r = 1, 8 do
	Squares[r] = {}
	for c = 1, 8 do
		local sq = Instance.new("TextButton", BoardArea)
		sq.Text = ""
		sq.TextSize = 24
		sq.Font = Enum.Font.GothamBold
		sq.BorderSizePixel = 0
		sq.AutoButtonColor = false
		sq.BackgroundColor3 = (r + c) % 2 == 0 and LightSq or DarkSq
		Squares[r][c] = sq
	end
end

-- Logic functions
local function GetPiece(r, c) return Board[r] and Board[r][c] end

local function GetValidMoves(r, c)
	local p = GetPiece(r, c)
	if not p then return {} end
	local moves = {}
	local color = p.Color
	local function add(nr, nc)
		if nr<1 or nr>8 or nc<1 or nc>8 then return false end
		local target = GetPiece(nr, nc)
		if not target then table.insert(moves, {nr, nc}) return true end
		if target.Color ~= color then table.insert(moves, {nr, nc}) end
		return false
	end
	if p.Type == "P" then
		local d = (color == "White") and -1 or 1
		if not GetPiece(r+d, c) then 
			table.insert(moves, {r+d, c})
			if ((color=="White" and r==7) or (color=="Black" and r==2)) and not GetPiece(r+2*d, c) then table.insert(moves, {r+2*d, c}) end
		end
		for _, dc in pairs({-1, 1}) do
			local t = GetPiece(r+d, c+dc)
			if t and t.Color ~= color then table.insert(moves, {r+d, c+dc}) end
		end
	elseif p.Type == "N" then
		local m = {{2,1},{2,-1},{-2,1},{-2,-1},{1,2},{1,-2},{-1,2},{-1,-2}}
		for _, v in pairs(m) do add(r+v[1], c+v[2]) end
	else
		local dirs = {}
		if p.Type=="R" or p.Type=="Q" then table.insert(dirs,{1,0}); table.insert(dirs,{-1,0}); table.insert(dirs,{0,1}); table.insert(dirs,{0,-1}) end
		if p.Type=="B" or p.Type=="Q" then table.insert(dirs,{1,1}); table.insert(dirs,{1,-1}); table.insert(dirs,{-1,1}); table.insert(dirs,{-1,-1}) end
		if p.Type=="K" then dirs={{1,0},{-1,0},{0,1},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1}} end
		for _, dr in pairs(dirs) do
			for i=1, 8 do if not add(r+dr[1]*i, c+dr[2]*i) or p.Type=="K" then break end end
		end
	end
	return moves
end

local function Render()
	for r=1,8 do for c=1,8 do
		local p = Board[r][c]
		Squares[r][c].Text = p and Icons[p.Color][p.Type] or ""
		Squares[r][c].TextColor3 = (p and p.Color=="White") and Color3.new(1,1,1) or Color3.new(0,0,0)
		Squares[r][c].BackgroundColor3 = (r+c)%2==0 and LightSq or DarkSq
	end end
end

local function AIMove()
	if not GameActive or Turn == PlayerColor then return end
	task.wait(1)
	local aiCol = (PlayerColor=="White") and "Black" or "White"
	local moves = {}
	for r=1,8 do for c=1,8 do
		local p = Board[r][c]
		if p and p.Color == aiCol then
			for _, m in pairs(GetValidMoves(r, c)) do table.insert(moves, {f={r,c}, t=m}) end
		end
	end end
	if #moves > 0 then
		local move = moves[math.random(#moves)]
		Board[move.t[1]][move.t[2]] = Board[move.f[1]][move.f[2]]
		Board[move.f[1]][move.f[2]] = nil
		Turn = PlayerColor
		Render()
	end
end

for r=1,8 do for c=1,8 do
	Squares[r][c].MouseButton1Click:Connect(function()
		if not GameActive or Turn ~= PlayerColor then return end
		if SelectedSquare then
			local valid = false
			for _, m in pairs(GetValidMoves(SelectedSquare.r, SelectedSquare.c)) do
				if m[1]==r and m[2]==c then valid=true break end
			end
			if valid then
				Board[r][c] = Board[SelectedSquare.r][SelectedSquare.c]
				Board[SelectedSquare.r][SelectedSquare.c] = nil
				Turn = (PlayerColor=="White") and "Black" or "White"
				SelectedSquare = nil
				Render()
				AIMove()
			else
				SelectedSquare = nil
				Render()
			end
		else
			local p = Board[r][c]
			if p and p.Color == PlayerColor then
				SelectedSquare = {r=r, c=c}
				Render()
				for _, m in pairs(GetValidMoves(r, c)) do
					Squares[m[1]][m[2]].BackgroundColor3 = HighlightColor
				end
			end
		end
	end)
end end

local function Start(col)
	PlayerColor = col
	Turn = "White"
	GameActive = true
	Board = {}
	for r=1,8 do Board[r] = {} end
	local l = {"R","N","B","Q","K","B","N","R"}
	for i=1,8 do
		Board[1][i]={Type=l[i],Color="Black"}; Board[2][i]={Type="P",Color="Black"}
		Board[7][i]={Type="P",Color="White"}; Board[8][i]={Type=l[i],Color="White"}
	end
	Render()
	if PlayerColor == "Black" then AIMove() end
end

-- Sidebar Controls
local function CreateBtn(txt, pos, color, func)
	local b = Instance.new("TextButton", LeftSidebar)
	b.Size = UDim2.new(1, -10, 0, 30)
	b.Position = pos
	b.Text = txt
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 10
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(func)
end

CreateBtn("الأبيض ⚪", UDim2.new(0, 5, 0, 50), Color3.fromRGB(60,60,60), function() Start("White") end)
CreateBtn("الأسود ⚫", UDim2.new(0, 5, 0, 90), Color3.fromRGB(15,15,15), function() Start("Black") end)
CreateBtn("إعادة المباراة 🔄", UDim2.new(0, 5, 0, 130), Color3.fromRGB(150,50,50), function() Start(PlayerColor) end)

-- Smooth Draggable Logic (WORKS ON MOBILE DELTA)
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Close
local Close = Instance.new("TextButton", MainFrame)
Close.Text = "X"
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.BackgroundTransparency = 1
Close.TextColor3 = Color3.new(1, 0, 0)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

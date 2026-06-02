-- MozerHub v3 - Chess Pro Edition
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local LeftSidebar = Instance.new("Frame")
local RightContent = Instance.new("Frame")
local MinimizedFrame = Instance.new("TextButton")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")

-- Chess Logic Variables
local Board = {}
local SelectedSquare = nil
local ValidMoves = {}
local PlayerColor = "White"
local Turn = "White"
local GameActive = false

-- UI Setup
ScreenGui.Name = "MozerChess"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Size = UDim2.new(0, 540, 0, 380)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -190)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

LeftSidebar.Parent = MainFrame
LeftSidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LeftSidebar.Size = UDim2.new(0, 140, 1, 0)
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 15)

Title.Parent = LeftSidebar
Title.Text = "Mozer Chess ♟️"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

RightContent.Parent = MainFrame
RightContent.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
RightContent.Position = UDim2.new(0, 145, 0, 10)
RightContent.Size = UDim2.new(1, -155, 1, -20)
Instance.new("UICorner", RightContent).CornerRadius = UDim.new(0, 12)

-- Chess Board UI
local BoardFrame = Instance.new("Frame", RightContent)
BoardFrame.Size = UDim2.new(0, 300, 0, 300)
BoardFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
BoardFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UIGridLayout", BoardFrame).CellSize = UDim2.new(0, 37, 0, 37)
BoardFrame.UIGridLayout.Spacing = UDim2.new(0,0,0,0)

-- Piece Icons
local Icons = {
	White = {P="♙", R="♖", N="♘", B="♗", Q="♕", K="♔"},
	Black = {P="♟︎", R="♜", N="♞", B="♝", Q="♛", K="♚"}
}

-- Create Squares
local Squares = {}
for row = 1, 8 do
	Squares[row] = {}
	for col = 1, 8 do
		local sq = Instance.new("TextButton", BoardFrame)
		sq.Name = row .. "_" .. col
		sq.Text = ""
		sq.TextSize = 25
		sq.Font = Enum.Font.GothamBold
		sq.BackgroundColor3 = (row + col) % 2 == 0 and Color3.fromRGB(235, 235, 208) or Color3.fromRGB(119, 149, 86)
		Squares[row][col] = sq
	end
end

-- Game Logic Functions
local function GetPiece(r, c) return Board[r] and Board[r][c] end

local function GetValidMoves(r, c)
	local piece = GetPiece(r, c)
	if not piece then return {} end
	local moves = {}
	local type = piece.Type
	local color = piece.Color
	
	local directions = {
		R = {{1,0}, {-1,0}, {0,1}, {0,-1}},
		B = {{1,1}, {1,-1}, {-1,1}, {-1,-1}},
		N = {{2,1}, {2,-1}, {-2,1}, {-2,-1}, {1,2}, {1,-2}, {-1,2}, {-1,-2}},
		K = {{1,0}, {-1,0}, {0,1}, {0,-1}, {1,1}, {1,-1}, {-1,1}, {-1,-1}}
	}
	directions.Q = {{1,0}, {-1,0}, {0,1}, {0,-1}, {1,1}, {1,-1}, {-1,1}, {-1,-1}}

	if type == "P" then
		local dir = (color == "White") and -1 or 1
		if not GetPiece(r+dir, c) then 
			table.insert(moves, {r+dir, c})
			if (color == "White" and r == 7 or color == "Black" and r == 2) and not GetPiece(r+2*dir, c) then
				table.insert(moves, {r+2*dir, c})
			end
		end
		-- Captures
		for _, dc in pairs({-1, 1}) do
			local target = GetPiece(r+dir, c+dc)
			if target and target.Color ~= color then table.insert(moves, {r+dir, c+dc}) end
		end
	elseif directions[type] then
		for _, d in pairs(directions[type]) do
			for i = 1, 8 do
				local nr, nc = r + d[1]*i, c + d[2]*i
				if nr<1 or nr>8 or nc<1 or nc>8 then break end
				local target = GetPiece(nr, nc)
				if not target then table.insert(moves, {nr, nc})
				elseif target.Color ~= color then table.insert(moves, {nr, nc}) break
				else break end
				if type == "N" or type == "K" then break end
			end
		end
	end
	return moves
end

local function UpdateBoardUI()
	for r=1,8 do for c=1,8 do
		local p = Board[r][c]
		Squares[r][c].Text = p and Icons[p.Color][p.Type] or ""
		Squares[r][c].TextColor3 = p and (p.Color == "White" and Color3.new(1,1,1) or Color3.new(0,0,0)) or Color3.new(1,1,1)
		-- Reset square color
		Squares[r][c].BackgroundColor3 = (r + c) % 2 == 0 and Color3.fromRGB(235, 235, 208) or Color3.fromRGB(119, 149, 86)
	end end
end

local function HighlightMoves(moves)
	for _, m in pairs(moves) do
		Squares[m[1]][m[2]].BackgroundColor3 = Color3.fromRGB(247, 247, 105) -- اصفر شفاف للتلميح
	end
end

-- AI Move (Simple Random/Greedy)
local function AIMove()
	if not GameActive or Turn == PlayerColor then return end
	task.wait(1)
	local aiColor = (PlayerColor == "White") and "Black" or "White"
	local allMoves = {}
	for r=1,8 do for c=1,8 do
		local p = Board[r][c]
		if p and p.Color == aiColor then
			local moves = GetValidMoves(r, c)
			for _, m in pairs(moves) do table.insert(allMoves, {from={r,c}, to=m}) end
		end
	end end
	
	if #allMoves > 0 then
		local move = allMoves[math.random(#allMoves)]
		local target = Board[move.to[1]][move.to[2]]
		if target and target.Type == "K" then GameActive = false end
		Board[move.to[1]][move.to[2]] = Board[move.from[1]][move.from[2]]
		Board[move.from[1]][move.from[2]] = nil
		Turn = PlayerColor
		UpdateBoardUI()
	end
end

-- Square Click Event
for r=1,8 do for c=1,8 do
	Squares[r][c].MouseButton1Click:Connect(function()
		if not GameActive or Turn ~= PlayerColor then return end
		
		local piece = Board[r][c]
		-- Move piece
		local isMove = false
		for _, m in pairs(ValidMoves) do
			if m[1] == r and m[2] == c then
				local target = Board[r][c]
				if target and target.Type == "K" then GameActive = false end
				Board[r][c] = Board[SelectedSquare.r][SelectedSquare.c]
				Board[SelectedSquare.r][SelectedSquare.c] = nil
				Turn = (PlayerColor == "White") and "Black" or "White"
				isMove = true
				break
			end
		end
		
		if isMove then
			SelectedSquare = nil
			ValidMoves = {}
			UpdateBoardUI()
			AIMove()
		else
			if piece and piece.Color == PlayerColor then
				UpdateBoardUI()
				SelectedSquare = {r=r, c=c}
				ValidMoves = GetValidMoves(r, c)
				HighlightMoves(ValidMoves)
			else
				-- Warning for illegal move
				local originalColor = Squares[r][c].BackgroundColor3
				Squares[r][c].BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				task.delay(0.5, function() Squares[r][c].BackgroundColor3 = originalColor end)
			end
		end
	end)
end end

-- Start Game Function
local function ResetGame(color)
	PlayerColor = color
	Turn = "White"
	GameActive = true
	Board = {}
	for r=1,8 do Board[r] = {} end
	
	local layout = {"R", "N", "B", "Q", "K", "B", "N", "R"}
	for i=1,8 do
		Board[1][i] = {Type=layout[i], Color="Black"}
		Board[2][i] = {Type="P", Color="Black"}
		Board[7][i] = {Type="P", Color="White"}
		Board[8][i] = {Type=layout[i], Color="White"}
	end
	UpdateBoardUI()
	if PlayerColor == "Black" then AIMove() end
end

-- UI Controls
local Controls = Instance.new("Frame", LeftSidebar)
Controls.Size = UDim2.new(1, -20, 0, 150)
Controls.Position = UDim2.new(0, 10, 0, 60)
Controls.BackgroundTransparency = 1
Instance.new("UIListLayout", Controls).Padding = UDim.new(0, 10)

local function CreateBtn(text, color)
	local b = Instance.new("TextButton", Controls)
	b.Size = UDim2.new(1, 0, 0, 35)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	Instance.new("UICorner", b)
	return b
end

local WhiteBtn = CreateBtn("العب بالأبيض ⚪", Color3.fromRGB(50, 50, 50))
local BlackBtn = CreateBtn("العب بالأسود ⚫", Color3.fromRGB(0, 0, 0))
local ResetBtn = CreateBtn("إعادة المباراة 🔄", Color3.fromRGB(150, 50, 50))

WhiteBtn.MouseButton1Click:Connect(function() ResetGame("White") end)
BlackBtn.MouseButton1Click:Connect(function() ResetGame("Black") end)
ResetBtn.MouseButton1Click:Connect(function() ResetGame(PlayerColor) end)

-- Draggable Logic (From previous version)
local function drag(f)
	local s, start, startP
	f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then s = true start = i.Position startP = f.Position end end)
	game:GetService("UserInputService").InputChanged:Connect(function(i) if s and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - start
		f.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
	end end)
	f.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then s = false end end)
end
drag(MainFrame)

CloseBtn.Parent = MainFrame
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0,30,0,30)
CloseBtn.Position = UDim2.new(1,-35,0,5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255,0,0)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

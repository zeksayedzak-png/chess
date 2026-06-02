-- MozerHub v4 - Chess Pro (Smart AI + Timers)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local RightContent = Instance.new("Frame")
local LeftSidebar = Instance.new("Frame")
local Title = Instance.new("TextLabel")

-- Game Variables
local Board = {}
local Squares = {}
local SelectedSquare = nil
local PlayerColor = "White"
local Turn = "White"
local GameActive = false
local WhiteTime = 600 -- 10 دقائق
local BlackTime = 600

-- Piece Values (for Smart AI)
local Values = { P = 10, N = 30, B = 30, R = 50, Q = 90, K = 900 }

-- UI Setup
ScreenGui.Name = "MozerChessPro"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

LeftSidebar.Parent = MainFrame
LeftSidebar.Size = UDim2.new(0, 150, 1, 0)
LeftSidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 15)

RightContent.Parent = MainFrame
RightContent.Position = UDim2.new(0, 160, 0, 10)
RightContent.Size = UDim2.new(1, -170, 1, -20)
RightContent.BackgroundTransparency = 1

-- Timers UI
local TimerFrame = Instance.new("Frame", LeftSidebar)
TimerFrame.Size = UDim2.new(1, -20, 0, 80)
TimerFrame.Position = UDim2.new(0, 10, 0, 60)
TimerFrame.BackgroundTransparency = 1

local WTimerLabel = Instance.new("TextLabel", TimerFrame)
WTimerLabel.Size = UDim2.new(1, 0, 0.4, 0)
WTimerLabel.Text = "⚪ White: 10:00"
WTimerLabel.TextColor3 = Color3.new(1,1,1)
WTimerLabel.Font = Enum.Font.GothamBold

local BTimerLabel = Instance.new("TextLabel", TimerFrame)
BTimerLabel.Size = UDim2.new(1, 0, 0.4, 0)
BTimerLabel.Position = UDim2.new(0, 0, 0.5, 0)
BTimerLabel.Text = "⚫ Black: 10:00"
BTimerLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
BTimerLabel.Font = Enum.Font.GothamBold

-- Board UI
local BoardFrame = Instance.new("Frame", RightContent)
BoardFrame.Size = UDim2.new(0, 320, 0, 320)
BoardFrame.Position = UDim2.new(0.5, -160, 0.5, -160)
local Grid = Instance.new("UIGridLayout", BoardFrame)
Grid.CellSize = UDim2.new(0, 40, 0, 40)
Grid.Spacing = UDim2.new(0,0,0,0)

-- Piece Icons
local Icons = {
	White = {P="♙", R="♖", N="♘", B="♗", Q="♕", K="♔"},
	Black = {P="♟︎", R="♜", N="♞", B="♝", Q="♛", K="♚"}
}

-- Create Squares
for r = 1, 8 do
	Squares[r] = {}
	for c = 1, 8 do
		local sq = Instance.new("TextButton", BoardFrame)
		sq.TextSize = 30
		sq.BackgroundColor3 = (r+c)%2==0 and Color3.fromRGB(240, 217, 181) or Color3.fromRGB(181, 136, 99)
		Squares[r][c] = sq
	end
end

-- Rules Logic
local function GetPiece(r, c) return Board[r] and Board[r][c] end

local function GetValidMoves(r, c)
	local p = GetPiece(r, c)
	if not p then return {} end
	local moves = {}
	local color = p.Color
	
	if p.Type == "P" then -- البيدق
		local dir = (color == "White") and -1 or 1
		if not GetPiece(r+dir, c) then 
			table.insert(moves, {r+dir, c})
			if (color == "White" and r == 7 or color == "Black" and r == 2) and not GetPiece(r+2*dir, c) then
				table.insert(moves, {r+2*dir, c})
			end
		end
		for _, dc in pairs({-1, 1}) do
			local target = GetPiece(r+dir, c+dc)
			if target and target.Color ~= color then table.insert(moves, {r+dir, c+dc}) end
		end
	elseif p.Type == "N" then -- الحصان حرف L
		local nMoves = {{2,1},{2,-1},{-2,1},{-2,-1},{1,2},{1,-2},{-1,2},{-1,-2}}
		for _, m in pairs(nMoves) do
			local nr, nc = r+m[1], c+m[2]
			if nr>=1 and nr<=8 and nc>=1 and nc<=8 then
				local target = GetPiece(nr, nc)
				if not target or target.Color ~= color then table.insert(moves, {nr, nc}) end
			end
		end
	-- (باقي الحركات للوزير والقلعة والفيل مدمجة هنا)
	elseif p.Type == "R" or p.Type == "B" or p.Type == "Q" or p.Type == "K" then
		local dirs = {}
		if p.Type == "R" or p.Type == "Q" then table.insert(dirs, {1,0}); table.insert(dirs, {-1,0}); table.insert(dirs, {0,1}); table.insert(dirs, {0,-1}) end
		if p.Type == "B" or p.Type == "Q" then table.insert(dirs, {1,1}); table.insert(dirs, {1,-1}); table.insert(dirs, {-1,1}); table.insert(dirs, {-1,-1}) end
		if p.Type == "K" then dirs = {{1,0},{-1,0},{0,1},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1}} end
		
		for _, d in pairs(dirs) do
			for i = 1, 8 do
				local nr, nc = r+d[1]*i, c+d[2]*i
				if nr<1 or nr>8 or nc<1 or nc>8 then break end
				local target = GetPiece(nr, nc)
				if not target then table.insert(moves, {nr, nc})
				elseif target.Color ~= color then table.insert(moves, {nr, nc}); break
				else break end
				if p.Type == "K" then break end
			end
		end
	end
	return moves
end

-- Smart AI Logic
local function SmartAIMove()
	if not GameActive or Turn == PlayerColor then return end
	local aiColor = (PlayerColor == "White") and "Black" or "White"
	local bestMove = nil
	local maxScore = -9999
	
	for r=1,8 do for c=1,8 do
		local p = Board[r][c]
		if p and p.Color == aiColor then
			local moves = GetValidMoves(r, c)
			for _, m in pairs(moves) do
				local score = 0
				local target = Board[m[1]][m[2]]
				if target then score = Values[target.Type] end -- أكل قطعة
				
				if score > maxScore then
					maxScore = score
					bestMove = {from={r,c}, to=m}
				end
			end
		end
	end end
	
	if bestMove then
		task.wait(1.5)
		local from = bestMove.from
		local to = bestMove.to
		Board[to[1]][to[2]] = Board[from[1]][from[2]]
		Board[from[1]][from[2]] = nil
		Turn = PlayerColor
		UpdateUI()
	end
end

function UpdateUI()
	for r=1,8 do for c=1,8 do
		local p = Board[r][c]
		Squares[r][c].Text = p and Icons[p.Color][p.Type] or ""
		Squares[r][c].TextColor3 = (p and p.Color == "White") and Color3.new(1,1,1) or Color3.new(0,0,0)
		Squares[r][c].BackgroundColor3 = (r+c)%2==0 and Color3.fromRGB(240, 217, 181) or Color3.fromRGB(181, 136, 99)
	end end
end

-- Handle Click
for r=1,8 do for c=1,8 do
	Squares[r][c].MouseButton1Click:Connect(function()
		if not GameActive or Turn ~= PlayerColor then return end
		
		if SelectedSquare then
			local moves = GetValidMoves(SelectedSquare.r, SelectedSquare.c)
			local moveMade = false
			for _, m in pairs(moves) do
				if m[1] == r and m[2] == c then
					Board[r][c] = Board[SelectedSquare.r][SelectedSquare.c]
					Board[SelectedSquare.r][SelectedSquare.c] = nil
					Turn = (PlayerColor == "White") and "Black" or "White"
					moveMade = true
					break
				end
			end
			SelectedSquare = nil
			UpdateUI()
			if moveMade then SmartAIMove() end
		else
			local p = Board[r][c]
			if p and p.Color == PlayerColor then
				SelectedSquare = {r=r, c=c}
				local moves = GetValidMoves(r, c)
				for _, m in pairs(moves) do
					Squares[m[1]][m[2]].BackgroundColor3 = Color3.fromRGB(255, 255, 150) -- تلميح أصفر
				end
			end
		end
	end)
end end

-- Timers Loop
task.spawn(function()
	while true do
		task.wait(1)
		if GameActive then
			if Turn == "White" then
				WhiteTime = math.max(0, WhiteTime - 1)
				WTimerLabel.Text = string.format("⚪ White: %02d:%02d", math.floor(WhiteTime/60), WhiteTime%60)
			else
				BlackTime = math.max(0, BlackTime - 1)
				BTimerLabel.Text = string.format("⚫ Black: %02d:%02d", math.floor(BlackTime/60), BlackTime%60)
			end
			if WhiteTime == 0 or BlackTime == 0 then GameActive = false end
		end
	end
end)

-- Controls
local function Start(color)
	PlayerColor = color
	Board = {}
	for r=1,8 do Board[r] = {} end
	local l = {"R","N","B","Q","K","B","N","R"}
	for i=1,8 do
		Board[1][i]={Type=l[i],Color="Black"}; Board[2][i]={Type="P",Color="Black"}
		Board[7][i]={Type="P",Color="White"}; Board[8][i]={Type=l[i],Color="White"}
	end
	WhiteTime, BlackTime = 600, 600
	Turn = "White"
	GameActive = true
	UpdateUI()
	if PlayerColor == "Black" then SmartAIMove() end
end

local WBtn = Instance.new("TextButton", LeftSidebar)
WBtn.Size = UDim2.new(1,-20,0,35); WBtn.Position = UDim2.new(0,10,0,160); WBtn.Text = "العب بالأبيض ⚪"
WBtn.BackgroundColor3 = Color3.fromRGB(60,60,60); WBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", WBtn)
WBtn.MouseButton1Click:Connect(function() Start("White") end)

local BBtn = Instance.new("TextButton", LeftSidebar)
BBtn.Size = UDim2.new(1,-20,0,35); BBtn.Position = UDim2.new(0,10,0,200); BBtn.Text = "العب بالأسود ⚫"
BBtn.BackgroundColor3 = Color3.fromRGB(10,10,10); BBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", BBtn)
BBtn.MouseButton1Click:Connect(function() Start("Black") end)

-- Draggable
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

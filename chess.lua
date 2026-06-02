-- MozerHub V6 - The Original Chess Experience
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local BoardArea = Instance.new("Frame")
local LeftSidebar = Instance.new("Frame")
local StatusLabel = Instance.new("TextLabel")

-- Settings
local Board = {}
local Squares = {}
local SelectedSquare = nil
local Turn = "White"
local PlayerColor = "White"
local GameActive = false

-- Color Palette (Chess.com Style)
local LightSq = Color3.fromRGB(235, 236, 208)
local DarkSq = Color3.fromRGB(119, 149, 86)
local HighlightColor = Color3.fromRGB(247, 247, 105)

-- UI Setup
ScreenGui.Name = "MozerChess_Final"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- Sidebar
LeftSidebar.Parent = MainFrame
LeftSidebar.Size = UDim2.new(0, 140, 1, 0)
LeftSidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", LeftSidebar)
Title.Text = "MOZER CHESS"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 20
Title.BackgroundTransparency = 1

StatusLabel.Parent = LeftSidebar
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 50)
StatusLabel.Text = "إختر لونك للبدء"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1

-- Original Chess Board
BoardArea.Name = "Board"
BoardArea.Parent = MainFrame
BoardArea.Position = UDim2.new(0, 150, 0.5, -160)
BoardArea.Size = UDim2.new(0, 320, 0, 320)
BoardArea.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BoardArea.BorderSizePixel = 2

local Grid = Instance.new("UIGridLayout", BoardArea)
Grid.CellSize = UDim2.new(0, 40, 0, 40)
Grid.Spacing = UDim2.new(0, 0, 0, 0)

-- Piece Icons (Solid & Visible)
local Icons = {
	White = {P="♙", R="♖", N="♘", B="♗", Q="♕", K="♔"},
	Black = {P="♟︎", R="♜", N="♞", B="♝", Q="♛", K="♚"}
}

-- Create Squares
for r = 1, 8 do
	Squares[r] = {}
	for c = 1, 8 do
		local sq = Instance.new("TextButton", BoardArea)
		sq.Name = r .. "_" .. c
		sq.Text = ""
		sq.TextSize = 32 -- تكبير القطع لتكون واضحة
		sq.Font = Enum.Font.GothamBold
		sq.BorderSizePixel = 0
		sq.AutoButtonColor = false
		sq.BackgroundColor3 = (r + c) % 2 == 0 and LightSq or DarkSq
		Squares[r][c] = sq
	end
end

-- Logic: Moves
local function GetPiece(r, c) return Board[r] and Board[r][c] end

local function GetValidMoves(r, c)
	local p = GetPiece(r, c)
	if not p then return {} end
	local moves = {}
	local color = p.Color
	
	local function check(nr, nc)
		if nr<1 or nr>8 or nc<1 or nc>8 then return "out" end
		local target = GetPiece(nr, nc)
		if not target then table.insert(moves, {nr, nc}) return "empty" end
		if target.Color ~= color then table.insert(moves, {nr, nc}) return "capture" end
		return "block"
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
		for _, v in pairs(m) do check(r+v[1], c+v[2]) end
	elseif p.Type == "R" or p.Type == "B" or p.Type == "Q" or p.Type == "K" then
		local dirs = {}
		if p.Type=="R" or p.Type=="Q" then table.insert(dirs,{1,0}); table.insert(dirs,{-1,0}); table.insert(dirs,{0,1}); table.insert(dirs,{0,-1}) end
		if p.Type=="B" or p.Type=="Q" then table.insert(dirs,{1,1}); table.insert(dirs,{1,-1}); table.insert(dirs,{-1,1}); table.insert(dirs,{-1,-1}) end
		if p.Type=="K" then dirs={{1,0},{-1,0},{0,1},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1}} end
		for _, dr in pairs(dirs) do
			for i=1, 8 do
				local res = check(r+dr[1]*i, c+dr[2]*i)
				if res ~= "empty" or p.Type=="K" then break end
			end
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

-- AI (Smart Thinking)
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
		StatusLabel.Text = "دورك الآن"
		Render()
	end
end

-- Interactions
for r=1,8 do for c=1,8 do
	Squares[r][c].MouseButton1Click:Connect(function()
		if not GameActive or Turn ~= PlayerColor then return end
		if SelectedSquare then
			local valid = false
			local moves = GetValidMoves(SelectedSquare.r, SelectedSquare.c)
			for _, m in pairs(moves) do if m[1]==r and m[2]==c then valid=true break end end
			
			if valid then
				Board[r][c] = Board[SelectedSquare.r][SelectedSquare.c]
				Board[SelectedSquare.r][SelectedSquare.c] = nil
				Turn = (PlayerColor=="White") and "Black" or "White"
				StatusLabel.Text = "الكمبيوتر يفكر..."
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

-- Start Game Function
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
	StatusLabel.Text = (Turn==PlayerColor) and "دورك الآن" or "دور الكمبيوتر"
	Render()
	if PlayerColor == "Black" then AIMove() end
end

-- Sidebar Controls
local function CreateBtn(txt, pos, color, func)
	local b = Instance.new("TextButton", LeftSidebar)
	b.Size = UDim2.new(1, -20, 0, 40)
	b.Position = pos
	b.Text = txt
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(func)
end

CreateBtn("الأبيض ⚪", UDim2.new(0, 10, 0, 100), Color3.fromRGB(60, 60, 60), function() Start("White") end)
CreateBtn("الأسود ⚫", UDim2.new(0, 10, 0, 150), Color3.fromRGB(15, 15, 15), function() Start("Black") end)
CreateBtn("إعادة 🔄", UDim2.new(0, 10, 0, 200), Color3.fromRGB(180, 50, 50), function() Start(PlayerColor) end)

-- Close & Drag
local Close = Instance.new("TextButton", MainFrame)
Close.Text = "X"
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.BackgroundTransparency = 1
Close.TextColor3 = Color3.new(1,0,0)
Close.TextSize = 20
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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

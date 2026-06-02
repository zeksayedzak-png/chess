-- MozerHub v2.4 - Blackjack Pro (Minimize System & Side Scores)
local UserInputService = game:GetService("UserInputService")
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local LeftSidebar = Instance.new("Frame")
local RightContent = Instance.new("Frame")
local MinimizedFrame = Instance.new("TextButton")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")

-- Game States
local Balance = 1000
local CurrentBet = 0
local PlayerHand = {}
local DealerHand = {}
local suits = {"❤️", "💎", "♣️", "♠️"}
local names = {[1]="آس",[11]="عجوز👴",[12]="أميرة👸",[13]="ملك🤴"}
local GameActive = false

-- UI Setup
ScreenGui.Name = "MozerBlackjack_V2.4"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- الواجهة الرئيسية
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- الزر الصغير (عند التصغير)
MinimizedFrame.Name = "MinimizedFrame"
MinimizedFrame.Parent = ScreenGui
MinimizedFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MinimizedFrame.Size = UDim2.new(0, 55, 0, 55)
MinimizedFrame.Position = UDim2.new(0.1, 0, 0.5, 0)
MinimizedFrame.Visible = false
MinimizedFrame.Text = "🃏"
MinimizedFrame.TextSize = 35
MinimizedFrame.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinimizedFrame).CornerRadius = UDim.new(0, 12)

-- Sidebar (القائمة اليسرى للنقاط)
LeftSidebar.Parent = MainFrame
LeftSidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
LeftSidebar.Size = UDim2.new(0, 130, 1, 0)
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 15)

Title.Parent = LeftSidebar
Title.Text = "Be Mozer 🃏"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

-- عرض النقاط في الجانب
local ScoreContainer = Instance.new("Frame", LeftSidebar)
ScoreContainer.Size = UDim2.new(1, 0, 0, 100)
ScoreContainer.Position = UDim2.new(0, 0, 0, 50)
ScoreContainer.BackgroundTransparency = 1

local PlayerScoreLabel = Instance.new("TextLabel", ScoreContainer)
PlayerScoreLabel.Size = UDim2.new(1, -10, 0, 30)
PlayerScoreLabel.Position = UDim2.new(0, 10, 0, 0)
PlayerScoreLabel.Text = "نقاطك: 0"
PlayerScoreLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
PlayerScoreLabel.Font = Enum.Font.GothamBold
PlayerScoreLabel.TextSize = 14
PlayerScoreLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerScoreLabel.BackgroundTransparency = 1

local DealerScoreLabel = Instance.new("TextLabel", ScoreContainer)
DealerScoreLabel.Size = UDim2.new(1, -10, 0, 30)
DealerScoreLabel.Position = UDim2.new(0, 10, 0, 35)
DealerScoreLabel.Text = "الموزع: 0"
DealerScoreLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
DealerScoreLabel.Font = Enum.Font.GothamBold
DealerScoreLabel.TextSize = 14
DealerScoreLabel.TextXAlignment = Enum.TextXAlignment.Left
DealerScoreLabel.BackgroundTransparency = 1

-- محتوى اللعبة (اليمين)
RightContent.Parent = MainFrame
RightContent.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
RightContent.Position = UDim2.new(0, 135, 0, 10)
RightContent.Size = UDim2.new(1, -145, 1, -20)
Instance.new("UICorner", RightContent).CornerRadius = UDim.new(0, 12)

local Header = Instance.new("Frame", RightContent)
Header.Size = UDim2.new(1, -10, 0, 30)
Header.Position = UDim2.new(0, 5, 0, 5)
Header.BackgroundTransparency = 1

local BalanceLabel = Instance.new("TextLabel", Header)
BalanceLabel.Size = UDim2.new(0.6, 0, 1, 0)
BalanceLabel.Text = "💰: " .. Balance
BalanceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
BalanceLabel.Font = Enum.Font.GothamBold
BalanceLabel.TextSize = 14
BalanceLabel.TextXAlignment = Enum.TextXAlignment.Left
BalanceLabel.BackgroundTransparency = 1

local ResearchBtn = Instance.new("TextButton", Header)
ResearchBtn.Size = UDim2.new(0, 60, 0, 25)
ResearchBtn.Position = UDim2.new(1, -65, 0, 0)
ResearchBtn.Text = "إعادة 🔄"
ResearchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ResearchBtn.TextColor3 = Color3.new(1,1,1)
ResearchBtn.TextSize = 10
Instance.new("UICorner", ResearchBtn)

-- منطقة الكروت
local CardContainer = Instance.new("Frame", RightContent)
CardContainer.Size = UDim2.new(1, -10, 0, 170)
CardContainer.Position = UDim2.new(0, 5, 0, 40)
CardContainer.BackgroundTransparency = 1

local DealerCards = Instance.new("Frame", CardContainer)
DealerCards.Size = UDim2.new(1, 0, 0.45, 0)
DealerCards.BackgroundTransparency = 1
Instance.new("UIListLayout", DealerCards).FillDirection = Enum.FillDirection.Horizontal
DealerCards.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
DealerCards.UIListLayout.Padding = UDim.new(0, 5)

local PlayerCards = Instance.new("Frame", CardContainer)
PlayerCards.Size = UDim2.new(1, 0, 0.45, 0)
PlayerCards.Position = UDim2.new(0, 0, 0.55, 0)
PlayerCards.BackgroundTransparency = 1
Instance.new("UIListLayout", PlayerCards).FillDirection = Enum.FillDirection.Horizontal
PlayerCards.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PlayerCards.UIListLayout.Padding = UDim.new(0, 5)

-- أزرار الكوينز (تصغير)
local BetScroll = Instance.new("ScrollingFrame", RightContent)
BetScroll.Size = UDim2.new(1, -10, 0, 35)
BetScroll.Position = UDim2.new(0, 5, 1, -80)
BetScroll.CanvasSize = UDim2.new(2, 0, 0, 0)
BetScroll.BackgroundTransparency = 1
BetScroll.ScrollBarThickness = 0
Instance.new("UIListLayout", BetScroll).FillDirection = Enum.FillDirection.Horizontal
BetScroll.UIListLayout.Padding = UDim.new(0, 4)

local function CreateBetBtn(amt)
	local b = Instance.new("TextButton", BetScroll)
	b.Size = UDim2.new(0, 40, 1, 0)
	b.Text = amt
	b.TextSize = 10
	b.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(function()
		if not GameActive then CurrentBet = amt BalanceLabel.Text = "💰: "..Balance.." | الرهان: "..amt end
	end)
end
for _, a in pairs({10, 50, 100, 500, 1000, 2000, 5000, 10000}) do CreateBetBtn(a) end

-- وظائف اللعبة
local function GetScore(hand)
	local s, aces = 0, 0
	for _, c in pairs(hand) do
		local val = c.Num
		if val > 10 then val = 10 end
		if val == 1 then val = 11 aces = aces + 1 end
		s = s + val
	end
	while s > 21 and aces > 0 do s = s - 10 aces = aces - 1 end
	return s
end

local function UpdateScores(showDealer)
	PlayerScoreLabel.Text = "نقاطك: " .. GetScore(PlayerHand)
	if showDealer then
		DealerScoreLabel.Text = "الموزع: " .. GetScore(DealerHand)
	else
		local fv = DealerHand[1].Num
		if fv > 10 then fv = 10 elseif fv == 1 then fv = 11 end
		DealerScoreLabel.Text = "الموزع: " .. fv .. " + ?"
	end
end

local function CreateCard(card, parent, isHidden)
	local c = Instance.new("Frame", parent)
	c.Size = UDim2.new(0, 45, 0, 70)
	c.BackgroundColor3 = isHidden and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", c).CornerRadius = UDim.new(0, 8)
	
	if not isHidden then
		local t = Instance.new("TextLabel", c)
		t.Size = UDim2.new(1, 0, 1, 0)
		t.Text = card.Suit .. "\n" .. (names[card.Num] or card.Num)
		t.TextSize = 15 -- تكبير محتوى الورقة قليلاً
		t.Font = Enum.Font.GothamBold
		t.TextColor3 = (card.Suit == "❤️" or card.Suit == "💎") and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 0, 0)
		t.BackgroundTransparency = 1
	else
		local t = Instance.new("TextLabel", c)
		t.Size = UDim2.new(1, 0, 1, 0)
		t.Text = "❓"
		t.TextSize = 20
		t.TextColor3 = Color3.new(1,1,1)
		t.BackgroundTransparency = 1
	end
end

-- أزرار التحكم
local Controls = Instance.new("Frame", RightContent)
Controls.Size = UDim2.new(1, -10, 0, 35)
Controls.Position = UDim2.new(0, 5, 1, -40)
Controls.BackgroundTransparency = 1

local MainAction = Instance.new("TextButton", Controls)
MainAction.Size = UDim2.new(0, 120, 1, 0)
MainAction.Position = UDim2.new(0.5, -60, 0, 0)
MainAction.Text = "بدء اللعب ✅"
MainAction.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
MainAction.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MainAction)

local HitBtn = Instance.new("TextButton", Controls)
HitBtn.Size = UDim2.new(0, 80, 1, 0)
HitBtn.Position = UDim2.new(0, 10, 0, 0)
HitBtn.Text = "سحب 🃏"
HitBtn.Visible = false
HitBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
Instance.new("UICorner", HitBtn)

local StandBtn = Instance.new("TextButton", Controls)
StandBtn.Size = UDim2.new(0, 80, 1, 0)
StandBtn.Position = UDim2.new(1, -90, 0, 0)
StandBtn.Text = "توقف ✋"
StandBtn.Visible = false
StandBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Instance.new("UICorner", StandBtn)

-- أحداث اللعب
MainAction.MouseButton1Click:Connect(function()
	if CurrentBet > 0 and Balance >= CurrentBet then
		GameActive = true
		Balance = Balance - CurrentBet
		PlayerHand = {{Num=math.random(1,13), Suit=suits[math.random(1,4)]}, {Num=math.random(1,13), Suit=suits[math.random(1,4)]}}
		DealerHand = {{Num=math.random(1,13), Suit=suits[math.random(1,4)]}, {Num=math.random(1,13), Suit=suits[math.random(1,4)]}}
		for _, v in pairs(PlayerCards:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
		for _, v in pairs(DealerCards:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
		for _, c in pairs(PlayerHand) do CreateCard(c, PlayerCards) end
		CreateCard(DealerHand[1], DealerCards); CreateCard({}, DealerCards, true)
		UpdateScores(false)
		MainAction.Visible = false; HitBtn.Visible = true; StandBtn.Visible = true
		BalanceLabel.Text = "💰: " .. Balance
	end
end)

HitBtn.MouseButton1Click:Connect(function()
	local c = {Num=math.random(1,13), Suit=suits[math.random(1,4)]}
	table.insert(PlayerHand, c); CreateCard(c, PlayerCards); UpdateScores(false)
	if GetScore(PlayerHand) > 21 then
		GameActive = false; HitBtn.Visible = false; StandBtn.Visible = false; MainAction.Visible = true
		MainAction.Text = "خسرت! جولة جديدة؟"; UpdateScores(true)
	end
end)

StandBtn.MouseButton1Click:Connect(function()
	HitBtn.Visible = false; StandBtn.Visible = false
	for _, v in pairs(DealerCards:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
	for _, c in pairs(DealerHand) do CreateCard(c, DealerCards) end
	while GetScore(DealerHand) < 17 do
		task.wait(0.5)
		local c = {Num=math.random(1,13), Suit=suits[math.random(1,4)]}
		table.insert(DealerHand, c); CreateCard(c, DealerCards); UpdateScores(true)
	end
	local ps, ds = GetScore(PlayerHand), GetScore(DealerHand)
	if ds > 21 or ps > ds then Balance = Balance + (CurrentBet * 2); MainAction.Text = "فزت! 🎉 جولة جديدة؟"
	elseif ps < ds then MainAction.Text = "خسرت! 💀 جولة جديدة؟"
	else Balance = Balance + CurrentBet; MainAction.Text = "تعادل! جولة جديدة؟" end
	GameActive = false; MainAction.Visible = true; BalanceLabel.Text = "💰: " .. Balance; UpdateScores(true)
end)

ResearchBtn.MouseButton1Click:Connect(function()
	if not GameActive then Balance = 1000; BalanceLabel.Text = "💰: " .. Balance; PlayerScoreLabel.Text = "نقاطك: 0"; DealerScoreLabel.Text = "الموزع: 0" end
end)

-- وظيفة التصغير والتحريك (Draggable)
local function MakeDraggable(frame)
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end

MakeDraggable(MainFrame)
MakeDraggable(MinimizedFrame)

CloseBtn.Parent = MainFrame
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0,30,0,30); CloseBtn.Position = UDim2.new(1,-35,0,5); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextColor3 = Color3.new(1,0,0)

CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	MinimizedFrame.Visible = true
end)

MinimizedFrame.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	MinimizedFrame.Visible = false
end)

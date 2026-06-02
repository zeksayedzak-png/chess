-- MozerHub v2.2 - Blackjack Pro (Score Counter & UI Fix)
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
ScreenGui.Name = "MozerBlackjack_Mobile"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

LeftSidebar.Parent = MainFrame
LeftSidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
LeftSidebar.Size = UDim2.new(0, 130, 1, 0)
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 15)

Title.Parent = LeftSidebar
Title.Text = "Be Mozer 🃏"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

RightContent.Parent = MainFrame
RightContent.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
RightContent.Position = UDim2.new(0, 135, 0, 10)
RightContent.Size = UDim2.new(1, -145, 1, -20)
Instance.new("UICorner", RightContent).CornerRadius = UDim.new(0, 12)

-- Balance & Research
local Header = Instance.new("Frame", RightContent)
Header.Size = UDim2.new(1, -10, 0, 30)
Header.Position = UDim2.new(0, 5, 0, 5)
Header.BackgroundTransparency = 1

local BalanceLabel = Instance.new("TextLabel", Header)
BalanceLabel.Size = UDim2.new(0.7, 0, 1, 0)
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
ResearchBtn.TextSize = 10
ResearchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ResearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ResearchBtn)

-- Card Display with Scores
local CardContainer = Instance.new("Frame", RightContent)
CardContainer.Size = UDim2.new(1, -10, 0, 160)
CardContainer.Position = UDim2.new(0, 5, 0, 40)
CardContainer.BackgroundTransparency = 1

-- العدادات (Score Labels)
local DealerScoreText = Instance.new("TextLabel", CardContainer)
DealerScoreText.Size = UDim2.new(1, 0, 0, 15)
DealerScoreText.Text = "نقاط الموزع: 0"
DealerScoreText.TextColor3 = Color3.fromRGB(200, 200, 200)
DealerScoreText.Font = Enum.Font.GothamMedium
DealerScoreText.TextSize = 11
DealerScoreText.BackgroundTransparency = 1

local PlayerScoreText = Instance.new("TextLabel", CardContainer)
PlayerScoreText.Size = UDim2.new(1, 0, 0, 15)
PlayerScoreText.Position = UDim2.new(0, 0, 0.5, -5)
PlayerScoreText.Text = "نقاطك: 0"
PlayerScoreText.TextColor3 = Color3.fromRGB(200, 200, 200)
PlayerScoreText.Font = Enum.Font.GothamMedium
PlayerScoreText.TextSize = 11
PlayerScoreText.BackgroundTransparency = 1

local DealerCards = Instance.new("Frame", CardContainer)
DealerCards.Size = UDim2.new(1, 0, 0.4, 0)
DealerCards.Position = UDim2.new(0, 0, 0.1, 0)
DealerCards.BackgroundTransparency = 1
local DLayout = Instance.new("UIListLayout", DealerCards)
DLayout.FillDirection = Enum.FillDirection.Horizontal
DLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
DLayout.Padding = UDim.new(0, 5)

local PlayerCards = Instance.new("Frame", CardContainer)
PlayerCards.Size = UDim2.new(1, 0, 0.4, 0)
PlayerCards.Position = UDim2.new(0, 0, 0.6, 0)
PlayerCards.BackgroundTransparency = 1
local PLayout = Instance.new("UIListLayout", PlayerCards)
PLayout.FillDirection = Enum.FillDirection.Horizontal
PLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PLayout.Padding = UDim.new(0, 5)

-- Small Bet Buttons (Reduced Size)
local BetScroll = Instance.new("ScrollingFrame", RightContent)
BetScroll.Size = UDim2.new(1, -10, 0, 40)
BetScroll.Position = UDim2.new(0, 5, 1, -80)
BetScroll.CanvasSize = UDim2.new(1.8, 0, 0, 0)
BetScroll.BackgroundTransparency = 1
BetScroll.ScrollBarThickness = 0
local BetLayout = Instance.new("UIListLayout", BetScroll)
BetLayout.FillDirection = Enum.FillDirection.Horizontal
BetLayout.Padding = UDim.new(0, 4)

local function CreateBetBtn(amt)
	local b = Instance.new("TextButton", BetScroll)
	b.Size = UDim2.new(0, 38, 0, 28) -- تصغير الأزرار
	b.Text = amt
	b.TextSize = 9
	b.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(function()
		if not GameActive then CurrentBet = amt BalanceLabel.Text = "💰: "..Balance.." | الرهان: "..amt end
	end)
end
local amounts = {10, 50, 100, 500, 1000, 2000, 5000, 10000}
for _, a in pairs(amounts) do CreateBetBtn(a) end

-- Logic
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

local function CreateCard(card, parent, isHidden)
	local c = Instance.new("Frame", parent)
	c.Size = UDim2.new(0, 45, 0, 70)
	c.BackgroundColor3 = isHidden and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", c).CornerRadius = UDim.new(0, 8)
	
	if not isHidden then
		local t = Instance.new("TextLabel", c)
		t.Size = UDim2.new(1, 0, 1, 0)
		t.Text = card.Suit .. "\n" .. (names[card.Num] or card.Num)
		t.TextSize = 14 -- تكبير الرقم والإيموجي قليلاً
		t.Font = Enum.Font.GothamBold
		t.TextColor3 = (card.Suit == "❤️" or card.Suit == "💎") and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 0, 0)
		t.BackgroundTransparency = 1
	else
		local t = Instance.new("TextLabel", c)
		t.Size = UDim2.new(1, 0, 1, 0)
		t.Text = "❓"
		t.TextSize = 18
		t.TextColor3 = Color3.fromRGB(255, 255, 255)
		t.BackgroundTransparency = 1
	end
end

-- Controls
local Controls = Instance.new("Frame", RightContent)
Controls.Size = UDim2.new(1, -10, 0, 35)
Controls.Position = UDim2.new(0, 5, 1, -40)
Controls.BackgroundTransparency = 1

local MainAction = Instance.new("TextButton", Controls)
MainAction.Size = UDim2.new(0, 120, 1, 0)
MainAction.Position = UDim2.new(0.5, -60, 0, 0)
MainAction.Text = "بدء اللعب ✅"
MainAction.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
MainAction.TextColor3 = Color3.fromRGB(255, 255, 255)
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

local function UpdateScores(showDealer)
    PlayerScoreText.Text = "نقاطك: " .. GetScore(PlayerHand)
    if showDealer then
        DealerScoreText.Text = "نقاط الموزع: " .. GetScore(DealerHand)
    else
        -- في البداية نظهر فقط قيمة أول كارت للموزع
        local firstCardVal = DealerHand[1].Num
        if firstCardVal > 10 then firstCardVal = 10 elseif firstCardVal == 1 then firstCardVal = 11 end
        DealerScoreText.Text = "نقاط الموزع: " .. firstCardVal .. " + ?"
    end
end

MainAction.MouseButton1Click:Connect(function()
	if CurrentBet > 0 and not GameActive and Balance >= CurrentBet then
		GameActive = true
		Balance = Balance - CurrentBet
		PlayerHand = {{Num=math.random(1,13), Suit=suits[math.random(1,4)]}, {Num=math.random(1,13), Suit=suits[math.random(1,4)]}}
		DealerHand = {{Num=math.random(1,13), Suit=suits[math.random(1,4)]}, {Num=math.random(1,13), Suit=suits[math.random(1,4)]}}
		
		for _, v in pairs(PlayerCards:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
		for _, v in pairs(DealerCards:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
		
		for _, c in pairs(PlayerHand) do CreateCard(c, PlayerCards) end
		CreateCard(DealerHand[1], DealerCards)
		CreateCard({}, DealerCards, true)
		
		UpdateScores(false)
		MainAction.Visible = false
		HitBtn.Visible = true
		StandBtn.Visible = true
		BalanceLabel.Text = "💰: " .. Balance
	end
end)

HitBtn.MouseButton1Click:Connect(function()
	local newCard = {Num=math.random(1,13), Suit=suits[math.random(1,4)]}
	table.insert(PlayerHand, newCard)
	CreateCard(newCard, PlayerCards)
    UpdateScores(false)
	if GetScore(PlayerHand) > 21 then
		GameActive = false
		HitBtn.Visible = false StandBtn.Visible = false MainAction.Visible = true
		MainAction.Text = "خسرت! جولة جديدة؟"
        UpdateScores(true)
	end
end)

StandBtn.MouseButton1Click:Connect(function()
	HitBtn.Visible = false StandBtn.Visible = false
	for _, v in pairs(DealerCards:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
	for _, c in pairs(DealerHand) do CreateCard(c, DealerCards) end
	
	while GetScore(DealerHand) < 17 do
		task.wait(0.5)
		local c = {Num=math.random(1,13), Suit=suits[math.random(1,4)]}
		table.insert(DealerHand, c)
		CreateCard(c, DealerCards)
        UpdateScores(true)
	end
	
	local pS, dS = GetScore(PlayerHand), GetScore(DealerHand)
    UpdateScores(true)
	if dS > 21 or pS > dS then
		Balance = Balance + (CurrentBet * 2)
		MainAction.Text = "فزت! 🎉 جولة جديدة؟"
	elseif pS < dS then
		MainAction.Text = "خسرت! 💀 جولة جديدة؟"
	else
		Balance = Balance + CurrentBet
		MainAction.Text = "تعادل! جولة جديدة؟"
	end
	GameActive = false
	MainAction.Visible = true
	BalanceLabel.Text = "💰: " .. Balance
end)

ResearchBtn.MouseButton1Click:Connect(function()
	if not GameActive then Balance = 1000 BalanceLabel.Text = "💰: " .. Balance end
end)

-- Draggable Logic
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

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

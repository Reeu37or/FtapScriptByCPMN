-- VIBE MENU | B = открыть/закрыть | T = Locker
-- Xeno compatible

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Ждём игрока
local player = Players.LocalPlayer
repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

local camera = workspace.CurrentCamera

-- Удаляем старое меню если есть
local oldGui = player.PlayerGui:FindFirstChild("VibeMenu")
if oldGui then oldGui:Destroy() end
local oldBlur = Lighting:FindFirstChild("VibeBlur")
if oldBlur then oldBlur:Destroy() end

-- СОСТОЯНИЯ
local menuOpen = false
local lockerActive = false
local lockerBV = nil
local lockerBG = nil
local animTrack = nil
local currentAnim = nil

-- BLUR
local vibeBlur = Instance.new("BlurEffect")
vibeBlur.Name = "VibeBlur"
vibeBlur.Size = 0
vibeBlur.Parent = Lighting

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VibeMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

-- ГЛАВНЫЙ ФРЕЙМ
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 700, 0, 540)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -270)
mainFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
mainFrame.BackgroundTransparency = 0.06
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
local ms = Instance.new("UIStroke", mainFrame)
ms.Color = Color3.fromRGB(255,255,255); ms.Thickness = 1; ms.Transparency = 0.82

-- TOPBAR
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,52)
topBar.BackgroundColor3 = Color3.fromRGB(10,10,10)
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,16)
local tfix = Instance.new("Frame", topBar)
tfix.Size=UDim2.new(1,0,0,18); tfix.Position=UDim2.new(0,0,1,-18)
tfix.BackgroundColor3=Color3.fromRGB(10,10,10); tfix.BorderSizePixel=0

-- Акцент полоска
local acc = Instance.new("Frame", topBar)
acc.Size=UDim2.new(0,3,0,26); acc.Position=UDim2.new(0,16,0.5,-13)
acc.BackgroundColor3=Color3.fromRGB(255,255,255); acc.BorderSizePixel=0; acc.ZIndex=3
Instance.new("UICorner", acc).CornerRadius=UDim.new(1,0)

local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Size=UDim2.new(1,-90,0,26); titleLbl.Position=UDim2.new(0,28,0,7)
titleLbl.BackgroundTransparency=1; titleLbl.Text="VIBE MENU"
titleLbl.TextColor3=Color3.fromRGB(255,255,255); titleLbl.TextSize=17
titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
titleLbl.ZIndex=3

local subLbl = Instance.new("TextLabel", topBar)
subLbl.Size=UDim2.new(1,-90,0,14); subLbl.Position=UDim2.new(0,29,0,33)
subLbl.BackgroundTransparency=1; subLbl.Text="B — открыть / закрыть"
subLbl.TextColor3=Color3.fromRGB(70,70,70); subLbl.TextSize=11
subLbl.Font=Enum.Font.Gotham; subLbl.TextXAlignment=Enum.TextXAlignment.Left; subLbl.ZIndex=3

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size=UDim2.new(0,32,0,32); closeBtn.Position=UDim2.new(1,-44,0,10)
closeBtn.BackgroundColor3=Color3.fromRGB(30,30,30); closeBtn.BorderSizePixel=0
closeBtn.Text="x"; closeBtn.TextColor3=Color3.fromRGB(160,160,160)
closeBtn.TextSize=14; closeBtn.Font=Enum.Font.GothamBold; closeBtn.ZIndex=3
Instance.new("UICorner", closeBtn).CornerRadius=UDim.new(0,8)

-- SIDEBAR
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size=UDim2.new(0,68,1,-52); sidebar.Position=UDim2.new(0,0,0,52)
sidebar.BackgroundColor3=Color3.fromRGB(9,9,9); sidebar.BorderSizePixel=0

local sdiv = Instance.new("Frame", mainFrame)
sdiv.Size=UDim2.new(0,1,1,-52); sdiv.Position=UDim2.new(0,68,0,52)
sdiv.BackgroundColor3=Color3.fromRGB(36,36,36); sdiv.BorderSizePixel=0

-- CONTENT
local contentArea = Instance.new("ScrollingFrame", mainFrame)
contentArea.Size=UDim2.new(1,-70,1,-52); contentArea.Position=UDim2.new(0,70,0,52)
contentArea.BackgroundTransparency=1; contentArea.BorderSizePixel=0
contentArea.ScrollBarThickness=3; contentArea.ScrollBarImageColor3=Color3.fromRGB(50,50,50)
contentArea.CanvasSize=UDim2.new(0,0,0,600); contentArea.ClipsDescendants=true

-- ИКОНКИ РИСОВАННЫЕ

local function makeIconSun(parent)
	-- Солнце
	local f = Instance.new("Frame",parent); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local c = Instance.new("Frame",f); c.Size=UDim2.new(0,10,0,10); c.Position=UDim2.new(0.5,-5,0.5,-5)
	c.BackgroundColor3=Color3.fromRGB(255,255,255); c.BorderSizePixel=0
	Instance.new("UICorner",c).CornerRadius=UDim.new(1,0)
	for i=0,7 do
		local r=Instance.new("Frame",f); r.Size=UDim2.new(0,2,0,5)
		r.AnchorPoint=Vector2.new(0.5,1); r.Position=UDim2.new(0.5,0,0.5,0)
		r.BackgroundColor3=Color3.fromRGB(255,255,255); r.BorderSizePixel=0; r.Rotation=i*45
		Instance.new("UICorner",r).CornerRadius=UDim.new(1,0)
	end
end

local function makeIconBody(parent)
	-- Фигурка
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local function box(sx,sy,px,py,rot)
		local b=Instance.new("Frame",f); b.Size=UDim2.new(0,sx,0,sy)
		b.Position=UDim2.new(0.5,px-sx/2,0,py); b.BackgroundColor3=Color3.fromRGB(255,255,255)
		b.BorderSizePixel=0; if rot then b.Rotation=rot end
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
	end
	box(8,8,0,1)        -- голова
	box(4,9,0,11)       -- тело
	box(3,7,-6,12,-20)  -- лрука
	box(3,7,7,10,30)    -- прука (смещ)
	box(3,8,-4,21,-10)  -- лнога
	box(3,8,3,21,10)    -- пнога
end

local function makeIconLock(parent)
	-- Замок
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local function box(sx,sy,px,py)
		local b=Instance.new("Frame",f); b.Size=UDim2.new(0,sx,0,sy)
		b.Position=UDim2.new(0.5,px,0.5,py); b.BackgroundColor3=Color3.fromRGB(255,255,255); b.BorderSizePixel=0
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
	end
	box(16,11,-8,0)   -- корпус
	box(3,9,-7,-9)    -- дужка L
	box(3,9,4,-9)     -- дужка R
	box(12,3,-6,-13)  -- дужка верх
	-- скважина
	local h=Instance.new("Frame",f); h.Size=UDim2.new(0,4,0,4); h.Position=UDim2.new(0.5,-2,0.5,2)
	h.BackgroundColor3=Color3.fromRGB(6,6,6); h.BorderSizePixel=0
	Instance.new("UICorner",h).CornerRadius=UDim.new(1,0)
end

local function makeIconPlanet(parent)
	-- Планета + стрелка
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local p=Instance.new("Frame",f); p.Size=UDim2.new(0,14,0,14); p.Position=UDim2.new(0.5,-7,0,-1)
	p.BackgroundColor3=Color3.fromRGB(255,255,255); p.BorderSizePixel=0
	Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
	local ring=Instance.new("Frame",f); ring.Size=UDim2.new(0,20,0,4); ring.Position=UDim2.new(0.5,-10,0,3)
	ring.BackgroundColor3=Color3.fromRGB(255,255,255); ring.BackgroundTransparency=0.5
	ring.BorderSizePixel=0; ring.Rotation=-20
	Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
	-- стрелка
	local ar=Instance.new("Frame",f); ar.Size=UDim2.new(0,2,0,9); ar.Position=UDim2.new(0.5,-1,0,16)
	ar.BackgroundColor3=Color3.fromRGB(255,255,255); ar.BorderSizePixel=0
	local al=Instance.new("Frame",f); al.Size=UDim2.new(0,6,0,2); al.Position=UDim2.new(0.5,-5,0,23)
	al.BackgroundColor3=Color3.fromRGB(255,255,255); al.BorderSizePixel=0; al.Rotation=40
	local arr=Instance.new("Frame",f); arr.Size=UDim2.new(0,6,0,2); arr.Position=UDim2.new(0.5,0,0,23)
	arr.BackgroundColor3=Color3.fromRGB(255,255,255); arr.BorderSizePixel=0; arr.Rotation=-40
end

local function makeIconTools(parent)
	-- Иконка: прицел + линия (символ инструментов/настроек)
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	-- Внешний круг прицела
	local outer=Instance.new("Frame",f); outer.Size=UDim2.new(0,18,0,18); outer.Position=UDim2.new(0.5,-9,0,2)
	outer.BackgroundTransparency=1; outer.BorderSizePixel=0
	local os=Instance.new("UIStroke",outer); os.Color=Color3.fromRGB(255,255,255); os.Thickness=2
	Instance.new("UICorner",outer).CornerRadius=UDim.new(1,0)
	-- Внутренняя точка
	local dot=Instance.new("Frame",f); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0.5,-2,0,9)
	dot.BackgroundColor3=Color3.fromRGB(255,255,255); dot.BorderSizePixel=0
	Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	-- Крестик линии прицела
	local h=Instance.new("Frame",f); h.Size=UDim2.new(0,8,0,2); h.Position=UDim2.new(0.5,-4,0,10)
	h.BackgroundColor3=Color3.fromRGB(255,255,255); h.BorderSizePixel=0
	local v=Instance.new("Frame",f); v.Size=UDim2.new(0,2,0,8); v.Position=UDim2.new(0.5,-1,0,7)
	v.BackgroundColor3=Color3.fromRGB(255,255,255); v.BorderSizePixel=0
	-- Маленький слайдер снизу
	local track=Instance.new("Frame",f); track.Size=UDim2.new(0,20,0,3); track.Position=UDim2.new(0.5,-10,0,23)
	track.BackgroundColor3=Color3.fromRGB(50,50,50); track.BorderSizePixel=0
	Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
	local fill=Instance.new("Frame",track); fill.Size=UDim2.new(0.6,0,1,0)
	fill.BackgroundColor3=Color3.fromRGB(255,255,255); fill.BorderSizePixel=0
	Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
	local knob=Instance.new("Frame",track); knob.Size=UDim2.new(0,5,0,7); knob.Position=UDim2.new(0.6,-2,0.5,-3)
	knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
	Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
end

local function makeIconSpeed(parent)
	-- Молния (скорость)
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	-- Верхняя часть молнии
	local t=Instance.new("Frame",f); t.Size=UDim2.new(0,10,0,13)
	t.Position=UDim2.new(0.5,0,0,1); t.BackgroundColor3=Color3.fromRGB(255,255,255)
	t.BorderSizePixel=0; t.Rotation=-15
	local tc=Instance.new("UICorner",t); tc.CornerRadius=UDim.new(0,2)
	-- Нижняя часть молнии
	local b=Instance.new("Frame",f); b.Size=UDim2.new(0,10,0,13)
	b.Position=UDim2.new(0.5,-10,0,12); b.BackgroundColor3=Color3.fromRGB(255,255,255)
	b.BorderSizePixel=0; b.Rotation=-15
	local bc=Instance.new("UICorner",b); bc.CornerRadius=UDim.new(0,2)
	-- Линии скорости
	for i=0,2 do
		local l=Instance.new("Frame",f); l.Size=UDim2.new(0,6-i*1,0,2)
		l.Position=UDim2.new(0,1,0,8+i*5); l.BackgroundColor3=Color3.fromRGB(255,255,255)
		l.BackgroundTransparency=0.4+i*0.15; l.BorderSizePixel=0
		Instance.new("UICorner",l).CornerRadius=UDim.new(1,0)
	end
end

local function makeIconEsp(parent)
	-- Глаз (ESP)
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	-- Верхняя дуга глаза
	local eyeOuter=Instance.new("Frame",f); eyeOuter.Size=UDim2.new(0,20,0,12)
	eyeOuter.Position=UDim2.new(0.5,-10,0.5,-8); eyeOuter.BackgroundTransparency=1; eyeOuter.BorderSizePixel=0
	local es=Instance.new("UIStroke",eyeOuter); es.Color=Color3.fromRGB(255,255,255); es.Thickness=2
	Instance.new("UICorner",eyeOuter).CornerRadius=UDim.new(0,6)
	-- Зрачок
	local pupil=Instance.new("Frame",f); pupil.Size=UDim2.new(0,7,0,7)
	pupil.Position=UDim2.new(0.5,-3,0.5,-5); pupil.BackgroundColor3=Color3.fromRGB(255,255,255)
	pupil.BorderSizePixel=0; Instance.new("UICorner",pupil).CornerRadius=UDim.new(1,0)
	-- Блик
	local shine=Instance.new("Frame",f); shine.Size=UDim2.new(0,3,0,3)
	shine.Position=UDim2.new(0.5,0,0.5,-7); shine.BackgroundColor3=Color3.fromRGB(255,255,255)
	shine.BackgroundTransparency=0.3; shine.BorderSizePixel=0
	Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
	-- Ресницы/лучи
	for i=-1,1 do
		local ray=Instance.new("Frame",f); ray.Size=UDim2.new(0,2,0,4)
		ray.Position=UDim2.new(0.5,i*6-1,0,0); ray.BackgroundColor3=Color3.fromRGB(255,255,255)
		ray.BackgroundTransparency=0.5; ray.BorderSizePixel=0
		Instance.new("UICorner",ray).CornerRadius=UDim.new(1,0)
	end
end

local function makeIconNoclip(parent)
	-- Два квадрата пересекающихся (прохождение сквозь)
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	-- Первый квадрат (цельный)
	local sq1=Instance.new("Frame",f); sq1.Size=UDim2.new(0,14,0,14)
	sq1.Position=UDim2.new(0.5,-12,0,3); sq1.BackgroundTransparency=1; sq1.BorderSizePixel=0
	local s1s=Instance.new("UIStroke",sq1); s1s.Color=Color3.fromRGB(255,255,255); s1s.Thickness=2
	Instance.new("UICorner",sq1).CornerRadius=UDim.new(0,3)
	-- Второй квадрат (пунктирный — имитация)
	local sq2=Instance.new("Frame",f); sq2.Size=UDim2.new(0,14,0,14)
	sq2.Position=UDim2.new(0.5,-2,0,10); sq2.BackgroundTransparency=1; sq2.BorderSizePixel=0
	local s2s=Instance.new("UIStroke",sq2); s2s.Color=Color3.fromRGB(255,255,255); s2s.Thickness=2; s2s.Transparency=0.4
	Instance.new("UICorner",sq2).CornerRadius=UDim.new(0,3)
	-- Стрелка "сквозь"
	local arr=Instance.new("Frame",f); arr.Size=UDim2.new(0,2,0,12)
	arr.Position=UDim2.new(0.5,-1,0,7); arr.BackgroundColor3=Color3.fromRGB(255,255,255)
	arr.BackgroundTransparency=0.3; arr.BorderSizePixel=0
end

-- SIDEBAR КНОПКИ

local function makeSideBtn(iconFn, yPos)
	local btn=Instance.new("TextButton",sidebar)
	btn.Size=UDim2.new(0,46,0,46); btn.Position=UDim2.new(0.5,-23,0,yPos)
	btn.BackgroundColor3=Color3.fromRGB(20,20,20); btn.BackgroundTransparency=1
	btn.BorderSizePixel=0; btn.Text=""; btn.AutoButtonColor=false
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)

	local ih=Instance.new("Frame",btn); ih.Size=UDim2.new(0,26,0,26)
	ih.Position=UDim2.new(0.5,-13,0.5,-13); ih.BackgroundTransparency=1
	iconFn(ih)

	local ind=Instance.new("Frame",btn); ind.Name="Ind"
	ind.Size=UDim2.new(0,3,0,22); ind.Position=UDim2.new(0,-2,0.5,-11)
	ind.BackgroundColor3=Color3.fromRGB(255,255,255); ind.BackgroundTransparency=1
	ind.BorderSizePixel=0
	Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)

	return btn
end

local btnSky    = makeSideBtn(makeIconSun,    10)
local btnAnim   = makeSideBtn(makeIconBody,   64)
local btnLocker = makeSideBtn(makeIconLock,  118)
local btnSkyC   = makeSideBtn(makeIconPlanet,172)
local btnTools  = makeSideBtn(makeIconTools, 226)
local btnSpeed  = makeSideBtn(makeIconSpeed, 280)
local btnEsp    = makeSideBtn(makeIconEsp,   334)
local btnNoclip = makeSideBtn(makeIconNoclip,388)

local allBtns = {btnSky, btnAnim, btnLocker, btnSkyC, btnTools, btnSpeed, btnEsp, btnNoclip}

-- Растягиваем sidebar под 8 кнопок
sidebar.Size = UDim2.new(0,68,1,-52)

-- ВСПОМОГАТЕЛЬНЫЕ КОМПОНЕНТЫ

local TIF = TweenInfo.new(0.14, Enum.EasingStyle.Quad)

local function clearContent()
	for _,c in ipairs(contentArea:GetChildren()) do c:Destroy() end
end

local function hdr(parent, title, sub, y)
	local l=Instance.new("TextLabel",parent)
	l.Size=UDim2.new(1,-28,0,22); l.Position=UDim2.new(0,14,0,y)
	l.BackgroundTransparency=1; l.Text=title
	l.TextColor3=Color3.fromRGB(255,255,255); l.TextSize=15
	l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
	if sub then
		local s=Instance.new("TextLabel",parent)
		s.Size=UDim2.new(1,-28,0,14); s.Position=UDim2.new(0,15,0,y+23)
		s.BackgroundTransparency=1; s.Text=sub
		s.TextColor3=Color3.fromRGB(60,60,60); s.TextSize=11
		s.Font=Enum.Font.Gotham; s.TextXAlignment=Enum.TextXAlignment.Left
	end
end

local function divLine(parent, y)
	local l=Instance.new("Frame",parent)
	l.Size=UDim2.new(1,-28,0,1); l.Position=UDim2.new(0,14,0,y)
	l.BackgroundColor3=Color3.fromRGB(24,24,24); l.BorderSizePixel=0
end

local function card(parent, title, sub, y, cb)
	local f=Instance.new("TextButton",parent)
	f.Size=UDim2.new(1,-28,0,50); f.Position=UDim2.new(0,14,0,y)
	f.BackgroundColor3=Color3.fromRGB(14,14,14); f.BorderSizePixel=0
	f.Text=""; f.AutoButtonColor=false
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
	local fs=Instance.new("UIStroke",f); fs.Color=Color3.fromRGB(30,30,30); fs.Thickness=1

	local t=Instance.new("TextLabel",f)
	t.Size=UDim2.new(1,-14,0,20); t.Position=UDim2.new(0,12,0,8)
	t.BackgroundTransparency=1; t.Text=title
	t.TextColor3=Color3.fromRGB(225,225,225); t.TextSize=13
	t.Font=Enum.Font.GothamSemibold; t.TextXAlignment=Enum.TextXAlignment.Left

	if sub then
		local s=Instance.new("TextLabel",f)
		s.Size=UDim2.new(1,-14,0,14); s.Position=UDim2.new(0,12,0,29)
		s.BackgroundTransparency=1; s.Text=sub
		s.TextColor3=Color3.fromRGB(65,65,65); s.TextSize=11
		s.Font=Enum.Font.Gotham; s.TextXAlignment=Enum.TextXAlignment.Left
	end

	f.MouseEnter:Connect(function() TweenService:Create(f,TIF,{BackgroundColor3=Color3.fromRGB(22,22,22)}):Play() end)
	f.MouseLeave:Connect(function() TweenService:Create(f,TIF,{BackgroundColor3=Color3.fromRGB(14,14,14)}):Play() end)
	f.MouseButton1Click:Connect(function()
		TweenService:Create(f,TweenInfo.new(0.07),{BackgroundColor3=Color3.fromRGB(32,32,32)}):Play()
		task.delay(0.1,function() TweenService:Create(f,TIF,{BackgroundColor3=Color3.fromRGB(14,14,14)}):Play() end)
		cb()
	end)
	return f
end

-- СТРАНИЦЫ

local function buildSkyPage()
	clearContent()
	contentArea.CanvasSize=UDim2.new(0,0,0,500)
	hdr(contentArea,"SKY","Пресеты неба и освещения",14)
	divLine(contentArea,55)

	local presets={
		{"Clear Day",    "Ясный день",          {ClockTime=14, Brightness=2,   Ambient=Color3.fromRGB(70,95,115)}},
		{"Night",        "Звёздная ночь",        {ClockTime=0,  Brightness=0,   Ambient=Color3.fromRGB(8,8,22)}},
		{"Sunset",       "Оранжевый закат",      {ClockTime=19, Brightness=1.5, Ambient=Color3.fromRGB(120,55,18)}},
		{"Overcast",     "Пасмурно",             {ClockTime=12, Brightness=0.7, Ambient=Color3.fromRGB(70,70,80)}},
		{"Deep Night",   "Глубокая ночь",        {ClockTime=3,  Brightness=0,   Ambient=Color3.fromRGB(4,4,12)}},
		{"Golden Hour",  "Золотой час",          {ClockTime=7,  Brightness=2,   Ambient=Color3.fromRGB(180,115,35)}},
		{"Blood Sky",    "Красное небо",         {ClockTime=18, Brightness=1.2, Ambient=Color3.fromRGB(130,20,10)}},
		{"Void",         "Черная пустота",       {ClockTime=0,  Brightness=0,   Ambient=Color3.fromRGB(0,0,0)}},
	}

	for i,p in ipairs(presets) do
		card(contentArea, p[1], p[2], 64+(i-1)*58, function()
			for k,v in pairs(p[3]) do
				pcall(function() Lighting[k]=v end)
			end
		end)
	end
end

local function buildAnimPage()
	clearContent()
	contentArea.CanvasSize=UDim2.new(0,0,0,480)
	hdr(contentArea,"ANIMATED","Анимации персонажа",14)
	divLine(contentArea,55)

	local anims={
		{"Split Arms",   "Руки отделяются от тела",      "rbxassetid://5915192537"},
		{"Sit Idle",     "Сидит на месте",               "rbxassetid://2506281857"},
		{"Demon Stand",  "Стоит в воздухе как демон",    "rbxassetid://5342546925"},
		{"Lay Down",     "Лежит на полу",                "rbxassetid://2506281879"},
		{"Levitate",     "Парит в воздухе",              "rbxassetid://3247955605"},
		{"T-Pose",       "Т-поза",                       "rbxassetid://2506281986"},
	}

	card(contentArea,"Сбросить","Остановить текущую анимацию",64,function()
		if animTrack then pcall(function() animTrack:Stop() end); animTrack=nil; currentAnim=nil end
	end)

	for i,a in ipairs(anims) do
		card(contentArea, a[1], a[2], 64+i*58, function()
			local char=player.Character; if not char then return end
			local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
			if animTrack then pcall(function() animTrack:Stop() end); animTrack=nil end
			if currentAnim==a[3] then currentAnim=nil; return end
			currentAnim=a[3]
			local anim=Instance.new("Animation"); anim.AnimationId=a[3]
			local animator=hum:FindFirstChildOfClass("Animator")
			if not animator then animator=Instance.new("Animator",hum) end
			animTrack=animator:LoadAnimation(anim)
			animTrack.Looped=true
			animTrack:Play()
		end)
	end
end

local function buildLockerPage()
	clearContent()
	contentArea.CanvasSize=UDim2.new(0,0,0,380)
	hdr(contentArea,"LOCKER","T — быстрый тоггл в любой момент",14)
	divLine(contentArea,55)

	-- Статус бокс
	local sb=Instance.new("Frame",contentArea)
	sb.Size=UDim2.new(1,-28,0,60); sb.Position=UDim2.new(0,14,0,64)
	sb.BackgroundColor3=Color3.fromRGB(11,11,11); sb.BorderSizePixel=0
	Instance.new("UICorner",sb).CornerRadius=UDim.new(0,12)
	Instance.new("UIStroke",sb).Color=Color3.fromRGB(32,32,32)

	local statusLbl=Instance.new("TextLabel",sb)
	statusLbl.Size=UDim2.new(1,0,1,0); statusLbl.BackgroundTransparency=1
	statusLbl.Text=lockerActive and "LOCKER  ON" or "LOCKER  OFF"
	statusLbl.TextColor3=lockerActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(55,55,55)
	statusLbl.TextSize=18; statusLbl.Font=Enum.Font.GothamBold

	local function updStatus(s)
		TweenService:Create(statusLbl,TIF,{
			TextColor3=s and Color3.fromRGB(255,255,255) or Color3.fromRGB(55,55,55)
		}):Play()
		statusLbl.Text=s and "LOCKER  ON" or "LOCKER  OFF"
	end

	card(contentArea,"Включить Locker","Плавное падение прямо вниз",136,function()
		lockerActive=true
		local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		if not lockerBV or not lockerBV.Parent then
			lockerBV=Instance.new("BodyVelocity",hrp)
			lockerBV.MaxForce=Vector3.new(1e5,1e5,1e5)
			lockerBV.Velocity=Vector3.new(0,-6,0)
		end
		if not lockerBG or not lockerBG.Parent then
			lockerBG=Instance.new("BodyGyro",hrp)
			lockerBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
			lockerBG.D=300; lockerBG.CFrame=CFrame.new(hrp.Position)
		end
		updStatus(true)
	end)

	card(contentArea,"Выключить Locker","Вернуть обычную физику",194,function()
		lockerActive=false
		if lockerBV and lockerBV.Parent then lockerBV:Destroy(); lockerBV=nil end
		if lockerBG and lockerBG.Parent then lockerBG:Destroy(); lockerBG=nil end
		updStatus(false)
	end)

	divLine(contentArea,256)

	local hint=Instance.new("Frame",contentArea)
	hint.Size=UDim2.new(1,-28,0,70); hint.Position=UDim2.new(0,14,0,264)
	hint.BackgroundColor3=Color3.fromRGB(10,10,10); hint.BorderSizePixel=0
	Instance.new("UICorner",hint).CornerRadius=UDim.new(0,10)
	local hl=Instance.new("TextLabel",hint)
	hl.Size=UDim2.new(1,-20,1,-14); hl.Position=UDim2.new(0,10,0,7)
	hl.BackgroundTransparency=1
	hl.Text="Когда тебя бросают — нажми T.\nГасит всю горизонтальную скорость,\nтело падает медленно и ровно вниз."
	hl.TextColor3=Color3.fromRGB(58,58,58); hl.TextSize=12; hl.Font=Enum.Font.Gotham
	hl.TextWrapped=true; hl.TextXAlignment=Enum.TextXAlignment.Left; hl.TextYAlignment=Enum.TextYAlignment.Top

	-- T клавиша обновляет статус
	UserInputService.InputBegan:Connect(function(inp,gpe)
		if gpe then return end
		if inp.KeyCode==Enum.KeyCode.T then
			lockerActive=not lockerActive
			local char=player.Character
			if lockerActive and char then
				local hrp=char:FindFirstChild("HumanoidRootPart")
				if hrp then
					if not lockerBV or not lockerBV.Parent then
						lockerBV=Instance.new("BodyVelocity",hrp)
						lockerBV.MaxForce=Vector3.new(1e5,1e5,1e5)
						lockerBV.Velocity=Vector3.new(0,-6,0)
					end
					if not lockerBG or not lockerBG.Parent then
						lockerBG=Instance.new("BodyGyro",hrp)
						lockerBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
						lockerBG.D=300; lockerBG.CFrame=CFrame.new(hrp.Position)
					end
				end
			else
				if lockerBV and lockerBV.Parent then lockerBV:Destroy(); lockerBV=nil end
				if lockerBG and lockerBG.Parent then lockerBG:Destroy(); lockerBG=nil end
			end
			updStatus(lockerActive)
		end
	end)
end

local function buildSkyChangerPage()
	clearContent()
	contentArea.CanvasSize=UDim2.new(0,0,0,360)
	hdr(contentArea,"SKY CHANGER","Вставь свой Asset ID",14)
	divLine(contentArea,55)

	-- Input
	local ibg=Instance.new("Frame",contentArea)
	ibg.Size=UDim2.new(1,-28,0,44); ibg.Position=UDim2.new(0,14,0,64)
	ibg.BackgroundColor3=Color3.fromRGB(13,13,13); ibg.BorderSizePixel=0
	Instance.new("UICorner",ibg).CornerRadius=UDim.new(0,10)
	local ibs=Instance.new("UIStroke",ibg); ibs.Color=Color3.fromRGB(40,40,40); ibs.Thickness=1

	local ph=Instance.new("TextLabel",ibg)
	ph.Size=UDim2.new(1,-14,1,0); ph.Position=UDim2.new(0,12,0,0)
	ph.BackgroundTransparency=1; ph.Text="Asset ID (только цифры)..."
	ph.TextColor3=Color3.fromRGB(48,48,48); ph.TextSize=13; ph.Font=Enum.Font.Gotham
	ph.TextXAlignment=Enum.TextXAlignment.Left

	local ib=Instance.new("TextBox",ibg)
	ib.Size=UDim2.new(1,-14,1,0); ib.Position=UDim2.new(0,12,0,0)
	ib.BackgroundTransparency=1; ib.BorderSizePixel=0; ib.Text=""
	ib.TextColor3=Color3.fromRGB(255,255,255); ib.TextSize=14; ib.Font=Enum.Font.GothamSemibold
	ib.TextXAlignment=Enum.TextXAlignment.Left; ib.ClearTextOnFocus=false; ib.PlaceholderText=""

	ib:GetPropertyChangedSignal("Text"):Connect(function()
		ph.Visible=ib.Text==""
		ib.Text=ib.Text:gsub("[^%d]","")
	end)
	ib.Focused:Connect(function() TweenService:Create(ibs,TIF,{Color=Color3.fromRGB(90,90,90)}):Play() end)
	ib.FocusLost:Connect(function() TweenService:Create(ibs,TIF,{Color=Color3.fromRGB(40,40,40)}):Play() end)

	-- Кнопка применить
	local ab=Instance.new("TextButton",contentArea)
	ab.Size=UDim2.new(1,-28,0,44); ab.Position=UDim2.new(0,14,0,118)
	ab.BackgroundColor3=Color3.fromRGB(255,255,255); ab.BorderSizePixel=0
	ab.Text="ПРИМЕНИТЬ"; ab.TextColor3=Color3.fromRGB(0,0,0)
	ab.TextSize=13; ab.Font=Enum.Font.GothamBold; ab.AutoButtonColor=false
	Instance.new("UICorner",ab).CornerRadius=UDim.new(0,10)
	ab.MouseEnter:Connect(function() TweenService:Create(ab,TIF,{BackgroundColor3=Color3.fromRGB(215,215,215)}):Play() end)
	ab.MouseLeave:Connect(function() TweenService:Create(ab,TIF,{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play() end)

	local res=Instance.new("TextLabel",contentArea)
	res.Size=UDim2.new(1,-28,0,22); res.Position=UDim2.new(0,16,0,172)
	res.BackgroundTransparency=1; res.Text=""; res.TextSize=12
	res.Font=Enum.Font.GothamSemibold; res.TextXAlignment=Enum.TextXAlignment.Left

	ab.MouseButton1Click:Connect(function()
		local id=ib.Text
		if id=="" then
			res.Text="Введи Asset ID!"; res.TextColor3=Color3.fromRGB(255,70,70); return
		end
		local aid="rbxassetid://"..id
		local old=Lighting:FindFirstChildOfClass("Sky"); if old then old:Destroy() end
		local sky=Instance.new("Sky",Lighting)
		sky.SkyboxBk=aid; sky.SkyboxDn=aid; sky.SkyboxFt=aid
		sky.SkyboxLf=aid; sky.SkyboxRt=aid; sky.SkyboxUp=aid
		res.Text="Применено: "..id; res.TextColor3=Color3.fromRGB(90,220,110)
	end)

	card(contentArea,"Убрать Sky","Вернуть стандартное небо",202,function()
		local old=Lighting:FindFirstChildOfClass("Sky"); if old then old:Destroy() end
		res.Text="Sky сброшен"; res.TextColor3=Color3.fromRGB(90,90,90)
	end)
end

local function buildToolsPage()
	clearContent()
	contentArea.CanvasSize=UDim2.new(0,0,0,520)
	hdr(contentArea,"TOOLS","Reach, FOV и Commands",14)
	divLine(contentArea,55)

	-- ── REACH ──
	local reachLbl=Instance.new("TextLabel",contentArea)
	reachLbl.Size=UDim2.new(1,-28,0,16); reachLbl.Position=UDim2.new(0,14,0,64)
	reachLbl.BackgroundTransparency=1; reachLbl.Text="REACH"
	reachLbl.TextColor3=Color3.fromRGB(60,60,60); reachLbl.TextSize=10
	reachLbl.Font=Enum.Font.GothamBold; reachLbl.TextXAlignment=Enum.TextXAlignment.Left

	local reachActive=false
	local reachCard=Instance.new("Frame",contentArea)
	reachCard.Size=UDim2.new(1,-28,0,50); reachCard.Position=UDim2.new(0,14,0,84)
	reachCard.BackgroundColor3=Color3.fromRGB(14,14,14); reachCard.BorderSizePixel=0
	Instance.new("UICorner",reachCard).CornerRadius=UDim.new(0,10)
	Instance.new("UIStroke",reachCard).Color=Color3.fromRGB(30,30,30)

	local rtl=Instance.new("TextLabel",reachCard)
	rtl.Size=UDim2.new(1,-80,0,20); rtl.Position=UDim2.new(0,12,0,8)
	rtl.BackgroundTransparency=1; rtl.Text="Free Gamepass Reach"
	rtl.TextColor3=Color3.fromRGB(225,225,225); rtl.TextSize=13
	rtl.Font=Enum.Font.GothamSemibold; rtl.TextXAlignment=Enum.TextXAlignment.Left

	local rsl=Instance.new("TextLabel",reachCard)
	rsl.Size=UDim2.new(1,-80,0,14); rsl.Position=UDim2.new(0,12,0,29)
	rsl.BackgroundTransparency=1; rsl.Text="Дальность граба без геймпасса"
	rsl.TextColor3=Color3.fromRGB(60,60,60); rsl.TextSize=11
	rsl.Font=Enum.Font.Gotham; rsl.TextXAlignment=Enum.TextXAlignment.Left

	local rtog=Instance.new("TextButton",reachCard)
	rtog.Size=UDim2.new(0,46,0,24); rtog.Position=UDim2.new(1,-58,0.5,-12)
	rtog.BackgroundColor3=Color3.fromRGB(38,38,38); rtog.BorderSizePixel=0
	rtog.Text=""; rtog.AutoButtonColor=false
	Instance.new("UICorner",rtog).CornerRadius=UDim.new(1,0)
	local rknob=Instance.new("Frame",rtog); rknob.Size=UDim2.new(0,18,0,18)
	rknob.Position=UDim2.new(0,3,0.5,-9); rknob.BackgroundColor3=Color3.fromRGB(110,110,110)
	rknob.BorderSizePixel=0; Instance.new("UICorner",rknob).CornerRadius=UDim.new(1,0)

	rtog.MouseButton1Click:Connect(function()
		reachActive=not reachActive
		TweenService:Create(rtog,TIF,{BackgroundColor3=reachActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(38,38,38)}):Play()
		TweenService:Create(rknob,TIF,{
			Position=reachActive and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
			BackgroundColor3=reachActive and Color3.fromRGB(0,0,0) or Color3.fromRGB(110,110,110)
		}):Play()
		if reachActive then
			pcall(function()
				loadstring(game:HttpGet("https://rawscripts.net/raw/Fling-Things-and-People-Free-Gamepass-80386"))()
			end)
		end
	end)

	-- ── FOV ──
	local fovLbl=Instance.new("TextLabel",contentArea)
	fovLbl.Size=UDim2.new(1,-28,0,16); fovLbl.Position=UDim2.new(0,14,0,148)
	fovLbl.BackgroundTransparency=1; fovLbl.Text="FOV"
	fovLbl.TextColor3=Color3.fromRGB(60,60,60); fovLbl.TextSize=10
	fovLbl.Font=Enum.Font.GothamBold; fovLbl.TextXAlignment=Enum.TextXAlignment.Left

	-- FOV слайдер карточка
	local fovCard=Instance.new("Frame",contentArea)
	fovCard.Size=UDim2.new(1,-28,0,76); fovCard.Position=UDim2.new(0,14,0,168)
	fovCard.BackgroundColor3=Color3.fromRGB(14,14,14); fovCard.BorderSizePixel=0
	Instance.new("UICorner",fovCard).CornerRadius=UDim.new(0,10)
	Instance.new("UIStroke",fovCard).Color=Color3.fromRGB(30,30,30)

	local fovTitle=Instance.new("TextLabel",fovCard)
	fovTitle.Size=UDim2.new(1,-70,0,18); fovTitle.Position=UDim2.new(0,12,0,8)
	fovTitle.BackgroundTransparency=1; fovTitle.Text="Field of View"
	fovTitle.TextColor3=Color3.fromRGB(225,225,225); fovTitle.TextSize=13
	fovTitle.Font=Enum.Font.GothamSemibold; fovTitle.TextXAlignment=Enum.TextXAlignment.Left

	local fovValLbl=Instance.new("TextLabel",fovCard)
	fovValLbl.Size=UDim2.new(0,55,0,18); fovValLbl.Position=UDim2.new(1,-65,0,8)
	fovValLbl.BackgroundTransparency=1
	fovValLbl.Text=tostring(math.floor(workspace.CurrentCamera.FieldOfView))
	fovValLbl.TextColor3=Color3.fromRGB(255,255,255); fovValLbl.TextSize=13
	fovValLbl.Font=Enum.Font.GothamBold; fovValLbl.TextXAlignment=Enum.TextXAlignment.Right

	-- Слайдер
	local fovTrack=Instance.new("Frame",fovCard)
	fovTrack.Size=UDim2.new(1,-24,0,6); fovTrack.Position=UDim2.new(0,12,0,40)
	fovTrack.BackgroundColor3=Color3.fromRGB(36,36,36); fovTrack.BorderSizePixel=0
	Instance.new("UICorner",fovTrack).CornerRadius=UDim.new(1,0)

	local defaultFov=workspace.CurrentCamera.FieldOfView
	local fovRatio=math.clamp((defaultFov-30)/(150-30),0,1)

	local fovFill=Instance.new("Frame",fovTrack)
	fovFill.Size=UDim2.new(fovRatio,0,1,0)
	fovFill.BackgroundColor3=Color3.fromRGB(255,255,255); fovFill.BorderSizePixel=0
	Instance.new("UICorner",fovFill).CornerRadius=UDim.new(1,0)

	local fovHandle=Instance.new("TextButton",fovTrack)
	fovHandle.Size=UDim2.new(0,16,0,16); fovHandle.Position=UDim2.new(fovRatio,-8,0.5,-8)
	fovHandle.BackgroundColor3=Color3.fromRGB(255,255,255); fovHandle.BorderSizePixel=0
	fovHandle.Text=""; fovHandle.AutoButtonColor=false; fovHandle.ZIndex=5
	Instance.new("UICorner",fovHandle).CornerRadius=UDim.new(1,0)
	local fhs=Instance.new("UIStroke",fovHandle); fhs.Color=Color3.fromRGB(0,0,0); fhs.Thickness=2; fhs.Transparency=0.6

	-- Быстрые кнопки FOV
	local presetRow=Instance.new("Frame",fovCard)
	presetRow.Size=UDim2.new(1,-24,0,18); presetRow.Position=UDim2.new(0,12,0,56)
	presetRow.BackgroundTransparency=1

	local fovPresets={{"70",70},{"90",90},{"110",110},{"130",130},{"150",150}}
	for i,fp in ipairs(fovPresets) do
		local pb=Instance.new("TextButton",presetRow)
		pb.Size=UDim2.new(0,38,0,18); pb.Position=UDim2.new(0,(i-1)*46,0,0)
		pb.BackgroundColor3=Color3.fromRGB(28,28,28); pb.BorderSizePixel=0
		pb.Text=fp[1]; pb.TextColor3=Color3.fromRGB(160,160,160)
		pb.TextSize=11; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,6)
		pb.MouseButton1Click:Connect(function()
			local v=fp[2]
			workspace.CurrentCamera.FieldOfView=v
			fovValLbl.Text=tostring(v)
			local r=math.clamp((v-30)/(150-30),0,1)
			fovFill.Size=UDim2.new(r,0,1,0)
			fovHandle.Position=UDim2.new(r,-8,0.5,-8)
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(42,42,42)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(28,28,28)}):Play() end)
	end

	-- Сброс FOV
	local fovReset=Instance.new("TextButton",contentArea)
	fovReset.Size=UDim2.new(1,-28,0,32); fovReset.Position=UDim2.new(0,14,0,252)
	fovReset.BackgroundColor3=Color3.fromRGB(18,18,18); fovReset.BorderSizePixel=0
	fovReset.Text="Сбросить FOV (70)"; fovReset.TextColor3=Color3.fromRGB(120,120,120)
	fovReset.TextSize=12; fovReset.Font=Enum.Font.GothamSemibold; fovReset.AutoButtonColor=false
	Instance.new("UICorner",fovReset).CornerRadius=UDim.new(0,8)
	fovReset.MouseButton1Click:Connect(function()
		workspace.CurrentCamera.FieldOfView=70
		fovValLbl.Text="70"
		local r=math.clamp((70-30)/(150-30),0,1)
		fovFill.Size=UDim2.new(r,0,1,0)
		fovHandle.Position=UDim2.new(r,-8,0.5,-8)
	end)

	-- FOV drag
	local fovDragging=false
	fovHandle.MouseButton1Down:Connect(function() fovDragging=true end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then fovDragging=false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if fovDragging and i.UserInputType==Enum.UserInputType.MouseMovement then
			local tx=fovTrack.AbsolutePosition.X
			local tw=fovTrack.AbsoluteSize.X
			local rel=math.clamp((i.Position.X-tx)/tw,0,1)
			local val=math.floor(30+rel*(150-30))
			fovFill.Size=UDim2.new(rel,0,1,0)
			fovHandle.Position=UDim2.new(rel,-8,0.5,-8)
			fovValLbl.Text=tostring(val)
			workspace.CurrentCamera.FieldOfView=val
		end
	end)

	-- ── COMMANDS ──
	local cmdLbl=Instance.new("TextLabel",contentArea)
	cmdLbl.Size=UDim2.new(1,-28,0,16); cmdLbl.Position=UDim2.new(0,14,0,298)
	cmdLbl.BackgroundTransparency=1; cmdLbl.Text="COMMANDS"
	cmdLbl.TextColor3=Color3.fromRGB(60,60,60); cmdLbl.TextSize=10
	cmdLbl.Font=Enum.Font.GothamBold; cmdLbl.TextXAlignment=Enum.TextXAlignment.Left

	local cmdActive=false
	local cmdCard=Instance.new("Frame",contentArea)
	cmdCard.Size=UDim2.new(1,-28,0,50); cmdCard.Position=UDim2.new(0,14,0,318)
	cmdCard.BackgroundColor3=Color3.fromRGB(14,14,14); cmdCard.BorderSizePixel=0
	Instance.new("UICorner",cmdCard).CornerRadius=UDim.new(0,10)
	Instance.new("UIStroke",cmdCard).Color=Color3.fromRGB(30,30,30)

	local ctl=Instance.new("TextLabel",cmdCard)
	ctl.Size=UDim2.new(1,-80,0,20); ctl.Position=UDim2.new(0,12,0,8)
	ctl.BackgroundTransparency=1; ctl.Text="Infinity Yield Commands"
	ctl.TextColor3=Color3.fromRGB(225,225,225); ctl.TextSize=13
	ctl.Font=Enum.Font.GothamSemibold; ctl.TextXAlignment=Enum.TextXAlignment.Left

	local csl=Instance.new("TextLabel",cmdCard)
	csl.Size=UDim2.new(1,-80,0,14); csl.Position=UDim2.new(0,12,0,29)
	csl.BackgroundTransparency=1; csl.Text="Universal admin commands"
	csl.TextColor3=Color3.fromRGB(60,60,60); csl.TextSize=11
	csl.Font=Enum.Font.Gotham; csl.TextXAlignment=Enum.TextXAlignment.Left

	local ctog=Instance.new("TextButton",cmdCard)
	ctog.Size=UDim2.new(0,46,0,24); ctog.Position=UDim2.new(1,-58,0.5,-12)
	ctog.BackgroundColor3=Color3.fromRGB(38,38,38); ctog.BorderSizePixel=0
	ctog.Text=""; ctog.AutoButtonColor=false
	Instance.new("UICorner",ctog).CornerRadius=UDim.new(1,0)
	local cknob=Instance.new("Frame",ctog); cknob.Size=UDim2.new(0,18,0,18)
	cknob.Position=UDim2.new(0,3,0.5,-9); cknob.BackgroundColor3=Color3.fromRGB(110,110,110)
	cknob.BorderSizePixel=0; Instance.new("UICorner",cknob).CornerRadius=UDim.new(1,0)

	local cmdStatusLbl=Instance.new("TextLabel",contentArea)
	cmdStatusLbl.Size=UDim2.new(1,-28,0,20); cmdStatusLbl.Position=UDim2.new(0,16,0,374)
	cmdStatusLbl.BackgroundTransparency=1; cmdStatusLbl.Text=""
	cmdStatusLbl.TextColor3=Color3.fromRGB(80,200,100); cmdStatusLbl.TextSize=11
	cmdStatusLbl.Font=Enum.Font.GothamSemibold; cmdStatusLbl.TextXAlignment=Enum.TextXAlignment.Left

	ctog.MouseButton1Click:Connect(function()
		if cmdActive then return end -- загружается только раз
		cmdActive=true
		TweenService:Create(ctog,TIF,{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
		TweenService:Create(cknob,TIF,{
			Position=UDim2.new(1,-21,0.5,-9),
			BackgroundColor3=Color3.fromRGB(0,0,0)
		}):Play()
		cmdStatusLbl.Text="Загружается..."
		cmdStatusLbl.TextColor3=Color3.fromRGB(160,160,160)
		task.spawn(function()
			local ok,err=pcall(function()
				loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Infinity-Yield-94242"))()
			end)
			if ok then
				cmdStatusLbl.Text="Infinity Yield загружен!"
				cmdStatusLbl.TextColor3=Color3.fromRGB(80,200,100)
			else
				cmdStatusLbl.Text="Ошибка загрузки"
				cmdStatusLbl.TextColor3=Color3.fromRGB(255,70,70)
				cmdActive=false
				TweenService:Create(ctog,TIF,{BackgroundColor3=Color3.fromRGB(38,38,38)}):Play()
				TweenService:Create(cknob,TIF,{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(110,110,110)}):Play()
			end
		end)
	end)
end

local function makeToggleCard(parent, title, sub, y, state, callback)
	local f=Instance.new("Frame",parent)
	f.Size=UDim2.new(1,-28,0,50); f.Position=UDim2.new(0,14,0,y)
	f.BackgroundColor3=Color3.fromRGB(14,14,14); f.BorderSizePixel=0
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
	Instance.new("UIStroke",f).Color=Color3.fromRGB(30,30,30)
	local tl=Instance.new("TextLabel",f)
	tl.Size=UDim2.new(1,-80,0,20); tl.Position=UDim2.new(0,12,0,8)
	tl.BackgroundTransparency=1; tl.Text=title
	tl.TextColor3=Color3.fromRGB(225,225,225); tl.TextSize=13
	tl.Font=Enum.Font.GothamSemibold; tl.TextXAlignment=Enum.TextXAlignment.Left
	if sub then
		local sl=Instance.new("TextLabel",f)
		sl.Size=UDim2.new(1,-80,0,14); sl.Position=UDim2.new(0,12,0,29)
		sl.BackgroundTransparency=1; sl.Text=sub
		sl.TextColor3=Color3.fromRGB(60,60,60); sl.TextSize=11
		sl.Font=Enum.Font.Gotham; sl.TextXAlignment=Enum.TextXAlignment.Left
	end
	local tog=Instance.new("TextButton",f)
	tog.Size=UDim2.new(0,46,0,24); tog.Position=UDim2.new(1,-58,0.5,-12)
	tog.BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(38,38,38)
	tog.BorderSizePixel=0; tog.Text=""; tog.AutoButtonColor=false
	Instance.new("UICorner",tog).CornerRadius=UDim.new(1,0)
	local knob=Instance.new("Frame",tog); knob.Size=UDim2.new(0,18,0,18)
	knob.Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
	knob.BackgroundColor3=state and Color3.fromRGB(0,0,0) or Color3.fromRGB(120,120,120)
	knob.BorderSizePixel=0; Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
	local cur=state
	tog.MouseButton1Click:Connect(function()
		cur=not cur
		TweenService:Create(tog,TIF,{BackgroundColor3=cur and Color3.fromRGB(255,255,255) or Color3.fromRGB(38,38,38)}):Play()
		TweenService:Create(knob,TIF,{
			Position=cur and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
			BackgroundColor3=cur and Color3.fromRGB(0,0,0) or Color3.fromRGB(120,120,120)
		}):Play()
		callback(cur)
	end)
	return f, tog, knob
end

local speedActive = false
local espActive = false
local noclipActive = false
-- ESP управляется через espBillboards и espBoxes выше

local function buildSpeedPage()
	clearContent()
	contentArea.CanvasSize=UDim2.new(0,0,0,420)
	hdr(contentArea,"SPEED","Скорость персонажа",14)
	divLine(contentArea,55)

	local speedVal = 16
	local speedCard=Instance.new("Frame",contentArea)
	speedCard.Size=UDim2.new(1,-28,0,76); speedCard.Position=UDim2.new(0,14,0,64)
	speedCard.BackgroundColor3=Color3.fromRGB(14,14,14); speedCard.BorderSizePixel=0
	Instance.new("UICorner",speedCard).CornerRadius=UDim.new(0,10)
	Instance.new("UIStroke",speedCard).Color=Color3.fromRGB(30,30,30)

	local stl=Instance.new("TextLabel",speedCard)
	stl.Size=UDim2.new(1,-70,0,18); stl.Position=UDim2.new(0,12,0,8)
	stl.BackgroundTransparency=1; stl.Text="WalkSpeed"
	stl.TextColor3=Color3.fromRGB(225,225,225); stl.TextSize=13
	stl.Font=Enum.Font.GothamSemibold; stl.TextXAlignment=Enum.TextXAlignment.Left

	local sValLbl=Instance.new("TextLabel",speedCard)
	sValLbl.Size=UDim2.new(0,55,0,18); sValLbl.Position=UDim2.new(1,-65,0,8)
	sValLbl.BackgroundTransparency=1; sValLbl.Text="16"
	sValLbl.TextColor3=Color3.fromRGB(255,255,255); sValLbl.TextSize=13
	sValLbl.Font=Enum.Font.GothamBold; sValLbl.TextXAlignment=Enum.TextXAlignment.Right

	local sTrack=Instance.new("Frame",speedCard)
	sTrack.Size=UDim2.new(1,-24,0,6); sTrack.Position=UDim2.new(0,12,0,40)
	sTrack.BackgroundColor3=Color3.fromRGB(36,36,36); sTrack.BorderSizePixel=0
	Instance.new("UICorner",sTrack).CornerRadius=UDim.new(1,0)

	local sRatio=(16-16)/(300-16)
	local sFill=Instance.new("Frame",sTrack); sFill.Size=UDim2.new(sRatio,0,1,0)
	sFill.BackgroundColor3=Color3.fromRGB(255,255,255); sFill.BorderSizePixel=0
	Instance.new("UICorner",sFill).CornerRadius=UDim.new(1,0)

	local sHandle=Instance.new("TextButton",sTrack)
	sHandle.Size=UDim2.new(0,16,0,16); sHandle.Position=UDim2.new(sRatio,-8,0.5,-8)
	sHandle.BackgroundColor3=Color3.fromRGB(255,255,255); sHandle.BorderSizePixel=0
	sHandle.Text=""; sHandle.AutoButtonColor=false; sHandle.ZIndex=5
	Instance.new("UICorner",sHandle).CornerRadius=UDim.new(1,0)

	local sDragging=false
	sHandle.MouseButton1Down:Connect(function() sDragging=true end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then sDragging=false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if sDragging and i.UserInputType==Enum.UserInputType.MouseMovement then
			local tx=sTrack.AbsolutePosition.X; local tw=sTrack.AbsoluteSize.X
			local rel=math.clamp((i.Position.X-tx)/tw,0,1)
			local val=math.floor(16+rel*(300-16))
			sFill.Size=UDim2.new(rel,0,1,0); sHandle.Position=UDim2.new(rel,-8,0.5,-8)
			sValLbl.Text=tostring(val); speedVal=val
			local char=player.Character
			if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=val end end
		end
	end)

	-- Пресеты
	local presets2={{"Норм",16},{"Быстро",50},{"Очень",100},{"Турбо",250}}
	for i,sp in ipairs(presets2) do
		local pb=Instance.new("TextButton",contentArea)
		pb.Size=UDim2.new(0,118,0,38); pb.Position=UDim2.new(0,14+(i-1)%2*136,0,152+math.floor((i-1)/2)*46)
		pb.BackgroundColor3=Color3.fromRGB(16,16,16); pb.BorderSizePixel=0
		pb.Text=sp[1].."  ("..sp[2]..")"; pb.TextColor3=Color3.fromRGB(190,190,190)
		pb.TextSize=12; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,9)
		Instance.new("UIStroke",pb).Color=Color3.fromRGB(30,30,30)
		pb.MouseButton1Click:Connect(function()
			local char=player.Character
			if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=sp[2] end end
			sValLbl.Text=tostring(sp[2])
			local rel=(sp[2]-16)/(300-16)
			sFill.Size=UDim2.new(math.clamp(rel,0,1),0,1,0)
			sHandle.Position=UDim2.new(math.clamp(rel,0,1),-8,0.5,-8)
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
	end

	-- JumpPower
	local jumpLbl=Instance.new("TextLabel",contentArea)
	jumpLbl.Size=UDim2.new(1,-28,0,16); jumpLbl.Position=UDim2.new(0,14,0,250)
	jumpLbl.BackgroundTransparency=1; jumpLbl.Text="ПРЫЖОК"
	jumpLbl.TextColor3=Color3.fromRGB(60,60,60); jumpLbl.TextSize=10
	jumpLbl.Font=Enum.Font.GothamBold; jumpLbl.TextXAlignment=Enum.TextXAlignment.Left

	local jPresets={{"Норм",50},{"Высоко",100},{"Луна",200},{"Космос",500}}
	for i,jp in ipairs(jPresets) do
		local pb=Instance.new("TextButton",contentArea)
		pb.Size=UDim2.new(0,118,0,38); pb.Position=UDim2.new(0,14+(i-1)%2*136,0,272+math.floor((i-1)/2)*46)
		pb.BackgroundColor3=Color3.fromRGB(16,16,16); pb.BorderSizePixel=0
		pb.Text=jp[1].."  ("..jp[2]..")"; pb.TextColor3=Color3.fromRGB(190,190,190)
		pb.TextSize=12; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,9)
		Instance.new("UIStroke",pb).Color=Color3.fromRGB(30,30,30)
		pb.MouseButton1Click:Connect(function()
			local char=player.Character
			if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower=jp[2] end end
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
	end
end

-- ESP данные
local espColor = Color3.fromRGB(255,255,255)
local espTargetOnly = nil -- имя игрока для таргет ESP, nil = все
local espBillboards = {} -- BillboardGui над головами
local espBoxes = {}      -- SelectionBox боксы
local espUpdateConn = nil

local function removeAllEsp()
	for _,v in pairs(espBillboards) do pcall(function() v:Destroy() end) end
	for _,v in pairs(espBoxes) do pcall(function() v:Destroy() end) end
	espBillboards={}; espBoxes={}
end

local function createEspForPlayer(p)
	if not p.Character then return end
	local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	local head=p.Character:FindFirstChild("Head")

	-- SelectionBox бокс
	local box=Instance.new("SelectionBox")
	box.Color3=espColor; box.LineThickness=0.04
	box.SurfaceTransparency=0.92; box.SurfaceColor3=espColor
	box.Adornee=p.Character; box.Parent=workspace
	espBoxes[p.Name]=box

	-- BillboardGui над головой
	local bb=Instance.new("BillboardGui")
	bb.Name="EspBB_"..p.Name
	bb.Size=UDim2.new(0,170,0,58)
	bb.StudsOffset=Vector3.new(0,3.2,0)
	bb.AlwaysOnTop=true
	bb.MaxDistance=500
	bb.Adornee=head or hrp
	bb.Parent=workspace

	-- Фон карточки
	local bg=Instance.new("Frame",bb)
	bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(6,6,6)
	bg.BackgroundTransparency=0.25; bg.BorderSizePixel=0
	Instance.new("UICorner",bg).CornerRadius=UDim.new(0,8)
	local bgs=Instance.new("UIStroke",bg); bgs.Color=espColor; bgs.Thickness=1.5; bgs.Transparency=0.3

	-- Аватар (цветной квадрат с инициалом — Roblox не даёт грузить аватар без HttpService)
	local avatarBox=Instance.new("Frame",bg)
	avatarBox.Size=UDim2.new(0,40,0,40); avatarBox.Position=UDim2.new(0,6,0.5,-20)
	avatarBox.BackgroundColor3=espColor; avatarBox.BackgroundTransparency=0.7; avatarBox.BorderSizePixel=0
	Instance.new("UICorner",avatarBox).CornerRadius=UDim.new(0,6)
	local avatarLbl=Instance.new("TextLabel",avatarBox)
	avatarLbl.Size=UDim2.new(1,0,1,0); avatarLbl.BackgroundTransparency=1
	avatarLbl.Text=string.upper(string.sub(p.Name,1,2))
	avatarLbl.TextColor3=Color3.fromRGB(255,255,255); avatarLbl.TextSize=16
	avatarLbl.Font=Enum.Font.GothamBold

	-- Имя игрока
	local nameLbl=Instance.new("TextLabel",bg)
	nameLbl.Size=UDim2.new(1,-56,0,18); nameLbl.Position=UDim2.new(0,52,0,7)
	nameLbl.BackgroundTransparency=1; nameLbl.Text=p.Name
	nameLbl.TextColor3=Color3.fromRGB(255,255,255); nameLbl.TextSize=13
	nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
	nameLbl.TextTruncate=Enum.TextTruncate.AtEnd

	-- Дистанция
	local distLbl=Instance.new("TextLabel",bg)
	distLbl.Name="DistLbl"; distLbl.Size=UDim2.new(1,-56,0,14)
	distLbl.Position=UDim2.new(0,52,0,28); distLbl.BackgroundTransparency=1
	distLbl.Text="-- м"; distLbl.TextColor3=Color3.fromRGB(160,160,160)
	distLbl.TextSize=11; distLbl.Font=Enum.Font.Gotham; distLbl.TextXAlignment=Enum.TextXAlignment.Left

	-- HP бар
	local hpBg=Instance.new("Frame",bg)
	hpBg.Size=UDim2.new(1,-56,0,4); hpBg.Position=UDim2.new(0,52,0,45)
	hpBg.BackgroundColor3=Color3.fromRGB(35,35,35); hpBg.BorderSizePixel=0
	Instance.new("UICorner",hpBg).CornerRadius=UDim.new(1,0)
	local hpFill=Instance.new("Frame",hpBg)
	hpFill.Name="HpFill"; hpFill.Size=UDim2.new(1,0,1,0)
	hpFill.BackgroundColor3=Color3.fromRGB(80,220,100); hpFill.BorderSizePixel=0
	Instance.new("UICorner",hpFill).CornerRadius=UDim.new(1,0)

	espBillboards[p.Name]=bb
end

local function rebuildEsp()
	removeAllEsp()
	if not espActive then return end
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=player then
			if espTargetOnly==nil or espTargetOnly==p.Name then
				createEspForPlayer(p)
			elseif espTargetOnly~=nil then
				-- остальные — просто тонкий бокс без карточки
				if p.Character then
					local box=Instance.new("SelectionBox")
					box.Color3=Color3.fromRGB(50,50,50); box.LineThickness=0.02
					box.SurfaceTransparency=0.98; box.Adornee=p.Character; box.Parent=workspace
					espBoxes[p.Name.."_dim"]=box
				end
			end
		end
	end
end

-- Обновление дистанции и HP каждые 0.5 сек
task.spawn(function()
	while true do
		task.wait(0.5)
		if not espActive then continue end
		local myChar=player.Character; if not myChar then continue end
		local myHrp=myChar:FindFirstChild("HumanoidRootPart"); if not myHrp then continue end
		for pname,bb in pairs(espBillboards) do
			local p=Players:FindFirstChild(pname)
			if p and p.Character then
				local hrp=p.Character:FindFirstChild("HumanoidRootPart")
				local hum=p.Character:FindFirstChildOfClass("Humanoid")
				if hrp then
					local dist=math.floor((myHrp.Position-hrp.Position).Magnitude)
					local distLbl=bb:FindFirstChild("Frame") and bb.Frame:FindFirstChild("DistLbl")
					if distLbl then distLbl.Text=tostring(dist).." м" end
				end
				if hum then
					local ratio=math.clamp(hum.Health/hum.MaxHealth,0,1)
					local hpFill=bb:FindFirstChild("Frame") and bb.Frame:FindFirstChild("HpFill")
					-- ищем через descendants
					for _,d in ipairs(bb:GetDescendants()) do
						if d.Name=="HpFill" then
							d.Size=UDim2.new(ratio,0,1,0)
							d.BackgroundColor3=ratio>0.6 and Color3.fromRGB(80,220,100) or ratio>0.3 and Color3.fromRGB(240,180,40) or Color3.fromRGB(240,60,60)
						end
					end
				end
			else
				pcall(function() espBillboards[pname]:Destroy() end)
				espBillboards[pname]=nil
			end
		end
	end
end)

local function buildEspPage()
	clearContent()
	contentArea.CanvasSize=UDim2.new(0,0,0,600)
	hdr(contentArea,"ESP","Карточки игроков над головой",14)
	divLine(contentArea,55)

	-- Главный тоггл
	makeToggleCard(contentArea,"ESP включить","Карточки + боксы над всеми игроками",64,espActive,function(v)
		espActive=v
		rebuildEsp()
	end)

	-- Цвет
	local colorSect=Instance.new("TextLabel",contentArea)
	colorSect.Size=UDim2.new(1,-28,0,16); colorSect.Position=UDim2.new(0,14,0,128)
	colorSect.BackgroundTransparency=1; colorSect.Text="ЦВЕТ"
	colorSect.TextColor3=Color3.fromRGB(60,60,60); colorSect.TextSize=10
	colorSect.Font=Enum.Font.GothamBold; colorSect.TextXAlignment=Enum.TextXAlignment.Left

	local colors={
		{"Белый",Color3.fromRGB(255,255,255)},
		{"Красный",Color3.fromRGB(255,60,60)},
		{"Зелёный",Color3.fromRGB(60,230,90)},
		{"Синий",Color3.fromRGB(60,130,255)},
		{"Жёлтый",Color3.fromRGB(255,215,45)},
		{"Фиолет",Color3.fromRGB(185,60,255)},
	}
	for i,col in ipairs(colors) do
		local cb=Instance.new("TextButton",contentArea)
		cb.Size=UDim2.new(0,86,0,32); cb.Position=UDim2.new(0,14+(i-1)%3*98,0,148+math.floor((i-1)/3)*40)
		cb.BackgroundColor3=Color3.fromRGB(14,14,14); cb.BorderSizePixel=0
		cb.Text=col[1]; cb.TextColor3=Color3.fromRGB(185,185,185)
		cb.TextSize=12; cb.Font=Enum.Font.GothamSemibold; cb.AutoButtonColor=false
		Instance.new("UICorner",cb).CornerRadius=UDim.new(0,8)
		local stripe=Instance.new("Frame",cb); stripe.Size=UDim2.new(0,3,0.55,0)
		stripe.Position=UDim2.new(0,0,0.22,0); stripe.BackgroundColor3=col[2]; stripe.BorderSizePixel=0
		Instance.new("UICorner",stripe).CornerRadius=UDim.new(1,0)
		cb.MouseButton1Click:Connect(function()
			espColor=col[2]
			for _,box in pairs(espBoxes) do pcall(function() box.Color3=col[2]; box.SurfaceColor3=col[2] end) end
			for _,bb in pairs(espBillboards) do
				pcall(function()
					for _,d in ipairs(bb:GetDescendants()) do
						if d:IsA("UIStroke") then d.Color=col[2] end
						if d:IsA("Frame") and d.Name~="HpFill" and d.Parent:IsA("BillboardGui") then
							d.BackgroundTransparency=0.7
						end
					end
				end)
			end
			TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(28,28,28)}):Play()
			task.delay(0.2,function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(14,14,14)}):Play() end)
		end)
		cb.MouseEnter:Connect(function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(22,22,22)}):Play() end)
		cb.MouseLeave:Connect(function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(14,14,14)}):Play() end)
	end

	-- Таргет ESP
	local targetSect=Instance.new("TextLabel",contentArea)
	targetSect.Size=UDim2.new(1,-28,0,16); targetSect.Position=UDim2.new(0,14,0,242)
	targetSect.BackgroundTransparency=1; targetSect.Text="ВЫБРАТЬ ЦЕЛЬ"
	targetSect.TextColor3=Color3.fromRGB(60,60,60); targetSect.TextSize=10
	targetSect.Font=Enum.Font.GothamBold; targetSect.TextXAlignment=Enum.TextXAlignment.Left

	-- Кнопка "Все игроки"
	local allBtn=Instance.new("TextButton",contentArea)
	allBtn.Size=UDim2.new(1,-28,0,36); allBtn.Position=UDim2.new(0,14,0,262)
	allBtn.BackgroundColor3=espTargetOnly==nil and Color3.fromRGB(255,255,255) or Color3.fromRGB(14,14,14)
	allBtn.BorderSizePixel=0
	allBtn.Text="  Все игроки"; allBtn.TextColor3=espTargetOnly==nil and Color3.fromRGB(0,0,0) or Color3.fromRGB(160,160,160)
	allBtn.TextSize=13; allBtn.Font=Enum.Font.GothamSemibold; allBtn.TextXAlignment=Enum.TextXAlignment.Left
	allBtn.AutoButtonColor=false
	Instance.new("UICorner",allBtn).CornerRadius=UDim.new(0,9)
	allBtn.MouseButton1Click:Connect(function()
		espTargetOnly=nil
		rebuildEsp()
		buildEspPage() -- перестроить для обновления UI
	end)

	-- Список игроков
	local yOff=306
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=player then
			local isTarget=espTargetOnly==p.Name
			local pb=Instance.new("TextButton",contentArea)
			pb.Size=UDim2.new(1,-28,0,46); pb.Position=UDim2.new(0,14,0,yOff)
			pb.BackgroundColor3=isTarget and Color3.fromRGB(22,22,22) or Color3.fromRGB(12,12,12)
			pb.BorderSizePixel=0; pb.Text=""; pb.AutoButtonColor=false
			Instance.new("UICorner",pb).CornerRadius=UDim.new(0,10)
			local pbs=Instance.new("UIStroke",pb)
			pbs.Color=isTarget and Color3.fromRGB(200,200,200) or Color3.fromRGB(28,28,28); pbs.Thickness=1

			-- Аватар-инициал
			local av=Instance.new("Frame",pb); av.Size=UDim2.new(0,32,0,32); av.Position=UDim2.new(0,8,0.5,-16)
			av.BackgroundColor3=Color3.fromRGB(30,30,30); av.BorderSizePixel=0
			Instance.new("UICorner",av).CornerRadius=UDim.new(0,8)
			local avl=Instance.new("TextLabel",av); avl.Size=UDim2.new(1,0,1,0); avl.BackgroundTransparency=1
			avl.Text=string.upper(string.sub(p.Name,1,2)); avl.TextColor3=Color3.fromRGB(220,220,220)
			avl.TextSize=13; avl.Font=Enum.Font.GothamBold

			-- Имя
			local nl=Instance.new("TextLabel",pb); nl.Size=UDim2.new(1,-90,0,18); nl.Position=UDim2.new(0,48,0,7)
			nl.BackgroundTransparency=1; nl.Text=p.Name
			nl.TextColor3=Color3.fromRGB(230,230,230); nl.TextSize=13
			nl.Font=Enum.Font.GothamSemibold; nl.TextXAlignment=Enum.TextXAlignment.Left
			nl.TextTruncate=Enum.TextTruncate.AtEnd

			-- Дистанция
			local myHrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local pHrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			local distTxt="-- м"
			if myHrp and pHrp then
				distTxt=tostring(math.floor((myHrp.Position-pHrp.Position).Magnitude)).." м"
			end
			local dl=Instance.new("TextLabel",pb); dl.Size=UDim2.new(1,-90,0,14); dl.Position=UDim2.new(0,48,0,27)
			dl.BackgroundTransparency=1; dl.Text=distTxt
			dl.TextColor3=Color3.fromRGB(80,80,80); dl.TextSize=11
			dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left

			-- Индикатор "таргет"
			if isTarget then
				local dot=Instance.new("Frame",pb); dot.Size=UDim2.new(0,6,0,6)
				dot.Position=UDim2.new(1,-16,0.5,-3); dot.BackgroundColor3=Color3.fromRGB(255,255,255)
				dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
			end

			pb.MouseButton1Click:Connect(function()
				if espTargetOnly==p.Name then
					espTargetOnly=nil
				else
					espTargetOnly=p.Name
				end
				rebuildEsp()
				buildEspPage()
			end)
			pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(20,20,20)}):Play() end)
			pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=isTarget and Color3.fromRGB(22,22,22) or Color3.fromRGB(12,12,12)}):Play() end)

			yOff=yOff+54
		end
	end

	contentArea.CanvasSize=UDim2.new(0,0,0,yOff+20)

	-- Обновление списка при входе новых игроков
	Players.PlayerAdded:Connect(function()
		task.wait(1)
		if espActive then rebuildEsp() end
		buildEspPage()
	end)
	Players.PlayerRemoving:Connect(function(p)
		pcall(function()
			if espBillboards[p.Name] then espBillboards[p.Name]:Destroy(); espBillboards[p.Name]=nil end
			if espBoxes[p.Name] then espBoxes[p.Name]:Destroy(); espBoxes[p.Name]=nil end
		end)
		buildEspPage()
	end)
end

local function buildNoclipPage()
	clearContent()
	contentArea.CanvasSize=UDim2.new(0,0,0,340)
	hdr(contentArea,"NOCLIP","Проходить сквозь стены",14)
	divLine(contentArea,55)

	local ncConn=nil

	local function applyNoclip(state)
		noclipActive=state
		if ncConn then ncConn:Disconnect(); ncConn=nil end
		if state then
			ncConn=RunService.Stepped:Connect(function()
				local char=player.Character; if not char then return end
				for _,p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") and p.CanCollide then
						p.CanCollide=false
					end
				end
			end)
		else
			local char=player.Character; if not char then return end
			for _,p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide=true end
			end
		end
	end

	makeToggleCard(contentArea,"NoClip","Проходить сквозь всё",64,noclipActive,function(v)
		applyNoclip(v)
	end)

	divLine(contentArea,126)

	-- Teleport to cursor
	local tpLbl=Instance.new("TextLabel",contentArea)
	tpLbl.Size=UDim2.new(1,-28,0,16); tpLbl.Position=UDim2.new(0,14,0,136)
	tpLbl.BackgroundTransparency=1; tpLbl.Text="ТЕЛЕПОРТ"
	tpLbl.TextColor3=Color3.fromRGB(60,60,60); tpLbl.TextSize=10
	tpLbl.Font=Enum.Font.GothamBold; tpLbl.TextXAlignment=Enum.TextXAlignment.Left

	card(contentArea,"Телепорт к прицелу","ЛКМ по поверхности — телепортирует туда",156,function()
		local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		local unitRay=camera:ScreenPointToRay(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
		local ray=workspace:Raycast(unitRay.Origin, unitRay.Direction*1000)
		if ray then
			hrp.CFrame=CFrame.new(ray.Position+Vector3.new(0,3,0))
		end
	end)

	card(contentArea,"Телепорт к случайному игроку","Мгновенный телепорт к другому игроку",214,function()
		local others={}
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(others,p)
			end
		end
		if #others==0 then return end
		local target=others[math.random(1,#others)]
		local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		local tHrp=target.Character.HumanoidRootPart
		hrp.CFrame=tHrp.CFrame*CFrame.new(0,0,3)
	end)
end

-- ВЫБОР ВКЛАДКИ

local function selectTab(active, buildFn)
	for _,b in ipairs(allBtns) do
		TweenService:Create(b,TIF,{BackgroundTransparency=1}):Play()
		local ind=b:FindFirstChild("Ind")
		if ind then TweenService:Create(ind,TIF,{BackgroundTransparency=1}):Play() end
		for _,ch in ipairs(b:GetDescendants()) do
			if ch:IsA("Frame") and ch.Name~="Ind" then
				pcall(function() TweenService:Create(ch,TIF,{BackgroundColor3=Color3.fromRGB(70,70,70)}):Play() end)
			end
		end
	end
	TweenService:Create(active,TIF,{BackgroundTransparency=0.86}):Play()
	local ind=active:FindFirstChild("Ind")
	if ind then TweenService:Create(ind,TIF,{BackgroundTransparency=0}):Play() end
	for _,ch in ipairs(active:GetDescendants()) do
		if ch:IsA("Frame") and ch.Name~="Ind" then
			pcall(function() TweenService:Create(ch,TIF,{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play() end)
		end
	end
	buildFn()
end

btnSky.MouseButton1Click:Connect(function()    selectTab(btnSky,    buildSkyPage) end)
btnAnim.MouseButton1Click:Connect(function()   selectTab(btnAnim,   buildAnimPage) end)
btnLocker.MouseButton1Click:Connect(function() selectTab(btnLocker, buildLockerPage) end)
btnSkyC.MouseButton1Click:Connect(function()   selectTab(btnSkyC,   buildSkyChangerPage) end)
btnTools.MouseButton1Click:Connect(function()  selectTab(btnTools,  buildToolsPage) end)
btnSpeed.MouseButton1Click:Connect(function()  selectTab(btnSpeed,  buildSpeedPage) end)
btnEsp.MouseButton1Click:Connect(function()    selectTab(btnEsp,    buildEspPage) end)
btnNoclip.MouseButton1Click:Connect(function() selectTab(btnNoclip, buildNoclipPage) end)

selectTab(btnSky, buildSkyPage)

-- ОТКРЫТЬ / ЗАКРЫТЬ + РАЗБЛОКИРОВКА МЫШИ (для FPS игр)

-- Сохраняем оригинальные настройки мыши
local origMouseBehavior = Enum.MouseBehavior.LockCenter
local origMouseIcon = false

local function unlockMouse()
	-- Принудительно разблокируем мышь для FPS игр
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
	-- Через getgenv перехватываем попытки игры заблокировать мышь
	getgenv().MouseLocked = true
end

local function lockMouseBack()
	getgenv().MouseLocked = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false
end

-- Каждый кадр пока меню открыто — держим мышь разблокированной
-- (игра каждый кадр пытается её заблокировать)
RunService.RenderStepped:Connect(function()
	if menuOpen then
		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
		if not UserInputService.MouseIconEnabled then
			UserInputService.MouseIconEnabled = true
		end
	end
end)

local function openMenu()
	menuOpen=true
	unlockMouse()
	mainFrame.Visible=true
	mainFrame.BackgroundTransparency=1
	mainFrame.Size=UDim2.new(0,670,0,510)
	mainFrame.Position=UDim2.new(0.5,-335,0.5,-260)
	TweenService:Create(mainFrame,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
		Size=UDim2.new(0,700,0,540),
		Position=UDim2.new(0.5,-350,0.5,-270),
		BackgroundTransparency=0.06
	}):Play()
	TweenService:Create(vibeBlur,TweenInfo.new(0.28),{Size=18}):Play()
end

local function closeMenu()
	menuOpen=false
	TweenService:Create(mainFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
		Size=UDim2.new(0,670,0,510),
		Position=UDim2.new(0.5,-335,0.5,-255),
		BackgroundTransparency=1
	}):Play()
	TweenService:Create(vibeBlur,TweenInfo.new(0.2),{Size=0}):Play()
	task.delay(0.22,function()
		mainFrame.Visible=false
		lockMouseBack()
	end)
end

closeBtn.MouseButton1Click:Connect(closeMenu)

-- B клавиша для Xeno
getgenv().VibeMenuOpen = false

task.spawn(function()
	while task.wait(0.05) do
		if UserInputService:IsKeyDown(Enum.KeyCode.B) then
			if not getgenv().VibeMenuOpen then
				getgenv().VibeMenuOpen = true
				if menuOpen then closeMenu() else openMenu() end
				task.wait(0.3)
				getgenv().VibeMenuOpen = false
			end
		end
	end
end)

-- DRAG
do
	local dr,ds,sp=false,nil,nil
	topBar.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;ds=i.Position;sp=mainFrame.Position end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
			local d=i.Position-ds
			mainFrame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
		end
	end)
end

-- LOCKER Heartbeat
RunService.Heartbeat:Connect(function()
	if lockerActive and lockerBG and lockerBG.Parent then
		local char=player.Character
		if char then
			local hrp=char:FindFirstChild("HumanoidRootPart")
			if hrp then lockerBG.CFrame=CFrame.new(hrp.Position) end
		end
	end
end)

print("[VibeMenu] OK — нажми B чтобы открыть")

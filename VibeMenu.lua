-- VIBE MENU | B = открыть/закрыть | T = Locker
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Reeu37or/FtapScriptByCPMN/refs/heads/main/VibeMenu.lua",true))()

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Lighting       = game:GetService("Lighting")
local player         = Players.LocalPlayer
repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Удаляем старое
local oldGui = player.PlayerGui:FindFirstChild("VibeMenu")
if oldGui then oldGui:Destroy() end
local oldBlur = Lighting:FindFirstChild("VibeBlur")
if oldBlur then oldBlur:Destroy() end

-- СОСТОЯНИЯ
local menuOpen       = false
local lockerActive   = false
local lockerBV, lockerBG = nil, nil
local animTrack, currentAnim = nil, nil
local espActive      = false
local espColor       = Color3.fromRGB(255,255,255)
local espTargetOnly  = nil
local espBillboards  = {}
local espBoxes       = {}
local noclipActive   = false
local noclipConn     = nil
local activeShader   = nil
local particleActive = false
local particleEmitters = {}
local particleColor1 = Color3.fromRGB(255,255,255)
local particleColor2 = Color3.fromRGB(255,200,100)
local currentParticle = nil
local registeredNick = nil  -- nil = не зарегистрирован

-- Таблица разрешённых ников → папка с досками
local NICK_FOLDERS = {
	["Dana_mammv"]   = "Dana_mammvSpawnedInToys",
	["alihanboq4"]   = "alihanboq4SpawnedInToys",
}

-- BLUR
local vibeBlur = Instance.new("BlurEffect")
vibeBlur.Name = "VibeBlur"; vibeBlur.Size = 0; vibeBlur.Parent = Lighting

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VibeMenu"; screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true; screenGui.Parent = player.PlayerGui

-- ══════════════════════════════
--   ЭКРАН РЕГИСТРАЦИИ
-- ══════════════════════════════
local regScreen = Instance.new("Frame",screenGui)
regScreen.Size = UDim2.new(1,0,1,0)
regScreen.BackgroundColor3 = Color3.fromRGB(0,0,0)
regScreen.BackgroundTransparency = 0.35
regScreen.BorderSizePixel = 0
regScreen.ZIndex = 100

-- Карточка по центру
local regCard = Instance.new("Frame",regScreen)
regCard.Size = UDim2.new(0,380,0,280)
regCard.Position = UDim2.new(0.5,-190,0.5,-140)
regCard.BackgroundColor3 = Color3.fromRGB(8,8,8)
regCard.BackgroundTransparency = 0.05
regCard.BorderSizePixel = 0; regCard.ZIndex = 101
Instance.new("UICorner",regCard).CornerRadius = UDim.new(0,18)
local rcs = Instance.new("UIStroke",regCard); rcs.Color=Color3.fromRGB(255,255,255); rcs.Thickness=1; rcs.Transparency=0.8

-- Лого / заголовок
local regLogo = Instance.new("Frame",regCard)
regLogo.Size=UDim2.new(0,3,0,32); regLogo.Position=UDim2.new(0,20,0,22)
regLogo.BackgroundColor3=Color3.fromRGB(255,255,255); regLogo.BorderSizePixel=0
Instance.new("UICorner",regLogo).CornerRadius=UDim.new(1,0)

local regTitle = Instance.new("TextLabel",regCard)
regTitle.Size=UDim2.new(1,-30,0,28); regTitle.Position=UDim2.new(0,30,0,20)
regTitle.BackgroundTransparency=1; regTitle.Text="VIBE MENU"
regTitle.TextColor3=Color3.fromRGB(255,255,255); regTitle.TextSize=20
regTitle.Font=Enum.Font.GothamBold; regTitle.TextXAlignment=Enum.TextXAlignment.Left; regTitle.ZIndex=102

local regSub = Instance.new("TextLabel",regCard)
regSub.Size=UDim2.new(1,-30,0,16); regSub.Position=UDim2.new(0,31,0,50)
regSub.BackgroundTransparency=1; regSub.Text="Введи свой никнейм для входа"
regSub.TextColor3=Color3.fromRGB(60,60,60); regSub.TextSize=12
regSub.Font=Enum.Font.Gotham; regSub.TextXAlignment=Enum.TextXAlignment.Left; regSub.ZIndex=102

-- Разделитель
local regDiv = Instance.new("Frame",regCard)
regDiv.Size=UDim2.new(1,-40,0,1); regDiv.Position=UDim2.new(0,20,0,76)
regDiv.BackgroundColor3=Color3.fromRGB(28,28,28); regDiv.BorderSizePixel=0

-- Поле ввода
local regInputBg = Instance.new("Frame",regCard)
regInputBg.Size=UDim2.new(1,-40,0,48); regInputBg.Position=UDim2.new(0,20,0,90)
regInputBg.BackgroundColor3=Color3.fromRGB(14,14,14); regInputBg.BorderSizePixel=0
Instance.new("UICorner",regInputBg).CornerRadius=UDim.new(0,12)
local regInputStroke = Instance.new("UIStroke",regInputBg); regInputStroke.Color=Color3.fromRGB(45,45,45); regInputStroke.Thickness=1

local regPlaceholder = Instance.new("TextLabel",regInputBg)
regPlaceholder.Size=UDim2.new(1,-20,1,0); regPlaceholder.Position=UDim2.new(0,14,0,0)
regPlaceholder.BackgroundTransparency=1; regPlaceholder.Text="Никнейм..."
regPlaceholder.TextColor3=Color3.fromRGB(45,45,45); regPlaceholder.TextSize=15; regPlaceholder.Font=Enum.Font.Gotham
regPlaceholder.TextXAlignment=Enum.TextXAlignment.Left; regPlaceholder.ZIndex=102

local regInput = Instance.new("TextBox",regInputBg)
regInput.Size=UDim2.new(1,-20,1,0); regInput.Position=UDim2.new(0,14,0,0)
regInput.BackgroundTransparency=1; regInput.BorderSizePixel=0; regInput.Text=""
regInput.TextColor3=Color3.fromRGB(255,255,255); regInput.TextSize=15; regInput.Font=Enum.Font.GothamSemibold
regInput.TextXAlignment=Enum.TextXAlignment.Left; regInput.ClearTextOnFocus=false; regInput.PlaceholderText=""; regInput.ZIndex=103

regInput:GetPropertyChangedSignal("Text"):Connect(function()
	regPlaceholder.Visible = regInput.Text==""
end)
regInput.Focused:Connect(function()
	TweenService:Create(regInputStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(100,100,100)}):Play()
end)
regInput.FocusLost:Connect(function()
	TweenService:Create(regInputStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(45,45,45)}):Play()
end)

-- Статус ошибки
local regError = Instance.new("TextLabel",regCard)
regError.Size=UDim2.new(1,-40,0,16); regError.Position=UDim2.new(0,20,0,144)
regError.BackgroundTransparency=1; regError.Text=""
regError.TextColor3=Color3.fromRGB(255,70,70); regError.TextSize=11; regError.Font=Enum.Font.Gotham
regError.TextXAlignment=Enum.TextXAlignment.Left; regError.ZIndex=102

-- Кнопка входа
local regBtn = Instance.new("TextButton",regCard)
regBtn.Size=UDim2.new(1,-40,0,48); regBtn.Position=UDim2.new(0,20,0,168)
regBtn.BackgroundColor3=Color3.fromRGB(255,255,255); regBtn.BorderSizePixel=0
regBtn.Text="ВОЙТИ"; regBtn.TextColor3=Color3.fromRGB(0,0,0)
regBtn.TextSize=14; regBtn.Font=Enum.Font.GothamBold; regBtn.AutoButtonColor=false; regBtn.ZIndex=102
Instance.new("UICorner",regBtn).CornerRadius=UDim.new(0,12)
regBtn.MouseEnter:Connect(function() TweenService:Create(regBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(215,215,215)}):Play() end)
regBtn.MouseLeave:Connect(function() TweenService:Create(regBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play() end)

-- Подсказка снизу
local regHint = Instance.new("TextLabel",regCard)
regHint.Size=UDim2.new(1,-40,0,20); regHint.Position=UDim2.new(0,20,0,228)
regHint.BackgroundTransparency=1; regHint.Text="Только для авторизованных пользователей"
regHint.TextColor3=Color3.fromRGB(35,35,35); regHint.TextSize=10; regHint.Font=Enum.Font.Gotham
regHint.TextXAlignment=Enum.TextXAlignment.Center; regHint.ZIndex=102

-- Логика входа
local function doLogin()
	local nick = regInput.Text:match("^%s*(.-)%s*$") -- trim
	if NICK_FOLDERS[nick] then
		registeredNick = nick
		regError.Text = ""
		-- Плавная анимация исчезновения
		TweenService:Create(regCard,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
			Size=UDim2.new(0,340,0,240), Position=UDim2.new(0.5,-170,0.5,-130)
		}):Play()
		TweenService:Create(regScreen,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{BackgroundTransparency=1}):Play()
		task.delay(0.35,function()
			regScreen.Visible=false
			regScreen:Destroy()
		end)
		-- Показываем подсказку
		local toast=Instance.new("TextLabel",screenGui)
		toast.Size=UDim2.new(0,260,0,36); toast.Position=UDim2.new(0.5,-130,1,-60)
		toast.BackgroundColor3=Color3.fromRGB(12,12,12); toast.BackgroundTransparency=0.2; toast.BorderSizePixel=0
		toast.Text="Добро пожаловать, "..nick.."!  (B — открыть меню)"; toast.TextColor3=Color3.fromRGB(200,200,200)
		toast.TextSize=11; toast.Font=Enum.Font.GothamSemibold; toast.ZIndex=99
		Instance.new("UICorner",toast).CornerRadius=UDim.new(0,10)
		TweenService:Create(toast,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-130,1,-70)}):Play()
		task.delay(3,function()
			TweenService:Create(toast,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-130,1,-40),BackgroundTransparency=1}):Play()
			task.delay(0.35,function() toast:Destroy() end)
		end)
	else
		regError.Text = "Никнейм не найден. Попробуй снова."
		TweenService:Create(regCard,TweenInfo.new(0.05),{Position=UDim2.new(0.5,-195,0.5,-140)}):Play()
		task.delay(0.05,function() TweenService:Create(regCard,TweenInfo.new(0.05),{Position=UDim2.new(0.5,-185,0.5,-140)}):Play() end)
		task.delay(0.10,function() TweenService:Create(regCard,TweenInfo.new(0.05),{Position=UDim2.new(0.5,-190,0.5,-140)}):Play() end)
	end
end

regBtn.MouseButton1Click:Connect(doLogin)
regInput.FocusLost:Connect(function(enter) if enter then doLogin() end end)

-- ГЛАВНЫЙ ФРЕЙМ (пол экрана)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.55,0,0.78,0)
mainFrame.Position = UDim2.new(0.225,0,0.11,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(6,6,6)
mainFrame.BackgroundTransparency = 0.06
mainFrame.BorderSizePixel = 0; mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner",mainFrame).CornerRadius = UDim.new(0,16)
local ms = Instance.new("UIStroke",mainFrame)
ms.Color = Color3.fromRGB(255,255,255); ms.Thickness = 1; ms.Transparency = 0.82

-- TOPBAR
local topBar = Instance.new("Frame",mainFrame)
topBar.Size = UDim2.new(1,0,0,52); topBar.BackgroundColor3 = Color3.fromRGB(10,10,10)
topBar.BorderSizePixel = 0; topBar.ZIndex = 2
Instance.new("UICorner",topBar).CornerRadius = UDim.new(0,16)
local tfix = Instance.new("Frame",topBar)
tfix.Size=UDim2.new(1,0,0,18); tfix.Position=UDim2.new(0,0,1,-18)
tfix.BackgroundColor3=Color3.fromRGB(10,10,10); tfix.BorderSizePixel=0

local acc = Instance.new("Frame",topBar)
acc.Size=UDim2.new(0,3,0,26); acc.Position=UDim2.new(0,16,0.5,-13)
acc.BackgroundColor3=Color3.fromRGB(255,255,255); acc.BorderSizePixel=0; acc.ZIndex=3
Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)

local titleLbl = Instance.new("TextLabel",topBar)
titleLbl.Size=UDim2.new(1,-90,0,26); titleLbl.Position=UDim2.new(0,28,0,7)
titleLbl.BackgroundTransparency=1; titleLbl.Text="VIBE MENU"
titleLbl.TextColor3=Color3.fromRGB(255,255,255); titleLbl.TextSize=17
titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.ZIndex=3

local subLbl = Instance.new("TextLabel",topBar)
subLbl.Size=UDim2.new(1,-90,0,14); subLbl.Position=UDim2.new(0,29,0,33)
subLbl.BackgroundTransparency=1; subLbl.Text="B — открыть / закрыть"
subLbl.TextColor3=Color3.fromRGB(70,70,70); subLbl.TextSize=11
subLbl.Font=Enum.Font.Gotham; subLbl.TextXAlignment=Enum.TextXAlignment.Left; subLbl.ZIndex=3

local closeBtn = Instance.new("TextButton",topBar)
closeBtn.Size=UDim2.new(0,32,0,32); closeBtn.Position=UDim2.new(1,-44,0,10)
closeBtn.BackgroundColor3=Color3.fromRGB(30,30,30); closeBtn.BorderSizePixel=0
closeBtn.Text="x"; closeBtn.TextColor3=Color3.fromRGB(160,160,160)
closeBtn.TextSize=14; closeBtn.Font=Enum.Font.GothamBold; closeBtn.ZIndex=3
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,8)

-- SIDEBAR (скролящийся под много вкладок)
local sideScroll = Instance.new("ScrollingFrame",mainFrame)
sideScroll.Size=UDim2.new(0,68,1,-52); sideScroll.Position=UDim2.new(0,0,0,52)
sideScroll.BackgroundColor3=Color3.fromRGB(9,9,9); sideScroll.BorderSizePixel=0
sideScroll.ScrollBarThickness=0; sideScroll.CanvasSize=UDim2.new(0,0,0,700)
sideScroll.ScrollingEnabled=true; sideScroll.ClipsDescendants=true

local sdiv = Instance.new("Frame",mainFrame)
sdiv.Size=UDim2.new(0,1,1,-52); sdiv.Position=UDim2.new(0,68,0,52)
sdiv.BackgroundColor3=Color3.fromRGB(36,36,36); sdiv.BorderSizePixel=0

local contentArea = Instance.new("ScrollingFrame",mainFrame)
contentArea.Size=UDim2.new(1,-70,1,-52); contentArea.Position=UDim2.new(0,70,0,52)
contentArea.BackgroundTransparency=1; contentArea.BorderSizePixel=0
contentArea.ScrollBarThickness=3; contentArea.ScrollBarImageColor3=Color3.fromRGB(50,50,50)
contentArea.CanvasSize=UDim2.new(0,0,0,600); contentArea.ClipsDescendants=true

-- ИКОНКИ
local function makeIconSun(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local c=Instance.new("Frame",f); c.Size=UDim2.new(0,10,0,10); c.Position=UDim2.new(0.5,-5,0.5,-5)
	c.BackgroundColor3=Color3.fromRGB(255,255,255); c.BorderSizePixel=0
	Instance.new("UICorner",c).CornerRadius=UDim.new(1,0)
	for i=0,7 do
		local r=Instance.new("Frame",f); r.Size=UDim2.new(0,2,0,5)
		r.AnchorPoint=Vector2.new(0.5,1); r.Position=UDim2.new(0.5,0,0.5,0)
		r.BackgroundColor3=Color3.fromRGB(255,255,255); r.BorderSizePixel=0; r.Rotation=i*45
		Instance.new("UICorner",r).CornerRadius=UDim.new(1,0)
	end
end
local function makeIconBody(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local function box(sx,sy,px,py,rot)
		local b=Instance.new("Frame",f); b.Size=UDim2.new(0,sx,0,sy)
		b.Position=UDim2.new(0.5,px-sx/2,0,py); b.BackgroundColor3=Color3.fromRGB(255,255,255)
		b.BorderSizePixel=0; if rot then b.Rotation=rot end
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
	end
	box(8,8,0,1); box(4,9,0,11); box(3,7,-6,12,-20); box(3,7,7,10,30); box(3,8,-4,21,-10); box(3,8,3,21,10)
end
local function makeIconLock(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local function box(sx,sy,px,py)
		local b=Instance.new("Frame",f); b.Size=UDim2.new(0,sx,0,sy)
		b.Position=UDim2.new(0.5,px,0.5,py); b.BackgroundColor3=Color3.fromRGB(255,255,255); b.BorderSizePixel=0
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
	end
	box(16,11,-8,0); box(3,9,-7,-9); box(3,9,4,-9); box(12,3,-6,-13)
	local h=Instance.new("Frame",f); h.Size=UDim2.new(0,4,0,4); h.Position=UDim2.new(0.5,-2,0.5,2)
	h.BackgroundColor3=Color3.fromRGB(6,6,6); h.BorderSizePixel=0
	Instance.new("UICorner",h).CornerRadius=UDim.new(1,0)
end
local function makeIconPlanet(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local pl=Instance.new("Frame",f); pl.Size=UDim2.new(0,14,0,14); pl.Position=UDim2.new(0.5,-7,0,-1)
	pl.BackgroundColor3=Color3.fromRGB(255,255,255); pl.BorderSizePixel=0
	Instance.new("UICorner",pl).CornerRadius=UDim.new(1,0)
	local ring=Instance.new("Frame",f); ring.Size=UDim2.new(0,20,0,4); ring.Position=UDim2.new(0.5,-10,0,3)
	ring.BackgroundColor3=Color3.fromRGB(255,255,255); ring.BackgroundTransparency=0.5
	ring.BorderSizePixel=0; ring.Rotation=-20
	Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
	local ar=Instance.new("Frame",f); ar.Size=UDim2.new(0,2,0,9); ar.Position=UDim2.new(0.5,-1,0,16)
	ar.BackgroundColor3=Color3.fromRGB(255,255,255); ar.BorderSizePixel=0
	local al=Instance.new("Frame",f); al.Size=UDim2.new(0,6,0,2); al.Position=UDim2.new(0.5,-5,0,23)
	al.BackgroundColor3=Color3.fromRGB(255,255,255); al.BorderSizePixel=0; al.Rotation=40
	local arr=Instance.new("Frame",f); arr.Size=UDim2.new(0,6,0,2); arr.Position=UDim2.new(0.5,0,0,23)
	arr.BackgroundColor3=Color3.fromRGB(255,255,255); arr.BorderSizePixel=0; arr.Rotation=-40
end
local function makeIconTools(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local outer=Instance.new("Frame",f); outer.Size=UDim2.new(0,18,0,18); outer.Position=UDim2.new(0.5,-9,0,2)
	outer.BackgroundTransparency=1; outer.BorderSizePixel=0
	local os=Instance.new("UIStroke",outer); os.Color=Color3.fromRGB(255,255,255); os.Thickness=2
	Instance.new("UICorner",outer).CornerRadius=UDim.new(1,0)
	local dot=Instance.new("Frame",f); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0.5,-2,0,9)
	dot.BackgroundColor3=Color3.fromRGB(255,255,255); dot.BorderSizePixel=0
	Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	local h=Instance.new("Frame",f); h.Size=UDim2.new(0,8,0,2); h.Position=UDim2.new(0.5,-4,0,10)
	h.BackgroundColor3=Color3.fromRGB(255,255,255); h.BorderSizePixel=0
	local v=Instance.new("Frame",f); v.Size=UDim2.new(0,2,0,8); v.Position=UDim2.new(0.5,-1,0,7)
	v.BackgroundColor3=Color3.fromRGB(255,255,255); v.BorderSizePixel=0
	local track=Instance.new("Frame",f); track.Size=UDim2.new(0,20,0,3); track.Position=UDim2.new(0.5,-10,0,23)
	track.BackgroundColor3=Color3.fromRGB(50,50,50); track.BorderSizePixel=0
	Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
	local fill=Instance.new("Frame",track); fill.Size=UDim2.new(0.6,0,1,0)
	fill.BackgroundColor3=Color3.fromRGB(255,255,255); fill.BorderSizePixel=0
	Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
end
local function makeIconSpeed(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local t=Instance.new("Frame",f); t.Size=UDim2.new(0,10,0,13); t.Position=UDim2.new(0.5,0,0,1)
	t.BackgroundColor3=Color3.fromRGB(255,255,255); t.BorderSizePixel=0; t.Rotation=-15
	Instance.new("UICorner",t).CornerRadius=UDim.new(0,2)
	local b=Instance.new("Frame",f); b.Size=UDim2.new(0,10,0,13); b.Position=UDim2.new(0.5,-10,0,12)
	b.BackgroundColor3=Color3.fromRGB(255,255,255); b.BorderSizePixel=0; b.Rotation=-15
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
	for i=0,2 do
		local l=Instance.new("Frame",f); l.Size=UDim2.new(0,6-i,0,2)
		l.Position=UDim2.new(0,1,0,8+i*5); l.BackgroundColor3=Color3.fromRGB(255,255,255)
		l.BackgroundTransparency=0.4+i*0.15; l.BorderSizePixel=0
		Instance.new("UICorner",l).CornerRadius=UDim.new(1,0)
	end
end
local function makeIconEsp(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local eye=Instance.new("Frame",f); eye.Size=UDim2.new(0,20,0,12); eye.Position=UDim2.new(0.5,-10,0.5,-8)
	eye.BackgroundTransparency=1; eye.BorderSizePixel=0
	Instance.new("UIStroke",eye).Color=Color3.fromRGB(255,255,255)
	Instance.new("UICorner",eye).CornerRadius=UDim.new(0,6)
	local pupil=Instance.new("Frame",f); pupil.Size=UDim2.new(0,7,0,7); pupil.Position=UDim2.new(0.5,-3,0.5,-5)
	pupil.BackgroundColor3=Color3.fromRGB(255,255,255); pupil.BorderSizePixel=0
	Instance.new("UICorner",pupil).CornerRadius=UDim.new(1,0)
end
local function makeIconNoclip(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	local s1=Instance.new("Frame",f); s1.Size=UDim2.new(0,14,0,14); s1.Position=UDim2.new(0.5,-12,0,3)
	s1.BackgroundTransparency=1; s1.BorderSizePixel=0
	Instance.new("UIStroke",s1).Color=Color3.fromRGB(255,255,255)
	Instance.new("UICorner",s1).CornerRadius=UDim.new(0,3)
	local s2=Instance.new("Frame",f); s2.Size=UDim2.new(0,14,0,14); s2.Position=UDim2.new(0.5,-2,0,10)
	s2.BackgroundTransparency=1; s2.BorderSizePixel=0
	local s2s=Instance.new("UIStroke",s2); s2s.Color=Color3.fromRGB(255,255,255); s2s.Transparency=0.4
	Instance.new("UICorner",s2).CornerRadius=UDim.new(0,3)
end
local function makeIconShader(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	for i,s in ipairs({22,15,8}) do
		local c=Instance.new("Frame",f); c.Size=UDim2.new(0,s,0,s); c.Position=UDim2.new(0.5,-s/2,0.5,-s/2-2)
		c.BackgroundTransparency=1; c.BorderSizePixel=0
		local cs=Instance.new("UIStroke",c); cs.Color=Color3.fromRGB(255,255,255); cs.Thickness=2; cs.Transparency=({0.6,0.35,0})[i]
		Instance.new("UICorner",c).CornerRadius=UDim.new(1,0)
	end
	local line=Instance.new("Frame",f); line.Size=UDim2.new(0,22,0,2); line.Position=UDim2.new(0.5,-11,1,-5)
	line.BackgroundColor3=Color3.fromRGB(255,255,255); line.BackgroundTransparency=0.5; line.BorderSizePixel=0
	Instance.new("UICorner",line).CornerRadius=UDim.new(1,0)
end
local function makeIconParticle(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	-- Центральная точка (источник)
	local center=Instance.new("Frame",f); center.Size=UDim2.new(0,5,0,5); center.Position=UDim2.new(0.5,-2,0.5,-2)
	center.BackgroundColor3=Color3.fromRGB(255,255,255); center.BorderSizePixel=0
	Instance.new("UICorner",center).CornerRadius=UDim.new(1,0)
	-- Частицы летят в разные стороны
	local dots={{-8,-8,3},{8,-8,3},{-10,0,2},{10,0,2},{-6,8,4},{6,8,4},{0,-11,2},{0,9,3}}
	for _,d in ipairs(dots) do
		local dot=Instance.new("Frame",f); dot.Size=UDim2.new(0,d[3],0,d[3])
		dot.Position=UDim2.new(0.5,d[1]-d[3]/2,0.5,d[2]-d[3]/2)
		dot.BackgroundColor3=Color3.fromRGB(255,255,255); dot.BackgroundTransparency=0.3; dot.BorderSizePixel=0
		Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	end
end

local function makeIconHVH(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	-- Два скрещенных меча (символ HVH)
	local function sword(rot)
		local blade=Instance.new("Frame",f); blade.Size=UDim2.new(0,3,0,20); blade.AnchorPoint=Vector2.new(0.5,0.5); blade.Position=UDim2.new(0.5,0,0.5,0); blade.BackgroundColor3=Color3.fromRGB(255,255,255); blade.BorderSizePixel=0; blade.Rotation=rot
		Instance.new("UICorner",blade).CornerRadius=UDim.new(0,1)
		local guard=Instance.new("Frame",f); guard.Size=UDim2.new(0,10,0,2); guard.AnchorPoint=Vector2.new(0.5,0.5); guard.Position=UDim2.new(0.5,0,0.5,4); guard.BackgroundColor3=Color3.fromRGB(255,255,255); guard.BorderSizePixel=0; guard.Rotation=rot
		Instance.new("UICorner",guard).CornerRadius=UDim.new(1,0)
	end
	sword(-35); sword(35)
end
local function makeIconHitbox(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	-- Фигурка в рамке хитбокса
	local box=Instance.new("Frame",f); box.Size=UDim2.new(0,22,0,26); box.Position=UDim2.new(0.5,-11,0,1); box.BackgroundTransparency=1; box.BorderSizePixel=0
	local bs=Instance.new("UIStroke",box); bs.Color=Color3.fromRGB(255,255,255); bs.Thickness=1.5; bs.Transparency=0.3
	Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
	-- голова внутри
	local head=Instance.new("Frame",f); head.Size=UDim2.new(0,7,0,7); head.Position=UDim2.new(0.5,-3,0,3); head.BackgroundColor3=Color3.fromRGB(255,255,255); head.BorderSizePixel=0; Instance.new("UICorner",head).CornerRadius=UDim.new(1,0)
	-- тело
	local body=Instance.new("Frame",f); body.Size=UDim2.new(0,3,0,8); body.Position=UDim2.new(0.5,-1,0,11); body.BackgroundColor3=Color3.fromRGB(255,255,255); body.BorderSizePixel=0
	-- размерные стрелки по бокам
	for _,side in ipairs({-13,12}) do
		local arr=Instance.new("Frame",f); arr.Size=UDim2.new(0,2,0,10); arr.Position=UDim2.new(0.5,side,0,8); arr.BackgroundColor3=Color3.fromRGB(255,255,255); arr.BackgroundTransparency=0.5; arr.BorderSizePixel=0
	end
end

local function makeIconAimbot(p)
	local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1
	-- Прицел: внешний круг + 4 линии + точка по центру
	local outer=Instance.new("Frame",f); outer.Size=UDim2.new(0,20,0,20); outer.Position=UDim2.new(0.5,-10,0.5,-12)
	outer.BackgroundTransparency=1; outer.BorderSizePixel=0
	local os=Instance.new("UIStroke",outer); os.Color=Color3.fromRGB(255,255,255); os.Thickness=1.5
	Instance.new("UICorner",outer).CornerRadius=UDim.new(1,0)
	-- 4 линии крест
	local function line(sx,sy,px,py)
		local l=Instance.new("Frame",f); l.Size=UDim2.new(0,sx,0,sy); l.Position=UDim2.new(0.5,px,0.5,py-12)
		l.BackgroundColor3=Color3.fromRGB(255,255,255); l.BorderSizePixel=0
	end
	line(6,1,-13,-0); line(6,1,7,0); line(1,6,-0,-13); line(1,6,0,7)
	-- центр точка
	local dot=Instance.new("Frame",f); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0.5,-2,0.5,-14)
	dot.BackgroundColor3=Color3.fromRGB(255,80,80); dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
end

-- SIDEBAR КНОПКИ
local TIF = TweenInfo.new(0.14,Enum.EasingStyle.Quad)

local function makeSideBtn(iconFn,yPos)
	local btn=Instance.new("TextButton",sideScroll)
	btn.Size=UDim2.new(0,46,0,46); btn.Position=UDim2.new(0.5,-23,0,yPos)
	btn.BackgroundColor3=Color3.fromRGB(20,20,20); btn.BackgroundTransparency=1
	btn.BorderSizePixel=0; btn.Text=""; btn.AutoButtonColor=false
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
	local ih=Instance.new("Frame",btn); ih.Size=UDim2.new(0,26,0,26); ih.Position=UDim2.new(0.5,-13,0.5,-13); ih.BackgroundTransparency=1
	iconFn(ih)
	local ind=Instance.new("Frame",btn); ind.Name="Ind"
	ind.Size=UDim2.new(0,3,0,22); ind.Position=UDim2.new(0,-2,0.5,-11)
	ind.BackgroundColor3=Color3.fromRGB(255,255,255); ind.BackgroundTransparency=1; ind.BorderSizePixel=0
	Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)
	return btn
end

local btnSky      = makeSideBtn(makeIconSun,      8)
local btnAnim     = makeSideBtn(makeIconBody,     60)
local btnLocker   = makeSideBtn(makeIconLock,    112)
local btnSkyC     = makeSideBtn(makeIconPlanet,  164)
local btnTools    = makeSideBtn(makeIconTools,   216)
local btnSpeed    = makeSideBtn(makeIconSpeed,   268)
local btnEsp      = makeSideBtn(makeIconEsp,     320)
local btnNoclip   = makeSideBtn(makeIconNoclip,  372)
local btnShader   = makeSideBtn(makeIconShader,  424)
local btnParticle = makeSideBtn(makeIconParticle,476)
local btnHVH      = makeSideBtn(makeIconHVH,     528)
local btnHitbox   = makeSideBtn(makeIconHitbox,  580)
local btnAimbot   = makeSideBtn(makeIconAimbot,  632)

local allBtns = {btnSky,btnAnim,btnLocker,btnSkyC,btnTools,btnSpeed,btnEsp,btnNoclip,btnShader,btnParticle,btnHVH,btnHitbox,btnAimbot}
sideScroll.CanvasSize = UDim2.new(0,0,0,692)

-- КОМПОНЕНТЫ
local function clearContent()
	for _,c in ipairs(contentArea:GetChildren()) do c:Destroy() end
end

local function hdr(parent,title,sub,y)
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

local function divLine(parent,y)
	local l=Instance.new("Frame",parent)
	l.Size=UDim2.new(1,-28,0,1); l.Position=UDim2.new(0,14,0,y)
	l.BackgroundColor3=Color3.fromRGB(24,24,24); l.BorderSizePixel=0
end

local function card(parent,title,sub,y,cb)
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

local function makeToggleCard(parent,title,sub,y,state,cb)
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
		cb(cur)
	end)
	return f,tog,knob
end

local function makeSlider(parent,title,y,minV,maxV,defV,cb)
	local con=Instance.new("Frame",parent)
	con.Size=UDim2.new(1,-28,0,56); con.Position=UDim2.new(0,14,0,y); con.BackgroundTransparency=1
	local lbl=Instance.new("TextLabel",con)
	lbl.Size=UDim2.new(1,-55,0,18); lbl.BackgroundTransparency=1; lbl.Text=title
	lbl.TextColor3=Color3.fromRGB(185,185,185); lbl.TextSize=12; lbl.Font=Enum.Font.GothamSemibold
	lbl.TextXAlignment=Enum.TextXAlignment.Left
	local valL=Instance.new("TextLabel",con)
	valL.Size=UDim2.new(0,50,0,18); valL.Position=UDim2.new(1,-50,0,0)
	valL.BackgroundTransparency=1; valL.Text=tostring(defV)
	valL.TextColor3=Color3.fromRGB(255,255,255); valL.TextSize=13; valL.Font=Enum.Font.GothamBold
	valL.TextXAlignment=Enum.TextXAlignment.Right
	local track=Instance.new("Frame",con)
	track.Size=UDim2.new(1,0,0,6); track.Position=UDim2.new(0,0,0,30)
	track.BackgroundColor3=Color3.fromRGB(36,36,36); track.BorderSizePixel=0
	Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
	local ratio=(defV-minV)/(maxV-minV)
	local fill=Instance.new("Frame",track); fill.Size=UDim2.new(ratio,0,1,0)
	fill.BackgroundColor3=Color3.fromRGB(255,255,255); fill.BorderSizePixel=0
	Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
	local handle=Instance.new("TextButton",track)
	handle.Size=UDim2.new(0,16,0,16); handle.Position=UDim2.new(ratio,-8,0.5,-8)
	handle.BackgroundColor3=Color3.fromRGB(255,255,255); handle.BorderSizePixel=0
	handle.Text=""; handle.AutoButtonColor=false; handle.ZIndex=5
	Instance.new("UICorner",handle).CornerRadius=UDim.new(1,0)
	local dragging=false
	handle.MouseButton1Down:Connect(function() dragging=true end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
			local tx=track.AbsolutePosition.X; local tw=track.AbsoluteSize.X
			local rel=math.clamp((i.Position.X-tx)/tw,0,1)
			local val=math.floor(minV+rel*(maxV-minV))
			fill.Size=UDim2.new(rel,0,1,0); handle.Position=UDim2.new(rel,-8,0.5,-8)
			valL.Text=tostring(val); cb(val)
		end
	end)
	return valL
end

-- ══════════════════════════════
--   СТРАНИЦЫ
-- ══════════════════════════════

local function buildSkyPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,580)
	hdr(contentArea,"SKY","Пресеты неба и освещения",14); divLine(contentArea,55)
	local presets={
		{"Clear Day","Ясный день",{ClockTime=14,Brightness=2,Ambient=Color3.fromRGB(70,95,115)}},
		{"Night","Звёздная ночь",{ClockTime=0,Brightness=0,Ambient=Color3.fromRGB(8,8,22)}},
		{"Sunset","Оранжевый закат",{ClockTime=19,Brightness=1.5,Ambient=Color3.fromRGB(120,55,18)}},
		{"Overcast","Пасмурно",{ClockTime=12,Brightness=0.7,Ambient=Color3.fromRGB(70,70,80)}},
		{"Deep Night","Глубокая ночь",{ClockTime=3,Brightness=0,Ambient=Color3.fromRGB(4,4,12)}},
		{"Golden Hour","Золотой час",{ClockTime=7,Brightness=2,Ambient=Color3.fromRGB(180,115,35)}},
		{"Blood Sky","Красное небо",{ClockTime=18,Brightness=1.2,Ambient=Color3.fromRGB(130,20,10)}},
		{"Void","Черная пустота",{ClockTime=0,Brightness=0,Ambient=Color3.fromRGB(0,0,0)}},
	}
	for i,p in ipairs(presets) do
		card(contentArea,p[1],p[2],64+(i-1)*58,function()
			for k,v in pairs(p[3]) do pcall(function() Lighting[k]=v end) end
		end)
	end
end

local function buildAnimPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,500)
	hdr(contentArea,"ANIMATED","Анимации персонажа",14); divLine(contentArea,55)
	local anims={
		{"Split Arms","Руки отделяются от тела","rbxassetid://5915192537"},
		{"Sit Idle","Сидит на месте","rbxassetid://2506281857"},
		{"Demon Stand","Стоит в воздухе как демон","rbxassetid://5342546925"},
		{"Lay Down","Лежит на полу","rbxassetid://2506281879"},
		{"Levitate","Парит в воздухе","rbxassetid://3247955605"},
		{"T-Pose","Т-поза","rbxassetid://2506281986"},
	}
	card(contentArea,"Сбросить","Остановить текущую анимацию",64,function()
		if animTrack then pcall(function() animTrack:Stop() end); animTrack=nil; currentAnim=nil end
	end)
	for i,a in ipairs(anims) do
		card(contentArea,a[1],a[2],64+i*58,function()
			local char=player.Character; if not char then return end
			local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
			if animTrack then pcall(function() animTrack:Stop() end); animTrack=nil end
			if currentAnim==a[3] then currentAnim=nil; return end
			currentAnim=a[3]
			local anim=Instance.new("Animation"); anim.AnimationId=a[3]
			local animator=hum:FindFirstChildOfClass("Animator") or Instance.new("Animator",hum)
			animTrack=animator:LoadAnimation(anim); animTrack.Looped=true; animTrack:Play()
		end)
	end
end

local function buildLockerPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,380)
	hdr(contentArea,"LOCKER","T — быстрый тоггл в любой момент",14); divLine(contentArea,55)
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
		TweenService:Create(statusLbl,TIF,{TextColor3=s and Color3.fromRGB(255,255,255) or Color3.fromRGB(55,55,55)}):Play()
		statusLbl.Text=s and "LOCKER  ON" or "LOCKER  OFF"
	end
	local function setLocker(s)
		lockerActive=s
		local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		if s then
			if not lockerBV or not lockerBV.Parent then
				lockerBV=Instance.new("BodyVelocity",hrp); lockerBV.MaxForce=Vector3.new(1e5,1e5,1e5); lockerBV.Velocity=Vector3.new(0,-6,0)
			end
			if not lockerBG or not lockerBG.Parent then
				lockerBG=Instance.new("BodyGyro",hrp); lockerBG.MaxTorque=Vector3.new(1e5,1e5,1e5); lockerBG.D=300; lockerBG.CFrame=CFrame.new(hrp.Position)
			end
		else
			if lockerBV and lockerBV.Parent then lockerBV:Destroy(); lockerBV=nil end
			if lockerBG and lockerBG.Parent then lockerBG:Destroy(); lockerBG=nil end
		end
	end
	card(contentArea,"Включить Locker","Плавное падение прямо вниз",136,function() setLocker(true); updStatus(true) end)
	card(contentArea,"Выключить Locker","Вернуть обычную физику",194,function() setLocker(false); updStatus(false) end)
	divLine(contentArea,256)
	local hint=Instance.new("Frame",contentArea); hint.Size=UDim2.new(1,-28,0,70); hint.Position=UDim2.new(0,14,0,264)
	hint.BackgroundColor3=Color3.fromRGB(10,10,10); hint.BorderSizePixel=0; Instance.new("UICorner",hint).CornerRadius=UDim.new(0,10)
	local hl=Instance.new("TextLabel",hint); hl.Size=UDim2.new(1,-20,1,-14); hl.Position=UDim2.new(0,10,0,7)
	hl.BackgroundTransparency=1; hl.Text="Когда тебя бросают — нажми T.\nГасит горизонтальную скорость,\nтело падает медленно и ровно вниз."
	hl.TextColor3=Color3.fromRGB(58,58,58); hl.TextSize=12; hl.Font=Enum.Font.Gotham
	hl.TextWrapped=true; hl.TextXAlignment=Enum.TextXAlignment.Left; hl.TextYAlignment=Enum.TextYAlignment.Top
	-- T клавиша обрабатывается глобально через polling внизу скрипта
end

local function buildSkyChangerPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,360)
	hdr(contentArea,"SKY CHANGER","Вставь свой Asset ID",14); divLine(contentArea,55)
	local ibg=Instance.new("Frame",contentArea); ibg.Size=UDim2.new(1,-28,0,44); ibg.Position=UDim2.new(0,14,0,64)
	ibg.BackgroundColor3=Color3.fromRGB(13,13,13); ibg.BorderSizePixel=0
	Instance.new("UICorner",ibg).CornerRadius=UDim.new(0,10)
	local ibs=Instance.new("UIStroke",ibg); ibs.Color=Color3.fromRGB(40,40,40); ibs.Thickness=1
	local ph=Instance.new("TextLabel",ibg); ph.Size=UDim2.new(1,-14,1,0); ph.Position=UDim2.new(0,12,0,0)
	ph.BackgroundTransparency=1; ph.Text="Asset ID..."; ph.TextColor3=Color3.fromRGB(48,48,48)
	ph.TextSize=13; ph.Font=Enum.Font.Gotham; ph.TextXAlignment=Enum.TextXAlignment.Left
	local ib=Instance.new("TextBox",ibg); ib.Size=UDim2.new(1,-14,1,0); ib.Position=UDim2.new(0,12,0,0)
	ib.BackgroundTransparency=1; ib.BorderSizePixel=0; ib.Text=""
	ib.TextColor3=Color3.fromRGB(255,255,255); ib.TextSize=14; ib.Font=Enum.Font.GothamSemibold
	ib.TextXAlignment=Enum.TextXAlignment.Left; ib.ClearTextOnFocus=false; ib.PlaceholderText=""
	ib:GetPropertyChangedSignal("Text"):Connect(function() ph.Visible=ib.Text==""; ib.Text=ib.Text:gsub("[^%d]","") end)
	ib.Focused:Connect(function() TweenService:Create(ibs,TIF,{Color=Color3.fromRGB(90,90,90)}):Play() end)
	ib.FocusLost:Connect(function() TweenService:Create(ibs,TIF,{Color=Color3.fromRGB(40,40,40)}):Play() end)
	local ab=Instance.new("TextButton",contentArea); ab.Size=UDim2.new(1,-28,0,44); ab.Position=UDim2.new(0,14,0,118)
	ab.BackgroundColor3=Color3.fromRGB(255,255,255); ab.BorderSizePixel=0
	ab.Text="ПРИМЕНИТЬ"; ab.TextColor3=Color3.fromRGB(0,0,0)
	ab.TextSize=13; ab.Font=Enum.Font.GothamBold; ab.AutoButtonColor=false
	Instance.new("UICorner",ab).CornerRadius=UDim.new(0,10)
	ab.MouseEnter:Connect(function() TweenService:Create(ab,TIF,{BackgroundColor3=Color3.fromRGB(215,215,215)}):Play() end)
	ab.MouseLeave:Connect(function() TweenService:Create(ab,TIF,{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play() end)
	local res=Instance.new("TextLabel",contentArea); res.Size=UDim2.new(1,-28,0,22); res.Position=UDim2.new(0,16,0,172)
	res.BackgroundTransparency=1; res.Text=""; res.TextSize=12; res.Font=Enum.Font.GothamSemibold; res.TextXAlignment=Enum.TextXAlignment.Left
	ab.MouseButton1Click:Connect(function()
		local id=ib.Text; if id=="" then res.Text="Введи Asset ID!"; res.TextColor3=Color3.fromRGB(255,70,70); return end
		local aid="rbxassetid://"..id
		local old=Lighting:FindFirstChildOfClass("Sky"); if old then old:Destroy() end
		local sky=Instance.new("Sky",Lighting)
		sky.SkyboxBk=aid; sky.SkyboxDn=aid; sky.SkyboxFt=aid; sky.SkyboxLf=aid; sky.SkyboxRt=aid; sky.SkyboxUp=aid
		res.Text="Применено: "..id; res.TextColor3=Color3.fromRGB(90,220,110)
	end)
	card(contentArea,"Убрать Sky","Вернуть стандартное небо",202,function()
		local old=Lighting:FindFirstChildOfClass("Sky"); if old then old:Destroy() end
		res.Text="Sky сброшен"; res.TextColor3=Color3.fromRGB(90,90,90)
	end)
end

local function buildToolsPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,520)
	hdr(contentArea,"TOOLS","Reach, FOV и Commands",14); divLine(contentArea,55)
	-- REACH
	local reachActive=false
	local rc=Instance.new("Frame",contentArea); rc.Size=UDim2.new(1,-28,0,50); rc.Position=UDim2.new(0,14,0,64)
	rc.BackgroundColor3=Color3.fromRGB(14,14,14); rc.BorderSizePixel=0
	Instance.new("UICorner",rc).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",rc).Color=Color3.fromRGB(30,30,30)
	local rtl=Instance.new("TextLabel",rc); rtl.Size=UDim2.new(1,-80,0,20); rtl.Position=UDim2.new(0,12,0,8)
	rtl.BackgroundTransparency=1; rtl.Text="Free Gamepass Reach"; rtl.TextColor3=Color3.fromRGB(225,225,225); rtl.TextSize=13; rtl.Font=Enum.Font.GothamSemibold; rtl.TextXAlignment=Enum.TextXAlignment.Left
	local rsl=Instance.new("TextLabel",rc); rsl.Size=UDim2.new(1,-80,0,14); rsl.Position=UDim2.new(0,12,0,29)
	rsl.BackgroundTransparency=1; rsl.Text="Дальность граба без геймпасса"; rsl.TextColor3=Color3.fromRGB(60,60,60); rsl.TextSize=11; rsl.Font=Enum.Font.Gotham; rsl.TextXAlignment=Enum.TextXAlignment.Left
	local rtog=Instance.new("TextButton",rc); rtog.Size=UDim2.new(0,46,0,24); rtog.Position=UDim2.new(1,-58,0.5,-12)
	rtog.BackgroundColor3=Color3.fromRGB(38,38,38); rtog.BorderSizePixel=0; rtog.Text=""; rtog.AutoButtonColor=false
	Instance.new("UICorner",rtog).CornerRadius=UDim.new(1,0)
	local rknob=Instance.new("Frame",rtog); rknob.Size=UDim2.new(0,18,0,18); rknob.Position=UDim2.new(0,3,0.5,-9); rknob.BackgroundColor3=Color3.fromRGB(110,110,110); rknob.BorderSizePixel=0; Instance.new("UICorner",rknob).CornerRadius=UDim.new(1,0)
	rtog.MouseButton1Click:Connect(function()
		reachActive=not reachActive
		TweenService:Create(rtog,TIF,{BackgroundColor3=reachActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(38,38,38)}):Play()
		TweenService:Create(rknob,TIF,{Position=reachActive and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),BackgroundColor3=reachActive and Color3.fromRGB(0,0,0) or Color3.fromRGB(110,110,110)}):Play()
		if reachActive then pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Fling-Things-and-People-Free-Gamepass-80386"))() end) end
	end)
	-- FOV
	local fovLbl=Instance.new("TextLabel",contentArea); fovLbl.Size=UDim2.new(1,-28,0,16); fovLbl.Position=UDim2.new(0,14,0,128)
	fovLbl.BackgroundTransparency=1; fovLbl.Text="FOV"; fovLbl.TextColor3=Color3.fromRGB(60,60,60); fovLbl.TextSize=10; fovLbl.Font=Enum.Font.GothamBold; fovLbl.TextXAlignment=Enum.TextXAlignment.Left
	local fovCard=Instance.new("Frame",contentArea); fovCard.Size=UDim2.new(1,-28,0,76); fovCard.Position=UDim2.new(0,14,0,148)
	fovCard.BackgroundColor3=Color3.fromRGB(14,14,14); fovCard.BorderSizePixel=0
	Instance.new("UICorner",fovCard).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",fovCard).Color=Color3.fromRGB(30,30,30)
	local ftl=Instance.new("TextLabel",fovCard); ftl.Size=UDim2.new(1,-70,0,18); ftl.Position=UDim2.new(0,12,0,8)
	ftl.BackgroundTransparency=1; ftl.Text="Field of View"; ftl.TextColor3=Color3.fromRGB(225,225,225); ftl.TextSize=13; ftl.Font=Enum.Font.GothamSemibold; ftl.TextXAlignment=Enum.TextXAlignment.Left
	local fovValLbl=Instance.new("TextLabel",fovCard); fovValLbl.Size=UDim2.new(0,55,0,18); fovValLbl.Position=UDim2.new(1,-65,0,8)
	fovValLbl.BackgroundTransparency=1; fovValLbl.Text=tostring(math.floor(camera.FieldOfView)); fovValLbl.TextColor3=Color3.fromRGB(255,255,255); fovValLbl.TextSize=13; fovValLbl.Font=Enum.Font.GothamBold; fovValLbl.TextXAlignment=Enum.TextXAlignment.Right
	local fovTrack=Instance.new("Frame",fovCard); fovTrack.Size=UDim2.new(1,-24,0,6); fovTrack.Position=UDim2.new(0,12,0,40)
	fovTrack.BackgroundColor3=Color3.fromRGB(36,36,36); fovTrack.BorderSizePixel=0; Instance.new("UICorner",fovTrack).CornerRadius=UDim.new(1,0)
	local fovR=math.clamp((camera.FieldOfView-30)/(150-30),0,1)
	local fovFill=Instance.new("Frame",fovTrack); fovFill.Size=UDim2.new(fovR,0,1,0); fovFill.BackgroundColor3=Color3.fromRGB(255,255,255); fovFill.BorderSizePixel=0; Instance.new("UICorner",fovFill).CornerRadius=UDim.new(1,0)
	local fovHandle=Instance.new("TextButton",fovTrack); fovHandle.Size=UDim2.new(0,16,0,16); fovHandle.Position=UDim2.new(fovR,-8,0.5,-8)
	fovHandle.BackgroundColor3=Color3.fromRGB(255,255,255); fovHandle.BorderSizePixel=0; fovHandle.Text=""; fovHandle.AutoButtonColor=false; fovHandle.ZIndex=5
	Instance.new("UICorner",fovHandle).CornerRadius=UDim.new(1,0)
	local fovPresets={{70},{90},{110},{130},{150}}
	local presetRow=Instance.new("Frame",fovCard); presetRow.Size=UDim2.new(1,-24,0,18); presetRow.Position=UDim2.new(0,12,0,56); presetRow.BackgroundTransparency=1
	for i,fp in ipairs(fovPresets) do
		local pb=Instance.new("TextButton",presetRow); pb.Size=UDim2.new(0,36,0,18); pb.Position=UDim2.new(0,(i-1)*44,0,0)
		pb.BackgroundColor3=Color3.fromRGB(28,28,28); pb.BorderSizePixel=0; pb.Text=tostring(fp[1]); pb.TextColor3=Color3.fromRGB(160,160,160); pb.TextSize=11; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,6)
		pb.MouseButton1Click:Connect(function()
			camera.FieldOfView=fp[1]; fovValLbl.Text=tostring(fp[1])
			local r=math.clamp((fp[1]-30)/(150-30),0,1); fovFill.Size=UDim2.new(r,0,1,0); fovHandle.Position=UDim2.new(r,-8,0.5,-8)
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(42,42,42)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(28,28,28)}):Play() end)
	end
	local fovDragging=false
	fovHandle.MouseButton1Down:Connect(function() fovDragging=true end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then fovDragging=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if fovDragging and i.UserInputType==Enum.UserInputType.MouseMovement then
			local rel=math.clamp((i.Position.X-fovTrack.AbsolutePosition.X)/fovTrack.AbsoluteSize.X,0,1)
			local val=math.floor(30+rel*(150-30)); fovFill.Size=UDim2.new(rel,0,1,0); fovHandle.Position=UDim2.new(rel,-8,0.5,-8)
			fovValLbl.Text=tostring(val); camera.FieldOfView=val
		end
	end)
	-- Сброс FOV
	local fovReset=Instance.new("TextButton",contentArea); fovReset.Size=UDim2.new(1,-28,0,32); fovReset.Position=UDim2.new(0,14,0,232)
	fovReset.BackgroundColor3=Color3.fromRGB(18,18,18); fovReset.BorderSizePixel=0; fovReset.Text="Сбросить FOV (70)"; fovReset.TextColor3=Color3.fromRGB(120,120,120); fovReset.TextSize=12; fovReset.Font=Enum.Font.GothamSemibold; fovReset.AutoButtonColor=false
	Instance.new("UICorner",fovReset).CornerRadius=UDim.new(0,8)
	fovReset.MouseButton1Click:Connect(function() camera.FieldOfView=70; fovValLbl.Text="70"; local r=(70-30)/(150-30); fovFill.Size=UDim2.new(r,0,1,0); fovHandle.Position=UDim2.new(r,-8,0.5,-8) end)
	-- COMMANDS
	local cmdLbl=Instance.new("TextLabel",contentArea); cmdLbl.Size=UDim2.new(1,-28,0,16); cmdLbl.Position=UDim2.new(0,14,0,278)
	cmdLbl.BackgroundTransparency=1; cmdLbl.Text="COMMANDS"; cmdLbl.TextColor3=Color3.fromRGB(60,60,60); cmdLbl.TextSize=10; cmdLbl.Font=Enum.Font.GothamBold; cmdLbl.TextXAlignment=Enum.TextXAlignment.Left
	local cmdLoaded=false
	local cmdCard=Instance.new("Frame",contentArea); cmdCard.Size=UDim2.new(1,-28,0,50); cmdCard.Position=UDim2.new(0,14,0,298)
	cmdCard.BackgroundColor3=Color3.fromRGB(14,14,14); cmdCard.BorderSizePixel=0
	Instance.new("UICorner",cmdCard).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",cmdCard).Color=Color3.fromRGB(30,30,30)
	local ctl=Instance.new("TextLabel",cmdCard); ctl.Size=UDim2.new(1,-80,0,20); ctl.Position=UDim2.new(0,12,0,8)
	ctl.BackgroundTransparency=1; ctl.Text="Infinity Yield Commands"; ctl.TextColor3=Color3.fromRGB(225,225,225); ctl.TextSize=13; ctl.Font=Enum.Font.GothamSemibold; ctl.TextXAlignment=Enum.TextXAlignment.Left
	local csl=Instance.new("TextLabel",cmdCard); csl.Size=UDim2.new(1,-80,0,14); csl.Position=UDim2.new(0,12,0,29)
	csl.BackgroundTransparency=1; csl.Text="Universal admin commands"; csl.TextColor3=Color3.fromRGB(60,60,60); csl.TextSize=11; csl.Font=Enum.Font.Gotham; csl.TextXAlignment=Enum.TextXAlignment.Left
	local ctog=Instance.new("TextButton",cmdCard); ctog.Size=UDim2.new(0,46,0,24); ctog.Position=UDim2.new(1,-58,0.5,-12)
	ctog.BackgroundColor3=Color3.fromRGB(38,38,38); ctog.BorderSizePixel=0; ctog.Text=""; ctog.AutoButtonColor=false
	Instance.new("UICorner",ctog).CornerRadius=UDim.new(1,0)
	local cknob=Instance.new("Frame",ctog); cknob.Size=UDim2.new(0,18,0,18); cknob.Position=UDim2.new(0,3,0.5,-9); cknob.BackgroundColor3=Color3.fromRGB(110,110,110); cknob.BorderSizePixel=0; Instance.new("UICorner",cknob).CornerRadius=UDim.new(1,0)
	local cmdStatus=Instance.new("TextLabel",contentArea); cmdStatus.Size=UDim2.new(1,-28,0,20); cmdStatus.Position=UDim2.new(0,16,0,354)
	cmdStatus.BackgroundTransparency=1; cmdStatus.Text=""; cmdStatus.TextSize=11; cmdStatus.Font=Enum.Font.GothamSemibold; cmdStatus.TextXAlignment=Enum.TextXAlignment.Left
	ctog.MouseButton1Click:Connect(function()
		if cmdLoaded then return end; cmdLoaded=true
		TweenService:Create(ctog,TIF,{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
		TweenService:Create(cknob,TIF,{Position=UDim2.new(1,-21,0.5,-9),BackgroundColor3=Color3.fromRGB(0,0,0)}):Play()
		cmdStatus.Text="Загружается..."; cmdStatus.TextColor3=Color3.fromRGB(160,160,160)
		task.spawn(function()
			local ok=pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Infinity-Yield-94242"))() end)
			if ok then cmdStatus.Text="Infinity Yield загружен!"; cmdStatus.TextColor3=Color3.fromRGB(80,200,100)
			else cmdStatus.Text="Ошибка загрузки"; cmdStatus.TextColor3=Color3.fromRGB(255,70,70); cmdLoaded=false
				TweenService:Create(ctog,TIF,{BackgroundColor3=Color3.fromRGB(38,38,38)}):Play()
				TweenService:Create(cknob,TIF,{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(110,110,110)}):Play()
			end
		end)
	end)
end

local function buildSpeedPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,420)
	hdr(contentArea,"SPEED","Скорость и прыжок персонажа",14); divLine(contentArea,55)
	local wsLbl=makeSlider(contentArea,"WalkSpeed",64,16,300,16,function(v)
		local char=player.Character; if char then local h=char:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v end end
	end)
	local spPresets={{"Норм",16},{"Быстро",50},{"Очень",100},{"Турбо",250}}
	for i,sp in ipairs(spPresets) do
		local pb=Instance.new("TextButton",contentArea); pb.Size=UDim2.new(0,118,0,38); pb.Position=UDim2.new(0,14+(i-1)%2*136,0,130+math.floor((i-1)/2)*46)
		pb.BackgroundColor3=Color3.fromRGB(16,16,16); pb.BorderSizePixel=0; pb.Text=sp[1].."  ("..sp[2]..")"; pb.TextColor3=Color3.fromRGB(190,190,190); pb.TextSize=12; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,9); Instance.new("UIStroke",pb).Color=Color3.fromRGB(30,30,30)
		pb.MouseButton1Click:Connect(function()
			local char=player.Character; if char then local h=char:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=sp[2] end end
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
	end
	divLine(contentArea,228)
	local jlbl=Instance.new("TextLabel",contentArea); jlbl.Size=UDim2.new(1,-28,0,16); jlbl.Position=UDim2.new(0,14,0,238)
	jlbl.BackgroundTransparency=1; jlbl.Text="ПРЫЖОК"; jlbl.TextColor3=Color3.fromRGB(60,60,60); jlbl.TextSize=10; jlbl.Font=Enum.Font.GothamBold; jlbl.TextXAlignment=Enum.TextXAlignment.Left
	local jPresets={{"Норм",50},{"Высоко",100},{"Луна",200},{"Космос",500}}
	for i,jp in ipairs(jPresets) do
		local pb=Instance.new("TextButton",contentArea); pb.Size=UDim2.new(0,118,0,38); pb.Position=UDim2.new(0,14+(i-1)%2*136,0,258+math.floor((i-1)/2)*46)
		pb.BackgroundColor3=Color3.fromRGB(16,16,16); pb.BorderSizePixel=0; pb.Text=jp[1].."  ("..jp[2]..")"; pb.TextColor3=Color3.fromRGB(190,190,190); pb.TextSize=12; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,9); Instance.new("UIStroke",pb).Color=Color3.fromRGB(30,30,30)
		pb.MouseButton1Click:Connect(function()
			local char=player.Character; if char then local h=char:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=jp[2] end end
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
	end
end

local function buildEspPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,600)
	hdr(contentArea,"ESP","Карточки игроков над головой",14); divLine(contentArea,55)
	local function removeAllEsp()
		for _,v in pairs(espBillboards) do pcall(function() v:Destroy() end) end
		for _,v in pairs(espBoxes) do pcall(function() v:Destroy() end) end
		espBillboards={}; espBoxes={}
	end
	local function createEspFor(p)
		if not p.Character then return end
		local hrp=p.Character:FindFirstChild("HumanoidRootPart"); local head=p.Character:FindFirstChild("Head"); if not hrp then return end
		local box=Instance.new("SelectionBox"); box.Color3=espColor; box.LineThickness=0.04; box.SurfaceTransparency=0.92; box.SurfaceColor3=espColor; box.Adornee=p.Character; box.Parent=workspace; espBoxes[p.Name]=box
		local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,170,0,58); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true; bb.MaxDistance=500; bb.Adornee=head or hrp; bb.Parent=workspace
		local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(6,6,6); bg.BackgroundTransparency=0.25; bg.BorderSizePixel=0; Instance.new("UICorner",bg).CornerRadius=UDim.new(0,8)
		local bgs=Instance.new("UIStroke",bg); bgs.Color=espColor; bgs.Thickness=1.5; bgs.Transparency=0.3
		local av=Instance.new("Frame",bg); av.Size=UDim2.new(0,40,0,40); av.Position=UDim2.new(0,6,0.5,-20); av.BackgroundColor3=espColor; av.BackgroundTransparency=0.7; av.BorderSizePixel=0; Instance.new("UICorner",av).CornerRadius=UDim.new(0,6)
		local avl=Instance.new("TextLabel",av); avl.Size=UDim2.new(1,0,1,0); avl.BackgroundTransparency=1; avl.Text=string.upper(string.sub(p.Name,1,2)); avl.TextColor3=Color3.fromRGB(255,255,255); avl.TextSize=16; avl.Font=Enum.Font.GothamBold
		local nl=Instance.new("TextLabel",bg); nl.Size=UDim2.new(1,-56,0,18); nl.Position=UDim2.new(0,52,0,7); nl.BackgroundTransparency=1; nl.Text=p.Name; nl.TextColor3=Color3.fromRGB(255,255,255); nl.TextSize=13; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.TextTruncate=Enum.TextTruncate.AtEnd
		local dl=Instance.new("TextLabel",bg); dl.Name="DistLbl"; dl.Size=UDim2.new(1,-56,0,14); dl.Position=UDim2.new(0,52,0,28); dl.BackgroundTransparency=1; dl.Text="-- м"; dl.TextColor3=Color3.fromRGB(160,160,160); dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left
		local hpBg=Instance.new("Frame",bg); hpBg.Size=UDim2.new(1,-56,0,4); hpBg.Position=UDim2.new(0,52,0,45); hpBg.BackgroundColor3=Color3.fromRGB(35,35,35); hpBg.BorderSizePixel=0; Instance.new("UICorner",hpBg).CornerRadius=UDim.new(1,0)
		local hpFill=Instance.new("Frame",hpBg); hpFill.Name="HpFill"; hpFill.Size=UDim2.new(1,0,1,0); hpFill.BackgroundColor3=Color3.fromRGB(80,220,100); hpFill.BorderSizePixel=0; Instance.new("UICorner",hpFill).CornerRadius=UDim.new(1,0)
		espBillboards[p.Name]=bb
	end
	local function rebuildEsp()
		removeAllEsp(); if not espActive then return end
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=player then
				if espTargetOnly==nil or espTargetOnly==p.Name then createEspFor(p)
				else
					if p.Character then
						local b=Instance.new("SelectionBox"); b.Color3=Color3.fromRGB(40,40,40); b.LineThickness=0.02; b.SurfaceTransparency=0.98; b.Adornee=p.Character; b.Parent=workspace; espBoxes[p.Name.."_dim"]=b
					end
				end
			end
		end
	end
	makeToggleCard(contentArea,"ESP включить","Карточки + боксы над игроками",64,espActive,function(v) espActive=v; rebuildEsp() end)
	-- Цвета
	local cs=Instance.new("TextLabel",contentArea); cs.Size=UDim2.new(1,-28,0,16); cs.Position=UDim2.new(0,14,0,128); cs.BackgroundTransparency=1; cs.Text="ЦВЕТ"; cs.TextColor3=Color3.fromRGB(60,60,60); cs.TextSize=10; cs.Font=Enum.Font.GothamBold; cs.TextXAlignment=Enum.TextXAlignment.Left
	local colors={{"Белый",Color3.fromRGB(255,255,255)},{"Красный",Color3.fromRGB(255,60,60)},{"Зелёный",Color3.fromRGB(60,230,90)},{"Синий",Color3.fromRGB(60,130,255)},{"Жёлтый",Color3.fromRGB(255,215,45)},{"Фиолет",Color3.fromRGB(185,60,255)}}
	for i,col in ipairs(colors) do
		local cb=Instance.new("TextButton",contentArea); cb.Size=UDim2.new(0,86,0,32); cb.Position=UDim2.new(0,14+(i-1)%3*98,0,148+math.floor((i-1)/3)*40); cb.BackgroundColor3=Color3.fromRGB(14,14,14); cb.BorderSizePixel=0; cb.Text=col[1]; cb.TextColor3=Color3.fromRGB(185,185,185); cb.TextSize=12; cb.Font=Enum.Font.GothamSemibold; cb.AutoButtonColor=false; Instance.new("UICorner",cb).CornerRadius=UDim.new(0,8)
		local stripe=Instance.new("Frame",cb); stripe.Size=UDim2.new(0,3,0.55,0); stripe.Position=UDim2.new(0,0,0.22,0); stripe.BackgroundColor3=col[2]; stripe.BorderSizePixel=0; Instance.new("UICorner",stripe).CornerRadius=UDim.new(1,0)
		cb.MouseButton1Click:Connect(function() espColor=col[2]; for _,b in pairs(espBoxes) do pcall(function() b.Color3=col[2]; b.SurfaceColor3=col[2] end) end; rebuildEsp() end)
		cb.MouseEnter:Connect(function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(22,22,22)}):Play() end)
		cb.MouseLeave:Connect(function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(14,14,14)}):Play() end)
	end
	-- Список игроков
	local ts=Instance.new("TextLabel",contentArea); ts.Size=UDim2.new(1,-28,0,16); ts.Position=UDim2.new(0,14,0,242); ts.BackgroundTransparency=1; ts.Text="ВЫБРАТЬ ЦЕЛЬ"; ts.TextColor3=Color3.fromRGB(60,60,60); ts.TextSize=10; ts.Font=Enum.Font.GothamBold; ts.TextXAlignment=Enum.TextXAlignment.Left
	local allBtn=Instance.new("TextButton",contentArea); allBtn.Size=UDim2.new(1,-28,0,36); allBtn.Position=UDim2.new(0,14,0,262); allBtn.BackgroundColor3=espTargetOnly==nil and Color3.fromRGB(255,255,255) or Color3.fromRGB(14,14,14); allBtn.BorderSizePixel=0; allBtn.Text="  Все игроки"; allBtn.TextColor3=espTargetOnly==nil and Color3.fromRGB(0,0,0) or Color3.fromRGB(160,160,160); allBtn.TextSize=13; allBtn.Font=Enum.Font.GothamSemibold; allBtn.TextXAlignment=Enum.TextXAlignment.Left; allBtn.AutoButtonColor=false; Instance.new("UICorner",allBtn).CornerRadius=UDim.new(0,9)
	allBtn.MouseButton1Click:Connect(function() espTargetOnly=nil; rebuildEsp(); buildEspPage() end)
	local yOff=306
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=player then
			local isT=espTargetOnly==p.Name
			local pb=Instance.new("TextButton",contentArea); pb.Size=UDim2.new(1,-28,0,46); pb.Position=UDim2.new(0,14,0,yOff); pb.BackgroundColor3=isT and Color3.fromRGB(22,22,22) or Color3.fromRGB(12,12,12); pb.BorderSizePixel=0; pb.Text=""; pb.AutoButtonColor=false; Instance.new("UICorner",pb).CornerRadius=UDim.new(0,10)
			local pbs=Instance.new("UIStroke",pb); pbs.Color=isT and Color3.fromRGB(200,200,200) or Color3.fromRGB(28,28,28); pbs.Thickness=1
			local av=Instance.new("Frame",pb); av.Size=UDim2.new(0,32,0,32); av.Position=UDim2.new(0,8,0.5,-16); av.BackgroundColor3=Color3.fromRGB(30,30,30); av.BorderSizePixel=0; Instance.new("UICorner",av).CornerRadius=UDim.new(0,8)
			local avl=Instance.new("TextLabel",av); avl.Size=UDim2.new(1,0,1,0); avl.BackgroundTransparency=1; avl.Text=string.upper(string.sub(p.Name,1,2)); avl.TextColor3=Color3.fromRGB(220,220,220); avl.TextSize=13; avl.Font=Enum.Font.GothamBold
			local nl=Instance.new("TextLabel",pb); nl.Size=UDim2.new(1,-90,0,18); nl.Position=UDim2.new(0,48,0,7); nl.BackgroundTransparency=1; nl.Text=p.Name; nl.TextColor3=Color3.fromRGB(230,230,230); nl.TextSize=13; nl.Font=Enum.Font.GothamSemibold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.TextTruncate=Enum.TextTruncate.AtEnd
			local myH=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); local pH=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			local dl=Instance.new("TextLabel",pb); dl.Size=UDim2.new(1,-90,0,14); dl.Position=UDim2.new(0,48,0,27); dl.BackgroundTransparency=1; dl.Text=(myH and pH) and tostring(math.floor((myH.Position-pH.Position).Magnitude)).." м" or "-- м"; dl.TextColor3=Color3.fromRGB(80,80,80); dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left
			if isT then local dot=Instance.new("Frame",pb); dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(1,-16,0.5,-3); dot.BackgroundColor3=Color3.fromRGB(255,255,255); dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0) end
			pb.MouseButton1Click:Connect(function() espTargetOnly=isT and nil or p.Name; rebuildEsp(); buildEspPage() end)
			pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(20,20,20)}):Play() end)
			pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=isT and Color3.fromRGB(22,22,22) or Color3.fromRGB(12,12,12)}):Play() end)
			yOff=yOff+54
		end
	end
	contentArea.CanvasSize=UDim2.new(0,0,0,yOff+20)
	-- Дистанция обновление
	task.spawn(function()
		while espActive do
			task.wait(0.5)
			local myH=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not myH then continue end
			for pname,bb in pairs(espBillboards) do
				local p=Players:FindFirstChild(pname); if not p or not p.Character then continue end
				local pH=p.Character:FindFirstChild("HumanoidRootPart"); local hum=p.Character:FindFirstChildOfClass("Humanoid")
				if pH then local dist=math.floor((myH.Position-pH.Position).Magnitude); for _,d in ipairs(bb:GetDescendants()) do if d.Name=="DistLbl" then d.Text=tostring(dist).." м" end end end
				if hum then local r=math.clamp(hum.Health/hum.MaxHealth,0,1); for _,d in ipairs(bb:GetDescendants()) do if d.Name=="HpFill" then d.Size=UDim2.new(r,0,1,0); d.BackgroundColor3=r>0.6 and Color3.fromRGB(80,220,100) or r>0.3 and Color3.fromRGB(240,180,40) or Color3.fromRGB(240,60,60) end end end
			end
		end
	end)
end

local function buildNoclipPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,340)
	hdr(contentArea,"NOCLIP","Проходить сквозь стены",14); divLine(contentArea,55)
	local function applyNoclip(s)
		noclipActive=s
		if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
		if s then
			noclipConn=RunService.Stepped:Connect(function()
				local char=player.Character; if not char then return end
				for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end
			end)
		else
			local char=player.Character; if not char then return end
			for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
		end
	end
	makeToggleCard(contentArea,"NoClip","Проходить сквозь всё",64,noclipActive,function(v) applyNoclip(v) end)
	divLine(contentArea,126)
	local tpl=Instance.new("TextLabel",contentArea); tpl.Size=UDim2.new(1,-28,0,16); tpl.Position=UDim2.new(0,14,0,136); tpl.BackgroundTransparency=1; tpl.Text="ТЕЛЕПОРТ"; tpl.TextColor3=Color3.fromRGB(60,60,60); tpl.TextSize=10; tpl.Font=Enum.Font.GothamBold; tpl.TextXAlignment=Enum.TextXAlignment.Left
	card(contentArea,"Телепорт к прицелу","Телепорт туда куда смотришь",156,function()
		local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		local ray=workspace:Raycast(camera.CFrame.Position,camera.CFrame.LookVector*1000)
		if ray then hrp.CFrame=CFrame.new(ray.Position+Vector3.new(0,3,0)) end
	end)
	card(contentArea,"Телепорт к случайному игроку","Мгновенный телепорт к другому игроку",214,function()
		local others={}; for _,p in ipairs(Players:GetPlayers()) do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(others,p) end end
		if #others==0 then return end
		local target=others[math.random(1,#others)]; local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		hrp.CFrame=target.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3)
	end)
end

-- ══════════════════════════════
--   SHADERS
-- ══════════════════════════════

local function clearShaders()
	for _,v in ipairs(Lighting:GetChildren()) do
		if v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then v:Destroy() end
	end
	Lighting.Brightness=2; Lighting.Ambient=Color3.fromRGB(70,70,70); Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
	Lighting.FogEnd=100000; Lighting.FogColor=Color3.fromRGB(192,192,192); Lighting.ExposureCompensation=0
end

local shaders={
	{name="Cinematic",     desc="Тёмные края, контраст, кино",         preview=Color3.fromRGB(220,215,200),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=-0.05; cc.Contrast=0.25; cc.Saturation=0.1; cc.TintColor=Color3.fromRGB(240,235,225); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=0.4; bl.Size=24; bl.Threshold=0.95; local sr=Instance.new("SunRaysEffect",Lighting); sr.Intensity=0.08; sr.Spread=0.5; Lighting.Brightness=1.8; Lighting.ExposureCompensation=-0.2 end},
	{name="Retro",         desc="Тёплые тона, выцветший стиль",        preview=Color3.fromRGB(255,220,170),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=0.05; cc.Contrast=-0.1; cc.Saturation=-0.3; cc.TintColor=Color3.fromRGB(255,235,200); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=0.6; bl.Size=30; bl.Threshold=0.8; Lighting.Brightness=2.5; Lighting.Ambient=Color3.fromRGB(90,75,60); Lighting.ExposureCompensation=0.15 end},
	{name="Midnight",      desc="Синяя ночь, холодный воздух",         preview=Color3.fromRGB(100,130,220),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=-0.2; cc.Contrast=0.3; cc.Saturation=0.2; cc.TintColor=Color3.fromRGB(180,200,255); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=0.8; bl.Size=40; bl.Threshold=0.7; Lighting.Brightness=0.3; Lighting.ClockTime=1; Lighting.Ambient=Color3.fromRGB(15,20,50); Lighting.ExposureCompensation=0.3 end},
	{name="Neon City",     desc="Яркий неон, киберпанк атмосфера",     preview=Color3.fromRGB(200,120,255),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=0.1; cc.Contrast=0.4; cc.Saturation=0.8; cc.TintColor=Color3.fromRGB(220,180,255); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=2; bl.Size=56; bl.Threshold=0.5; Lighting.Brightness=0.5; Lighting.ClockTime=0; Lighting.Ambient=Color3.fromRGB(20,5,40); Lighting.ExposureCompensation=0.5 end},
	{name="Anime",         desc="Насыщенные цвета, аниме стиль",       preview=Color3.fromRGB(245,200,255),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=0.08; cc.Contrast=0.15; cc.Saturation=0.6; cc.TintColor=Color3.fromRGB(245,240,255); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=0.9; bl.Size=28; bl.Threshold=0.85; local sr=Instance.new("SunRaysEffect",Lighting); sr.Intensity=0.15; sr.Spread=0.8; Lighting.Brightness=2.8; Lighting.ExposureCompensation=0.1 end},
	{name="Horror",        desc="Красный туман, жуткая атмосфера",     preview=Color3.fromRGB(160,30,30),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=-0.3; cc.Contrast=0.5; cc.Saturation=-0.4; cc.TintColor=Color3.fromRGB(255,180,180); Lighting.FogEnd=120; Lighting.FogStart=10; Lighting.FogColor=Color3.fromRGB(80,10,10); Lighting.Brightness=0.4; Lighting.ClockTime=0; Lighting.Ambient=Color3.fromRGB(40,5,5); Lighting.ExposureCompensation=-0.1 end},
	{name="Desert Heat",   desc="Жаркое солнце, жёлтый песок",         preview=Color3.fromRGB(255,210,100),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=0.12; cc.Contrast=0.2; cc.Saturation=0.3; cc.TintColor=Color3.fromRGB(255,240,190); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=1.2; bl.Size=50; bl.Threshold=0.75; local sr=Instance.new("SunRaysEffect",Lighting); sr.Intensity=0.25; sr.Spread=1; Lighting.Brightness=4; Lighting.ClockTime=13; Lighting.Ambient=Color3.fromRGB(130,100,50); Lighting.ExposureCompensation=0.2 end},
	{name="Underwater",    desc="Синяя глубина, туман воды",            preview=Color3.fromRGB(40,100,200),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=-0.15; cc.Contrast=0.1; cc.Saturation=0.4; cc.TintColor=Color3.fromRGB(100,180,255); Lighting.FogEnd=80; Lighting.FogStart=5; Lighting.FogColor=Color3.fromRGB(20,80,160); Lighting.Brightness=1; Lighting.Ambient=Color3.fromRGB(10,40,90); Lighting.ExposureCompensation=0.1 end},
	{name="Vintage Film",  desc="Сепия, выцвет, старое кино",           preview=Color3.fromRGB(210,185,140),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=-0.02; cc.Contrast=0.08; cc.Saturation=-0.6; cc.TintColor=Color3.fromRGB(255,230,190); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=0.3; bl.Size=20; bl.Threshold=0.9; Lighting.Brightness=2; Lighting.ExposureCompensation=-0.05; Lighting.Ambient=Color3.fromRGB(85,70,50) end},
	{name="Arctic",        desc="Снежная белизна, холодный свет",       preview=Color3.fromRGB(200,220,255),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=0.2; cc.Contrast=0.1; cc.Saturation=-0.2; cc.TintColor=Color3.fromRGB(220,235,255); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=1.5; bl.Size=60; bl.Threshold=0.6; Lighting.Brightness=3.5; Lighting.ClockTime=12; Lighting.Ambient=Color3.fromRGB(160,180,210); Lighting.ExposureCompensation=0.3 end},
	{name="Golden Hour",   desc="Закат, золотой свет и тени",           preview=Color3.fromRGB(255,180,60),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=0.05; cc.Contrast=0.2; cc.Saturation=0.5; cc.TintColor=Color3.fromRGB(255,215,150); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=1; bl.Size=35; bl.Threshold=0.7; local sr=Instance.new("SunRaysEffect",Lighting); sr.Intensity=0.35; sr.Spread=1; Lighting.Brightness=2.5; Lighting.ClockTime=18.5; Lighting.Ambient=Color3.fromRGB(120,80,30); Lighting.ExposureCompensation=0.1 end},
	{name="Matrix",        desc="Зелёный монохром, хакер стиль",        preview=Color3.fromRGB(50,220,80),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=-0.1; cc.Contrast=0.5; cc.Saturation=-1; cc.TintColor=Color3.fromRGB(100,255,120); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=1.5; bl.Size=40; bl.Threshold=0.6; Lighting.Brightness=0.8; Lighting.ClockTime=0; Lighting.Ambient=Color3.fromRGB(0,30,0); Lighting.ExposureCompensation=0.2 end},
	{name="Dream",         desc="Мягкий розово-белый туман",            preview=Color3.fromRGB(255,200,230),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=0.15; cc.Contrast=-0.05; cc.Saturation=0.3; cc.TintColor=Color3.fromRGB(255,220,240); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=2.5; bl.Size=70; bl.Threshold=0.4; Lighting.Brightness=3; Lighting.Ambient=Color3.fromRGB(180,140,180); Lighting.ExposureCompensation=0.4 end},
	{name="Nuclear",       desc="Жёлто-зелёный радиоактивный свет",    preview=Color3.fromRGB(180,255,50),
	 apply=function() local cc=Instance.new("ColorCorrectionEffect",Lighting); cc.Brightness=0.1; cc.Contrast=0.35; cc.Saturation=0.7; cc.TintColor=Color3.fromRGB(200,255,150); local bl=Instance.new("BloomEffect",Lighting); bl.Intensity=1.8; bl.Size=45; bl.Threshold=0.55; Lighting.FogEnd=200; Lighting.FogStart=50; Lighting.FogColor=Color3.fromRGB(60,100,10); Lighting.Brightness=1.2; Lighting.Ambient=Color3.fromRGB(30,60,5); Lighting.ExposureCompensation=0.25 end},
}

local function buildShaderPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,100+#shaders*68)
	hdr(contentArea,"SHADERS","Визуальные эффекты освещения",14); divLine(contentArea,55)
	-- Кнопка сброса
	local resetBtn=Instance.new("TextButton",contentArea); resetBtn.Size=UDim2.new(1,-28,0,36); resetBtn.Position=UDim2.new(0,14,0,64)
	resetBtn.BackgroundColor3=Color3.fromRGB(18,18,18); resetBtn.BorderSizePixel=0; resetBtn.Text="Сбросить все шейдеры"; resetBtn.TextColor3=Color3.fromRGB(120,120,120); resetBtn.TextSize=12; resetBtn.Font=Enum.Font.GothamSemibold; resetBtn.AutoButtonColor=false
	Instance.new("UICorner",resetBtn).CornerRadius=UDim.new(0,9); Instance.new("UIStroke",resetBtn).Color=Color3.fromRGB(35,35,35)
	resetBtn.MouseButton1Click:Connect(function() activeShader=nil; clearShaders(); buildShaderPage() end)
	resetBtn.MouseEnter:Connect(function() TweenService:Create(resetBtn,TIF,{BackgroundColor3=Color3.fromRGB(28,28,28)}):Play() end)
	resetBtn.MouseLeave:Connect(function() TweenService:Create(resetBtn,TIF,{BackgroundColor3=Color3.fromRGB(18,18,18)}):Play() end)
	-- Список шейдеров
	for i,sh in ipairs(shaders) do
		local isActive=activeShader==sh.name
		local c=Instance.new("TextButton",contentArea); c.Size=UDim2.new(1,-28,0,56); c.Position=UDim2.new(0,14,0,108+(i-1)*64)
		c.BackgroundColor3=isActive and Color3.fromRGB(20,20,20) or Color3.fromRGB(11,11,11); c.BorderSizePixel=0; c.Text=""; c.AutoButtonColor=false
		Instance.new("UICorner",c).CornerRadius=UDim.new(0,10)
		local cs=Instance.new("UIStroke",c); cs.Color=isActive and Color3.fromRGB(220,220,220) or Color3.fromRGB(28,28,28); cs.Thickness=1
		-- Цветная полоска превью
		local preview=Instance.new("Frame",c); preview.Size=UDim2.new(0,5,0.65,0); preview.Position=UDim2.new(0,0,0.175,0); preview.BackgroundColor3=sh.preview; preview.BorderSizePixel=0; Instance.new("UICorner",preview).CornerRadius=UDim.new(0,3)
		local nl=Instance.new("TextLabel",c); nl.Size=UDim2.new(1,-60,0,20); nl.Position=UDim2.new(0,14,0,9); nl.BackgroundTransparency=1; nl.Text=sh.name; nl.TextColor3=Color3.fromRGB(230,230,230); nl.TextSize=14; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left
		local dl=Instance.new("TextLabel",c); dl.Size=UDim2.new(1,-60,0,14); dl.Position=UDim2.new(0,14,0,31); dl.BackgroundTransparency=1; dl.Text=sh.desc; dl.TextColor3=Color3.fromRGB(65,65,65); dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left
		if isActive then
			local dot=Instance.new("Frame",c); dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(1,-16,0.5,-3); dot.BackgroundColor3=Color3.fromRGB(255,255,255); dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
		end
		c.MouseButton1Click:Connect(function()
			if activeShader==sh.name then activeShader=nil; clearShaders()
			else activeShader=sh.name; clearShaders(); sh.apply() end
			buildShaderPage()
		end)
		c.MouseEnter:Connect(function() if not isActive then TweenService:Create(c,TIF,{BackgroundColor3=Color3.fromRGB(18,18,18)}):Play() end end)
		c.MouseLeave:Connect(function() if not isActive then TweenService:Create(c,TIF,{BackgroundColor3=Color3.fromRGB(11,11,11)}):Play() end end)
	end
end

-- ══════════════════════════════
--   PARTICLES
-- ══════════════════════════════

local particleFolder = nil

local function removeAllParticles()
	if particleFolder then particleFolder:Destroy(); particleFolder=nil end
	particleEmitters={}; currentParticle=nil; particleActive=false
end

local function applyParticle(ptype)
	removeAllParticles()
	local char=player.Character; if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

	particleFolder=Instance.new("Folder",hrp); particleFolder.Name="VibeParticles"
	currentParticle=ptype; particleActive=true

	local function makeEmitter(parent, cfg)
		local att=Instance.new("Attachment",parent); att.Position=cfg.offset or Vector3.new(0,0,0)
		local pe=Instance.new("ParticleEmitter",att)
		pe.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(0,particleColor1),
			ColorSequenceKeypoint.new(1,particleColor2)
		})
		pe.LightEmission=cfg.lightEmission or 0.8
		pe.LightInfluence=cfg.lightInfluence or 0.2
		pe.Size=cfg.size or NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(0.5,0.5),NumberSequenceKeypoint.new(1,0)})
		pe.Transparency=cfg.transparency or NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.8,0.2),NumberSequenceKeypoint.new(1,1)})
		pe.Speed=cfg.speed or NumberRange.new(2,5)
		pe.Rate=cfg.rate or 20
		pe.Lifetime=cfg.lifetime or NumberRange.new(1,2)
		pe.SpreadAngle=cfg.spread or Vector2.new(30,30)
		pe.Rotation=cfg.rotation or NumberRange.new(0,360)
		pe.RotSpeed=cfg.rotSpeed or NumberRange.new(-90,90)
		pe.VelocityInheritance=cfg.velInherit or 0.1
		if cfg.texture then pe.Texture=cfg.texture end
		if cfg.acceleration then pe.Acceleration=cfg.acceleration end
		table.insert(particleEmitters,pe)
		return pe
	end

	if ptype=="star" then
		-- Звёзды вокруг тела
		makeEmitter(hrp,{texture="rbxassetid://6042583378",rate=25,speed=NumberRange.new(2,6),lifetime=NumberRange.new(1.5,3),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(0.5,0.6),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(45,45),lightEmission=1})
		-- Вторая волна более редкая
		makeEmitter(hrp,{texture="rbxassetid://6042583378",rate=8,speed=NumberRange.new(5,10),lifetime=NumberRange.new(2,4),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.5,0.8),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(60,60),lightEmission=1,offset=Vector3.new(0,1,0)})

	elseif ptype=="heart" then
		-- Сердечки
		makeEmitter(hrp,{texture="rbxassetid://7547440900",rate=18,speed=NumberRange.new(1,4),lifetime=NumberRange.new(1.5,3),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(0.5,0.7),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(35,35),lightEmission=0.9,acceleration=Vector3.new(0,1,0),rotation=NumberRange.new(-20,20),rotSpeed=NumberRange.new(-30,30)})
		-- Дополнительные с груди
		makeEmitter(hrp,{texture="rbxassetid://7547440900",rate=10,speed=NumberRange.new(2,5),lifetime=NumberRange.new(2,3.5),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(0.5,0.5),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(50,50),lightEmission=0.9,acceleration=Vector3.new(0,2,0),offset=Vector3.new(0,0.5,0)})

	elseif ptype=="cube" then
		-- Кубики
		makeEmitter(hrp,{texture="rbxassetid://2273224484",rate=22,speed=NumberRange.new(2,7),lifetime=NumberRange.new(1,2.5),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.35),NumberSequenceKeypoint.new(0.5,0.5),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(50,50),lightEmission=0.7,rotSpeed=NumberRange.new(-180,180),rotation=NumberRange.new(0,360)})
		makeEmitter(hrp,{texture="rbxassetid://2273224484",rate=12,speed=NumberRange.new(4,8),lifetime=NumberRange.new(1.5,3),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.5,0.65),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(70,70),lightEmission=0.7,rotSpeed=NumberRange.new(-200,200),offset=Vector3.new(0,-0.5,0)})

	elseif ptype=="smoke" then
		makeEmitter(hrp,{texture="rbxasset://fonts/placeholder.otf",rate=15,speed=NumberRange.new(1,3),lifetime=NumberRange.new(2,4),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(0.5,1.5),NumberSequenceKeypoint.new(1,2)}),transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.5,0.5),NumberSequenceKeypoint.new(1,1)}),spread=Vector2.new(20,20),lightEmission=0.1,lightInfluence=0.8,rotSpeed=NumberRange.new(-30,30)})

	elseif ptype=="fire" then
		makeEmitter(hrp,{texture="rbxassetid://298768656",rate=30,speed=NumberRange.new(3,7),lifetime=NumberRange.new(0.8,1.5),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.6),NumberSequenceKeypoint.new(0.5,0.4),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(25,25),lightEmission=1,acceleration=Vector3.new(0,4,0),rotation=NumberRange.new(0,360),rotSpeed=NumberRange.new(-60,60)})
		makeEmitter(hrp,{texture="rbxassetid://298768656",rate=15,speed=NumberRange.new(5,10),lifetime=NumberRange.new(1,2),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(0.5,0.7),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(40,40),lightEmission=1,acceleration=Vector3.new(0,5,0),offset=Vector3.new(0,1,0)})

	elseif ptype=="sparkle" then
		makeEmitter(hrp,{texture="rbxassetid://6042583378",rate=40,speed=NumberRange.new(1,8),lifetime=NumberRange.new(0.5,1.5),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(0.3,0.35),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(80,80),lightEmission=1,rotSpeed=NumberRange.new(-200,200)})

	elseif ptype=="snow" then
		makeEmitter(hrp,{texture="rbxassetid://243728166",rate=25,speed=NumberRange.new(1,3),lifetime=NumberRange.new(3,6),size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.25),NumberSequenceKeypoint.new(0.5,0.3),NumberSequenceKeypoint.new(1,0)}),spread=Vector2.new(60,60),lightEmission=0.5,lightInfluence=0.6,acceleration=Vector3.new(0,-1,0),rotation=NumberRange.new(0,360),rotSpeed=NumberRange.new(-45,45)})
	end
end

local function buildParticlePage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,680)
	hdr(contentArea,"PARTICLES","Частицы с персонажа",14); divLine(contentArea,55)

	-- Кнопка выключить
	local offBtn=Instance.new("TextButton",contentArea); offBtn.Size=UDim2.new(1,-28,0,36); offBtn.Position=UDim2.new(0,14,0,64)
	offBtn.BackgroundColor3=Color3.fromRGB(18,18,18); offBtn.BorderSizePixel=0; offBtn.Text="Выключить частицы"; offBtn.TextColor3=Color3.fromRGB(120,120,120); offBtn.TextSize=12; offBtn.Font=Enum.Font.GothamSemibold; offBtn.AutoButtonColor=false
	Instance.new("UICorner",offBtn).CornerRadius=UDim.new(0,9); Instance.new("UIStroke",offBtn).Color=Color3.fromRGB(35,35,35)
	offBtn.MouseButton1Click:Connect(function() removeAllParticles(); buildParticlePage() end)
	offBtn.MouseEnter:Connect(function() TweenService:Create(offBtn,TIF,{BackgroundColor3=Color3.fromRGB(28,28,28)}):Play() end)
	offBtn.MouseLeave:Connect(function() TweenService:Create(offBtn,TIF,{BackgroundColor3=Color3.fromRGB(18,18,18)}):Play() end)

	-- Типы частиц
	local pSect=Instance.new("TextLabel",contentArea); pSect.Size=UDim2.new(1,-28,0,16); pSect.Position=UDim2.new(0,14,0,114)
	pSect.BackgroundTransparency=1; pSect.Text="ТИП ЧАСТИЦ"; pSect.TextColor3=Color3.fromRGB(60,60,60); pSect.TextSize=10; pSect.Font=Enum.Font.GothamBold; pSect.TextXAlignment=Enum.TextXAlignment.Left

	local ptypes={
		{id="star",    name="Stars",    desc="Звёзды летят вокруг тела"},
		{id="heart",   name="Hearts",   desc="Сердечки поднимаются вверх"},
		{id="cube",    name="Cubes",    desc="Кубики крутятся вокруг"},
		{id="fire",    name="Fire",     desc="Огонь и искры"},
		{id="sparkle", name="Sparkle",  desc="Искры во все стороны"},
		{id="snow",    name="Snow",     desc="Снежинки падают вниз"},
	}

	for i,pt in ipairs(ptypes) do
		local isActive=currentParticle==pt.id
		local c=Instance.new("TextButton",contentArea); c.Size=UDim2.new(1,-28,0,50); c.Position=UDim2.new(0,14,0,134+(i-1)*58)
		c.BackgroundColor3=isActive and Color3.fromRGB(22,22,22) or Color3.fromRGB(12,12,12); c.BorderSizePixel=0; c.Text=""; c.AutoButtonColor=false
		Instance.new("UICorner",c).CornerRadius=UDim.new(0,10)
		local cs=Instance.new("UIStroke",c); cs.Color=isActive and Color3.fromRGB(220,220,220) or Color3.fromRGB(28,28,28); cs.Thickness=1
		local nl=Instance.new("TextLabel",c); nl.Size=UDim2.new(1,-50,0,20); nl.Position=UDim2.new(0,12,0,8); nl.BackgroundTransparency=1; nl.Text=pt.name; nl.TextColor3=Color3.fromRGB(230,230,230); nl.TextSize=14; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left
		local dl=Instance.new("TextLabel",c); dl.Size=UDim2.new(1,-50,0,14); dl.Position=UDim2.new(0,12,0,29); dl.BackgroundTransparency=1; dl.Text=pt.desc; dl.TextColor3=Color3.fromRGB(65,65,65); dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left
		if isActive then local dot=Instance.new("Frame",c); dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(1,-16,0.5,-3); dot.BackgroundColor3=Color3.fromRGB(255,255,255); dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0) end
		c.MouseButton1Click:Connect(function()
			if currentParticle==pt.id then removeAllParticles()
			else applyParticle(pt.id) end
			buildParticlePage()
		end)
		c.MouseEnter:Connect(function() if not isActive then TweenService:Create(c,TIF,{BackgroundColor3=Color3.fromRGB(20,20,20)}):Play() end end)
		c.MouseLeave:Connect(function() if not isActive then TweenService:Create(c,TIF,{BackgroundColor3=Color3.fromRGB(12,12,12)}):Play() end end)
	end

	-- Цвет частиц
	local cSect=Instance.new("TextLabel",contentArea); cSect.Size=UDim2.new(1,-28,0,16); cSect.Position=UDim2.new(0,14,0,490)
	cSect.BackgroundTransparency=1; cSect.Text="ЦВЕТ ЧАСТИЦ"; cSect.TextColor3=Color3.fromRGB(60,60,60); cSect.TextSize=10; cSect.Font=Enum.Font.GothamBold; cSect.TextXAlignment=Enum.TextXAlignment.Left

	local pcolors={
		{"Белый",     Color3.fromRGB(255,255,255), Color3.fromRGB(200,200,255)},
		{"Огонь",     Color3.fromRGB(255,120,20),  Color3.fromRGB(255,230,50)},
		{"Радуга",    Color3.fromRGB(255,100,100),  Color3.fromRGB(100,100,255)},
		{"Неон",      Color3.fromRGB(0,255,180),    Color3.fromRGB(180,0,255)},
		{"Золото",    Color3.fromRGB(255,215,0),    Color3.fromRGB(255,150,0)},
		{"Розовый",   Color3.fromRGB(255,100,180),  Color3.fromRGB(255,200,240)},
		{"Ледяной",   Color3.fromRGB(150,220,255),  Color3.fromRGB(255,255,255)},
		{"Токсичный", Color3.fromRGB(100,255,50),   Color3.fromRGB(200,255,100)},
	}

	for i,pc in ipairs(pcolors) do
		local cb=Instance.new("TextButton",contentArea); cb.Size=UDim2.new(0,138,0,32); cb.Position=UDim2.new(0,14+(i-1)%2*152,0,510+math.floor((i-1)/2)*40)
		cb.BackgroundColor3=Color3.fromRGB(14,14,14); cb.BorderSizePixel=0; cb.Text=pc[1]; cb.TextColor3=Color3.fromRGB(185,185,185); cb.TextSize=12; cb.Font=Enum.Font.GothamSemibold; cb.AutoButtonColor=false
		Instance.new("UICorner",cb).CornerRadius=UDim.new(0,8)
		-- Градиентная полоска
		local stripe=Instance.new("Frame",cb); stripe.Size=UDim2.new(0,4,0.6,0); stripe.Position=UDim2.new(0,0,0.2,0); stripe.BackgroundColor3=pc[2]; stripe.BorderSizePixel=0; Instance.new("UICorner",stripe).CornerRadius=UDim.new(1,0)
		local stripe2=Instance.new("Frame",cb); stripe2.Size=UDim2.new(0,4,0.6,0); stripe2.Position=UDim2.new(0,4,0.2,0); stripe2.BackgroundColor3=pc[3]; stripe2.BorderSizePixel=0; Instance.new("UICorner",stripe2).CornerRadius=UDim.new(1,0)
		cb.MouseButton1Click:Connect(function()
			particleColor1=pc[2]; particleColor2=pc[3]
			-- Обновляем цвет живых эмиттеров
			for _,em in ipairs(particleEmitters) do
				pcall(function() em.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,particleColor1),ColorSequenceKeypoint.new(1,particleColor2)}) end)
			end
			-- Перезапускаем если был активен
			if currentParticle then local cur=currentParticle; applyParticle(cur) end
			TweenService:Create(cb,TweenInfo.new(0.07),{BackgroundColor3=Color3.fromRGB(32,32,32)}):Play()
			task.delay(0.1,function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(14,14,14)}):Play() end)
		end)
		cb.MouseEnter:Connect(function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(22,22,22)}):Play() end)
		cb.MouseLeave:Connect(function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(14,14,14)}):Play() end)
	end

	contentArea.CanvasSize=UDim2.new(0,0,0,510+math.ceil(#pcolors/2)*40+20)
end

-- ══════════════════════════════
--   HVH
-- ══════════════════════════════

-- ══════════════════════════════
--   AIMBOT СОСТОЯНИЯ
-- ══════════════════════════════
local aimbotActive    = false
local aimbotMode      = "hold"   -- "hold" / "toggle" / "always"
local aimbotTarget    = "Head"   -- "Head" / "HumanoidRootPart" / "nearest"
local aimbotSmooth    = 0.18     -- 0.0 = мгновенно, 1.0 = очень плавно
local aimbotFOV       = 120      -- радиус захвата в пикселях
local aimbotConn      = nil
local aimbotLocked    = false
local aimbotShowFOV   = true
local aimbotFovCircle = nil

local flyV2Active   = false
local flyV2Conn     = nil
local flyV2BV       = nil
local flyV2Speed    = 60
local bhopActive    = false
local bhopConn      = nil
local bhopSpeed     = 60

local function buildHVHPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,580)
	hdr(contentArea,"HVH","FlyV2, Bhop, Tab Spammer",14); divLine(contentArea,55)

	-- ── FLY V2 ──
	local flyLbl=Instance.new("TextLabel",contentArea); flyLbl.Size=UDim2.new(1,-28,0,16); flyLbl.Position=UDim2.new(0,14,0,64)
	flyLbl.BackgroundTransparency=1; flyLbl.Text="FLY V2  (обходит антифлай)"; flyLbl.TextColor3=Color3.fromRGB(60,60,60); flyLbl.TextSize=10; flyLbl.Font=Enum.Font.GothamBold; flyLbl.TextXAlignment=Enum.TextXAlignment.Left

	-- Слайдер скорости флая
	local flySpeedLbl=Instance.new("TextLabel",contentArea); flySpeedLbl.Size=UDim2.new(1,-28,0,14); flySpeedLbl.Position=UDim2.new(0,14,0,84)
	flySpeedLbl.BackgroundTransparency=1; flySpeedLbl.Text="Скорость: "..flyV2Speed; flySpeedLbl.TextColor3=Color3.fromRGB(100,100,100); flySpeedLbl.TextSize=11; flySpeedLbl.Font=Enum.Font.Gotham; flySpeedLbl.TextXAlignment=Enum.TextXAlignment.Left

	local flyTrack=Instance.new("Frame",contentArea); flyTrack.Size=UDim2.new(1,-28,0,6); flyTrack.Position=UDim2.new(0,14,0,102)
	flyTrack.BackgroundColor3=Color3.fromRGB(36,36,36); flyTrack.BorderSizePixel=0; Instance.new("UICorner",flyTrack).CornerRadius=UDim.new(1,0)
	local flyR=(flyV2Speed-10)/(200-10)
	local flyFill=Instance.new("Frame",flyTrack); flyFill.Size=UDim2.new(flyR,0,1,0); flyFill.BackgroundColor3=Color3.fromRGB(255,255,255); flyFill.BorderSizePixel=0; Instance.new("UICorner",flyFill).CornerRadius=UDim.new(1,0)
	local flyHandle=Instance.new("TextButton",flyTrack); flyHandle.Size=UDim2.new(0,16,0,16); flyHandle.Position=UDim2.new(flyR,-8,0.5,-8)
	flyHandle.BackgroundColor3=Color3.fromRGB(255,255,255); flyHandle.BorderSizePixel=0; flyHandle.Text=""; flyHandle.AutoButtonColor=false; flyHandle.ZIndex=5
	Instance.new("UICorner",flyHandle).CornerRadius=UDim.new(1,0)
	local flyDrag=false
	flyHandle.MouseButton1Down:Connect(function() flyDrag=true end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then flyDrag=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if flyDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
			local rel=math.clamp((i.Position.X-flyTrack.AbsolutePosition.X)/flyTrack.AbsoluteSize.X,0,1)
			flyV2Speed=math.floor(10+rel*(200-10)); flyFill.Size=UDim2.new(rel,0,1,0); flyHandle.Position=UDim2.new(rel,-8,0.5,-8)
			flySpeedLbl.Text="Скорость: "..flyV2Speed
		end
	end)

	-- Функция флая V2 — через BodyVelocity + постоянный сброс Humanoid.WalkSpeed=0
	-- Обходит антифлай: перемещается небольшими шагами вместо резкого телепорта
	local function startFlyV2()
		flyV2Active=true
		local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
		hum.WalkSpeed=0; hum.JumpPower=0
		flyV2BV=Instance.new("BodyVelocity",hrp)
		flyV2BV.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
		flyV2BV.Velocity=Vector3.new(0,0,0)
		local bg=Instance.new("BodyGyro",hrp); bg.Name="FlyV2Gyro"
		bg.MaxTorque=Vector3.new(math.huge,math.huge,math.huge); bg.D=100; bg.P=1000
		flyV2Conn=RunService.RenderStepped:Connect(function()
			if not flyV2Active then return end
			local char2=player.Character; if not char2 then return end
			local hrp2=char2:FindFirstChild("HumanoidRootPart"); if not hrp2 then return end
			local gyro=hrp2:FindFirstChild("FlyV2Gyro")
			-- Направление камеры
			local camCF=camera.CFrame
			local vel=Vector3.new(0,0,0)
			local spd=flyV2Speed
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel=vel+camCF.LookVector*spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel=vel-camCF.LookVector*spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel=vel-camCF.RightVector*spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel=vel+camCF.RightVector*spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel=vel+Vector3.new(0,spd*0.6,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel=vel-Vector3.new(0,spd*0.6,0) end
			if flyV2BV and flyV2BV.Parent then flyV2BV.Velocity=vel end
			if gyro then gyro.CFrame=camCF end
			-- Антивфлай: небольшие микро-шаги вниз имитируют нормальную физику
			if vel.Magnitude<1 then
				if flyV2BV and flyV2BV.Parent then flyV2BV.Velocity=Vector3.new(0,-0.5,0) end
			end
		end)
	end
	local function stopFlyV2()
		flyV2Active=false
		if flyV2Conn then flyV2Conn:Disconnect(); flyV2Conn=nil end
		local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart")
		if hrp then
			if flyV2BV and flyV2BV.Parent then flyV2BV:Destroy(); flyV2BV=nil end
			local gyro=hrp:FindFirstChild("FlyV2Gyro"); if gyro then gyro:Destroy() end
		end
		local hum=char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed=16; hum.JumpPower=50 end
	end

	makeToggleCard(contentArea,"FlyV2","WASD+Space+Ctrl — обходит антифлай",120,flyV2Active,function(v)
		if v then startFlyV2() else stopFlyV2() end
	end)

	divLine(contentArea,180)

	-- ── BHOP ──
	local bhopLbl=Instance.new("TextLabel",contentArea); bhopLbl.Size=UDim2.new(1,-28,0,16); bhopLbl.Position=UDim2.new(0,14,0,190)
	bhopLbl.BackgroundTransparency=1; bhopLbl.Text="BHOP"; bhopLbl.TextColor3=Color3.fromRGB(60,60,60); bhopLbl.TextSize=10; bhopLbl.Font=Enum.Font.GothamBold; bhopLbl.TextXAlignment=Enum.TextXAlignment.Left

	local bhopSpeedLbl=Instance.new("TextLabel",contentArea); bhopSpeedLbl.Size=UDim2.new(1,-28,0,14); bhopSpeedLbl.Position=UDim2.new(0,14,0,210)
	bhopSpeedLbl.BackgroundTransparency=1; bhopSpeedLbl.Text="Скорость: "..bhopSpeed; bhopSpeedLbl.TextColor3=Color3.fromRGB(100,100,100); bhopSpeedLbl.TextSize=11; bhopSpeedLbl.Font=Enum.Font.Gotham; bhopSpeedLbl.TextXAlignment=Enum.TextXAlignment.Left

	local bhTrack=Instance.new("Frame",contentArea); bhTrack.Size=UDim2.new(1,-28,0,6); bhTrack.Position=UDim2.new(0,14,0,228)
	bhTrack.BackgroundColor3=Color3.fromRGB(36,36,36); bhTrack.BorderSizePixel=0; Instance.new("UICorner",bhTrack).CornerRadius=UDim.new(1,0)
	local bhR=(bhopSpeed-20)/(200-20)
	local bhFill=Instance.new("Frame",bhTrack); bhFill.Size=UDim2.new(bhR,0,1,0); bhFill.BackgroundColor3=Color3.fromRGB(255,255,255); bhFill.BorderSizePixel=0; Instance.new("UICorner",bhFill).CornerRadius=UDim.new(1,0)
	local bhHandle=Instance.new("TextButton",bhTrack); bhHandle.Size=UDim2.new(0,16,0,16); bhHandle.Position=UDim2.new(bhR,-8,0.5,-8)
	bhHandle.BackgroundColor3=Color3.fromRGB(255,255,255); bhHandle.BorderSizePixel=0; bhHandle.Text=""; bhHandle.AutoButtonColor=false; bhHandle.ZIndex=5
	Instance.new("UICorner",bhHandle).CornerRadius=UDim.new(1,0)
	local bhDrag=false
	bhHandle.MouseButton1Down:Connect(function() bhDrag=true end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then bhDrag=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if bhDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
			local rel=math.clamp((i.Position.X-bhTrack.AbsolutePosition.X)/bhTrack.AbsoluteSize.X,0,1)
			bhopSpeed=math.floor(20+rel*(200-20)); bhFill.Size=UDim2.new(rel,0,1,0); bhHandle.Position=UDim2.new(rel,-8,0.5,-8)
			bhopSpeedLbl.Text="Скорость: "..bhopSpeed
		end
	end)

	makeToggleCard(contentArea,"Bhop","Автоматический прыжок при приземлении",246,bhopActive,function(v)
		bhopActive=v
		if bhopConn then bhopConn:Disconnect(); bhopConn=nil end
		if v then
			bhopConn=RunService.Heartbeat:Connect(function()
				local char=player.Character; if not char then return end
				local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
				local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
				if hum.FloorMaterial~=Enum.Material.Air then
					hum.WalkSpeed=bhopSpeed
					hrp:ApplyImpulse(Vector3.new(0,hum.JumpPower*hrp.AssemblyMass*0.7,0))
				end
			end)
		else
			local char=player.Character; if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=16 end end
		end
	end)

	divLine(contentArea,308)

	-- ── TAB (Pallet Spawn) ──
	local tabLbl=Instance.new("TextLabel",contentArea); tabLbl.Size=UDim2.new(1,-28,0,16); tabLbl.Position=UDim2.new(0,14,0,318)
	tabLbl.BackgroundTransparency=1; tabLbl.Text="TAB  (спавн доски под игроком)"; tabLbl.TextColor3=Color3.fromRGB(60,60,60); tabLbl.TextSize=10; tabLbl.Font=Enum.Font.GothamBold; tabLbl.TextXAlignment=Enum.TextXAlignment.Left

	local tabStatus=Instance.new("TextLabel",contentArea); tabStatus.Size=UDim2.new(1,-28,0,14); tabStatus.Position=UDim2.new(0,14,0,338)
	tabStatus.BackgroundTransparency=1; tabStatus.TextSize=11; tabStatus.Font=Enum.Font.Gotham; tabStatus.TextXAlignment=Enum.TextXAlignment.Left

	-- Показываем из какой папки берёт текущий пользователь
	if registeredNick and NICK_FOLDERS[registeredNick] then
		tabStatus.Text="Папка: "..NICK_FOLDERS[registeredNick]; tabStatus.TextColor3=Color3.fromRGB(80,180,100)
	else
		tabStatus.Text="Сначала войди в систему"; tabStatus.TextColor3=Color3.fromRGB(255,80,80)
	end

	-- Функция спавна доски по нику
	local function spawnPallet(statusLabel)
		if not registeredNick then
			if statusLabel then statusLabel.Text="Не авторизован!"; statusLabel.TextColor3=Color3.fromRGB(255,80,80) end
			return
		end
		local folderName=NICK_FOLDERS[registeredNick]
		if not folderName then
			if statusLabel then statusLabel.Text="Папка не найдена для "..registeredNick; statusLabel.TextColor3=Color3.fromRGB(255,80,80) end
			return
		end
		local char=player.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		local ok,err=pcall(function()
			-- Ищем папку игрока в workspace
			local folder=workspace:FindFirstChild(folderName)
			if not folder then error("Папка '"..folderName.."' не найдена в workspace") end
			-- Ищем PalletLightBrown внутри папки
			local template=folder:FindFirstChild("PalletLightBrown")
			if not template then error("PalletLightBrown не найден в "..folderName) end
			-- Клонируем и размещаем под игроком
			local clone=template:Clone()
			clone.Parent=folder -- кладём обратно в ту же папку как оригинал
			-- Ставим позицию под игрока
			if clone:IsA("Model") then
				local prim=clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart",true)
				if prim then
					clone:SetPrimaryPartCFrame(CFrame.new(hrp.Position-Vector3.new(0,3.5,0)))
				end
			elseif clone:IsA("BasePart") then
				clone.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3.5,0))
			end
			-- Обновляем PlayerValue если есть
			local pv=clone:FindFirstChild("PlayerValue",true)
			if pv and pv:IsA("StringValue") then pv.Value=registeredNick end
			if statusLabel then statusLabel.Text="Доска из "..folderName.." спавнена!"; statusLabel.TextColor3=Color3.fromRGB(80,220,100) end
		end)
		if not ok then
			if statusLabel then statusLabel.Text="Ошибка: "..tostring(err); statusLabel.TextColor3=Color3.fromRGB(255,80,80) end
		end
	end

	local tabBtn=Instance.new("TextButton",contentArea); tabBtn.Size=UDim2.new(1,-28,0,44); tabBtn.Position=UDim2.new(0,14,0,358)
	tabBtn.BackgroundColor3=Color3.fromRGB(255,255,255); tabBtn.BorderSizePixel=0; tabBtn.Text="СПАВН PALLET"
	tabBtn.TextColor3=Color3.fromRGB(0,0,0); tabBtn.TextSize=14; tabBtn.Font=Enum.Font.GothamBold; tabBtn.AutoButtonColor=false
	Instance.new("UICorner",tabBtn).CornerRadius=UDim.new(0,10)
	tabBtn.MouseEnter:Connect(function() TweenService:Create(tabBtn,TIF,{BackgroundColor3=Color3.fromRGB(215,215,215)}):Play() end)
	tabBtn.MouseLeave:Connect(function() TweenService:Create(tabBtn,TIF,{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play() end)
	tabBtn.MouseButton1Click:Connect(function() spawnPallet(tabStatus) end)

	-- Авто по Tab клавише
	local tabAutoEnabled=false
	makeToggleCard(contentArea,"Tab автокнопка","Tab клавиша спавнит доску автоматически",412,false,function(v)
		tabAutoEnabled=v
		tabStatus.Text=v and ("Tab активен — папка: "..(NICK_FOLDERS[registeredNick] or "?")) or ("Папка: "..(NICK_FOLDERS[registeredNick] or "не авторизован"))
		tabStatus.TextColor3=v and Color3.fromRGB(80,220,100) or Color3.fromRGB(80,180,100)
	end)

	-- Tab polling
	getgenv().TabKeyDown=false
	task.spawn(function()
		while task.wait(0.04) do
			if tabAutoEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Tab) then
				if not getgenv().TabKeyDown then
					getgenv().TabKeyDown=true
					spawnPallet(nil)
					task.wait(0.25); getgenv().TabKeyDown=false
				end
			end
		end
	end)
end

-- ══════════════════════════════
--   HITBOX
-- ══════════════════════════════

local hitboxActive  = false
local hitboxSize    = 10
local hitboxColor   = Color3.fromRGB(255,50,50)
local hitboxTrans   = 0.5
local hitboxParts   = {}

local function removeAllHitboxes()
	for _,p in pairs(hitboxParts) do pcall(function() p:Destroy() end) end
	hitboxParts={}
end

local function applyHitboxes()
	removeAllHitboxes()
	if not hitboxActive then return end
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=player and p.Character then
			local hrp=p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local box=Instance.new("Part")
				box.Name="VibeHitbox_"..p.Name
				box.Size=Vector3.new(hitboxSize,hitboxSize,hitboxSize)
				box.Transparency=hitboxTrans
				box.Color=hitboxColor
				box.Material=Enum.Material.Neon
				box.CanCollide=false
				box.Anchored=false
				box.CFrame=hrp.CFrame
				box.Parent=workspace
				-- Крепим к hrp через Weld
				local weld=Instance.new("WeldConstraint")
				weld.Part0=box; weld.Part1=hrp; weld.Parent=box
				hitboxParts[p.Name]=box
			end
		end
	end
end

local function buildHitboxPage()
	clearContent(); contentArea.CanvasSize=UDim2.new(0,0,0,560)
	hdr(contentArea,"HITBOX","Расширенные хитбоксы игроков",14); divLine(contentArea,55)

	makeToggleCard(contentArea,"Hitbox включить","Показывает и расширяет хитбоксы",64,hitboxActive,function(v)
		hitboxActive=v; applyHitboxes()
	end)

	-- Размер хитбокса
	local szLbl=Instance.new("TextLabel",contentArea); szLbl.Size=UDim2.new(1,-28,0,16); szLbl.Position=UDim2.new(0,14,0,130)
	szLbl.BackgroundTransparency=1; szLbl.Text="РАЗМЕР ХИТБОКСА"; szLbl.TextColor3=Color3.fromRGB(60,60,60); szLbl.TextSize=10; szLbl.Font=Enum.Font.GothamBold; szLbl.TextXAlignment=Enum.TextXAlignment.Left

	local sizeCard=Instance.new("Frame",contentArea); sizeCard.Size=UDim2.new(1,-28,0,56); sizeCard.Position=UDim2.new(0,14,0,150)
	sizeCard.BackgroundColor3=Color3.fromRGB(14,14,14); sizeCard.BorderSizePixel=0; Instance.new("UICorner",sizeCard).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",sizeCard).Color=Color3.fromRGB(30,30,30)
	local sizeValLbl=Instance.new("TextLabel",sizeCard); sizeValLbl.Size=UDim2.new(0,50,0,18); sizeValLbl.Position=UDim2.new(1,-62,0,8); sizeValLbl.BackgroundTransparency=1; sizeValLbl.Text=tostring(hitboxSize).." ст"; sizeValLbl.TextColor3=Color3.fromRGB(255,255,255); sizeValLbl.TextSize=13; sizeValLbl.Font=Enum.Font.GothamBold; sizeValLbl.TextXAlignment=Enum.TextXAlignment.Right
	local stl2=Instance.new("TextLabel",sizeCard); stl2.Size=UDim2.new(1,-80,0,18); stl2.Position=UDim2.new(0,12,0,8); stl2.BackgroundTransparency=1; stl2.Text="Размер хитбокса"; stl2.TextColor3=Color3.fromRGB(200,200,200); stl2.TextSize=13; stl2.Font=Enum.Font.GothamSemibold; stl2.TextXAlignment=Enum.TextXAlignment.Left
	local szTrack=Instance.new("Frame",sizeCard); szTrack.Size=UDim2.new(1,-24,0,6); szTrack.Position=UDim2.new(0,12,0,40); szTrack.BackgroundColor3=Color3.fromRGB(36,36,36); szTrack.BorderSizePixel=0; Instance.new("UICorner",szTrack).CornerRadius=UDim.new(1,0)
	local szR=(hitboxSize-3)/(50-3)
	local szFill=Instance.new("Frame",szTrack); szFill.Size=UDim2.new(szR,0,1,0); szFill.BackgroundColor3=Color3.fromRGB(255,255,255); szFill.BorderSizePixel=0; Instance.new("UICorner",szFill).CornerRadius=UDim.new(1,0)
	local szHandle=Instance.new("TextButton",szTrack); szHandle.Size=UDim2.new(0,16,0,16); szHandle.Position=UDim2.new(szR,-8,0.5,-8); szHandle.BackgroundColor3=Color3.fromRGB(255,255,255); szHandle.BorderSizePixel=0; szHandle.Text=""; szHandle.AutoButtonColor=false; szHandle.ZIndex=5
	Instance.new("UICorner",szHandle).CornerRadius=UDim.new(1,0)
	local szDrag=false
	szHandle.MouseButton1Down:Connect(function() szDrag=true end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then szDrag=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if szDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
			local rel=math.clamp((i.Position.X-szTrack.AbsolutePosition.X)/szTrack.AbsoluteSize.X,0,1)
			hitboxSize=math.floor(3+rel*(50-3)); szFill.Size=UDim2.new(rel,0,1,0); szHandle.Position=UDim2.new(rel,-8,0.5,-8)
			sizeValLbl.Text=tostring(hitboxSize).." ст"
			-- Обновляем живые хитбоксы
			for _,bp in pairs(hitboxParts) do pcall(function() bp.Size=Vector3.new(hitboxSize,hitboxSize,hitboxSize) end) end
		end
	end)

	-- Быстрые размеры
	local szPresets={{5,"Мал"},{10,"Норм"},{20,"Большой"},{40,"Огромный"}}
	for i,sp in ipairs(szPresets) do
		local pb=Instance.new("TextButton",contentArea); pb.Size=UDim2.new(0,118,0,34); pb.Position=UDim2.new(0,14+(i-1)%2*136,0,216+math.floor((i-1)/2)*42)
		pb.BackgroundColor3=Color3.fromRGB(16,16,16); pb.BorderSizePixel=0; pb.Text=sp[2].." ("..sp[1]..")"; pb.TextColor3=Color3.fromRGB(190,190,190); pb.TextSize=12; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,9); Instance.new("UIStroke",pb).Color=Color3.fromRGB(30,30,30)
		pb.MouseButton1Click:Connect(function()
			hitboxSize=sp[1]; sizeValLbl.Text=tostring(sp[1]).." ст"
			local rel=(sp[1]-3)/(50-3); szFill.Size=UDim2.new(math.clamp(rel,0,1),0,1,0); szHandle.Position=UDim2.new(math.clamp(rel,0,1),-8,0.5,-8)
			for _,bp in pairs(hitboxParts) do pcall(function() bp.Size=Vector3.new(sp[1],sp[1],sp[1]) end) end
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
	end

	-- Прозрачность хитбокса
	local trLbl=Instance.new("TextLabel",contentArea); trLbl.Size=UDim2.new(1,-28,0,16); trLbl.Position=UDim2.new(0,14,0,308)
	trLbl.BackgroundTransparency=1; trLbl.Text="ПРОЗРАЧНОСТЬ"; trLbl.TextColor3=Color3.fromRGB(60,60,60); trLbl.TextSize=10; trLbl.Font=Enum.Font.GothamBold; trLbl.TextXAlignment=Enum.TextXAlignment.Left
	local trPresets={{0,"Виден"},{0.5,"Норм"},{0.85,"Призрак"},{1,"Невидим"}}
	for i,tp in ipairs(trPresets) do
		local pb=Instance.new("TextButton",contentArea); pb.Size=UDim2.new(0,118,0,34); pb.Position=UDim2.new(0,14+(i-1)%2*136,0,328+math.floor((i-1)/2)*42)
		pb.BackgroundColor3=Color3.fromRGB(16,16,16); pb.BorderSizePixel=0; pb.Text=tp[2]; pb.TextColor3=Color3.fromRGB(190,190,190); pb.TextSize=12; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,9); Instance.new("UIStroke",pb).Color=Color3.fromRGB(30,30,30)
		pb.MouseButton1Click:Connect(function()
			hitboxTrans=tp[1]; for _,bp in pairs(hitboxParts) do pcall(function() bp.Transparency=tp[1] end) end
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
	end

	-- Цвет хитбокса
	local colLbl=Instance.new("TextLabel",contentArea); colLbl.Size=UDim2.new(1,-28,0,16); colLbl.Position=UDim2.new(0,14,0,418)
	colLbl.BackgroundTransparency=1; colLbl.Text="ЦВЕТ ХИТБОКСА"; colLbl.TextColor3=Color3.fromRGB(60,60,60); colLbl.TextSize=10; colLbl.Font=Enum.Font.GothamBold; colLbl.TextXAlignment=Enum.TextXAlignment.Left
	local hbColors={{"Красный",Color3.fromRGB(255,50,50)},{"Синий",Color3.fromRGB(50,120,255)},{"Зелёный",Color3.fromRGB(50,220,80)},{"Жёлтый",Color3.fromRGB(255,215,0)},{"Фиолет",Color3.fromRGB(180,50,255)},{"Белый",Color3.fromRGB(255,255,255)}}
	for i,hc in ipairs(hbColors) do
		local cb=Instance.new("TextButton",contentArea); cb.Size=UDim2.new(0,88,0,32); cb.Position=UDim2.new(0,14+(i-1)%3*100,0,438+math.floor((i-1)/3)*40)
		cb.BackgroundColor3=Color3.fromRGB(14,14,14); cb.BorderSizePixel=0; cb.Text=hc[1]; cb.TextColor3=Color3.fromRGB(185,185,185); cb.TextSize=12; cb.Font=Enum.Font.GothamSemibold; cb.AutoButtonColor=false
		Instance.new("UICorner",cb).CornerRadius=UDim.new(0,8)
		local stripe=Instance.new("Frame",cb); stripe.Size=UDim2.new(0,3,0.6,0); stripe.Position=UDim2.new(0,0,0.2,0); stripe.BackgroundColor3=hc[2]; stripe.BorderSizePixel=0; Instance.new("UICorner",stripe).CornerRadius=UDim.new(1,0)
		cb.MouseButton1Click:Connect(function()
			hitboxColor=hc[2]; for _,bp in pairs(hitboxParts) do pcall(function() bp.Color=hc[2] end) end
		end)
		cb.MouseEnter:Connect(function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(22,22,22)}):Play() end)
		cb.MouseLeave:Connect(function() TweenService:Create(cb,TIF,{BackgroundColor3=Color3.fromRGB(14,14,14)}):Play() end)
	end

	contentArea.CanvasSize=UDim2.new(0,0,0,438+math.ceil(#hbColors/3)*40+20)

	-- Автообновление хитбоксов при входе игроков
	Players.PlayerAdded:Connect(function(p)
		if not hitboxActive then return end
		task.wait(2); applyHitboxes()
	end)
	Players.PlayerRemoving:Connect(function(p)
		if hitboxParts[p.Name] then pcall(function() hitboxParts[p.Name]:Destroy() end); hitboxParts[p.Name]=nil end
	end)
end

-- ══════════════════════════════
--   AIMBOT
-- ══════════════════════════════

-- ══════════════════════════════
--   AIMBOT — FOV CIRCLE
-- ══════════════════════════════

-- FOV-круг на экране (Drawing API)
local fovCircle = nil
local fovCircleLocked = nil  -- второй круг когда захвачена цель

local function createFovCircles()
	-- Основной круг FOV (белый пунктир)
	if Drawing then
		pcall(function()
			fovCircle = Drawing.new("Circle")
			fovCircle.Visible    = false
			fovCircle.Radius     = aimbotFOV
			fovCircle.Color      = Color3.fromRGB(255,255,255)
			fovCircle.Thickness  = 1.5
			fovCircle.Filled     = false
			fovCircle.NumSides   = 64
			fovCircle.Transparency = 0.5

			fovCircleLocked = Drawing.new("Circle")
			fovCircleLocked.Visible    = false
			fovCircleLocked.Radius     = 6
			fovCircleLocked.Color      = Color3.fromRGB(255,60,60)
			fovCircleLocked.Thickness  = 2
			fovCircleLocked.Filled     = false
			fovCircleLocked.NumSides   = 32
			fovCircleLocked.Transparency = 0
		end)
	end
end

local function removeFovCircles()
	pcall(function() if fovCircle then fovCircle:Remove() end end)
	pcall(function() if fovCircleLocked then fovCircleLocked:Remove() end end)
	fovCircle = nil; fovCircleLocked = nil
end

local function getAimbotTarget()
	local bestPlayer = nil
	local bestDist   = aimbotFOV
	local vpSize     = camera.ViewportSize
	local cx,cy      = vpSize.X/2, vpSize.Y/2

	for _,p in ipairs(Players:GetPlayers()) do
		if p == player then continue end
		if not p.Character then continue end
		local hum = p.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end

		local head = p.Character:FindFirstChild("Head")
		if not head then continue end

		local spos, onScreen = camera:WorldToViewportPoint(head.Position)
		if not onScreen then continue end

		local dist = math.sqrt((spos.X - cx)^2 + (spos.Y - cy)^2)
		if dist < bestDist then
			bestDist   = dist
			bestPlayer = {p = p, head = head, spos = spos, dist = dist}
		end
	end
	return bestPlayer
end

local function startAimbot()
	if aimbotConn then aimbotConn:Disconnect() end
	createFovCircles()

	aimbotConn = RunService.RenderStepped:Connect(function()
		if not aimbotActive then return end

		local vpSize = camera.ViewportSize
		local cx, cy = vpSize.X/2, vpSize.Y/2

		-- Обновляем позицию FOV-круга по центру экрана
		pcall(function()
			if fovCircle then
				fovCircle.Position = Vector2.new(cx, cy)
				fovCircle.Radius   = aimbotFOV
				fovCircle.Visible  = true
			end
		end)

		local target = getAimbotTarget()

		if target then
			-- Цель в круге — показываем красный кружок на голове
			pcall(function()
				if fovCircleLocked then
					fovCircleLocked.Position = Vector2.new(target.spos.X, target.spos.Y)
					fovCircleLocked.Visible  = true
					-- Цвет круга меняется в зависимости от дистанции
					fovCircleLocked.Color = target.dist < aimbotFOV * 0.3
						and Color3.fromRGB(255,50,50)
						or  Color3.fromRGB(255,160,0)
				end
			end)

			-- Плавно ведём камеру на голову
			local targetCF = CFrame.new(camera.CFrame.Position, target.head.Position)
			-- lerp: чем больше smooth тем медленнее (0% = мгновенно, 100% = очень плавно)
			local speed = 1 - aimbotSmooth * 0.95
			camera.CFrame = camera.CFrame:Lerp(targetCF, speed)
		else
			pcall(function()
				if fovCircleLocked then fovCircleLocked.Visible = false end
			end)
		end
	end)
end

local function stopAimbot()
	if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
	removeFovCircles()
end

local function buildAimbotPage()
	clearContent(); contentArea.CanvasSize = UDim2.new(0,0,0,480)
	hdr(contentArea,"AIMBOT","FOV-круг → цель в круге → держит голову",14); divLine(contentArea,55)

	-- ── ГЛАВНЫЙ ТОГГЛ ──
	local statusLbl = Instance.new("TextLabel",contentArea)
	statusLbl.Size=UDim2.new(1,-28,0,14); statusLbl.Position=UDim2.new(0,14,0,128)
	statusLbl.BackgroundTransparency=1
	statusLbl.Text = aimbotActive and "● АКТИВЕН — смотри на игрока в круге" or "○ Выключен"
	statusLbl.TextColor3 = aimbotActive and Color3.fromRGB(255,80,80) or Color3.fromRGB(60,60,60)
	statusLbl.TextSize=11; statusLbl.Font=Enum.Font.GothamSemibold; statusLbl.TextXAlignment=Enum.TextXAlignment.Left

	makeToggleCard(contentArea,"Aimbot (Head)","Держит камеру на голове в FOV-круге",64,aimbotActive,function(v)
		aimbotActive = v
		if v then
			startAimbot()
			statusLbl.Text = "● АКТИВЕН — смотри на игрока в круге"
			statusLbl.TextColor3 = Color3.fromRGB(255,80,80)
		else
			stopAimbot()
			statusLbl.Text = "○ Выключен"
			statusLbl.TextColor3 = Color3.fromRGB(60,60,60)
		end
	end)

	divLine(contentArea,148)

	-- ── РАЗМЕР FOV-КРУГА ──
	local fovSectLbl = Instance.new("TextLabel",contentArea)
	fovSectLbl.Size=UDim2.new(1,-28,0,16); fovSectLbl.Position=UDim2.new(0,14,0,158)
	fovSectLbl.BackgroundTransparency=1; fovSectLbl.Text="РАЗМЕР FOV-КРУГА"
	fovSectLbl.TextColor3=Color3.fromRGB(60,60,60); fovSectLbl.TextSize=10
	fovSectLbl.Font=Enum.Font.GothamBold; fovSectLbl.TextXAlignment=Enum.TextXAlignment.Left

	local fovCard = Instance.new("Frame",contentArea)
	fovCard.Size=UDim2.new(1,-28,0,56); fovCard.Position=UDim2.new(0,14,0,178)
	fovCard.BackgroundColor3=Color3.fromRGB(14,14,14); fovCard.BorderSizePixel=0
	Instance.new("UICorner",fovCard).CornerRadius=UDim.new(0,10)
	Instance.new("UIStroke",fovCard).Color=Color3.fromRGB(30,30,30)

	local fovTL = Instance.new("TextLabel",fovCard)
	fovTL.Size=UDim2.new(1,-80,0,18); fovTL.Position=UDim2.new(0,12,0,8)
	fovTL.BackgroundTransparency=1; fovTL.Text="Радиус круга"
	fovTL.TextColor3=Color3.fromRGB(200,200,200); fovTL.TextSize=13; fovTL.Font=Enum.Font.GothamSemibold; fovTL.TextXAlignment=Enum.TextXAlignment.Left

	local fovValL = Instance.new("TextLabel",fovCard)
	fovValL.Size=UDim2.new(0,60,0,18); fovValL.Position=UDim2.new(1,-70,0,8)
	fovValL.BackgroundTransparency=1; fovValL.Text=tostring(aimbotFOV).." px"
	fovValL.TextColor3=Color3.fromRGB(255,255,255); fovValL.TextSize=13; fovValL.Font=Enum.Font.GothamBold; fovValL.TextXAlignment=Enum.TextXAlignment.Right

	local fovTrack = Instance.new("Frame",fovCard)
	fovTrack.Size=UDim2.new(1,-24,0,6); fovTrack.Position=UDim2.new(0,12,0,40)
	fovTrack.BackgroundColor3=Color3.fromRGB(36,36,36); fovTrack.BorderSizePixel=0
	Instance.new("UICorner",fovTrack).CornerRadius=UDim.new(1,0)

	local fovR = (aimbotFOV-20)/(400-20)
	local fovFill = Instance.new("Frame",fovTrack)
	fovFill.Size=UDim2.new(fovR,0,1,0); fovFill.BackgroundColor3=Color3.fromRGB(255,80,80); fovFill.BorderSizePixel=0
	Instance.new("UICorner",fovFill).CornerRadius=UDim.new(1,0)

	local fovHandle = Instance.new("TextButton",fovTrack)
	fovHandle.Size=UDim2.new(0,16,0,16); fovHandle.Position=UDim2.new(fovR,-8,0.5,-8)
	fovHandle.BackgroundColor3=Color3.fromRGB(255,80,80); fovHandle.BorderSizePixel=0
	fovHandle.Text=""; fovHandle.AutoButtonColor=false; fovHandle.ZIndex=5
	Instance.new("UICorner",fovHandle).CornerRadius=UDim.new(1,0)

	local fovDrag = false
	fovHandle.MouseButton1Down:Connect(function() fovDrag=true end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then fovDrag=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if fovDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
			local rel = math.clamp((i.Position.X - fovTrack.AbsolutePosition.X)/fovTrack.AbsoluteSize.X,0,1)
			aimbotFOV = math.floor(20 + rel*(400-20))
			fovFill.Size=UDim2.new(rel,0,1,0); fovHandle.Position=UDim2.new(rel,-8,0.5,-8)
			fovValL.Text = tostring(aimbotFOV).." px"
			-- Обновляем живой круг
			pcall(function() if fovCircle then fovCircle.Radius = aimbotFOV end end)
		end
	end)

	-- Быстрые пресеты размера
	local fovPresets = {{60,"Малый"},{120,"Средний"},{200,"Большой"},{350,"Огромный"}}
	for i,fp in ipairs(fovPresets) do
		local pb=Instance.new("TextButton",contentArea)
		pb.Size=UDim2.new(0,118,0,34); pb.Position=UDim2.new(0,14+(i-1)%2*136,0,244+math.floor((i-1)/2)*42)
		pb.BackgroundColor3=Color3.fromRGB(16,16,16); pb.BorderSizePixel=0
		pb.Text=fp[2].." ("..fp[1]..")"; pb.TextColor3=Color3.fromRGB(190,190,190)
		pb.TextSize=12; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,9)
		Instance.new("UIStroke",pb).Color=Color3.fromRGB(30,30,30)
		pb.MouseButton1Click:Connect(function()
			aimbotFOV=fp[1]
			local rel=(fp[1]-20)/(400-20)
			fovFill.Size=UDim2.new(math.clamp(rel,0,1),0,1,0)
			fovHandle.Position=UDim2.new(math.clamp(rel,0,1),-8,0.5,-8)
			fovValL.Text=tostring(fp[1]).." px"
			pcall(function() if fovCircle then fovCircle.Radius=fp[1] end end)
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
	end

	divLine(contentArea,336)

	-- ── ПЛАВНОСТЬ ──
	local smLbl = Instance.new("TextLabel",contentArea)
	smLbl.Size=UDim2.new(1,-28,0,16); smLbl.Position=UDim2.new(0,14,0,346)
	smLbl.BackgroundTransparency=1; smLbl.Text="ПЛАВНОСТЬ НАВЕДЕНИЯ"
	smLbl.TextColor3=Color3.fromRGB(60,60,60); smLbl.TextSize=10; smLbl.Font=Enum.Font.GothamBold; smLbl.TextXAlignment=Enum.TextXAlignment.Left

	local smCard = Instance.new("Frame",contentArea)
	smCard.Size=UDim2.new(1,-28,0,56); smCard.Position=UDim2.new(0,14,0,366)
	smCard.BackgroundColor3=Color3.fromRGB(14,14,14); smCard.BorderSizePixel=0
	Instance.new("UICorner",smCard).CornerRadius=UDim.new(0,10)
	Instance.new("UIStroke",smCard).Color=Color3.fromRGB(30,30,30)

	local smTL = Instance.new("TextLabel",smCard)
	smTL.Size=UDim2.new(1,-80,0,18); smTL.Position=UDim2.new(0,12,0,8)
	smTL.BackgroundTransparency=1; smTL.Text="Smoothness"
	smTL.TextColor3=Color3.fromRGB(200,200,200); smTL.TextSize=13; smTL.Font=Enum.Font.GothamSemibold; smTL.TextXAlignment=Enum.TextXAlignment.Left

	local smValL = Instance.new("TextLabel",smCard)
	smValL.Size=UDim2.new(0,60,0,18); smValL.Position=UDim2.new(1,-70,0,8)
	smValL.BackgroundTransparency=1; smValL.Text=tostring(math.floor(aimbotSmooth*100)).."%"
	smValL.TextColor3=Color3.fromRGB(255,255,255); smValL.TextSize=13; smValL.Font=Enum.Font.GothamBold; smValL.TextXAlignment=Enum.TextXAlignment.Right

	local smHint = Instance.new("TextLabel",smCard)
	smHint.Size=UDim2.new(0.5,0,0,14); smHint.Position=UDim2.new(0,12,0,28)
	smHint.BackgroundTransparency=1; smHint.Text="0% = моментально"
	smHint.TextColor3=Color3.fromRGB(50,50,50); smHint.TextSize=10; smHint.Font=Enum.Font.Gotham; smHint.TextXAlignment=Enum.TextXAlignment.Left

	local smTrack = Instance.new("Frame",smCard)
	smTrack.Size=UDim2.new(1,-24,0,6); smTrack.Position=UDim2.new(0,12,0,40)
	smTrack.BackgroundColor3=Color3.fromRGB(36,36,36); smTrack.BorderSizePixel=0
	Instance.new("UICorner",smTrack).CornerRadius=UDim.new(1,0)

	local smR = aimbotSmooth
	local smFill = Instance.new("Frame",smTrack)
	smFill.Size=UDim2.new(smR,0,1,0); smFill.BackgroundColor3=Color3.fromRGB(255,80,80); smFill.BorderSizePixel=0
	Instance.new("UICorner",smFill).CornerRadius=UDim.new(1,0)

	local smHandle = Instance.new("TextButton",smTrack)
	smHandle.Size=UDim2.new(0,16,0,16); smHandle.Position=UDim2.new(smR,-8,0.5,-8)
	smHandle.BackgroundColor3=Color3.fromRGB(255,80,80); smHandle.BorderSizePixel=0
	smHandle.Text=""; smHandle.AutoButtonColor=false; smHandle.ZIndex=5
	Instance.new("UICorner",smHandle).CornerRadius=UDim.new(1,0)

	local smDrag=false
	smHandle.MouseButton1Down:Connect(function() smDrag=true end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then smDrag=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if smDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
			local rel=math.clamp((i.Position.X-smTrack.AbsolutePosition.X)/smTrack.AbsoluteSize.X,0,1)
			aimbotSmooth=rel; smFill.Size=UDim2.new(rel,0,1,0); smHandle.Position=UDim2.new(rel,-8,0.5,-8)
			smValL.Text=tostring(math.floor(rel*100)).."%"
		end
	end)

	-- Быстрые пресеты плавности
	local smPresets = {{0,"Instant"},{0.3,"Низкая"},{0.6,"Средняя"},{0.85,"Высокая"}}
	for i,sp in ipairs(smPresets) do
		local pb=Instance.new("TextButton",contentArea)
		pb.Size=UDim2.new(0,118,0,34); pb.Position=UDim2.new(0,14+(i-1)%2*136,0,432+math.floor((i-1)/2)*42)
		pb.BackgroundColor3=Color3.fromRGB(16,16,16); pb.BorderSizePixel=0
		pb.Text=sp[2]; pb.TextColor3=Color3.fromRGB(190,190,190)
		pb.TextSize=12; pb.Font=Enum.Font.GothamSemibold; pb.AutoButtonColor=false
		Instance.new("UICorner",pb).CornerRadius=UDim.new(0,9)
		Instance.new("UIStroke",pb).Color=Color3.fromRGB(30,30,30)
		pb.MouseButton1Click:Connect(function()
			aimbotSmooth=sp[1]
			smFill.Size=UDim2.new(sp[1],0,1,0); smHandle.Position=UDim2.new(sp[1],-8,0.5,-8)
			smValL.Text=tostring(math.floor(sp[1]*100)).."%"
		end)
		pb.MouseEnter:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb,TIF,{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
	end

	contentArea.CanvasSize = UDim2.new(0,0,0,432+math.ceil(4/2)*42+16)
end

-- ══════════════════════════════
--   ВЫБОР ВКЛАДКИ
-- ══════════════════════════════

local function selectTab(active,buildFn)
	for _,b in ipairs(allBtns) do
		TweenService:Create(b,TIF,{BackgroundTransparency=1}):Play()
		local ind=b:FindFirstChild("Ind"); if ind then TweenService:Create(ind,TIF,{BackgroundTransparency=1}):Play() end
		for _,ch in ipairs(b:GetDescendants()) do
			if ch:IsA("Frame") and ch.Name~="Ind" then pcall(function() TweenService:Create(ch,TIF,{BackgroundColor3=Color3.fromRGB(70,70,70)}):Play() end) end
		end
	end
	TweenService:Create(active,TIF,{BackgroundTransparency=0.86}):Play()
	local ind=active:FindFirstChild("Ind"); if ind then TweenService:Create(ind,TIF,{BackgroundTransparency=0}):Play() end
	for _,ch in ipairs(active:GetDescendants()) do
		if ch:IsA("Frame") and ch.Name~="Ind" then pcall(function() TweenService:Create(ch,TIF,{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play() end) end
	end
	buildFn()
end

btnSky.MouseButton1Click:Connect(function()      selectTab(btnSky,      buildSkyPage) end)
btnAnim.MouseButton1Click:Connect(function()     selectTab(btnAnim,     buildAnimPage) end)
btnLocker.MouseButton1Click:Connect(function()   selectTab(btnLocker,   buildLockerPage) end)
btnSkyC.MouseButton1Click:Connect(function()     selectTab(btnSkyC,     buildSkyChangerPage) end)
btnTools.MouseButton1Click:Connect(function()    selectTab(btnTools,    buildToolsPage) end)
btnSpeed.MouseButton1Click:Connect(function()    selectTab(btnSpeed,    buildSpeedPage) end)
btnEsp.MouseButton1Click:Connect(function()      selectTab(btnEsp,      buildEspPage) end)
btnNoclip.MouseButton1Click:Connect(function()   selectTab(btnNoclip,   buildNoclipPage) end)
btnShader.MouseButton1Click:Connect(function()   selectTab(btnShader,   buildShaderPage) end)
btnParticle.MouseButton1Click:Connect(function() selectTab(btnParticle, buildParticlePage) end)
btnHVH.MouseButton1Click:Connect(function()      selectTab(btnHVH,      buildHVHPage) end)
btnHitbox.MouseButton1Click:Connect(function()   selectTab(btnHitbox,   buildHitboxPage) end)
btnAimbot.MouseButton1Click:Connect(function()   selectTab(btnAimbot,   buildAimbotPage) end)

selectTab(btnSky, buildSkyPage)

-- ══════════════════════════════
--   МЫШЬ (для FPS игр)
-- ══════════════════════════════

local function unlockMouse()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
	getgenv().MouseLocked = true
end
local function lockMouseBack()
	getgenv().MouseLocked = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false
end

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

-- ══════════════════════════════
--   ОТКРЫТЬ / ЗАКРЫТЬ
-- ══════════════════════════════

local function openMenu()
	menuOpen=true; unlockMouse()
	mainFrame.Visible=true; mainFrame.BackgroundTransparency=1
	mainFrame.Size=UDim2.new(0.52,0,0.74,0); mainFrame.Position=UDim2.new(0.24,0,0.13,0)
	TweenService:Create(mainFrame,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
		Size=UDim2.new(0.55,0,0.78,0), Position=UDim2.new(0.225,0,0.11,0), BackgroundTransparency=0.06
	}):Play()
	TweenService:Create(vibeBlur,TweenInfo.new(0.28),{Size=18}):Play()
end

local function closeMenu()
	menuOpen=false
	TweenService:Create(mainFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
		Size=UDim2.new(0.52,0,0.74,0), Position=UDim2.new(0.24,0,0.14,0), BackgroundTransparency=1
	}):Play()
	TweenService:Create(vibeBlur,TweenInfo.new(0.2),{Size=0}):Play()
	task.delay(0.22,function() mainFrame.Visible=false; lockMouseBack() end)
end

closeBtn.MouseButton1Click:Connect(closeMenu)

-- B клавиша (Xeno polling)
getgenv().VibeMenuOpen = false
task.spawn(function()
	while task.wait(0.05) do
		if UserInputService:IsKeyDown(Enum.KeyCode.B) then
			if not getgenv().VibeMenuOpen then
				getgenv().VibeMenuOpen=true
				if menuOpen then closeMenu() else openMenu() end
				task.wait(0.3); getgenv().VibeMenuOpen=false
			end
		end
	end
end)

-- ══════════════════════════════
--   DRAG
-- ══════════════════════════════

do
	local dr,ds,sp=false,nil,nil
	topBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;ds=i.Position;sp=mainFrame.Position end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
			local d=i.Position-ds; mainFrame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
		end
	end)
end

-- ══════════════════════════════
--   HEARTBEAT LOOPS
-- ══════════════════════════════

RunService.Heartbeat:Connect(function()
	-- Locker gyro
	if lockerActive and lockerBG and lockerBG.Parent then
		local char=player.Character; if char then local hrp=char:FindFirstChild("HumanoidRootPart"); if hrp then lockerBG.CFrame=CFrame.new(hrp.Position) end end
	end
	-- Particles следуют за персонажем (уже прикреплены к hrp, автоматически)
end)

-- T клавиша — Locker (polling как B, надёжно работает в FPS играх)
getgenv().LockerKeyDown = false
task.spawn(function()
	while task.wait(0.05) do
		if UserInputService:IsKeyDown(Enum.KeyCode.T) then
			if not getgenv().LockerKeyDown then
				getgenv().LockerKeyDown = true
				lockerActive = not lockerActive
				local char=player.Character
				if char then
					local hrp=char:FindFirstChild("HumanoidRootPart")
					if hrp then
						if lockerActive then
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
						else
							if lockerBV and lockerBV.Parent then lockerBV:Destroy(); lockerBV=nil end
							if lockerBG and lockerBG.Parent then lockerBG:Destroy(); lockerBG=nil end
						end
					end
				end
				task.wait(0.3)
				getgenv().LockerKeyDown = false
			end
		end
	end
end)

-- При смерти — убираем всё
player.CharacterAdded:Connect(function()
	task.wait(1)
	if particleActive and currentParticle then
		local cur=currentParticle; applyParticle(cur)
	end
	if lockerActive then lockerActive=false end
end)

print("[VibeMenu] OK — B открыть | T Locker")

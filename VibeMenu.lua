[07.03.2026 1:44] . .: -- ╔══════════════════════════════════════════╗
-- ║         XENO MENU  by Script             ║
-- ║         Open: B key (English)            ║
-- ╚══════════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════
--              CONFIG
-- ══════════════════════════════════════════
local Config = {
    OpenKey = Enum.KeyCode.B,
    MenuOpen = false,
    MenuSize = UDim2.new(0, 680, 0, 480),
    Theme = {
        Background = Color3.fromRGB(8, 8, 8),
        Panel = Color3.fromRGB(14, 14, 14),
        SideBar = Color3.fromRGB(11, 11, 11),
        Accent = Color3.fromRGB(220, 220, 220),
        AccentDim = Color3.fromRGB(140, 140, 140),
        Button = Color3.fromRGB(22, 22, 22),
        ButtonHover = Color3.fromRGB(35, 35, 35),
        ButtonActive = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(230, 230, 230),
        TextDim = Color3.fromRGB(110, 110, 110),
        Border = Color3.fromRGB(35, 35, 35),
        Toggle_On = Color3.fromRGB(220, 220, 220),
        Toggle_Off = Color3.fromRGB(40, 40, 40),
        Red = Color3.fromRGB(220, 60, 60),
        Green = Color3.fromRGB(60, 200, 100),
    },
}

-- ══════════════════════════════════════════
--              STATE
-- ══════════════════════════════════════════
local State = {
    ESP = false,
    FOV = false,
    FOVValue = 70,
    HighJump = false,
    JumpPower = 50,
    Speed = false,
    SpeedValue = 16,
    Fling = false,
    FlingSpeed = 1,
    Pallet = false,
    HudEnabled = false,
    Fly = false,
    FlySpeed = 50,
    ActiveSection = 1,
    ActiveFunctions = {},
}

-- ══════════════════════════════════════════
--              UTILS
-- ══════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    local ti = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, ti, props):Play()
end
[07.03.2026 1:44] . .: local function Notify(text)
    if not State.HudEnabled then return end
    local notifGui = LocalPlayer.PlayerGui:FindFirstChild("XenoNotif")
    if notifGui then notifGui:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "XenoNotif"
    sg.ResetOnSpawn = false
    sg.Parent = LocalPlayer.PlayerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 36)
    frame.Position = UDim2.new(1, -230, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(14,14,14)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60,60,60)
    stroke.Thickness = 1
    stroke.Parent = frame
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 12, 0.5, -3)
    dot.BackgroundColor3 = Config.Theme.Green
    dot.BorderSizePixel = 0
    dot.Parent = frame
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1,0)
    dc.Parent = dot
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -34, 1, 0)
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Config.Theme.Text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    frame.Position = UDim2.new(1, 10, 1, -50)
    Tween(frame, {Position = UDim2.new(1, -230, 1, -50)}, 0.3)
    task.delay(2.5, function()
        Tween(frame, {Position = UDim2.new(1, 10, 1, -50)}, 0.3)
        task.delay(0.35, function() sg:Destroy() end)
    end)
end

-- ══════════════════════════════════════════
--              ESP FUNCTION
-- ══════════════════════════════════════════
local ESPConnections = {}
local function ClearESP()
    for _, c in pairs(ESPConnections) do pcall(function() c:Disconnect() end) end
    ESPConnections = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local gui = plr.PlayerGui:FindFirstChild("XenoESP")
            if gui then gui:Destroy() end
            -- billboard
            local char = plr.Character
            if char then
                local bb = char:FindFirstChild("XenoESPBB")
                if bb then bb:Destroy() end
                local hl = char:FindFirstChild("XenoHL")
                if hl then hl:Destroy() end
            end
        end
    end
end

local function CreateESPForPlayer(plr)
    if plr == LocalPlayer then return end
    local function setup()
        local char = plr.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then return end

        -- Highlight
        local hl = Instance.new("SelectionBox")
        hl.Name = "XenoHL"
        hl.Color3 = Color3.fromRGB(220,220,220)
        hl.LineThickness = 0.04
        hl.SurfaceTransparency = 0.85
        hl.SurfaceColor3 = Color3.fromRGB(220,220,220)
        hl.Adornee = char
        hl.Parent = char

        -- BillboardGui above head
        local bb = Instance.new("BillboardGui")
        bb.Name = "XenoESPBB"
        bb.Size = UDim2.new(0, 160, 0, 44)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent = char

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(8,8,8)
        bg.BackgroundTransparency = 0.25
        bg.BorderSizePixel = 0
        bg.Parent = bb
        local bgc = Instance.new("UICorner")
        bgc.CornerRadius = UDim.new(0, 6)
        bgc.Parent = bg
        local bgs = Instance.new("UIStroke")
        bgs.Color = Color3.fromRGB(200,200,200)
        bgs.Thickness = 1
        bgs.Transparency = 0.3
        bgs.Parent = bg
[07.03.2026 1:44] . .: local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -8, 0.55, 0)
        nameLbl.Position = UDim2.new(0, 4, 0, 2)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "◈  " .. plr.Name
        nameLbl.TextColor3 = Color3.fromRGB(230,230,230)
        nameLbl.TextSize = 11
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Parent = bg

        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1, -8, 0.45, 0)
        distLbl.Position = UDim2.new(0, 4, 0.55, 0)
        distLbl.BackgroundTransparency = 1
        distLbl.TextColor3 = Color3.fromRGB(160,160,160)
        distLbl.TextSize = 10
        distLbl.Font = Enum.Font.Gotham
        distLbl.TextXAlignment = Enum.TextXAlignment.Left
        distLbl.Parent = bg

        local conn = RunService.RenderStepped:Connect(function()
            if not State.ESP or not char.Parent or not hrp.Parent then
                bb:Destroy()
                hl:Destroy()
                return
            end
            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
            distLbl.Text = "  ⟡ " .. dist .. " m"
        end)
        table.insert(ESPConnections, conn)
    end

    local charConn = plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        setup()
    end)
    table.insert(ESPConnections, charConn)
    if plr.Character then
        task.wait(0.1)
        setup()
    end
end

local function ToggleESP(val)
    State.ESP = val
    if val then
        for _, plr in pairs(Players:GetPlayers()) do
            CreateESPForPlayer(plr)
        end
        local joinConn = Players.PlayerAdded:Connect(function(plr)
            CreateESPForPlayer(plr)
        end)
        table.insert(ESPConnections, joinConn)
    else
        ClearESP()
    end
end

-- ══════════════════════════════════════════
--              FOV
-- ══════════════════════════════════════════
local function SetFOV(val)
    Camera.FieldOfView = val
end

-- ══════════════════════════════════════════
--              HIGH JUMP
-- ══════════════════════════════════════════
local jumpConn
local function ToggleHighJump(val, power)
    State.HighJump = val
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    if val then
        jumpConn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, (power or State.JumpPower) * 5, hrp.Velocity.Z)
            end
        end)
    end
end

-- ══════════════════════════════════════════
--              SPEED (Anti-cheat bypass)
-- ══════════════════════════════════════════
local speedConn
local function ToggleSpeed(val, spd)
    State.Speed = val
    if speedConn then speedConn:Disconnect() speedConn = nil end
    if val then
        speedConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum.WalkSpeed = spd or State.SpeedValue
                -- Bypass: re-apply every heartbeat to override server resets
                if hrp.AssemblyLinearVelocity.Magnitude > 0.5 then
                    local dir = hrp.AssemblyLinearVelocity.Unit
                    hrp.AssemblyLinearVelocity = Vector3.new(dir.X, hrp.AssemblyLinearVelocity.Y, dir.Z) * (spd or State.SpeedValue)
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end
[07.03.2026 1:44] . .: -- ══════════════════════════════════════════
--              FLING
-- ══════════════════════════════════════════
local flingConn
local function ToggleFling(val, intensity)
    State.Fling = val
    if flingConn then flingConn:Disconnect() flingConn = nil end
    if val then
        flingConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp = (intensity or State.FlingSpeed)
                local t = tick() * sp * 2
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(sp * 15), 0)
            end
        end)
    end
end

-- ══════════════════════════════════════════
--              PALLET SPAWN
-- ══════════════════════════════════════════
local palletConn
local function SpawnPallet()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pallets = Workspace:FindFirstChild("Pallets")
    if not pallets then return end
    local template = pallets:FindFirstChild("PalletLightBrown")
    if not template then return end
    local clone = template:Clone()
    clone.Parent = Workspace
    if clone:IsA("Model") then
        local primary = clone.PrimaryPart or clone:FindFirstChildOfClass("BasePart")
        if primary then
            clone:SetPrimaryPartCFrame(CFrame.new(hrp.Position - Vector3.new(0, 2, 0)))
        end
    elseif clone:IsA("BasePart") then
        clone.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2, 0))
    end
    Notify("Pallet spawned!")
end

local palletToggle = false
local function TogglePalletAuto(val)
    palletToggle = val
    if palletConn then palletConn:Disconnect() palletConn = nil end
    if val then
        palletConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Tab then
                SpawnPallet()
            end
        end)
    end
end

-- ══════════════════════════════════════════
--              HACK (Plot Owner)
-- ══════════════════════════════════════════
local function HackPlot(newName)
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then Notify("Plots not found!") return end
    local plot2 = plots:FindFirstChild("Plot2")
    if not plot2 then Notify("Plot2 not found!") return end
    local owners = plot2:FindFirstChild("ThisPlotsOwners")
    if not owners then Notify("ThisPlotsOwners not found!") return end
    local val = owners:FindFirstChildOfClass("StringValue") or owners:FindFirstChildOfClass("ValueBase")
    if not val then
        -- try all children
        for _, v in pairs(owners:GetChildren()) do
            if v:IsA("ValueBase") then val = v break end
        end
    end
    if val then
        val.Value = newName or LocalPlayer.Name
        Notify("Plot owner set to: " .. (newName or LocalPlayer.Name))
    else
        Notify("Value not found in ThisPlotsOwners!")
    end
end

-- ══════════════════════════════════════════
--              FLY
-- ══════════════════════════════════════════
local flyConn, flyBodyVelocity, flyBodyGyro
local function ToggleFly(val)
    State.Fly = val
    if flyConn then flyConn:Disconnect() flyConn = nil end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if val then
        hum.PlatformStand = true
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Velocity = Vector3.zero
        flyBodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9)
        flyBodyVelocity.Parent = hrp
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
        flyBodyGyro.P = 1e6
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp
[07.03.2026 1:44] . .: flyConn = RunService.RenderStepped:Connect(function()
            if not State.Fly then return end
            local spd = State.FlySpeed
            local cam = Camera.CFrame
            local vel = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0,1,0) end
            flyBodyVelocity.Velocity = vel * spd
            flyBodyGyro.CFrame = cam
        end)
    else
        hum.PlatformStand = false
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
    end
end

-- ══════════════════════════════════════════
--              TELEPORT
-- ══════════════════════════════════════════
local function TpRandom()
    local all = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(all, p)
        end
    end
    if #all == 0 then Notify("No players found!") return end
    local target = all[math.random(1, #all)]
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
        Notify("Teleported to " .. target.Name)
    end
end

local function TpToMouse()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
    if result then
        hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        Notify("Teleported to cursor!")
    end
end

-- ══════════════════════════════════════════
--              COIN TELEPORT
-- ══════════════════════════════════════════
local function TpToCoin()
    local slots = Workspace:FindFirstChild("Slots")
    if not slots then Notify("Slots folder not found!") return end
    local target = nil
    for _, slot in pairs(slots:GetDescendants()) do
        if slot.Name == "LightBall" then target = slot break end
    end
    if not target then Notify("LightBall not found!") return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = target:IsA("BasePart") and target.Position or (target:IsA("Model") and target:GetModelCFrame().Position)
        if pos then
            char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
            Notify("Teleported to LightBall!")
        end
    end
end

-- ══════════════════════════════════════════
--              HUD
-- ══════════════════════════════════════════
local hudGui
local function BuildHUD()
    if hudGui then hudGui:Destroy() end
    hudGui = Instance.new("ScreenGui")
    hudGui.Name = "XenoHUD"
    hudGui.ResetOnSpawn = false
    hudGui.DisplayOrder = 100
    hudGui.Parent = LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 64)
    frame.Position = UDim2.new(0, 12, 0, 12)
    frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = hudGui
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0,8)
    fc.Parent = frame
    local fs = Instance.new("UIStroke")
    fs.Color = Color3.fromRGB(60,60,60)
    fs.Thickness = 1
    fs.Parent = frame
[07.03.2026 1:44] . .: -- Avatar thumb
    local thumb = Instance.new("ImageLabel")
    thumb.Size = UDim2.new(0, 44, 0, 44)
    thumb.Position = UDim2.new(0, 10, 0.5, -22)
    thumb.BackgroundColor3 = Color3.fromRGB(25,25,25)
    thumb.BorderSizePixel = 0
    thumb.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=48&height=48&format=png"
    thumb.Parent = frame
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0,6)
    tc.Parent = thumb

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1,-66,0,22)
    nameL.Position = UDim2.new(0,60,0,8)
    nameL.BackgroundTransparency = 1
    nameL.Text = LocalPlayer.Name
    nameL.TextColor3 = Color3.fromRGB(230,230,230)
    nameL.TextSize = 12
    nameL.Font = Enum.Font.GothamBold
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = frame

    local fpsL = Instance.new("TextLabel")
    fpsL.Size = UDim2.new(1,-66,0,16)
    fpsL.Position = UDim2.new(0,60,0,30)
    fpsL.BackgroundTransparency = 1
    fpsL.TextColor3 = Color3.fromRGB(130,130,130)
    fpsL.TextSize = 10
    fpsL.Font = Enum.Font.Gotham
    fpsL.TextXAlignment = Enum.TextXAlignment.Left
    fpsL.Parent = frame

    local fpsConn = RunService.RenderStepped:Connect(function()
        local fps = math.floor(1/RunService.RenderStepped:Wait())
        -- Aktau time UTC+5
        local utcTime = os.time()
        local aktauHour = math.floor((utcTime % 86400) / 3600 + 5) % 24
        local aktauMin = math.floor((utcTime % 3600) / 60)
        fpsL.Text = string.format("FPS: %d  |  Aktau %02d:%02d", fps, aktauHour, aktauMin)
    end)
    -- store for cleanup
    hudGui:GetPropertyChangedSignal("Parent"):Connect(function()
        fpsConn:Disconnect()
    end)
end

local function ToggleHUD(val)
    State.HudEnabled = val
    if val then
        BuildHUD()
    else
        if hudGui then hudGui:Destroy() hudGui = nil end
    end
end

-- ══════════════════════════════════════════
--              SKIN / HVH
-- ══════════════════════════════════════════
local function ApplySkin(targetNick)
    local targetPlayer = Players:FindFirstChild(targetNick)
    if targetPlayer then
        local appearance = targetPlayer.Character
        if appearance then
            local desc = Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ApplyDescription(desc)
                    Notify("Skin applied: " .. targetNick)
                end
            end
        end
    else
        -- try by name from platform
        local ok, desc = pcall(function()
            local uid = Players:GetUserIdFromNameAsync(targetNick)
            return Players:GetHumanoidDescriptionFromUserId(uid)
        end)
        if ok and desc then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ApplyDescription(desc)
                    Notify("Skin applied: " .. targetNick)
                end
            end
        else
            Notify("Player not found!")
        end
    end
end

local function SetVisualName(newName)
    -- Change name above head visually
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayName = newName
        Notify("Name set to: " .. newName)
    end
end
[07.03.2026 1:44] . .: -- ══════════════════════════════════════════
--              SKYBOX
-- ══════════════════════════════════════════
local SkyPresets = {
    {name="🌙 Night", sky="rbxassetid://159454299"},
    {name="🌅 Sunset", sky="rbxassetid://182667080"},
    {name="🌄 Dawn", sky="rbxassetid://185177702"},
    {name="❄️ Arctic", sky="rbxassetid://151165209"},
    {name="☁️ Cloudy", sky="rbxassetid://141355621"},
    {name="🔥 Fire Sky", sky="rbxassetid://2845660"},
    {name="🌌 Galaxy", sky="rbxassetid://129474335"},
    {name="🌊 Ocean Haze", sky="rbxassetid://276977061"},
    {name="🌿 Forest", sky="rbxassetid://159454332"},
    {name="🏙 Citynight", sky="rbxassetid://576530274"},
}
local function ApplySky(preset)
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    local faces = {"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}
    for _, face in pairs(faces) do
        sky[face] = preset.sky
    end
    Notify("Sky: " .. preset.name)
end

-- ══════════════════════════════════════════
--         GREETING ANIMATION
-- ══════════════════════════════════════════
local function PlayGreeting()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507770239" -- wave emote
        local track = hum:LoadAnimation(anim)
        track:Play()
        Notify("Wave animation played!")
        task.delay(3, function() track:Stop() end)
    end
end

-- ══════════════════════════════════════════
--           MUSIC (YouTube via HTML5)
-- ══════════════════════════════════════════
local musicGui
local function PlayMusic(url, volume)
    if musicGui then musicGui:Destroy() end
    musicGui = Instance.new("ScreenGui")
    musicGui.Name = "XenoMusic"
    musicGui.ResetOnSpawn = false
    musicGui.Parent = LocalPlayer.PlayerGui
    -- We use a Frame with a label since Roblox can't embed YouTube
    -- Instead we use Roblox Sound with asset or show link
    Notify("Music: Use Roblox Sound ID or URL")
    -- If numeric sound id provided:
    local soundId = tonumber(url)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local existing = hrp:FindFirstChild("XenoSound")
        if existing then existing:Destroy() end
        if soundId then
            local sound = Instance.new("Sound")
            sound.Name = "XenoSound"
            sound.SoundId = "rbxassetid://" .. soundId
            sound.Volume = volume or 0.5
            sound.Looped = true
            sound.Parent = hrp
            sound:Play()
            Notify("Playing sound: " .. soundId)
        end
    end
end

local function StopMusic()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local s = hrp:FindFirstChild("XenoSound")
        if s then s:Destroy() end
    end
    if musicGui then musicGui:Destroy() musicGui = nil end
end

-- ══════════════════════════════════════════
--            MAIN GUI BUILD
-- ══════════════════════════════════════════

-- Remove old GUI
local function CleanOld()
    local existing = LocalPlayer.PlayerGui:FindFirstChild("XenoMenu")
    if existing then existing:Destroy() end
end
CleanOld()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = Config.MenuSize
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -240)
MainFrame.BackgroundColor3 = Config.Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame
[07.03.2026 1:44] . .: local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Theme.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Drop shadow
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, 10)
Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = MainFrame
local ShadowC = Instance.new("UICorner")
ShadowC.CornerRadius = UDim.new(0,16)
ShadowC.Parent = Shadow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Config.Theme.Panel
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TBC = Instance.new("UICorner")
TBC.CornerRadius = UDim.new(0,12)
TBC.Parent = TitleBar
-- fix bottom corners
local TBFix = Instance.new("Frame")
TBFix.Size = UDim2.new(1,0,0.5,0)
TBFix.Position = UDim2.new(0,0,0.5,0)
TBFix.BackgroundColor3 = Config.Theme.Panel
TBFix.BorderSizePixel = 0
TBFix.Parent = TitleBar

local TitleLogo = Instance.new("TextLabel")
TitleLogo.Size = UDim2.new(0, 80, 1, 0)
TitleLogo.Position = UDim2.new(0, 16, 0, 0)
TitleLogo.BackgroundTransparency = 1
TitleLogo.Text = "✦ XENO"
TitleLogo.TextColor3 = Config.Theme.Accent
TitleLogo.TextSize = 15
TitleLogo.Font = Enum.Font.GothamBold
TitleLogo.TextXAlignment = Enum.TextXAlignment.Left
TitleLogo.Parent = TitleBar

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(0, 200, 1, 0)
TitleSub.Position = UDim2.new(0, 100, 0, 0)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "MENU  v2.0"
TitleSub.TextColor3 = Config.Theme.TextDim
TitleSub.TextSize = 11
TitleSub.Font = Enum.Font.Gotham
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Config.Theme.Button
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Config.Theme.TextDim
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
local CBC = Instance.new("UICorner")
CBC.CornerRadius = UDim.new(0,6)
CBC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    State.MenuOpen = false
    Tween(MainFrame, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.25)
    task.delay(0.28, function() MainFrame.Visible = false MainFrame.Size = Config.MenuSize MainFrame.Position = UDim2.new(0.5,-340,0.5,-240) end)
end)

-- Drag
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Sidebar
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 170, 1, -44)
SideBar.Position = UDim2.new(0, 0, 0, 44)
SideBar.BackgroundColor3 = Config.Theme.SideBar
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame
local SBC = Instance.new("UICorner")
SBC.CornerRadius = UDim.new(0,12)
SBC.Parent = SideBar
local SBFix = Instance.new("Frame")
SBFix.Size = UDim2.new(0,0.5,1,0)
SBFix.Position = UDim2.new(1,-0.5,0,0)
SBFix.BackgroundColor3 = Config.Theme.SideBar
SBFix.BorderSizePixel = 0
SBFix.Parent = SideBar
[07.03.2026 1:44] . .: local SBList = Instance.new("ScrollingFrame")
SBList.Size = UDim2.new(1,-8,1,-12)
SBList.Position = UDim2.new(0,4,0,8)
SBList.BackgroundTransparency = 1
SBList.BorderSizePixel = 0
SBList.ScrollBarThickness = 2
SBList.ScrollBarImageColor3 = Color3.fromRGB(60,60,60)
SBList.CanvasSize = UDim2.new(0,0,0,0)
SBList.AutomaticCanvasSize = Enum.AutomaticSize.Y
SBList.Parent = SideBar
local SBPad = Instance.new("UIPadding")
SBPad.PaddingTop = UDim.new(0,4)
SBPad.Parent = SBList
local SBLayout = Instance.new("UIListLayout")
SBLayout.Padding = UDim.new(0,3)
SBLayout.Parent = SBList

-- Content Area
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -180, 1, -56)
ContentArea.Position = UDim2.new(0, 178, 0, 52)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 2
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(60,60,60)
ContentArea.CanvasSize = UDim2.new(0,0,0,0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.Parent = MainFrame
local CALayout = Instance.new("UIListLayout")
CALayout.Padding = UDim.new(0,8)
CALayout.Parent = ContentArea
local CAPad = Instance.new("UIPadding")
CAPad.PaddingTop = UDim.new(0,8)
CAPad.PaddingLeft = UDim.new(0,8)
CAPad.PaddingRight = UDim.new(0,12)
CAPad.Parent = ContentArea

-- Divider line between sidebar and content
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 1, -54)
Divider.Position = UDim2.new(0, 174, 0, 50)
Divider.BackgroundColor3 = Config.Theme.Border
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- ══════════════════════════════════════════
--           COMPONENT BUILDERS
-- ══════════════════════════════════════════

-- Section pages storage
local SectionPages = {}
local SectionButtons = {}

local function ShowSection(idx)
    State.ActiveSection = idx
    for i, page in pairs(SectionPages) do
        page.Visible = (i == idx)
    end
    for i, btn in pairs(SectionButtons) do
        if i == idx then
            Tween(btn, {BackgroundColor3 = Config.Theme.ButtonActive}, 0.15)
            local lbl = btn:FindFirstChildOfClass("TextLabel")
            if lbl then Tween(lbl, {TextColor3 = Color3.fromRGB(10,10,10)}, 0.15) end
        else
            Tween(btn, {BackgroundColor3 = Config.Theme.Button}, 0.15)
            local lbl = btn:FindFirstChildOfClass("TextLabel")
            if lbl then Tween(lbl, {TextColor3 = Config.Theme.TextDim}, 0.15) end
        end
    end
    ContentArea.CanvasPosition = Vector2.zero
end

-- Creates a sidebar nav button
local function MakeSectionBtn(idx, icon, label)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Config.Theme.Button
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = SBList
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,7)
    bc.Parent = btn
    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(0,28,1,0)
    iconL.Position = UDim2.new(0,8,0,0)
    iconL.BackgroundTransparency = 1
    iconL.Text = icon
    iconL.TextColor3 = Config.Theme.TextDim
    iconL.TextSize = 14
    iconL.Font = Enum.Font.GothamBold
    iconL.Parent = btn
    local textL = Instance.new("TextLabel")
    textL.Size = UDim2.new(1,-42,1,0)
    textL.Position = UDim2.new(0,38,0,0)
    textL.BackgroundTransparency = 1
    textL.Text = label
    textL.TextColor3 = Config.Theme.TextDim
    textL.TextSize = 11
    textL.Font = Enum.Font.Gotham
    textL.TextXAlignment = Enum.TextXAlignment.Left
    textL.Parent = btn
    SectionButtons[idx] = btn
    btn.MouseButton1Click:Connect(function() ShowSection(idx) end)
    btn.MouseEnter:Connect(function()
        if State.ActiveSection ~= idx then
            Tween(btn, {BackgroundColor3 = Config.Theme.ButtonHover}, 0.1)
        end
    end)
    btn.MouseLeave:Connect(function()
        if State.ActiveSection ~= idx then
            Tween(btn, {BackgroundColor3 = Config.Theme.Button}, 0.1)
        end
    end)
    return btn
end
[07.03.2026 1:44] . .: -- Creates a section page (Frame inside ContentArea)
local function MakePage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = ContentArea
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = page
    return page
end

-- Section header label
local function MakeSectionHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Config.Theme.TextDim
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- Toggle button
local function MakeToggle(parent, label, desc, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Config.Theme.Button
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0,8)
    fc.Parent = frame

    local labelL = Instance.new("TextLabel")
    labelL.Size = UDim2.new(1,-60,0,22)
    labelL.Position = UDim2.new(0,12,0,8)
    labelL.BackgroundTransparency = 1
    labelL.Text = label
    labelL.TextColor3 = Config.Theme.Text
    labelL.TextSize = 12
    labelL.Font = Enum.Font.GothamBold
    labelL.TextXAlignment = Enum.TextXAlignment.Left
    labelL.Parent = frame

    if desc and desc ~= "" then
        local descL = Instance.new("TextLabel")
        descL.Size = UDim2.new(1,-60,0,16)
        descL.Position = UDim2.new(0,12,0,28)
        descL.BackgroundTransparency = 1
        descL.Text = desc
        descL.TextColor3 = Config.Theme.TextDim
        descL.TextSize = 10
        descL.Font = Enum.Font.Gotham
        descL.TextXAlignment = Enum.TextXAlignment.Left
        descL.Parent = frame
    end

    -- Toggle pill
    local pillBg = Instance.new("Frame")
    pillBg.Size = UDim2.new(0,44,0,24)
    pillBg.Position = UDim2.new(1,-54,0.5,-12)
    pillBg.BackgroundColor3 = Config.Theme.Toggle_Off
    pillBg.BorderSizePixel = 0
    pillBg.Parent = frame
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(1,0)
    pc.Parent = pillBg

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,18,0,18)
    dot.Position = UDim2.new(0,3,0.5,-9)
    dot.BackgroundColor3 = Color3.fromRGB(180,180,180)
    dot.BorderSizePixel = 0
    dot.Parent = pillBg
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1,0)
    dc.Parent = dot

    local toggled = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Tween(pillBg, {BackgroundColor3 = Config.Theme.Toggle_On}, 0.2)
            Tween(dot, {Position = UDim2.new(0,23,0.5,-9), BackgroundColor3 = Color3.fromRGB(10,10,10)}, 0.2)
        else
            Tween(pillBg, {BackgroundColor3 = Config.Theme.Toggle_Off}, 0.2)
            Tween(dot, {Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = Color3.fromRGB(180,180,180)}, 0.2)
        end
        callback(toggled)
    end)

    return frame, function(v)
        toggled = v
        if v then
            pillBg.BackgroundColor3 = Config.Theme.Toggle_On
            dot.Position = UDim2.new(0,23,0.5,-9)
            dot.BackgroundColor3 = Color3.fromRGB(10,10,10)
        else
            pillBg.BackgroundColor3 = Config.Theme.Toggle_Off
            dot.Position = UDim2.new(0,3,0.5,-9)
            dot.BackgroundColor3 = Color3.fromRGB(180,180,180)
        end
    end
end
[07.03.2026 1:44] . .: -- Button (action)
local function MakeButton(parent, label, desc, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Config.Theme.Button
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0,8)
    fc.Parent = frame

    local labelL = Instance.new("TextLabel")
    labelL.Size = UDim2.new(1,-60,0,22)
    labelL.Position = UDim2.new(0,12,0,8)
    labelL.BackgroundTransparency = 1
    labelL.Text = label
    labelL.TextColor3 = Config.Theme.Text
    labelL.TextSize = 12
    labelL.Font = Enum.Font.GothamBold
    labelL.TextXAlignment = Enum.TextXAlignment.Left
    labelL.Parent = frame

    if desc and desc ~= "" then
        local descL = Instance.new("TextLabel")
        descL.Size = UDim2.new(1,-60,0,16)
        descL.Position = UDim2.new(0,12,0,28)
        descL.BackgroundTransparency = 1
        descL.Text = desc
        descL.TextColor3 = Config.Theme.TextDim
        descL.TextSize = 10
        descL.Font = Enum.Font.Gotham
        descL.TextXAlignment = Enum.TextXAlignment.Left
        descL.Parent = frame
    end

    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0,70,0,28)
    actionBtn.Position = UDim2.new(1,-82,0.5,-14)
    actionBtn.BackgroundColor3 = Config.Theme.Accent
    actionBtn.BorderSizePixel = 0
    actionBtn.Text = "RUN"
    actionBtn.TextColor3 = Color3.fromRGB(10,10,10)
    actionBtn.TextSize = 11
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.Parent = frame
    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(0,6)
    ac.Parent = actionBtn

    actionBtn.MouseButton1Click:Connect(function()
        Tween(actionBtn, {BackgroundColor3 = Color3.fromRGB(160,160,160)}, 0.1)
        task.delay(0.12, function() Tween(actionBtn, {BackgroundColor3 = Config.Theme.Accent}, 0.1) end)
        callback()
    end)

    return frame
end

-- Slider
local function MakeSlider(parent, label, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Config.Theme.Button
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0,8)
    fc.Parent = frame

    local labelL = Instance.new("TextLabel")
    labelL.Size = UDim2.new(0.7,0,0,22)
    labelL.Position = UDim2.new(0,12,0,8)
    labelL.BackgroundTransparency = 1
    labelL.Text = label
    labelL.TextColor3 = Config.Theme.Text
    labelL.TextSize = 12
    labelL.Font = Enum.Font.GothamBold
    labelL.TextXAlignment = Enum.TextXAlignment.Left
    labelL.Parent = frame

    local valL = Instance.new("TextLabel")
    valL.Size = UDim2.new(0.3,-12,0,22)
    valL.Position = UDim2.new(0.7,0,0,8)
    valL.BackgroundTransparency = 1
    valL.Text = tostring(default)
    valL.TextColor3 = Config.Theme.Accent
    valL.TextSize = 12
    valL.Font = Enum.Font.GothamBold
    valL.TextXAlignment = Enum.TextXAlignment.Right
    valL.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-24,0,4)
    track.Position = UDim2.new(0,12,0,38)
    track.BackgroundColor3 = Config.Theme.Border
    track.BorderSizePixel = 0
    track.Parent = frame
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Config.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fillc = Instance.new("UICorner")
    fillc.CornerRadius = UDim.new(1,0)
    fillc.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,14,0,14)
    knob.Position = UDim2.new((default-min)/(max-min),0-7,0.5,-7)
    knob.BackgroundColor3 = Config.Theme.Accent
    knob.BorderSizePixel = 0
    knob.Parent = track
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1,0)
    kc.Parent = knob
[07.03.2026 1:44] . .: local sliding = false
    local function Update(x)
        local abs = track.AbsoluteSize.X
        local rel = math.clamp((x - track.AbsolutePosition.X) / abs, 0, 1)
        local val = math.floor(min + (max-min)*rel)
        valL.Text = tostring(val)
        Tween(fill, {Size = UDim2.new(rel,0,1,0)}, 0.05)
        Tween(knob, {Position = UDim2.new(rel,-7,0.5,-7)}, 0.05)
        callback(val)
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true Update(inp.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then Update(inp.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    return frame
end

-- TextInput
local function MakeInput(parent, label, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = Config.Theme.Button
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0,8)
    fc.Parent = frame

    local labelL = Instance.new("TextLabel")
    labelL.Size = UDim2.new(1,-12,0,20)
    labelL.Position = UDim2.new(0,12,0,6)
    labelL.BackgroundTransparency = 1
    labelL.Text = label
    labelL.TextColor3 = Config.Theme.TextDim
    labelL.TextSize = 10
    labelL.Font = Enum.Font.GothamBold
    labelL.TextXAlignment = Enum.TextXAlignment.Left
    labelL.Parent = frame

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1,-24,0,24)
    inputBg.Position = UDim2.new(0,12,0,24)
    inputBg.BackgroundColor3 = Config.Theme.Background
    inputBg.BorderSizePixel = 0
    inputBg.Parent = frame
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0,5)
    ic.Parent = inputBg
    local is = Instance.new("UIStroke")
    is.Color = Config.Theme.Border
    is.Thickness = 1
    is.Parent = inputBg

    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1,-12,1,0)
    tb.Position = UDim2.new(0,6,0,0)
    tb.BackgroundTransparency = 1
    tb.PlaceholderText = placeholder or "Type here..."
    tb.PlaceholderColor3 = Config.Theme.TextDim
    tb.Text = ""
    tb.TextColor3 = Config.Theme.Text
    tb.TextSize = 11
    tb.Font = Enum.Font.Gotham
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.ClearTextOnFocus = false
    tb.Parent = inputBg

    tb.FocusLost:Connect(function(enter)
        if enter and tb.Text ~= "" then
            callback(tb.Text)
        end
    end)

    return frame
end

-- Dropdown for themes
local function MakeDropdown(parent, label, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundColor3 = Config.Theme.Button
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0,8)
    fc.Parent = frame
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5,0,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Config.Theme.Text
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0,130,0,28)
    selBtn.Position = UDim2.new(1,-142,0.5,-14)
    selBtn.BackgroundColor3 = Config.Theme.Background
    selBtn.BorderSizePixel = 0
    selBtn.Text = options[1] and options[1].name or "Select"
    selBtn.TextColor3 = Config.Theme.Accent
    selBtn.TextSize = 10
    selBtn.Font = Enum.Font.Gotham
    selBtn.Parent = frame
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0,6)
    sc.Parent = selBtn
    local ss = Instance.new("UIStroke")
    ss.Color = Config.Theme.Border
    ss.Thickness = 1
    ss.Parent = selBtn
[07.03.2026 1:44] . .: local ddFrame = Instance.new("Frame")
    ddFrame.Size = UDim2.new(0,140,0,0)
    ddFrame.Position = UDim2.new(1,-142,1,4)
    ddFrame.BackgroundColor3 = Config.Theme.Panel
    ddFrame.BorderSizePixel = 0
    ddFrame.ClipsDescendants = true
    ddFrame.ZIndex = 10
    ddFrame.Visible = false
    ddFrame.Parent = frame
    local ddc = Instance.new("UICorner")
    ddc.CornerRadius = UDim.new(0,7)
    ddc.Parent = ddFrame
    local dds = Instance.new("UIStroke")
    dds.Color = Config.Theme.Border
    dds.Thickness = 1
    dds.Parent = ddFrame
    local ddLayout = Instance.new("UIListLayout")
    ddLayout.Parent = ddFrame

    local open = false
    for _, opt in pairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,28)
        ob.BackgroundTransparency = 1
        ob.Text = opt.name
        ob.TextColor3 = Config.Theme.TextDim
        ob.TextSize = 10
        ob.Font = Enum.Font.Gotham
        ob.ZIndex = 11
        ob.Parent = ddFrame
        ob.MouseButton1Click:Connect(function()
            selBtn.Text = opt.name
            open = false
            Tween(ddFrame, {Size = UDim2.new(0,140,0,0)}, 0.2)
            task.delay(0.22, function() ddFrame.Visible = false end)
            callback(opt)
        end)
        ob.MouseEnter:Connect(function() ob.TextColor3 = Config.Theme.Accent end)
        ob.MouseLeave:Connect(function() ob.TextColor3 = Config.Theme.TextDim end)
    end

    selBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            ddFrame.Visible = true
            Tween(ddFrame, {Size = UDim2.new(0,140,0,#options*28)}, 0.2)
        else
            Tween(ddFrame, {Size = UDim2.new(0,140,0,0)}, 0.15)
            task.delay(0.18, function() ddFrame.Visible = false end)
        end
    end)

    return frame
end

-- ══════════════════════════════════════════
--         BUILD SECTIONS
-- ══════════════════════════════════════════

-- ── SECTION 1: MainFunction ──────────────
MakeSectionBtn(1, "◈", "MainFunction")
local p1 = MakePage()

MakeSectionHeader(p1, "ESP & VISUALS")
MakeToggle(p1, "ESP", "Show players with distance & name", function(v)
    ToggleESP(v)
    Notify("ESP " .. (v and "ON" or "OFF"))
end)

MakeSlider(p1, "FOV", 60, 120, 70, function(v)
    State.FOVValue = v
    if State.FOV then SetFOV(v) end
end)
MakeToggle(p1, "FOV", "Expand camera field of view", function(v)
    State.FOV = v
    SetFOV(v and State.FOVValue or 70)
    Notify("FOV " .. (v and "ON (" .. State.FOVValue .. "°)" or "OFF"))
end)

MakeSectionHeader(p1, "MOVEMENT")
MakeSlider(p1, "Jump Power", 1, 100, 50, function(v) State.JumpPower = v end)
MakeToggle(p1, "High Jump", "Set jump height 1–100 meters", function(v)
    ToggleHighJump(v, State.JumpPower)
    Notify("HighJump " .. (v and "ON" or "OFF"))
end)

MakeSlider(p1, "Speed Value", 1, 1000, 16, function(v) State.SpeedValue = v end)
MakeToggle(p1, "Speed", "Enhanced speed with anti-cheat bypass", function(v)
    ToggleSpeed(v, State.SpeedValue)
    Notify("Speed " .. (v and "ON (" .. State.SpeedValue .. ")" or "OFF"))
end)

MakeSectionHeader(p1, "COMBAT & FUN")
MakeToggle(p1, "Fling", "Spin your character (Slow / Fast / Ultra)", function(v)
    ToggleFling(v, State.FlingSpeed)
    Notify("Fling " .. (v and "ON" or "OFF"))
end)
MakeSlider(p1, "Fling Speed", 1, 20, 1, function(v) State.FlingSpeed = v if State.Fling then ToggleFling(true,v) end end)

MakeSectionHeader(p1, "REACH — FreeGamepassReach")
MakeButton(p1, "Reach", "FreeGamepassReach  —  launches gamepass script", function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Fling-Things-and-People-Free-Gamepass-80386"))()
    Notify("Reach script executed!")
end)

MakeSectionHeader(p1, "PALLET")
MakeToggle(p1, "Pallet Auto (Tab)", "Enable Tab key to spawn PalletLightBrown", function(v)
    TogglePalletAuto(v)
    Notify("Pallet " .. (v and "ON (Tab to spawn)" or "OFF"))
end)
MakeButton(p1, "Spawn Pallet Now", "Instant spawn under your feet", function()
    SpawnPallet()
end)
[07.03.2026 1:44] . .: MakeSectionHeader(p1, "HACK — PLOT OWNER")
MakeInput(p1, "Plot2 Owner Name", "Enter name (e.g. Dana_mammv)", function(text)
    HackPlot(text)
end)
MakeButton(p1, "Set Plot Owner", "Overwrites Plot2 > ThisPlotsOwners > Value", function()
    HackPlot(LocalPlayer.Name)
end)

-- ── SECTION 2: Menu-Gui ──────────────────
MakeSectionBtn(2, "◉", "Menu-Gui")
local p2 = MakePage()

MakeSectionHeader(p2, "THEME COLOR")
local themeOptions = {
    {name="⬛️ Black & White", bg=Color3.fromRGB(8,8,8), accent=Color3.fromRGB(220,220,220)},
    {name="🔵 Midnight Blue", bg=Color3.fromRGB(5,8,18), accent=Color3.fromRGB(80,140,255)},
    {name="🔴 Crimson", bg=Color3.fromRGB(12,5,5), accent=Color3.fromRGB(220,50,50)},
    {name="🟢 Matrix", bg=Color3.fromRGB(4,12,4), accent=Color3.fromRGB(40,220,80)},
    {name="🟣 Purple", bg=Color3.fromRGB(10,5,16), accent=Color3.fromRGB(160,80,255)},
    {name="🟠 Ember", bg=Color3.fromRGB(14,7,3), accent=Color3.fromRGB(255,140,40)},
    {name="🩵 Ice", bg=Color3.fromRGB(4,12,16), accent=Color3.fromRGB(100,220,255)},
    {name="⬜️ Light Mode", bg=Color3.fromRGB(235,235,235), accent=Color3.fromRGB(20,20,20)},
}
MakeDropdown(p2, "Theme", themeOptions, function(opt)
    Config.Theme.Background = opt.bg
    Config.Theme.Panel = Color3.new(opt.bg.R+0.03, opt.bg.G+0.03, opt.bg.B+0.03)
    Config.Theme.SideBar = Color3.new(opt.bg.R+0.015, opt.bg.G+0.015, opt.bg.B+0.015)
    Config.Theme.Accent = opt.accent
    Tween(MainFrame, {BackgroundColor3 = opt.bg}, 0.3)
    Tween(TitleBar, {BackgroundColor3 = Config.Theme.Panel}, 0.3)
    Tween(TBFix, {BackgroundColor3 = Config.Theme.Panel}, 0.3)
    Tween(SideBar, {BackgroundColor3 = Config.Theme.SideBar}, 0.3)
    Tween(SBFix, {BackgroundColor3 = Config.Theme.SideBar}, 0.3)
    Notify("Theme changed!")
end)

MakeSectionHeader(p2, "OPEN KEY")
local keyOptions = {}
local keys = {"B","N","M","F1","F2","F3","F4","Home","Insert","Delete","RightBracket","LeftBracket"}
for _, k in pairs(keys) do
    table.insert(keyOptions, {name=k, code=Enum.KeyCode[k]})
end
MakeDropdown(p2, "Menu Key", keyOptions, function(opt)
    Config.OpenKey = opt.code
    Notify("Menu key set to: " .. opt.name)
end)

MakeSectionHeader(p2, "SIZE & SCALE")
MakeSlider(p2, "Menu Width", 500, 900, 680, function(v)
    Config.MenuSize = UDim2.new(0,v,0, Config.MenuSize.Y.Offset)
    MainFrame.Size = Config.MenuSize
end)
MakeSlider(p2, "Menu Height", 350, 650, 480, function(v)
    Config.MenuSize = UDim2.new(0, Config.MenuSize.X.Offset, 0, v)
    MainFrame.Size = Config.MenuSize
end)

-- ── SECTION 3: Sky_World ─────────────────
MakeSectionBtn(3, "☁️", "Sky World")
local p3 = MakePage()

MakeSectionHeader(p3, "SKY COLOR")
for _, preset in pairs(SkyPresets) do
    local p = preset
    MakeButton(p3, p.name, "Apply atmospheric sky", function()
        ApplySky(p)
    end)
end

MakeSectionHeader(p3, "MUSIC")
MakeInput(p3, "Sound Asset ID", "Enter Roblox sound ID number", function(text)
    PlayMusic(text, 0.5)
end)
MakeSlider(p3, "Volume", 0, 100, 50, function(v)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local s = hrp:FindFirstChild("XenoSound")
        if s then s.Volume = v/100 end
    end
end)
MakeButton(p3, "Stop Music", "Stop currently playing sound", function()
    StopMusic()
end)

MakeSectionHeader(p3, "HVH — SKIN & IDENTITY")
MakeInput(p3, "Steal Skin From", "Enter player nickname", function(text)
    ApplySkin(text)
end)
MakeInput(p3, "Visual Nickname", "Enter display name (any symbols)", function(text)
    SetVisualName(text)
end)
MakeButton(p3, "Wave Greeting", "Play wave animation", function()
    PlayGreeting()
end)

MakeSectionHeader(p3, "FLY")
MakeToggle(p3, "Fly", "W/A/S/D + Space/Ctrl to fly", function(v)
    ToggleFly(v)
    Notify("Fly " .. (v and "ON" or "OFF"))
end)
MakeSlider(p3, "Fly Speed", 5, 200, 50, function(v)
    State.FlySpeed = v
end)

-- ── SECTION 4: InterFace ─────────────────
MakeSectionBtn(4, "◧", "InterFace")
local p4 = MakePage()
[07.03.2026 1:44] . .: MakeSectionHeader(p4, "HUD DISPLAY")
MakeToggle(p4, "HUD", "Top-left: nick + skin + FPS + Aktau time", function(v)
    ToggleHUD(v)
    Notify("HUD " .. (v and "ON" or "OFF"))
end)

MakeSectionHeader(p4, "COIN TELEPORT")
MakeButton(p4, "CoinFar", "Teleport to Workspace > Slots > LightBall", function()
    TpToCoin()
end)

-- ── SECTION 5: TpTELEPORT ────────────────
MakeSectionBtn(5, "⟡", "TpTeleport")
local p5 = MakePage()

MakeSectionHeader(p5, "TELEPORT")
MakeButton(p5, "Teleport to Random Player", "Jump to a random player in the server", function()
    TpRandom()
end)
MakeButton(p5, "Teleport to Cursor", "Raycast teleport wherever your mouse points", function()
    TpToMouse()
end)

-- Fill remaining sections as extra placeholders
local sectionDefs = {
    {6,  "◈", "Section 6"},
    {7,  "◈", "Section 7"},
    {8,  "◈", "Section 8"},
    {9,  "◈", "Section 9"},
    {10, "◈", "Section 10"},
    {11, "◈", "Section 11"},
    {12, "◈", "Section 12"},
    {13, "◈", "Section 13"},
    {14, "◈", "Section 14"},
    {15, "◈", "Section 15"},
    {16, "◈", "Section 16"},
    {17, "◈", "Section 17"},
    {18, "◈", "Section 18"},
    {19, "◈", "Section 19"},
    {20, "◈", "Section 20"},
}
for _, def in pairs(sectionDefs) do
    MakeSectionBtn(def[1], def[2], def[3])
    local pg = MakePage()
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,40)
    lbl.BackgroundTransparency = 1
    lbl.Text = def[3] .. "  —  Coming Soon"
    lbl.TextColor3 = Config.Theme.TextDim
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = pg
end

-- Register all pages
local allPages = ContentArea:GetChildren()
local pageIdx = 0
for _, child in pairs(allPages) do
    if child:IsA("Frame") then
        pageIdx = pageIdx + 1
        SectionPages[pageIdx] = child
    end
end

-- Default section
ShowSection(1)

-- ══════════════════════════════════════════
--          MENU TOGGLE (B KEY)
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.OpenKey then
        State.MenuOpen = not State.MenuOpen
        if State.MenuOpen then
            MainFrame.Size = UDim2.new(0,0,0,0)
            MainFrame.Position = UDim2.new(0.5,0,0.5,0)
            MainFrame.Visible = true
            Tween(MainFrame, {
                Size = Config.MenuSize,
                Position = UDim2.new(0.5,-340,0.5,-240)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            Tween(MainFrame, {
                Size = UDim2.new(0,0,0,0),
                Position = UDim2.new(0.5,0,0.5,0)
            }, 0.25)
            task.delay(0.28, function()
                MainFrame.Visible = false
                MainFrame.Size = Config.MenuSize
                MainFrame.Position = UDim2.new(0.5,-340,0.5,-240)
            end)
        end
    end
end)
[07.03.2026 1:44] . .: -- Intro notification
task.wait(1)
Notify = function(text)
    -- override for all future calls after HUD init
    local notifGui = LocalPlayer.PlayerGui:FindFirstChild("XenoNotif")
    if notifGui then notifGui:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "XenoNotif"
    sg.ResetOnSpawn = false
    sg.Parent = LocalPlayer.PlayerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 36)
    frame.Position = UDim2.new(1, -230, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(14,14,14)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60,60,60)
    stroke.Thickness = 1
    stroke.Parent = frame
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 12, 0.5, -3)
    dot.BackgroundColor3 = Config.Theme.Green
    dot.BorderSizePixel = 0
    dot.Parent = frame
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1,0)
    dc.Parent = dot
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -34, 1, 0)
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Config.Theme.Text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    frame.Position = UDim2.new(1, 10, 1, -50)
    Tween(frame, {Position = UDim2.new(1, -230, 1, -50)}, 0.3)
    task.delay(2.5, function()
        Tween(frame, {Position = UDim2.new(1, 10, 1, -50)}, 0.3)
        task.delay(0.35, function() sg:Destroy() end)
    end)
end

-- Load notification
local loadSg = Instance.new("ScreenGui")
loadSg.Name = "XenoLoad"
loadSg.ResetOnSpawn = false
loadSg.DisplayOrder = 2000
loadSg.Parent = LocalPlayer.PlayerGui
local loadFrame = Instance.new("Frame")
loadFrame.Size = UDim2.new(0,260,0,60)
loadFrame.Position = UDim2.new(0.5,-130,0,20)
loadFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
loadFrame.BackgroundTransparency = 0.1
loadFrame.BorderSizePixel = 0
loadFrame.Parent = loadSg
local lfc = Instance.new("UICorner")
lfc.CornerRadius = UDim.new(0,10)
lfc.Parent = loadFrame
local lfs = Instance.new("UIStroke")
lfs.Color = Color3.fromRGB(60,60,60)
lfs.Thickness = 1
lfs.Parent = loadFrame
local lTitle = Instance.new("TextLabel")
lTitle.Size = UDim2.new(1,0,0.5,0)
lTitle.BackgroundTransparency = 1
lTitle.Text = "✦  XENO MENU  LOADED"
lTitle.TextColor3 = Color3.fromRGB(230,230,230)
lTitle.TextSize = 13
lTitle.Font = Enum.Font.GothamBold
lTitle.Parent = loadFrame
local lSub = Instance.new("TextLabel")
lSub.Size = UDim2.new(1,0,0.5,0)
lSub.Position = UDim2.new(0,0,0.5,0)
lSub.BackgroundTransparency = 1
lSub.Text = "Press  B  to open"
lSub.TextColor3 = Color3.fromRGB(100,100,100)
lSub.TextSize = 11
lSub.Font = Enum.Font.Gotham
lSub.Parent = loadFrame

loadFrame.Position = UDim2.new(0.5,-130,0,-80)
Tween(loadFrame, {Position = UDim2.new(0.5,-130,0,20)}, 0.4, Enum.EasingStyle.Back)
task.delay(3, function()
    Tween(loadFrame, {Position = UDim2.new(0.5,-130,0,-80)}, 0.3)
    task.delay(0.35, function() loadSg:Destroy() end)
end)

print("✦ XENO MENU loaded — press B to open")

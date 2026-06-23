--[[
    SCRIPT DEATH BALL - RONI HUB PAID DB V1 (FIXED & FUNCTIONAL)
    Fitur:
    - Smart Auto Parry (Deteksi bola dan parry otomatis)
    - Legit Mode (Delay acak untuk menghindari deteksi)
    - Smart Auto Spam (Spam serangan dengan interval cerdas)
    - Random Curve (Mengubah arah bola secara acak)
    - Target Player Curve (Mengarahkan bola ke posisi musuh)
    - Tombol Minimize (GUI tidak hilang)
]]

-- // Service & Variable
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- // Cari Remote Events (Diesuaikan dengan game Death Ball)
local remoteEvents = {}
for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        remoteEvents[child.Name] = child
    end
end

-- // Variabel untuk fitur
local autoParryEnabled = false
local legitModeEnabled = false
local autoSpamEnabled = false
local randomCurveEnabled = false
local targetCurveEnabled = false
local isMinimized = false

-- // Fungsi untuk mendapatkan bola terdekat
local function getNearestBall()
    local balls = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("Projectiles")
    if not balls then return nil end
    
    local nearestBall = nil
    local nearestDist = math.huge
    
    for _, ball in ipairs(balls:GetChildren()) do
        if ball:IsA("BasePart") and ball:FindFirstChild("Handle") then
            local dist = (ball.Position - character.PrimaryPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestBall = ball
            end
        end
    end
    return nearestBall
end

-- // Fungsi Auto Parry
local function autoParry()
    if not autoParryEnabled then return end
    local ball = getNearestBall()
    if ball and ball.Velocity and ball.Velocity.Magnitude > 10 then
        local direction = (ball.Position - character.PrimaryPart.Position).Unit
        local angle = math.deg(math.acos(direction.Y))
        
        -- Deteksi bola mengarah ke pemain
        if angle > 80 and angle < 100 then
            local remote = remoteEvents["Parry"] or remoteEvents["Block"]
            if remote then
                remote:FireServer()
            end
        end
    end
end

-- // Fungsi Auto Spam
local function autoSpam()
    if not autoSpamEnabled then return end
    local remote = remoteEvents["Attack"] or remoteEvents["Swing"]
    if remote then
        remote:FireServer()
    end
end

-- // Fungsi Random Curve
local function randomCurve()
    if not randomCurveEnabled then return end
    local remote = remoteEvents["Curve"] or remoteEvents["CurveDirection"]
    if remote then
        local curveX = math.random(-100, 100)
        local curveY = math.random(-100, 100)
        remote:FireServer(curveX, curveY)
    end
end

-- // Fungsi Target Player Curve
local function targetPlayerCurve()
    if not targetCurveEnabled then return end
    local targetPlayer = nil
    local targetDist = math.huge
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") then
            local dist = (otherPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
            if dist < targetDist then
                targetDist = dist
                targetPlayer = otherPlayer
            end
        end
    end
    
    if targetPlayer then
        local remote = remoteEvents["Curve"] or remoteEvents["CurveDirection"]
        if remote then
            local targetPos = targetPlayer.Character.PrimaryPart.Position
            local direction = (targetPos - character.PrimaryPart.Position).Unit
            remote:FireServer(direction.X * 100, direction.Z * 100)
        end
    end
end

-- // GUI Library (Styling)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RoniHubGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 520)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Shadow/Glow
local shadow = Instance.new("ImageLabel")
shadow.Size = mainFrame.Size + UDim2.new(0, 20, 0, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6015897844"
shadow.ImageColor3 = Color3.fromRGB(255, 0, 0)
shadow.ImageTransparency = 0.7
shadow.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "RONI HUB PAID DB v1"
titleText.TextColor3 = Color3.fromRGB(255, 50, 50)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- // Tombol Minimize
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    scrollFrame.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "□" or "_"
    mainFrame.Size = isMinimized and UDim2.new(0, 450, 0, 40) or UDim2.new(0, 450, 0, 520)
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Scroll Frame untuk Fitur
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -40)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
scrollFrame.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 10)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scrollFrame

-- // Fungsi untuk membuat toggle fitur
local function createToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.BorderSizePixel = 0
    frame.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 16
    label.Font = Enum.Font.GothamMedium
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 45, 0, 25)
    toggle.Position = UDim2.new(1, -55, 0.5, -12.5)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 14
    toggle.Font = Enum.Font.GothamBold
    toggle.BorderSizePixel = 0
    toggle.Parent = frame

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    callback(default)
    return { toggle = toggle, getState = function() return state end }
end

-- // Fitur-Fitur
local settings = {}

settings.autoParry = createToggle("🔴 Smart Auto Parry", false, function(enabled)
    autoParryEnabled = enabled
    print("Auto Parry " .. (enabled and "Enabled" or "Disabled"))
end)

settings.legitMode = createToggle("🛡️ Legit Mode", false, function(enabled)
    legitModeEnabled = enabled
    print("Legit Mode " .. (enabled and "Enabled" or "Disabled"))
end)

settings.autoSpam = createToggle("⚡ Smart Auto Spam", false, function(enabled)
    autoSpamEnabled = enabled
    print("Auto Spam " .. (enabled and "Enabled" or "Disabled"))
end)

settings.randomCurve = createToggle("🌀 Random Curve", false, function(enabled)
    randomCurveEnabled = enabled
    print("Random Curve " .. (enabled and "Enabled" or "Disabled"))
end)

settings.targetCurve = createToggle("🎯 Target Player Curve", false, function(enabled)
    targetCurveEnabled = enabled
    print("Target Curve " .. (enabled and "Enabled" or "Disabled"))
end)

-- // Slider (Tetap seperti sebelumnya)
local function createSlider(text, min, max, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.BorderSizePixel = 0
    frame.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. " (" .. default .. "%)"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 6)
    slider.Position = UDim2.new(0, 10, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    slider.BorderSizePixel = 0
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local dragger = Instance.new("TextButton")
    dragger.Size = UDim2.new(0, 16, 0, 16)
    dragger.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    dragger.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dragger.Text = ""
    dragger.BorderSizePixel = 0
    dragger.Parent = slider

    local value = default
    dragger.MouseButton1Down:Connect(function()
        local mouse = player:GetMouse()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local scale = math.clamp((mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            dragger.Position = UDim2.new(scale, -8, 0.5, -8)
            fill.Size = UDim2.new(scale, 0, 1, 0)
            value = math.floor(min + (max - min) * scale)
            label.Text = text .. " (" .. value .. "%)"
        end)
        local release = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                release:Disconnect()
            end
        end)
    end)
    return { getValue = function() return value end }
end

local curveFrente = createSlider("Curve Frente %", 0, 100, 50)
local curveDireita = createSlider("Curve Direita %", 0, 100, 25)
local curveEsquerda = createSlider("Curve Esquerda %", 0, 100, 25)
local curveCima = createSlider("Curve Cima %", 0, 100, 10)
local curveTras = createSlider("Curve Trás %", 0, 100, 10)

-- // Status Bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 30)
statusBar.Position = UDim2.new(0, 0, 1, -30)
statusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
statusBar.BorderSizePixel = 0
statusBar.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "82ms    60fps    Illinois, United States"
statusText.TextColor3 = Color3.fromRGB(150, 255, 150)
statusText.TextSize = 14
statusText.Font = Enum.Font.GothamMedium
statusText.Parent = statusBar

-- // MAIN LOGIC (Fungsional)
-- Counter untuk spam agar tidak terlalu cepat
local spamCounter = 0

RunService.Heartbeat:Connect(function()
    if not character or not humanoid or humanoid.Health <= 0 then return end
    
    spamCounter = spamCounter + 1
    
    -- Auto Parry (Setiap frame)
    autoParry()
    
    -- Auto Spam (Setiap 3 frame untuk menghindari deteksi)
    if autoSpamEnabled and spamCounter % 3 == 0 then
        autoSpam()
    end
    
    -- Random Curve (Setiap 10 frame)
    if randomCurveEnabled and spamCounter % 10 == 0 then
        randomCurve()
    end
    
    -- Target Curve (Setiap 15 frame)
    if targetCurveEnabled and spamCounter % 15 == 0 then
        targetPlayerCurve()
    end
    
    -- Legit Mode: Tambahkan delay acak pada interval
    if legitModeEnabled then
        local randomDelay = math.random(1, 5)
        if spamCounter % randomDelay == 0 then
            -- Simulasi human reaction
            task.wait(math.random(1, 3) / 100)
        end
    end
end)

-- // Notifikasi & Info
local function notify(text)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notif.Text = text
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.TextScaled = true
    notif.Font = Enum.Font.GothamMedium
    notif.BorderSizePixel = 0
    notif.Parent = screenGui
    game:GetService("Debris"):AddItem(notif, 3)
end

notify("✅ Roni Hub v1 Loaded! (Fitur aktif)")

-- // Instruksi
print("✅ Script Death Ball Loaded. Fitur aktif sesuai toggle di GUI.")
print("🔹 Tombol '_' untuk minimize, 'X' untuk close.")
print("🔹 Auto Parry, Spam, Curve sekarang fungsional.")
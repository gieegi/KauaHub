--[[
    KauaHub OP - Murder Mystery (Roblox)
    - ESP jogadores (nome, arma, papel)
    - ESP arma/faca dropada
    - Auto-collect arma dropada
    - Floater (controle pela câmera)
    - Speed hack
    - Fly
    - Auto-win (murderer/sheriff)
    - Autofarm de coins
    - Teleport para player
    - Grab Gun (pega arma do chão instantaneamente)
    - GUI preto moderno, botão fechar/abrir (mobile/PC)
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

---------------------
-- ESP JOGADORES   --
---------------------
local function clearESPPlayers()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("ESP_MM") then
            plr.Character.Head.ESP_MM:Destroy()
        end
    end
end

local function getRoleGuess(plr)
    if plr.Backpack:FindFirstChild("Gun") or (plr.Character and plr.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    if plr.Backpack:FindFirstChild("Knife") or (plr.Character and plr.Character:FindFirstChild("Knife")) then
        return "Murderer"
    end
    return "Innocent"
end

local function drawESPPlayers()
    clearESPPlayers()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local esp = Instance.new("BillboardGui", plr.Character.Head)
            esp.Name = "ESP_MM"
            esp.Size = UDim2.new(0,150,0,38)
            esp.AlwaysOnTop = true
            esp.Adornee = plr.Character.Head

            local label = Instance.new("TextLabel", esp)
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true
            label.TextStrokeTransparency = 0.13

            local role = getRoleGuess(plr)
            if role == "Murderer" then
                label.TextColor3 = Color3.fromRGB(255,40,40)
            elseif role == "Sheriff" then
                label.TextColor3 = Color3.fromRGB(0,245,255)
            else
                label.TextColor3 = Color3.fromRGB(255,255,255)
            end

            label.Text = plr.DisplayName.." ["..role.."]"
        end
    end
end

---------------------
-- ESP ITENS DROP   --
---------------------
local function clearESPItems()
    for _,gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "ESP_ITEM_MM" then gui:Destroy() end
    end
end

local function drawESPItems()
    clearESPItems()
    for _,obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "GunDrop" or obj.Name == "KnifeDrop" then
            local gui = Instance.new("BillboardGui", CoreGui)
            gui.Name = "ESP_ITEM_MM"
            gui.Size = UDim2.new(0,100,0,32)
            gui.AlwaysOnTop = true
            gui.Adornee = obj:FindFirstChildWhichIsA("BasePart") or obj

            local label = Instance.new("TextLabel", gui)
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBlack
            label.TextScaled = true
            if obj.Name == "GunDrop" then
                label.Text = "ARMA NO CHÃO"
                label.TextColor3 = Color3.fromRGB(0,255,180)
            else
                label.Text = "FACA NO CHÃO"
                label.TextColor3 = Color3.fromRGB(255,80,80)
            end
        end
    end
end

---------------------
-- AUTO-COLLECT ARMA & GRAB GUN
---------------------
local function autoCollectGun()
    for _,obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "GunDrop" then
            local part = obj:FindFirstChildWhichIsA("BasePart") or obj
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,1,0)
            end
        end
    end
end

local function grabGun()
    for _,obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "GunDrop" then
            local part = obj:FindFirstChildWhichIsA("BasePart") or obj
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,1,0)
            end
            break
        end
    end
end

---------------------
-- SPEED / FLY
---------------------
local speedOn = false
local flyOn = false
local speedVal = 30
local flyConn

local function setSpeed(enable)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = enable and speedVal or 16
    end
    speedOn = enable
end

local function setFly(enable)
    flyOn = enable
    if not enable and flyConn then flyConn:Disconnect() end
    if enable then
        flyConn = RS.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Velocity = workspace.CurrentCamera.CFrame.LookVector * 85
            end
        end)
    end
end

---------------------
-- FLOATER DIRECIONAL
---------------------
local floaterOn = false
local floaterConn
local floaterSpeed = 130

local function startFloater()
    if floaterConn then floaterConn:Disconnect() end
    floaterConn = nil
    if floaterOn then
        floaterConn = RS.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Velocity = workspace.CurrentCamera.CFrame.LookVector * floaterSpeed
            end
        end)
    end
end

---------------------
-- AUTO-WIN
---------------------
local function autoKillAll()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Backpack:FindFirstChild("Knife") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
                wait(0.15)
            end
        end
    end
end

local function autoShootMurderer()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and getRoleGuess(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Backpack:FindFirstChild("Gun") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
            end
        end
    end
end

---------------------
-- AUTOFARM DE COINS
---------------------
local autofarmOn = false
local autofarmConn

local function startAutofarm()
    if autofarmConn then autofarmConn:Disconnect() end
    autofarmConn = nil
    if autofarmOn then
        autofarmConn = RS.RenderStepped:Connect(function()
            for _,coin in pairs(Workspace:GetChildren()) do
                if coin.Name:lower():find("coin") and coin:IsA("BasePart") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame + Vector3.new(0,1,0)
                        break -- Pega uma moeda por frame para não bugar
                    end
                end
            end
        end)
    end
end

---------------------
-- TELEPORT PARA PLAYER
---------------------
local function teleportToPlayerMenu()
    local menu = Instance.new("ScreenGui", CoreGui)
    menu.Name = "TeleportMenu_KauaHub"
    local frame = Instance.new("Frame", menu)
    frame.Size = UDim2.new(0,180,0,40 + (#Players:GetPlayers()-1)*38)
    frame.Position = UDim2.new(0.5,-90,0.5,-frame.Size.Y.Offset/2)
    frame.BackgroundColor3 = Color3.fromRGB(18,18,28)
    frame.BorderSizePixel = 0

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,34)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = "Teleport Para:"
    title.TextColor3 = Color3.fromRGB(0,255,155)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    local y = 1
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, -20, 0, 28)
            btn.Position = UDim2.new(0,10,0,8 + y*30)
            btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
            btn.TextColor3 = Color3.fromRGB(0,200,255)
            btn.Font = Enum.Font.GothamBold
            btn.Text = plr.DisplayName
            btn.TextSize = 16
            btn.BorderSizePixel = 0
            btn.MouseButton1Click:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
                end
                menu:Destroy()
            end)
            y = y + 1
        end
    end

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0,28,0,28)
    closeBtn.Position = UDim2.new(1,-32,0,6)
    closeBtn.Text = "✕"
    closeBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    closeBtn.BorderSizePixel = 0
    closeBtn.TextColor3 = Color3.fromRGB(255,40,110)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.MouseButton1Click:Connect(function()
        menu:Destroy()
    end)
end

---------------------
-- INTERFACE (GUI) --
---------------------
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KauaHub_MurderMystery"
local main = Instance.new("Frame", gui)
main.AnchorPoint = Vector2.new(1,1)
main.Position = UDim2.new(1,-30,1,-330)
main.Size = UDim2.new(0, 270, 0, 420)
main.BackgroundColor3 = Color3.fromRGB(15,15,18)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = true

local border = Instance.new("UIStroke", main)
border.Thickness = 2
border.Color = Color3.fromRGB(0,255,120)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,38)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "KauaHub OP"
title.TextColor3 = Color3.fromRGB(0,255,120)
title.Font = Enum.Font.GothamBlack
title.TextSize = 26

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-34,0,4)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
closeBtn.BorderSizePixel = 0
closeBtn.TextColor3 = Color3.fromRGB(255,40,110)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

local y = 0
local function makeBtn(txt, clr, func)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.93,0,0,34)
    btn.Position = UDim2.new(0.035,0,0,46 + (y*38))
    btn.BackgroundColor3 = Color3.fromRGB(26,26,36)
    btn.TextColor3 = clr
    btn.Font = Enum.Font.GothamBold
    btn.Text = txt
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(func)
    y = y + 1
end

makeBtn("ESP Jogadores", Color3.fromRGB(0,245,255), function()
    drawESPPlayers()
end)
makeBtn("ESP Arma/Faca Dropada", Color3.fromRGB(0,255,120), function()
    drawESPItems()
end)
makeBtn("Auto Pegar Arma", Color3.fromRGB(0,255,180), function()
    autoCollectGun()
end)
makeBtn("GRAB GUN (Instantâneo)", Color3.fromRGB(0,255,255), function()
    grabGun()
end)
makeBtn("Velocidade OP", Color3.fromRGB(255,255,120), function()
    speedOn = not speedOn
    setSpeed(speedOn)
end)
makeBtn("Fly (segura)", Color3.fromRGB(180,255,180), function()
    setFly(not flyOn)
end)
makeBtn("Floater (Câmera)", Color3.fromRGB(0,200,255), function()
    floaterOn = not floaterOn
    startFloater()
end)
makeBtn("Auto Win (Murderer)", Color3.fromRGB(255,80,120), function()
    autoKillAll()
end)
makeBtn("Auto Shoot Murderer", Color3.fromRGB(255,120,120), function()
    autoShootMurderer()
end)
makeBtn("AUTOFARM COINS", Color3.fromRGB(255,210,60), function()
    autofarmOn = not autofarmOn
    startAutofarm()
end)
makeBtn("TELEPORT PARA PLAYER", Color3.fromRGB(0,245,255), function()
    teleportToPlayerMenu()
end)
makeBtn("Fechar", Color3.fromRGB(255,40,110), function()
    main.Visible = false
end)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,44,0,44)
openBtn.Position = UDim2.new(1,-54,1,-54)
openBtn.Text = "☰"
openBtn.BackgroundColor3 = Color3.fromRGB(0,255,120)
openBtn.BorderSizePixel = 0
openBtn.TextColor3 = Color3.fromRGB(10,10,18)
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 28
openBtn.Visible = false
openBtn.MouseButton1Click:Connect(function()
    main.Visible = true
end)
main:GetPropertyChangedSignal("Visible"):Connect(function()
    openBtn.Visible = not main.Visible
    if not main.Visible then
        floaterOn = false
        if floaterConn then floaterConn:Disconnect() floaterConn = nil end
        autofarmOn = false
        if autofarmConn then autofarmConn:Disconnect() autofarmConn = nil end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    floaterOn = false
    if floaterConn then floaterConn:Disconnect() floaterConn = nil end
    autofarmOn = false
    if autofarmConn then autofarmConn:Disconnect() autofarmConn = nil end
end)

spawn(function()
    while true do
        if main.Visible then
            pcall(drawESPPlayers)
            pcall(drawESPItems)
        end
        wait(2)
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end)

print("[KauaHub OP] Loaded para Murder Mystery! Aproveite.")

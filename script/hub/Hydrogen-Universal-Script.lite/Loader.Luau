-- [[ HYDROGEN LITE (SPECTATE SCRIPT) - OCEAN MARINE THEME WITH KEY & ADVANCED FEATURES ]] --
local UNIQUE_ID = "HyDRoGrEnLITEUIANtIbUGCodE_404_8410410511532731153270114114111328011410118101106111110326711110101328710410111032821171101101013285132721089711510132681111078311698101109321001011081101161013273116"

if getgenv()[UNIQUE_ID .. "_Cleanup"] then
    pcall(getgenv()[UNIQUE_ID .. "_Cleanup"])
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local setclipboard = setclipboard or toclipboard or function() end
local request = (syn and syn.request) or (http and http.request) or http_request or (Fluxus and Fluxus.request) or request
local readfile = readfile or function() return nil end
local writefile = writefile or function() end
local isfile = isfile or function() return false end

local KEY_FILE_NAME = "HydrogenLite_SavedKey_" .. LocalPlayer.UserId .. ".txt"

local PUBLIC_KEY = "HYdROgEN_PublicKey_2008091909192008051105251618152290405022582504181507051420150501030819031809162003180501201819152521041514140520150221251514"
local DEV_WEBHOOK_URL = "https://discord.com/api/webhooks/1545989966356676728/P7GU8tR2p0Rf7lBZNpYLI1o9APCba-pFFQuw4avsqWtFG79iQwEZXkVGjvCoosRD9EcU"

local spectateEnabled = false
local currentSpectateIndex = 1
local spectateTargets = {}
local targetPlayer = nil

local followEnabled = false
local orbitEnabled = false
local espPlayerEnabled = false
local espNpcEnabled = false
local immortalEnabled = false
local flingEnabled = false
local headsitEnabled = false
local antiFlingEnabled = false

local boomboxEnabled = false
local boomboxSound = nil

local userNoticeWebhook = ""
local webhookNoticeEnabled = false

local orbitHeight = 0
local orbitDistance = 5
local orbitSpeed = 50
local orbitAngle = 0

local espStorage = {}
local npcEspStorage = {}
local renderConnection = nil
local heartbeatConnection = nil
local antiFlingConnection = nil

local OCEAN_DARK = Color3.fromRGB(10, 22, 38)
local OCEAN_MID = Color3.fromRGB(18, 40, 68)
local OCEAN_LIGHT = Color3.fromRGB(28, 65, 105)
local OCEAN_CYAN = Color3.fromRGB(0, 225, 255)
local OCEAN_BLUE = Color3.fromRGB(0, 140, 255)
local WHITE = Color3.fromRGB(255, 255, 255)

local function notify(title, desc)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = desc, Duration = 5 })
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HydrogenLiteSpectateOcean"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

getgenv()[UNIQUE_ID] = ScreenGui

local function removePlayerESP(plr)
    if espStorage[plr] then
        pcall(function() if espStorage[plr].Highlight then espStorage[plr].Highlight:Destroy() end end)
        pcall(function() if espStorage[plr].Billboard then espStorage[plr].Billboard:Destroy() end end)
        espStorage[plr] = nil
    end
end

local function clearAllESP()
    for plr, _ in pairs(espStorage) do
        removePlayerESP(plr)
    end
    espStorage = {}
end

local function removeNPCESP(model)
    if npcEspStorage[model] then
        pcall(function() if npcEspStorage[model].Highlight then npcEspStorage[model].Highlight:Destroy() end end)
        pcall(function() if npcEspStorage[model].Billboard then npcEspStorage[model].Billboard:Destroy() end end)
        npcEspStorage[model] = nil
    end
end

local function clearAllNPCEsp()
    for model, _ in pairs(npcEspStorage) do
        removeNPCESP(model)
    end
    npcEspStorage = {}
end

getgenv()[UNIQUE_ID .. "_Cleanup"] = function()
    clearAllESP()
    clearAllNPCEsp()
    if boomboxSound then pcall(function() boomboxSound:Destroy() end) end
    if renderConnection then renderConnection:Disconnect() end
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    if antiFlingConnection then antiFlingConnection:Disconnect() end
    pcall(function() ScreenGui:Destroy() end)
end

local function saveKey(key)
    pcall(function()
        writefile(KEY_FILE_NAME, HttpService:JSONEncode({Key = key, Expire = os.time() + 86400}))
    end)
end

local function checkBypass()
    if LocalPlayer.Name == "cairebagby_2927" then return "special" end
    if LocalPlayer.Name == "Larpking6769tuff" or LocalPlayer.Name == "LarpKing6769tuff" then return "owner" end
    return false
end

local function isKeyValid()
    if checkBypass() then return true end
    if isfile and isfile(KEY_FILE_NAME) then
        local success, result = pcall(function()
            local data = HttpService:JSONDecode(readfile(KEY_FILE_NAME))
            if data and data.Expire and os.time() < data.Expire then
                if data.Key == PUBLIC_KEY then
                    return true
                end
            end
        end)
        if success and result then return true end
    end
    return false
end

local function sendNoticeWebhook(title, description)
    if not webhookNoticeEnabled or userNoticeWebhook == "" then return end
    local payload = {
        username = "Hydrogen Lite Notice | Webhook",
        embeds = {{ title = title, description = description, color = 3447003, timestamp = DateTime.now():ToIsoDate() }}
    }
    if request then
        pcall(function() request({ Url = userNoticeWebhook, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(payload) }) end)
    end
end

local function copyToClipboard(text)
    setclipboard(text)
    notify("Hydrogen Lite", "Copied to Clipboard!")
end

local function instantTeleport(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        LocalPlayer.Character:PivotTo(cframe)
    end
end

local function makeSmoothDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    dragHandle.Active = true
    guiObject.Active = true
    
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(guiObject, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end
    end)
end

local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Name = "KeySystemFrame"
KeyFrame.Size = UDim2.new(0, 360, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
KeyFrame.BackgroundColor3 = OCEAN_DARK
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.ClipsDescendants = true
KeyFrame.ZIndex = 50
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 14)

local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Color = OCEAN_CYAN
KeyStroke.Thickness = 2

local GreetingLabel = Instance.new("TextLabel", KeyFrame)
GreetingLabel.Size = UDim2.new(1, -20, 0, 35)
GreetingLabel.Position = UDim2.new(0, 10, 0, 14)
GreetingLabel.Text = "Hello " .. LocalPlayer.DisplayName .. ", please enter your key"
GreetingLabel.TextColor3 = OCEAN_CYAN
GreetingLabel.Font = Enum.Font.GothamBold
GreetingLabel.TextSize = 13
GreetingLabel.BackgroundTransparency = 1
GreetingLabel.ZIndex = 51

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0.88, 0, 0, 36)
KeyInput.Position = UDim2.new(0.06, 0, 0, 58)
KeyInput.PlaceholderText = "Paste key here..."
KeyInput.Text = ""
KeyInput.TextColor3 = WHITE
KeyInput.BackgroundColor3 = OCEAN_MID
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 12
KeyInput.ZIndex = 51
KeyInput.ClearTextOnFocus = false
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

local SubmitKeyBtn = Instance.new("TextButton", KeyFrame)
SubmitKeyBtn.Size = UDim2.new(0.88, 0, 0, 38)
SubmitKeyBtn.Position = UDim2.new(0.06, 0, 0, 104)
SubmitKeyBtn.BackgroundColor3 = OCEAN_CYAN
SubmitKeyBtn.Text = "SUBMIT KEY"
SubmitKeyBtn.TextColor3 = OCEAN_DARK
SubmitKeyBtn.Font = Enum.Font.GothamBold
SubmitKeyBtn.TextSize = 14
SubmitKeyBtn.ZIndex = 51
SubmitKeyBtn.Active = true
Instance.new("UICorner", SubmitKeyBtn).CornerRadius = UDim.new(0, 8)

local DiscordText = Instance.new("TextLabel", KeyFrame)
DiscordText.Size = UDim2.new(1, -20, 0, 20)
DiscordText.Position = UDim2.new(0, 10, 0, 152)
DiscordText.Text = "Join our discord for get free public key!"
DiscordText.TextColor3 = Color3.fromRGB(160, 190, 220)
DiscordText.Font = Enum.Font.GothamMedium
DiscordText.TextSize = 11
DiscordText.BackgroundTransparency = 1
DiscordText.ZIndex = 51

makeSmoothDraggable(KeyFrame)

local function applyOceanButtonStyle(button, isSpecial)
    button.Active = true
    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 6)

    local btnStroke = Instance.new("UIStroke", button)
    btnStroke.Color = isSpecial and OCEAN_CYAN or OCEAN_BLUE
    btnStroke.Thickness = 1
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = OCEAN_LIGHT}):Play() end)
    button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = isSpecial and OCEAN_MID or Color3.fromRGB(15, 32, 55)}):Play() end)
end

local function initializeMainScript()
    local ToggleIcon = Instance.new("TextButton", ScreenGui)
    ToggleIcon.Name = "ToggleIcon"
    ToggleIcon.Size = UDim2.new(0, 44, 0, 44)
    ToggleIcon.Position = UDim2.new(0.08, 0, 0.25, 0)
    ToggleIcon.BackgroundColor3 = OCEAN_MID
    ToggleIcon.Text = "💧"
    ToggleIcon.TextSize = 22
    ToggleIcon.Active = true
    ToggleIcon.ZIndex = 10
    Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(1, 0)
    
    local IconStroke = Instance.new("UIStroke", ToggleIcon)
    IconStroke.Color = OCEAN_CYAN
    IconStroke.Thickness = 1.5

    makeSmoothDraggable(ToggleIcon)

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 310, 0, 290)
    MainFrame.Position = UDim2.new(0.5, -155, 0.28, 0)
    MainFrame.BackgroundColor3 = OCEAN_DARK
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.ZIndex = 5

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = OCEAN_CYAN
    MainStroke.Thickness = 1.5

    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.BackgroundColor3 = OCEAN_MID
    TitleBar.ZIndex = 6
    TitleBar.Active = true
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

    local TitleText = Instance.new("TextLabel", TitleBar)
    TitleText.Size = UDim2.new(1, -15, 1, 0)
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.Text = "Hydrogen Lite"
    TitleText.TextColor3 = OCEAN_CYAN
    TitleText.TextSize = 13
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.BackgroundTransparency = 1
    TitleText.ZIndex = 7

    makeSmoothDraggable(MainFrame, TitleBar)

    local EnableBtn = Instance.new("TextButton", MainFrame)
    EnableBtn.Size = UDim2.new(0.92, 0, 0, 32)
    EnableBtn.Position = UDim2.new(0.04, 0, 0, 44)
    EnableBtn.BackgroundColor3 = OCEAN_MID
    EnableBtn.Text = "Camera Enable: FALSE"
    EnableBtn.TextColor3 = Color3.fromRGB(255, 80, 90)
    EnableBtn.Font = Enum.Font.GothamBold
    EnableBtn.TextSize = 12
    EnableBtn.ZIndex = 7
    applyOceanButtonStyle(EnableBtn, true)

    local ScrollList = Instance.new("ScrollingFrame", MainFrame)
    ScrollList.Size = UDim2.new(0.94, 0, 0, 198)
    ScrollList.Position = UDim2.new(0.03, 0, 0, 82)
    ScrollList.BackgroundTransparency = 1
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 3
    ScrollList.ScrollBarImageColor3 = OCEAN_CYAN
    ScrollList.ZIndex = 6
    ScrollList.Active = true

    local ListLayout = Instance.new("UIListLayout", ScrollList)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 6)

    local ListPadding = Instance.new("UIPadding", ScrollList)
    ListPadding.PaddingTop = UDim.new(0, 2)
    ListPadding.PaddingBottom = UDim.new(0, 2)
    ListPadding.PaddingLeft = UDim.new(0, 2)
    ListPadding.PaddingRight = UDim.new(0, 2)

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
    end)

    local SpectateUI = Instance.new("Frame", ScreenGui)
    SpectateUI.Size = UDim2.new(0, 280, 0, 75)
    SpectateUI.Position = UDim2.new(0.5, -140, 0.85, -25.4)
    SpectateUI.BackgroundColor3 = OCEAN_DARK
    SpectateUI.Visible = false
    SpectateUI.ZIndex = 15
    SpectateUI.Active = true

    Instance.new("UICorner", SpectateUI).CornerRadius = UDim.new(0, 10)
    local SpecStroke = Instance.new("UIStroke", SpectateUI)
    SpecStroke.Color = OCEAN_CYAN
    SpecStroke.Thickness = 1.5

    local HideSpectateUIBtn = Instance.new("TextButton", ScreenGui)
    HideSpectateUIBtn.Name = "HideSpectateUIBtn"
    HideSpectateUIBtn.Size = UDim2.new(0, 38, 0, 38)
    HideSpectateUIBtn.Position = UDim2.new(0.5, 145, 0.78, 0)
    HideSpectateUIBtn.BackgroundColor3 = OCEAN_MID
    HideSpectateUIBtn.Text = "👁️"
    HideSpectateUIBtn.TextSize = 18
    HideSpectateUIBtn.Visible = false
    HideSpectateUIBtn.ZIndex = 25
    HideSpectateUIBtn.Active = true
    Instance.new("UICorner", HideSpectateUIBtn).CornerRadius = UDim.new(1, 0)
    local HideStroke = Instance.new("UIStroke", HideSpectateUIBtn)
    HideStroke.Color = OCEAN_CYAN
    HideStroke.Thickness = 1.5

    local DispNameLab = Instance.new("TextLabel", SpectateUI)
    DispNameLab.Size = UDim2.new(1, -70, 0, 18)
    DispNameLab.Position = UDim2.new(0, 35, 0, 6)
    DispNameLab.Text = "Searching..."
    DispNameLab.TextColor3 = WHITE
    DispNameLab.Font = Enum.Font.GothamBold
    DispNameLab.TextSize = 13
    DispNameLab.TextXAlignment = Enum.TextXAlignment.Left
    DispNameLab.BackgroundTransparency = 1
    DispNameLab.ZIndex = 16

    local UserLab = Instance.new("TextLabel", SpectateUI)
    UserLab.Size = UDim2.new(1, -70, 0, 15)
    UserLab.Position = UDim2.new(0, 35, 0, 24)
    UserLab.Text = "@none"
    UserLab.TextColor3 = Color3.fromRGB(160, 190, 220)
    UserLab.Font = Enum.Font.Gotham
    UserLab.TextSize = 11
    UserLab.TextXAlignment = Enum.TextXAlignment.Left
    UserLab.BackgroundTransparency = 1
    UserLab.ZIndex = 16

    local CoordLab = Instance.new("TextLabel", SpectateUI)
    CoordLab.Size = UDim2.new(1, -70, 0, 22)
    CoordLab.Position = UDim2.new(0, 35, 0, 44)
    CoordLab.Text = "X: 0, Y: 0, Z: 0"
    CoordLab.TextColor3 = OCEAN_CYAN
    CoordLab.Font = Enum.Font.Code
    CoordLab.TextSize = 10
    CoordLab.TextXAlignment = Enum.TextXAlignment.Left
    CoordLab.BackgroundTransparency = 1
    CoordLab.ZIndex = 16

    local PrevBtn = Instance.new("TextButton", SpectateUI)
    PrevBtn.Size = UDim2.new(0, 25, 1, -10)
    PrevBtn.Position = UDim2.new(0, 5, 0, 5)
    PrevBtn.Text = "<"
    PrevBtn.TextColor3 = OCEAN_CYAN
    PrevBtn.Font = Enum.Font.GothamBold
    PrevBtn.TextSize = 18
    PrevBtn.BackgroundColor3 = OCEAN_MID
    PrevBtn.ZIndex = 17
    applyOceanButtonStyle(PrevBtn)

    local NextBtn = Instance.new("TextButton", SpectateUI)
    NextBtn.Size = UDim2.new(0, 25, 1, -10)
    NextBtn.Position = UDim2.new(1, -30, 0, 5)
    NextBtn.Text = ">"
    NextBtn.TextColor3 = OCEAN_CYAN
    NextBtn.Font = Enum.Font.GothamBold
    NextBtn.TextSize = 18
    NextBtn.BackgroundColor3 = OCEAN_MID
    NextBtn.ZIndex = 17
    applyOceanButtonStyle(NextBtn)

    local isSpectateUIHidden = false
    HideSpectateUIBtn.MouseButton1Click:Connect(function()
        isSpectateUIHidden = not isSpectateUIHidden
        SpectateUI.Visible = not isSpectateUIHidden
        HideSpectateUIBtn.Text = "👁️"
    end)

    local isGuiOpen = true
    ToggleIcon.MouseButton1Click:Connect(function()
        isGuiOpen = not isGuiOpen
        if isGuiOpen then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 310, 0, 290)}):Play()
        else
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            tween:Play()
            tween.Completed:Connect(function() if not isGuiOpen then MainFrame.Visible = false end end)
        end
    end)

    local function animateClick(button)
        local origSize = button:GetAttribute("OriginalSize")
        if not origSize then
            origSize = button.Size
            button:SetAttribute("OriginalSize", origSize)
        end
        TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = origSize - UDim2.new(0, 2, 0, 2)}):Play()
        task.wait(0.08)
        TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = origSize}):Play()
    end

    local function getValidPlayers()
        local list = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("Humanoid") and pl.Character:FindFirstChild("HumanoidRootPart") then
                if pl.Character.Humanoid.Health > 0 then table.insert(list, pl) end
            end
        end
        return list
    end

    local function spectateIndex(index)
        spectateTargets = getValidPlayers()
        if #spectateTargets == 0 then
            targetPlayer = nil
            DispNameLab.Text = "No Target"
            UserLab.Text = "@none"
            CoordLab.Text = "X: 0, Y: 0, Z: 0"
            return
        end
        if index < 1 then index = #spectateTargets elseif index > #spectateTargets then index = 1 end
        currentSpectateIndex = index
        targetPlayer = spectateTargets[currentSpectateIndex]

        if targetPlayer then
            DispNameLab.Text = targetPlayer.DisplayName
            UserLab.Text = "@" .. targetPlayer.Name

            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = targetPlayer.Character.Humanoid
                LocalPlayer.DevComputerCameraMode = Enum.DevComputerCameraMode.Classic
                LocalPlayer.DevTouchCameraMode = Enum.DevTouchCameraMode.Classic
            end
        end
    end

    local function ensureTarget()
        if not spectateEnabled then
            notify("Hydrogen Lite", "You must enable Camera Spectate first!")
            return false
        end
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            spectateIndex(currentSpectateIndex)
        end
        if not targetPlayer then
            notify("Hydrogen Lite", "No valid target player found!")
            return false
        end
        return true
    end

    local FlingBtn, FollowBtn, OrbitBtn, HeadsitBtn, AntiFlingBtn

    EnableBtn.MouseButton1Click:Connect(function()
        animateClick(EnableBtn)
        spectateEnabled = not spectateEnabled
        EnableBtn.Text = "Camera Enable: " .. (spectateEnabled and "TRUE" or "FALSE")
        EnableBtn.TextColor3 = spectateEnabled and OCEAN_CYAN or Color3.fromRGB(255, 80, 90)
        SpectateUI.Visible = spectateEnabled and not isSpectateUIHidden
        HideSpectateUIBtn.Visible = spectateEnabled

        if spectateEnabled then
            spectateIndex(1)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
            targetPlayer = nil
            isSpectateUIHidden = false
            HideSpectateUIBtn.Visible = false
            HideSpectateUIBtn.Text = "👁️"
            
            followEnabled = false
            orbitEnabled = false
            flingEnabled = false
            headsitEnabled = false

            if FollowBtn then
                FollowBtn.Text = "Follow Target: OFF"
                FollowBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
            end
            if OrbitBtn then
                OrbitBtn.Text = "Orbit Player: OFF"
                OrbitBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
            end
            if FlingBtn then
                FlingBtn.Text = "Fling Player: OFF"
                FlingBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
            end
            if HeadsitBtn then
                HeadsitBtn.Text = "Headsit: OFF"
                HeadsitBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
            end
            
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Sit = false end
                if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    LocalPlayer.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end)

    PrevBtn.MouseButton1Click:Connect(function() animateClick(PrevBtn); spectateIndex(currentSpectateIndex - 1) end)
    NextBtn.MouseButton1Click:Connect(function() animateClick(NextBtn); spectateIndex(currentSpectateIndex + 1) end)

    -- ======================================================== --
    -- 1. TOGGLE CẦN SPECTATE (LayoutOrder 1 - 3)
    -- ======================================================== --

    -- 1.1 Fling Player
    FlingBtn = Instance.new("TextButton", ScrollList)
    FlingBtn.Size = UDim2.new(1, -4, 0, 32)
    FlingBtn.LayoutOrder = 1
    FlingBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    FlingBtn.Text = "Fling Player: OFF"
    FlingBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    FlingBtn.Font = Enum.Font.Gotham
    FlingBtn.TextSize = 11
    FlingBtn.ZIndex = 7
    applyOceanButtonStyle(FlingBtn)

    FlingBtn.MouseButton1Click:Connect(function()
        animateClick(FlingBtn)
        if not flingEnabled then
            if not ensureTarget() then return end
            flingEnabled = true
            headsitEnabled = false
            if HeadsitBtn then HeadsitBtn.Text = "Headsit: OFF"; HeadsitBtn.TextColor3 = Color3.fromRGB(200, 220, 240) end
            FlingBtn.Text = "Fling Player: ON"
            FlingBtn.TextColor3 = OCEAN_CYAN
        else
            flingEnabled = false
            FlingBtn.Text = "Fling Player: OFF"
            FlingBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                LocalPlayer.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)

    -- 1.2 Follow Target
    FollowBtn = Instance.new("TextButton", ScrollList)
    FollowBtn.Size = UDim2.new(1, -4, 0, 32)
    FollowBtn.LayoutOrder = 2
    FollowBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    FollowBtn.Text = "Follow Target: OFF"
    FollowBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    FollowBtn.Font = Enum.Font.Gotham
    FollowBtn.TextSize = 11
    FollowBtn.ZIndex = 7
    applyOceanButtonStyle(FollowBtn)

    FollowBtn.MouseButton1Click:Connect(function()
        animateClick(FollowBtn)
        if not followEnabled then
            if not ensureTarget() then return end
            followEnabled = true
            headsitEnabled = false
            if HeadsitBtn then HeadsitBtn.Text = "Headsit: OFF"; HeadsitBtn.TextColor3 = Color3.fromRGB(200, 220, 240) end
            FollowBtn.Text = "Follow Target: ON"
            FollowBtn.TextColor3 = OCEAN_CYAN
        else
            followEnabled = false
            FollowBtn.Text = "Follow Target: OFF"
            FollowBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
        end
    end)

    -- 1.3 Headsit
    HeadsitBtn = Instance.new("TextButton", ScrollList)
    HeadsitBtn.Size = UDim2.new(1, -4, 0, 32)
    HeadsitBtn.LayoutOrder = 3
    HeadsitBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    HeadsitBtn.Text = "Headsit: OFF"
    HeadsitBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    HeadsitBtn.Font = Enum.Font.Gotham
    HeadsitBtn.TextSize = 11
    HeadsitBtn.ZIndex = 7
    applyOceanButtonStyle(HeadsitBtn)

    HeadsitBtn.MouseButton1Click:Connect(function()
        animateClick(HeadsitBtn)
        if not headsitEnabled then
            if not ensureTarget() then return end
            headsitEnabled = true
            followEnabled = false
            orbitEnabled = false
            flingEnabled = false
            if FollowBtn then FollowBtn.Text = "Follow Target: OFF"; FollowBtn.TextColor3 = Color3.fromRGB(200, 220, 240) end
            if OrbitBtn then OrbitBtn.Text = "Orbit Player: OFF"; OrbitBtn.TextColor3 = Color3.fromRGB(200, 220, 240) end
            if FlingBtn then FlingBtn.Text = "Fling Player: OFF"; FlingBtn.TextColor3 = Color3.fromRGB(200, 220, 240) end
            
            HeadsitBtn.Text = "Headsit: ON"
            HeadsitBtn.TextColor3 = OCEAN_CYAN
        else
            headsitEnabled = false
            HeadsitBtn.Text = "Headsit: OFF"
            HeadsitBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Sit = false end
            end
        end
    end)

    -- ======================================================== --
    -- 2. BUTTON CẦN SPECTATE (LayoutOrder 4 - 6)
    -- ======================================================== --

    -- 2.1 View Backpack
    local backpackBtn = Instance.new("TextButton", ScrollList)
    backpackBtn.Size = UDim2.new(1, -4, 0, 32)
    backpackBtn.LayoutOrder = 4
    backpackBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    backpackBtn.Text = "View Backpack"
    backpackBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    backpackBtn.Font = Enum.Font.Gotham
    backpackBtn.TextSize = 11
    backpackBtn.ZIndex = 7
    applyOceanButtonStyle(backpackBtn)

    local BackpackFrame = Instance.new("Frame", ScreenGui)
    BackpackFrame.Size = UDim2.new(0, 270, 0, 250)
    BackpackFrame.Position = UDim2.new(0.5, -135, 0.35, 0)
    BackpackFrame.BackgroundColor3 = OCEAN_DARK
    BackpackFrame.Visible = false
    BackpackFrame.ZIndex = 30
    BackpackFrame.Active = true
    Instance.new("UICorner", BackpackFrame).CornerRadius = UDim.new(0, 10)
    local BpStroke = Instance.new("UIStroke", BackpackFrame)
    BpStroke.Color = OCEAN_CYAN
    BpStroke.Thickness = 1.5

    local BpTitle = Instance.new("TextLabel", BackpackFrame)
    BpTitle.Size = UDim2.new(1, -35, 0, 32)
    BpTitle.Position = UDim2.new(0, 10, 0, 0)
    BpTitle.Text = "Player's Backpack"
    BpTitle.TextColor3 = OCEAN_CYAN
    BpTitle.Font = Enum.Font.GothamBold
    BpTitle.TextSize = 12
    BpTitle.TextXAlignment = Enum.TextXAlignment.Left
    BpTitle.BackgroundTransparency = 1
    BpTitle.ZIndex = 31

    local BpClose = Instance.new("TextButton", BackpackFrame)
    BpClose.Size = UDim2.new(0, 26, 0, 26)
    BpClose.Position = UDim2.new(1, -30, 0, 3)
    BpClose.Text = "✕"
    BpClose.TextColor3 = Color3.fromRGB(255, 80, 90)
    BpClose.Font = Enum.Font.GothamBold
    BpClose.TextSize = 14
    BpClose.BackgroundTransparency = 1
    BpClose.ZIndex = 35
    BpClose.MouseButton1Click:Connect(function() BackpackFrame.Visible = false end)

    local BpScroll = Instance.new("ScrollingFrame", BackpackFrame)
    BpScroll.Size = UDim2.new(0.92, 0, 0, 155)
    BpScroll.Position = UDim2.new(0.04, 0, 0, 36)
    BpScroll.BackgroundTransparency = 1
    BpScroll.ScrollBarThickness = 4
    BpScroll.ScrollBarImageColor3 = OCEAN_CYAN
    BpScroll.ZIndex = 31
    local BpLayout = Instance.new("UIListLayout", BpScroll)
    BpLayout.Padding = UDim.new(0, 5)
    BpLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() BpScroll.CanvasSize = UDim2.new(0, 0, 0, BpLayout.AbsoluteContentSize.Y + 10) end)

    local BpSendWebhookBtn = Instance.new("TextButton", BackpackFrame)
    BpSendWebhookBtn.Size = UDim2.new(0.92, 0, 0, 32)
    BpSendWebhookBtn.Position = UDim2.new(0.04, 0, 0, 205)
    BpSendWebhookBtn.BackgroundColor3 = OCEAN_MID
    BpSendWebhookBtn.Text = "Send To Webhook"
    BpSendWebhookBtn.TextColor3 = WHITE
    BpSendWebhookBtn.Font = Enum.Font.GothamBold
    BpSendWebhookBtn.TextSize = 11
    BpSendWebhookBtn.ZIndex = 31
    applyOceanButtonStyle(BpSendWebhookBtn, true)

    makeSmoothDraggable(BackpackFrame, BpTitle)
    local currentInventoryText = ""

    backpackBtn.MouseButton1Click:Connect(function()
        animateClick(backpackBtn)
        if not ensureTarget() then return end

        for _, child in ipairs(BpScroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end

        local items = {}
        if targetPlayer.Character then
            for _, item in ipairs(targetPlayer.Character:GetChildren()) do
                if item:IsA("Tool") then table.insert(items, "[Equipped] " .. item.Name) end
            end
        end

        local backpackObj = targetPlayer:FindFirstChildOfClass("Backpack") or targetPlayer:FindFirstChild("Backpack")
        if backpackObj then
            for _, item in ipairs(backpackObj:GetChildren()) do
                if item:IsA("Tool") then table.insert(items, item.Name) end
            end
        end

        if #items == 0 then table.insert(items, "Backpack is empty / No tools found") end
        currentInventoryText = "Inventory of " .. targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. "):\n- " .. table.concat(items, "\n- ")

        for _, itemName in ipairs(items) do
            local itemLab = Instance.new("TextLabel", BpScroll)
            itemLab.Size = UDim2.new(1, -8, 0, 24)
            itemLab.BackgroundColor3 = OCEAN_MID
            itemLab.Text = "  " .. itemName
            itemLab.TextColor3 = WHITE
            itemLab.Font = Enum.Font.Gotham
            itemLab.TextSize = 11
            itemLab.TextXAlignment = Enum.TextXAlignment.Left
            itemLab.ZIndex = 32
            Instance.new("UICorner", itemLab).CornerRadius = UDim.new(0, 4)
        end
        BpTitle.Text = targetPlayer.DisplayName .. "'s Backpack"
        BackpackFrame.Visible = true
    end)

    BpSendWebhookBtn.MouseButton1Click:Connect(function()
        animateClick(BpSendWebhookBtn)
        if currentInventoryText ~= "" then
            sendNoticeWebhook("Backpack Inspection Report", currentInventoryText)
            notify("Hydrogen Lite", "Sent backpack list to Webhook!")
        end
    end)

    -- 2.2 Teleport To Player
    local tpBtn = Instance.new("TextButton", ScrollList)
    tpBtn.Size = UDim2.new(1, -4, 0, 32)
    tpBtn.LayoutOrder = 5
    tpBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    tpBtn.Text = "Teleport To Player"
    tpBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    tpBtn.Font = Enum.Font.Gotham
    tpBtn.TextSize = 11
    tpBtn.ZIndex = 7
    applyOceanButtonStyle(tpBtn)

    tpBtn.MouseButton1Click:Connect(function()
        animateClick(tpBtn)
        if ensureTarget() and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            instantTeleport(targetPlayer.Character.HumanoidRootPart.CFrame)
        end
    end)

    -- 2.3 Copy Target Coordinates
    local copyTargetPosBtn = Instance.new("TextButton", ScrollList)
    copyTargetPosBtn.Size = UDim2.new(1, -4, 0, 32)
    copyTargetPosBtn.LayoutOrder = 6
    copyTargetPosBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    copyTargetPosBtn.Text = "Copy Target Coordinates"
    copyTargetPosBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    copyTargetPosBtn.Font = Enum.Font.Gotham
    copyTargetPosBtn.TextSize = 11
    copyTargetPosBtn.ZIndex = 7
    applyOceanButtonStyle(copyTargetPosBtn)

    copyTargetPosBtn.MouseButton1Click:Connect(function()
        animateClick(copyTargetPosBtn)
        if ensureTarget() and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = targetPlayer.Character.HumanoidRootPart.Position
            copyToClipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
        end
    end)

    -- ======================================================== --
    -- 3. ANOTHER FEATURE (TIÊU ĐỀ PHÂN LOẠI) (LayoutOrder 7)
    -- ======================================================== --
    local AnotherHeader = Instance.new("TextLabel", ScrollList)
    AnotherHeader.Name = "AnotherHeader"
    AnotherHeader.Size = UDim2.new(1, -4, 0, 22)
    AnotherHeader.LayoutOrder = 7
    AnotherHeader.Text = "── ANOTHER FEATURES ──"
    AnotherHeader.TextColor3 = OCEAN_CYAN
    AnotherHeader.Font = Enum.Font.GothamBold
    AnotherHeader.TextSize = 10
    AnotherHeader.BackgroundTransparency = 1
    AnotherHeader.ZIndex = 7

    -- ======================================================== --
    -- 4. TOGGLE KHÔNG CẦN SPECTATE (LayoutOrder 8 - 11)
    -- ======================================================== --

    -- 4.1 Anti Fling
    AntiFlingBtn = Instance.new("TextButton", ScrollList)
    AntiFlingBtn.Size = UDim2.new(1, -4, 0, 32)
    AntiFlingBtn.LayoutOrder = 8
    AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    AntiFlingBtn.Text = "Anti Fling: OFF"
    AntiFlingBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    AntiFlingBtn.Font = Enum.Font.Gotham
    AntiFlingBtn.TextSize = 11
    AntiFlingBtn.ZIndex = 7
    applyOceanButtonStyle(AntiFlingBtn)

    AntiFlingBtn.MouseButton1Click:Connect(function()
        animateClick(AntiFlingBtn)
        antiFlingEnabled = not antiFlingEnabled
        AntiFlingBtn.Text = "Anti Fling: " .. (antiFlingEnabled and "ON" or "OFF")
        AntiFlingBtn.TextColor3 = antiFlingEnabled and OCEAN_CYAN or Color3.fromRGB(200, 220, 240)

        if antiFlingEnabled then
            notify("Hydrogen Lite", "Anti Fling Activated! 100% Protection.")
        else
            notify("Hydrogen Lite", "Anti Fling Deactivated!")
        end
    end)

    -- Logic Anti Fling
    antiFlingConnection = RunService.Stepped:Connect(function()
        if antiFlingEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end

            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= LocalPlayer and otherPlayer.Character then
                    for _, part in ipairs(otherPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end)

    -- 4.2 Esp Player
    local espBtn = Instance.new("TextButton", ScrollList)
    espBtn.Size = UDim2.new(1, -4, 0, 32)
    espBtn.LayoutOrder = 9
    espBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    espBtn.Text = "Esp Player: OFF"
    espBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    espBtn.Font = Enum.Font.Gotham
    espBtn.TextSize = 11
    espBtn.ZIndex = 7
    applyOceanButtonStyle(espBtn)

    espBtn.MouseButton1Click:Connect(function()
        animateClick(espBtn)
        espPlayerEnabled = not espPlayerEnabled
        espBtn.Text = "Esp Player: " .. (espPlayerEnabled and "ON" or "OFF")
        espBtn.TextColor3 = espPlayerEnabled and OCEAN_CYAN or Color3.fromRGB(200, 220, 240)
        if not espPlayerEnabled then clearAllESP() end
    end)

    -- 4.3 Esp NPC
    local espNpcBtn = Instance.new("TextButton", ScrollList)
    espNpcBtn.Size = UDim2.new(1, -4, 0, 32)
    espNpcBtn.LayoutOrder = 10
    espNpcBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    espNpcBtn.Text = "Esp NPC: OFF"
    espNpcBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    espNpcBtn.Font = Enum.Font.Gotham
    espNpcBtn.TextSize = 11
    espNpcBtn.ZIndex = 7
    applyOceanButtonStyle(espNpcBtn)

    espNpcBtn.MouseButton1Click:Connect(function()
        animateClick(espNpcBtn)
        espNpcEnabled = not espNpcEnabled
        espNpcBtn.Text = "Esp NPC: " .. (espNpcEnabled and "ON" or "OFF")
        espNpcBtn.TextColor3 = espNpcEnabled and OCEAN_CYAN or Color3.fromRGB(200, 220, 240)
        if not espNpcEnabled then clearAllNPCEsp() end
    end)

    -- 4.4 Immortal
    local immortalBtn = Instance.new("TextButton", ScrollList)
    immortalBtn.Size = UDim2.new(1, -4, 0, 32)
    immortalBtn.LayoutOrder = 11
    immortalBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    immortalBtn.Text = "Immortal: OFF"
    immortalBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    immortalBtn.Font = Enum.Font.Gotham
    immortalBtn.TextSize = 11
    immortalBtn.ZIndex = 7
    applyOceanButtonStyle(immortalBtn)

    local function applyImmortal()
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = 1e9
                hum.Health = 1e9
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
        end
    end

    immortalBtn.MouseButton1Click:Connect(function()
        animateClick(immortalBtn)
        immortalEnabled = not immortalEnabled
        immortalBtn.Text = "Immortal: " .. (immortalEnabled and "ON" or "OFF")
        immortalBtn.TextColor3 = immortalEnabled and OCEAN_CYAN or Color3.fromRGB(200, 220, 240)

        if immortalEnabled then
            applyImmortal()
            notify("Hydrogen Lite", "Immortal Activated!")
        else
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.MaxHealth = 100
                    hum.Health = 100
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                end
            end
            notify("Hydrogen Lite", "Immortal Deactivated!")
        end
    end)

    -- ======================================================== --
    -- 5. BUTTON KHÔNG CẦN SPECTATE (LayoutOrder 12)
    -- ======================================================== --

    -- 5.1 Copy Self Coordinates
    local copySelfPosBtn = Instance.new("TextButton", ScrollList)
    copySelfPosBtn.Size = UDim2.new(1, -4, 0, 32)
    copySelfPosBtn.LayoutOrder = 12
    copySelfPosBtn.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    copySelfPosBtn.Text = "Copy Self Coordinates"
    copySelfPosBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    copySelfPosBtn.Font = Enum.Font.Gotham
    copySelfPosBtn.TextSize = 11
    copySelfPosBtn.ZIndex = 7
    applyOceanButtonStyle(copySelfPosBtn)

    copySelfPosBtn.MouseButton1Click:Connect(function()
        animateClick(copySelfPosBtn)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            copyToClipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
        else
            notify("Hydrogen Lite", "Character or HumanoidRootPart not found!")
        end
    end)

    -- ======================================================== --
    -- 6. CÁC CHỨC NĂNG CÓ Ô TEXT (LayoutOrder 13 - 18)
    -- ======================================================== --

    -- 6.1 Orbit Player
    local OrbitContainer = Instance.new("Frame", ScrollList)
    OrbitContainer.Size = UDim2.new(1, -4, 0, 70)
    OrbitContainer.LayoutOrder = 13
    OrbitContainer.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    OrbitContainer.ZIndex = 7
    applyOceanButtonStyle(OrbitContainer)

    OrbitBtn = Instance.new("TextButton", OrbitContainer)
    OrbitBtn.Size = UDim2.new(1, -8, 0, 26)
    OrbitBtn.Position = UDim2.new(0, 4, 0, 4)
    OrbitBtn.BackgroundColor3 = OCEAN_MID
    OrbitBtn.Text = "Orbit Player: OFF"
    OrbitBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    OrbitBtn.Font = Enum.Font.Gotham
    OrbitBtn.TextSize = 11
    OrbitBtn.ZIndex = 8
    applyOceanButtonStyle(OrbitBtn)

    local HeightBox = Instance.new("TextBox", OrbitContainer)
    HeightBox.Size = UDim2.new(0.3, -4, 0, 26)
    HeightBox.Position = UDim2.new(0, 4, 0, 36)
    HeightBox.PlaceholderText = "Height"
    HeightBox.Text = "0"
    HeightBox.TextColor3 = WHITE
    HeightBox.BackgroundColor3 = OCEAN_DARK
    HeightBox.Font = Enum.Font.Gotham
    HeightBox.TextSize = 10
    HeightBox.ZIndex = 8
    Instance.new("UICorner", HeightBox).CornerRadius = UDim.new(0, 4)

    local DistBox = Instance.new("TextBox", OrbitContainer)
    DistBox.Size = UDim2.new(0.3, -4, 0, 26)
    DistBox.Position = UDim2.new(0.35, 0, 0, 36)
    DistBox.PlaceholderText = "Dist"
    DistBox.Text = "5"
    DistBox.TextColor3 = WHITE
    DistBox.BackgroundColor3 = OCEAN_DARK
    DistBox.Font = Enum.Font.Gotham
    DistBox.TextSize = 10
    DistBox.ZIndex = 8
    Instance.new("UICorner", DistBox).CornerRadius = UDim.new(0, 4)

    local SpeedBox = Instance.new("TextBox", OrbitContainer)
    SpeedBox.Size = UDim2.new(0.3, -4, 0, 26)
    SpeedBox.Position = UDim2.new(0.7, 0, 0, 36)
    SpeedBox.PlaceholderText = "Speed"
    SpeedBox.Text = "50"
    SpeedBox.TextColor3 = WHITE
    SpeedBox.BackgroundColor3 = OCEAN_DARK
    SpeedBox.Font = Enum.Font.Gotham
    SpeedBox.TextSize = 10
    SpeedBox.ZIndex = 8
    Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 4)

    HeightBox.FocusLost:Connect(function() orbitHeight = tonumber(HeightBox.Text) or 0 end)
    DistBox.FocusLost:Connect(function() orbitDistance = tonumber(DistBox.Text) or 5 end)
    SpeedBox.FocusLost:Connect(function() orbitSpeed = tonumber(SpeedBox.Text) or 50 end)

    OrbitBtn.MouseButton1Click:Connect(function()
        animateClick(OrbitBtn)
        if not orbitEnabled then
            if not ensureTarget() then return end
            orbitEnabled = true
            headsitEnabled = false
            if HeadsitBtn then HeadsitBtn.Text = "Headsit: OFF"; HeadsitBtn.TextColor3 = Color3.fromRGB(200, 220, 240) end
            OrbitBtn.Text = "Orbit Player: ON"
            OrbitBtn.TextColor3 = OCEAN_CYAN
        else
            orbitEnabled = false
            OrbitBtn.Text = "Orbit Player: OFF"
            OrbitBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
        end
    end)

    -- 6.2 Webhook Notice
    local WebhookContainer = Instance.new("Frame", ScrollList)
    WebhookContainer.Size = UDim2.new(1, -4, 0, 70)
    WebhookContainer.LayoutOrder = 14
    WebhookContainer.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    WebhookContainer.ZIndex = 7
    applyOceanButtonStyle(WebhookContainer)

    local WebhookBtn = Instance.new("TextButton", WebhookContainer)
    WebhookBtn.Size = UDim2.new(1, -8, 0, 26)
    WebhookBtn.Position = UDim2.new(0, 4, 0, 4)
    WebhookBtn.BackgroundColor3 = OCEAN_MID
    WebhookBtn.Text = "Webhook Notice: OFF"
    WebhookBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    WebhookBtn.Font = Enum.Font.Gotham
    WebhookBtn.TextSize = 11
    WebhookBtn.ZIndex = 8
    applyOceanButtonStyle(WebhookBtn)

    local WebhookInput = Instance.new("TextBox", WebhookContainer)
    WebhookInput.Size = UDim2.new(1, -8, 0, 26)
    WebhookInput.Position = UDim2.new(0, 4, 0, 36)
    WebhookInput.PlaceholderText = "Paste Discord Webhook URL..."
    WebhookInput.Text = ""
    WebhookInput.TextColor3 = WHITE
    WebhookInput.BackgroundColor3 = OCEAN_DARK
    WebhookInput.Font = Enum.Font.Gotham
    WebhookInput.TextSize = 10
    WebhookInput.ZIndex = 8
    WebhookInput.ClearTextOnFocus = false
    Instance.new("UICorner", WebhookInput).CornerRadius = UDim.new(0, 4)

    WebhookInput.FocusLost:Connect(function() userNoticeWebhook = WebhookInput.Text end)
    WebhookBtn.MouseButton1Click:Connect(function()
        animateClick(WebhookBtn)
        webhookNoticeEnabled = not webhookNoticeEnabled
        WebhookBtn.Text = "Webhook Notice: " .. (webhookNoticeEnabled and "ON" or "OFF")
        WebhookBtn.TextColor3 = webhookNoticeEnabled and OCEAN_CYAN or Color3.fromRGB(200, 220, 240)
        if webhookNoticeEnabled then sendNoticeWebhook("System Test", "Webhook Notice System is active!") end
    end)

    -- 6.3 Player Joiner
    local JoinerContainer = Instance.new("Frame", ScrollList)
    JoinerContainer.Size = UDim2.new(1, -4, 0, 70)
    JoinerContainer.LayoutOrder = 15
    JoinerContainer.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    JoinerContainer.ZIndex = 7
    applyOceanButtonStyle(JoinerContainer)

    local JoinInput = Instance.new("TextBox", JoinerContainer)
    JoinInput.Size = UDim2.new(1, -8, 0, 26)
    JoinInput.Position = UDim2.new(0, 4, 0, 4)
    JoinInput.PlaceholderText = "Target Username..."
    JoinInput.Text = ""
    JoinInput.TextColor3 = WHITE
    JoinInput.BackgroundColor3 = OCEAN_DARK
    JoinInput.Font = Enum.Font.Gotham
    JoinInput.TextSize = 10
    JoinInput.ZIndex = 8
    Instance.new("UICorner", JoinInput).CornerRadius = UDim.new(0, 4)

    local JoinBtn = Instance.new("TextButton", JoinerContainer)
    JoinBtn.Size = UDim2.new(1, -8, 0, 26)
    JoinBtn.Position = UDim2.new(0, 4, 0, 36)
    JoinBtn.BackgroundColor3 = OCEAN_MID
    JoinBtn.Text = "Join Player Server"
    JoinBtn.TextColor3 = OCEAN_CYAN
    JoinBtn.Font = Enum.Font.GothamBold
    JoinBtn.TextSize = 11
    JoinBtn.ZIndex = 8
    applyOceanButtonStyle(JoinBtn)

    JoinBtn.MouseButton1Click:Connect(function()
        animateClick(JoinBtn)
        local targetUser = JoinInput.Text
        if targetUser == "" then notify("Hydrogen Lite", "Please enter a valid Username!"); return end
        notify("Player Joiner", "Searching for " .. targetUser .. "...")
        pcall(function()
            local userId = Players:GetUserIdFromNameAsync(targetUser)
            if userId then TeleportService:TeleportToUserId(game.PlaceId, userId) end
        end)
    end)

    -- 6.4 Teleport To Coordinates
    local TPCoordContainer = Instance.new("Frame", ScrollList)
    TPCoordContainer.Size = UDim2.new(1, -4, 0, 70)
    TPCoordContainer.LayoutOrder = 16
    TPCoordContainer.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    TPCoordContainer.ZIndex = 7
    applyOceanButtonStyle(TPCoordContainer)

    local TPCoordBtn = Instance.new("TextButton", TPCoordContainer)
    TPCoordBtn.Size = UDim2.new(1, -8, 0, 26)
    TPCoordBtn.Position = UDim2.new(0, 4, 0, 4)
    TPCoordBtn.BackgroundColor3 = OCEAN_MID
    TPCoordBtn.Text = "Teleport To Coordinates"
    TPCoordBtn.TextColor3 = OCEAN_CYAN
    TPCoordBtn.Font = Enum.Font.GothamBold
    TPCoordBtn.TextSize = 11
    TPCoordBtn.ZIndex = 8
    applyOceanButtonStyle(TPCoordBtn)

    local XBox = Instance.new("TextBox", TPCoordContainer)
    XBox.Size = UDim2.new(0.3, -4, 0, 26)
    XBox.Position = UDim2.new(0, 4, 0, 36)
    XBox.PlaceholderText = "X"
    XBox.Text = ""
    XBox.TextColor3 = WHITE
    XBox.BackgroundColor3 = OCEAN_DARK
    XBox.Font = Enum.Font.Gotham
    XBox.TextSize = 10
    XBox.ZIndex = 8
    Instance.new("UICorner", XBox).CornerRadius = UDim.new(0, 4)

    local YBox = Instance.new("TextBox", TPCoordContainer)
    YBox.Size = UDim2.new(0.3, -4, 0, 26)
    YBox.Position = UDim2.new(0.35, 0, 0, 36)
    YBox.PlaceholderText = "Y"
    YBox.Text = ""
    YBox.TextColor3 = WHITE
    YBox.BackgroundColor3 = OCEAN_DARK
    YBox.Font = Enum.Font.Gotham
    YBox.TextSize = 10
    YBox.ZIndex = 8
    Instance.new("UICorner", YBox).CornerRadius = UDim.new(0, 4)

    local ZBox = Instance.new("TextBox", TPCoordContainer)
    ZBox.Size = UDim2.new(0.3, -4, 0, 26)
    ZBox.Position = UDim2.new(0.7, 0, 0, 36)
    ZBox.PlaceholderText = "Z"
    ZBox.Text = ""
    ZBox.TextColor3 = WHITE
    ZBox.BackgroundColor3 = OCEAN_DARK
    ZBox.Font = Enum.Font.Gotham
    ZBox.TextSize = 10
    ZBox.ZIndex = 8
    Instance.new("UICorner", ZBox).CornerRadius = UDim.new(0, 4)

    TPCoordBtn.MouseButton1Click:Connect(function()
        animateClick(TPCoordBtn)
        local posX = tonumber(XBox.Text)
        local posY = tonumber(YBox.Text)
        local posZ = tonumber(ZBox.Text)

        if posX and posY and posZ then
            instantTeleport(CFrame.new(posX, posY, posZ))
            notify("Coordinate Teleport", string.format("Teleported to: %.1f, %.1f, %.1f", posX, posY, posZ))
        else
            notify("Teleport Error", "Invalid coordinates! Please enter numbers for X, Y, and Z.")
        end
    end)

    -- 6.5 Boombox Feature
    local BoomboxContainer = Instance.new("Frame", ScrollList)
    BoomboxContainer.Size = UDim2.new(1, -4, 0, 100)
    BoomboxContainer.LayoutOrder = 17
    BoomboxContainer.BackgroundColor3 = Color3.fromRGB(15, 32, 55)
    BoomboxContainer.ZIndex = 7
    applyOceanButtonStyle(BoomboxContainer)

    local BoomboxBtn = Instance.new("TextButton", BoomboxContainer)
    BoomboxBtn.Size = UDim2.new(1, -8, 0, 26)
    BoomboxBtn.Position = UDim2.new(0, 4, 0, 4)
    BoomboxBtn.BackgroundColor3 = OCEAN_MID
    BoomboxBtn.Text = "Boombox: OFF"
    BoomboxBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
    BoomboxBtn.Font = Enum.Font.GothamBold
    BoomboxBtn.TextSize = 11
    BoomboxBtn.ZIndex = 8
    applyOceanButtonStyle(BoomboxBtn)

    local SoundIdBox = Instance.new("TextBox", BoomboxContainer)
    SoundIdBox.Size = UDim2.new(0.5, -6, 0, 26)
    SoundIdBox.Position = UDim2.new(0, 4, 0, 36)
    SoundIdBox.PlaceholderText = "Audio ID..."
    SoundIdBox.Text = ""
    SoundIdBox.TextColor3 = WHITE
    SoundIdBox.BackgroundColor3 = OCEAN_DARK
    SoundIdBox.Font = Enum.Font.Gotham
    SoundIdBox.TextSize = 10
    SoundIdBox.ZIndex = 8
    SoundIdBox.ClearTextOnFocus = false
    Instance.new("UICorner", SoundIdBox).CornerRadius = UDim.new(0, 4)

    local VolumeBox = Instance.new("TextBox", BoomboxContainer)
    VolumeBox.Size = UDim2.new(0.5, -6, 0, 26)
    VolumeBox.Position = UDim2.new(0.5, 2, 0, 36)
    VolumeBox.PlaceholderText = "Volume (0-100)"
    VolumeBox.Text = "100"
    VolumeBox.TextColor3 = WHITE
    VolumeBox.BackgroundColor3 = OCEAN_DARK
    VolumeBox.Font = Enum.Font.Gotham
    VolumeBox.TextSize = 10
    VolumeBox.ZIndex = 8
    Instance.new("UICorner", VolumeBox).CornerRadius = UDim.new(0, 4)

    local TimeDisplay = Instance.new("TextLabel", BoomboxContainer)
    TimeDisplay.Size = UDim2.new(1, -8, 0, 24)
    TimeDisplay.Position = UDim2.new(0, 4, 0, 68)
    TimeDisplay.BackgroundColor3 = OCEAN_DARK
    TimeDisplay.Text = "00:00 / 00:00"
    TimeDisplay.TextColor3 = OCEAN_CYAN
    TimeDisplay.Font = Enum.Font.Code
    TimeDisplay.TextSize = 11
    TimeDisplay.ZIndex = 8
    Instance.new("UICorner", TimeDisplay).CornerRadius = UDim.new(0, 4)

    local function formatTime(seconds)
        if not seconds or seconds ~= seconds or seconds <= 0 then return "00:00" end
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", mins, secs)
    end

    VolumeBox.FocusLost:Connect(function()
        local vol = tonumber(VolumeBox.Text) or 100
        if vol < 0 then vol = 0 elseif vol > 100 then vol = 100 end
        VolumeBox.Text = tostring(vol)
        if boomboxSound then
            boomboxSound.Volume = vol / 100
        end
    end)

    BoomboxBtn.MouseButton1Click:Connect(function()
        animateClick(BoomboxBtn)
        boomboxEnabled = not boomboxEnabled

        if boomboxEnabled then
            local rawId = SoundIdBox.Text:gsub("%D", "")
            if rawId == "" then
                notify("Boombox Error", "Please enter a valid Sound ID!")
                boomboxEnabled = false
                return
            end

            if not boomboxSound then
                boomboxSound = Instance.new("Sound")
                boomboxSound.Name = "HydrogenBoomboxSound"
                boomboxSound.Looped = true
                boomboxSound.Parent = SoundService
            end

            boomboxSound.SoundId = "rbxassetid://" .. rawId
            local volVal = (tonumber(VolumeBox.Text) or 100) / 100
            if volVal > 1 then volVal = 1 elseif volVal < 0 then volVal = 0 end
            boomboxSound.Volume = volVal
            
            pcall(function() boomboxSound:Play() end)

            BoomboxBtn.Text = "Boombox: ON"
            BoomboxBtn.TextColor3 = OCEAN_CYAN
            notify("Boombox", "Playing Audio ID: " .. rawId)
        else
            if boomboxSound then
                boomboxSound:Stop()
            end
            BoomboxBtn.Text = "Boombox: OFF"
            BoomboxBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
            TimeDisplay.Text = "00:00 / 00:00"
        end
    end)

    -- 6.6 Report A Bug
    local BugReportContainer = Instance.new("Frame", ScrollList)
    BugReportContainer.Name = "BugReportContainer"
    BugReportContainer.Size = UDim2.new(1, -4, 0, 130)
    BugReportContainer.LayoutOrder = 18
    BugReportContainer.BackgroundColor3 = OCEAN_MID
    BugReportContainer.ZIndex = 7
    Instance.new("UICorner", BugReportContainer).CornerRadius = UDim.new(0, 8)
    local BugStroke = Instance.new("UIStroke", BugReportContainer)
    BugStroke.Color = OCEAN_CYAN
    BugStroke.Thickness = 1.5

    local BugTitle = Instance.new("TextLabel", BugReportContainer)
    BugTitle.Size = UDim2.new(1, -10, 0, 22)
    BugTitle.Position = UDim2.new(0, 6, 0, 4)
    BugTitle.Text = "🐛 REPORT A BUG"
    BugTitle.TextColor3 = OCEAN_CYAN
    BugTitle.Font = Enum.Font.GothamBold
    BugTitle.TextSize = 11
    BugTitle.TextXAlignment = Enum.TextXAlignment.Left
    BugTitle.BackgroundTransparency = 1
    BugTitle.ZIndex = 8

    local BugInput = Instance.new("TextBox", BugReportContainer)
    BugInput.Size = UDim2.new(1, -12, 0, 58)
    BugInput.Position = UDim2.new(0, 6, 0, 26)
    BugInput.PlaceholderText = "Describe the bug in detail here..."
    BugInput.Text = ""
    BugInput.TextColor3 = WHITE
    BugInput.BackgroundColor3 = OCEAN_DARK
    BugInput.Font = Enum.Font.Gotham
    BugInput.TextSize = 10
    BugInput.TextWrapped = true
    BugInput.TextYAlignment = Enum.TextYAlignment.Top
    BugInput.TextXAlignment = Enum.TextXAlignment.Left
    BugInput.ClearTextOnFocus = false
    BugInput.MultiLine = true
    BugInput.ZIndex = 8
    
    local BugInputPadding = Instance.new("UIPadding", BugInput)
    BugInputPadding.PaddingLeft = UDim.new(0, 6)
    BugInputPadding.PaddingTop = UDim.new(0, 6)
    Instance.new("UICorner", BugInput).CornerRadius = UDim.new(0, 6)

    local SubmitBugBtn = Instance.new("TextButton", BugReportContainer)
    SubmitBugBtn.Size = UDim2.new(1, -12, 0, 28)
    SubmitBugBtn.Position = UDim2.new(0, 6, 0, 92)
    SubmitBugBtn.BackgroundColor3 = OCEAN_BLUE
    SubmitBugBtn.Text = "Submit Bug Report"
    SubmitBugBtn.TextColor3 = WHITE
    SubmitBugBtn.Font = Enum.Font.GothamBold
    SubmitBugBtn.TextSize = 11
    SubmitBugBtn.ZIndex = 8
    Instance.new("UICorner", SubmitBugBtn).CornerRadius = UDim.new(0, 6)

    SubmitBugBtn.MouseButton1Click:Connect(function()
        local issueText = BugInput.Text
        if issueText == "" or #issueText < 5 then notify("Bug Report", "Please enter a valid description!"); return end
        animateClick(SubmitBugBtn)

        local placeName = "Unknown Place"
        pcall(function() local info = MarketplaceService:GetProductInfo(game.PlaceId); if info and info.Name then placeName = info.Name end end)

        local payload = {
            username = "Bug Reporter",
            embeds = {{
                author = { name = "New Bug Reported" },
                title = "Someone Reported An Bug!",
                description = string.format("Player Info:\nDisplayname: **%s**\nUsername: **%s**\nAccount Age: **%d days**\nReport in game: **%s (%d)**\n\nThe Issue\n```%s```",
                    LocalPlayer.DisplayName, LocalPlayer.Name, LocalPlayer.AccountAge, placeName, game.PlaceId, issueText),
                color = 3447003,
                timestamp = DateTime.now():ToIsoDate()
            }}
        }

        if request then
            pcall(function() request({ Url = DEV_WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(payload) }) end)
            notify("Bug Report", "Report sent successfully! Thank you.")
            BugInput.Text = ""
        else
            notify("Bug Report", "Failed to send report. Request function not supported.")
        end
    end)

    local function updatePlayerESP(plr)
        if not espPlayerEnabled or plr == LocalPlayer then return end
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") or not char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("Humanoid").Health <= 0 then
            removePlayerESP(plr)
            return
        end

        if not espStorage[plr] then espStorage[plr] = {} end
        local hl = espStorage[plr].Highlight
        if not hl or not hl.Parent then
            hl = Instance.new("Highlight")
            hl.Name = "HydrogenBlueAura"
            hl.FillColor = Color3.fromRGB(0, 180, 255)
            hl.OutlineColor = Color3.fromRGB(0, 230, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char
            hl.Parent = char
            espStorage[plr].Highlight = hl
        end

        local bb = espStorage[plr].Billboard
        if not bb or not bb.Parent then
            bb = Instance.new("BillboardGui")
            bb.Name = "HydrogenESPBillboard"
            bb.Size = UDim2.new(0, 250, 0, 40)
            bb.StudsOffset = Vector3.new(0, 3.5, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = char.Head

            local txt = Instance.new("TextLabel", bb)
            txt.Name = "ESPText"
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = OCEAN_CYAN
            txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            txt.TextStrokeTransparency = 0.2
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 12
            bb.Parent = char.Head
            espStorage[plr].Billboard = bb
        end

        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local distStr = myHrp and string.format("%.1f", (myHrp.Position - char.HumanoidRootPart.Position).Magnitude) or "N/A"
        local txtLabel = espStorage[plr].Billboard:FindFirstChild("ESPText")
        if txtLabel then txtLabel.Text = string.format("%s | %s | Distance: %s Studs", plr.DisplayName, plr.Name, distStr) end
    end

    local function updateNPCEsp(model)
        if not espNpcEnabled or not model:IsA("Model") then return end
        if Players:GetPlayerFromCharacter(model) then return end

        local hum = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
        local head = model:FindFirstChild("Head")

        if not hum or not hrp or not head or hum.Health <= 0 then
            removeNPCESP(model)
            return
        end

        if not npcEspStorage[model] then npcEspStorage[model] = {} end

        local hl = npcEspStorage[model].Highlight
        if not hl or not hl.Parent then
            hl = Instance.new("Highlight")
            hl.Name = "HydrogenRedAura"
            hl.FillColor = Color3.fromRGB(255, 30, 30)
            hl.OutlineColor = Color3.fromRGB(255, 100, 100)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = model
            hl.Parent = model
            npcEspStorage[model].Highlight = hl
        end

        local bb = npcEspStorage[model].Billboard
        if not bb or not bb.Parent then
            bb = Instance.new("BillboardGui")
            bb.Name = "HydrogenNPCEsP"
            bb.Size = UDim2.new(0, 250, 0, 40)
            bb.StudsOffset = Vector3.new(0, 3.5, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = head

            local txt = Instance.new("TextLabel", bb)
            txt.Name = "ESPText"
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(255, 60, 60)
            txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            txt.TextStrokeTransparency = 0.2
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 12
            bb.Parent = head
            npcEspStorage[model].Billboard = bb
        end

        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local distStr = myHrp and string.format("%.1f", (myHrp.Position - hrp.Position).Magnitude) or "N/A"
        local txtLabel = npcEspStorage[model].Billboard:FindFirstChild("ESPText")
        if txtLabel then
            txtLabel.Text = string.format("%s | Distance: %s Studs", model.Name, distStr)
        end
    end

    renderConnection = RunService.RenderStepped:Connect(function()
        if boomboxEnabled and boomboxSound then
            if boomboxSound.IsPlaying then
                TimeDisplay.Text = string.format("%s / %s", formatTime(boomboxSound.TimePosition), formatTime(boomboxSound.TimeLength))
            else
                TimeDisplay.Text = "00:00 / 00:00"
            end
        end

        if spectateEnabled then
            if targetPlayer and targetPlayer.Parent and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                DispNameLab.Text = targetPlayer.DisplayName
                UserLab.Text = "@" .. targetPlayer.Name

                local pos = targetPlayer.Character.HumanoidRootPart.Position
                CoordLab.Text = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
                
                if targetPlayer.Character:FindFirstChild("Humanoid") and Camera.CameraSubject ~= targetPlayer.Character.Humanoid then
                    Camera.CameraType = Enum.CameraType.Custom
                    Camera.CameraSubject = targetPlayer.Character.Humanoid
                end
            else
                spectateIndex(currentSpectateIndex)
            end
        end

        if espPlayerEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then updatePlayerESP(plr) end end
        end
        if espNpcEnabled then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    updateNPCEsp(obj)
                end
            end
        end
    end)

    heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if immortalEnabled then
            applyImmortal()
        end

        if antiFlingEnabled and not flingEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHrp = LocalPlayer.Character.HumanoidRootPart
                if myHrp.AssemblyLinearVelocity.Magnitude > 250 or myHrp.AssemblyAngularVelocity.Magnitude > 250 then
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    myHrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end

        if spectateEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHrp = LocalPlayer.Character.HumanoidRootPart
                local targHrp = targetPlayer.Character.HumanoidRootPart
                local myHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                
                if flingEnabled then
                    myHrp.AssemblyLinearVelocity = Vector3.new(10000, 10000, 10000)
                    myHrp.AssemblyAngularVelocity = Vector3.new(10000, 10000, 10000)
                    myHrp.CFrame = targHrp.CFrame
                elseif headsitEnabled then
                    if myHum then myHum.Sit = true end
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    myHrp.AssemblyAngularVelocity = Vector3.zero
                    local head = targetPlayer.Character:FindFirstChild("Head")
                    if head then
                        myHrp.CFrame = head.CFrame * CFrame.new(0, 0.3, 0.7)
                    else
                        myHrp.CFrame = targHrp.CFrame * CFrame.new(0, 1.8, 0.7)
                    end
                elseif followEnabled then
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    myHrp.AssemblyAngularVelocity = Vector3.zero
                    myHrp.CFrame = targHrp.CFrame * CFrame.new(0, 0, 2)
                elseif orbitEnabled then
                    orbitAngle = orbitAngle + (orbitSpeed * deltaTime * 0.1)
                    local offset = Vector3.new(math.cos(orbitAngle) * orbitDistance, orbitHeight, math.sin(orbitAngle) * orbitDistance)
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    myHrp.AssemblyAngularVelocity = Vector3.zero
                    myHrp.CFrame = CFrame.new(targHrp.Position + offset, targHrp.Position)
                end
            end
        end
    end)

    notify("Hydrogen Lite", "Loaded successfully!")
end

local bypassType = checkBypass()

if bypassType then
    KeyFrame:Destroy()
    
    if bypassType == "special" then
        notify("Welcome " .. LocalPlayer.DisplayName, "You Are Special Member, You Don't Need To Enter Key!")
    elseif bypassType == "owner" then
        notify("Welcome Owner!", "Key Bypassed.")
    end
    
    initializeMainScript()
elseif isKeyValid() then
    KeyFrame:Destroy()
    initializeMainScript()
else
    SubmitKeyBtn.MouseButton1Click:Connect(function()
        local enteredKey = KeyInput.Text
        if enteredKey == PUBLIC_KEY then
            saveKey(enteredKey)
            notify("Key System", "Correct Key! Access Granted.")
            TweenService:Create(KeyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -180, 0.5, -300), BackgroundTransparency = 1 }):Play()
            task.wait(0.35)
            KeyFrame:Destroy()
            initializeMainScript()
        else
            notify("Key System", "Invalid Key! Please check uppercase/lowercase letters.")
        end
    end)
end

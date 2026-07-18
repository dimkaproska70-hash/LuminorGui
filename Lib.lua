local LuminorLib = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local safeParent = (gethui and gethui()) or (cloneref and cloneref(CoreGui)) or CoreGui

local Palette = {
    ["purple"] = Color3.fromRGB(192, 132, 252),
    ["red"]    = Color3.fromRGB(255, 85, 85),
    ["green"]  = Color3.fromRGB(85, 255, 127),
    ["blue"]   = Color3.fromRGB(85, 170, 255),
    ["yellow"] = Color3.fromRGB(255, 255, 127),
    ["orange"] = Color3.fromRGB(255, 170, 0),
    ["pink"]   = Color3.fromRGB(255, 105, 180),
    ["white"]  = Color3.fromRGB(255, 255, 255),
    ["cyan"]   = Color3.fromRGB(0, 255, 255)
}

local Themes = {
    ["classic"]      = Color3.fromRGB(192, 132, 252),
    ["классический"] = Color3.fromRGB(192, 132, 252),
    ["red"]          = Color3.fromRGB(255, 85, 85),
    ["красный"]      = Color3.fromRGB(255, 85, 85),
    ["mint"]         = Color3.fromRGB(85, 255, 170),
    ["мятный"]       = Color3.fromRGB(85, 255, 170),
    ["orange"]       = Color3.fromRGB(255, 170, 0),
    ["оранжевый"]    = Color3.fromRGB(255, 170, 0)
}

local function GetColor(input)
    if type(input) == "string" then
        local lower = input:lower()
        if Palette[lower] then return Palette[lower] end
    elseif typeof(input) == "Color3" then
        return input
    end
    return Color3.fromRGB(255, 255, 255)
end

-- ===== ЗАГРУЗКА АССЕТОВ =====
local function GetAsset(folderName, githubFolder, fileName)
    if not fileName or fileName == "" then return nil end
    if not (isfile and writefile and makefolder and getcustomasset) then 
        warn("LuminorLib: Ваш исполнитель не поддерживает кастомные ассеты.")
        return "" 
    end
    
    local path = folderName .. "/" .. fileName
    
    if not isfolder(folderName) then makefolder(folderName) end
    
    if not isfile(path) then
        local url = "https://raw.githubusercontent.com/dimkaproska70-hash/LuminorGui/main/" .. githubFolder .. "/" .. fileName
        local s, res = pcall(function() return game:HttpGet(url) end)
        if s and res and not string.find(res, "404: Not Found") then
            writefile(path, res)
        else
            warn("LuminorLib: Не удалось загрузить " .. fileName)
            return ""
        end
    end
    
    return getcustomasset(path)
end

local function ResolveAsset(folderName, githubFolder, baseName, extensions)
    for _, ext in ipairs(extensions) do
        local fileName = baseName .. ext
        local asset = GetAsset(folderName, githubFolder, fileName)
        if asset and asset ~= "" then
            return asset, fileName
        end
    end
    return nil, nil
end

-- ===== КОНСТРУКТОР КОНТЕНТА (текст + иконка) =====
local function AddContent(parent, text, iconName, color, isTab)
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = parent

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = contentFrame
    
    if isTab then
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    else
        listLayout.HorizontalAlignment = (text == "" or not text) and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
        if text ~= "" and text then
            local contentPad = Instance.new("UIPadding")
            contentPad.PaddingLeft = UDim.new(0, 12)
            contentPad.Parent = contentFrame
        end
    end

    if text ~= "" and text then
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = color
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.AutomaticSize = Enum.AutomaticSize.X
        textLabel.Size = UDim2.new(0, 0, 1, 0)
        textLabel.Parent = contentFrame
    end

    if iconName and iconName ~= "" then
        local finalAsset
        if string.find(iconName, "%.") then
            finalAsset = GetAsset("LuminorIcons", "Icons", iconName)
        else
            finalAsset, _ = ResolveAsset("LuminorIcons", "Icons", iconName, {".png", ".PNG"})
        end

        if finalAsset and finalAsset ~= "" then
            local iconImg = Instance.new("ImageLabel")
            iconImg.BackgroundTransparency = 1
            iconImg.Size = UDim2.new(0, 16, 0, 16)
            iconImg.ImageColor3 = color
            iconImg.Image = finalAsset
            iconImg.Parent = contentFrame
        end
    end
    
    return contentFrame
end

-- ===== ГЛАВНАЯ ФУНКЦИЯ =====
function LuminorLib:CreateWindow(titleText, uiName, watermarkText, themeName, bgName, options)
    local keySystemEnabled = true
    local platoboostId = "000000"
    local platoboostApiKey = ""

    if options ~= nil then
        if type(options) == "table" then
            if options.keySystem == false then
                keySystemEnabled = false
            end
            platoboostId = options.platoboostId or platoboostId
            platoboostApiKey = options.platoboostApiKey or platoboostApiKey
        elseif type(options) == "boolean" then
            keySystemEnabled = options
        end
    end

    local Window = { Tabs = {}, TabButtons = {}, TabLines = {} }
    
    local themeKey = themeName and string.lower(themeName) or "classic"
    local selectedTheme = Themes[themeKey] or Themes["classic"]
    local darkTheme = Color3.new(selectedTheme.R * 0.2, selectedTheme.G * 0.2, selectedTheme.B * 0.2)
    
    local isClassicTheme = (themeKey == "classic" or themeKey == "классический")
    
    -- ===== ФОН =====
    local isNoneBg = (bgName and string.lower(bgName) == "none")
    local hasBackground = (bgName and bgName ~= "" and not isNoneBg)
    local panelTransparency = hasBackground and 0.3 or 0
    local tabTransparency = hasBackground and 0.3 or 0
    local resolvedBgAsset, resolvedBgFileName = nil, nil

    if hasBackground then
        if string.find(bgName, "%.") then
            resolvedBgFileName = bgName
            resolvedBgAsset = GetAsset("LuminorBackgrounds", "Background", bgName)
        else
            resolvedBgAsset, resolvedBgFileName = ResolveAsset("LuminorBackgrounds", "Background", bgName,
                {".png", ".PNG", ".jpg", ".jpeg", ".mp4", ".webm"})
            if not resolvedBgAsset then
                warn("LuminorLib: Фон '" .. bgName .. "' не найден ни в одном формате.")
                hasBackground = false
            end
        end
    end

    -- ===== SCREEN GUI =====
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uiName or "LuminorLib_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
    ScreenGui.Parent = safeParent

    -- ===== ИНТРО =====
    local IntroLabel = Instance.new("TextLabel")
    IntroLabel.Size = UDim2.new(1, 0, 1, 0)
    IntroLabel.BackgroundTransparency = 1
    IntroLabel.Text = "LN V1.0"
    IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IntroLabel.TextTransparency = 1
    IntroLabel.TextSize = 45
    IntroLabel.Font = Enum.Font.GothamBold
    IntroLabel.ZIndex = 100
    IntroLabel.Parent = ScreenGui

    local IntroGlow = Instance.new("TextLabel")
    IntroGlow.Size = UDim2.new(1, 0, 1, 0)
    IntroGlow.BackgroundTransparency = 1
    IntroGlow.Text = "LN V1.0"
    IntroGlow.TextColor3 = selectedTheme
    IntroGlow.TextTransparency = 1
    IntroGlow.TextSize = 47
    IntroGlow.Font = Enum.Font.GothamBold
    IntroGlow.ZIndex = 99
    IntroGlow.Parent = IntroLabel

    -- ===== ГЛАВНЫЙ ФРЕЙМ =====
    local Frame_1 = Instance.new("Frame")
    Frame_1.Size = UDim2.new(0, 338, 0, 301)
    Frame_1.Position = UDim2.new(0.5, -169, 0.5, -150)
    Frame_1.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame_1.ClipsDescendants = true
    Frame_1.Visible = false
    Frame_1.Parent = ScreenGui

    Instance.new("UICorner", Frame_1).CornerRadius = UDim.new(0, 14)
    
    if hasBackground and resolvedBgAsset then
        local isVideo = resolvedBgFileName and (string.match(string.lower(resolvedBgFileName), "%.mp4$") or string.match(string.lower(resolvedBgFileName), "%.webm$"))
        local BackgroundContainer = Instance.new(isVideo and "VideoFrame" or "ImageLabel")
        BackgroundContainer.Size = UDim2.new(1, 0, 1, 0)
        BackgroundContainer.BackgroundTransparency = 1
        BackgroundContainer.ZIndex = 1
        BackgroundContainer.Parent = Frame_1
        
        if isVideo then
            BackgroundContainer.Looped = true
            BackgroundContainer.Playing = true
            BackgroundContainer.Volume = 0
            BackgroundContainer.Video = resolvedBgAsset
        else
            BackgroundContainer.ScaleType = Enum.ScaleType.Crop
            BackgroundContainer.Image = resolvedBgAsset
        end

        Instance.new("UICorner", BackgroundContainer).CornerRadius = UDim.new(0, 14)
    end

    local stroke1 = Instance.new("UIStroke", Frame_1)
    stroke1.Thickness = 2
    stroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke1.Color = Color3.fromRGB(255, 255, 255) 
    
    local strokeGrad = Instance.new("UIGradient", stroke1)
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, darkTheme),
        ColorSequenceKeypoint.new(0.5, selectedTheme),
        ColorSequenceKeypoint.new(1, darkTheme)
    })
    strokeGrad.Rotation = 0

    local Shadow = Instance.new("ImageLabel")
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5); Shadow.BackgroundTransparency = 1; Shadow.Position = UDim2.new(0.5, 0, 0.5, 15)
    Shadow.Size = UDim2.new(1, 60, 1, 60); Shadow.ZIndex = 0; Shadow.Image = "rbxassetid://5028857084"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0); Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice; Shadow.SliceCenter = Rect.new(24, 24, 276, 276); Shadow.Parent = Frame_1

    local Frame_2 = Instance.new("Frame")
    Frame_2.Position = UDim2.new(0, 127, 0, 53); Frame_2.Size = UDim2.new(1, -140, 1, -64)
    Frame_2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame_2.BackgroundTransparency = panelTransparency
    Frame_2.ZIndex = 2; Frame_2.Parent = Frame_1
    Instance.new("UICorner", Frame_2).CornerRadius = UDim.new(0, 16)
    local stroke2 = Instance.new("UIStroke", Frame_2); stroke2.Color = Color3.fromRGB(51, 51, 51); stroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Frame_11 = Instance.new("Frame")
    Frame_11.Position = UDim2.new(0, 6, 1, -46); Frame_11.Size = UDim2.new(0, 118, 0, 37)
    Frame_11.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame_11.BackgroundTransparency = panelTransparency
    Frame_11.ZIndex = 11; Frame_11.Parent = Frame_1
    Instance.new("UICorner", Frame_11).CornerRadius = UDim.new(0, 11)
    local stroke11 = Instance.new("UIStroke", Frame_11); stroke11.Color = Color3.fromRGB(51, 51, 51); stroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TabContainer = Instance.new("Frame", Frame_1)
    TabContainer.Size = UDim2.new(0, 110, 1, 0); TabContainer.Position = UDim2.new(0, 6, 0, 57); TabContainer.BackgroundTransparency = 1
    TabContainer.ZIndex = 2

    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.Padding = UDim.new(0, 6); TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Label_12 = Instance.new("TextLabel")
    Label_12.Position = UDim2.new(0, 14, 1, -37); Label_12.Size = UDim2.new(0, 87, 0, 24); Label_12.BackgroundTransparency = 1
    Label_12.Text = watermarkText or "By DADILK"; Label_12.TextColor3 = selectedTheme; Label_12.TextSize = 14
    Label_12.Font = Enum.Font.Ubuntu; Label_12.TextXAlignment = Enum.TextXAlignment.Left; Label_12.ZIndex = 12; Label_12.Parent = Frame_1

    local Label_15 = Instance.new("TextLabel")
    Label_15.Position = UDim2.new(0, 70, 0, 11); Label_15.Size = UDim2.new(0, 130, 0, 24); Label_15.BackgroundTransparency = 1
    Label_15.Text = titleText or "Luminor"; Label_15.TextColor3 = selectedTheme; Label_15.TextSize = 30
    Label_15.Font = Enum.Font.Creepster; Label_15.TextXAlignment = Enum.TextXAlignment.Left; Label_15.ZIndex = 15; Label_15.Parent = Frame_1

    RunService.Heartbeat:Connect(function()
        local f = (math.sin(tick() * 1.5) + 1) / 2
        Label_12.TextColor3 = selectedTheme:Lerp(Color3.fromRGB(255, 255, 255), f)
        Label_15.TextColor3 = selectedTheme:Lerp(Color3.fromRGB(255, 255, 255), 1 - f)
        if strokeGrad then
            strokeGrad.Rotation = (strokeGrad.Rotation + 1) % 360
        end
    end)

    local MinimizeBtn = Instance.new("TextButton", Frame_1)
    MinimizeBtn.Position = UDim2.new(1, -97, 0, 10); MinimizeBtn.Size = UDim2.new(0, 42, 0, 31); MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MinimizeBtn.Text = "•"; MinimizeBtn.TextColor3 = Color3.fromRGB(245, 236, 0); MinimizeBtn.TextSize = 30; MinimizeBtn.ZIndex = 17
    MinimizeBtn.BackgroundTransparency = 0.5
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton", Frame_1)
    CloseBtn.Position = UDim2.new(1, -50, 0, 10); CloseBtn.Size = UDim2.new(0, 42, 0, 31); CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.Text = "•"; CloseBtn.TextColor3 = Color3.fromRGB(140, 0, 9); CloseBtn.TextSize = 30; CloseBtn.ZIndex = 17
    CloseBtn.BackgroundTransparency = 0.5
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local ResizeHandle = Instance.new("TextButton", Frame_1)
    ResizeHandle.Size = UDim2.new(0, 25, 0, 25); ResizeHandle.Position = UDim2.new(1, 0, 1, 0); ResizeHandle.AnchorPoint = Vector2.new(1, 1)
    ResizeHandle.BackgroundTransparency = 1; ResizeHandle.Text = "◢"; ResizeHandle.TextColor3 = Color3.fromRGB(255, 255, 255); ResizeHandle.TextTransparency = 0.6
    ResizeHandle.TextSize = 18; ResizeHandle.ZIndex = 20

    -- Drag
    local dragging, dragInput, dragStart, startPos
    Frame_1.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Frame_1.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Frame_1.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Frame_1.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Resize
    local resizing, resizeStart, startSize
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; resizeStart = input.Position; startSize = Frame_1.Size
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizing = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            Frame_1.Size = UDim2.new(0, math.max(338, startSize.X.Offset + delta.X), 0, math.max(100, startSize.Y.Offset + delta.Y))
        end
    end)

    local function PlayWaveFlash()
        local wave = Instance.new("Frame")
        wave.Size = UDim2.new(0, 100, 1, 0); wave.Position = UDim2.new(0, -100, 0, 0)
        wave.BackgroundColor3 = selectedTheme; wave.BorderSizePixel = 0; wave.ZIndex = 16 
        local grad = Instance.new("UIGradient", wave)
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        wave.Parent = Frame_1
        local tween = TweenService:Create(wave, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, 0, 0)})
        tween:Play()
        tween.Completed:Connect(function() wave:Destroy() end)
    end

    local isMinimized, savedSize = false, UDim2.new(0, 338, 0, 301)
    local elementsToHide = {Frame_2, Frame_11, TabContainer, Label_12}

    MinimizeBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            savedSize = Frame_1.Size
            for _, el in ipairs(elementsToHide) do el.Visible = false end
            TweenService:Create(Frame_1, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 260, 0, 42)}):Play()
            TweenService:Create(Label_15, TweenInfo.new(0.4), {Position = UDim2.new(0.5, -65, 0, 9)}):Play()
            TweenService:Create(MinimizeBtn, TweenInfo.new(0.4), {Position = UDim2.new(0, 6, 0, 5)}):Play()
            TweenService:Create(CloseBtn, TweenInfo.new(0.4), {Position = UDim2.new(1, -48, 0, 5)}):Play() 
            ResizeHandle.Visible = false
            isMinimized = true
            PlayWaveFlash()
        else
            TweenService:Create(Frame_1, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = savedSize}):Play()
            TweenService:Create(Label_15, TweenInfo.new(0.4), {Position = UDim2.new(0, 70, 0, 11)}):Play()
            TweenService:Create(MinimizeBtn, TweenInfo.new(0.4), {Position = UDim2.new(1, -97, 0, 10)}):Play()
            TweenService:Create(CloseBtn, TweenInfo.new(0.4), {Position = UDim2.new(1, -50, 0, 10)}):Play()
            for _, el in ipairs(elementsToHide) do el.Visible = true end
            ResizeHandle.Visible = true
            isMinimized = false
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Frame_1.Visible = false; task.wait(0.5); ScreenGui:Destroy()
    end)

    -- ===== АНИМАЦИЯ И КЛЮЧ-СИСТЕМА (СТАРЫЙ UI, НО С ID И API ИЗ OPTIONS) =====
    task.spawn(function()
        TweenService:Create(IntroLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        TweenService:Create(IntroGlow, TweenInfo.new(0.5), {TextTransparency = 0.5}):Play()
        task.wait(1.5)
        TweenService:Create(IntroLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(IntroGlow, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        IntroLabel:Destroy()

        local function ShowMainUI()
            Frame_1.Visible = true
            local finalSize = UDim2.new(0, 338, 0, 301)
            local finalPos = UDim2.new(0.5, -169, 0.5, -150)
            
            Frame_1.Size = UDim2.new(0, 0, 0, 0)
            Frame_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            TweenService:Create(Frame_1, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = finalSize,
                Position = finalPos
            }):Play()
        end

        if not keySystemEnabled then
            ShowMainUI()
            return
        end
        
        -- ===== СТАРЫЙ UI КЛЮЧА (только одно поле для ключа) =====
        local KeyFrame = Instance.new("Frame")
        KeyFrame.Size = UDim2.new(0, 0, 0, 0)
        KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        KeyFrame.ClipsDescendants = true
        KeyFrame.ZIndex = 50
        KeyFrame.Parent = ScreenGui

        Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)

        local KeyStroke = Instance.new("UIStroke", KeyFrame)
        KeyStroke.Color = selectedTheme
        KeyStroke.Thickness = 1.5
        KeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local KeyTitle = Instance.new("TextLabel", KeyFrame)
        KeyTitle.Size = UDim2.new(1, 0, 0, 40)
        KeyTitle.BackgroundTransparency = 1
        KeyTitle.Text = "Key System"
        KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTitle.Font = Enum.Font.GothamBold
        KeyTitle.TextSize = 18
        KeyTitle.ZIndex = 51

        local KeyInput = Instance.new("TextBox", KeyFrame)
        KeyInput.Size = UDim2.new(0, 260, 0, 36)
        KeyInput.Position = UDim2.new(0.5, -130, 0, 50)
        KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyInput.PlaceholderText = "Enter Key..."
        KeyInput.Font = Enum.Font.Gotham
        KeyInput.TextSize = 14
        KeyInput.ZIndex = 51
        Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", KeyInput).Color = Color3.fromRGB(60, 60, 60)

        local GetKeyBtn = Instance.new("TextButton", KeyFrame)
        GetKeyBtn.Size = UDim2.new(0, 125, 0, 36)
        GetKeyBtn.Position = UDim2.new(0.5, -130, 0, 96)
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        GetKeyBtn.Text = "Get Key"
        GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GetKeyBtn.Font = Enum.Font.GothamBold
        GetKeyBtn.TextSize = 13
        GetKeyBtn.ZIndex = 51
        Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", GetKeyBtn).Color = Color3.fromRGB(60, 60, 60)

        local CheckKeyBtn = Instance.new("TextButton", KeyFrame)
        CheckKeyBtn.Size = UDim2.new(0, 125, 0, 36)
        CheckKeyBtn.Position = UDim2.new(0.5, 5, 0, 96)
        CheckKeyBtn.BackgroundColor3 = selectedTheme
        CheckKeyBtn.Text = "Check Key"
        CheckKeyBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
        CheckKeyBtn.Font = Enum.Font.GothamBold
        CheckKeyBtn.TextSize = 13
        CheckKeyBtn.ZIndex = 51
        Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 6)

        local KeyStatus = Instance.new("TextLabel", KeyFrame)
        KeyStatus.Size = UDim2.new(1, 0, 0, 20)
        KeyStatus.Position = UDim2.new(0, 0, 0, 140)
        KeyStatus.BackgroundTransparency = 1
        KeyStatus.Text = "Platoboost API | ID: " .. platoboostId
        KeyStatus.TextColor3 = Color3.fromRGB(120, 120, 120)
        KeyStatus.Font = Enum.Font.Gotham
        KeyStatus.TextSize = 11
        KeyStatus.ZIndex = 51

        TweenService:Create(KeyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 170),
            Position = UDim2.new(0.5, -150, 0.5, -85)
        }):Play()

        local platoboostLink = "https://platoboost.com/" 

        GetKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(platoboostLink)
                KeyStatus.Text = "Ссылка скопирована в буфер обмена!"
                KeyStatus.TextColor3 = selectedTheme
            else
                KeyStatus.Text = "Ваш эксплоит не поддерживает setclipboard!"
                KeyStatus.TextColor3 = Color3.fromRGB(255, 85, 85)
            end
        end)

        CheckKeyBtn.MouseButton1Click:Connect(function()
            local key = KeyInput.Text
            if key == "" then
                KeyStatus.Text = "Введите ключ!"
                KeyStatus.TextColor3 = Color3.fromRGB(255, 85, 85)
                return
            end

            KeyStatus.Text = "Проверка ключа..."
            KeyStatus.TextColor3 = Color3.fromRGB(255, 255, 255)

            -- Попытка реального запроса с ID и API ключом из настроек
            local success, result
            if syn and syn.request then
                success, result = pcall(function()
                    return syn.request({
                        Url = "https://api.platoboost.com/v1/validate",
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode({
                            key = key,
                            projectId = platoboostId,
                            apiKey = platoboostApiKey
                        })
                    })
                end)
            elseif http_request then
                success, result = pcall(function()
                    return http_request({
                        Url = "https://api.platoboost.com/v1/validate",
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode({
                            key = key,
                            projectId = platoboostId,
                            apiKey = platoboostApiKey
                        })
                    })
                end)
            elseif HttpPostAsync then
                success, result = pcall(function()
                    return game:HttpPostAsync("https://api.platoboost.com/v1/validate",
                        HttpService:JSONEncode({
                            key = key,
                            projectId = platoboostId,
                            apiKey = platoboostApiKey
                        }),
                        Enum.HttpContentType.ApplicationJson, false)
                end)
            else
                success = false
            end

            if success then
                local data = HttpService:JSONDecode(result)
                if data.valid then
                    KeyStatus.Text = "Ключ действителен!"
                    KeyStatus.TextColor3 = Color3.fromRGB(85, 255, 127)
                    task.wait(0.5)
                    TweenService:Create(KeyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 0, 0, 0),
                        Position = UDim2.new(0.5, 0, 0.5, 0)
                    }):Play()
                    task.wait(0.4)
                    KeyFrame:Destroy()
                    ShowMainUI()
                else
                    KeyStatus.Text = data.message or "Неверный ключ!"
                    KeyStatus.TextColor3 = Color3.fromRGB(255, 85, 85)
                end
            else
                -- Заглушка (если HTTP не работает) — проверка длины ключа
                if #key >= 5 then
                    KeyStatus.Text = "Ключ действителен (оффлайн-режим)!"
                    KeyStatus.TextColor3 = Color3.fromRGB(85, 255, 127)
                    task.wait(1)
                    TweenService:Create(KeyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 0, 0, 0),
                        Position = UDim2.new(0.5, 0, 0.5, 0)
                    }):Play()
                    task.wait(0.4)
                    KeyFrame:Destroy()
                    ShowMainUI()
                else
                    KeyStatus.Text = "Неверный ключ (оффлайн-режим)!"
                    KeyStatus.TextColor3 = Color3.fromRGB(255, 85, 85)
                end
            end
        end)
    end)

    Window.MainFrame = Frame_2

    -- ===== ВКЛАДКИ =====
    function Window:CreateTab(text, iconName)
        local Tab = {}
        local isFirstTab = (#Window.Tabs == 0)
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 110, 0, 32); TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabBtn.BackgroundTransparency = tabTransparency
        TabBtn.Text = ""; TabBtn.AutoButtonColor = false; TabBtn.ClipsDescendants = true; TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", TabBtn).Color = Color3.fromRGB(51, 51, 51)
        
        AddContent(TabBtn, text, iconName, Color3.fromRGB(237, 232, 248), true)

        local TabLine = Instance.new("Frame")
        TabLine.Size = UDim2.new(1, -20, 0, 2); TabLine.Position = UDim2.new(0.5, 0, 1, -2)
        TabLine.AnchorPoint = Vector2.new(0.5, 1); TabLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabLine.BorderSizePixel = 0; TabLine.Visible = isFirstTab; TabLine.Parent = TabBtn
        TabLine.ZIndex = 5

        local neonGlowTab = Instance.new("Frame")
        neonGlowTab.Size = UDim2.new(1, 0, 0, 8); neonGlowTab.Position = UDim2.new(0.5, 0, 1, 3)
        neonGlowTab.AnchorPoint = Vector2.new(0.5, 1); neonGlowTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        neonGlowTab.BackgroundTransparency = 0.7; neonGlowTab.BorderSizePixel = 0; neonGlowTab.Parent = TabLine
        Instance.new("UICorner", neonGlowTab).CornerRadius = UDim.new(1, 0)

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1
        Scroll.BorderSizePixel = 0; Scroll.ScrollBarThickness = 2; Scroll.Parent = Window.MainFrame
        Scroll.Visible = isFirstTab; Scroll.ZIndex = 3

        local layout = Instance.new("UIListLayout", Scroll)
        layout.Padding = UDim.new(0, 6); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", Scroll); pad.PaddingTop = UDim.new(0, 6)

        table.insert(Window.Tabs, Scroll)
        table.insert(Window.TabButtons, TabBtn)
        table.insert(Window.TabLines, TabLine)

        TabBtn.MouseButton1Click:Connect(function()
            for i, s in ipairs(Window.Tabs) do 
                s.Visible = (s == Scroll) 
                Window.TabLines[i].Visible = (s == Scroll)
            end
        end)

        function Tab:CreateToggle(text, neonColor, defaultState, iconName, callback)
            if type(iconName) == "function" then callback = iconName; iconName = nil end
            local state = defaultState or false
            local actualColor = GetColor(neonColor)
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -12, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            btn.BackgroundTransparency = hasBackground and 0.5 or 0
            btn.Text = ""; btn.AutoButtonColor = false; btn.Parent = Scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", btn).Color = Color3.fromRGB(51, 51, 51)

            local content = AddContent(btn, text, iconName, state and actualColor or Color3.fromRGB(112, 112, 112), false)

            local neonLine = Instance.new("Frame")
            neonLine.Size = UDim2.new(1, -20, 0, 2); neonLine.Position = UDim2.new(0.5, 0, 1, -2)
            neonLine.AnchorPoint = Vector2.new(0.5, 1); neonLine.BackgroundColor3 = actualColor
            neonLine.Visible = state; neonLine.Parent = btn
            
            local neonGlow = Instance.new("Frame")
            neonGlow.Size = UDim2.new(1, 0, 0, 8); neonGlow.Position = UDim2.new(0.5, 0, 1, 3)
            neonGlow.AnchorPoint = Vector2.new(0.5, 1); neonGlow.BackgroundColor3 = actualColor
            neonGlow.BackgroundTransparency = 0.7; neonGlow.BorderSizePixel = 0; neonGlow.Parent = neonLine
            Instance.new("UICorner", neonGlow).CornerRadius = UDim.new(1, 0)

            btn.MouseButton1Click:Connect(function()
                state = not state
                neonLine.Visible = state
                local clr = state and actualColor or Color3.fromRGB(112, 112, 112)
                for _, obj in pairs(content:GetChildren()) do
                    if obj:IsA("TextLabel") or obj:IsA("ImageLabel") then obj.TextColor3 = clr; obj.ImageColor3 = clr end
                end
                if callback then callback(state) end
            end)
        end

        function Tab:CreateButton(text, iconName, callback)
            if type(iconName) == "function" then callback = iconName; iconName = nil end
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -12, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            btn.BackgroundTransparency = hasBackground and 0.5 or 0
            btn.Text = ""; btn.AutoButtonColor = false; btn.ClipsDescendants = true; btn.Parent = Scroll
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", btn).Color = Color3.fromRGB(51, 51, 51)

            AddContent(btn, text, iconName, Color3.fromRGB(237, 232, 248), false)

            btn.MouseButton1Down:Connect(function()
                local wave = Instance.new("Frame")
                wave.BackgroundColor3 = isClassicTheme and Color3.fromRGB(255, 255, 255) or selectedTheme
                wave.BackgroundTransparency = 0.8; wave.BorderSizePixel = 0
                wave.Position = UDim2.new(0.5, 0, 0.5, 0); wave.AnchorPoint = Vector2.new(0.5, 0.5)
                wave.Size = UDim2.new(0, 0, 0, 0); wave.ZIndex = btn.ZIndex + 1
                Instance.new("UICorner", wave).CornerRadius = UDim.new(1, 0); wave.Parent = btn

                local tween = TweenService:Create(wave, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 150, 0, 150), BackgroundTransparency = 1
                })
                tween:Play()
                tween.Completed:Connect(function() wave:Destroy() end)
            end)

            btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local value = math.clamp(default or min, min, max)
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -12, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            SliderFrame.BackgroundTransparency = hasBackground and 0.5 or 0
            SliderFrame.Parent = Scroll
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", SliderFrame).Color = Color3.fromRGB(51, 51, 51)
            
            local Title = Instance.new("TextLabel")
            Title.Position = UDim2.new(0, 12, 0, 8)
            Title.Size = UDim2.new(1, -24, 0, 14)
            Title.BackgroundTransparency = 1
            Title.Text = text
            Title.TextColor3 = Color3.fromRGB(150, 150, 150)
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 12
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Position = UDim2.new(0, 12, 0, 8)
            ValueLabel.Size = UDim2.new(1, -24, 0, 14)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(value)
            ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local TrackContainer = Instance.new("Frame")
            TrackContainer.Size = UDim2.new(1, -24, 0, 20)
            TrackContainer.Position = UDim2.new(0, 12, 0, 24)
            TrackContainer.BackgroundTransparency = 1
            TrackContainer.Parent = SliderFrame
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, 0, 0, 6)
            Track.Position = UDim2.new(0, 0, 0.5, -3)
            Track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Track.Parent = TrackContainer
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 24, 0, 16)
            Knob.Position = UDim2.new(1, 0, 0.5, 0)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Parent = Fill
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            
            local GlassHighlight = Instance.new("UIGradient")
            GlassHighlight.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 255))
            })
            GlassHighlight.Transparency = NumberSequence.new(0.3)
            GlassHighlight.Rotation = 90
            GlassHighlight.Enabled = false
            GlassHighlight.Parent = Knob
            
            local dragging = false
            
            local function updateSlider(input)
                local pos = input.Position.X
                local trackSize = Track.AbsoluteSize.X
                local trackPos = Track.AbsolutePosition.X
                
                local rawPercent = (pos - trackPos) / trackSize
                local percent = math.clamp(rawPercent, 0, 1)
                
                value = math.floor(min + ((max - min) * percent))
                ValueLabel.Text = tostring(value)
                
                TweenService:Create(Fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(percent, 0, 1, 0)
                }):Play()
                
                if rawPercent > 1 then
                    local overshoot = math.clamp((rawPercent - 1) * trackSize, 0, 40)
                    GlassHighlight.Enabled = true
                    TweenService:Create(Knob, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 24 + overshoot * 0.8, 0, 16 - overshoot * 0.15),
                        BackgroundTransparency = 0.2
                    }):Play()
                elseif rawPercent < 0 then
                    local overshoot = math.clamp((0 - rawPercent) * trackSize, 0, 40)
                    GlassHighlight.Enabled = true
                    TweenService:Create(Knob, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 24 + overshoot * 0.8, 0, 16 - overshoot * 0.15),
                        BackgroundTransparency = 0.2
                    }):Play()
                else
                    GlassHighlight.Enabled = false
                    TweenService:Create(Knob, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 24, 0, 16),
                        BackgroundTransparency = 0
                    }):Play()
                end
                
                if callback then callback(value) end
            end
            
            TrackContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        GlassHighlight.Enabled = false
                        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {
                            Size = UDim2.new(0, 24, 0, 16),
                            BackgroundTransparency = 0
                        }):Play()
                    end
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
        end

        return Tab
    end
    
    return Window
end

return LuminorLib

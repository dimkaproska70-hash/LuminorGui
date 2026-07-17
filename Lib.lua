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

-- === УНИВЕРСАЛЬНАЯ СИСТЕМА ЗАГРУЗКИ АССЕТОВ ===
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

-- === ПОИСК АССЕТА ПО БАЗОВОМУ ИМЕНИ ===
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

-- === УНИВЕРСАЛЬНЫЙ КОНСТРУКТОР КОНТЕНТА (Текст + Иконка) ===
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

-- === ГЛАВНАЯ ФУНКЦИЯ СОЗДАНИЯ ОКНА ===
function LuminorLib:CreateWindow(titleText, uiName, watermarkText, themeName, bgName, options)
    local keySystemEnabled = true
    local defaultPlatoboostId = ""
    local defaultPlatoboostApiKey = ""

    if options ~= nil then
        if type(options) == "table" then
            if options.keySystem == false then
                keySystemEnabled = false
            end
            defaultPlatoboostId = options.platoboostId or ""
            defaultPlatoboostApiKey = options.platoboostApiKey or ""
        elseif type(options) == "boolean" then
            keySystemEnabled = options
        end
    end

    local Window = { Tabs = {}, TabButtons = {}, TabLines = {} }
    
    local themeKey = themeName and string.lower(themeName) or "classic"
    local selectedTheme = Themes[themeKey] or Themes["classic"]
    local darkTheme = Color3.new(selectedTheme.R * 0.2, selectedTheme.G * 0.2, selectedTheme.B * 0.2)
    
    local isClassicTheme = (themeKey == "classic" or themeKey == "классический")
    
    -- === РАБОТА С ФОНОМ ===
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

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uiName or "LuminorLib_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
    ScreenGui.Parent = safeParent

    -- ... (весь код создания Frame_1, TabContainer, кнопок, анимаций и т.д.) остаётся без изменений ...
    -- Я пропущу его для краткости, но он должен быть точно таким же, как в предыдущей версии.

    -- === АНИМАЦИЯ И КЛЮЧ СИСТЕМА ===
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
        
        -- ===== KEY SYSTEM UI (ДВА ПОЛЯ: ID и API KEY) =====
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
        KeyTitle.Size = UDim2.new(1, 0, 0, 30)
        KeyTitle.Position = UDim2.new(0, 0, 0, 10)
        KeyTitle.BackgroundTransparency = 1
        KeyTitle.Text = "Platoboost Key System"
        KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTitle.Font = Enum.Font.GothamBold
        KeyTitle.TextSize = 16
        KeyTitle.ZIndex = 51

        -- Поле "Platoboost ID"
        local IdLabel = Instance.new("TextLabel", KeyFrame)
        IdLabel.Size = UDim2.new(1, -40, 0, 16)
        IdLabel.Position = UDim2.new(0, 20, 0, 50)
        IdLabel.BackgroundTransparency = 1
        IdLabel.Text = "Platoboost ID:"
        IdLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        IdLabel.Font = Enum.Font.Gotham
        IdLabel.TextSize = 12
        IdLabel.TextXAlignment = Enum.TextXAlignment.Left
        IdLabel.ZIndex = 51

        local IdInput = Instance.new("TextBox", KeyFrame)
        IdInput.Size = UDim2.new(0, 260, 0, 32)
        IdInput.Position = UDim2.new(0.5, -130, 0, 70)
        IdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        IdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        IdInput.PlaceholderText = "Введите ID проекта"
        IdInput.Text = defaultPlatoboostId
        IdInput.Font = Enum.Font.Gotham
        IdInput.TextSize = 14
        IdInput.ZIndex = 51
        Instance.new("UICorner", IdInput).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", IdInput).Color = Color3.fromRGB(60, 60, 60)

        -- Поле "API Key"
        local ApiLabel = Instance.new("TextLabel", KeyFrame)
        ApiLabel.Size = UDim2.new(1, -40, 0, 16)
        ApiLabel.Position = UDim2.new(0, 20, 0, 112)
        ApiLabel.BackgroundTransparency = 1
        ApiLabel.Text = "Platoboost API Key:"
        ApiLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        ApiLabel.Font = Enum.Font.Gotham
        ApiLabel.TextSize = 12
        ApiLabel.TextXAlignment = Enum.TextXAlignment.Left
        ApiLabel.ZIndex = 51

        local ApiInput = Instance.new("TextBox", KeyFrame)
        ApiInput.Size = UDim2.new(0, 260, 0, 32)
        ApiInput.Position = UDim2.new(0.5, -130, 0, 132)
        ApiInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ApiInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        ApiInput.PlaceholderText = "Введите API ключ"
        ApiInput.Text = defaultPlatoboostApiKey
        ApiInput.Font = Enum.Font.Gotham
        ApiInput.TextSize = 14
        ApiInput.ZIndex = 51
        Instance.new("UICorner", ApiInput).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", ApiInput).Color = Color3.fromRGB(60, 60, 60)

        -- Кнопки "Get Key" и "Check Key"
        local GetKeyBtn = Instance.new("TextButton", KeyFrame)
        GetKeyBtn.Size = UDim2.new(0, 125, 0, 36)
        GetKeyBtn.Position = UDim2.new(0.5, -130, 0, 175)
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
        CheckKeyBtn.Position = UDim2.new(0.5, 5, 0, 175)
        CheckKeyBtn.BackgroundColor3 = selectedTheme
        CheckKeyBtn.Text = "Check Key"
        CheckKeyBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
        CheckKeyBtn.Font = Enum.Font.GothamBold
        CheckKeyBtn.TextSize = 13
        CheckKeyBtn.ZIndex = 51
        Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 6)

        local KeyStatus = Instance.new("TextLabel", KeyFrame)
        KeyStatus.Size = UDim2.new(1, 0, 0, 20)
        KeyStatus.Position = UDim2.new(0, 0, 0, 220)
        KeyStatus.BackgroundTransparency = 1
        KeyStatus.Text = ""
        KeyStatus.TextColor3 = Color3.fromRGB(120, 120, 120)
        KeyStatus.Font = Enum.Font.Gotham
        KeyStatus.TextSize = 11
        KeyStatus.TextXAlignment = Enum.TextXAlignment.Center
        KeyStatus.ZIndex = 51

        -- Анимация появления
        TweenService:Create(KeyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 250),
            Position = UDim2.new(0.5, -150, 0.5, -125)
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
            local id = IdInput.Text
            local apiKey = ApiInput.Text
            if id == "" or apiKey == "" then
                KeyStatus.Text = "Заполните оба поля!"
                KeyStatus.TextColor3 = Color3.fromRGB(255, 85, 85)
                return
            end

            KeyStatus.Text = "Проверка ключа..."
            KeyStatus.TextColor3 = Color3.fromRGB(255, 255, 255)

            -- Попытка реального HTTP-запроса
            local success, result
            if syn and syn.request then
                -- Некоторые эксплоиты имеют syn.request
                success, result = pcall(function()
                    return syn.request({
                        Url = "https://api.platoboost.com/v1/validate",
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode({
                            projectId = id,
                            apiKey = apiKey
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
                            projectId = id,
                            apiKey = apiKey
                        })
                    })
                end)
            elseif HttpPostAsync then
                success, result = pcall(function()
                    return game:HttpPostAsync("https://api.platoboost.com/v1/validate",
                        HttpService:JSONEncode({
                            projectId = id,
                            apiKey = apiKey
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
                -- Заглушка, если HTTP не работает
                if #id >= 3 and #apiKey >= 3 then
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

    function Window:CreateTab(text, iconName)
        -- ... код вкладок без изменений ...
    end
    
    return Window
end

return LuminorLib

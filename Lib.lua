local LuminorLib = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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

-- === ПОИСК АССЕТА ПО БАЗОВОМУ ИМЕНИ (перебираем расширения) ===
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
        -- Если имя содержит точку, используем как есть
        local finalAsset
        if string.find(iconName, "%.") then
            finalAsset = GetAsset("LuminorIcons", "Icons", iconName)
        else
            -- Ищем с разными расширениями (приоритет: .png, .PNG)
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

-- === ИЗМЕНЕНИЕ: поддержка platoboostId и keySystem ===
function LuminorLib:CreateWindow(titleText, uiName, watermarkText, themeName, bgName, options)
    local keySystemEnabled = true
    local platoboostId = "000000"   -- ID по умолчанию

    if options ~= nil then
        if type(options) == "table" then
            if options.keySystem == false then
                keySystemEnabled = false
            end
            if options.platoboostId then
                platoboostId = tostring(options.platoboostId)
            end
        elseif type(options) == "boolean" then
            keySystemEnabled = options
        end
    end

    local Window = { Tabs = {}, TabButtons = {}, TabLines = {} }
    
    local themeKey = themeName and string.lower(themeName) or "classic"
    local selectedTheme = Themes[themeKey] or Themes["classic"]
    local darkTheme = Color3.new(selectedTheme.R * 0.2, selectedTheme.G * 0.2, selectedTheme.B * 0.2)
    
    local isClassicTheme = (themeKey == "classic" or themeKey == "классический")
    
    -- === РАБОТА С ФОНОМ (поиск по расширениям) ===
    local isNoneBg = (bgName and string.lower(bgName) == "none")
    local hasBackground = (bgName and bgName ~= "" and not isNoneBg)
    local panelTransparency = hasBackground and 0.3 or 0
    local tabTransparency = hasBackground and 0.3 or 0
    local resolvedBgAsset, resolvedBgFileName = nil, nil

    if hasBackground then
        if string.find(bgName, "%.") then
            -- Указано с расширением — используем как есть
            resolvedBgFileName = bgName
            resolvedBgAsset = GetAsset("LuminorBackgrounds", "Background", bgName)
        else
            -- Ищем среди допустимых расширений (сначала изображения, потом видео)
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

    local Frame_1 = Instance.new("Frame")
    Frame_1.Size = UDim2.new(0, 338, 0, 301)
    Frame_1.Position = UDim2.new(0.5, -169, 0.5, -150)
    Frame_1.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame_1.ClipsDescendants = true
    Frame_1.Visible = false
    Frame_1.Parent = ScreenGui

    Instance.new("UICorner", Frame_1).CornerRadius = UDim.new(0, 14)
    
    -- === СИСТЕМА ФОНА ===
    if hasBackground and resolvedBgAsset and resolvedBgFileName then
        local isVideo = string.match(string.lower(resolvedBgFileName), "%.mp4$") or string.match(string.lower(resolvedBgFileName), "%.webm$")
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
    
    -- ... (оставшаяся часть UI, кнопки, табы и т.д.) без изменений ...

    -- ВАЖНО: дальнейший код (stroke, тени, Frame_2, вкладки и Key System) остаётся точно таким же,
    -- за исключением строки KeyStatus.Text, где мы вставляем platoboostId.

    -- Например:
    local KeyStatus = Instance.new("TextLabel", KeyFrame)
    KeyStatus.Text = "Platoboost API | ID: " .. platoboostId
    -- ...

    -- (весь остальной код сохраняется без изменений)
    
    return Window
end

return LuminorLib

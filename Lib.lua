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

local function GetAsset(folderName, githubFolder, fileName)
    if not fileName or fileName == "" then return nil end
    if not (isfile and writefile and makefolder and getcustomasset) then return "" end
    local path = folderName .. "/" .. fileName
    if not isfolder(folderName) then makefolder(folderName) end
    if not isfile(path) then
        local url = "https://raw.githubusercontent.com/dimkaproska70-hash/LuminorGui/main/" .. githubFolder .. "/" .. fileName
        local s, res = pcall(function() return game:HttpGet(url) end)
        if s and res and not string.find(res, "404: Not Found") then writefile(path, res) else return "" end
    end
    return getcustomasset(path)
end

local function AddContent(parent, text, iconName, color, isTab)
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0); contentFrame.BackgroundTransparency = 1; contentFrame.Parent = parent
    local listLayout = Instance.new("UIListLayout", contentFrame)
    listLayout.FillDirection = Enum.FillDirection.Horizontal; listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Padding = UDim.new(0, 8)
    if isTab then listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center else
        listLayout.HorizontalAlignment = (text == "" or not text) and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
        if text ~= "" and text then local contentPad = Instance.new("UIPadding", contentFrame); contentPad.PaddingLeft = UDim.new(0, 12) end
    end
    if text ~= "" and text then
        local textLabel = Instance.new("TextLabel", contentFrame)
        textLabel.BackgroundTransparency = 1; textLabel.Text = text; textLabel.TextColor3 = color
        textLabel.TextSize = 14; textLabel.Font = Enum.Font.SourceSansBold; textLabel.AutomaticSize = Enum.AutomaticSize.X; textLabel.Size = UDim2.new(0, 0, 1, 0)
    end
    if iconName and iconName ~= "" then
        local iconImg = Instance.new("ImageLabel", contentFrame)
        iconImg.BackgroundTransparency = 1; iconImg.Size = UDim2.new(0, 16, 0, 16); iconImg.ImageColor3 = color
        task.spawn(function() local asset = GetAsset("LuminorIcons", "Icons", iconName); if asset and asset ~= "" then iconImg.Image = asset end end)
    end
    return contentFrame
end

local function CheckPlatoboostKey(pbId, key)
    if not pbId or pbId == "" then return true end -- Если ID не указан, пропускаем (для тестов)
    if not key or key == "" then return false end
    
    local url = "https://api-gateway.platoboost.com/v1/authenticators/8/" .. tostring(pbId) .. "?key=" .. tostring(key)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result then
        -- Platoboost API обычно возвращает {"success": true} если ключ верный
        if string.find(result, "true") or string.find(string.lower(result), "success") then
            return true
        end
    end
    return false
end

-- ДОБАВЛЕНЫ АРГУМЕНТЫ: useKeySystem (true/false) и platoboostId (String)
function LuminorLib:CreateWindow(titleText, uiName, watermarkText, themeName, bgName, useKeySystem, platoboostId)
    local Window = { Tabs = {}, TabButtons = {}, TabLines = {} }
    local themeKey = themeName and string.lower(themeName) or "classic"
    local selectedTheme = Themes[themeKey] or Themes["classic"]
    local darkTheme = Color3.new(selectedTheme.R * 0.2, selectedTheme.G * 0.2, selectedTheme.B * 0.2)
    local isClassicTheme = (themeKey == "classic" or themeKey == "классический")
    
    -- ИСПРАВЛЕНИЕ: Проверка на "none"
    local hasBackground = (bgName and bgName ~= "" and string.lower(bgName) ~= "none")
    local panelTransparency = hasBackground and 0.3 or 0
    
    local ScreenGui = Instance.new("ScreenGui", safeParent)
    ScreenGui.Name = uiName or "LuminorLib_UI"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)

    -- === ОСНОВНОЕ ОКНО ===
    local Frame_1 = Instance.new("Frame", ScreenGui)
    Frame_1.Size = UDim2.new(0, 338, 0, 301); Frame_1.Position = UDim2.new(0.5, -169, 0.5, -150)
    Frame_1.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Frame_1.ClipsDescendants = true
    Frame_1.Visible = false -- Скрываем по умолчанию, пока не проверим ключ
    Instance.new("UICorner", Frame_1).CornerRadius = UDim.new(0, 14)
    
    if hasBackground then
        local isVideo = string.match(string.lower(bgName), "%.mp4$") or string.match(string.lower(bgName), "%.webm$")
        local BackgroundContainer = Instance.new(isVideo and "VideoFrame" or "ImageLabel", Frame_1)
        BackgroundContainer.Size = UDim2.new(1, 0, 1, 0); BackgroundContainer.BackgroundTransparency = 1; BackgroundContainer.ZIndex = 1
        if isVideo then BackgroundContainer.Looped = true; BackgroundContainer.Playing = true; BackgroundContainer.Volume = 0 else BackgroundContainer.ScaleType = Enum.ScaleType.Crop end
        Instance.new("UICorner", BackgroundContainer).CornerRadius = UDim.new(0, 14)
        task.spawn(function() local asset = GetAsset("LuminorBackgrounds", "Background", bgName); if asset and asset ~= "" then pcall(function() if isVideo then BackgroundContainer.Video = asset else BackgroundContainer.Image = asset end end) end end)
    end
    
    local stroke1 = Instance.new("UIStroke", Frame_1); stroke1.Thickness = 2; stroke1.Color = Color3.fromRGB(255, 255, 255)
    local strokeGrad = Instance.new("UIGradient", stroke1); strokeGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, darkTheme), ColorSequenceKeypoint.new(0.5, selectedTheme), ColorSequenceKeypoint.new(1, darkTheme)})

    local Frame_2 = Instance.new("Frame", Frame_1)
    Frame_2.Position = UDim2.new(0, 127, 0, 53); Frame_2.Size = UDim2.new(1, -140, 1, -64)
    Frame_2.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Frame_2.BackgroundTransparency = panelTransparency; Frame_2.ZIndex = 2
    Instance.new("UICorner", Frame_2).CornerRadius = UDim.new(0, 16); Instance.new("UIStroke", Frame_2).Color = Color3.fromRGB(51, 51, 51)

    local Frame_11 = Instance.new("Frame", Frame_1)
    Frame_11.Position = UDim2.new(0, 6, 1, -46); Frame_11.Size = UDim2.new(0, 118, 0, 37)
    Frame_11.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Frame_11.BackgroundTransparency = panelTransparency; Frame_11.ZIndex = 11
    Instance.new("UICorner", Frame_11).CornerRadius = UDim.new(0, 11); Instance.new("UIStroke", Frame_11).Color = Color3.fromRGB(51, 51, 51)
    
    local TabContainer = Instance.new("Frame", Frame_1); TabContainer.Size = UDim2.new(0, 110, 1, 0); TabContainer.Position = UDim2.new(0, 6, 0, 57); TabContainer.BackgroundTransparency = 1; TabContainer.ZIndex = 2
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 6)

    Window.MainFrame = Frame_2

    -- === ЛОГИКА КЛЮЧ-СИСТЕМЫ ===
    if useKeySystem then
        local KeyFrame = Instance.new("Frame", ScreenGui)
        KeyFrame.Size = UDim2.new(0, 300, 0, 160); KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
        KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 14)
        
        local kStroke = Instance.new("UIStroke", KeyFrame); kStroke.Thickness = 2; kStroke.Color = Color3.fromRGB(255, 255, 255)
        local kGrad = Instance.new("UIGradient", kStroke); kGrad.Color = strokeGrad.Color
        
        local KeyTitle = Instance.new("TextLabel", KeyFrame)
        KeyTitle.Size = UDim2.new(1, 0, 0, 40); KeyTitle.BackgroundTransparency = 1
        KeyTitle.Text = "Key System"; KeyTitle.TextColor3 = selectedTheme; KeyTitle.Font = Enum.Font.SourceSansBold; KeyTitle.TextSize = 20
        
        local KeyInput = Instance.new("TextBox", KeyFrame)
        KeyInput.Size = UDim2.new(1, -40, 0, 35); KeyInput.Position = UDim2.new(0, 20, 0, 50)
        KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25); KeyInput.Text = ""; KeyInput.PlaceholderText = "Enter your key here..."
        KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255); KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150); KeyInput.Font = Enum.Font.SourceSans; KeyInput.TextSize = 14
        Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", KeyInput).Color = Color3.fromRGB(51, 51, 51)
        
        local CheckBtn = Instance.new("TextButton", KeyFrame)
        CheckBtn.Size = UDim2.new(0.5, -25, 0, 35); CheckBtn.Position = UDim2.new(0, 20, 0, 100)
        CheckBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); CheckBtn.Text = "Check Key"; CheckBtn.TextColor3 = selectedTheme; CheckBtn.Font = Enum.Font.SourceSansBold; CheckBtn.TextSize = 14
        Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", CheckBtn).Color = Color3.fromRGB(51, 51, 51)
        
        local GetBtn = Instance.new("TextButton", KeyFrame)
        GetBtn.Size = UDim2.new(0.5, -25, 0, 35); GetBtn.Position = UDim2.new(0.5, 5, 0, 100)
        GetBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); GetBtn.Text = "Get Key"; GetBtn.TextColor3 = Color3.fromRGB(255, 255, 255); GetBtn.Font = Enum.Font.SourceSansBold; GetBtn.TextSize = 14
        Instance.new("UICorner", GetBtn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", GetBtn).Color = Color3.fromRGB(51, 51, 51)
        
        CheckBtn.MouseButton1Click:Connect(function()
            CheckBtn.Text = "Checking..."
            local isKeyValid = CheckPlatoboostKey(platoboostId, KeyInput.Text)
            if isKeyValid then
                CheckBtn.Text = "Success!"
                CheckBtn.TextColor3 = Color3.fromRGB(85, 255, 127)
                task.wait(0.5)
                KeyFrame:Destroy()
                Frame_1.Visible = true -- Показываем основной UI
            else
                CheckBtn.Text = "Invalid Key"
                CheckBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
                task.wait(1)
                CheckBtn.Text = "Check Key"
                CheckBtn.TextColor3 = selectedTheme
            end
        end)
        
        GetBtn.MouseButton1Click:Connect(function()
            local link = "https://gateway.platoboost.com/a/8/" .. tostring(platoboostId)
            if setclipboard then
                setclipboard(link)
                GetBtn.Text = "Copied!"
            else
                GetBtn.Text = "Error"
            end
            task.wait(1)
            GetBtn.Text = "Get Key"
        end)
    else
        -- Если ключ-система отключена, сразу показываем основное окно
        Frame_1.Visible = true
    end


    function Window:CreateTab(text, iconName)
        local Tab = {}
        local isFirstTab = (#Window.Tabs == 0)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(0, 110, 0, 32); TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); TabBtn.BackgroundTransparency = panelTransparency
        TabBtn.Text = ""; TabBtn.AutoButtonColor = false; TabBtn.ClipsDescendants = true
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", TabBtn).Color = Color3.fromRGB(51, 51, 51)
        AddContent(TabBtn, text, iconName, Color3.fromRGB(237, 232, 248), true)

        local Scroll = Instance.new("ScrollingFrame", Window.MainFrame)
        Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.Visible = isFirstTab
        local layout = Instance.new("UIListLayout", Scroll); layout.Padding = UDim.new(0, 6); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        table.insert(Window.Tabs, Scroll)

        function Tab:CreateToggle(text, neonColor, defaultState, iconName, callback)
            if type(iconName) == "function" then callback = iconName; iconName = nil end
            local state = defaultState or false; local actualColor = GetColor(neonColor)
            local btn = Instance.new("TextButton", Scroll)
            -- Кнопки и тогглы всегда непрозрачные (0)
            btn.Size = UDim2.new(1, -12, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); btn.BackgroundTransparency = 0
            btn.Text = ""; btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", btn).Color = Color3.fromRGB(51, 51, 51)
            
            local content = AddContent(btn, text, iconName, state and actualColor or Color3.fromRGB(112, 112, 112), false)
            -- ... Логика тоггла 
        end

        function Tab:CreateButton(text, iconName, callback)
            if type(iconName) == "function" then callback = iconName; iconName = nil end
            local btn = Instance.new("TextButton", Scroll)
            -- Кнопки и тогглы всегда непрозрачные (0)
            btn.Size = UDim2.new(1, -12, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); btn.BackgroundTransparency = 0
            btn.Text = ""; btn.AutoButtonColor = false; btn.ClipsDescendants = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", btn).Color = Color3.fromRGB(51, 51, 51)
            AddContent(btn, text, iconName, Color3.fromRGB(237, 232, 248), false)

            btn.MouseButton1Down:Connect(function()
                local wave = Instance.new("Frame", btn)
                wave.BackgroundColor3 = isClassicTheme and Color3.fromRGB(255, 255, 255) or selectedTheme
                wave.BackgroundTransparency = 0.8; wave.BorderSizePixel = 0; wave.Position = UDim2.new(0.5, 0, 0.5, 0); wave.AnchorPoint = Vector2.new(0.5, 0.5); wave.Size = UDim2.new(0, 0, 0, 0)
                Instance.new("UICorner", wave).CornerRadius = UDim.new(1, 0)
                local tween = TweenService:Create(wave, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 150), BackgroundTransparency = 1})
                tween:Play(); tween.Completed:Connect(function() wave:Destroy() end)
            end)
        end
        return Tab
    end
    return Window
end

return LuminorLib

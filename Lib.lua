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
    ["cyan"]   = Color3.fromRGB(0, 255, 255)
}

local Themes = {
    ["classic"]      = Color3.fromRGB(255, 255, 255),
    ["классический"] = Color3.fromRGB(255, 255, 255),
    ["rainbow"]      = "rainbow",
    ["радуга"]       = "rainbow",
    ["purple"]       = Color3.fromRGB(192, 132, 252),
    ["red"]          = Color3.fromRGB(255, 85, 85),
    ["mint"]         = Color3.fromRGB(85, 255, 170),
    ["orange"]       = Color3.fromRGB(255, 170, 0)
}

local function GetColor(input, fallbackThemeColor)
    if type(input) == "string" then
        local lower = input:lower()
        if Palette[lower] then return Palette[lower] end
    elseif typeof(input) == "Color3" then
        return input
    end
    if fallbackThemeColor == "rainbow" then return Color3.fromRGB(255, 255, 255) end
    return fallbackThemeColor or Color3.fromRGB(255, 255, 255)
end

local function GetAsset(folderName, githubFolder, fileName)
    if not fileName or fileName == "" then return nil end
    if not (isfile and writefile and makefolder and getcustomasset) then return "" end
    
    local path = folderName .. "/" .. fileName
    if not isfolder(folderName) then makefolder(folderName) end
    
    if not isfile(path) then
        local url = "https://raw.githubusercontent.com/dimkaproska70-hash/LuminorGui/main/" .. githubFolder .. "/" .. fileName
        local s, res = pcall(function() return game:HttpGet(url) end)
        if s and res and not string.find(res, "404: Not Found") then
            writefile(path, res)
        else
            return ""
        end
    end
    return getcustomasset(path)
end

local function AddContent(parent, text, iconName, color, isTab)
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0); contentFrame.BackgroundTransparency = 1; contentFrame.Parent = parent

    local listLayout = Instance.new("UIListLayout", contentFrame)
    listLayout.FillDirection = Enum.FillDirection.Horizontal; listLayout.VerticalAlignment = Enum.VerticalAlignment.Center; listLayout.Padding = UDim.new(0, 8)
    
    if isTab then
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    else
        listLayout.HorizontalAlignment = (text == "" or not text) and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
        if text ~= "" and text then Instance.new("UIPadding", contentFrame).PaddingLeft = UDim.new(0, 12) end
    end

    if text ~= "" and text then
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1; textLabel.Text = text; textLabel.TextColor3 = color
        textLabel.TextSize = 14; textLabel.Font = Enum.Font.SourceSansBold; textLabel.AutomaticSize = Enum.AutomaticSize.X
        textLabel.Size = UDim2.new(0, 0, 1, 0); textLabel.Parent = contentFrame
    end

    if iconName and iconName ~= "" then
        local iconImg = Instance.new("ImageLabel")
        iconImg.BackgroundTransparency = 1; iconImg.Size = UDim2.new(0, 16, 0, 16); iconImg.ImageColor3 = color; iconImg.Parent = contentFrame
        task.spawn(function()
            local asset = GetAsset("LuminorIcons", "Icons", iconName)
            if asset and asset ~= "" then iconImg.Image = asset end
        end)
    end
    
    return contentFrame
end

function LuminorLib:CreateWindow(titleText, uiName, watermarkText, themeName, bgName)
    local Window = { Tabs = {}, TabButtons = {}, TabLines = {} }
    
    local themeKey = themeName and string.lower(themeName) or "classic"
    local selectedTheme = Themes[themeKey] or Themes["classic"]
    local isClassic = (themeKey == "classic" or themeKey == "классический")
    local isRainbow = (selectedTheme == "rainbow")
    
    local isNoneBg = (bgName and string.lower(bgName) == "none")
    local hasBackground = (bgName and bgName ~= "" and not isNoneBg)
    local panelTransparency = hasBackground and 0.3 or 0
    local tabTransparency = hasBackground and 0.3 or 0

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uiName or "LuminorLib_UI"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
    ScreenGui.Parent = safeParent

    local Frame_1 = Instance.new("Frame")
    Frame_1.Size = UDim2.new(0, 338, 0, 301); Frame_1.Position = UDim2.new(0.5, -169, 0.5, -150)
    Frame_1.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Frame_1.ClipsDescendants = true; Frame_1.Parent = ScreenGui
    Instance.new("UICorner", Frame_1).CornerRadius = UDim.new(0, 14)
    
    if hasBackground then
        local isVideo = string.match(string.lower(bgName), "%.mp4$") or string.match(string.lower(bgName), "%.webm$")
        local BackgroundContainer = Instance.new(isVideo and "VideoFrame" or "ImageLabel")
        BackgroundContainer.Size = UDim2.new(1, 0, 1, 0); BackgroundContainer.BackgroundTransparency = 1; BackgroundContainer.ZIndex = 1; BackgroundContainer.Parent = Frame_1
        if isVideo then BackgroundContainer.Looped = true; BackgroundContainer.Playing = true; BackgroundContainer.Volume = 0 else BackgroundContainer.ScaleType = Enum.ScaleType.Crop end
        Instance.new("UICorner", BackgroundContainer).CornerRadius = UDim.new(0, 14)
        task.spawn(function()
            local asset = GetAsset("LuminorBackgrounds", "Background", bgName)
            if asset and asset ~= "" then pcall(function() if isVideo then BackgroundContainer.Video = asset else BackgroundContainer.Image = asset end end) end
        end)
    end
    
    local stroke1 = Instance.new("UIStroke", Frame_1); stroke1.Thickness = 2; stroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke1.Color = Color3.fromRGB(40, 40, 40)
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5); Shadow.BackgroundTransparency = 1; Shadow.Position = UDim2.new(0.5, 0, 0.5, 15)
    Shadow.Size = UDim2.new(1, 60, 1, 60); Shadow.ZIndex = 0; Shadow.Image = "rbxassetid://5028857084"; Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0); Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice; Shadow.SliceCenter = Rect.new(24, 24, 276, 276); Shadow.Parent = Frame_1

    local Frame_2 = Instance.new("Frame")
    Frame_2.Position = UDim2.new(0, 127, 0, 53); Frame_2.Size = UDim2.new(1, -140, 1, -64)
    Frame_2.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Frame_2.BackgroundTransparency = panelTransparency; Frame_2.ZIndex = 2; Frame_2.Parent = Frame_1
    Instance.new("UICorner", Frame_2).CornerRadius = UDim.new(0, 16)
    
    local stroke2 = Instance.new("UIStroke", Frame_2)
    stroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke2.Thickness = 2

    if isClassic then
        stroke2.Color = Color3.fromRGB(150, 150, 150)
    else
        stroke2.Color = Color3.fromRGB(255, 255, 255)
        local gradient = Instance.new("UIGradient", stroke2)
        
        if isRainbow then
            RunService.RenderStepped:Connect(function()
                local t = tick()
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV((t % 5) / 5, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(((t + 1) % 5) / 5, 1, 1))
                })
                gradient.Rotation = (t * 60) % 360
            end)
        else
            local h, s, v = selectedTheme:ToHSV()
            local darkColor = Color3.fromHSV(h, s, v * 0.15)
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, selectedTheme),
                ColorSequenceKeypoint.new(0.5, darkColor),
                ColorSequenceKeypoint.new(1, selectedTheme)
            })
            RunService.RenderStepped:Connect(function()
                gradient.Rotation = (tick() * 75) % 360
            end)
        end
    end

    local Frame_11 = Instance.new("Frame")
    Frame_11.Position = UDim2.new(0, 6, 1, -46); Frame_11.Size = UDim2.new(0, 118, 0, 37)
    Frame_11.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Frame_11.BackgroundTransparency = panelTransparency; Frame_11.ZIndex = 11; Frame_11.Parent = Frame_1
    Instance.new("UICorner", Frame_11).CornerRadius = UDim.new(0, 11)
    local stroke11 = Instance.new("UIStroke", Frame_11); stroke11.Color = Color3.fromRGB(40, 40, 40); stroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local TabContainer = Instance.new("Frame", Frame_1)
    TabContainer.Size = UDim2.new(0, 110, 1, 0); TabContainer.Position = UDim2.new(0, 6, 0, 57); TabContainer.BackgroundTransparency = 1; TabContainer.ZIndex = 2
    local TabListLayout = Instance.new("UIListLayout", TabContainer); TabListLayout.Padding = UDim.new(0, 6); TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Label_12 = Instance.new("TextLabel")
    Label_12.Position = UDim2.new(0, 14, 1, -37); Label_12.Size = UDim2.new(0, 87, 0, 24); Label_12.BackgroundTransparency = 1; Label_12.Text = watermarkText or "By DADILK"
    Label_12.TextColor3 = Color3.fromRGB(150, 150, 150); Label_12.TextSize = 14; Label_12.Font = Enum.Font.Ubuntu; Label_12.TextXAlignment = Enum.TextXAlignment.Left; Label_12.ZIndex = 12; Label_12.Parent = Frame_1

    local Label_15 = Instance.new("TextLabel")
    Label_15.Position = UDim2.new(0, 70, 0, 11); Label_15.Size = UDim2.new(0, 130, 0, 24); Label_15.BackgroundTransparency = 1; Label_15.Text = titleText or "Luminor"
    Label_15.TextColor3 = Color3.fromRGB(255, 255, 255); Label_15.TextSize = 30; Label_15.Font = Enum.Font.Creepster; Label_15.TextXAlignment = Enum.TextXAlignment.Left; Label_15.ZIndex = 15; Label_15.Parent = Frame_1

    local MinimizeBtn = Instance.new("TextButton", Frame_1)
    MinimizeBtn.Position = UDim2.new(1, -97, 0, 10); MinimizeBtn.Size = UDim2.new(0, 42, 0, 31); MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); MinimizeBtn.Text = "•"
    MinimizeBtn.TextColor3 = Color3.fromRGB(245, 236, 0); MinimizeBtn.TextSize = 30; MinimizeBtn.ZIndex = 17; MinimizeBtn.BackgroundTransparency = 0.5
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton", Frame_1)
    CloseBtn.Position = UDim2.new(1, -50, 0, 10); CloseBtn.Size = UDim2.new(0, 42, 0, 31); CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); CloseBtn.Text = "•"
    CloseBtn.TextColor3 = Color3.fromRGB(140, 0, 9); CloseBtn.TextSize = 30; CloseBtn.ZIndex = 17; CloseBtn.BackgroundTransparency = 0.5
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local ResizeHandle = Instance.new("TextButton", Frame_1)
    ResizeHandle.Size = UDim2.new(0, 25, 0, 25); ResizeHandle.Position = UDim2.new(1, 0, 1, 0); ResizeHandle.AnchorPoint = Vector2.new(1, 1); ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = "◢"; ResizeHandle.TextColor3 = Color3.fromRGB(150, 150, 150); ResizeHandle.TextTransparency = 0.6; ResizeHandle.TextSize = 18; ResizeHandle.ZIndex = 20

    local dragging, dragInput, dragStart, startPos
    Frame_1.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Frame_1.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Frame_1.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; Frame_1.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

    local resizing, resizeStart, startSize
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; resizeStart = input.Position; startSize = Frame_1.Size
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizing = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart; Frame_1.Size = UDim2.new(0, math.max(338, startSize.X.Offset + delta.X), 0, math.max(100, startSize.Y.Offset + delta.Y))
        end
    end)

    local isMinimized, savedSize = false, UDim2.new(0, 338, 0, 301)
    local elementsToHide = {Frame_2, Frame_11, TabContainer, Label_12}

    MinimizeBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            savedSize = Frame_1.Size; for _, el in ipairs(elementsToHide) do el.Visible = false end
            TweenService:Create(Frame_1, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 260, 0, 42)}):Play(); ResizeHandle.Visible = false; isMinimized = true
        else
            TweenService:Create(Frame_1, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = savedSize}):Play()
            for _, el in ipairs(elementsToHide) do el.Visible = true end; ResizeHandle.Visible = true; isMinimized = false
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function() Frame_1.Visible = false; task.wait(0.5); ScreenGui:Destroy() end)

    Window.MainFrame = Frame_2

    function Window:CreateTab(text, iconName)
        local Tab = {}
        local isFirstTab = (#Window.Tabs == 0)
        local fallbackAccent = isRainbow and Color3.fromRGB(255, 255, 255) or selectedTheme
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 110, 0, 32); TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); TabBtn.BackgroundTransparency = tabTransparency
        TabBtn.Text = ""; TabBtn.AutoButtonColor = false; TabBtn.ClipsDescendants = true; TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", TabBtn).Color = Color3.fromRGB(51, 51, 51)
        AddContent(TabBtn, text, iconName, Color3.fromRGB(237, 232, 248), true)

        local TabLine = Instance.new("Frame")
        TabLine.Size = UDim2.new(1, -20, 0, 2); TabLine.Position = UDim2.new(0.5, 0, 1, -2); TabLine.AnchorPoint = Vector2.new(0.5, 1)
        TabLine.BackgroundColor3 = isClassic and Color3.fromRGB(200, 200, 200) or fallbackAccent
        TabLine.BorderSizePixel = 0; TabLine.Visible = isFirstTab; TabLine.Parent = TabBtn; TabLine.ZIndex = 5

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0; Scroll.ScrollBarThickness = 2
        Scroll.Parent = Window.MainFrame; Scroll.Visible = isFirstTab; Scroll.ZIndex = 3; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Scroll.ScrollBarImageColor3 = isClassic and Color3.fromRGB(150, 150, 150) or fallbackAccent

        local layout = Instance.new("UIListLayout", Scroll)
        layout.Padding = UDim.new(0, 6); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.SortOrder = Enum.SortOrder.LayoutOrder
        Instance.new("UIPadding", Scroll).PaddingTop = UDim.new(0, 6)

        table.insert(Window.Tabs, Scroll); table.insert(Window.TabButtons, TabBtn); table.insert(Window.TabLines, TabLine)

        TabBtn.MouseButton1Click:Connect(function()
            for i, s in ipairs(Window.Tabs) do s.Visible = (s == Scroll); Window.TabLines[i].Visible = (s == Scroll) end
        end)

        function Tab:CreateToggle(text, defaultState, neonColor, iconName, callback)
            if type(iconName) == "function" then callback = iconName; iconName = nil end
            local state = defaultState or false
            local actualColor = GetColor(neonColor, fallbackAccent)
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -12, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            btn.BackgroundTransparency = hasBackground and 0.5 or 0; btn.Text = ""; btn.AutoButtonColor = false; btn.Parent = Scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", btn).Color = Color3.fromRGB(51, 51, 51)

            local content = AddContent(btn, text, iconName, state and actualColor or Color3.fromRGB(112, 112, 112), false)

            local neonLine = Instance.new("Frame")
            neonLine.Size = UDim2.new(1, -20, 0, 2); neonLine.Position = UDim2.new(0.5, 0, 1, -2); neonLine.AnchorPoint = Vector2.new(0.5, 1)
            neonLine.BackgroundColor3 = actualColor; neonLine.Visible = state; neonLine.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                state = not state; neonLine.Visible = state
                local clr = state and actualColor or Color3.fromRGB(112, 112, 112)
                for _, obj in pairs(content:GetChildren()) do if obj:IsA("TextLabel") or obj:IsA("ImageLabel") then obj.TextColor3 = clr; obj.ImageColor3 = clr end end
                if callback then callback(state) end
            end)
        end

        function Tab:CreateButton(text, iconName, callback)
            if type(iconName) == "function" then callback = iconName; iconName = nil end
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -12, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            btn.BackgroundTransparency = hasBackground and 0.5 or 0; btn.Text = ""; btn.AutoButtonColor = false; btn.ClipsDescendants = true; btn.Parent = Scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", btn).Color = Color3.fromRGB(51, 51, 51)
            AddContent(btn, text, iconName, Color3.fromRGB(237, 232, 248), false)

            btn.MouseButton1Down:Connect(function()
                local wave = Instance.new("Frame")
                wave.BackgroundColor3 = fallbackAccent; wave.BackgroundTransparency = 0.8; wave.BorderSizePixel = 0
                wave.Position = UDim2.new(0.5, 0, 0.5, 0); wave.AnchorPoint = Vector2.new(0.5, 0.5); wave.Size = UDim2.new(0, 0, 0, 0); wave.ZIndex = btn.ZIndex + 1
                Instance.new("UICorner", wave).CornerRadius = UDim.new(1, 0); wave.Parent = btn
                local tween = TweenService:Create(wave, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 150), BackgroundTransparency = 1})
                tween:Play(); tween.Completed:Connect(function() wave:Destroy() end)
            end)
            btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        end

        function Tab:CreateSlider(text, min, max, default, neonColor, iconName, callback)
            if type(iconName) == "function" then callback = iconName; iconName = nil end
            local actualColor = GetColor(neonColor, fallbackAccent)
            local currentValue = math.clamp(default or min, min, max)

            local SliderContainer = Instance.new("Frame")
            SliderContainer.Size = UDim2.new(1, -12, 0, 52); SliderContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15); SliderContainer.Parent = Scroll
            Instance.new("UICorner", SliderContainer).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", SliderContainer).Color = Color3.fromRGB(51, 51, 51)

            local content = AddContent(SliderContainer, text, iconName, Color3.fromRGB(237, 232, 248), false)
            content.Size = UDim2.new(1, -50, 0, 30) 

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 40, 0, 30); ValueLabel.Position = UDim2.new(1, -45, 0, 0); ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(currentValue); ValueLabel.TextColor3 = actualColor; ValueLabel.TextSize = 14; ValueLabel.Font = Enum.Font.SourceSansBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right; ValueLabel.Parent = SliderContainer

            local SliderBg = Instance.new("Frame")
            SliderBg.Size = UDim2.new(1, -24, 0, 4); SliderBg.Position = UDim2.new(0, 12, 0, 36); SliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SliderBg.Parent = SliderContainer
            Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

            local SliderFill = Instance.new("Frame")
            local startPct = (currentValue - min) / (max - min)
            SliderFill.Size = UDim2.new(startPct, 0, 1, 0); SliderFill.BackgroundColor3 = actualColor; SliderFill.Parent = SliderBg
            Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                currentValue = math.floor(min + ((max - min) * pos))
                ValueLabel.Text = tostring(currentValue)
                TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                if callback then callback(currentValue) end
            end

            SliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
        end

        function Tab:CreateDropdown(text, options, default, neonColor, iconName, callback)
            if type(iconName) == "function" then callback = iconName; iconName = nil end
            local actualColor = GetColor(neonColor, fallbackAccent)
            local isDropped = false; local selected = default or (options and options[1]) or ""

            local DropdownContainer = Instance.new("Frame")
            DropdownContainer.Size = UDim2.new(1, -12, 0, 32); DropdownContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            DropdownContainer.ClipsDescendants = true; DropdownContainer.Parent = Scroll
            Instance.new("UICorner", DropdownContainer).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", DropdownContainer).Color = Color3.fromRGB(51, 51, 51)

            local MainBtn = Instance.new("TextButton")
            MainBtn.Size = UDim2.new(1, 0, 0, 32); MainBtn.BackgroundTransparency = 1; MainBtn.Text = ""; MainBtn.Parent = DropdownContainer
            
            local content = AddContent(MainBtn, text, iconName, Color3.fromRGB(237, 232, 248), false); content.Size = UDim2.new(1, -120, 1, 0) 

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0, 90, 1, 0); SelectedLabel.Position = UDim2.new(1, -115, 0, 0); SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Text = tostring(selected); SelectedLabel.TextColor3 = actualColor; SelectedLabel.TextSize = 13
            SelectedLabel.Font = Enum.Font.SourceSansBold; SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right; SelectedLabel.Parent = MainBtn

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 1, 0); Arrow.Position = UDim2.new(1, -25, 0, 0); Arrow.BackgroundTransparency = 1; Arrow.Text = "▼"
            Arrow.TextColor3 = Color3.fromRGB(150, 150, 150); Arrow.Parent = MainBtn

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, 0, 0, 0); OptionsContainer.Position = UDim2.new(0, 0, 0, 32); OptionsContainer.BackgroundTransparency = 1; OptionsContainer.Parent = DropdownContainer
            local OptionsLayout = Instance.new("UIListLayout"); OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder; OptionsLayout.Parent = OptionsContainer

            MainBtn.MouseButton1Click:Connect(function()
                isDropped = not isDropped
                local targetHeight = isDropped and (32 + (#options * 28)) or 32
                TweenService:Create(DropdownContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -12, 0, targetHeight)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = isDropped and 180 or 0}):Play()
            end)

            for _, option in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 28); OptBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OptBtn.Text = "  " .. tostring(option)
                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200); OptBtn.TextSize = 13; OptBtn.Font = Enum.Font.SourceSans; OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.AutoButtonColor = false; OptBtn.Parent = OptionsContainer
                
                OptBtn.MouseButton1Click:Connect(function()
                    selected = option; SelectedLabel.Text = tostring(selected); isDropped = false
                    TweenService:Create(DropdownContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, -12, 0, 32)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    if callback then callback(selected) end
                end)
            end
        end

        function Tab:CreateMarkdown(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -12, 0, 0); Label.AutomaticSize = Enum.AutomaticSize.Y; Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.Font = Enum.Font.SourceSans
            Label.TextWrapped = true; Label.RichText = true; Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Text = text; Label.Parent = Scroll
            return Label
        end

        function Tab:CreateScrollingBox(height)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -12, 0, height or 150); Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Frame.BackgroundTransparency = 0.5; Frame.Parent = Scroll
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local InnerScroll = Instance.new("ScrollingFrame")
            InnerScroll.Size = UDim2.new(1, -10, 1, -10); InnerScroll.Position = UDim2.new(0, 5, 0, 5); InnerScroll.BackgroundTransparency = 1
            InnerScroll.ScrollBarThickness = 4; InnerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; InnerScroll.Parent = Frame
            
            Instance.new("UIListLayout", InnerScroll).Padding = UDim.new(0, 5)
            return InnerScroll
        end

        return Tab
    end
    
    return Window
end

-- ==========================================
-- ПРИМЕР ИСПОЛЬЗОВАНИЯ (ЗАПУСК)
-- ==========================================
local Window = LuminorLib:CreateWindow("Luminor", "LuminorUI", "By DADILK", "red", "none")

local Tab = Window:CreateTab("Главная", "")

-- ВОТ НУЖНЫЙ ТЕБЕ ДРОПДАУН С ВЫБОРОМ ИГРОКОВ:
Tab:CreateDropdown(
    "Выбрать игрока",                   -- Текст слева
    {"Player1", "Player2", "Player3"},  -- Таблица вариантов
    "Player1",                          -- Значение по умолчанию
    "cyan",                             -- Цвет текста выбранной опции
    "",                                 -- Иконка (если есть)
    function(selected)                  -- Функция, вызываемая при выборе
        print("Ты выбрал игрока:", selected)
    end
)

Tab:CreateToggle("Авто-Фарм", false, nil, "", function(state)
    print("Авто-фарм:", state)
end)

return LuminorLib

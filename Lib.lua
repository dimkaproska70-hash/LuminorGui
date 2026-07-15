local LuminorLib = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local safeParent = (gethui and gethui()) or (cloneref and cloneref(CoreGui)) or CoreGui

function LuminorLib:CreateWindow(titleText, uiName, watermarkText)
    local Window = { Tabs = {}, TabButtons = {} }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uiName or "LuminorLib_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
    ScreenGui.Parent = safeParent

    local Frame_1 = Instance.new("Frame")
    Frame_1.Size = UDim2.new(0, 338, 0, 301)
    Frame_1.Position = UDim2.new(0.5, -169, 0.5, -150)
    Frame_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame_1.ClipsDescendants = true
    Frame_1.Parent = ScreenGui

    Instance.new("UICorner", Frame_1).CornerRadius = UDim.new(0, 14)
    local stroke1 = Instance.new("UIStroke", Frame_1); stroke1.Color = Color3.fromRGB(51, 51, 51); stroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Shadow = Instance.new("ImageLabel")
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5); Shadow.BackgroundTransparency = 1; Shadow.Position = UDim2.new(0.5, 0, 0.5, 15)
    Shadow.Size = UDim2.new(1, 60, 1, 60); Shadow.ZIndex = 0; Shadow.Image = "rbxassetid://5028857084"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0); Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice; Shadow.SliceCenter = Rect.new(24, 24, 276, 276); Shadow.Parent = Frame_1

    local Frame_2 = Instance.new("Frame")
    Frame_2.Position = UDim2.new(0, 127, 0, 53); Frame_2.Size = UDim2.new(1, -140, 1, -64)
    Frame_2.BackgroundColor3 = Color3.fromRGB(51, 51, 51); Frame_2.ZIndex = 2; Frame_2.Parent = Frame_1
    Instance.new("UICorner", Frame_2).CornerRadius = UDim.new(0, 16)
    local stroke2 = Instance.new("UIStroke", Frame_2); stroke2.Color = Color3.fromRGB(51, 51, 51); stroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Frame_11 = Instance.new("Frame")
    Frame_11.Position = UDim2.new(0, 6, 1, -46); Frame_11.Size = UDim2.new(0, 118, 0, 37)
    Frame_11.BackgroundColor3 = Color3.fromRGB(0, 0, 0); Frame_11.ZIndex = 11; Frame_11.Parent = Frame_1
    Instance.new("UICorner", Frame_11).CornerRadius = UDim.new(0, 11)
    local stroke11 = Instance.new("UIStroke", Frame_11); stroke11.Color = Color3.fromRGB(51, 51, 51); stroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local TabContainer = Instance.new("Frame", Frame_1)
    TabContainer.Size = UDim2.new(0, 110, 1, 0); TabContainer.Position = UDim2.new(0, 6, 0, 57); TabContainer.BackgroundTransparency = 1

    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.Padding = UDim.new(0, 6); TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Label_12 = Instance.new("TextLabel")
    Label_12.Position = UDim2.new(0, 14, 1, -37); Label_12.Size = UDim2.new(0, 87, 0, 24); Label_12.BackgroundTransparency = 1
    Label_12.Text = watermarkText or "By DADILK"; Label_12.TextColor3 = Color3.fromRGB(192, 132, 252); Label_12.TextSize = 14
    Label_12.Font = Enum.Font.Ubuntu; Label_12.TextXAlignment = Enum.TextXAlignment.Left; Label_12.ZIndex = 12; Label_12.Parent = Frame_1

    local Label_15 = Instance.new("TextLabel")
    Label_15.Position = UDim2.new(0, 70, 0, 11); Label_15.Size = UDim2.new(0, 130, 0, 24); Label_15.BackgroundTransparency = 1
    Label_15.Text = titleText or "Luminor"; Label_15.TextColor3 = Color3.fromRGB(192, 132, 252); Label_15.TextSize = 30
    Label_15.Font = Enum.Font.Creepster; Label_15.TextXAlignment = Enum.TextXAlignment.Left; Label_15.ZIndex = 15; Label_15.Parent = Frame_1

    RunService.Heartbeat:Connect(function()
        local f = (math.sin(tick() * 1.5) + 1) / 2
        Label_12.TextColor3 = Color3.new(f, f, f)
        Label_15.TextColor3 = Color3.new(1 - f, 1 - f, 1 - f)
    end)

    local MinimizeBtn = Instance.new("TextButton", Frame_1)
    MinimizeBtn.Position = UDim2.new(1, -97, 0, 10); MinimizeBtn.Size = UDim2.new(0, 42, 0, 31); MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MinimizeBtn.Text = "•"; MinimizeBtn.TextColor3 = Color3.fromRGB(245, 236, 0); MinimizeBtn.TextSize = 30; MinimizeBtn.ZIndex = 17
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton", Frame_1)
    CloseBtn.Position = UDim2.new(1, -50, 0, 10); CloseBtn.Size = UDim2.new(0, 42, 0, 31); CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.Text = "•"; CloseBtn.TextColor3 = Color3.fromRGB(140, 0, 9); CloseBtn.TextSize = 30; CloseBtn.ZIndex = 17
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local ResizeHandle = Instance.new("TextButton", Frame_1)
    ResizeHandle.Size = UDim2.new(0, 25, 0, 25); ResizeHandle.Position = UDim2.new(1, 0, 1, 0); ResizeHandle.AnchorPoint = Vector2.new(1, 1)
    ResizeHandle.BackgroundTransparency = 1; ResizeHandle.Text = "◢"; ResizeHandle.TextColor3 = Color3.fromRGB(255, 255, 255); ResizeHandle.TextTransparency = 0.6
    ResizeHandle.TextSize = 18; ResizeHandle.ZIndex = 20

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

    local isMinimized, savedSize = false, UDim2.new(0, 338, 0, 301)
    local elementsToHide = {Frame_2, Frame_11, TabContainer, Label_12}

    MinimizeBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            savedSize = Frame_1.Size; for _, el in ipairs(elementsToHide) do el.Visible = false end
            TweenService:Create(Frame_1, TweenInfo.new(0.4), {Size = UDim2.new(0, savedSize.X.Offset, 0, 48)}):Play()
            ResizeHandle.Visible = false; isMinimized = true
        else
            TweenService:Create(Frame_1, TweenInfo.new(0.4), {Size = savedSize}):Play()
            for _, el in ipairs(elementsToHide) do el.Visible = true end
            ResizeHandle.Visible = true; isMinimized = false
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Frame_1.Visible = false; task.wait(0.5); ScreenGui:Destroy()
    end)

    Window.MainFrame = Frame_2

    function Window:CreateTab(iconText)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 110, 0, 32); TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabBtn.Text = iconText; TabBtn.TextColor3 = Color3.fromRGB(237, 232, 248)
        TabBtn.TextSize = 14; TabBtn.Font = Enum.Font.SourceSans; TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", TabBtn).Color = Color3.fromRGB(51, 51, 51)

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1
        Scroll.BorderSizePixel = 0; Scroll.ScrollBarThickness = 2; Scroll.Parent = Window.MainFrame
        Scroll.Visible = (#Window.Tabs == 0)

        local layout = Instance.new("UIListLayout", Scroll)
        layout.Padding = UDim.new(0, 6); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", Scroll); pad.PaddingTop = UDim.new(0, 6)

        table.insert(Window.Tabs, Scroll)
        table.insert(Window.TabButtons, TabBtn)

        TabBtn.MouseButton1Click:Connect(function()
            for _, s in ipairs(Window.Tabs) do s.Visible = (s == Scroll) end
        end)

        function Tab:CreateToggle(text, neonColor, defaultState, callback)
            local state = defaultState or false
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -12, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            btn.Text = text; btn.TextColor3 = state and neonColor or Color3.fromRGB(112, 112, 112)
            btn.TextSize = 14; btn.Font = Enum.Font.SourceSansBold; btn.AutoButtonColor = false; btn.Parent = Scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(51, 51, 51); stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local neonLine = Instance.new("Frame")
            neonLine.Size = UDim2.new(1, -20, 0, 2); neonLine.Position = UDim2.new(0.5, 0, 1, -2)
            neonLine.AnchorPoint = Vector2.new(0.5, 1); neonLine.BackgroundColor3 = neonColor
            neonLine.BorderSizePixel = 0; neonLine.Visible = state; neonLine.Parent = btn

            local neonGlow = Instance.new("Frame")
            neonGlow.Size = UDim2.new(1, 0, 0, 8); neonGlow.Position = UDim2.new(0.5, 0, 1, 3)
            neonGlow.AnchorPoint = Vector2.new(0.5, 1); neonGlow.BackgroundColor3 = neonColor
            neonGlow.BackgroundTransparency = 0.7; neonGlow.BorderSizePixel = 0; neonGlow.Parent = neonLine
            Instance.new("UICorner", neonGlow).CornerRadius = UDim.new(1, 0)

            btn.MouseButton1Click:Connect(function()
                state = not state
                neonLine.Visible = state
                btn.TextColor3 = state and neonColor or Color3.fromRGB(112, 112, 112)
                if callback then callback(state) end
            end)
        end

        return Tab
    end
    
    return Window
end

return LuminorLib

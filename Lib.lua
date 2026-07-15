local LuminorGui = {
    Theme = {
        Background = Color3.fromRGB(25, 25, 25),
        TabBackground = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(255, 255, 255),
        -- Цвет по умолчанию для активной линии (можно переопределить при создании тоггла)
        LineActive = Color3.fromRGB(85, 170, 255),  
        LineInactive = Color3.fromRGB(55, 55, 55)   -- Цвет выключенной линии
    }
}

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function LuminorGui:CreateWindow(titleText)
    local Window = {}
    
    -- Создаем основной ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LuminorGui_UI"
    ScreenGui.Parent = CoreGui
    
    -- Главный фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = self.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 6)
    
    -- Заголовок меню
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "  " .. titleText
    Title.TextColor3 = self.Theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame
    
    -- Контейнер для контента вкладок
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -130, 1, -40)
    Container.Position = UDim2.new(0, 120, 0, 35)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame
    
    Window.Container = Container
    Window.Tabs = {}

    -- Создание новой вкладки
    function Window:CreateTab(tabName)
        local Tab = {}
        
        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.BackgroundTransparency = 1
        Scroll.ScrollBarThickness = 2
        Scroll.Visible = (#self.Tabs == 0) -- Первая вкладка видна по умолчанию
        Scroll.Parent = self.Container
        
        local UIListLayout = Instance.new("UIListLayout", Scroll)
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        table.insert(self.Tabs, Scroll)

        -- Создание переключателя (тоггла) внутри вкладки
        function Tab:CreateToggle(toggleText, customColor, callback)
            local state = false
            -- Если передан свой цвет — берем его, иначе берем дефолтный голубой
            local activeColor = customColor or LuminorGui.Theme.LineActive
            
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(1, -10, 0, 35)
            ToggleBtn.BackgroundColor3 = LuminorGui.Theme.TabBackground
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Parent = Scroll
            
            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)
            
            local ToggleText = Instance.new("TextLabel")
            ToggleText.Size = UDim2.new(1, -20, 1, 0)
            ToggleText.Position = UDim2.new(0, 10, 0, 0)
            ToggleText.BackgroundTransparency = 1
            ToggleText.Text = toggleText
            ToggleText.TextColor3 = LuminorGui.Theme.Text
            ToggleText.TextSize = 14
            ToggleText.Font = Enum.Font.Gotham
            ToggleText.TextXAlignment = Enum.TextXAlignment.Left
            ToggleText.Parent = ToggleBtn
            
            -- Та самая светящаяся/цветная линия слева у кнопки
            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(0, 3, 1, -10)
            Line.Position = UDim2.new(0, 3, 0, 5)
            Line.BackgroundColor3 = LuminorGui.Theme.LineInactive
            Line.BorderSizePixel = 0
            Line.Parent = ToggleBtn
            Instance.new("UICorner", Line).CornerRadius = UDim.new(0, 2)
            
            -- Обработка клика
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                
                -- Плавный переход цвета линии с помощью TweenService
                local targetColor = state and activeColor or LuminorGui.Theme.LineInactive
                TweenService:Create(Line, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                
                if callback then
                    callback(state)
                end
            end)
        end
        
        return Tab
    end
    
    return Window
end

return LuminorGui

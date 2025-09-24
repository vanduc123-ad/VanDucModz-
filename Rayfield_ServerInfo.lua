-- Rayfield_ServerInfo.lua
-- Tab 1: Thông Tin Sever (Server Info)
-- Mô tả: Script tạo GUI (cố gắng load Rayfield khi có) hiển thị:
--  • Số người chơi (ví dụ 10/12)
--  • Danh sách player (tên + avatar thumbnail)
--  • FPS thực
--  • Ping ước lượng
-- Dán file này vào executor (KRNL, Synapse, v.v.) như 1 LocalScript.

-- ========== CÀI ĐẶT VÀ LOAD RAYFIELD (nếu có) ==========
local Rayfield = nil
local success, loaded = pcall(function()
    local urls = {
        "https://raw.githubusercontent.com/shlexware/Rayfield-Library/main/source.lua",
        "https://raw.githubusercontent.com/Kesex/Rayfield-Library/main/source.lua",
        "https://raw.githubusercontent.com/AikaV3/Roblox/main/Rayfield.lua",
    }
    for _, url in ipairs(urls) do
        local ok, lib = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok and lib then
            Rayfield = lib
            break
        end
    end
end)

-- ========== FALLBACK: GUI TỰ TẠO nếu không có Rayfield ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Gui = nil

local function createFallbackGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VanDuc_ServerInfo_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(1, 0)
    main.Size = UDim2.new(0, 360, 0, 420)
    main.Position = UDim2.new(1, -10, 0, 10)
    main.BackgroundTransparency = 0.06
    main.BackgroundColor3 = Color3.fromRGB(20,20,20)
    main.BorderSizePixel = 0
    main.Parent = screenGui

    local uiCorner = Instance.new("UICorner", main)
    uiCorner.CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -12, 0, 36)
    title.Position = UDim2.new(0, 6, 0, 6)
    title.Text = "VanDucModz"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(240,240,240)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1, -12, 0, 20)
    subtitle.Position = UDim2.new(0, 6, 0, 44)
    subtitle.Text = "VanDucModz Gaming"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextColor3 = Color3.fromRGB(200,200,200)
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = main

    -- Info labels container
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.BackgroundTransparency = 1
    infoFrame.Position = UDim2.new(0, 6, 0, 70)
    infoFrame.Size = UDim2.new(1, -12, 0, 56)
    infoFrame.Parent = main

    local playersCount = Instance.new("TextLabel")
    playersCount.Name = "PlayersCount"
    playersCount.BackgroundTransparency = 1
    playersCount.Size = UDim2.new(0.5, -6, 1, 0)
    playersCount.Font = Enum.Font.Gotham
    playersCount.TextSize = 14
    playersCount.TextColor3 = Color3.fromRGB(220,220,220)
    playersCount.Text = "Người chơi: 0/0"
    playersCount.TextXAlignment = Enum.TextXAlignment.Left
    playersCount.Parent = infoFrame

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPS"
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Size = UDim2.new(0.5, -6, 1, 0)
    fpsLabel.Position = UDim2.new(0.5, 6, 0, 0)
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextSize = 14
    fpsLabel.TextColor3 = Color3.fromRGB(220,220,220)
    fpsLabel.Text = "FPS: ..."
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
    fpsLabel.Parent = infoFrame

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "Ping"
    pingLabel.BackgroundTransparency = 1
    pingLabel.Position = UDim2.new(0, 6, 0, 126)
    pingLabel.Size = UDim2.new(1, -12, 0, 20)
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.TextSize = 13
    pingLabel.TextColor3 = Color3.fromRGB(200,200,200)
    pingLabel.Text = "Ping: ... ms"
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Parent = main

    local listFrame = Instance.new("Frame")
    listFrame.Name = "ListFrame"
    listFrame.BackgroundTransparency = 1
    listFrame.Position = UDim2.new(0, 6, 0, 150)
    listFrame.Size = UDim2.new(1, -12, 0, 260)
    listFrame.Parent = main

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "PlayersScroll"
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    scroll.Parent = listFrame

    local uiList = Instance.new("UIListLayout")
    uiList.Parent = scroll
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0,6)

    local uiPadding = Instance.new("UIPadding")
    uiPadding.Parent = scroll
    uiPadding.PaddingTop = UDim.new(0,6)
    uiPadding.PaddingLeft = UDim.new(0,6)
    uiPadding.PaddingRight = UDim.new(0,6)

    return screenGui, {
        PlayersCount = playersCount,
        FPS = fpsLabel,
        Ping = pingLabel,
        Scroll = scroll,
        ListFrame = listFrame,
        Main = main,
    }
end

Gui, Elements = createFallbackGui()

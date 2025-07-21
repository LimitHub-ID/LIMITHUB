--// Services
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local placeId = 126884695634066

--// Function to Create Loading GUI
local function createLoadingGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Background
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.3
    bg.Parent = screenGui

    -- Container for Title
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 400, 0, 50)
    container.Position = UDim2.new(0.5, -200, 0.5, -150)
    container.BackgroundTransparency = 1
    container.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "SERVER HOPPED"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeTransparency = 0.2
    title.Font = Enum.Font.Fantasy
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    -- Loading Bar Outline
    local barOutline = Instance.new("Frame")
    barOutline.Size = UDim2.new(0, 400, 0, 25)
    barOutline.Position = UDim2.new(0.5, -200, 0.5, 0)
    barOutline.BackgroundColor3 = Color3.new(0, 0, 0)
    barOutline.BorderColor3 = Color3.fromRGB(0, 255, 255)
    barOutline.BorderSizePixel = 2
    barOutline.Parent = bg

    -- Fill Bar
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = barOutline

    -- Percentage Label
    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(0, 100, 0, 40)
    percentLabel.Position = UDim2.new(0.5, -50, 0.5, -40)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.new(1, 1, 1)
    percentLabel.TextStrokeTransparency = 0.3
    percentLabel.Font = Enum.Font.Code
    percentLabel.TextScaled = true
    percentLabel.Parent = bg

    -- "LOADING" Text
    local loadingText = Instance.new("TextLabel")
    loadingText.Text = "LOADING"
    loadingText.Size = UDim2.new(0, 400, 0, 70)
    loadingText.Position = UDim2.new(0.5, -200, 0.5, 40)
    loadingText.BackgroundTransparency = 1
    loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
    loadingText.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    loadingText.TextStrokeTransparency = 0.2
    loadingText.Font = Enum.Font.SciFi
    loadingText.TextScaled = true
    loadingText.Parent = bg

    -- Animate Loading
    local percent = 0
    while percent <= 100 do
        percentLabel.Text = percent .. "%"
        fill.Size = UDim2.new(percent / 100, 0, 1, 0)
        percent += 5
        task.wait(0.05)
    end

    task.wait(1)
    screenGui:Destroy()
end

--// Check if came from ServerHop
local teleportData = TeleportService:GetLocalPlayerTeleportData()
if teleportData and teleportData.ServerHopped then
    createLoadingGui()
end

--// Server Hop Function
local function serverHop()
    local cursor = ""
    local smallestServer = nil

    repeat
        local success, result = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync(
                ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(placeId, cursor)
            ))
        end)

        if success and result and result.data then
            for _, server in pairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    if not smallestServer or server.playing < smallestServer.playing then
                        smallestServer = server
                    end
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end

        task.wait(0.2)
    until cursor == ""

    if smallestServer then
        TeleportService:SetTeleportData({ ServerHopped = true })
        TeleportService:TeleportToPlaceInstance(placeId, smallestServer.id, LocalPlayer)
    else
        TeleportService:SetTeleportData({ ServerHopped = true })
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end

--// Call the ServerHop Function
serverHop()

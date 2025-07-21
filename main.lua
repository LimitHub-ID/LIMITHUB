local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local placeId = 126884695634066

-- GUI Function
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Text = "LIMIT HUB"
    title.Font = Enum.Font.SciFi
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeTransparency = 0.2
    title.TextScaled = true
    title.Size = UDim2.new(0, 600, 0, 100)
    title.Position = UDim2.new(0.5, -300, 0.5, -160)
    title.BackgroundTransparency = 1
    title.Parent = bg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 400, 0, 30)
    bar.Position = UDim2.new(0.5, -200, 0.5, -30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bar.BorderSizePixel = 0
    bar.Parent = bg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(0, 100, 0, 40)
    percentLabel.Position = UDim2.new(0.5, -50, 0.5, -70)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.new(1, 1, 1)
    percentLabel.TextStrokeTransparency = 0.3
    percentLabel.Font = Enum.Font.SciFi
    percentLabel.TextScaled = true
    percentLabel.Parent = bg

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

    task.spawn(function()
        local percent = 0
        while percent <= 100 do
            percentLabel.Text = percent .. "%"
            fill.Size = UDim2.new(percent / 100, 0, 1, 0)
            percent += 5
            task.wait(0.1)
        end
        task.wait(1)
        screenGui:Destroy()
    end)
end

-- Server Hop Function
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
        TeleportService:SetTeleportData({ Hopped = true })
        TeleportService:TeleportToPlaceInstance(placeId, smallestServer.id, player)
    else
        TeleportService:SetTeleportData({ Hopped = true })
        TeleportService:Teleport(placeId, player)
    end
end

-- Main
local teleportData = TeleportService:GetLocalPlayerTeleportData()

if teleportData and teleportData.Hopped then
    createGui()
else
    serverHop()
end
